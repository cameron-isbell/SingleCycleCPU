library IEEE;
use IEEE.std_logic_1164.all;

entity ID_EX is
generic (N : integer := 32);
port (
	i_CLK 			: in std_logic; --clock for dff
	i_R				: in std_logic; --reset for dff
	i_W		        : in std_logic; --write enable for the lead in mux of in_data(1), out_data(0)

	in_IDEX_WrEn		: in std_logic; --write enable for the pipeline ID/EX dff

	--Control values that need to be added below:
	--All inputs and outputs
	--ALUSrc, ALUOp, RegDst, MemWr, Branch, MemtoReg, RegWr, ExtOp?

	in_data 	: in std_logic_vector (N-1 downto 0);
	out_data	: inout std_logic_vector (N-1 downto 0) ); --inout bc it has to be read by a mux to go back into dff

end ID_EX;

architecture structure of ID_EX is

component dffTrue
port(
	i_CLK        : in std_logic;     -- Clock input
	i_RST        : in std_logic;     -- Reset input
	i_WE         : in std_logic;     -- Write enable input
	i_D          : in std_logic;     -- Data value input
	o_Q          : out std_logic );   -- Data value output

end component;

component mux2_struct
port (
	a_in 	: in std_logic;
	b_in 	: in std_logic;
	s_in 	: in std_logic;

	o_F	: out std_logic );

end component;

signal to_load : std_logic_vector (N-1 downto 0);

begin

G1: for i in 0 to N-1 generate

mux_in : mux2_struct
port map (
	a_in => out_data(i),
	b_in => in_data(i),
	s_in => i_W,

	o_F => to_load (i) );


reg_n : dffTrue
port map (
	i_CLK => i_CLK,
	i_RST => i_R,
	i_WE  => in_IDEX_WrEn, --Select value
	i_D   => to_load(i),

	o_Q   => out_data(i) );

end generate;

end structure;
