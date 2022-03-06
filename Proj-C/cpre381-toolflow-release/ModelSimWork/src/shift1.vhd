--shift1
--Cameron Isbell
library IEEE;
use IEEE.std_logic_1164.all;

entity shift1 is
generic (numBits : integer := 32);
port (
  i_A : in std_logic_vector(numBits-1 downto 0);
  o_F : out std_logic_vector(numBits-1 downto 0) );

end shift1;

architecture dataflow of shift1 is
  constant shiftAmount : integer := 1;

begin

o_F(0) <= '0';
G1: for i in 0 to numBits-2 generate
  o_F(i+1) <= i_A(i);
end generate;

end dataflow;
