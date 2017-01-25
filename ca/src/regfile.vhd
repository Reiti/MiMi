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
	signal regfile: regfile_type;
	-- signal forw : std_logic; -- debug signal

begin  -- rtl

	rddata1 <= regfile(to_integer(unsigned(rdaddr1_int)));
	rddata2 <= regfile(to_integer(unsigned(rdaddr2_int)));

	latch: process(clk) is
	begin
		IF rising_edge(clk) then
			IF (regwrite = '1') THEN
				regfile(wraddr) <= wrdata;
			END IF;
			rdaddr1_int <= rdaddr1;
			rdaddr2_int <= rdaddr2;
		END IF;
	end process;
end rtl;
