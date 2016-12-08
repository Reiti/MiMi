library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity wb is
	
	port (
		clk, reset : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;
		op	   	   : in  wb_op_type;
		rd_in      : in  std_logic_vector(REG_BITS-1 downto 0);
		aluresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		memresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		rd_out     : out std_logic_vector(REG_BITS-1 downto 0);
		result     : out std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite   : out std_logic);

end wb;

architecture rtl of wb is
	signal aluresult_int, memresult_int: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal rd_in_int: std_logic_vector(REG_BITS-1 downto 0);
	signal op_int: wb_op_type;
begin  -- rtl

	wb_out: process(op_int, aluresult_int, memresult_int, rd_in_int) is
	begin
		regwrite <= op_int.regwrite;
		if op_int.memtoreg = '1' then
			result <= memresult_int;
		else
			result <= aluresult_int;
		end if;
	end process;

	rd_out <= rd_in_int;
		
	latch: process(clk, reset, stall, flush) is
	begin
		if reset = '0' or flush = '1' then
			aluresult_int <= (others => '0');
			memresult_int <= (others => '0');
			rd_in_int <= (others => '0');
			op_int <= WB_NOP;
		elsif rising_edge(clk) and (not(stall = '1')) then
			aluresult_int <= aluresult;
			memresult_int <= memresult;
			rd_in_int <= rd_in;
			op_int <= op;
		end if;
	end process;
end rtl;
