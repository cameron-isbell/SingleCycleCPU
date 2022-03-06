--ALU_32b
--Cameron Isbell

library IEEE;
use IEEE.std_logic_1164.all;

entity ALU_32b is
generic (numBits : integer := 32;
		 selectBits : integer := 3 );
port (
	i_A 		: in std_logic_vector(numBits-1 downto 0);		--input/operand A
	i_B 		: in std_logic_vector(numBits-1 downto 0);		--input/operand B
	i_Control	: in std_logic_vector(selectBits-1 downto 0);	--control input, each bit used to control a 1bit ALU

	F	  		: inout std_logic_vector(numBits-1 downto 0); 	--Output
	CarryOut	: out std_logic;
	Overflow	: out std_logic;
	Zero		: out std_logic );								--1 if A = 0 and B = 0

end ALU_32b;

architecture structure of ALU_32b is

component ALU_overflow
	port (
		in_A0			: in std_logic;
		in_A1			: in std_logic;
		in_carry		: in std_logic;
		in_less			: in std_logic;
		in_select		: in std_logic_vector(2 downto 0);

		o_out			: out std_logic;
		o_cOut			: out std_logic;
		o_set			: out std_logic;
		o_overflow		: out std_logic );

end component;

component ALU1bit
	port (
		in_A0		: in std_logic;
		in_A1		: in std_logic;
		in_carry	: in std_logic;
		in_select	: in std_logic_vector(selectBits-1 downto 0);
		in_less		: in std_logic;

		o_out 		: out std_logic;
		o_cOut 		: out std_logic );

end component;

component or_32b
port (
	i_A : in std_logic_vector(numBits-1 downto 0);
	o_F  : out std_logic );

end component;

--cList(0) will always = 0. each ALU will use i and output i+1
signal s_carryList : std_logic_vector (numBits-1 downto 0);
signal s_less, s_or : std_logic;

begin
s_carryList(0) <= '0';

--ALU 0 is responsible for slt, has special functionality
ALU0 : ALU1bit
port map (
	in_A0 => i_A(0),
	in_A1 => i_B(0),
	in_carry => s_carryList(0),
	in_Select => i_Control,
	in_less => s_less,
	o_out => F(0),
	o_cOut => s_carryList(1) );

G1: for i in 1 to numBits-2 generate

ALU1to30 : ALU1bit
port map (
	in_A0 => i_A(i),
	in_A1 => i_B(i),
	in_carry => s_carryList(i),
	in_select => i_Control,
	in_less => '0',

	o_out => F(i),
	o_cOut => s_carryList(i+1) );

end generate;

--last ALU has to handle overflow, special functionality
ALU31 : ALU_overflow
port map (
	in_A0 => i_A(numBits-1),
	in_A1 => i_B(numBits-1),
	in_carry => s_carryList(numBits-1),
	in_less => '0',
	in_select => i_Control,

	o_out => F(31),
	o_cOut => CarryOut,
	o_set => s_less,
	o_overflow => Overflow );

orZero : or_32b
port map (
	i_A => F,
	o_F => s_or );

Zero <= not s_or;

end structure;
