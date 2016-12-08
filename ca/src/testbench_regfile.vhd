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
    --test write
    wait until rising_edge(reset);
    wraddr <= "11111";
    wait until rising_edge(clk);
    wrdata <= x"aaaaaaaa";
    regwrite <= '1';
    wait until rising_edge(clk);
    wraddr <= "11110";
    wait until rising_edge(clk);
    wrdata <= x"aaaaaaaa";
    wait until rising_edge(clk);

    --test simultaneous read and write
    rdaddr1 <= "11111";
    wraddr <= "11111";
    wait until rising_edge(clk);
    wrdata <= x"0000aaaa";
    regwrite <= '1';
    wait until rising_edge(clk);
    regwrite <= '0';
    wait until rising_edge(clk);

    --test read i guess
    rdaddr1 <= "11111";
    rdaddr2 <= "11110";
    wait until rising_edge(clk);
    stall <= '1';
    rdaddr1 <= "00111";
    rdaddr2 <= "00110";
    wraddr <= "00111";
    wait until rising_edge(clk);
    wait until rising_edge(clk);
  end process;

end architecture beh;
