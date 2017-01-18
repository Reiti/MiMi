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
	regwrite <= '1';
	wraddr <= "00001";
	wrdata <= x"DDCADDCA";
	wait until rising_edge(clk);
	stall <= '1';
	wrdata <= (others => '0');
	wait for 1 ns;
	stall <= '0';


	wait until rising_edge(clk);
	rdaddr1 <= "00000"; rdaddr2<="00000";
	stall <= '0';
	regwrite <= '0';
	wraddr <= (others => '0');
	wrdata <= (others => '0');

	wait until rising_edge(clk);
--prep for failes stall tests:
	stall <= '0';
	rdaddr1 <= "00001"; rdaddr2<="00000";
	wraddr <= "00001";
	wrdata <= x"AA55AA55";
	regwrite <= '1';

	wait until rising_edge(clk);
	assert(or_reduce(rddata1) = '0') report "0010" severity Error;
	assert(or_reduce(rddata2) = '0') report "0020" severity Error;

	--expecting: rd1: AA55AA55 rd2: 0
	for I in 1 to 3 loop
		wait until rising_edge(clk);

		wait for CLK_PERIOD/100;
		assert(or_reduce(rddata2) = '0') report "0110" severity Error;
		assert(rddata1 = x"AA55AA55") report "0120" severity Error;
	end loop;


	wait until rising_edge(clk);
  --reproducing failed test
	stall <= '1';
	rdaddr1 <= "00000"; rdaddr2<="00000";
	wraddr <= "10101";
	wrdata <=x"55AA55AA";
	regwrite <= '1';
	wait for CLK_PERIOD/100;
	assert(or_reduce(rddata2) = '0') report "0210" severity Error;
	assert(rddata1 = x"AA55AA55") report "0220" severity Error;

	wait for 2*CLK_PERIOD;
	wait until rising_edge(clk);
	stall <= '1';
	rdaddr1 <= "00000"; rdaddr2<="00000";
	wraddr <= "00000";
	wrdata <=x"12345678";
	regwrite <= '1';
	wait for CLK_PERIOD/100;
	assert(or_reduce(rddata2) = '0') report "0310" severity Error;
	assert(rddata1 = x"AA55AA55") report "0320" severity Error;
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
	assert(or_reduce(rddata2) = '0') report "0410" severity Error;
	assert(rddata1 = x"AA55AA55") report "0420" severity Error;

	wait until rising_edge(clk);
	rdaddr1 <= "00000"; rdaddr2<="00000";
	wraddr <= "11101";
	wrdata <=x"FEDCBA98";
	regwrite <= '1';


	wait for 3*CLK_PERIOD;
	wait for CLK_PERIOD/100;
	assert(or_reduce(rddata1) = '0') report "0480" severity Error;
	assert(or_reduce(rddata2) = '0') report "0490" severity Error;
	wait until rising_edge(clk); -- <-- need this!!!
	rdaddr1<= "11100"; rdaddr2 <= "00000";
	regwrite <= '0';
	wait until rising_edge(clk);
	rdaddr1 <= "11101"; rdaddr2 <= "11101";
	wraddr <= "11100";
	wrdata <= x"89ABCDEF";
	regwrite <= '1';
	wait for CLK_PERIOD/100;
	assert(rddata1 = x"89ABCDEF") report "0510" severity Error;
	assert(or_reduce(rddata2) = '0') report "0520" severity Error;

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
	assert(rddata2 = x"76543210") report "0610" severity Error;

	wait until rising_edge(clk);
	regwrite <= '1';
	wraddr <= "00000";
	wrdata <= x"FFFFFFFF";
	wait for CLK_PERIOD/100;
	assert(or_reduce(rddata1) = '0') report "0620" severity Error;
	assert(rddata2 = x"76543210") report "0630" severity Error;
	--expecting: rd1:0 rd2:76543210

	wait until rising_edge(clk);
	stall <= '0';
	rdaddr1<= "11101"; rdaddr2 <= "11101";
	wraddr <= "11101";
	wrdata <= x"ABCDEF00";
	regwrite <= '0';
	-- expecting old data as regwrite = 0
	wait for CLK_PERIOD/100;
	assert(or_reduce(rddata1) = '0') report "0620" severity Error;
	assert(rddata2 = x"76543210") report "0630" severity Error;

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
		assert(rddata1 = x"ABCDEF00") report "0810" severity Error;
		assert(rddata2 = x"ABCDEF00") report "0820" severity Error;
	end loop;

	wait until rising_edge(clk);
	regwrite <= '1';
	wraddr <= "00001";
	wrdata <= (others => '0');

	wait until rising_edge(clk);
	regwrite <= '1';
	wraddr <= "00010";
	rdaddr1 <= "00000"; rdaddr2 <= "00000";
	wrdata <= (others => '0');

	wait until rising_edge(clk);
	regwrite <= '1';
	wraddr <= "00001";
	wrdata <= x"AAAAAAAA";
	rdaddr1 <= "00001"; rdaddr2 <= "00010";
	
	wait until rising_edge(clk);
	assert(or_reduce(rddata1) = '0') report "0900" severity Error;
	assert(or_reduce(rddata2) = '0') report "0901" severity Error;

	regwrite <= '1';
	wraddr <= "00010";
	wrdata <= x"BBBBBBBB";
	

	wait until rising_edge(clk);
	assert(rddata1 = x"AAAAAAAA") report "0910" severity Error;
	assert(rddata2 = x"BBBBBBBB") report "0911" severity Error;

	regwrite <= '0';
	stall <= '0';
	

	wait until rising_edge(clk);
	assert(rddata1 = x"AAAAAAAA") report "0920" severity Error;
	assert(rddata2 = x"BBBBBBBB") report "0921" severity Error;

	regwrite <= '1';
	stall <= '1';
	wraddr <= "00010";
	wrdata <= x"CCCCCCCC";

	wait until rising_edge(clk);
	assert(rddata1 = x"AAAAAAAA") report "0930" severity Error;
	assert(rddata2 = x"BBBBBBBB") report "0931" severity Error;

	wraddr <= "00010";
	wrdata <= x"DDDDDDDD";
	stall <= '0';
	regwrite <= '1';
	

	wait until rising_edge(clk);
	assert(rddata1 = x"AAAAAAAA") report "0940" severity Error;
	assert(rddata2 = x"DDDDDDDD") report "0941" severity Error;

	wraddr <= "00010";
	wrdata <= x"FFFFFFFF";
	stall <= '1';
	regwrite <= '1';
	

	wait until rising_edge(clk);
	assert(rddata1 = x"AAAAAAAA") report "0950" severity Error;
	assert(rddata2 = x"DDDDDDDD") report "0951" severity Error;

	stall <= '1';
	rdaddr1 <= "00000"; rdaddr2 <= "00001";
	wraddr <= "00001";
	regwrite <= '1';
	wrdata <= x"1234ABCD";

	wait until rising_edge(clk);
	assert(rddata1 = x"AAAAAAAA") report "0960" severity Error;
	assert(rddata2 = x"DDDDDDDD") report "0961" severity Error;


	stall <= '0';
	rdaddr1 <= "00001"; rdaddr2 <= "00000";
	wraddr <= "00000";
	wrdata <= x"FFFFFFFF";
	regwrite <= '1';

	wait until rising_edge(clk);
	assert(rddata1 = x"AAAAAAAA") report "0970" severity Error;
	assert(rddata2 = x"DDDDDDDD") report "0971" severity Error;
	
	rdaddr1 <= "00000"; rdaddr2 <= "00000";
	regwrite <= '0';

	wait until rising_edge(clk);
	assert(rddata1 = x"AAAAAAAA") report "0980" severity Error;
	assert(or_reduce(rddata2) = '0') report "0981" severity Error;

	wait until rddata1'event or rddata2'event;
	wait until rddata1'event or rddata2'event;
	assert(rdaddr1'last_event <= CLK_PERIOD+CLK_PERIOD/100) report "1000" severity Error;



	wait; 
  end process;

end architecture beh;
