library IEEE;
use IEEE.std_logic_1164.all;

entity zero_extender_16to32 is
generic (givenBits : integer := 16;
	 targetBits: integer := 32);
port (
	--assuming given value to extend is 2's complemented
	toExtend : in std_logic_vector(givenBits-1 downto 0);
	extended : out std_logic_vector(targetBits-1 downto 0) );

end zero_extender_16to32;

architecture dataflow of zero_extender_16to32 is
begin

G1 : for i in 0 to givenBits-1 generate
	extended(i) <= toExtend(i);
end generate;

G2 : for i in givenBits to targetBits-1 generate 
	extended(i) <= '0';
end generate;

end dataflow;