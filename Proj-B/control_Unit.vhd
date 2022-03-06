library IEEE;
use IEEE.std_logic_1164.all;

entity control_Unit is
  port (in_Opcode  : in std_logic_vector(5 downto 0);  --instruction [31-26] (opcode)
        o_regDst        : out std_logic;
        o_regWrite      : out std_logic;
        o_ALUOp         : out std_logic_vector(1 downto 0); --ALUOp1 and ALUOp0 (The "select values" of the ALU_Control)
        o_ALUSrc        : out std_logic;
        o_MemWrite      : out std_logic;
        o_MemRead       : out std_logic;
        o_MemToReg      : out std_logic);
end control_Unit;

architecture dataflow of control_Unit is

  --signal

  begin
    process(in_Opcode)
    begin
      S1: case(in_Opcode) is
        when "000000" =>
        --add, addu, and, nor, xor, or, slt, sltu, sll, srl, sra, sllv, srlv, srav, sub, subu
            o_regDst <= '1';  --writeAddr[15-11]
            o_regWrite <= '1';
            o_ALUOp <= "00";
            o_ALUSrc <= '0';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

        when "001000" =>
        --addi,
            o_regDst <= '0';  --writeAddr[20-16] (same as readAddr2)
            o_regWrite <= '1';
            o_ALUOp <= "00";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

        when "001001" =>
        --addiu
            o_regDst <= '1';
            o_regWrite <= '1';
            o_ALUOp <= "00";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

        when "001100" =>
        --andi
            o_regDst <= '0';
            o_regWrite <= '1';
            o_ALUOp <= "00";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

        when "001111" =>
        --lui
            o_regDst <= '1';
            o_regWrite <= '1';
            o_ALUOp <= "10";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '1';

        when "100011" =>
        --lw
            o_regDst <= '1';
            o_regWrite <= '1';
            o_ALUOp <= "11";
            o_ALUSrc <= 'X';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '1';

        when "001110" =>
        --xori
            o_regDst <= '1';
            o_regWrite <= '1';
            o_ALUOp <= "01";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

        when "001101" =>
        --ori
            o_regDst <= '0';
            o_regWrite <= '1';
            o_ALUOp <= "01";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

        when "001010" =>
        --slti
            o_regDst <= '0';
            o_regWrite <= '1';
            o_ALUOp <= "10";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

        when "001011" =>
        --sltiu
            o_regDst <= '1';
            o_regWrite <= '1';
            o_ALUOp <= "10";
            o_ALUSrc <= '0';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

        when "101011" =>
        --sw
            o_regDst <= 'X';
            o_regWrite <= '0';
            o_ALUOp <= "11";
            o_ALUSrc <= '0';
            o_MemWrite <= '1';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

        when others =>
            o_regDst <= 'X';
            o_regWrite <= 'X';
            o_ALUOp <= "XX";
            o_ALUSrc <= 'X';
            o_MemWrite <= 'X';
            o_MemRead <= 'X';
            o_MemToReg <= 'X';

        end case;

      end process;

end architecture;
