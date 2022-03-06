-- ALU1bit.vhd
-- Matthew G. Hoskins

library IEEE;
use IEEE.std_logic_1164.all;

entity ALU1bit is
	port (	in_A0, in_A1, in_carry, in_less	: in std_logic;
			in_Select			: in std_logic_vector(2 downto 0);
			o_out, o_cOut	: out std_logic);
end ALU1bit;

architecture structural of ALU1bit is

	component mux2_struct
		port (
			a_in 	: in std_logic;
			b_in 	: in std_logic;
			s_in 	: in std_logic;

			o_F		: out std_logic );
	end component;

	component add_sub_1bit
		port (
			a_in : in std_logic;
			b_in : in std_logic;
			c_in : in std_logic;
			sub_in	 : in std_logic;

			result : out std_logic;
			c_out  : out std_logic );
	end component;

	component andg2
		port(i_A     : in std_logic;
		i_B          : in std_logic;
		o_F          : out std_logic);
	end component;

	component norg2
		port(i_A : in std_logic;
		 i_B : in std_logic;
		 o_F : out std_logic);
	end component;

	component xorg2
		 port(i_A          : in std_logic;
		   i_B          : in std_logic;
		   o_F          : out std_logic);
	end component;

	component set_less_than
		port (i_a : in std_logic;
			i_b : in std_logic;
			i_less : in std_logic;
			c_in : std_logic;
			o_F : out std_logic;
			c_out : out std_logic );
	end component;

	component nandg2
		port(i_A : in std_logic;
			 i_B : in std_logic;
			 o_F : out std_logic);
	end component;

	component org2
		port(i_A    : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
	end component;

	component mux8to1
		generic(N : integer := 1);	--change to 1 bit 8to1 mux
		port(in_select : in std_logic_vector(2 downto 0);
			 in_data0, in_data1, in_data2, in_data3, in_data4, in_data5, in_data6, in_data7 : in std_logic_vector((N - 1) downto 0);
			 o_Data : out std_logic_vector((N - 1) downto 0));
	end component;

	signal s_carries : std_logic_vector(1 downto 0);
	signal s_addSum, s_and, s_nor, s_xor, s_slt, s_nand, s_or, s_subCOutMux , s_cMux1, s_subCarryOut, s_sub : std_logic;

	begin
		addR : add_sub_1bit	--select 000
			port map(
					a_in => in_A0,
					b_in => in_A1,
					c_in => in_carry,
					sub_in => '0',
					result => s_addSum,
					c_out => s_carries(0) );

		andR : andg2	--select 001
			port map(i_A => in_A0,
					i_B => in_A1,
					o_F => s_and );

		norR : norg2	--select 010
			port map(i_A => in_A0,
					i_B => in_A1,
					o_F => s_nor );

		xorR : xorg2	--select 011
			port map(i_A => in_A0,
					i_B => in_A1,
					o_F => s_xor );

		sltR : set_less_than --select 100
			port map(i_a => in_A0,
					i_b => in_A1,
					i_less => in_less,
					c_in => in_carry,
					o_F => s_slt,
					c_out => s_carries(1) );

		nandR : nandg2		--select 101
			port map(i_A => in_A0,
					i_B => in_A1,
					o_F => s_nand );

		orR : org2			--select 110
			port map(i_A => in_A0,
					i_B => in_A1,
					o_F => s_or );

		subR : add_sub_1bit	--select 111
		port map(
			  a_in => in_A0,
				b_in => in_A1,
				c_in => in_carry,
				sub_in	 => '1',
				result => s_sub,
				c_out => s_subCarryOut );

		muxR : mux8to1
			port map(in_select => in_Select,
					in_data0(0) => s_addSum,
					in_data1(0) => s_and,
					in_data2(0) => s_nor,
					in_data3(0) => s_xor,
					in_data4(0) => in_less,
					in_data5(0) => s_nand,
					in_data6(0) => s_or,
					in_data7(0) => s_sub,
					o_Data(0) => o_out );

		--select one of the 2 carry outs depending on the intended operation
		--select adder carryout if !s(2), slt if s(2)
		muxCOut : mux2_struct
			port map (a_in => s_carries(0),
					  b_in => s_carries(1),
					  s_in => in_Select(2),
					  o_F  => s_cMux1);

		--sub out at 111, carry out to
 		s_subCOutMux <= in_select(0) and in_select(1) and in_select(2);

		muxCout2 : mux2_struct
			port map (
				a_in => s_cMux1,
				b_in => s_subCarryOut,
				s_in => s_subCOutMux,

				o_F => o_cOut );

end structural;
