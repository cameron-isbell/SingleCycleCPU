library IEEE;
use IEEE.std_logic_1164.all;

entity ones_comp_p2 is 
	generic (N :integer := 14);
	port (
		i_raw : in std_logic_vector(N-1 downto 0);
		o_ones : out std_logic_vector(N-1 downto 0) );

end ones_comp_p2;

architecture behavior of ones_comp_p2 is 

begin


G1: for i in 0 to N-1 generate
	o_ones(i) <= not i_raw(i);

end generate;

end behavior; 