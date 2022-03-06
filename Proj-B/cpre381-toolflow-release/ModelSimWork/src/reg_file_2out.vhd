library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.vectorArray.all;

entity reg_file_2out is
generic (numBits : integer := 32;
	 numItems : integer := 32);

port (
		s_in0	: in std_logic_vector (4 downto 0); 		--select the register to write to
		s_in1	: in std_logic_vector (4 downto 0); 		--select the register perform some action
		s_in2	: in std_logic_vector (4 downto 0);
		r_in    : in std_logic;
		in_data : in std_logic_vector(numBits-1 downto 0);      --data to write, if any
		w_in 	: in std_logic; 				 --choose to write to a specific register
		i_CLK   : in std_logic;   				--data to output

		val_out1: out std_logic_vector(numBits-1 downto 0 );
		val_out2: out std_logic_vector(numBits-1 downto 0 );
		v0			: out std_logic_vector(numBits-1 downto 0) );
end reg_file_2out;

architecture structure of reg_file_2out is

component decoder_5to32
	generic (
		N : integer := numItems;
		s_length : integer := 5);

	port (
		a_in : in std_logic_vector (s_length-1 downto 0);
		o_out : out std_logic_vector (numItems-1 downto 0) );
end component;

component reg_nbit
	generic (N : integer := numBits);
	port (
		i_CLK 			: in std_logic; --clock for dff
		i_R			: in std_logic; --reset for dff
		i_W		        : in std_logic; --write enable for dff

		in_data 		: in std_logic_vector (N-1 downto 0);
		out_data		: inout std_logic_vector (N-1 downto 0) );
end component;

component mux32to1
generic(N: integer := 32);
port (	i_input		: in vecArr_32b;
		i_select	: in std_logic_vector(4 downto 0);
		o_output	: out std_logic_vector(N-1 downto 0)
	);

end component;

component andg2
	port (
		i_A : in std_logic;
		i_B : in std_logic;
		o_F : out std_logic );
end component;

signal decoder_out : std_logic_vector (numItems-1 downto 0);
signal reset_values : std_logic_vector (numItems-1 downto 0);

--an array of all values stored by registers in order from 0 -> 31
signal reg_vals : vecArr_32b;

signal s_W, s_R : std_logic_vector (numItems-1 downto 0);

begin

decode_select : decoder_5to32
port map (
	a_in => s_in0,
	o_out => decoder_out );

--zero register can only store 0, set reset to always be 1.

reg_zero : reg_nbit
port map (
	i_CLK => i_CLK,
	i_R => '1',
	i_W => '0',

	in_data => "00000000000000000000000000000000",
	out_data => reg_vals(0) );

--for the rest of the items, set it up as 30 rows of n bit register
G1 : for i in 1 to numItems-1 generate

w_and_decoder : andg2
port map (
	i_A => w_in,
	i_B => decoder_out(i),
	o_F => s_W(i) );

r_and_decoder : andg2
port map (
	i_A => r_in,
	i_B => decoder_out(i),
	o_F => s_R(i));

regs : reg_nbit
port map (
	i_CLK => i_CLK,
	i_R   => s_R(i), --reset if reset is true and we are at the correct address (decoder)
	i_W   => s_W(i), --write if we are at the correct address and write is true

	in_data => in_data,
	out_data => reg_vals(i) );

end generate;

end_mux1 : mux32to1
port map (
	i_input => reg_vals,
	i_select => s_in1,
	o_output => val_out1 );

end_mux2 : mux32to1 --select the second register input
port map (
	i_input => reg_vals,
	i_select => s_in2,
	o_output => val_out2 );

v0 <= reg_vals(2);

end structure;
