library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity testbench_fetch is
end entity;


architecture beh of testbench_fetch is
	constant CLK_PERIOD: time := 20 ns;
	signal clk, reset, stall, pcsrc: std_logic;
	signal pc_in, pc_out: std_logic_vector(PC_WIDTH-1 downto 0);
	signal instr: std_logic_vector(INSTR_WIDTH-1 downto 0);
begin

 f: entity work.fetch
 port map
 (
	clk => clk,
	reset => reset,
	stall => stall,
	pcsrc => pcsrc,
	pc_in => pc_in,
	pc_out => pc_out,
	instr => instr
 );
	
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

  test_fetch: process is
  begin
	wait until rising_edge(reset);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	stall <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	pcsrc <= '1';
	pc_in <= "00000000000010";
	stall <= '0';
	wait until rising_edge(clk);
  end process;
end beh;