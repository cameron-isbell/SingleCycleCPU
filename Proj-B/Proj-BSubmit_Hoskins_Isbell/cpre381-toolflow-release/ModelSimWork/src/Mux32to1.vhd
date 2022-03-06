-- Mux32to1.vhd

library IEEE;
use IEEE.std_logic_1164.all;
use work.vectorArray.all;
use IEEE.NUMERIC_STD.all;


entity Mux32to1 is
	generic(N: integer := 32);
	port (	i_input		: in vecArr_32b;
			i_select	: in std_logic_vector(4 downto 0);
			o_output	: out std_logic_vector(N-1 downto 0)
		);
end Mux32to1;

architecture dataflow of Mux32to1 is

	begin
		o_output <= i_input(to_integer(unsigned (i_select)));

end dataflow;
