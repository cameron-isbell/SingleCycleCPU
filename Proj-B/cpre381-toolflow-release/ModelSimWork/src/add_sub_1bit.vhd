library IEEE;
use IEEE.std_logic_1164.all;

entity add_sub_1bit is
	port (
		a_in 	: in std_logic;
		b_in 	: in std_logic;
		c_in 	: in std_logic;
		sub_in  : in std_logic;

		result 	: out std_logic;
		c_out  	: out std_logic );

end add_sub_1bit;

architecture structure of add_sub_1bit is

  component full_adder_struct_nbit
  	generic (N : integer := 1);
  	port(
  		a_in    : in std_logic_vector(N-1 downto 0);
  		b_in    : in std_logic_vector(N-1 downto 0);
  		c_in    : in std_logic;

  		c_out   : out std_logic;
      s_out   : out std_logic_vector(N-1 downto 0));

  end component;

  component mux2_struct
  	port(
  			a_in  : in std_logic;
  		  b_in  : in std_logic;

  		  o_F  : out std_logic;
  		  s_in  : in std_logic );
  end component;

signal s_notB, s_c, s_cSubOut, s_cAddOut : std_logic;

begin

perfOp : full_adder_struct_nbit
  port map (
    a_in(0) => a_in,
    b_in(0) => b_in,
    c_in => c_in,

    c_out => s_cAddOut,
    s_out(0) => result  );

--carry out for subtraction
s_cSubOut <= (( not a_in ) and c_in ) or ((not a_in) and b_in) or (b_in and c_in);

mux_carry : mux2_struct
port map (
  a_in => s_cAddOut,
  b_in => s_cSubOut,

  o_F => c_out,
  s_in => sub_in );

end structure;
