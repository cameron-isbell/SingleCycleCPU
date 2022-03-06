library IEEE;
use IEEE.std_logic_1164.all;

entity instruction_decoder is
  port (in_Instruction  : in std_logic_vector(31 downto 0);
        --Extender Input
        o_signExtend    : out std_logic_vector(15 downto 0);  --instruction [15-0]
        --Register stuff below
        o_writeAddr     : out std_logic_vector(4 downto 0);
        o_readAddr1     : out std_logic_vector(4 downto 0); --instruction [25-21]
        o_readAddr2     : out std_logic_vector(4 downto 0); --instruction [20-16]
        --Control stuff below
        o_regDst        : out std_logic;
        o_regWrite      : out std_logic;
        o_ALUSrc        : out std_logic;
        o_ALUCtrlFinal  : out std_logic_vector(2 downto 0); --final ALUCtrl
        o_beq           : out std_logic;
        o_bne           : out std_logic;
        o_MemWrite      : out std_logic;
        o_toShift       : out std_logic_vector (25 downto 0);
        --o_MemRead       : out std_logic;
        o_MemToReg      : out std_logic;

        --added funct_decrypt output selects
        o_shift       : out std_logic;
        o_vectorShift : out std_logic;
        o_shiftLogical  : out std_logic;
        o_shiftRight  : out std_logic;
        o_jr          : out std_logic;

        o_upper         : out std_logic;
        --added opcode_decrypt output selects
        o_signExtendSig : out std_logic;    --Select if sign extend
        o_jump          : out std_logic;    --Select if jump
        o_jal           : out std_logic);
end instruction_decoder;

architecture structure of instruction_decoder is

  component opcode_decrypt
    port (in_Opcode  : in std_logic_vector(5 downto 0);  --instruction [31-26] (opcode)
          o_regDst        : out std_logic;
          o_regWrite      : out std_logic;
          o_ALUOp         : out std_logic_vector(1 downto 0); --ALUOp1 and ALUOp0 (The "select values" of the ALU_Control)
          o_ALUSrc        : out std_logic;
          o_ALUCtrl       : out std_logic_vector(2 downto 0);
          o_funct         : out std_logic;          --Select funciton (1 if ALU info from funct_decrypt, 0 if ALU infor from opcode_decrypt)
          o_MemWrite      : out std_logic;
          o_MemRead       : out std_logic;
          o_MemToReg      : out std_logic;
          o_signExtend    : out std_logic;    --Select if sign extend
          o_jump          : out std_logic;    --Select if jump
          o_jal           : out std_logic;
          o_beq           : out std_logic;
          o_bne           : out std_logic;
          o_upper         : out std_logic  );
  end component;

  component funct_decrypt
    port( in_functCode  : in std_logic_vector(5 downto 0);  --instruction [5-0] (function code) get it from instruction IMem
          in_enable      : in std_logic;                     --enable values
          in_ALUOp      : in std_logic_vector(1 downto 0);  --ALUOp0 and ALUOp1 from control_Unit
          o_shift       : out std_logic;
          o_vectorShift : out std_logic;
          o_shiftLogical  : out std_logic;
          o_shiftRight  : out std_logic;
          o_jr          : out std_logic;
          o_ALUCtrl     : out std_logic_vector(2 downto 0)); --feeds to ALU acting as control
  end component;

  component NMux
    generic(N : integer := 5);
    port(in_Select : in std_logic;
         in_A : in std_logic_vector((N - 1) downto 0);    --RegDst = 0 (instruction[20-16] goes to write register)
         in_B : in std_logic_vector((N - 1) downto 0);    --RegDst = 1 (instruction[15-11] goes to write register)
         o_F : out std_logic_vector((N - 1) downto 0));
  end component;

  signal s_ALUOp : std_logic_vector(1 downto 0); --ALUOp1 and ALUOp0 (The "select values" of the ALU_Control)
  signal s_regDst, s_funct, s_shift : std_logic;
  signal s_functOut, s_optcodeOut : std_logic_vector(2 downto 0);

  begin

    opcode_setup : opcode_decrypt
      port map( in_Opcode => in_Instruction(31 downto 26),
                o_regDst => s_regDst,
                o_regWrite => o_regWrite,
                o_ALUOp => s_ALUOp,
                o_ALUSrc => o_ALUSrc,
                o_ALUCtrl => s_optcodeOut,
                o_MemWrite => o_MemWrite,
                o_MemToReg => o_MemToReg,

                o_funct => s_funct,
                o_signExtend => o_signExtendSig,
      				  o_jump => o_jump,
      				  o_jal => o_jal,
      				  o_beq => o_beq,
                o_bne => o_bne,
                o_upper => o_upper
      );

    function_setup : funct_decrypt
      port map( in_functCode => in_Instruction(5 downto 0), --instruction [5-0] (function code) get it from instruction IMem

                in_enable => s_funct,           --Will only go through if function is needed
                in_ALUOp => s_ALUOp,                        --ALUOp0 and ALUOp1 from control_Unit

                o_shift => s_shift,
                o_vectorShift => o_vectorShift,
                o_shiftLogical => o_shiftLogical,
                o_jr => o_jr,

                o_ALUCtrl => s_functOut,                  --feeds to ALU acting as control
                o_shiftRight => o_shiftRight
      );

    RegDst_Mux : NMux
      port map( in_Select => s_regDst,
                in_A => in_Instruction(20 downto 16), --RegDst = 0 (instruction[20-16] goes to write register)
                in_B => in_Instruction(15 downto 11), --RegDst = 1 (instruction[15-11] goes to write register)
                o_F => o_writeAddr
      );

    ALU_C : NMux
        generic map (N => 3)
        port map (  in_Select => s_funct,
                    in_A => s_optcodeOut,
                    in_B => s_functOut,
                    o_F => o_ALUCtrlFinal);

    muxShift : NMux
    generic map ( N => 1 )
    port map (
      in_Select => s_funct,
      in_A(0)      => '0',
      in_B(0)      => s_shift,

      o_F(0)       => o_shift );

      o_regDst <= s_regDst;
      o_readAddr1 <= in_Instruction(25 downto 21);  --instruction [25-21]
      o_readAddr2 <= in_Instruction(20 downto 16);  --instruction [20-16]
      o_signExtend <= in_Instruction(15 downto 0);  --instruction [15-0]
      o_toShift <= in_Instruction(25 downto 0);

end architecture;
