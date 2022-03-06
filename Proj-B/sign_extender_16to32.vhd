library IEEE;
use IEEE.std_logic_1164.all;

entity sign_extender_16to32 is
generic (givenBits : integer := 16;
	 targetBits: integer := 32);
port (
	--assuming given value to extend is 2's complemented
	toExtend : in std_logic_vector(givenBits-1 downto 0);
	extended : out std_logic_vector(targetBits-1 downto 0) );

end sign_extender_16to32;

architecture dataflow of sign_extender_16to32 is
begin

--copy bits 0 to 15 into extended
G1 : for i in 0 to givenBits-1 generate
	extended(i) <= toExtend(i);
end generate;

--Copy the sign at toExtend(15) to 16 -> 31
G2 : for i in givenBits to targetBits-1 generate
	extended(i) <= toExtend(givenBits-1);
end generate;

end dataflow;
