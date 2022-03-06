-- shifter.vhd
-- Matthew G. Hoskins

library IEEE;
use IEEE.std_logic_1164.all;

entity shifter is
	generic (N: integer := 32);
	port(in_ShiftAmount	: in std_logic_vector (4 downto 0); 	--Amount to shift by (select values) (1,2,4,8,16)
		in_styleSelect	: in std_logic;							--Arithmetic for 1 (keep sign), logical for 0 (loose sign)
		in_input		: in std_logic_vector ((N-1) downto 0);	--Input that will be shifted
		o_output		: out std_logic_vector((N-1) downto 0)	--Shifted output
	);
end shifter;

architecture structural of shifter is 

	component NMux is
		generic(N : integer := 32);
		port(in_Select : in std_logic;
			 in_A : in std_logic_vector((N - 1) downto 0);
			 in_B : in std_logic_vector((N - 1) downto 0);
			 o_F : out std_logic_vector((N - 1) downto 0)
			);
	end component;
	
	component mux2_struct is
		port(	a_in 	: in std_logic;
				b_in 	: in std_logic;
				s_in 	: in std_logic;

				o_F	: out std_logic
			);
	end component;
	
	signal s_msBit : std_logic;
	signal s_shift1, s_shift2, s_shift4, s_shift8, s_shift16	: std_logic_vector((N-1) downto 0);
	
	begin
	
		style_mux : mux2_struct		-- Determine if keeping sign (MSB) if 0 then no, if 1 then yes
			port map(
				a_in => '0',
				b_in => in_input(N-1),
				s_in => in_styleSelect,
				o_F => s_msBit
			);
			
			
		-- Shift by 1 bit ---------------------------------
		shift1_mux0 : mux2_struct
			port map (
				a_in => in_input,
				b_in => s_msBit,
				s_in => in_ShiftAmount(0),
				o_F => s_shift1(0)
			);
		
		G1: for i in 1 to N-1 generate
			shift1_mux_i : mux2_struct
				port map(
					a_in => in_input(i),
					b_in => in_input(i-1)
					s_in => in_ShiftAmount(0),
					o_F => s_shift1(i)
				);
		end generate;
		
		
		-- Shift by 2 bits --------------------------------
		shift2_mux0 : mux2_struct
			port map (
				a_in => s_shift1(0),
				b_in => s_msBit,
				s_in => in_ShiftAmount(1),
				o_F => s_shift2(0)
			);
			
		shift2_mux1 : mux2_struct
			port map (
				a_in => s_shift1(1),
				b_in => s_msBit,
				s_in => in_ShiftAmount(1),
				o_F => s_shift2(1)
			);
		
		G2: for i in 2 to N-1 generate
			shift2_mux_i : mux2_struct
				port map (
					a_in => s_shift1(i),
					b_in => s_shift1(i-2),
					s_in => in_ShiftAmount(1),
					o_F => s_shift2(i)
				);
		end generate;
		
		
		-- Shift by 4 bits --------------------------------
		G4_0thru3 : for i in 0 to 3 generate
			shift4_mux_i3 : mux2_struct
				port map (
					a_in => s_shift2(i),
					b_in => s_msBit,
					s_in => in_ShiftAmount(2),
					o_F => s_shift4(i)
				);
		end generate;
		
		G4_4thruN : for i in 4 to N-1 generate
			shift4_mux_iN : mux2_struct
				port map (
					a_in => s_shift2(i),
					b_in => s_shift2(i-4),
					s_in => in_ShiftAmount(2),
					o_F => s_shift4(i)
				);
		end generate;
		
		
		-- Shift by 8 bits --------------------------------
		G8_0thru7 : for i in 0 to 7 generate
			shift8_mux_i7 : mux2_struct
				port map (
					a_in => s_shift4(i),
					b_in => s_msBit,
					s_in => in_ShiftAmount(3),
					o_F => s_shift8(i)
				);
		end generate;
		
		G8_7thruN : for i in 8 to N-1 generate
			shift8_mux_iN : mux2_struct
				port map (
					a_in => s_shift4(i),
					b_in => s_shift4(i-8),
					s_in => in_ShiftAmount(3),
					o_F => s_shift4(i)
				);
		end generate;
		
		-- Shift by 16 bits -------------------------------
		G16_0thru15 : for i in 0 to 15 generate
			shift16_muxi15 : mux2_struct
				port map (
					a_in => s_shift8(i),
					b_in => s_msBit,
					s_in => in_ShiftAmount(4),
					o_F => s_shift16(i)
				);
		end generate;
		
		G16_15thruN : for i in 16 to N-1 generate
			shift16_muxiN : mux2_struct
				port map (
					a_in => s_shift8(i),
					b_in => s_shift8(i-16),
					s_in => in_ShiftAmount(4),
					o_F => s_shift16(i)
				);
		end generate;
		
		finalMux : mux2_struct
			port map (
				a_in => s_shift16,
				b_in => '1',
				s_in => '0',
				o_F => o_output
			);
		
end structural;