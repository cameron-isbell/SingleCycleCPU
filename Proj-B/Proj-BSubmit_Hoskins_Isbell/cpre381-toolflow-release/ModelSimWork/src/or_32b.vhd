--or_32b
--Cameron Isbell

library IEEE;
use IEEE.std_logic_1164.all;

entity or_32b is 
generic(numBits : integer := 32);
port (
	i_A : in std_logic_vector(numBits-1 downto 0);
	o_F  : out std_logic );

end or_32b;

architecture structure of or_32b is

component org2
port(
	i_A          : in std_logic;
	i_B          : in std_logic;
    o_F          : out std_logic );

end component;

signal s_h1 : std_logic_vector(15 downto 0);
signal s_h2 : std_logic_vector(15 downto 0);

signal s_or : std_logic_vector(15 downto 0);

begin

--split the input in half
G1: for i in 0 to 15 generate

s_h1(i) <= i_A(i);
s_h2(i) <= i_A(i+16);

end generate;

--or the input
G2: for i in 0 to 15 generate

orN : org2
port map (
	i_A => s_h1(i),
	i_B => s_h2(i),
	o_F => s_or(i) );

end generate;

--it works dont worry about it
o_F <= s_or(0) or s_or(1) or s_or(2) or s_or(3) or s_or(4) or s_or(5) or s_or(6) or s_or(7) 
		or s_or(8) or s_or(9) or s_or(10) or s_or(11) or s_or(12) or s_or(13) or s_or(14) or s_or(15);

end structure; 