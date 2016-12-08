library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.core_pack.all;

entity regfile is

	port (
		clk, reset       : in  std_logic;
		stall            : in  std_logic;
		rdaddr1, rdaddr2 : in  std_logic_vector(REG_BITS-1 downto 0);
		rddata1, rddata2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
		wraddr			 : in  std_logic_vector(REG_BITS-1 downto 0);
		wrdata			 : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite         : in  std_logic);

end regfile;

architecture rtl of regfile is
	type regfile_type is array(0 to REG_COUNT-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

	signal rdaddr1_int, rdaddr2_int: std_logic_vector(REG_BITS-1 downto 0);
	signal wraddr_int: std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
	signal regfile: regfile_type;

begin  -- rtl

  readwrite: process(rdaddr1_int, rdaddr2_int, wraddr_int, wrdata, regwrite) is
	begin
		if regwrite = '1' then
			if or_reduce(wraddr_int) /= '0' then
				if wraddr_int = rdaddr1_int then
					rddata1 <= wrdata;
				end if;
				if wraddr_int = rdaddr2_int then
					rddata2 <= wrdata;
				end if;
				regfile(to_integer(unsigned(wraddr_int))) <= wrdata;
			end if;
		end if;
		if or_reduce(rdaddr1_int) = '0' then
			rddata1 <= (DATA_WIDTH-1 downto 0 => '0');
		elsif wraddr_int /= rdaddr1_int then
			rddata1 <= regfile(to_integer(unsigned(rdaddr1_int)));
		end if;
		if or_reduce(rdaddr2_int) = '0' then
			rddata2 <= (DATA_WIDTH-1 downto 0 => '0');
		elsif wraddr_int /= rdaddr2_int then
			rddata2 <= regfile(to_integer(unsigned(rdaddr2_int)));
		end if;
	end process;

	latch: process(clk, reset) is
	begin
		if reset = '0' then
			rdaddr1_int <= (others => '0');
			rdaddr2_int <= (others => '0');
			wraddr_int <= (others => '0');
		elsif rising_edge(clk) and (not(stall = '1'))then
			rdaddr1_int <= rdaddr1;
			rdaddr2_int <= rdaddr2;
			wraddr_int <= wraddr;
		end if;
	end process;
end rtl;
