
library ieee;
use ieee.std_logic_1164.all;

entity serial_port is
	generic(
		CLK_FREQ : integer;
		BAUD_RATE : integer;
		SYNC_STAGES : integer := 2;
		TX_FIFO_DEPTH : integer := 10;
		RX_FIFO_DEPTH : integer := 10
	);
	port(
		clk : in std_logic;
		res_n : in std_logic;
		rx : in std_logic;
		tx_data : in std_logic_vector(7 downto 0);
		tx_wr : in std_logic;
		rx_rd : in std_logic;

		rx_data : out std_logic_vector(7 downto 0);
		rx_data_empty : out std_logic;
		rx_data_full : out std_logic;
		tx : out std_logic;
		tx_free : out std_logic
	);
end entity serial_port;

architecture struct of serial_port is
constant CLK_DIV : integer := CLK_FREQ/BAUD_RATE;
signal serial_rx : std_logic;
signal transmit_data : std_logic_vector(7 downto 0);
signal transmit_empty, transmit_full, rd1 : std_logic;
signal receive_data : std_logic_vector(7 downto 0);
signal receive_data_new : std_logic;
begin
	sync:entity work.sync
	generic map(SYNC_STAGES, '1')
	port map(clk, res_n, rx, serial_rx);
	
	fifo_left:entity work.fifo_1c1r1w
	generic map(TX_FIFO_DEPTH, 8)
	port map(clk, res_n, transmit_data, rd1, tx_data, tx_wr, transmit_empty, transmit_full);

	serial_port_receiver_fsm:entity work.serial_port_receiver
	generic map(CLK_DIV)
	port map(clk, res_n, serial_rx, receive_data, receive_data_new);
	
	serial_port_transmitter_fsm:entity work.serial_port_transmitter
	generic map(CLK_DIV)
	port map(clk, res_n, transmit_data, transmit_empty, rd1, tx);

	fifo_right:entity work.fifo_1c1r1w
	generic map(RX_FIFO_DEPTH, 8)
	port map(clk, res_n, rx_data, rx_rd, receive_data, receive_data_new, rx_data_empty, rx_data_full);


	tx_free <= "not"(transmit_full);
end architecture;
