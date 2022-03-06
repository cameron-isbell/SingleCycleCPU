--barrel_shift
--Cameron Isbell

--everything is uppercase thanks to vscode vhdl auto formatter
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY barrel_shift IS
  GENERIC (
    numBits : INTEGER := 32;
    shiftControl : INTEGER := 5);
  PORT (
    i_A : IN STD_LOGIC_VECTOR(numBits - 1 DOWNTO 0);
    i_Shift : IN STD_LOGIC_VECTOR(shiftControl - 1 DOWNTO 0);
    i_srl : IN STD_LOGIC; --shift right logical. If 1, reverse i_A
    o_F : OUT STD_LOGIC_VECTOR(numBits - 1 DOWNTO 0));

END barrel_shift;

ARCHITECTURE structure OF barrel_shift IS

  COMPONENT NMux
    GENERIC (N : INTEGER := 32);
    PORT (
      in_Select : IN STD_LOGIC;
      in_A : IN STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
      in_B : IN STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
      o_F : OUT STD_LOGIC_VECTOR((N - 1) DOWNTO 0));

  END COMPONENT;

  COMPONENT Structural2Mux
    PORT (
      i_A : IN STD_LOGIC;
      i_B : IN STD_LOGIC;
      i_S : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;

  SIGNAL s_right, s_toUse : STD_LOGIC_VECTOR(numBits - 1 DOWNTO 0);
  SIGNAL s_shiftedBy1, s_shiftedBy2, s_shiftedBy4, s_shiftedBy8, s_shiftedBy16 : STD_LOGIC_VECTOR(numBits - 1 DOWNTO 0);

BEGIN

  --reverse i, shift left (upside down, shift right), uninvert?
  G1 : FOR i IN 0 TO numBits - 1 GENERATE
    s_right((numBits - 1) - i) <= i_A(i);
  END GENERATE;

  muxInDirection : NMux
  PORT MAP(
    in_Select => i_srl,
    in_A => i_A,
    in_B => s_right,
    o_F => s_toUse);

  --shift 1 ----------------------------------------------------
  shift1_zeros : Structural2Mux
  PORT MAP(
    i_A => i_A(0),
    i_B => '0',
    i_S => i_Shift(0),
    o_F => s_shiftedBy1(0));

  shift1_gen : FOR i IN 1 TO numBits - 1 GENERATE
    shiftby1 : Structural2Mux

    PORT MAP(
      i_A => i_A(i),
      i_B => i_A(i - 1),
      i_S => i_Shift(0),
      o_F => s_shiftedBy1(i));

  END GENERATE;

  --end shift1 ------------------------------------------------

  --shift2 ---------------------------------------------------

  shift2_zeros : FOR i IN 0 TO 1 GENERATE
    s2zeros : Structural2Mux

    PORT MAP(

      i_A => s_shiftedBy1(i),
      i_B => '0',
      i_S => i_Shift(1),
      o_F => s_shiftedBy2(i));

  END GENERATE;

  shift2 : FOR i IN 2 TO numBits - 1 GENERATE
    shiftby2 : Structural2Mux

    PORT MAP(

      i_A => s_shiftedBy1(i),
      i_B => s_shiftedBy1(i - 1),
      i_S => i_Shift(1),
      o_F => s_shiftedBy2(i));

  END GENERATE;

  --end shift2 ------------------------------------------------------

  --shift4 ----------------------------------------------------------

  shift4_zeros : FOR i IN 0 TO 3 GENERATE
    s4zeros : Structural2Mux

    PORT MAP(

      i_A => s_shiftedBy2(i),
      i_B => '0',
      i_S => i_Shift(2),
      o_F => s_shiftedBy4(i));

  END GENERATE;

  shift4 : FOR i IN 4 TO numBits - 1 GENERATE
    shiftby4 : Structural2Mux

    PORT MAP(

      i_A => s_shiftedBy2(i),
      i_B => s_shiftedBy2(i - 1),
      i_S => i_Shift(2),
      o_F => s_shiftedBy4(i));

  END GENERATE;

  --end shift4 ------------------------------------------------------

  --shift 8

  shift8_zeros : FOR i IN 0 TO 7 GENERATE
    s8zeros : Structural2Mux

    PORT MAP(

      i_A => s_shiftedBy4(i),
      i_B => '0',
      i_S => i_Shift(3),
      o_F => s_shiftedBy8(i));

  END GENERATE;

  shift8 : FOR i IN 8 TO numBits - 1 GENERATE
    shiftby8 : Structural2Mux

    PORT MAP(
      i_A => s_shiftedBy4(i),
      i_B => s_shiftedBy4(i - 1),
      i_S => i_Shift(3),

      o_F => s_shiftedBy8(i));

  END GENERATE;

  --end shift 8 ------------------------------------------------------

  --shift 16 ----------------------------------------------------

  shift16_zeros : FOR i IN 0 TO 15 GENERATE
    s16zeros : Structural2Mux

    PORT MAP(

      i_A => s_shiftedBy8(i),
      i_B => '0',
      i_S => i_Shift(4),
      o_F => s_shiftedBy16(i));

  END GENERATE;

  shift16 : FOR i IN 16 TO numBits - 1 GENERATE
    shiftby16 : Structural2Mux

    PORT MAP(

      i_A => s_shiftedBy8(i),
      i_B => s_shiftedBy8(i - 1),
      i_S => i_Shift(4),
      o_F => s_shiftedBy16(i));

  END GENERATE;

  --end shift 16 ------------------------------------------------------

  unInvert : FOR i IN 0 TO numBits - 1 GENERATE
    o_F((numBits - 1) - i) <= s_shiftedBy16(i);

  END GENERATE;

END structure;