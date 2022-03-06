--Cameron Isbell
--tb_MIPS_ALU

--The program running the top level design of the shifter, ALU, mem, and
--regFile combined for q4

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_MIPS_ALU is
	generic(gCLK_HPER   : time := 50 ns);
end tb_MIPS_ALU;

architecture testbench of tb_MIPS_ALU is

  constant cCLK_PER  : time := gCLK_HPER * 2;

component MIPS_ALU
generic(numBits    : integer := 32;
				ALUselectBits : integer := 3;
				regSelectBits : integer := 5 );
  port (
	i_Control   : in std_logic_vector(ALUselectBits-1 downto 0);

	i_rd        : in std_logic_vector (regSelectBits-1 downto 0);
	i_rs        : in std_logic_vector (regSelectBits-1 downto 0);
	i_rt        : in std_logic_vector (regSelectBits-1 downto 0);

	i_sw        : in std_logic;
	i_lw        : in std_logic;

	i_memAddr   : in std_logic_vector (9 downto 0);
	i_imm       : in std_logic_vector (numBits-1 downto 0);
	i_ALUSrc    : in std_logic;
	i_nAdd_Sub  : in std_logic;
	i_regWrite  : in std_logic;

	i_srl       : in std_logic;
	i_Shift     : in std_logic_vector (regSelectBits-1 downto 0);
	i_sEn       : in std_logic;

	i_CLK       : in std_logic;

	F           : inout std_logic_vector(numBits-1 downto 0);
	CarryOut    : out std_logic;
	Overflow    : out std_logic;
	Zero        : out std_logic );

end component;

constant numBits : integer := 32;
constant ALUselectBits : integer := 3;
constant regSelectBits : integer := 5;

signal tb_sw, tb_lw, tb_ALUSrc, tb_nAdd_Sub, tb_regWrite, tb_srl, tb_sEn, tb_CLK, tb_CarryOut, tb_Overflow, tb_Zero : std_logic;
signal tb_rd, tb_rs, tb_rt, tb_Shift  : std_logic_vector(regSelectBits-1 downto 0);
signal tb_Control : std_logic_vector(ALUselectBits-1 downto 0);
signal tb_F, tb_imm : std_logic_vector(numBits-1 downto 0);
signal tb_A1, tb_A2 : std_logic_vector(numBits-1 downto 0);

signal tb_memAddr : std_logic_vector(9 downto 0);

begin

alu : MIPS_ALU
port map (

	i_Control => tb_Control,

	i_rd => tb_rd,
	i_rs => tb_rs,
	i_rt => tb_rt,

	i_sw => tb_sw,
	i_lw => tb_lw,

	i_memAddr => tb_memAddr,
	i_imm => tb_imm,
	i_ALUSrc => tb_ALUSrc,
	i_nAdd_Sub => tb_nAdd_Sub,
	i_regWrite => tb_regWrite,

	i_srl => tb_srl,
	i_Shift => tb_Shift,
	i_sEn => tb_sEn,

	i_CLK => tb_CLK,

	F => tb_F,
	CarryOut => tb_CarryOut,
	Overflow => tb_Overflow,
	Zero => tb_Zero );

  P_CLK: process
  begin
  	tb_CLK <= '0';
  	wait for gCLK_HPER;
      tb_CLK <= '1';
      wait for gCLK_HPER;

  end process;

P_TB : process
begin

--add $1, $0, 0xA9800000 -> $1 = 0xA9800000

--add_sub
tb_Control <= "000";

--add immediate
tb_ALUSrc <= '1';
tb_nAdd_Sub <= '0';
tb_rd			<= "00001";
tb_rt 		<= "00000";
tb_rs			<= "00000";
tb_imm		<= X"FFF00000";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000000";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "10000";

wait for cCLK_PER;

--add $2, $1, $0 -> $2 = 0xA9800000

tb_ALUSrc <= '1';
tb_nAdd_Sub <= '0';
tb_rd			<= "00010";
tb_rt 		<= "00001";
tb_rs			<= "00000";
tb_imm		<= X"FFFF0000";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000000";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "10000";

wait for cCLK_PER;


--slt $4, $1, $4 -> $4 = 0x00000000
tb_Control <= "100";
tb_ALUSrc <= '0';
tb_nAdd_Sub <= '0';
tb_rd			<= "00100";
tb_rs			<= "00001";
tb_rt 		<= "00100";
tb_imm		<= X"AAAA0000";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;

--slt $4, $0, $2 -> $4 = 1
tb_ALUSrc <= '1';
tb_nAdd_Sub <= '0';
tb_rd			<= "00100";
tb_rs			<= "00000";
tb_rt 		<= "00010";
tb_imm		<= X"AAAA0000";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;













--sll $2, $1 -> 2 = 0x90000000
tb_ALUSrc <= '0';
tb_nAdd_Sub <= '0';
tb_rd			<= "00010";
tb_rt 		<= "00001";
tb_rs			<= "00000";
tb_imm		<= X"AAAA0000";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000000";

tb_srl <= '0';
tb_sEn <= '1';
tb_Shift <= "00100";

wait for cCLK_PER;

--sw 1, $1 -> mem(1) = $1
tb_ALUSrc <= '0';
tb_nAdd_Sub <= '0';
tb_rd			<= "00011";
tb_rs			<= "00001";
tb_rt 		<= "00000";
tb_imm		<= X"AAAA0000";

tb_sw <= '1';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;

--lw $4, 1 -> $4 =  mem(1)
tb_ALUSrc <= '0';
tb_nAdd_Sub <= '0';
tb_rd			<= "00100";
tb_rs			<= "00001";
tb_rt 		<= "00000";
tb_imm		<= X"AAAA0000";

tb_sw <= '0';
tb_lw <= '1';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;



--nand $5, $2, $1 -> 0x77FFFFFF
tb_Control <= "101";
tb_ALUSrc <= '0';
tb_nAdd_Sub <= '0';
tb_rd			<= "00101";
tb_rs			<= "00010";
tb_rt 		<= "00001";
tb_imm		<= X"AAAA0000";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;

--nand $5, $2, $1 -> 0x77FFFFFF
tb_Control <= "101";
tb_ALUSrc <= '0';
tb_nAdd_Sub <= '0';
tb_rd			<= "00101";
tb_rs			<= "00101";
tb_rt 		<= "00101";
tb_imm		<= X"AAAA0000";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;

--ori $5, $0, 0xFFFFFFFF ->
tb_Control <= "110";
tb_ALUSrc <= '1';
tb_nAdd_Sub <= '0';
tb_rd			<= "00101";
tb_rs			<= "00000";
tb_rt 		<= "00001";
tb_imm		<= X"FFFFFFFF";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;

--or $6, $5, $2
tb_Control <= "110";
tb_ALUSrc <= '0';
tb_nAdd_Sub <= '0';
tb_rd			<= "00110";
tb_rs			<= "00101";
tb_rt 		<= "00010";
tb_imm		<= X"AAAA0000";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;

--and $7, $5, 0x10101010
tb_Control <= "001";
tb_ALUSrc <= '1';
tb_nAdd_Sub <= '0';
tb_rd			<= "00111";
tb_rs			<= "00101";
tb_rt 		<= "00001";
tb_imm		<= X"10101010";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;

--xor $8, $7, $0
tb_Control <= "011";
tb_ALUSrc <= '0';
tb_nAdd_Sub <= '0';
tb_rd			<= "01001";
tb_rs			<= "00111";
tb_rt 		<= "00000";
tb_imm		<= X"AAAA0000";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;

--xori $8, $8, 0xFFFFFFFF
tb_Control <= "011";
tb_ALUSrc <= '1';
tb_nAdd_Sub <= '0';
tb_rd			<= "01000";
tb_rs			<= "01000";
tb_rt 		<= "00001";
tb_imm		<= X"FFFFFFFF";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;

--nori $8, $8, 0xFFFFFFFF
tb_Control <= "010";
tb_ALUSrc <= '1';
tb_nAdd_Sub <= '0';
tb_rd			<= "01000";
tb_rs			<= "01000";
tb_rt 		<= "00001";
tb_imm		<= X"FFFFFFFF";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;

--nor $8, $7, $8
tb_Control <= "101";
tb_ALUSrc <= '0';
tb_nAdd_Sub <= '0';
tb_rd			<= "01000";
tb_rs			<= "00111";
tb_rt 		<= "01000";
tb_imm		<= X"AAAA0000";

tb_sw <= '0';
tb_lw <= '0';

tb_regWrite <= '1';
tb_memAddr  <= "0000000001";

tb_srl <= '0';
tb_sEn <= '0';
tb_Shift <= "00100";

wait for cCLK_PER;


end process;


end testbench;
