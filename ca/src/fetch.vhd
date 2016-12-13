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
	signal pc_int, pc_next: std_logic_vector(PC_WIDTH-1 downto 0);
	signal instr_next, instr_next_next : std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');
begin  -- rtl

	isnt_mem: entity work.imem_altera
	port map
	(
		clock => clk,
		address => imem_addr,
		q => instr_next
	);

	imem_addr <= pc_int(PC_WIDTH-1 downto 2);

	i : process(instr_next, stall, pc_int, pc_next, instr_next_next) is
	begin
		instr <= instr_next;
		pc_out <= std_logic_vector(unsigned(pc_next));
		if stall = '0' then 
			instr <= instr_next_next;	
			pc_out <= pc_int;
		end if;
	end process;


  	compute_addr: process(clk, reset, pcsrc, pc_in, pc_int, instr_next) is
	variable x : std_logic_vector(PC_WIDTH-1 downto 0);
	begin
		if reset = '0' then
			pc_int <= (others => '0');
		elsif rising_edge(clk) and not stall = '1' then
			if pcsrc = '1' then
				pc_int <= pc_in;
				--imem_addr <= pc_in(PC_WIDTH-1 downto 2);
			else
				pc_int <= std_logic_vector(unsigned(pc_int) + to_unsigned(4, pc_int'length));
				 --x := (std_logic_vector(unsigned(pc_int) + to_unsigned(4, pc_int'length)));
				--imem_addr <=x(PC_WIDTH-1 downto 2);
			end if;
			pc_next <= pc_int;
			instr_next_next <= instr_next; 
		end if;
		
	end process;

end rtl;
