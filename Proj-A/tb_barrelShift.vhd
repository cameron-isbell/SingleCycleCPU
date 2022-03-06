-- tb_barrelShift.vhd
-- Matthew G. Hoskins

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_barrelShift is
	generic (gCLK_HPER	: time := 50 ns);
end tb_barrelShift;

architecture behavior of tb_barrelShift is

	-- Calculate the clock period as twice the half-period
	constant cCLK_PER  : time := gCLK_HPER * 2;
	
	component barrel_shift
		generic(numBits : integer := 32;
				shiftLen : integer := 5 );
		  port (
			  i_A     : in std_logic_vector(numBits-1 downto 0);
			  i_Shift : in std_logic_vector(shiftLen-1 downto 0);
			  i_srl   : in std_logic;                               --shift right logical. If 1, reverse i_A
			  o_F     : out std_logic_vector(numBits-1 downto 0) );
	end component;
	
	signal s_A, s_F : std_logic_vector(31 downto 0);
	signal s_Shift  : std_logic_vector(4 downto 0);
	signal s_srl	: std_logic;
	signal s_CLK : std_logic;
	
	begin
		barrel : barrel_shift
			port map (	i_A => s_A,
						i_Shift => s_Shift,
						i_srl => s_srl,
						o_F => s_F);
	
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
				-- Shift by 0 bits
				s_A <= x"00000001";
				s_Shift <= "00000";
				s_srl <= '0';
				wait for cCLK_PER;
				-- Result: 00000001
				
				-- Shift by 1 bits
				s_A <= x"00000001";
				s_Shift <= "00001";
				s_srl <= '0';
				wait for cCLK_PER;
				-- Result: 00000002
				
				-- Shift by 2 bits
				s_A <= x"10001000";
				s_Shift <= "00010";
				s_srl <= '0';
				wait for cCLK_PER;
				-- Result: 40004000
				
				-- Shift by 4 bits
				s_A <= x"00000F0F";
				s_Shift <= "00100";
				s_srl <= '0';
				wait for cCLK_PER;
				-- Result: 0000F0F0
				
				-- Shift by 8 bits
				s_A <= x"00000100";
				s_Shift <= "01000";
				s_srl <= '0';
				wait for cCLK_PER;
				-- Result: 00010000
				
				-- Shift by 16 bits
				s_A <= x"00000001";
				s_Shift <= "10000";
				s_srl <= '0';
				wait for cCLK_PER;
				-- Result: 00010000
				
				-- Reverse and shift by 1 bits
				s_A <= x"00000001";
				s_Shift <= "00001";
				s_srl <= '1';
				wait for cCLK_PER;
				
		end process;

end behavior;