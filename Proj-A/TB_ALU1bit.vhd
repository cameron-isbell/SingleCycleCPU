-- tb_ALU1bit.vhd
-- Matthew G. Hoskins

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_ALU1bit is
	generic (gCLK_HPER	: time := 50 ns);
end tb_ALU1bit;

architecture behavior of tb_ALU1bit is

	-- Calculate the clock period as twice the half-period
	constant cCLK_PER  : time := gCLK_HPER * 2;
	
	component ALU1bit
		port (	in_A0, in_A1, in_carry, in_less	: in std_logic;
				in_Select		: in std_logic_vector(2 downto 0);
				o_out, o_cOut	: out std_logic);
	end component;
	
	signal s_A0, s_A1, s_carry, s_less : std_logic;
	signal s_Select : std_logic_vector(2 downto 0);
	signal s_out, s_cOut : std_logic;
	signal s_CLK : std_logic;
	
	begin
		ALU : ALU1bit
			port map (	in_A0 => s_A0,
						in_A1 => s_A1,
						in_carry => s_carry,
						in_less => s_less,
						in_Select => s_Select,
						o_out => s_out,
						o_cOut => s_cOut);
						
		-- This process sets the clock value (low for gCLK_HPER, then high
		-- for gCLK_HPER). Absent a "wait" command, processes restart 
		-- at the beginning once they have reached the final statement.
		P_CLK: process
			begin
				s_CLK <= '0';
				wait for gCLK_HPER;
				s_CLK <= '1';
				wait for gCLK_HPER;
			end process;
			
		-- Testbench Process
		P_TB: process
			begin
				-----------------------------------------------------
				-- Select 000 [add_sub]
				s_Select <= "000";
				s_A0 <= '0';
				s_A1 <= '0';
				s_carry <= '0';
				wait for cCLK_PER;
				-- should set s_out to 0
				-- should set s_cOut to 0
				s_A0 <= '1';
				s_A1 <= '0';
				s_carry <= '0';
				wait for cCLK_PER;
				-- should set s_out to 1
				-- should set s_cOut to 0
				s_A0 <= '0';
				s_A1 <= '1';
				s_carry <= '0';
				wait for cCLK_PER;
				-- should set s_out to 1
				-- should set s_cOut to 0
				s_A0 <= '1';
				s_A1 <= '0';
				s_carry <= '1';
				wait for cCLK_PER;
				-- should set s_out to 0
				-- should set s_cOut to 1
				s_A0 <= '1';
				s_A1 <= '1';
				s_carry <= '0';
				wait for cCLK_PER;
				-- should set s_out to 0
				-- should set s_cOut to 1
				s_A0 <= '1';
				s_A1 <= '1';
				s_carry <= '1';
				wait for cCLK_PER;
				-- should set s_out to 1
				-- should set s_cOut to 1
				wait for cCLK_PER;
				-----------------------------------------------------
				
				-----------------------------------------------------
				-- Select 001 [and]
				s_Select <= "001";
				s_A0 <= '0';
				s_A1 <= '0';
				wait for cCLK_PER;
				-- should set s_out to 0
				s_A0 <= '1';
				s_A1 <= '0';
				wait for cCLK_PER;
				-- should set s_out to 0
				s_A0 <= '0';
				s_A1 <= '1';
				wait for cCLK_PER;
				-- should set s_out to 0
				s_A0 <= '1';
				s_A1 <= '1';
				wait for cCLK_PER;
				-- should set s_out to 1
				wait for cCLK_PER;
				-----------------------------------------------------
				
				-----------------------------------------------------
				-- Select 010 [nor]
				s_Select <= "010";
				s_A0 <= '0';
				s_A1 <= '0';
				wait for cCLK_PER;
				-- should set s_out to 1
				s_A0 <= '1';
				s_A1 <= '0';
				wait for cCLK_PER;
				-- should set s_out to 0
				s_A0 <= '0';
				s_A1 <= '1';
				wait for cCLK_PER;
				-- should set s_out to 0
				s_A0 <= '1';
				s_A1 <= '1';
				wait for cCLK_PER;
				-- should set s_out to 0
				wait for cCLK_PER;
				-----------------------------------------------------
				
				-----------------------------------------------------
				-- Select 011 [xor]
				s_Select <= "011";
				s_A0 <= '0';
				s_A1 <= '0';
				wait for cCLK_PER;
				-- should set s_out to 0
				s_A0 <= '1';
				s_A1 <= '0';
				wait for cCLK_PER;
				-- should set s_out to 1
				s_A0 <= '0';
				s_A1 <= '1';
				wait for cCLK_PER;
				-- should set s_out to 1
				s_A0 <= '1';
				s_A1 <= '1';
				wait for cCLK_PER;
				-- should set s_out to 0
				wait for cCLK_PER;
				-----------------------------------------------------
				
				-----------------------------------------------------
				-- Select 100 [set_less_than]
				s_Select <= "100";
				s_A0 <= '0';
				s_A1 <= '0';
				s_less <= '0';
				wait for cCLK_PER;
				-- should set s_out to 0
				-- should set s_cOut to 0
				s_A0 <= '1';
				s_A1 <= '1';
				s_less <= '1';
				wait for cCLK_PER;
				-- should set s_out to 1
				-- should set s_cOut to 0
				-----------------------------------------------------
				
				-----------------------------------------------------
				-- Select 101 [nand]
				s_Select <= "101";
				s_A0 <= '0';
				s_A1 <= '0';
				wait for cCLK_PER;
				-- should set s_out to 1
				s_A0 <= '1';
				s_A1 <= '0';
				wait for cCLK_PER;
				-- should set s_out to 1
				s_A0 <= '0';
				s_A1 <= '1';
				wait for cCLK_PER;
				-- should set s_out to 1
				s_A0 <= '1';
				s_A1 <= '1';
				wait for cCLK_PER;
				-- should set s_out to 0
				wait for cCLK_PER;
				-----------------------------------------------------
				
				-----------------------------------------------------
				-- Select 110 [or]	
				s_Select <= "110";				
				s_A0 <= '0';
				s_A1 <= '0';
				wait for cCLK_PER;
				-- should set s_out to 0
				s_A0 <= '1';
				s_A1 <= '0';
				wait for cCLK_PER;
				-- should set s_out to 1
				s_A0 <= '0';
				s_A1 <= '1';
				wait for cCLK_PER;
				-- should set s_out to 1
				s_A0 <= '1';
				s_A1 <= '1';
				wait for cCLK_PER;
				-- should set s_out to 1
				wait for cCLK_PER;
				-----------------------------------------------------
				
				-----------------------------------------------------
				-- Select 111 [return 0]
				s_Select <= "111";
				s_A0 <= '0';
				s_A1 <= '0';
				wait for cCLK_PER;
				-- should set s_out to 0 no matter input
				s_A0 <= '1';
				s_A1 <= '0';
				wait for cCLK_PER;
				-- should set s_out to 0 no matter input
				s_A0 <= '0';
				s_A1 <= '1';
				wait for cCLK_PER;
				-- should set s_out to 0 no matter input
				s_A0 <= '1';
				s_A1 <= '1';
				wait for cCLK_PER;
				-- should set s_out to 0 no matter input
				-----------------------------------------------------
				
			end process;

end behavior;