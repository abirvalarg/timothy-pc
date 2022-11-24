library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rctl is
	port(
		clk, nrst, high: in std_logic;
		data_bus: in std_logic_vector(7 downto 0);
		reg_sel, target_sel: in integer range 0 to 3;
		cmd: in integer range 0 to 5;
		addr_back: in std_logic_vector(15 downto 0);
		addr: out std_logic_vector(15 downto 0);
		value: out std_logic_vector(7 downto 0)
	);
end;

architecture struct of rctl is

signal x, y, sp, pc, sel_val: std_logic_vector(15 downto 0) := "0000000000000000";

begin
	upd_p: process(nrst, clk)
	begin
		if nrst = '0' then
			x <= "0000000000000000";
			y <= "0000000000000000";
			sp <= "0000000000000000";
			pc <= "0000000000000000";
		elsif clk'event and clk = '1' then
			case cmd is
				when 0 =>
				when 1 =>
					if high = '1' then
						case reg_sel is
							when 0 => x <= data_bus & x(7 downto 0);
							when 1 => y <= data_bus & y(7 downto 0);
							when 2 => sp <= data_bus & sp(7 downto 0);
							when 3 => pc <= data_bus & pc(7 downto 0);
						end case;
					else
						case reg_sel is
							when 0 => x <= x(15 downto 8) & data_bus;
							when 1 => y <= y(15 downto 8) & data_bus;
							when 2 => sp <= sp(15 downto 8) & data_bus;
							when 3 => pc <= pc(15 downto 8) & data_bus;
						end case;
					end if;
				when 2 =>
					case reg_sel is
						when 0 => x <= std_logic_vector(unsigned(x) + 1);
						when 1 => y <= std_logic_vector(unsigned(y) + 1);
						when 2 => sp <= std_logic_vector(unsigned(sp) + 1);
						when 3 => pc <= std_logic_vector(unsigned(pc) + 1);
					end case;
				when 3 =>
					case reg_sel is
						when 0 => x <= std_logic_vector(unsigned(x) - 1);
						when 1 => y <= std_logic_vector(unsigned(y) - 1);
						when 2 => sp <= std_logic_vector(unsigned(sp) - 1);
						when 3 => pc <= std_logic_vector(unsigned(pc) - 1);
					end case;
				when 4 =>
					case target_sel is
						when 0 => x <= sel_val;
						when 1 => y <= sel_val;
						when 2 => sp <= sel_val;
						when 3 => pc <= sel_val;
					end case;
				when 5 =>
					case reg_sel is
						when 0 => x <= addr_back;
						when 1 => y <= addr_back;
						when 2 => sp <= addr_back;
						when 3 => pc <= addr_back;
					end case;
			end case;
		end if;
	end process;

	with reg_sel select sel_val <=
		x when 0,
		y when 1,
		sp when 2,
		pc when 3;
	
	addr <= sel_val;
	value <= sel_val(15 downto 8) when high = '1' else sel_val(7 downto 0);
end;
