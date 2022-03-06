-- nandg2.vhd
-- Matthew G. Hoskins

library IEEE;
use IEEE.std_logic_1164.all;

entity nandg2 is
	port(i_A : in std_logic;
		 i_B : in std_logic;
		 o_F : out std_logic);
end nandg2;

architecture dataflow of nandg2 is
begin
	o_F <= i_A nand i_B;
	
end dataflow;