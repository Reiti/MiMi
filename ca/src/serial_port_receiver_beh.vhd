
----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------------------
--                               ARCHITECTURE                                   --
----------------------------------------------------------------------------------

architecture beh of serial_port_receiver is
	type RECEIVER_STATE_TYPE is (
		RECEIVER_STATE_IDLE,
		RECEIVER_STATE_WAIT_START_BIT,
		RECEIVER_STATE_GOTO_MIDDLE_OF_START_BIT,
		RECEIVER_STATE_MIDDLE_OF_START_BIT,
		RECEIVER_STATE_WAIT_DATA_BIT,
		RECEIVER_STATE_MIDDLE_OF_DATA_BIT,
		RECEIVER_STATE_WAIT_STOP_BIT,
		RECEIVER_STATE_MIDDLE_OF_STOP_BIT
		);

	signal receiver_state, receiver_state_next : RECEIVER_STATE_TYPE;
	signal bit_cnt, bit_cnt_next : integer range 0 to 8;
	signal clk_cnt, clk_cnt_next : integer range 0 to CLK_DIVISOR - 1;
	signal data_int, data_int_next : std_logic_vector(7 downto 0);
	signal data_next,data_next_next : std_logic_vector(7 downto 0);
	signal data_new_next : std_logic;
begin

	--------------------------------------------------------------------
	--                    PROCESS : NEXT_STATE                        --
	--------------------------------------------------------------------

	receiver_next_state : process(receiver_state, clk_cnt, bit_cnt, rx)
	begin
		receiver_state_next <= receiver_state;
		
		case receiver_state is
		when RECEIVER_STATE_IDLE =>
			if rx = '1' then
				receiver_state_next <= RECEIVER_STATE_WAIT_START_BIT;
			end if;
		when RECEIVER_STATE_WAIT_START_BIT =>
			if rx = '0' then
				receiver_state_next <= RECEIVER_STATE_GOTO_MIDDLE_OF_START_BIT;
			end if;
		when RECEIVER_STATE_GOTO_MIDDLE_OF_START_BIT =>
			if clk_cnt = CLK_DIVISOR/2-2 then
				receiver_state_next <= RECEIVER_STATE_MIDDLE_OF_START_BIT;
			end if;
		when RECEIVER_STATE_MIDDLE_OF_START_BIT =>
			receiver_state_next <= RECEIVER_STATE_WAIT_DATA_BIT;
		when RECEIVER_STATE_WAIT_DATA_BIT =>
			if clk_cnt = CLK_DIVISOR-2 then
				receiver_state_next <= RECEIVER_STATE_MIDDLE_OF_DATA_BIT;
			end if;
		when RECEIVER_STATE_MIDDLE_OF_DATA_BIT =>
			if bit_cnt = 7 then
				receiver_state_next <= RECEIVER_STATE_WAIT_STOP_BIT;
			else
				receiver_state_next <= RECEIVER_STATE_WAIT_DATA_BIT;
			end if;
		when RECEIVER_STATE_WAIT_STOP_BIT =>
			if clk_cnt = CLK_DIVISOR-2 then
				receiver_state_next <= RECEIVER_STATE_MIDDLE_OF_STOP_BIT;
			end if;
		when RECEIVER_STATE_MIDDLE_OF_STOP_BIT =>
			if rx = '0' then
				receiver_state_next <= RECEIVER_STATE_IDLE;
			else
				receiver_state_next <= RECEIVER_STATE_WAIT_START_BIT;
			end if;
		end case;
	end process receiver_next_state;

	--------------------------------------------------------------------
	--                    PROCESS : OUTPUT                            --
	--------------------------------------------------------------------  

	receiver_output : process(receiver_state, clk_cnt, bit_cnt, data_int, data_next, rx)
	begin
		clk_cnt_next <= clk_cnt;
		bit_cnt_next <= bit_cnt;
		data_new_next <= '0';
		data_int_next <= data_int;
		data_next_next <= data_next;

		case receiver_state is
		when RECEIVER_STATE_IDLE =>
			null;
		when RECEIVER_STATE_WAIT_START_BIT =>
			bit_cnt_next <= 0;
			clk_cnt_next <= 0;
		when RECEIVER_STATE_GOTO_MIDDLE_OF_START_BIT =>
			clk_cnt_next <= clk_cnt + 1;
		when RECEIVER_STATE_MIDDLE_OF_START_BIT =>
			clk_cnt_next <= 0;
			null;
		when RECEIVER_STATE_WAIT_DATA_BIT =>
			clk_cnt_next <= clk_cnt + 1;
		when RECEIVER_STATE_MIDDLE_OF_DATA_BIT =>
			data_int_next <= rx & data_int(7 downto 1);
			clk_cnt_next <= 0;
			bit_cnt_next <= bit_cnt + 1;
		when RECEIVER_STATE_WAIT_STOP_BIT =>
			clk_cnt_next <= clk_cnt + 1;
		when RECEIVER_STATE_MIDDLE_OF_STOP_BIT =>
			data_new_next <= '1';
			data_next_next <= data_int;
			null;
		end case;

	end process receiver_output;

	--------------------------------------------------------------------
	--                    PROCESS : SYNC                              --
	--------------------------------------------------------------------

	sync : process(clk, res_n)
	begin
		if res_n = '0' then
			receiver_state <= RECEIVER_STATE_IDLE;
			data_new <= '0';
			data_next <= (others => '0');
			data_int <= (others => '0');

		elsif rising_edge(clk) then
			receiver_state <= receiver_state_next;
			bit_cnt <= bit_cnt_next;
			clk_cnt <= clk_cnt_next;
			data <= data_next_next;
			data_next <= data_next_next;
			data_int <= data_int_next;
			data_new <= data_new_next;
		end if;
	end process sync;
end architecture beh;

--- EOF ---
