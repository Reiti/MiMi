library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity testbench_pipe is
end entity;


architecture beh of testbench_pipe is
 	constant CLK_PERIOD: time := 20 ns; 
	signal clk, reset : std_logic;
	signal mem_in : MEM_IN_TYPE;
	signal mem_out : MEM_OUT_TYPE;
	signal intr : std_logic_vector(INTR_COUNT -1 downto 0);	

begin	
	pipe_inst: entity work.pipeline
		port map
		(
			clk => clk,
			reset => reset,
			mem_in => mem_in,
			mem_out => mem_out,
			intr => intr	
		);

	mem_vllt: entity work.ocram_altera-- wos was i :D
		port map(
			address =>mem_out.address(11 downto 2),
			byteena =>mem_out.byteena,
			clock => clk,
			data => mem_out.wrdata,
			wren =>mem_out.wr,
			q => mem_in.rddata
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


	pipe_test: process(mem_out)
	begin
	  mem_in.busy <= mem_out.rd;
	end process;
end beh;
