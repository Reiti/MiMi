library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity testbench_alu is
end entity;


architecture beh of testbench_alu is
	constant CLK_PERIOD: time := 20 ns;

	signal clk: std_logic;
	signal rst: std_logic;

	signal A, B, R: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal Z, V: std_logic;
	signal op: alu_op_type;

begin
	
	alu_inst: entity work.alu
		port map
		(
			op => op,
			A => A,
			B => B,
			R => R,
			Z => Z,
			V => V
		);
	
	test: process
	begin
		--Standard functionality tests
		op <= ALU_NOP;
		A <= std_logic_vector(to_unsigned(5, DATA_WIDTH));
		B <= (others => '0');
		wait for 1 ns;
		op <= ALU_LUI;
		A <= (others => '0');
		B <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_SLT;
		A <= std_logic_vector(to_signed(-4, DATA_WIDTH));
		B <= std_logic_vector(to_signed(3, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_SLTU;
		A <= std_logic_vector(to_signed(-4, DATA_WIDTH));
		B <= std_logic_vector(to_unsigned(3, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_SLL;
		A <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
		B <= std_logic_vector(to_signed(-4, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_SRL;
		A <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
		B <= std_logic_vector(to_signed(-4, DATA_WIDTH));
	        wait for 1 ns;	
		op <= ALU_SRA;
		A <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
		B <= std_logic_vector(to_signed(-4, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_ADD;
		A <= std_logic_vector(to_signed(10, DATA_WIDTH));
		B <= std_logic_vector(to_signed(15, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_SUB;
		A <= std_logic_vector(to_signed(20, DATA_WIDTH));
		B <= std_logic_vector(to_signed(10, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_AND;
		A <= std_logic_vector(to_unsigned(12, DATA_WIDTH));
		B <= std_logic_vector(to_unsigned(3, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_OR;
		A <= std_logic_vector(to_unsigned(12, DATA_WIDTH));
		B <= std_logic_vector(to_unsigned(3, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_XOR;
		A <= std_logic_vector(to_unsigned(12, DATA_WIDTH));
		B <= std_logic_vector(to_unsigned(3, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_NOR;
		A <= std_logic_vector(to_unsigned(12, DATA_WIDTH));
		B <= std_logic_vector(to_unsigned(3, DATA_WIDTH));
		wait for 1 ns;
		--overflow tests
		op <= ALU_ADD;
		A <= (DATA_WIDTH-1 => '0', others => '1');
		B <= std_logic_vector(to_signed(10, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_ADD;
		A <= (DATA_WIDTH-1 => '1', others => '0');
		B <= std_logic_vector(to_signed(-10, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_SUB;
		A <= (DATA_WIDTH-1 => '0', others => '1');
		B <= std_logic_vector(to_signed(-10, DATA_WIDTH));
		wait for 1 ns;
		op <= ALU_SUB;
		A <= (DATA_WIDTH-1 => '1', others => '0');
		B <= std_logic_vector(to_signed(10, DATA_WIDTH));
		wait for 1 ns;
		--zero test
		op <= ALU_SUB;
		A <= std_logic_vector(to_signed(10, DATA_WIDTH));
		B <= std_logic_vector(to_signed(10, DATA_WIDTH));
		wait for 1 ns;
	end process;

end beh;
