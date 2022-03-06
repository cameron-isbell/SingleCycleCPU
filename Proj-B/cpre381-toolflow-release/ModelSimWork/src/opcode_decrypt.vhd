library IEEE;
use IEEE.std_logic_1164.all;

entity opcode_decrypt is
  port (in_Opcode  : in std_logic_vector(5 downto 0);  --instruction [31-26] (opcode)
        o_regDst        : out std_logic;
        o_regWrite      : out std_logic;
        o_ALUOp         : out std_logic_vector(1 downto 0); --ALUOp1 and ALUOp0 (The "select values" of the ALU_Control)
        o_ALUSrc        : out std_logic;
        o_ALUCtrl       : out std_logic_vector(2 downto 0);
        o_funct         : out std_logic;          --Select funciton (1 if ALU info from funct_decrypt, 0 if ALU infor from opcode_decrypt)
        o_MemWrite      : out std_logic;
        o_MemRead       : out std_logic;
        o_MemToReg      : out std_logic;
        o_signExtend    : out std_logic;    --Select if sign extend
		    o_jump          : out std_logic;    --Select if jump
		    o_jal           : out std_logic;
		    o_beq           : out std_logic;
        o_bne           : out std_logic;
        o_upper         : out std_logic );
end opcode_decrypt;

architecture dataflow of opcode_decrypt is

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
            o_MemRead <= '0';
            o_MemToReg <= '0';

            o_funct <= '1'; --function code will decide o_ALUCtrl (in the instruction_decoder)
            o_jump <= '0';
            o_beq <= '0';
            o_bne <= '0';
            o_signExtend <= '0';
            o_upper <= '0';

        when "001000" =>
        --addi,
            o_regDst <= '0';  --writeAddr[20-16] (same as readAddr2)
            o_regWrite <= '1';
            o_ALUOp <= "00";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

            o_funct <= '0'; --opcode code will decide o_ALUCtrl (in the instruction_decoder)
            o_ALUCtrl <= "000"; --it will add
            o_jump <= '0';
            o_beq <= '0';
            o_bne <= '0';
						o_signExtend <= '1';
            o_upper <= '0';

        when "001001" =>
        --addiu
            o_regDst <= '0';
            o_regWrite <= '1';
            o_ALUOp <= "00";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

            o_funct <= '0'; --opcode code will decide o_ALUCtrl (in the instruction_decoder)
            o_ALUCtrl <= "000"; --it will add
            o_jump <= '0';
            o_beq <= '0';
            o_bne <= '0';
						o_signExtend <= '0';
            o_upper <= '0';

        when "001100" =>
        --andi
            o_regDst <= '0';
            o_regWrite <= '1';
            o_ALUOp <= "00";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

            o_funct <= '0'; --opcode code will decide o_ALUCtrl (in the instruction_decoder)
            o_ALUCtrl <= "001"; --it will and
            o_jump <= '0';
            o_beq <= '0';
            o_bne <= '0';
					  o_signExtend <= '0';
            o_upper <= '0';

        when "001111" =>
        --lui
            o_regDst <= '0';
            o_regWrite <= '1';
            o_ALUOp <= "10";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';
            o_upper <= '1';

            o_funct <= '0';   --opcode code will decide o_ALUCtrl (in the instruction_decoder)
            o_ALUCtrl <= "000";
            o_jump <= '0';
            o_beq <= '0';
            o_bne <= '0';
					  o_signExtend <= '0';

        when "100011" =>
        --lw
            o_regDst <= '0';
            o_regWrite <= '1';
            o_ALUOp <= "11";
            o_ALUSrc <= '1';
            o_ALUCtrl <= "000";
            o_MemWrite <= '0';
            o_jump <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '1';
            o_beq <= '0';
            o_bne <= '0';
            o_upper <= '0';

        when "001110" =>
        --xori
            o_regDst <= '0';
            o_regWrite <= '1';
            o_ALUOp <= "01";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

            o_funct <= '0'; --opcode code will decide o_ALUCtrl (in the instruction_decoder)
            o_ALUCtrl <= "011"; --it will xor
            o_jump <= '0';
            o_beq <= '0';
            o_bne <= '0';
					  o_signExtend <= '0';
            o_upper <= '0';

        when "001101" =>
        --ori
            o_regDst <= '0';
            o_regWrite <= '1';
            o_ALUOp <= "01";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

            o_funct <= '0'; --opcode code will decide o_ALUCtrl (in the instruction_decoder)
            o_ALUCtrl <= "110"; --it will or
            o_jump <= '0';
            o_beq <= '0';
            o_bne <= '0';
					  o_signExtend <= '0';
            o_upper <= '0';

        when "001010" =>
        --slti
            o_regDst <= '0';
            o_regWrite <= '1';
            o_ALUOp <= "10";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

            o_funct <= '0'; --opcode code will decide o_ALUCtrl (in the instruction_decoder)
            o_ALUCtrl <= "100"; --it will slt
            o_jump <= '0';
            o_beq <= '0';
            o_bne <= '0';
					  o_signExtend <= '1';
            o_upper <= '0';

        when "001011" =>
        --sltiu
            o_regDst <= '0';
            o_regWrite <= '1';
            o_ALUOp <= "10";
            o_ALUSrc <= '1';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

            o_funct <= '0'; --opcode code will decide o_ALUCtrl (in the instruction_decoder)
            o_ALUCtrl <= "100"; --it will slt
            o_jump <= '0';
            o_beq <= '0';
            o_bne <= '0';
					  o_signExtend <= '0';
            o_upper <= '0';

        when "101011" =>
        --sw

            o_regDst <= '0';
            o_regWrite <= '0';
            o_ALUOp <= "11";
            o_ALUSrc <= '1';

            o_MemWrite <= '1';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

            o_funct <= '0'; --opcode code will decide o_ALUCtrl (in the instruction_decoder)
            o_ALUCtrl <= "000"; --it will add
            o_jump <= '0';
					  o_signExtend <= '1';
            o_beq <= '0';
            o_bne <= '0';
            o_upper <= '0';

        when "000100" =>
        --beq
            o_regDst <= 'X';
            o_regWrite <= '0';
            o_ALUOp <= "XX";
            o_ALUSrc <= '0';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

            o_funct <= '0';
            o_ALUCtrl <= "111";
            o_jump <= '0';
						o_beq <= '1';
            o_bne <= '0';
            o_upper <= '0';

        when "000101" =>
        --bne
            o_regDst <= 'X';
            o_regWrite <= '0';
            o_ALUOp <= "XX";
            o_ALUSrc <= '0';
            o_MemWrite <= '0';
            o_MemRead <= 'X';
            o_MemToReg <= '0';

            o_funct <= '0';
            o_ALUCtrl <= "111";
            o_jump <= '0';
            o_beq <= '0';
            o_bne <= '1';
            o_upper <= '0';

        when "000010" =>
        --j
            o_regDst <= 'X';
            o_regWrite <= 'X';
            o_ALUOp <= "XX";
            o_ALUSrc <= 'X';
            o_MemWrite <= 'X';
            o_MemRead <= 'X';
            o_MemToReg <= 'X';

            o_jump <= '1';
            o_jal <= '0';
            o_beq <= '0';
            o_bne <= '0';
            o_upper <= '0';

        when "000011" =>
        --jal
            o_regDst <= 'X';
            o_regWrite <= 'X';
            o_ALUOp <= "XX";
            o_ALUSrc <= 'X';
            o_MemWrite <= 'X';
            o_MemRead <= 'X';
            o_MemToReg <= 'X';


            o_jump <= '0';
            o_jal <= '1';
            o_beq <= '0';
            o_bne <= '0';
            o_upper <= '0';

        when others =>
            o_regDst <= 'X';
            o_regWrite <= 'X';
            o_ALUOp <= "XX";
            o_ALUSrc <= 'X';
            o_MemWrite <= 'X';
            o_MemRead <= 'X';
            o_MemToReg <= 'X';
            o_jump <= 'X';
            o_upper <= 'X';

        end case;

      end process;

end architecture;
