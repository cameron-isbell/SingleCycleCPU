library IEEE;
use IEEE.std_logic_1164.all;

entity set_less_than is
port (
	i_a 	: in std_logic;
	i_b 	: in std_logic;
	c_in  : in std_logic;
	i_less  : in std_logic;

	o_F 	: out std_logic;
	c_out 	: out std_logic );

end set_less_than;

architecture structure of set_less_than is

component add_sub
generic(N : integer := 1);
port (
	a_in 	: in std_logic_vector (N -1 downto 0);
	b_in 	: in std_logic_vector (N -1 downto 0);
	c_in 	: in std_logic;
	sub_in  : in std_logic;

	result 	: out std_logic_vector(N-1 downto 0);
	c_out  	: out std_logic );

end component;
signal s_sTemp : std_logic;

begin

sub : add_sub
port map (
	a_in(0) => i_b,
	b_in(0) => i_a,
	c_in => c_in,
	sub_in => '1',

	--result(0) => ,
	c_out => c_out );

end structure;
