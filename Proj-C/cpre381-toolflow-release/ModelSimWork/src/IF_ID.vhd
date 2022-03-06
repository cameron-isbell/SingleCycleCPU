library IEEE;
use IEEE.std_logic_1164.all;

entity IF_ID is
generic (N : integer := 32);
port (
	i_CLK 			: in std_logic; --clock for dff
	i_stall			: in std_logic;
	i_data 			: in std_logic_vector (N-1 downto 0);
	
	o_data		    : out std_logic_vector (N-1 downto 0) );

end IF_ID;

architecture structure of IF_ID is

component NMux 
generic(N : integer := 32);
	port(in_Select : in std_logic;
	     in_A : in std_logic_vector((N - 1) downto 0);
	     in_B : in std_logic_vector((N - 1) downto 0);
	     o_F : out std_logic_vector((N - 1) downto 0));
end component;

component reg_nbit
	generic (N : integer := 32);
	port (
		i_CLK 			: in std_logic; --clock for dff
		i_R				: in std_logic; --reset for dff
		i_W		        : in std_logic; --write enable for dff

		in_data 	: in std_logic_vector (N-1 downto 0);
		out_data	: inout std_logic_vector (N-1 downto 0) ); --inout bc it has to be read by a mux to go back into dff
end component;

signal s_regOut: std_logic_vector(N-1 downto 0);
signal s_wr    : std_logic;

begin
	--don't write when stalling
	s_wr <= not i_stall;

	reg : reg_nbit
	port map (
		i_CLK => i_CLK,
		i_R => '0',
		i_W => '1',

		in_data => i_data,
		out_data => s_regOut );

	
	--if stalling, output NOP
	muxFlush : NMux
	port map (
		in_Select => i_stall,
		in_A => s_regOut,
		in_B => X"00000000",

		o_F => o_data );
	
end structure;
