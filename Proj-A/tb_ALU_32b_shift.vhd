library IEEE;
use IEEE.std_logic_1164.all;

entity tb_ALU_32b_shift is
	generic(gCLK_HPER   : time := 50 ns);
end tb_ALU_32b_shift;

architecture testbench of tb_ALU_32b_shift is



component ALU_32b_shift
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

end component;

signal tb_A, tb_B
signal tb_Control, t
signal tb_srl, tb_sEn, tb_Zero, tb_


end testbench;
