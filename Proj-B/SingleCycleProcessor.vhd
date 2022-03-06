--Cameron Isbell
--SingleCycleProcessor

--The top level of Proj-B part 1.
--Based off the provided diagram in Proj-B.pdf

library IEEE;
use IEEE.std_logic_1164.all;

entity SingleCycleProcessor is
  generic (numBits : integer := 32);
  port (i_CLK : in std_logic );

end SingleCycleProcessor;

architecture structure of SingleCycleProcessor is

component add_sub
  generic(N : integer := 32);
  port (
    a_in 	: in std_logic_vector (N -1 downto 0);
    b_in 	: in std_logic_vector (N -1 downto 0);
    c_in 	: in std_logic;
    sub_in  : in std_logic;

    result 	: out std_logic_vector(N-1 downto 0);
    c_out  	: out std_logic );

end component;

component ALU_32b_shift
  generic (numBits    : integer := 32;
           selectBits : integer := 3;
           shiftLen   : integer := 5 );
  port (
    i_A 		  : in std_logic_vector(numBits-1 downto 0);		--input/operand A
    i_B 	   	: in std_logic_vector(numBits-1 downto 0);		--input/operand B
    i_Control	: in std_logic_vector(selectBits-1 downto 0);	--control input, each bit used to control a 1bit ALU

    i_srl     : in std_logic;
    i_Shift   : in std_logic_vector (shiftLen-1 downto 0);
    i_sEn     : in std_logic;

    F	  	  	: inout std_logic_vector(numBits-1 downto 0); 	--Output
    CarryOut	: out std_logic;
    Overflow	: out std_logic;
    Zero		  : out std_logic );
end component;

component NMux
  generic(N : integer := 32);
  port(in_Select : in std_logic;
       in_A : in std_logic_vector((N - 1) downto 0);
       in_B : in std_logic_vector((N - 1) downto 0);
       o_F : out std_logic_vector((N - 1) downto 0));
end component;

component barrel_shift
  generic(numBits : integer := 32;
          shiftLen : integer := 5 );
  port (
      i_A     : in std_logic_vector(numBits-1 downto 0);
      i_Shift : in std_logic_vector(shiftLen-1 downto 0);
      i_srl   : in std_logic;
      o_F     : out std_logic_vector(numBits-1 downto 0) );
end component;

component mem
  generic
  (
    --the length of the bits being loaded
    DATA_WIDTH : natural := 32;
    --the width of the address
    ADDR_WIDTH : natural := 10
  );

  port
  (
    clk		: in std_logic; --clock
    addr	        : in std_logic_vector((ADDR_WIDTH-1) downto 0); --address to write to
    data	        : in std_logic_vector((DATA_WIDTH-1) downto 0); --data to write
    we		: in std_logic;											--write enable
    q		: out std_logic_vector((DATA_WIDTH -1) downto 0)		--output the memory at the given address
  );

end component;

component reg_file_2out
  generic (numBits : integer := 32;
  	 numItems : integer := 32);

  port (
  		s_in0	  : in std_logic_vector (4 downto 0);
  		s_in1   : in std_logic_vector (4 downto 0);
  		s_in2 	: in std_logic_vector (4 downto 0);
  		r_in    : in std_logic;
  		in_data : in std_logic_vector(numBits-1 downto 0);
  		w_in 	  : in std_logic;
  		i_CLK   : in std_logic;

  		val_out1: out std_logic_vector(numBits-1 downto 0 );
  		val_out2: out std_logic_vector(numBits-1 downto 0 ) );
end component;

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
      o_Branch        : out std_logic;
      o_MemWrite      : out std_logic;
      o_ALUCtrl       : out std_logic_vector (2 downto 0);
      o_toShift       : out std_logic_vector (25 downto 0);
      --o_MemRead       : out std_logic;
      o_MemToReg      : out std_logic);
end component;

component andg2
  port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

component sign_extender_16to32
  generic (givenBits : integer := 16;
  	 targetBits: integer := 32);
  port (
  	--assuming given value to extend is 2's complemented
  	toExtend : in std_logic_vector(givenBits-1 downto 0);
  	extended : out std_logic_vector(targetBits-1 downto 0) );
end component;

component reg_nbit
  generic (N : integer := 32);
  port (
  	i_CLK 		: in std_logic;
  	i_R				: in std_logic;
  	i_W		    : in std_logic;

  	in_data 	: in std_logic_vector (N-1 downto 0);
  	out_data	: inout std_logic_vector (N-1 downto 0) );
end component;

component zero_extender_16to32
  generic (givenBits : integer := 16;
  	 targetBits: integer := 32);
  port (
  	--assuming given value to extend is 2's complemented
  	toExtend : in std_logic_vector(givenBits-1 downto 0);
  	extended : out std_logic_vector(targetBits-1 downto 0) );

end component;

--intermediate values
signal s_signExtOut, s_iMemInstr, s_regALUout, s_muxImmOut, s_dMemOut, s_dMemMuxOut,
    s_jumpAddrShift, s_jumpAddr32, s_PCp4ext, s_MuxJumpOut, s_signExtShift,
    s_iMemExt32,  s_PCp4pSignExt, s_muxPC, s_rfileOut1, s_rfileOut2, s_PCplus4  : std_logic_vector (numBits-1 downto 0);

signal s_iMemAddr : std_logic_vector (9 downto 0);

--signals from control unit
signal cu_regWrite, cu_branch, cu_ALUSrc, cu_MemWrite, cu_MemtoReg, cu_memRead, cu_RegDst, cu_Jump, s_zero,  s_branchMuxSel  : std_logic;
signal cu_ALUctrl : std_logic_vector(2 downto 0);

--signals from instruction decoder
signal id_readAddr1, id_readAddr2, id_writeAddr : std_logic_vector (4 downto 0);
signal id_signExtend  : std_logic_vector (15 downto 0);
signal id_jValToShift : std_logic_vector (25 downto 0);

begin

PC : reg_nbit
  generic map (N => 32)
  port map (
    i_CLK => i_CLK,
    i_R => '0'
    i_W => '1',

    in_data => s_MuxJumpOut,
    out_data => s_iMemAddr );

incrPC : add_sub
  generic map (N => 32)
    port map (
      a_in    => s_iMemAddr,
      b_in    => X"00000004",
      c_in 	  => '0',
      sub_in  => '0',

      result  => s_PCplus4,
      c_out  	=> open );

--extend PC +4 to add it with the sign-extended value
zeroExtPCp4 : zero_extender_16to32
  generic map (givenBits => 4, targetBits => 32)
  port map (
    toExtend => s_PCplus4,
    extended => s_PCp4ext );

--extend the 25 bit value to be able to shift it w/ the barrel_shift
zeroExtIMem : zero_extender_16to32
  generic map (givenBits => 25, targetBits => 32)
    port map (
    	toExtend => id_jValToShift,
    	extended => s_iMemExt32 );

--shift the jump address by 2
sll2_jumpAddr : barrel_shift
  generic map (numBits => 32, shiftLen => 5)
    port map (
      i_A     => s_iMemExt32,
      i_Shift => "00010",
      i_srl   => '0',
      o_F     => s_jumpAddrShift );

--because the barrel shifter can only deal with 32 bits, append the proper values
s_jumpAddr32(27 downto 0) <= s_jumpAddrShift(27 downto 0);
s_jumpAddr32(31 downto 28) <= s_PCplus4;

--decide if we're going to go to PC+4 or to the given branch/jump address
muxJumpAddr : NMux
  generic map (N => 32)
  port map (
    in_select => s_branchMuxSel,
    in_A => s_PCp4ext,
    in_B =>  s_PCp4pSignExt,
    o_F => s_muxPC  );

--mux the output of the jump
finalJumpMux : NMux
  generic map (N => 32)
  port map (
    in_select => cu_Jump,
    in_A      => s_muxPC,
    in_B      => s_jumpAddr32,
    o_F       => s_MuxJumpOut );

--shift the sign extended value by 4 to fit with the branch immediate value
sll2_signExt : barrel_shift
  generic map (numBits => 32, shiftLen => 5)
    port map (
      i_A     => s_signExtOut,
      i_Shift => "00010",
      i_srl   => '0',
      o_F     => s_signExtShift );


--Deciding whether or not to branch based on cu_branch, which should never be true for this portion of the processor
PCincSignExt: add_sub
  generic map(N => 32)
    port map (
      a_in 	  => s_PCp4ext,
      b_in    => s_signExtShift,
      c_in    => '0',
      sub_in  => '0',

      result  => s_PCp4pSignExt,
      c_out   => open );

--decides if a branch will happen based on ALU output zero AND branch
andZero : andg2
  port map (
     i_A  => s_zero,
     i_B  => cu_branch,
     o_F  => s_branchMuxSel );

--Memory storing the instructions to perform with a 4 byte offset
I_mem : mem
  generic map (DATA_WIDTH => 32, ADDR_WIDTH => 10)
    port map (
      clk  => i_CLK,
      addr => s_iMemAddr,
      data => X"DEADBEEF", --TEMP VALUE... HOW TO PUT INSTRUCTIONS INTO MEM?
      we	 => '0',         --TEMP VALUE... ONLY TIME TO WRITE IS WHEN PUTTING VALUES INTO MEM
      q		 => s_iMemInstr );

--creates usable signals based on a given binary input
instrDecode : instruction_decoder
  port map (
    in_Instruction  => s_iMemInstr,
    --Extender Input
    o_signExtend    => id_signExtend,
    --Register stuff below
    o_writeAddr     => id_writeAddr,
    o_readAddr1     => id_readAddr1,
    o_readAddr2     => id_readAddr2,
    --Control stuff below
    o_regDst        => cu_regDst,
    o_regWrite      => cu_regWrite,
    o_ALUSrc        => cu_ALUSrc,
    o_Branch        => cu_branch,
    o_MemWrite      => cu_MemWrite,
    o_ALUCtrl       => cu_ALUctrl,
    o_toShift       => id_jValToShift,
    o_MemToReg      => cu_MemtoReg );

--registers storing information
rFile : reg_file_2out
  generic map (numBits => 32, numItems => 32)
    port map (
      s_in0	   => id_writeAddr,
      s_in1    => id_readAddr1,
      s_in2 	 => id_readAddr2,
      r_in     => '0',
      in_data  => s_dMemMuxOut,
      w_in 	   => cu_regWrite,
      i_CLK    => i_CLK,

      val_out1 => s_rfileOut1,
      val_out2 => s_rfileOut2 );

--sign extend the immediate value to 32 bits to make it fit in the ALU
sExtend : sign_extender_16to32
    generic map (givenBits => 16, targetBits => 32)
      port map (
        toExtend => id_signExtend,
        extended => s_signExtOut );

--decides if the immediate value or if another register will be used in computing
immMux : NMux
  generic map (N => 32)
    port map (
      in_Select => cu_ALUSrc,
      in_A => s_rFileOut2,
      in_B => s_signExtOut,
      o_F  => s_muxImmOut );

--ALU after the register file, used to compute
ALU_rFileOut : ALU_32b_shift
  generic map (numBits => 32,
               selectBits => 3,
               shiftLen => 5  )
    port map (
      i_A       => s_rFileOut1,
      i_B       => s_rFileOut2,
      i_Control => cu_ALUctrl,

      i_srl     => '0', --TEMP VALUE HOW TO GET DATA FOR THIS OUT OF INSTRUCTION?
      i_Shift   => "00000", --TEMP VALUE HOW TO GET DATA FOR THIS OUT OF INSTRUCTION?
      i_sEn     => '0', --TEMP VALUE HOW TO GET DATA FOR THIS OUT OF INSTRUCTION?

      F	  	  	=> s_regALUout,
      CarryOut	=> open,
      Overflow  => open,
      Zero		  => s_zero );

--The data memory that the register file can use to store and load data
D_mem : mem
  generic map (DATA_WIDTH => 32, ADDR_WIDTH => 10)
    port map (
      clk  => i_CLK,
      addr => s_regALUout,  --based off the given diagram, but the sizes are mismatched
      data => s_rFileOut2,
      we	 => cu_MemWrite,
      q		 => s_dMemOut );

--Decides if the output past the memory will be from the ALU or from the memory
DMemMux : NMux
  generic map (N => 32)
    port map (
      in_Select => cu_MemtoReg,
      in_A => s_dMemOut,
      in_B => s_regALUout,
      o_F  => s_dMemMuxOut );

end structure;
