-- Structural2Mux.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an what should be an implementation
-- of a 2:1 mux using and, or, and not gates.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity Structural2Mux is
  port(i_A  : in std_logic;	
       i_B  : in std_logic;	
       i_S  : in std_logic;	
       o_F  : out std_logic);
end Structural2Mux;

architecture structure of Structural2Mux is

component invg
  port(i_A  : in std_logic;
       o_F  : out std_logic);
end component;

component andg2
  port(i_A  : in std_logic;
       i_B  : in std_logic;
       o_F  : out std_logic);
end component;

component org2
  port (i_A : in std_logic;
       i_B  : in std_logic;
       o_F  : out std_logic);
end component;

signal sNot, and1R, and2R : std_logic;

begin

     NotS: invg port map(i_A  => i_S, o_F  => sNot);
     
     And1: andg2 port map(i_A => i_A, i_B => sNot, o_F => and1R);

     And2: andg2 port map(i_A => i_B, i_B => i_S, o_F => and2R);

     Or1: org2 port map(i_A => and1R, i_B => and2R, o_F => o_F);

end structure;