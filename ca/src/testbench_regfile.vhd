library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
--prep for failes stall tests:
	stall <= '0';
	rdaddr1 <= "00001"; rdaddr2<="00000";
	wraddr <= "00001";
	wrdata <=x"AA55AA55";
	regwrite <= '1';
wait for 3*CLK_PERIOD;
  --reproducing failed test
	stall <= '1';
	rdaddr1 <= "00000"; rdaddr2<="00000";
	wraddr <= "10101";
	wrdata <=x"55AA55AA";
	regwrite <= '1';
	--expecting: rd1: AA55AA55 rd2: 0
	wait for 2*CLK_PERIOD;
	stall <= '1';
	rdaddr1 <= "00000"; rdaddr2<="00000";
	wraddr <= "00000";
	wrdata <=x"12345678";
	regwrite <= '1';
	--expecting: rd1: AA55AA55 rd2: 0
wait for 5*CLK_PERIOD;

--prep for failed sym. r/w tests
	stall <= '0';
	rdaddr1 <= "00000"; rdaddr2<="00000";
	wraddr <= "11100";
	wrdata <=x"00000000";
	regwrite <= '1';
wait for 1*CLK_PERIOD;
	stall <= '0';
	rdaddr1 <= "00000"; rdaddr2<="00000";
	wraddr <= "11101";
	wrdata <=x"FEDCBA98";
	regwrite <= '1';


	wait for 3*CLK_PERIOD;
	wait until rising_edge(clk); -- <-- need this!!!
	stall <= '0';
	rdaddr1<= "11100"; rdaddr2 <= "00000";
	regwrite <= '0';
	wait until rising_edge(clk);
	wraddr <= "11100";
	wrdata <= x"89ABCDEF";
	regwrite <= '1';
	assert(rddata1 = x"89ABCDEF");
	assert(rddata2 = x"00000000");

	--expecting: rd1:89ABCDEF rd2:0
	--wait for 1*CLK_PERIOD;
	--wrdata <= x"00000000";
	wait for 4*CLK_PERIOD;
	stall <= '0';
	rdaddr1<= "00000"; rdaddr2 <= "11101";
	wraddr <= "11101";
	wrdata <= x"76543210";
	regwrite <= '1';
	wait for 1*CLK_PERIOD;
	--wrdata <= x"00000000";
	--expecting: rd1:0 rd2:76543210
	wait; 
  end process;

end architecture beh;
