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

  val_out1: out std_logic_vector(numBits-1 downto 0);
  val_out2: out std_logic_vector(numBits-1 downto 0);
  v0	    : out std_logic_vector(numBits-1 downto 0);
  ra			: out std_logic_vector(numBits-1 downto 0) );
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

component ALU_32b_shift
  generic ( numBits    : integer    := 32; 
            selectBits : integer    := 3;
            shiftLen   : integer    := 5 );
  port (
    i_A 		  : in std_logic_vector(numBits-1 downto 0);		--input/operand A
    i_B 		  : in std_logic_vector(numBits-1 downto 0);		--input/operand B
    i_Control	: in std_logic_vector(selectBits-1 downto 0);	--control input, each bit used to control a 1bit ALU

    i_Srl     : in std_logic;
    i_Shift   : in std_logic_vector(shiftLen-1 downto 0);
    i_sEn     : in std_logic; 

    F	  		  : inout std_logic_vector(numBits-1 downto 0); 	--Output
    CarryOut	: out std_logic;
    Overflow	: out std_logic;
    Zero		  : out std_logic );
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

component IF_ID
generic (N : integer := 32);
port (
	i_CLK 			: in std_logic; --clock for dff
	i_stall			: in std_logic;
	i_data 			: in std_logic_vector (N-1 downto 0);
	
	o_data		  : out std_logic_vector (N-1 downto 0) );
end component;

-- Required data memory signals
signal s_DMemWr       : std_logic;
signal s_DMemAddr     : std_logic_vector(N-1 downto 0); 
signal s_DMemData     : std_logic_vector(N-1 downto 0);
signal s_DMemOut      : std_logic_vector(N-1 downto 0); 

-- Required register file signals
signal s_RegWr        : std_logic; 
signal s_RegWrAddr    : std_logic_vector(4 downto 0); 
signal s_RegWrData    : std_logic_vector(N-1 downto 0);

-- Required instruction memory signals
signal s_IMemAddr     : std_logic_vector(N-1 downto 0);
signal s_NextInstAddr : std_logic_vector(N-1 downto 0);
signal s_Inst         : std_logic_vector(N-1 downto 0); 

-- Required halt signal -- for simulation
signal v0             : std_logic_vector(N-1 downto 0);
signal s_Halt         : std_logic; 

--misc signals
signal s_PCinc, s_signExtOut, s_iMemInstr, s_regALUout, s_muxImmOut, s_muxBranch, s_DMemMuxOut : std_logic_vector (N-1 downto 0);
signal s_toShiftExtd, s_jumpAddrShift, s_jumpAddr32, s_jumpSum, s_MuxJumpOut, s_signExtShift, ra, s_finalJAddr  : std_logic_vector (N-1 downto 0);
signal s_iMemExt32,  s_PCp4pSignExt, s_muxPC, s_jumpMuxOut, s_temp, s_resetMuxOut,  s_PCout, s_muxPCin : std_logic_vector (N-1 downto 0);
signal s_immShift, s_DMemOutShift16, s_muxShiftRes, s_immShift16, s_ALUin,  s_muxShiftOut, s_shiftToUse : std_logic_vector(N-1 downto 0);

signal s_rFileOut1, s_rFileOut2, s_PCplus4, s_ALUoutShifted : std_logic_vector (N-1 downto 0);
signal s_zero,  s_branchMuxSel,  s_eq : std_logic;
signal s_JAddr : std_logic_vector (25 downto 0);

--signals from control unit
signal cu_branch, cu_MemtoReg, cu_memRead, cu_RegDst, cu_jump, s_overflow, cu_beq, cu_bne : std_logic;
signal s_ALUShiftEn, s_ALUShiftRtEn, id_jal, id_jr, s_finalJumpEn : std_logic;
signal cu_ALUctrl : std_logic_vector(2 downto 0);

--signals from instruction decoder
signal id_readAddr1, id_readAddr2, s_muxShfV, s_shiftCtrlVal, id_regWriteAddr, temp_RegWrAddr : std_logic_vector (4 downto 0);
signal id_signExtend : std_logic_vector (15 downto 0);
signal id_toShift    : std_logic_vector (25 downto 0);

--general pipeline signals 
signal IFID_stall, IDEX_stall, EXMEM_stall, MEMWB_stall : std_logic;
signal IFID_flush, IDEX_flush, EXMEM_flush, MEMWB_flush : std_logic;

--IFID signals
signal IFID_pcPlus4, IFID_inst : std_logic_vector (N-1 downto 0);

--IDEX signals
signal IDEX_rFOut1, IDEX_rFOut2, IDEX_nextPCVal : std_logic_vector(N-1 downto 0);
signal IDEX_writeAddr : std_logic_vector (4 downto 0);
signal IDEX_toShift : std_logic_vector(25 downto 0);
signal IDEX_signExtend : std_logic_vector(15 downto 0);
signal IDEX_ALUCtrl : std_logic_vector(2 downto 0);

constant numIDEXgenVals : integer := 14;
signal IDEX_decodeOut   : std_logic_vector (numIDEXgenVals-1 downto 0);
signal IDEX_miscOut : std_logic_vector (numIDEXgenVals-1 downto 0);



--EXMEM signals
signal EXMEM_RegWrAddr : std_logic_vector(4 downto 0);
signal EXMEM_memToReg, EXMEM_regWr, EXMEM_DMemWr : std_logic;
signal EXMEM_DMemAddr, EXMEM_DMemData, EXMEM_nextPCVal, EXMEM_ALUout : std_logic_vector(N-1 downto 0);

--MEMWB signals,
 
signal MEMWB_RegWrAddr : std_logic_vector (4 downto 0);
signal MEMWB_regWr, MEMWB_memToReg, MEMWB_jal : std_logic;
signal MEMWB_ALUout, MEMWB_DMemOut, MEMWB_nextPCVal : std_logic_vector (N-1 downto 0);

begin

  IFID_stall <= '1'; --should have stall = 0, then invert for write enables
  IFID_flush <= '0';
  
  IDEX_stall <= '1';
  IDEX_flush <= '0';
  
  EXMEM_stall <= '1';
  EXMEM_flush <= '0';
  
  MEMWB_stall <= '1'; 
  MEMWB_flush <= '0';

  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
    iInstAddr when others;

  --set halt to 1 to end the program on these conditions
  s_Halt <='1' when (s_Inst(31 downto 26) = "000000") and (s_Inst(5 downto 0) = "001100") and (v0 = "00000000000000000000000000001010") else '0';

muxPCIn : NMux
generic map (N => 32)
port map (
  in_select => iRST,
  in_A => s_finalJAddr,
  in_B => X"00000000",

  o_F => s_muxPCin );

PC : reg_nbit
generic map (N => 32)
port map (
  i_CLK => iCLK,
  i_R => '0',
  --don't update if stalling
  i_W => IFID_stall,

  in_data => s_muxPCin,
  out_data => s_PCout );

IMem: mem
generic map (ADDR_WIDTH => 10,
             DATA_WIDTH => N )
port map (
  clk  => iCLK,
  addr => s_IMemAddr(11 downto 2),
  data => iInstExt,
  we   => iInstLd,
  q    => s_Inst);

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

--BEGIN IF/ID 
  IFID_instReg : IF_ID
  port map (
    i_CLK   => iCLK,
    i_data  => s_Inst,
    i_stall => '0',

    o_data  => IFID_inst );

  IFID_PCp4Reg : reg_nbit
  port map (
    i_CLK => iCLK,
    i_W => IFID_stall,
    i_R => IFID_flush,
    
    in_data => s_PCplus4,
    out_data => IFID_pcPlus4 );

--END IF/ID

--creates usable signals based on a given binary input
instrDecode : instruction_decoder
port map (
  in_Instruction  => IFID_inst,
  --Extender Input
  o_signExtend    => id_signExtend,
  --Register stuff below
  o_writeAddr     => id_regWriteAddr,
  o_readAddr1     => id_readAddr1,
  o_readAddr2     => id_readAddr2,
  --Control stuff below
  o_regDst        => IDEX_decodeOut(0), -- cu_regDst,
  o_regWrite      => IDEX_decodeOut(1), -- s_RegWr,
  o_ALUSrc        => IDEX_decodeOut(2), -- cu_ALUSrc,
  o_beq           => IDEX_decodeOut(3), -- cu_beq,
  o_bne           => IDEX_decodeOut(4), -- cu_bne,
  o_MemWrite      => IDEX_decodeOut(5), -- s_DMemWr,
  o_ALUCtrlFinal  => cu_ALUctrl,
  o_toShift       => id_toShift,
  o_upper         => IDEX_decodeOut(6), -- id_upper,
  o_vectorShift   => IDEX_decodeOut(7), -- id_vShift,

  o_shift         => IDEX_decodeOut(8), -- id_shift,
  o_shiftRight    => IDEX_decodeOut(9), -- id_shiftRight,
  o_MemToReg      => IDEX_decodeOut(10), -- cu_MemtoReg,
  o_jump          => IDEX_decodeOut(11), -- cu_jump,
  o_jal           => IDEX_decodeOut(12), -- id_jal,
  o_jr            => IDEX_decodeOut(13) );-- id_jr );

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
s_jumpAddr32(31 downto 28) <= IFID_pcPlus4(31 downto 28);

findEq : check_equivalent
  port map (
    i_A => s_rFileOut1,
    i_B => s_rFileOut2, --MAY NEED TO CONVERT THIS TO USE muxImmOut
    o_F => s_eq );

--if beq and values are equivalent or if bne and vals not equivalent
s_branchMuxSel <= (s_eq and IDEX_decodeOut(3)) or (not s_eq and IDEX_decodeOut(4));

--Deciding whether or not to branch based on cu_branch, which should never be true for this portion of the processor
PCincSignExt: add_sub
generic map(N => 32)
port map (
  a_in 	  => IFID_pcPlus4,
  b_in    => s_signExtShift,
  c_in    => '0',
  sub_in  => '0',

  result  => s_PCp4pSignExt,
  c_out   => open );

--decides if we're going to PC+4 or branch address
muxBranchOut : NMux
  generic map (N => 32)
  port map (
    in_select => s_branchMuxSel,
    in_A => IFID_pcPlus4,
    in_B => s_PCp4pSignExt,
    o_F =>  s_muxBranch  );


--CAUSES SIMULATION TO RUN FOREVER
s_finalJumpEn <= IDEX_miscOut(11) or IDEX_miscOut(12);

--decides if writing to i_mem s_muxBranch or the jump address

--THIS ONE CASEFASDHFASUIODFHAUISHDFASUIFHASUIDFHASUIDHFASUIDH
finalJumpMux : NMux
  generic map (N => 32)
  port map (
    in_select => s_finalJumpEn, -- s_finalJumpEn, --CAUSES ERROR
    in_A      => s_muxBranch,
    in_B      => s_jumpAddr32,
    o_F       => s_finalJAddr );

--chooses ra if we're jump returning
-- jrMux : NMux
--   generic map (N => 32)
--   port map (
--     in_select => '0', --WRONG WRONG WRONG NOT SETTING CORRECTLY USE 0 INSTEAD
--     in_A => s_jumpMuxOut,
--     in_B => ra,
--     o_F => s_finalJAddr );

sll2_signExt : barrel_shift
  generic map (numBits => 32, shiftLen => 5)
  port map (
    i_A     => s_signExtOut,
    i_Shift => "00010",
    i_srl   => '0',
    o_F     => s_signExtShift );

--$ra = regFile[31]
raMux : NMux 
  generic map (N => 5)
  port map (
    in_select => '0', --SHOULD BE id_jal : jal NOT WORKING, ALWAYS SELECT CORRECT ADDR
    in_A => id_regWriteAddr,
    in_B => "11111",
    
    o_F => temp_RegWrAddr );

--registers storing information
--everything for writing to file comes from MEM/WB
rFile : reg_file_2out
generic map (numBits => 32, numItems => 32)
  port map (
  s_in0	   => s_RegWrAddr,
  s_in1    => id_readAddr1,
  s_in2 	 => id_readAddr2,
  r_in     => '0',
  in_data  => s_RegWrData,
  w_in 	   => MEMWB_regWr,
  i_CLK    => iCLK,

  val_out1 => s_rFileOut1,
  val_out2 => s_rFileOut2,
  v0   		 => v0,
  ra       => ra );

--BEGIN ID/EX
genIDEXmiscVals: for i in 0 to numIDEXgenVals-1 generate
  ID_EX_miscVals : reg_nbit
  generic map (N => 1)
  port map (
    i_CLK => iCLK,
    i_R => IDEX_flush,
    i_W => IDEX_stall,

    in_data(0) => IDEX_decodeOut(i),
    out_data(0) => IDEX_miscOut(i) );
  
end generate;

IDEX_nextPCValReg : reg_nbit
port map (
  i_CLK => iCLK,
  i_R => IDEX_flush,
  i_W => IDEX_stall,

  in_data => s_finalJAddr,
  out_data => IDEX_nextPCVal );

IDEX_signExtReg : reg_nbit 
generic map (N => 16)
port map (
  i_CLK => iCLK,
  i_R => IDEX_flush,
  i_W => IDEX_stall,

  in_data => id_signExtend,
  out_data => IDEX_signExtend );

IDEX_writeAddrReg : reg_nbit 
generic map (N => 5)
port map (
  i_CLK => iCLK,
  i_R => IDEX_flush,
  i_W => IDEX_stall,

  in_data => temp_RegWrAddr,
  out_data => IDEX_writeAddr );

IDEX_ALUCtrlReg : reg_nbit
generic map (N => 3)
port map (
  i_CLK => iCLK,
  i_R => IDEX_flush,
  i_W => IDEX_stall,

  in_data => cu_ALUctrl,
  out_data => IDEX_ALUCtrl );

ID_EX1 : reg_nbit
port map (
  i_CLK => iCLK,
  i_R => IDEX_flush,
  i_W => IDEX_stall,

  in_data => s_rFileOut1,
  out_data => IDEX_rFOut1 ); 

ID_EX2 : reg_nbit 
port map (
  i_CLK => iCLK,
  i_R => IDEX_flush,
  i_W => IDEX_stall,

  in_data => s_rFileOut2,
  out_data => IDEX_rFOut2 );

--END ID/EX

--sign extend the immediate value to 32 bits to make it fit in the ALU
sExtend : sign_extender_16to32
  generic map (givenBits => 16, targetBits => 32)
  port map (
    toExtend => IDEX_signExtend,
    extended => s_signExtOut );

--decides if we need to shift by the immediate value (sll) or regFileOut (sllv)
shiftImm : NMux
  generic map (N => 5)
  port map (
    in_select => IDEX_miscOut(7), --vectorShift
    in_A => s_signExtOut(4 downto 0),
    in_B => IDEX_rFOut2 (4 downto 0),
    o_F => s_muxShfV );   

--if we're doing lui, shift by 16
shiftUpper : NMux
  generic map (N => 5)
  port map (
    in_select => IDEX_miscOut(6), --if shifting by upper, shift by 16
    in_A => s_muxShfV,
    in_B => "10000",
    o_F =>  s_shiftCtrlVal );

--decides if the immediate value or if another register will be used in computing
immMux : NMux
  generic map (N => 32)
  port map (
    in_Select => IDEX_miscOut(2), --ALUSrc
    in_A => IDEX_rFOut2,
    in_B => s_signExtOut,
    o_F  => s_muxImmOut );

s_ALUShiftEn <= IDEX_miscOut(6) or IDEX_miscOut(8);
--s_ALUShiftRtEn <= IDEX_miscOut(9) and (not IDEX_miscOut(6));
--ALU after the register file, used to compute
ALU_rFileOut : ALU_32b_shift
  generic map (numBits => 32, selectBits => 3, shiftLen => 5)
  port map (
    i_A       => IDEX_rFOut1, 
    i_B       => s_muxImmOut, 
    i_Control => IDEX_ALUCtrl,

    i_srl     => IDEX_miscOut(9),
    i_Shift   => s_shiftCtrlVal,
    i_sEn     => s_ALUShiftEn,

    F	  	  	=> s_regALUout,
    CarryOut	=> open,
    Overflow  => s_overflow,
    Zero		  => s_zero );

EXMEM_sFinalJumpReg : reg_nbit 
port map (
  i_CLK => iCLK,
  i_R => EXMEM_flush,
  i_W => EXMEM_stall,
  
  in_data => IDEX_nextPCVal,
  out_data => EXMEM_nextPCVal );

EXMEM_sDMemWrReg : reg_nbit
generic map (N => 1)
port map (
  i_CLK => iCLK,
  i_R => EXMEM_flush,
  i_W => EXMEM_stall,

  in_data(0) => IDEX_miscOut(5),
  out_data(0) => s_DMemWr );

EXMEM_regWrReg : reg_nbit
generic map (N => 1)
port map (
  i_CLK => iCLK,
  i_R => EXMEM_flush,
  i_W => EXMEM_stall,

  in_data(0) => IDEX_miscOut(1),
  out_data(0) => EXMEM_regWr);

EXMEM_writeAddrReg : reg_nbit
generic map (N => 5)
port map (
  i_CLK => iCLK,
  i_R => EXMEM_flush,
  i_W => EXMEM_stall,

  in_data => IDEX_writeAddr,
  out_data => EXMEM_RegWrAddr);

EXMEM_memToRegReg: reg_nbit
generic map (N => 1)
port map (
  i_CLK => iCLK,
  i_R => EXMEM_flush,
  i_W => EXMEM_stall,

  in_data(0) => IDEX_miscOut(10),
  out_data(0) => EXMEM_memToReg );

EXMEM_DMemAddrReg : reg_nbit
port map (
  i_CLK => iCLK,
  i_R => EXMEM_flush,
  i_W => EXMEM_stall,
  
  in_data => s_regALUout,
  out_data => s_DMemAddr );

EXMEM_ALUOutReg : reg_nbit
port map (
  i_CLK => iCLK,
  i_R => EXMEM_flush,
  i_W => EXMEM_stall,
  
  in_data => s_regALUout,
  out_data => EXMEM_ALUout );

EXMEM_DMemDataReg : reg_nbit
port map (
  i_CLK => iCLK,
  i_R => EXMEM_flush,
  i_W => EXMEM_stall,

  in_data => IDEX_rFOut2, --may need to change to muxImmOut?????
  out_data => s_DMemData);

--END EX/MEM

DMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(
      clk  => iCLK,
      addr => s_DMemAddr(11 downto 2),
      data => s_DMemData,
      we   => s_DMemWr,
      q    => s_DMemOut);

--BEGIN MEM/WB
MEMWB_nextPCValReg : reg_nbit 
port map (
  i_CLK => iCLK,
  i_R => MEMWB_flush,
  i_W => MEMWB_stall,

  in_data => EXMEM_nextPCVal,
  out_data => MEMWB_nextPCVal );

MEMWB_wAddrReg : reg_nbit 
generic map (N => 5)
port map (
  i_CLK => iCLK,
  i_R => MEMWB_flush,
  i_W => MEMWB_stall,

  in_data => EXMEM_RegWrAddr,
  out_data => s_RegWrAddr );

MEMWB_regWrReg : reg_nbit 
generic map (N => 1)
port map (
  i_CLK => iCLK,
  i_R => MEMWB_flush,
  i_W => MEMWB_stall,

  in_data(0) => EXMEM_regWr,
  out_data(0) => s_RegWr );

MEMWB_DMemOutReg : reg_nbit
port map (
  i_CLK => iCLK,
  i_R => MEMWB_flush,
  i_W => MEMWB_stall,

  in_data => s_DMemOut,
  out_data => MEMWB_DMemOut );

MEMWB_ALUoutReg : reg_nbit 
port map (
  i_CLK => iCLK,
  i_R => MEMWB_flush,
  i_W => MEMWB_stall,

  in_data => EXMEM_ALUout,
  out_data => MEMWB_ALUout );

MEMWB_memToRegReg : reg_nbit 
generic map (N => 1)
port map (
  i_CLK => iCLK,
  i_R => MEMWB_flush,
  i_W => MEMWB_stall,

  in_data(0) => EXMEM_memToReg,
  out_data(0) => MEMWB_memToReg );

oALUOut <= MEMWB_ALUout;

--Decides if the output past the memory will be from the ALU or from the memory
DMemMux : NMux
  generic map (N => 32)
  port map (
    in_Select => MEMWB_memToReg,
    in_A => MEMWB_ALUout,
    in_B => MEMWB_DMemOut,
    o_F  => s_DMemMuxOut );
  
--write back to $ra if jal, $ra = PC+4
s_RegWrData <= s_DMemMuxOut;

end structure;
