library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.core_pack.all;
use work.op_pack.all;

entity testbench_regfile is
end entity;

architecture beh of testbench_regfile is
  constant CLK_PERIOD: time := 20 ns;
  signal clk, reset, stall, regwrite: std_logic;
  signal rdaddr1, rdaddr2, wraddr: std_logic_vector(REG_BITS-1 downto 0);
  signal rddata1, rddata2, wrdata: std_logic_vector(DATA_WIDTH-1 downto 0);

begin

  reg: entity work.regfile
  port map(
    clk => clk,
    reset => reset,
    stall => stall,
    rdaddr1 => rdaddr1,
    rdaddr2 => rdaddr2,
    rddata1 => rddata1,
    rddata2 => rddata2,
    wraddr => wraddr,
    wrdata => wrdata,
    regwrite => regwrite
  );

  clk_gen: process is
  begin
    clk <= '1';
    wait for CLK_PERIOD/2;
    clk <= '0';
    wait for CLK_PERIOD/2;
  end process;

  rs_gen: process is
  begin
    reset <= '0';
    wait for 2*CLK_PERIOD;
    reset <= '1';
    wait;
  end process;

  regfile_test: process is
  begin
	wait until rising_edge(reset);
	wait until rising_edge(clk);
	rdaddr1 <= "00000"; rdaddr2<="00000";
	stall <= '0';
	regwrite <= '0';

	wait until rising_edge(clk);
--prep for failes stall tests:
	stall <= '0';
	rdaddr1 <= "00001"; rdaddr2<="00000";
	wraddr <= "00001";
	wrdata <= x"AA55AA55";
	regwrite <= '1';

	wait until rising_edge(clk);
	assert(or_reduce(rddata1) = '0') report "0010";
	assert(or_reduce(rddata2) = '0') report "0020";

	--expecting: rd1: AA55AA55 rd2: 0
	for I in 1 to 3 loop
		wait until rising_edge(clk);

		wait for CLK_PERIOD/100;
		assert(or_reduce(rddata2) = '0') report "0110";
		assert(rddata1 = x"AA55AA55") report "0120";
	end loop;


	wait until rising_edge(clk);
  --reproducing failed test
	stall <= '1';
	rdaddr1 <= "00000"; rdaddr2<="00000";
	wraddr <= "10101";
	wrdata <=x"55AA55AA";
	regwrite <= '1';
	wait for CLK_PERIOD/100;
	assert(or_reduce(rddata2) = '0') report "0210";
	assert(rddata1 = x"AA55AA55") report "0220";

	wait for 2*CLK_PERIOD;
	wait until rising_edge(clk);
	stall <= '1';
	rdaddr1 <= "00000"; rdaddr2<="00000";
	wraddr <= "00000";
	wrdata <=x"12345678";
	regwrite <= '1';
	wait for CLK_PERIOD/100;
	assert(or_reduce(rddata2) = '0') report "0310";
	assert(rddata1 = x"AA55AA55") report "0320";
	--expecting: rd1: AA55AA55 rd2: 0

	wait for 5*CLK_PERIOD;
--prep for failed sym. r/w tests
	wait until rising_edge(clk);
	stall <= '0';
	rdaddr1 <= "00000"; rdaddr2<="00000";
	wraddr <= "11100";
	wrdata <=x"00000001";
	regwrite <= '1';

	wait for CLK_PERIOD/100;
	assert(or_reduce(rddata2) = '0') report "0410";
	assert(rddata1 = x"AA55AA55") report "0420";

	wait until rising_edge(clk);
	rdaddr1 <= "00000"; rdaddr2<="00000";
	wraddr <= "11101";
	wrdata <=x"FEDCBA98";
	regwrite <= '1';


	wait for 3*CLK_PERIOD;
	wait for CLK_PERIOD/100;
	assert(or_reduce(rddata1) = '0') report "0480";
	assert(or_reduce(rddata2) = '0') report "0490";
	wait until rising_edge(clk); -- <-- need this!!!
	rdaddr1<= "11100"; rdaddr2 <= "00000";
	regwrite <= '0';
	wait until rising_edge(clk);
	rdaddr1 <= "11101"; rdaddr2 <= "11101";
	wraddr <= "11100";
	wrdata <= x"89ABCDEF";
	regwrite <= '1';
	wait for CLK_PERIOD/100;
	assert(rddata1 = x"89ABCDEF") report "0510";
	assert(or_reduce(rddata2) = '0') report "0520";

	--expecting: rd1:89ABCDEF rd2:0
	--wait for 1*CLK_PERIOD;
	--wrdata <= x"00000000";
	wait for 4*CLK_PERIOD;
	wait until rising_edge(clk);
	stall <= '0';
	rdaddr1<= "00000"; rdaddr2 <= "11101";
	wraddr <= "11101";
	wrdata <= x"76543210";
	regwrite <= '1';
	wait for CLK_PERIOD/100;
	assert(rddata2 = x"76543210") report "0610";

	wait until rising_edge(clk);
	regwrite <= '1';
	wraddr <= "00000";
	wrdata <= x"FFFFFFFF";
	wait for CLK_PERIOD/100;
	assert(or_reduce(rddata1) = '0') report "0620";
	assert(rddata2 = x"76543210") report "0630";
	--expecting: rd1:0 rd2:76543210

	wait until rising_edge(clk);
	rdaddr1<= "11101"; rdaddr2 <= "11101";
	wraddr <= "11101";
	wrdata <= x"ABCDEF00";
	regwrite <= '0';
	-- expecting old data as regwrite = 0
	wait for CLK_PERIOD/100;
	assert(or_reduce(rddata1) = '0') report "0620";
	assert(rddata2 = x"76543210") report "0630";

	for I in 1 to 10 loop
		wait until rising_edge(clk);
		rdaddr1<= "11101"; rdaddr2 <= "11101";
		if I = 3 then
			wraddr <= "00000";
		else
			wraddr <= "11101";
		end if;
		wrdata <= x"ABCDEF00";
		if I = 4 then
			regwrite <= '0';
		else
			regwrite <= '1';
		end if;
		if I = 8 or I = 9 then
			stall <= '1';
		else
			stall <= '0';
		end if;
		wait for CLK_PERIOD/100;
		-- expecting new data at r30
		-- playing around with regwrite/stall or writing
		-- to other registers should not change this
		assert(rddata1 = x"ABCDEF00") report "0810";
		assert(rddata2 = x"ABCDEF00") report "0820";
	end loop;

	wait until rising_edge(clk);
	rdaddr1 <= "00000"; rdaddr2 <= "00000";
	regwrite <= '0';

	wait until rising_edge(clk);


	wait; 
  end process;

end architecture beh;
