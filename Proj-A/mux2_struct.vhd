library IEEE;
use IEEE.std_logic_1164.all;

entity mux2_struct is 
port (
	a_in 	: in std_logic;
	b_in 	: in std_logic;
	s_in 	: in std_logic;

	o_F	: out std_logic);
end mux2_struct;

architecture structure of mux2_struct is

component invg
	port(
		i_A : in std_logic; 
		o_F : out std_logic );

end component;

component org2
	port (
		i_A : in std_logic;
		i_B : in std_logic;
		o_F : out std_logic );
end component;

component andg2
	port (
		i_A : in std_logic;
		i_B : in std_logic;
		o_F : out std_logic );
end component;

--     stores s negated, s and b, s negated and a
signal notS, s_and_b, nS_and_a : std_logic;

begin

inv_select: invg
	port MAP (
		i_A => s_in,
		o_F => notS );

and_nS_a: andg2
	port MAP(
             i_A               => notS,
             i_B               => a_in,
             o_F               => nS_and_a);

and_s_b: andg2
	port MAP(
             i_A               => s_in,
             i_B               => b_in,
             o_F               => s_and_b);

or_sb_nSa: org2
	port MAP(
		i_A 		=> s_and_b,
		i_B		=> nS_and_a,
		o_F		=> o_F);		

end structure;
