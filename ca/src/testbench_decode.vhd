library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity testbench_decode is
end entity;


architecture beh of testbench_decode is
  
	signal sysclk, reset, stall, flush, regwrite, exc : std_logic;

	signal pc_in, pc_out : std_logic_vector(PC_WIDTH-1 downto 0);
	signal instr : std_logic_vector(INSTR_WIDTH-1 downto 0);
	signal wraddr : std_logic_vector(REG_BITS-1 downto 0);
	signal wrdata : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal exec_op : exec_op_type;
	signal cop0_op : cop0_op_type;
	signal jmp_op : jmp_op_type;
	signal mem_op : mem_op_type;
	signal wb_op : wb_op_type;

begin

	dec:entity work.decode
	port map(
		sysclk, reset,
		stall,
		flush,
		pc_in,
		instr,
		wraddr,
		wrdata,
		regwrite,
		pc_out,
		exec_op,
		cop0_op,
		jmp_op,
		mem_op,
		wb_op,
		exc
	);

	clockgen:process
	begin
		sysclk <= '0';
		wait for 10 ns;
		sysclk <= '1';
		wait for 10 ns;
	end process;

	resetgen:process
	begin
		reset <= '0';
		flush <= '1';
		wait for 100 ns;
		wait until rising_edge(sysclk);
		reset <= '1';
		flush <= '0';
		wait;
	end process;

	alu_test: process
	variable pc : std_logic_vector(PC_WIDTH-1 downto 0) := (3 => '1', others => '0');
	begin
		stall <= '0';
		regwrite <= '0';

		wait until reset = '1' and rising_edge(sysclk);

		-- write "10011011010010110100110011000000" to r1
		regwrite <= '1';
		wraddr <= "00001";
		wrdata <= "10011011010010110100110011000000";

		wait until rising_edge(sysclk);

		-- write "00000000111111110000111111111111" to r2
		regwrite <= '1';
		wraddr <= "00010";
		wrdata <= "00000000111111110000111111111111";

		-- XOR r3, r2, r1
		instr <= "00000000010000010001100000100110";
		pc_in <= pc;

		wait until rising_edge(sysclk);
		regwrite <= '0';

		-- JALR r17, r1
		instr <= "00000000001000001000100000001001";
		pc_in <= pc;

		wait until rising_edge(sysclk);
		regwrite <= '0';

		-- LW r17, 4(r0)
		instr <= "10001100000000010000000000000010";
		pc_in <= pc;
		
		wait until rising_edge(sysclk);
		pc := pc_out;
		pc_in <= pc;

		wait for 100 ns;
		stall <= '1';
		wait;
	end process;

end beh;
