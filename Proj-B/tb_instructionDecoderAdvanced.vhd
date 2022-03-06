library IEEE;
use IEEE.std_logic_1164.all;

entity tb_instructionDecoderAdvanced is
  generic (gCLK_HPER	: time := 50 ns);
end entity;

architecture behavior of tb_instructionDecoderAdvanced is

  -- Calculate the clock period as twice the half-period
	constant cCLK_PER  : time := gCLK_HPER * 2;

  component instruction_decoder
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
          o_Branch        : out std_logic;
          o_MemWrite      : out std_logic;
          o_toShift       : out std_logic_vector (25 downto 0);
          --o_MemRead       : out std_logic;
          o_MemToReg      : out std_logic;

          --added funct_decrypt output selects
          o_shift       : out std_logic;
          o_vectorShift : out std_logic;
          o_shiftLogical  : out std_logic;
          o_jr          : out std_logic;

          --added opcode_decrypt output selects
          o_signExtendSig : out std_logic;    --Select if sign extend
          o_jump          : out std_logic;    --Select if jump
          o_jal           : out std_logic);
  end component;

  signal s_regDst, s_regWrite, s_ALUSrc, s_MemWrite, s_MemToReg, s_Branch : std_logic;
  signal s_shiftSig, s_vectorShift, s_shiftLogical, s_jr, s_signExtendSig, s_jump, s_jal : std_logic;
  signal s_writeAddr, s_readAddr1, s_readAddr2 : std_logic_vector(4 downto 0);
  signal s_ALUCtrlFinal : std_logic_vector (2 downto 0);
  signal s_toShift : std_logic_vector (25 downto 0);
  signal s_signExtend : std_logic_vector(15 downto 0);
  signal s_Instruction : std_logic_vector(31 downto 0);
  signal s_CLK : std_logic;

  begin
    tb_Instruction : instruction_decoder
      port map (
        in_Instruction => s_Instruction,
        o_signExtend => s_signExtend,
        o_writeAddr => s_writeAddr,
        o_readAddr1 => s_readAddr1,
        o_readAddr2 => s_readAddr2,
        o_regDst => s_regDst,
        o_regWrite => s_regWrite,
        o_Branch   => s_Branch,
        o_ALUSrc => s_ALUSrc,
        o_ALUCtrlFinal => s_ALUCtrlFinal,
        o_toShift => s_toShift,
        o_MemWrite => s_MemWrite,
        o_MemToReg => s_MemToReg,

        o_shift => s_shiftSig,
        o_vectorShift => s_vectorShift,
        o_shiftLogical => s_shiftLogical,
        o_jr => s_jr,
        o_signExtendSig => s_signExtendSig,
        o_jump => s_jump,
        o_jal => s_jal
      );


    -- This process sets the clock value (low for gCLK_HPER, then high
		-- for gCLK_HPER). Absent a "wait" command, processes restart
		-- at the beginning once they have reached the final statement.
		P_CLK: process
			begin
				s_CLK <= '0';
				wait for gCLK_HPER;
				s_CLK <= '1';
				wait for gCLK_HPER;
			end process;

      -- Testbench Process
  		P_TB: process
  			begin

          -- R Format
          -- "six op, five rs, five rt, five rd, 5 shamt, 6 funct"
          -- rs = readAddr1
          -- rt = readAddr2
          -- rd = writeAddr
  				-----------------------------------------------------
          -- Instruction ADD to regs of 1 all around
          s_Instruction <= "00000000001000010000100000100000";
          -- Expected:
          -- writeAddr = 00001
          -- readAddr1 = 00001
          -- readAddr2 = 00001
          -- regDst = 1
          -- regWrite = 1
          -- ALUSrc = 0
          -- MemWrite = 0
          -- MemToReg = 0
          -- [MemRead = X, ALUOp = 00]
          -- ALUCtrl = 000
          -- shift = 0
          -- jr = 0
  				wait for cCLK_PER;

          wait for cCLK_PER;
          wait for cCLK_PER;

          -----------------------------------------------------
          -- Instruction BEQ if rs = rt
          s_Instruction <= "00010000001000010000000000000100";
          -- Expected:
          -- readAddr1 = 00001
          -- readAddr2 = 00001
          -- regDst = X
          -- regWrite = 0
          -- ALUSrc = 0
          -- MemWrite = 0
          -- MemToReg = 0
          -- [MemRead = X, ALUOp = XX]
          -- ALUCtrl = 111
          -- branch = 1
          -- jump = 0
          -- funct = 0;
  				wait for cCLK_PER;

          -- Instruction J
          s_Instruction <= "00001000000000000000000000000100";
          -- Expected:
          -- regDst = X
          -- regWrite = X
          -- ALUSrc = X
          -- MemWrite = X
          -- MemToReg = X
          -- [MemRead = X, ALUOp = XX]
          -- ALUCtrl = XXX
          -- branch = 0
          -- jump = 1
  				wait for cCLK_PER;

          -- Instruction jr (first reg matters)
          s_Instruction <= "00000000001000000000000000001000";
          -- Expected:
          -- regDst = X
          -- regWrite = X
          -- ALUSrc = X
          -- MemWrite = X
          -- MemToReg = X
          -- [MemRead = X, ALUOp = XX]
          -- ALUCtrl = XXX
          -- branch = 0
          -- shift = 0
          -- jump = 0
          -- jr = 1
  				wait for cCLK_PER;

      end process;

end architecture;
