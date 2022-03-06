library IEEE;
use IEEE.std_logic_1164.all;

entity check_equivalent is
  generic (numBits : integer := 32);
  port (
    i_A : in std_logic_vector(numBits-1 downto 0);
    i_B : in std_logic_vector(numBits-1 downto 0);

    o_F : out std_logic );

end check_equivalent;

architecture dataflow of check_equivalent is

signal s_eqPropog : std_logic_vector (numBits downto 0);

begin

s_eqPropog(0) <= '1';
G1 : for i in 0 to numBits-1 generate
  s_eqPropog(i+1) <= s_eqPropog(i) and (i_A(i) xnor i_B(i));

end generate;

o_F <= s_eqPropog(numBits);

end dataflow;
