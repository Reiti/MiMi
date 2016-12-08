library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity testbench_wb is
end entity;


architecture beh of testbench_wb is
	constant CLK_PERIOD: time := 20 ns;
	signal clk, reset, stall, flush, regwrite: std_logic;
	signal 	op: wb_op_type;
	signal rd_in, rd_out: std_logic_vector(REG_BITS-1 downto 0);
	signal aluresult, memresult, result: std_logic_vector(DATA_WIDTH-1 downto 0);
begin


  clk_gen: process is
  begin
    clk <= '1';
    wait for CLK_PERIOD/2;
    clk <= '0';
    wait for CLK_PERIOD/2;
  end process;

  rs_gen: process is
  begin
    reset <= '0';
    wait for 2*CLK_PERIOD;
    reset <= '1';
    wait;
  end process;

  wb_test: entity work.wb
  port map
  (
	clk => clk,
	reset => reset,
	stall => stall,
	flush => flush,
	regwrite => regwrite,
	op => op,
	rd_in => rd_in,
	rd_out => rd_out,
	aluresult => aluresult,
	memresult => memresult,
	result => result
  );

  test_wb: process is
  begin
	wait until rising_edge(reset);
	--test writeback from memory
	op <= ('1', '1');
	rd_in <= "11111";
	aluresult <= x"00001111";
	memresult <= x"11110000";
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	--test writeback from alu
	op <= ('0', '1');
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	--test stall
	stall <= '1';
	rd_in <= "00000";
	op <= ('0', '0');
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	--test flush
	stall <= '0';
	flush <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
  end process;

end beh;