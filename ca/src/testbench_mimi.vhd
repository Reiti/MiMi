library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity testbench_mimi is
end entity;


architecture beh of testbench_mimi is
 	constant CLK_PERIOD: time := 1 sec / 75000000;
	constant CLK_FREQ : integer := 1 sec / CLK_PERIOD;
	constant BAUD_RATE : integer := 115200;
	signal clk : std_logic;
	signal reset : std_logic;
	signal stx, srx : std_logic;
	signal intr : std_logic_vector(INTR_COUNT-1 downto 0);
	signal d : std_logic_vector(7 downto 0);
	signal dn : std_logic;
begin	
	
	intr <= (others => '0');

	mimi_inst: entity work.mimi
	port map(
		clk_pin => clk,
		reset_pin => reset,
		tx => stx,
		rx => srx,
		intr_pin => intr);
	
	recv: entity work.serial_port_receiver
	generic map ( CLK_DIVISOR => CLK_FREQ/BAUD_RATE)
	port map(clk => clk, res_n => reset, rx => stx, data => d, data_new => dn);

	clock:process is
	begin
		clk <= '0';
		wait for CLK_PERIOD/2;
		clk <= '1';
		wait for CLK_PERIOD/2;
	end process;

	run:process is
	begin
		reset <= '0';
		wait for 1 us;
		reset <= '1';
		wait;
	end process;


end architecture;
