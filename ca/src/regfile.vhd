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
	signal rddata1_next, rddata2_next: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal rddata1_next_next, rddata2_next_next: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal rf1, rf2 : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal wraddr_int: std_logic_vector(REG_BITS-1 downto 0);
	signal wrdata_int : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal regfile: regfile_type;
	signal regwrite_int : std_logic;
	-- signal forw : std_logic; -- debug signal

begin  -- rtl

	forwarder:process(stall, regwrite, wraddr, wrdata, rdaddr1_int, rdaddr2_int, rddata1_next, rddata2_next, rf1, rf2) is
	variable fwd : boolean;
	begin
		rddata1_next_next <= rddata1_next;
		rddata2_next_next <= rddata2_next;
		if stall = '0' then
			rddata1_next_next <= rf1;
			rddata2_next_next <= rf2;

			-- check if we should forward wrdata
			fwd := regwrite = '1';
			if fwd and wraddr = rdaddr1_int then
				rddata1_next_next <= wrdata;
			end if;
			if fwd and wraddr = rdaddr2_int then
				rddata2_next_next <= wrdata;
			end if;

			-- zero outputs if $0 was read
			if or_reduce(rdaddr1_int) = '0' then
				rddata1_next_next <= (others => '0');
			end if;
			if or_reduce(rdaddr2_int) = '0' then
				rddata2_next_next <= (others => '0');
			end if;
		end if;
	end process;

	rddata1 <= rddata1_next_next;
	rddata2 <= rddata2_next_next;
	rf1 <= regfile(to_integer(unsigned(rdaddr1_int)));
	rf2 <= regfile(to_integer(unsigned(rdaddr2_int)));

	latch: process(clk, reset, stall, rdaddr1, rdaddr2, wraddr, wrdata, regwrite, regwrite_int, rddata1_next_next, rddata2_next_next, wrdata_int, wraddr_int) is
	begin
		if reset = '0' then
			rdaddr1_int <= (others => '0');
			rdaddr2_int <= (others => '0');
			wraddr_int <= (others => '0');
			wrdata_int <= (others => '0');
			rddata1_next <= (others => '0');
			rddata2_next <= (others => '0');
			regwrite_int <= '0';
			--assert(forw = '0');
		elsif stall /= '1' and rising_edge(clk) then
			rdaddr1_int <= rdaddr1;
			rdaddr2_int <= rdaddr2;
			wraddr_int <= wraddr;
			wrdata_int <= wrdata;
			regwrite_int <= regwrite;
			rddata1_next <= rddata1_next_next;
			rddata2_next <= rddata2_next_next;
		end if;
		if reset /= '0' and regwrite_int = '1' and or_reduce(wraddr_int) /= '0' then
			regfile(to_integer(unsigned(wraddr_int))) <= wrdata_int;
		end if;
	end process;
end rtl;
