library IEEE;
use IEEE.std_logic_1164.all;

entity pipeline_reg is
    generic (numBits : integer := 32);
    port (
        i_data  : in std_logic_vector (numBits-1 downto 0); 
        i_flush : in std_logic;
        i_stall : in std_logic;
        i_CLK   : in std_logic;
        o_F     : inout std_logic_vector (numBits-1 downto 0) );
end pipeline_reg;

architecture structure of pipeline_reg is 
    component reg_nbit 
    generic (N : integer := 32);
    port (
        i_CLK 			: in std_logic; --clock for dff
        i_R				: in std_logic; --reset for dff
        i_W		        : in std_logic; --write enable for dff

        in_data 	: in std_logic_vector (N-1 downto 0);
        out_data	: inout std_logic_vector (N-1 downto 0) ); --inout bc it has to be read by a mux to go back into dff
    end component;

begin 
    reg : reg_nbit
    generic map (N => numBits)
    port map ( 
        i_CLK => i_CLK,
        i_R => i_flush,
        i_W => i_stall,

        in_data => i_data,
        out_data => o_F );

end structure;
