--TB_ALU_32b
--Cameron Isbell

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_ALU_32b is
	generic(gCLK_HPER   : time := 50 ns);
end TB_ALU_32b;

architecture testbench of TB_ALU_32b is

constant cCLK_PER  : time := gCLK_HPER * 2;

component ALU_32b
generic (numBits : integer := 32;
		 selectBits : integer := 3 );
port (
	i_A 		: in std_logic_vector(numBits-1 downto 0);
	i_B 		: in std_logic_vector(numBits-1 downto 0);
	i_Control	: in std_logic_vector(selectBits-1 downto 0);

	F	  		: inout std_logic_vector(numBits-1 downto 0);
	CarryOut	: out std_logic;
	Overflow	: out std_logic;
	Zero		: out std_logic );

end component;

signal tb_a, tb_b, tb_F : std_logic_vector(31 downto 0);
signal tb_control : std_logic_vector(2 downto 0);
signal tb_CLK, tb_cOut, tb_overflow, tb_zero : std_logic;

begin

alu : ALU_32b
port map (
	i_A 		=> tb_a,
	i_B 		=> tb_b,
	i_Control	=> tb_control,

	F	  		=> tb_F,
	CarryOut	=> tb_cOut,
	Overflow	=> tb_overflow,
	Zero		=> tb_zero );

P_CLK: process
begin
	tb_CLK <= '0';
	wait for gCLK_HPER;
    tb_CLK <= '1';
    wait for gCLK_HPER;

end process;

P_TB : process
begin
--000 = add/sub
--001 = and
--010 = nor
--011 = xor
--100 = slt
--101 = nand
--110 = or

--add
tb_a <= X"21222222";
tb_b <= X"11111111";
tb_control <= "000";

wait for cCLK_PER;

--add
tb_a <= X"F0000000";
tb_b <= X"F0000000";
tb_control <= "000";

wait for cCLK_PER;



--and
tb_a <= X"00000001";
tb_b <= X"00000001";
tb_control <= "001";

wait for cCLK_PER;



--nor
tb_a <= X"00000001";
tb_b <= X"00000000";
tb_control <= "010";

wait for cCLK_PER;

--xor
tb_a <= X"00000001";
tb_b <= X"00000001";
tb_control <= "011";

wait for cCLK_PER;

--slt
tb_a <= X"00111101";
tb_b <= X"01101CA1";
tb_control <= "100";

wait for cCLK_PER;

--slt
tb_a <= X"11111111";
tb_b <= X"01111111";
tb_control <= "100";

wait for cCLK_PER;

--slt
tb_a <= X"11111111";
tb_b <= X"11111111";
tb_control <= "100";

wait for cCLK_PER;

--nand
tb_a <= X"00000001";
tb_b <= X"00000001";
tb_control <= "101";

wait for cCLK_PER;

--or
tb_a <= X"00000000";
tb_b <= X"00000000";
tb_control <= "110";

wait for cCLK_PER;

end process;
end testbench;
