-- mux8to1.vhd
-- Matthew G. Hoskins

library IEEE;
use IEEE.std_logic_1164.all;

entity mux8to1 is
	generic(N : integer := 32);
	port(in_select : in std_logic_vector(2 downto 0);
		 in_data0, in_data1, in_data2, in_data3, in_data4, in_data5, in_data6, in_data7 : in std_logic_vector((N - 1) downto 0);
		 o_Data : out std_logic_vector((N - 1) downto 0));
end mux8to1;

architecture structural of mux8to1 is

	component NMux
		generic(N : integer := 32);
		port(in_Select : in std_logic;
			 in_A : in std_logic_vector((N - 1) downto 0);
			 in_B : in std_logic_vector((N - 1) downto 0);
			 o_F : out std_logic_vector((N - 1) downto 0));
	end component;
	
	signal s_0, s_1, s_2, s_3, s_4, s_5 :  std_logic_vector((N - 1) downto 0);
	
	begin
		mux0 : NMux
			generic map(N => N)
			port map (in_Select => in_select(0),
					in_A => in_data0,
					in_B => in_data1,
					o_F => s_0);
					
		mux1 : NMux
			generic map(N => N)
			port map (in_Select => in_select(0),
					in_A => in_data2,
					in_B => in_data3,
					o_F => s_1);
					
		mux2 : NMux
			generic map(N => N)
			port map (in_Select => in_select(0),
					in_A => in_data4,
					in_B => in_data5,
					o_F => s_2);
					
		mux3 : NMux
			generic map(N => N)
			port map (in_Select => in_select(0),
					in_A => in_data6,
					in_B => in_data7,
					o_F => s_3);
					
		mux4 : NMux
			generic map(N => N)
			port map (in_Select => in_select(1),
					in_A => s_0,
					in_B => s_1,
					o_F => s_4);
		
		mux5 : NMux
			generic map(N => N)
			port map (in_Select => in_select(1),
					in_A => s_2,
					in_B => s_3,
					o_F => s_5);
					
		mux6 : NMux
			generic map(N => N)
			port map (in_Select => in_select(2),
					in_A => s_4,
					in_B => s_5,
					o_F => o_Data);

end structural;