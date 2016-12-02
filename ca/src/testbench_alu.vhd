library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity testbench_alu is
end entity;


architecture beh of testbench_alu is
	constant CLK_PERIOD: time := 20ns;

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
	end process;

end beh;