library IEEE;
use IEEE.std_logic_1164.all;

entity MIPS_ALU is
  generic(numBits    : integer := 32;
          ALUselectBits : integer := 3;
          regSelectBits : integer := 5 );
  port (
    --i_A         : in std_logic_vector(numBits-1 downto 0);
    --i_B         : in std_logic_vector(numBits-1 downto 0);
    i_Control   : in std_logic_vector(ALUselectBits-1 downto 0);

    i_rd        : in std_logic_vector (regSelectBits-1 downto 0);
    i_rs        : in std_logic_vector (regSelectBits-1 downto 0);
    i_rt        : in std_logic_vector (regSelectBits-1 downto 0);

    i_sw        : in std_logic;
    i_lw        : in std_logic;

    i_memAddr   : in std_logic_vector (9 downto 0);
    i_imm       : in std_logic_vector (numBits-1 downto 0);
    i_ALUSrc    : in std_logic;
    i_nAdd_Sub  : in std_logic;
    i_regWrite  : in std_logic;

    i_srl       : in std_logic;
    i_Shift     : in std_logic_vector (regSelectBits-1 downto 0);
    i_sEn       : in std_logic;

    i_CLK       : in std_logic;

    F           : inout std_logic_vector(numBits-1 downto 0);
    CarryOut    : out std_logic;
    Overflow    : out std_logic;
    Zero        : out std_logic );

end MIPS_ALU;

architecture structure of MIPS_ALU is

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

component reg_file_2out
generic (
    numBits : integer := 32;
		numItems : integer := 32 );
port (
	s_in0	   : in std_logic_vector (4 downto 0);
	s_in1	   : in std_logic_vector (4 downto 0);
	s_in2	   : in std_logic_vector (4 downto 0);

	r_in     : in std_logic;
	in_data  : in std_logic_vector (numBits-1 downto 0);
	w_in 	   : in std_logic;
	i_CLK    : in std_logic;

	val_out1 : out std_logic_vector(numBits-1 downto 0 );
	val_out2 : out std_logic_vector(numBits-1 downto 0 ) );

end component;

component NMux
generic (N : integer := 32);
port (
    in_Select : in std_logic;
    in_A : in std_logic_vector((N - 1) downto 0);
    in_B : in std_logic_vector((N - 1) downto 0);

    o_F : out std_logic_vector((N - 1) downto 0) );

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
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 10
	);

	port
	(
		clk		: in std_logic;
		addr	: in std_logic_vector((ADDR_WIDTH-1) downto 0);
		data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic;
		q		  : out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end component;

signal s_wEn, s_muxLoad : std_logic;
signal s_ALUout, s_memOut, s_muxOut		: std_logic_vector(31 downto 0);
signal s_rFileOut1, s_rFileOut2 : std_logic_vector(31 downto 0);

begin

--DO N0T WRITE ON SW
s_wEn <= not i_sw;

--mux_load <= lw or sw; --if 1, load the mem value into the reg file
s_muxLoad <= i_sw or i_lw;

--Code from MIPS_reg_file, consists of alu / reg_file combination
--a register file with 2 outputs
r_file : reg_file_2out
port map(
	s_in0	 	=> i_rd,
	s_in1   => i_rs,
	s_in2		=> i_rt,

	r_in		=> '0',
	in_data => F,
	w_in 		=> s_wEn,
	i_CLK   => i_CLK,

	val_out1	=> s_rFileOut1,
	val_out2 	=> s_rFileOut2 );

--selects immediate if ALUSrc = 1
imm_mux : NMux
port map (
  in_select => i_ALUSrc,
  in_A      => s_rFileOut2,
  in_B      => i_imm,

  o_F       => s_muxOut );

get_output : ALU_32b_shift
port map (
  i_A 	   	=> s_rFileOut1,
  i_B   		=> s_muxOut,
  i_Control	=> i_Control,

  i_srl     => i_srl,
  i_Shift   => i_Shift,
  i_sEn     => i_sEn,

  F	  	    => s_ALUout,
  CarryOut  => CarryOut,
  Overflow	=> Overflow,
  Zero		  => Zero );

--------------------------------------------------------------------------------

ram : mem
port map (
	clk	 => i_CLK,
	addr => i_memAddr,
	data => s_rFileOut1, --the first value retrieved from the reg_file
	we   => i_sw,			     --writing to memory if storing a word
	q	   => s_memOut );

--decides the value to be loaded in
in_mux : NMux
port map (
  in_select => s_muxLoad,
  in_A => s_ALUout,
  in_B => s_memOut,

  o_F => F );

end structure;
