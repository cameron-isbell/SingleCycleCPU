library IEEE;
use IEEE.std_logic_1164.all;

entity mux2_dataflow is
generic (N : integer := 4);
port ( 
	a_in : in std_logic_vector (N-1 downto 0);
	b_in : in std_logic_vector (N-1 downto 0);
	o_F  : out std_logic_vector (N-1 downto 0);
	
	s_in : in std_logic );
	
end mux2_dataflow;

architecture dataflow of mux2_dataflow is

begin

G1: for i in 0 to N-1 generate
	o_F(i) <=	( (not s_in) and a_in(i)) or (s_in and b_in(i));
	
end generate;

end dataflow;