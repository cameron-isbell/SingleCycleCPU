-- NMux.vhd
-- Matthew G. Hoskins

library IEEE;
use IEEE.std_logic_1164.all;

entity NMux is
	generic(N : integer := 32);
	port(in_Select : in std_logic;
	     in_A : in std_logic_vector((N - 1) downto 0);
	     in_B : in std_logic_vector((N - 1) downto 0);
	     o_F : out std_logic_vector((N - 1) downto 0));
end NMux;

architecture structural of NMux is

	component Structural2Mux
		port(i_A  : in std_logic;	
			i_B  : in std_logic;	
			i_S  : in std_logic;	
			o_F  : out std_logic);
	end component;
	
	begin

	--Generate Nbit
	G1: for i in 0 to N-1 generate
	newMux : Structural2Mux
		port map(i_S  => in_Select,
				i_A  => in_A(i),
				i_B => in_B(i),
				o_F  => o_F(i));
	end generate;

end structural;