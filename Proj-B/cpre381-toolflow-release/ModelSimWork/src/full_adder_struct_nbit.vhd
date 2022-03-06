library IEEE;
use IEEE.std_logic_1164.all;

-- Modeling: sum = (A xor B) xor Cin, cout = (A and B) or ((A xor B) and Cin)
entity full_adder_struct_nbit is 
generic (N : integer := 16);
port (
--  num 1
	a_in 	: in std_logic_vector(N-1 downto 0);
--  num 2
	b_in 	: in std_logic_vector(N-1 downto 0);
--  carry in
	c_in 		: in std_logic;
-- carry out
	c_out   	: out std_logic;
-- sum
	s_out		: out std_logic_vector(N-1 downto 0) );
	
end full_adder_struct_nbit;

architecture structure of full_adder_struct_nbit is

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

component xorg2
	port (
		i_A : in std_logic;
		i_B : in std_logic;
		o_F : out std_logic );
end component;

signal carry_arr : std_logic_vector(N downto 0);
signal AxorB, AandB, AxorBandCin : std_logic_vector(N-1 downto 0);

begin

carry_arr(0) <= c_in;

G1: for i in 0 to N-1 generate
-- A xor B
AxB : xorg2
	port map (
		i_A => a_in(i),
		i_B => b_in(i),
		o_F => AxorB(i) );
--A xor B xor C		
AxBxC : xorg2
	port map (
		i_A => AxorB(i),
		i_B => carry_arr(i),
		o_F => s_out(i));
	
--A and B
AB : andg2 
	port map (
		i_A => a_in(i),
		i_B => b_in(i),
		o_F => AandB(i) );
--A xor B and C		
AxBandCin : andg2
	port map (
		i_A => AxorB(i),
		i_B => carry_arr(i),
		o_F => AxorBandCin(i) );

--A and B or (A xor B and C)
carry_out : org2
port map ( 
	i_A => AandB(i),
	i_B => AxorBandCin(i),
	o_F => carry_arr(i+1) );

end generate;

c_out <= carry_arr(N);

end structure;