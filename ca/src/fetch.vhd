library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;

entity fetch is
	
	port (
		clk, reset : in	 std_logic;
		stall      : in  std_logic;
		pcsrc	   : in	 std_logic;
		pc_in	   : in	 std_logic_vector(PC_WIDTH-1 downto 0);
		pc_out	   : out std_logic_vector(PC_WIDTH-1 downto 0);
		instr	   : out std_logic_vector(INSTR_WIDTH-1 downto 0));

end fetch;

architecture rtl of fetch is
	constant testbench_fetch_stall : integer := 0;
	signal imem_addr: std_logic_vector(11 downto 0);
	signal pc_int: std_logic_vector(PC_WIDTH-1 downto 0);
	signal clk_cnt, clk_cnt_next : integer;
begin  -- rtl

	isnt_mem: entity work.imem_altera
	port map
	(
		clock => clk,
		address => imem_addr,
		q => instr
	);

	imem_addr <= pc_int(PC_WIDTH-1 downto 2);
	pc_out <= pc_int;

	cl_count : process(clk_cnt) is
	begin
		clk_cnt_next <= clk_cnt +1;
	end process;


	compute_addr: process(clk, reset, pcsrc, pc_in, clk_cnt_next) is
	begin
		if reset = '0' then
			pc_int <= (others => '0');
			clk_cnt <= 0;
		elsif rising_edge(clk) and (not(stall = '1')) then
			if clk_cnt <  testbench_fetch_stall then
				clk_cnt <= clk_cnt_next;
			else
				clk_cnt <= 0;
				if pcsrc = '1' then
					pc_int <= pc_in;
				else
					pc_int <= std_logic_vector(unsigned(pc_int) + to_unsigned(4, pc_int'length));
				end if;
			end if;
		end if; 
	end process;

end rtl;
