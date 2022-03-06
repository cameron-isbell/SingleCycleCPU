-- Quartus Prime VHDL Template
-- Single-port RAM with single read/write address

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem is

	generic 
	(
		--the length of the bits being loaded
		DATA_WIDTH : natural := 32;	
		--the width of the address
		ADDR_WIDTH : natural := 10
	);

	port 
	(
		clk		: in std_logic; --clock
		addr	        : in std_logic_vector((ADDR_WIDTH-1) downto 0); --address to write to
		data	        : in std_logic_vector((DATA_WIDTH-1) downto 0); --data to write
		we		: in std_logic;											--write enable
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)		--output the memory at the given address
	);

end mem;

architecture rtl of mem is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);	--a word is an std_logic_vector of data
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;		--memory_t is an array  of std_logic_vectors

	-- Declare the RAM signal and specify a default value.	Quartus Prime
	-- will load the provided memory initialization file (.mif).
	signal ram : memory_t;

begin

	process(clk)
	begin
	if(rising_edge(clk)) then
		if(we = '1') then
			ram(to_integer(unsigned(addr))) <= data;	--write the data to the given address
		end if;
	end if;
	end process;

	q <= ram(to_integer(unsigned(addr)));				--output the data

end rtl;
