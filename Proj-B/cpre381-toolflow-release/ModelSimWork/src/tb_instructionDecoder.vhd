library IEEE;
use IEEE.std_logic_1164.all;

entity tb_instructionDecoder is
  generic (gCLK_HPER	: time := 50 ns);
end entity;

architecture behavior of tb_instructionDecoder is

  -- Calculate the clock period as twice the half-period
	constant cCLK_PER  : time := gCLK_HPER * 2;

  component instruction_decoder
    port (in_Instruction  : in std_logic_vector(31 downto 0);
          --Extender Input
          o_signExtend    : out std_logic_vector(15 downto 0);  --instruction [15-0]
          --Register stuff below
          o_writeAddr     : out std_logic_vector(4 downto 0); --instruction[15-11] (regDst = 1) / instruction[20-16] (regDst = 0)
          o_readAddr1     : out std_logic_vector(4 downto 0); --instruction [25-21]
          o_readAddr2     : out std_logic_vector(4 downto 0); --instruction [20-16]
          --Control stuff below
          o_regDst        : out std_logic;
          o_regWrite      : out std_logic;
          o_Branch        : out std_logic;
          o_ALUSrc        : out std_logic;
          o_ALUCtrl       : out std_logic_vector (2 downto 0);
          o_toShift       : out std_logic_vector (25 downto 0);
          o_MemWrite      : out std_logic;
          --o_MemRead       : out std_logic;
          o_MemToReg      : out std_logic);
  end component;

  signal s_regDst, s_regWrite, s_ALUSrc, s_MemWrite, s_MemToReg, s_Branch : std_logic;
  signal s_writeAddr, s_readAddr1, s_readAddr2 : std_logic_vector(4 downto 0);
  signal s_ALUCtrl : std_logic_vector (2 downto 0);
  signal s_toShift : std_logic_vector (25 downto 0);
  signal s_signExtend : std_logic_vector(15 downto 0);
  signal s_Instruction : std_logic_vector(31 downto 0);
  signal s_CLK : std_logic;

  begin
    tb_Instruction : instruction_decoder
      port map (
        in_Instruction => s_Instruction,
        o_signExtend => s_signExtend,
        o_writeAddr => s_writeAddr,
        o_readAddr1 => s_readAddr1,
        o_readAddr2 => s_readAddr2,
        o_regDst => s_regDst,
        o_regWrite => s_regWrite,
        o_Branch   => s_Branch,
        o_ALUSrc => s_ALUSrc,
        o_ALUCtrl => s_ALUCtrl,
        o_toShift => s_toShift,
        o_MemWrite => s_MemWrite,
        o_MemToReg => s_MemToReg
      );

    -- This process sets the clock value (low for gCLK_HPER, then high
		-- for gCLK_HPER). Absent a "wait" command, processes restart
		-- at the beginning once they have reached the final statement.
		P_CLK: process
			begin
				s_CLK <= '0';
				wait for gCLK_HPER;
				s_CLK <= '1';
				wait for gCLK_HPER;
			end process;

		-- Testbench Process
		P_TB: process
			begin

        -- R Format
        -- "six op, five rs, five rt, five rd, 5 shamt, 6 funct"
        -- rs = readAddr1
        -- rt = readAddr2
        -- rd = writeAddr
				-----------------------------------------------------
        -- Instruction ADD to regs of 1 all around
        s_Instruction <= "00000000001000010000100000100000";
        -- Expected:
        -- writeAddr = 00001
        -- readAddr1 = 00001
        -- readAddr2 = 00001
        -- regDst = 1
        -- regWrite = 1
        -- ALUSrc = 0
        -- MemWrite = 0
        -- MemToReg = 0
        -- [MemRead = X, ALUOp = 00]
        -- ALUCtrl = 000
				wait for cCLK_PER;

        -- Instruction AND to regs of 3 all around
        s_Instruction <= "00000000011000110001100000100100";
        -- Expected:
        -- writeAddr = 00011
        -- readAddr1 = 00011
        -- readAddr2 = 00011
        -- regDst = 1
        -- regWrite = 1
        -- ALUSrc = 0
        -- MemWrite = 0
        -- MemToReg = 0
        -- [MemRead = X, ALUOp = 00]
        -- ALUCtrl = 001
				wait for cCLK_PER;

        -- Instruction NOR to regs of 1,2,3
        s_Instruction <= "00000000001000100001100000100111";
        -- Expected:
        -- writeAddr = 00001
        -- readAddr1 = 00010
        -- readAddr2 = 00011
        -- regDst = 1
        -- regWrite = 1
        -- ALUSrc = 0
        -- MemWrite = 0
        -- MemToReg = 0
        -- [MemRead = X, ALUOp = 00]
        -- ALUCtrl = 010
        wait for cCLK_PER;

        -- Instruction XOR to regs of 1,4,4
        s_Instruction <= "00000000001001000010000000100110";
        -- Expected:
        -- writeAddr = 00001
        -- readAddr1 = 00010
        -- readAddr2 = 00011
        -- regDst = 1
        -- regWrite = 1
        -- ALUSrc = 0
        -- MemWrite = 0
        -- MemToReg = 0
        -- [MemRead = X, ALUOp = 00]
        -- ALUCtrl = 011
        wait for cCLK_PER;

        -- Instruction OR to regs of 1,1,1
        s_Instruction <= "00000000001000010000100000100101";
        -- Expected:
        -- writeAddr = 00001
        -- readAddr1 = 00001
        -- readAddr2 = 00001
        -- regDst = 1
        -- regWrite = 1
        -- ALUSrc = 0
        -- MemWrite = 0
        -- MemToReg = 0
        -- [MemRead = X, ALUOp = 00]
        -- ALUCtrl = 110
        wait for cCLK_PER;

        -- Instruction SLT to regs of 1,1,1
        s_Instruction <= "00000000001000010000100000101010";
        -- Expected:
        -- writeAddr = 00001
        -- readAddr1 = 00001
        -- readAddr2 = 00001
        -- regDst = 1
        -- regWrite = 1
        -- ALUSrc = 0
        -- MemWrite = 0
        -- MemToReg = 0
        -- [MemRead = X, ALUOp = 00]
        -- ALUCtrl = 100
        wait for cCLK_PER;

        -- I format
        -- "six op, five rs, five rt, 16 immediate"

        -- Instruction addi to regs 1,2 (immediate = 1)
        s_Instruction <= "00100000001000100000000000000001";
        -- Expected:
        -- writeAddr = 00001
        -- readAddr1 = 00002
        -- regDst = 0
        -- regWrite = 1
        -- ALUSrc = 1
        -- MemWrite = 0
        -- MemToReg = 0
        -- [MemRead = X, ALUOp = 00]
        -- ALUCtrl = 000
        wait for cCLK_PER;

          wait for cCLK_PER;
        -- Instruction andi to regs 1,2 (immediate = 0)
        s_Instruction <= "00110000001000100000000000000000";
        -- Expected:
        -- writeAddr = 00001
        -- readAddr1 = 00002
        -- regDst = 0
        -- regWrite = 1
        -- ALUSrc = 1
        -- MemWrite = 0
        -- MemToReg = 0
        -- [MemRead = X, ALUOp = 00]
        -- ALUCtrl = 000
        wait for cCLK_PER;

        -- Instruction lw to regs 3,4,5 (immediate = 1)
        s_Instruction <= "10001100011001000010100000000001";
        -- Expected:
        -- readAddr1 = 00011
        -- readAddr2 = 00100
        -- regDst = 1
        -- regWrite = 1
        -- ALUSrc = X
        -- MemWrite = 1
        -- MemToReg = 1
        -- [MemRead = X, ALUOp = 11]
        -- ALUCtrl = 111
        wait for cCLK_PER;

        -- Instruction xori to regs 1,1 (immediate = 0)
        s_Instruction <= "00111000001000010000000000000000";
        -- Expected:
        -- readAddr1 = 00011
        -- readAddr2 = 00100
        -- regDst = 1
        -- regWrite = 1
        -- ALUSrc = 1
        -- MemWrite = 0
        -- MemToReg = 0
        -- [MemRead = X, ALUOp = 01]
        -- ALUCtrl = 011
        wait for cCLK_PER;

        -- Instruction check if invalid opcode
        s_Instruction <= "11111100001000010001000000000000";
        -- Expected:
        -- writeAddr = 00001
        -- readAddr1 = 00001
        -- regDst = X
        -- regWrite = X
        -- ALUSrc = X
        -- MemWrite = X
        -- MemToReg = X
        -- [MemRead = X, ALUOp = XX]
        -- ALUCtrl = 111
        wait for cCLK_PER;

    end process;

end architecture;
