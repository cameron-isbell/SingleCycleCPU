--ALU_32b_shift
--Cameron Isbell

library IEEE;
use IEEE.std_logic_1164.all;

entity ALU_32b_shift is
  generic (numBits    : integer := 32;
  		     selectBits : integer := 3;
           shiftLen   : integer := 5 );
  port (
  	i_A 		  : in std_logic_vector(numBits-1 downto 0);		--input/operand A
  	i_B 	   	: in std_logic_vector(numBits-1 downto 0);		--input/operand B
  	i_Control	: in std_logic_vector(selectBits-1 downto 0);	--control input, each bit used to control a 1bit ALU

    i_srl     : in std_logic;
    i_Shift   : in std_logic_vector (shiftLen-1 downto 0);
    i_sEn     : in std_logic;

  	F	  	  	: inout std_logic_vector(numBits-1 downto 0); 	--Output
  	CarryOut	: out std_logic;
  	Overflow	: out std_logic;
  	Zero		  : out std_logic );

end ALU_32b_shift;

architecture structure of ALU_32b_shift is

component ALU_32b
  generic (numBits : integer := 32;
		       selectBits : integer := 3 );
  port (
    i_A 		  : in std_logic_vector(numBits-1 downto 0);		--input/operand A
    i_B 		  : in std_logic_vector(numBits-1 downto 0);		--input/operand B
    i_Control	: in std_logic_vector(selectBits-1 downto 0);	--control input, each bit used to control a 1bit ALU

    F	  		  : inout std_logic_vector(numBits-1 downto 0); 	--Output
    CarryOut	: out std_logic;
    Overflow	: out std_logic;
    Zero		  : out std_logic );								--1 if A = 0 and B = 0

end component;

component NMux
  generic (N : integer := 32);
  port (
       in_Select : in std_logic;
	     in_A : in std_logic_vector((N - 1) downto 0);
	     in_B : in std_logic_vector((N - 1) downto 0);
	     o_F : out std_logic_vector((N - 1) downto 0) );

end component;

component barrel_shift
  generic(numBits : integer := 32;
          shiftLen : integer := 5 );
  port (
      i_A     : in std_logic_vector(numBits-1 downto 0);
      i_Shift : in std_logic_vector(shiftLen-1 downto 0);
      i_srl   : in std_logic;                               --shift right logical. If 1, reverse i_A
      o_F     : out std_logic_vector(numBits-1 downto 0) );
end component;

signal s_ALUout, s_shiftOut : std_logic_vector(numBits-1 downto 0);

begin

alu : ALU_32b
port map (
  i_A       =>  i_A,
  i_B       =>  i_B,
  i_Control =>  i_Control,

  F         => s_ALUout,
  CarryOut  => CarryOut,
  Overflow  => Overflow,
  Zero      => Zero );

shifter : barrel_shift
port map (
  i_A     => s_ALUout,
  i_Shift => i_Shift,
  i_srl   => i_srl,
  o_F     => s_shiftOut );

mux : NMux
port map (
   in_select => i_sEn,
   in_A      => s_ALUout,
   in_B      => s_shiftOut,

   o_F       => F );

end structure;
