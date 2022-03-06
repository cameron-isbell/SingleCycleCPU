library IEEE;
use IEEE.std_logic_1164.all;

entity funct_decrypt is
  port( in_functCode  : in std_logic_vector(5 downto 0);  --instruction [5-0] (function code) get it from instruction IMem
        in_enable      : in std_logic;                     --enable values
        in_ALUOp      : in std_logic_vector(1 downto 0);  --ALUOp0 and ALUOp1 from control_Unit
        o_shift       : out std_logic;
        o_vectorShift : out std_logic;
        o_shiftLogical  : out std_logic;
        o_shiftRight  : out std_logic;
        o_jr          : out std_logic;
        o_ALUCtrl     : out std_logic_vector(2 downto 0)); --feeds to ALU acting as control
end funct_decrypt;

architecture dataflow of funct_decrypt is

  --signal

  begin
    process(in_functCode, in_enable)
    begin
      S1: case(in_functCode) is
        when "100000" =>
            o_ALUCtrl <= "000"; --add
            o_shift <= '0';
            o_jr <= '0';

        when "100001" =>
            o_ALUCtrl <= "000"; --addu (maybe 000)
            o_shift <= '0';
            o_jr <= '0';

        when "100100" =>
            o_ALUCtrl <= "001"; --and
            o_shift <= '0';
            o_jr <= '0';

        when "100111" =>
            o_ALUCtrl <= "010"; --nor
            o_shift <= '0';
            o_jr <= '0';

        when "100110" =>
            o_ALUCtrl <= "011"; --xor
            o_shift <= '0';
            o_jr <= '0';

        when "100101" =>
            o_ALUCtrl <= "110"; --or
            o_shift <= '0';
            o_jr <= '0';

        when "101010" =>
            o_ALUCtrl <= "100"; --slt
            o_shift <= '0';
            o_jr <= '0';

        when "101011" =>
            o_ALUCtrl <= "100"; --sltu (maybe 100)
            o_shift <= '0';
            o_jr <= '0';

        --Below not applicable to ALU?

        when "000000" =>
            o_ALUCtrl <= "111"; --sll
            o_shift <= '1';
            o_shiftRight <= '0';
            o_vectorShift <= '0';
            o_shiftLogical <= '1';
            o_jr <= '0';

        when "000010" =>
            o_ALUCtrl <= "111"; --srl
            o_shift <= '1';
            o_shiftRight <= '1';
            o_vectorShift <= '0';
            o_shiftLogical <= '1';
            o_jr <= '0';

        when "000011" =>
            o_ALUCtrl <= "111"; --sra
            o_shift <= '1';
            o_shiftRight <= '1';
            o_vectorShift <= '0';
            o_shiftLogical <= '0';
            o_jr <= '0';

        when "000100" =>
            o_ALUCtrl <= "111"; --sllv
            o_shift <= '1';
            o_shiftRight <= '0';
            o_vectorShift <= '1';
            o_shiftLogical <= '1';
            o_jr <= '0';

        when "000110" =>
            o_ALUCtrl <= "111"; --srlv
            o_shift <= '1';
            o_shiftRight <= '1';
            o_vectorShift <= '1';
            o_shiftLogical <= '1';
            o_jr <= '0';

        when "000111" =>
            o_ALUCtrl <= "111"; --srav
            o_shift <= '1';
            o_shiftRight <= '1';
            o_vectorShift <= '1';
            o_shiftLogical <= '1';
            o_jr <= '0';

        when "001000" =>
        -- jr
            o_ALUCtrl <= "111";
            o_shift <= '0';
            o_jr <= '1';

        when "100010" =>
          o_ALUCtrl <= "111"; --sub
          o_shift <= '0';
          o_jr <= '0';

        when "100011" =>
          o_ALUCtrl <= "111"; --subu
          o_shift <= '0';
          o_jr <= '0';

        --Add:000
        --And:001
        --Nor:010
        --Xor:011
        --Slt:100
        --Nand:101
        --Or:110

        when others => o_ALUCtrl <= "111";  --Empty slot
      end case;

    end process;

end architecture;
