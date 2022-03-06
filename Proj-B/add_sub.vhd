--add_sub
--Cameron Isbell

library IEEE;
use IEEE.std_logic_1164.all;

entity add_sub is
	generic(N : integer := 32);
	port (
		a_in 	: in std_logic_vector (N -1 downto 0);
		b_in 	: in std_logic_vector (N -1 downto 0);
		c_in 	: in std_logic;
		sub_in  : in std_logic;

		result 	: out std_logic_vector(N-1 downto 0);
		c_out  	: out std_logic );

end add_sub;

architecture structure of add_sub is

--changed from 32 to 1 bit for the 1 bit ALU
constant numBits : integer := N;

component full_adder_struct_nbit
	generic (N : integer := numBits);
	port(
		a_in    : in std_logic_vector(N-1 downto 0);
		b_in    : in std_logic_vector(N-1 downto 0);
		c_in    : in std_logic;

		c_out   : out std_logic;
       	s_out   : out std_logic_vector(N-1 downto 0));

end component;

component mux2_struct
	port(
			a_in  : in std_logic;
		  b_in  : in std_logic;

		  o_F  : out std_logic;
		  s_in  : in std_logic );
end component;

component mux2_dataflow
	generic (N : integer := numBits);
	port( a_in  : in std_logic_vector(N-1 downto 0);
		  b_in  : in std_logic_vector(N-1 downto 0);

		  o_F  : out std_logic_vector(N-1 downto 0);
		  s_in  : in std_logic );
end component;

component ones_comp_p2
	generic (N :integer := numBits);
	port (
		i_raw : in std_logic_vector(N-1 downto 0);
		o_ones : out std_logic_vector(N-1 downto 0) );

end component;

signal notB, muxResult : std_logic_vector(N-1 downto 0);
signal sub_ctrl : std_logic;

begin

negate_b : ones_comp_p2
	port map (
		i_raw => b_in,
		o_ones => notB );

mux_b : mux2_dataflow
	port map (
		a_in => b_in,
		b_in => notB,
		s_in => sub_in,

		o_F => muxResult );

--if we ones comp and not add 1, not a true subtraction
sub_ctrlMux : mux2_struct
	port map (
		a_in => c_in,
		b_in => '1',
		s_in => sub_in,

		o_F => sub_ctrl );

get_result : full_adder_struct_nbit
	port map (
		a_in => a_in,
		b_in => muxResult,
		c_in => sub_ctrl,

		s_out => result,
		c_out => c_out);

end structure;
