-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------

--Cameron Isbell
--SingleCycleProcessor

--The top level of Proj-B part 1.
--Based off the provided diagram in Proj-B.pdf

library IEEE;
use IEEE.std_logic_1164.all;

entity MIPS_Processor is
  generic(N : integer := 32);
  port(
    iCLK            : in std_logic;
    iRST            : in std_logic;
    iInstLd         : in std_logic;
    iInstAddr       : in std_logic_vector(N-1 downto 0);
    iInstExt        : in std_logic_vector(N-1 downto 0);
    oALUOut         : out std_logic_vector(N-1 downto 0));

end  MIPS_Processor;

architecture structure of MIPS_Processor is

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
  val_out2: out std_logic_vector(numBits-1 downto 0 );
  v0	  : out std_logic_vector(numBits-1 downto 0) );
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
        o_shiftRight  : out std_logic;
        o_shiftLogical  : out std_logic;
        o_jr          : out std_logic;
        o_upper       : out std_logic;

        --added opcode_decrypt output selects
        o_signExtendSig : out std_logic;    --Select if sign extend
        o_jump          : out std_logic;    --Select if jump
        o_jal           : out std_logic );
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

component ALU_32b
  generic (numBits : integer := 32; selectBits : integer := 3);
  port (
  	i_A 		: in std_logic_vector(numBits-1 downto 0);		--input/operand A
  	i_B 		: in std_logic_vector(numBits-1 downto 0);		--input/operand B
  	i_Control	: in std_logic_vector(selectBits-1 downto 0);	--control input, each bit used to control a 1bit ALU

  	F	  		: inout std_logic_vector(numBits-1 downto 0); 	--Output
  	CarryOut	: out std_logic;
  	Overflow	: out std_logic;
  	Zero		: out std_logic );
  end component;


component zero_extender_16to32
  generic (givenBits : integer := 16;
  targetBits: integer := 32);
  port (
  --assuming given value to extend is 2's complemented
  toExtend : in std_logic_vector(givenBits-1 downto 0);
  extended : out std_logic_vector(targetBits-1 downto 0) );

end component;

component check_equivalent
  generic (numBits : integer := 32);
  port (
    i_A : in std_logic_vector(numBits-1 downto 0);
    i_B : in std_logic_vector(numBits-1 downto 0);
    o_F : out std_logic );

end component;

-- Required data memory signals
signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- todo?? : use this signal as the final data memory address input
signal s_DMemData     : std_logic_vector(N-1 downto 0); -- DONE : use this signal as the final data memory data input
signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- DONE?? : use this signal as the data memory output

-- Required register file signals
signal s_RegWr        : std_logic; -- DONE: use this signal as the final active high write enable input to the register file
signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- DONE: use this signal as the final destination register address input
signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- DONE: use this signal as the final data memory data input

-- Required instruction memory signals
signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- DONE: use this signal as your intended final instruction memory address input.
signal s_Inst         : std_logic_vector(N-1 downto 0); -- DONE: use this signal as the instruction signal

-- Required halt signal -- for simulation
signal v0             : std_logic_vector(N-1 downto 0); -- DONE: should be assigned to the output of register 2, used to implement the halt SYSCALL
signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. This case happens when the syscall instruction is observed and the V0 register is at 0x0000000A. This signal is active high and should only be asserted after the last register and memory writes before the syscall are guaranteed to be completed.

--MY SIGNALS

signal s_PCinc, s_signExtOut, s_iMemInstr, s_regALUout, s_muxImmOut, s_muxBranch : std_logic_vector (N-1 downto 0);
signal s_toShiftExtd, s_jumpAddrShift, s_jumpAddr32, s_jumpSum, s_MuxJumpOut, s_signExtShift : std_logic_vector (N-1 downto 0);
signal s_iMemExt32,  s_PCp4pSignExt, s_muxPC, s_jumpMuxOut, s_temp, s_resetMuxOut,  s_PCout, s_muxPCin : std_logic_vector (N-1 downto 0);
signal s_immShift, s_DMemOutShift16, s_muxShiftRes, s_immShift16, s_ALUin,  s_muxShiftOut, s_shiftToUse : std_logic_vector(N-1 downto 0);

signal s_rfileOut1, s_rfileOut2, s_PCplus4, s_ALUoutShifted            : std_logic_vector (N-1 downto 0);
signal s_zero,  s_branchMuxSel,  s_eq,  id_vShift : std_logic;
signal s_JAddr : std_logic_vector (25 downto 0);

--signals from control unit
signal cu_branch, cu_ALUSrc,  cu_MemtoReg, cu_memRead, cu_RegDst, cu_Jump, s_overflow, cu_beq, cu_bne  : std_logic;
signal id_shift, id_shiftRight, id_upper,  s_ShiftWBEn : std_logic;
signal cu_ALUctrl : std_logic_vector(2 downto 0);

--signals from instruction decoder
signal id_readAddr1, id_readAddr2 : std_logic_vector (4 downto 0);
signal id_signExtend : std_logic_vector (15 downto 0);
signal id_toShift    : std_logic_vector (25 downto 0);

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
    iInstAddr when others;

  IMem: mem
    generic map (ADDR_WIDTH => 10,
                 DATA_WIDTH => N )
    port map (
      clk  => iCLK,
      addr => s_IMemAddr(11 downto 2),
      data => iInstExt,
      we   => iInstLd,
      q    => s_Inst);

  DMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(
      clk  => iCLK,
      addr => s_DMemAddr(11 downto 2),
      data => s_DMemData,
      we   => s_DMemWr,
      q    => s_DMemOut);

  --set halt to 1 to end the program on these conditions
  s_Halt <='1' when (s_Inst(31 downto 26) = "000000") and (s_Inst(5 downto 0) = "001100") and (v0 = "00000000000000000000000000001010") else '0';

--MY PROCESSOR IMPLEMENTATION

muxPCIn : NMux
generic map (N => 32)
port map (
  in_select => iRST,
  in_A => s_jumpMuxOut,
  in_B => X"00000000",

  o_F => s_muxPCin );

PC : reg_nbit
generic map (N => 32)
port map (
  i_CLK => iCLK,
  i_R => '0',
  i_W => '1',

  in_data => s_muxPCin,
  out_data => s_PCout );

muxIMemIn : NMux
generic map (N => 32)
port map (
  in_select => iRST,
  in_A      => s_PCout,
  in_B      => X"00000000",

  o_F       => s_NextInstAddr );

incrPC : add_sub
generic map (N => 32)
  port map (
    a_in    => s_PCout,
    b_in    => X"00000004",
    c_in 	  => '0',
    sub_in  => '0',

    result  => s_PCplus4,
    c_out  	=> open );

--extend the 26 bit value to be able to shift it w/ the barrel_shift
zeroExtIMem : zero_extender_16to32
generic map (givenBits => 26, targetBits => 32)
  port map (
    toExtend => id_toShift,
    extended => s_iMemExt32 );

--shift the jump address by 2
sll2_jumpAddr : barrel_shift
generic map ( numBits => 32, shiftLen => 5 )
port map (
  i_A     => s_iMemExt32,
  i_Shift => "00010",
  i_srl   => '0',
  o_F     => s_jumpAddrShift );

--because the barrel shifter can only deal with 32 bits, append the proper values
s_jumpAddr32(27 downto 0) <= s_jumpAddrShift(27 downto 0);
s_jumpAddr32(31 downto 28) <= s_PCplus4(31 downto 28);


findEq : check_equivalent
port map (
  i_A => s_rFileOut1,
  i_B => s_rFileOut2,
  o_F => s_eq );

s_branchMuxSel <= (s_eq and cu_beq) or (not s_eq and cu_bne);

muxBranchOut : NMux
generic map (N => 32)
port map (
  in_select => s_branchMuxSel,
  in_A => s_PCplus4,
  in_B => s_PCp4pSignExt,
  o_F =>  s_muxBranch  );

finalJumpMux : NMux
generic map (N => 32)
port map (
  in_select => cu_Jump,
  in_A      => s_muxBranch,
  in_B      => s_jumpAddr32,
  o_F       => s_jumpMuxOut );

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
  a_in 	  => s_PCplus4,
  b_in    => s_signExtShift,
  c_in    => '0',
  sub_in  => '0',

  result  => s_PCp4pSignExt,
  c_out   => open );

--creates usable signals based on a given binary input
instrDecode : instruction_decoder
port map (
  in_Instruction  => s_Inst,
  --Extender Input
  o_signExtend    => id_signExtend,
  --Register stuff below
  o_writeAddr     => s_RegWrAddr,
  o_readAddr1     => id_readAddr1,
  o_readAddr2     => id_readAddr2,
  --Control stuff below
  o_regDst        => cu_regDst,
  o_regWrite      => s_RegWr,
  o_ALUSrc        => cu_ALUSrc,
  o_beq           => cu_beq,
  o_bne           => cu_bne,
  o_MemWrite      => s_DMemWr,
  o_ALUCtrlFinal  => cu_ALUctrl,
  o_toShift       => id_toShift,
  o_upper         => id_upper,
  o_vectorShift   => id_vShift,

  o_shift         => id_shift,
  o_shiftRight    => id_shiftRight,
  o_MemToReg      => cu_MemtoReg,
  o_jump          => cu_Jump );

--registers storing information
rFile : reg_file_2out
generic map (numBits => 32, numItems => 32)
  port map (
  s_in0	   => s_RegWrAddr,
  s_in1    => id_readAddr1,
  s_in2 	 => id_readAddr2,
  r_in     => iRST,
  in_data  => s_RegWrData,
  w_in 	   => s_RegWr,
  i_CLK    => iCLK,

  val_out1 => s_rfileOut1,
  val_out2 => s_rfileOut2,
  v0   		 => v0 );

--input to the dmem is rFileOut2
  s_DMemData <= s_rFileOut2;

--sign extend the immediate value to 32 bits to make it fit in the ALU
sExtend : sign_extender_16to32
generic map (givenBits => 16, targetBits => 32)
port map (
  toExtend => id_signExtend,
  extended => s_signExtOut );

sInst : barrel_shift
port map (
  --shift depending on if using the immediate value or the reg-file value
  i_A =>     s_muxImmOut,
  i_Shift => s_muxImmOut(4 downto 0),
  i_srl   => id_shiftRight,

  o_F => s_immShift );

sUpper : barrel_shift
port map (
  i_A => s_signExtOut,
  i_Shift => "10000",
  i_srl => '0',

  o_F => s_immShift16 );

sToUse : NMux
port map (
  in_select => id_upper,
  in_A      => s_immShift,
  in_B      => s_immShift16,

  o_F       => s_shiftToUse );

--decides if the immediate value or if another register will be used in computing
immMux : NMux
generic map (N => 32)
port map (
  in_Select => cu_ALUSrc,
  in_A => s_rFileOut2,
  in_B => s_signExtOut,
  o_F  => s_muxImmOut );

--ALU after the register file, used to compute
ALU_rFileOut : ALU_32b
generic map (numBits => 32, selectBits => 3)
port map (
  i_A       => s_rFileOut1,
  i_B       => s_muxImmOut,
  i_Control => cu_ALUctrl,

  F	  	  	=> s_regALUout,
  CarryOut	=> open,
  Overflow  => s_overflow,
  Zero		  => s_zero );

oALUOut <= s_regALUout;
s_DMemAddr <= s_regALUout;

s_ShiftWBEn <= id_upper or id_shift;
MuxShiftWB : NMux
port map (
  in_select => s_ShiftWBEn,
  in_A      => s_regALUout,
  in_B      => s_shiftToUse,

  o_F => s_muxShiftOut );

--Decides if the output past the memory will be from the ALU or from the memory
DMemMux : NMux
generic map (N => 32)
port map (
  in_Select => cu_MemtoReg,
  in_A => s_muxShiftOut,
  in_B => s_DMemout,
  o_F  => s_RegWrData );

end structure;
