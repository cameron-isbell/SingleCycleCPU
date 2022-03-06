--barrel_shift
--Cameron Isbell

library IEEE;
use IEEE.std_logic_1164.all;

package vectorArray is
	type vecArr_32b is array (31 downto 0)  of std_logic_vector(31 downto 0);

end package;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.vectorArray.all;

entity barrel_shift is
  generic(numBits : integer := 32;
          shiftLen : integer := 5 );
  port (
      i_A     : in std_logic_vector(numBits-1 downto 0);
      i_Shift : in std_logic_vector(shiftLen-1 downto 0);
      i_srl   : in std_logic;                               --shift right logical. If 1, reverse i_A
      o_F     : out std_logic_vector(numBits-1 downto 0) );

end barrel_shift;

architecture structure of barrel_shift is

component NMux
  generic(N : integer := 32);
  port(in_Select : in std_logic;
     in_A : in std_logic_vector((N - 1) downto 0);
     in_B : in std_logic_vector((N - 1) downto 0);
     o_F : out std_logic_vector((N - 1) downto 0) );

end component;

component shift1
  generic (numBits : integer := 32);
  port (
    i_A : in std_logic_vector(numBits-1 downto 0);
    o_F : out std_logic_vector(numBits-1 downto 0) );
end component;

component Mux32to1
  generic(N: integer := 32);
  port (	i_input		: in vecArr_32b;
      i_select	: in std_logic_vector(4 downto 0);
      o_output	: out std_logic_vector(N-1 downto 0)
  );
end component;

signal s_right, s_toUse, s_shiftVal, s_unInv : std_logic_vector(numBits-1 downto 0);
signal s_shiftOut : vecArr_32b;

begin

--reverse i, shift left (upside down, shift right), uninvert?
G1: for i in 0 to numBits-1 generate
  s_right((numBits-1) - i) <= i_A(i);
end generate;

muxInDirection : Nmux
  port map (
    in_Select => i_srl,
    in_A      => i_A,
    in_B      => s_right,
    o_F       => s_toUse );

s_shiftOut(0) <= s_toUse;
G2: for i in 0 to numBits-2 generate
  sBy1 : shift1
  port map (
    i_A => s_shiftOut(i),
    o_F => s_shiftOut(i+1) );

end generate;

muxOut : Mux32to1
port map (
  i_input => s_shiftOut,
  i_select => i_Shift,
  o_output => s_shiftVal );

  --reverse i, shift left (upside down, shift right), uninvert?
  G3: for i in 0 to numBits-1 generate
    s_unInv((numBits-1) - i) <= s_shiftVal(i);
  end generate;

--reverse i, shift left (upside down, shift right), uninvert?
muxRight : NMux
port map (
  in_select => i_srl,
  in_A => s_shiftVal,
  in_B => s_unInv,
  o_F => o_F );

end structure;
