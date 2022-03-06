library IEEE;
use IEEE.std_logic_1164.all;

entity set_less_than is
port (
	i_a 	: in std_logic;
	i_b 	: in std_logic;
	c_in  	: in std_logic;
	i_less  : in std_logic;

	o_F 	: out std_logic;
	c_out 	: out std_logic );

end set_less_than;

architecture structure of set_less_than is

component add_sub_1bit
port (
	a_in 	: in std_logic;
	b_in 	: in std_logic;
	c_in 	: in std_logic;
	sub_in  : in std_logic;

	result 	: out std_logic;
	c_out  	: out std_logic );

end component;

begin

sub : add_sub_1bit
port map (
	a_in => i_a,
	b_in => i_b,
	c_in => c_in,
	sub_in => '1',

	result => open,
	c_out => c_out );

end structure;
