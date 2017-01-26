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

	signal rdaddr1_int, rdaddr2_int, wraddr_int: std_logic_vector(REG_BITS-1 downto 0);
	signal rddata1_int, rddata2_int, wrdata_int: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal regwrite_int: std_logic;

	signal regfile: regfile_type;
	-- signal forw : std_logic; -- debug signal

begin  -- rtl


	forwarder:process(stall, regwrite, regwrite_int, rdaddr1, rdaddr2, rdaddr1_int, rdaddr2_int, rddata1_int, rddata2_int, wraddr, wrdata) is
	begin
		rddata1 <= std_logic_vector(TO_01(signed(rddata1_int)));
		rddata2 <= std_logic_vector(TO_01(signed(rddata2_int)));

		if regwrite = '1' and stall = '0' then
			if rdaddr1_int = wraddr then
				rddata1 <= wrdata;
			end if;
			if rdaddr2_int = wraddr then
				rddata2 <= wrdata;
			end if;
		end if;
		
		if or_reduce(rdaddr1_int) = '0' then
			rddata1 <= (others => '0');
		end if;
		if or_reduce(rdaddr2_int) = '0' then
			rddata2 <= (others => '0');
		end if;
	end process;
	

-- SYNC_RAM register memory conforming to Altera guidelines
	rddata1_int <= regfile(to_integer(unsigned(rdaddr1_int)));
	rddata2_int <= regfile(to_integer(unsigned(rdaddr2_int)));

	regmem: process(clk) is
	begin
		if rising_edge(clk) and stall = '0' then
			if regwrite = '1' then
				regfile(to_integer(unsigned(wraddr))) <= wrdata;
			end if;
			rdaddr1_int <= rdaddr1;
			rdaddr2_int <= rdaddr2;
			wraddr_int <= wraddr;
			wrdata_int <= wrdata;
			regwrite_int <= regwrite;
		end if;
	end process;
end rtl;
