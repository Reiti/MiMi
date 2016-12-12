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
	signal rddata1_int, rddata2_int: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal wraddr_int: std_logic_vector(REG_BITS-1 downto 0) := (others => '0');
	signal wrdata_int : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal regfile: regfile_type := (others => (others => '0'));

begin  -- rtl

	readwrite: process(rdaddr1_int, rdaddr2_int, wraddr_int, wrdata_int, regwrite, regfile) is
	begin
		if regwrite = '1' and or_reduce(wraddr_int) /= '0' then
			regfile(to_integer(unsigned(wraddr_int))) <= wrdata_int;
		end if;
		if or_reduce(rdaddr1_int) = '0' then
			rddata1_int <= (DATA_WIDTH-1 downto 0 => '0');
		else
			rddata1_int <= regfile(to_integer(unsigned(rdaddr1_int)));
		end if;
		if or_reduce(rdaddr2_int) = '0' then
			rddata2_int <= (DATA_WIDTH-1 downto 0 => '0');
		else
			rddata2_int <= regfile(to_integer(unsigned(rdaddr2_int)));
		end if;
	end process;

	mux:process(clk, regwrite, wraddr, rdaddr1_int, rdaddr2_int, rddata1_int, rddata2_int)
	begin
		if regwrite = '1' and wraddr = rdaddr1_int then
			rddata1 <= wrdata;
		else
			if rising_edge(clk) then
				rddata1 <= rddata1_int;
			end if;
		end if;
		if regwrite = '1' and wraddr = rdaddr2_int then
			rddata2 <= wrdata;
		else
			if rising_edge(clk) then
				rddata2 <= rddata2_int;
			end if;
		end if;
	end process;

	latch: process(clk, reset) is
	begin
		if reset = '0' then
			rdaddr1_int <= (others => '0');
			rdaddr2_int <= (others => '0');
			wraddr_int <= (others => '0');
			rddata1_int <= (others => '0');
			rddata2_int <= (others => '0');
		elsif rising_edge(clk) and (not(stall = '1'))then
			rdaddr1_int <= rdaddr1;
			rdaddr2_int <= rdaddr2;
			wraddr_int <= wraddr;
			wrdata_int <= wrdata;
		end if;
	end process;
end rtl;
