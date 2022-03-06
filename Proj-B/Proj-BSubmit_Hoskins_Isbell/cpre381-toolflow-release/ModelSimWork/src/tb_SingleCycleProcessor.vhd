--tb_SingleCycleProcessor
--Cameron Isbell

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_SingleCycleProcessor is
  generic (gCLK_HPER : time := 50 ns);
end tb_SingleCycleProcessor;

architecture testbench of tb_SingleCycleProcessor is

component SingleCycleProcessor



end component;



begin



end testbench;
