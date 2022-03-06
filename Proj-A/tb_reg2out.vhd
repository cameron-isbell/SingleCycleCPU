library IEEE;
use IEEE.std_logic_1164.all;

entity tb_reg2out is
generic(gCLK_HPER   : time := 50 ns);

end tb_reg2out;

architecture testbench of tb_reg2out is

component reg_file_2out
generic (numBits : integer := 32;
	 numItems : integer := 32);

port (
		s_in0	: in std_logic_vector (4 downto 0); 		--select the register to write to
		s_in1	: in std_logic_vector (4 downto 0); 		--select the register perform some action
		s_in2	: in std_logic_vector (4 downto 0);
		r_in    : in std_logic;
		in_data : in std_logic_vector(numBits-1 downto 0);      --data to write, if any
		w_in 	: in std_logic; 				 --choose to write to a specific register
		i_CLK   : in std_logic;   				--data to output

		val_out1: out std_logic_vector(numBits-1 downto 0 );
		val_out2: out std_logic_vector(numBits-1 downto 0 ) );

end component;

constant cCLK_PER : time := gCLK_HPER * 2;

signal tb_in0, tb_in1, tb_in2 : std_logic_vector(4 downto 0);
signal tb_r, tb_w, tb_CLK : std_logic;
signal tb_indata, tb_val_out1, tb_val_out2 : std_logic_vector(31 downto 0);

begin

rFile : reg_file_2out

port map (
		s_in0 => tb_in0,
		s_in1	=> tb_in1,
		s_in2	=> tb_in2,
		r_in  => tb_r,
		in_data  => tb_indata,
		w_in 	 => tb_w,
		i_CLK  => tb_CLK,

		val_out1 => tb_val_out1,
		val_out2 => tb_val_out2 );

    P_CLK: process
    begin
    	tb_CLK <= '0';
    	wait for gCLK_HPER;
        tb_CLK <= '1';
        wait for gCLK_HPER;

    end process;

    P_TB : process

    begin
      tb_indata <= X"FFFF0000";
      tb_in0 <= "00010";
      tb_in1 <= "00000";
      tb_in2 <= "00000";

      tb_r <= '0';
      tb_w <= '1';

      wait for cCLK_PER;

      tb_indata <= X"000FFF00";
      tb_in0 <= "00011";
      tb_in1 <= "00010";
      tb_in2 <= "00011";

      tb_r <= '0';
      tb_w <= '1';

      wait for cCLK_PER;

      tb_indata <= X"000FFF00";
      tb_in0 <= "00011";
      tb_in1 <= "00000";
      tb_in2 <= "00000";

      tb_r <= '0';
      tb_w <= '0';

      wait for cCLK_PER;




    end process;

end testbench;
