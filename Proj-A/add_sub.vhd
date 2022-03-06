--add_sub
--Cameron Isbell

library IEEE;
use IEEE.std_logic_1164.all;

entity add_sub is
	generic(N : integer := 1);
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
constant numBits : integer := 1;

component full_adder_struct_nbit
	generic (N : integer := numBits);
	port(
		a_in    : in std_logic_vector(N-1 downto 0);
		b_in    : in std_logic_vector(N-1 downto 0);
		c_in    : in std_logic;

		c_out   : out std_logic;
       	s_out   : out std_logic_vector(N-1 downto 0));

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

get_result : full_adder_struct_nbit
	port map (
		a_in => a_in,
		b_in => muxResult,
		c_in => c_in,

		s_out => result,
		c_out => c_out);

end structure;
