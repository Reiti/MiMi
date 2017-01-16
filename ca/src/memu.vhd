library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.core_pack.all;
use work.op_pack.all;

entity memu is
	port (
		op   : in  mem_op_type;
		A    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
		W    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		D    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		M    : out mem_out_type;
		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		XL   : out std_logic;
		XS   : out std_logic);
end memu;

architecture rtl of memu is
	signal acc_type: std_logic_vector(1 downto 0);
	function get_pos(from_left: integer) return integer is
	begin
		return (BYTES_PER_WORD - from_left)*BYTE_WIDTH;
	end get_pos;
begin  -- rtl
  acc_type <= A(1 downto 0);

	mem_out: process(op, W, acc_type) is
	begin
		M.wrdata <= (others => '0');
		case op.memtype is
			when MEM_B | MEM_BU =>
				case acc_type is
					when "00" =>
						M.byteena <= "1000";
						M.wrdata(get_pos(0)-1 downto get_pos(1)) <= W(BYTE_WIDTH-1 downto 0);
					when "01" =>
						M.byteena <= "0100";
						M.wrdata(get_pos(1)-1 downto get_pos(2)) <= W(BYTE_WIDTH-1 downto 0);
					when "10" =>
						M.byteena <= "0010";
						M.wrdata(get_pos(2)-1 downto get_pos(3)) <= W(BYTE_WIDTH-1 downto 0);
					when "11" =>
						M.byteena <= "0001";
						M.wrdata(get_pos(3)-1 downto get_pos(4)) <= W(BYTE_WIDTH-1 downto 0);
					when others => null;
				end case;
			when MEM_H | MEM_HU =>
				case acc_type is
					when "00" | "01" =>
						M.byteena <= "1100";
						M.wrdata(get_pos(0)-1 downto get_pos(2)) <= W((2*BYTE_WIDTH)-1 downto 0);
					when "10" | "11" =>
						M.byteena <= "0011";
						M.wrdata(get_pos(2)-1 downto get_pos(4)) <= W((2*BYTE_WIDTH)-1 downto 0);
					when others => null;
				end case;
			when MEM_W =>
				M.byteena <= "1111";
				M.wrdata(get_pos(0)-1 downto get_pos(4)) <= W((4*BYTE_WIDTH)-1 downto 0);
			when others => null;
		end case;
	end process;

	mem_in: process(op, D, acc_type) is
	begin
    case op.memtype is
      when MEM_B =>
        case acc_type is
          when "00" =>
            R <= std_logic_vector(resize(signed(D(get_pos(0)-1 downto get_pos(1))), R'length));
          when "01" =>
            R <= std_logic_vector(resize(signed(D(get_pos(1)-1 downto get_pos(2))), R'length));
          when "10" =>
            R <= std_logic_vector(resize(signed(D(get_pos(2)-1 downto get_pos(3))), R'length));
          when "11" =>
            R <= std_logic_vector(resize(signed(D(get_pos(3)-1 downto get_pos(4))), R'length));
          when others => null;
        end case;
      when MEM_BU =>
        case acc_type is
          when "00" =>
            R <= std_logic_vector(resize(unsigned(D(get_pos(0)-1 downto get_pos(1))), R'length));
          when "01" =>
            R <= std_logic_vector(resize(unsigned(D(get_pos(1)-1 downto get_pos(2))), R'length));
          when "10" =>
            R <= std_logic_vector(resize(unsigned(D(get_pos(2)-1 downto get_pos(3))), R'length));
          when "11" =>
            R <= std_logic_vector(resize(unsigned(D(get_pos(3)-1 downto get_pos(4))), R'length));
          when others => null;
        end case;
      when MEM_H =>
        case acc_type is
          when "00" | "01" =>
            R <= std_logic_vector(resize(signed(D(get_pos(0)-1 downto get_pos(2))), R'length));
          when "10" | "11"=>
            R <= std_logic_vector(resize(signed(D(get_pos(2)-1 downto get_pos(4))), R'length));
          when others => null;
        end case;
      when MEM_HU =>
        case acc_type is
          when "00" | "01" =>
            R <= std_logic_vector(resize(unsigned(D(get_pos(0)-1 downto get_pos(2))), R'length));
          when "10" | "11"=>
            R <= std_logic_vector(resize(unsigned(D(get_pos(2)-1 downto get_pos(4))), R'length));
          when others => null;
        end case;
      when MEM_W =>
        R <= D(get_pos(0)-1 downto get_pos(4));
      when others => null;
    end case;
	end process;

	load_ex: process(op, A, acc_type) is
	begin
		XL <= '0';
		M.address <= A;
		M.rd <= op.memread;
		if op.memread = '1' then
			if acc_type = "00" and or_reduce(A(ADDR_WIDTH-1 downto 2)) = '0' then
				XL <= '1';
				M.rd <= '0';
			else
				case op.memtype is
					when MEM_H | MEM_HU =>
						if acc_type = "01" or acc_type = "11" then
							XL <= '1';
							M.rd <= '0';
						end if;
					when MEM_W =>
						if acc_type /= "00" then
							XL <= '1';
							M.rd <= '0';
						end if;
					when others => null;
				end case;
			end if;
		end if;
	end process;

	store_ex: process(op, A, acc_type) is
	begin
		XS <= '0';
		M.address <= A;
		M.wr <= op.memwrite;
		if op.memwrite = '1' then
			if acc_type = "00" and or_reduce(A(ADDR_WIDTH-1 downto 2)) = '0' then
				XS <= '1';
				M.wr <= '0';
			else
				case op.memtype is
					when MEM_H | MEM_HU =>
						if acc_type = "01" or acc_type = "11" then
							XS <= '1';
							M.wr <= '0';
						end if;
					when MEM_W =>
						if acc_type /= "00" then
							XS <= '1';
							M.wr <= '0';
						end if;
					when others => null;
				end case;
			end if;
		end if;
	end process;
end rtl;
