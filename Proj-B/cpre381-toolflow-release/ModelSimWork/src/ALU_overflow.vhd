--ALU_overflow
--Cameron Isbell

--ALU WITH OVERFLOW FUNCTIONALITY
--AND WITH o_set USED TO SET LEAST SIG BIT IN ALU_32b

library IEEE;
use IEEE.std_logic_1164.all;

entity ALU_overflow is
	port (	
			in_A0			: in std_logic;
			in_A1			: in std_logic;
			in_carry		: in std_logic;
			in_less			: in std_logic;
			in_select		: in std_logic_vector(2 downto 0);
			
			o_out			: out std_logic;
			o_cOut			: out std_logic;
			o_set			: out std_logic;
			o_overflow		: out std_logic );

end ALU_overflow;

architecture structure of ALU_overflow is 

component ALU1bit
	port (	in_A0, in_A1, in_carry, in_less	: in std_logic;
			in_Select			: in std_logic_vector(2 downto 0);
			o_out, o_cOut	: out std_logic);
end component;

signal s_tempOut : std_logic;
begin

common : ALU1bit
port map ( 
	in_A0 => in_A0,
	in_A1 => in_A1,
	in_carry => in_carry,
	in_less => in_less,
	in_Select => in_select,
	
	o_out => o_out,
	o_cOut => o_cOut );

o_set <= in_carry;

--OVERFLOW != CARRY OUT
--overflow is true when the sign of the output does not match the sign of the inputs

--True if:		2 positives go to a negative			2 negatives go to a positive
o_overflow <= (not in_A0 and not in_A1 and s_tempOut) or (in_A0 and in_A1 and not s_tempOut);
end structure;

