library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ndisp is
	port(
		inter_clk, io_clk, wr, nrst: in std_logic;
		addr: in std_logic_vector(2 downto 0);
		data_bus: in std_logic_vector(7 downto 0);
		segments: out std_logic_vector(1 to 7);
		dp: out std_logic;
		digit_sel: out std_logic_vector(0 to 7)
	);
end;

architecture struct of ndisp is

type regs_t is array(0 to 7) of std_logic_vector(5 downto 0);
signal regs: regs_t;
signal id, cur_id: integer range 0 to 7 := 0;
signal cycle: integer range 0 to 3 := 0;
signal hide: std_logic := '0';
signal cur: integer range 0 to 15;

begin
	reg_upd_p: process(nrst, inter_clk, wr)
	begin
		if nrst = '0' then
			regs(0) <= "100000";
			regs(1) <= "100000";
			regs(2) <= "100000";
			regs(3) <= "100000";
			regs(4) <= "100000";
			regs(5) <= "100000";
			regs(6) <= "100000";
			regs(7) <= "100000";
		elsif inter_clk'event and inter_clk = '1' and wr = '1' then
			regs(id) <= data_bus(5 downto 0);
		end if;
	end process;
	
	show_p: process(io_clk)
	begin
		if io_clk'event and io_clk = '1' then
			cycle <= cycle + 1;

			if hide = '0' and cycle = 1 then
				case cur is
					when 0 =>
						segments <= "0000001";
					when 1 =>
						segments <= "1001111";
					when 2 =>
						segments <= "0010010";
					when 3 =>
						segments <= "0000110";
					when 4 =>
						segments <= "1001100";
					when 5 =>
						segments <= "0100100";
					when 6 =>
						segments <= "0100000";
					when 7 =>
						segments <= "0001111";
					when 8 =>
						segments <= "0000000";
					when 9 =>
						segments <= "0000100";
					when 10 =>
						segments <= "0001000";
					when 11 =>
						segments <= "1100000";
					when 12 =>
						segments <= "0110001";
					when 13 =>
						segments <= "1000010";
					when 14 =>
						segments <= "0110000";
					when 15 =>
						segments <= "0111000";
					when others =>
						segments <= "1101010";
				end case;
			else
				segments <= "1111111";
			end if;
			
			if cycle = 3 then
				cur_id <= cur_id + 1;
			end if;
		end if;
	end process;
	
	id <= to_integer(unsigned(addr));
	hide <= regs(cur_id)(5);
	dp <= not regs(cur_id)(4);
	cur <= to_integer(unsigned(regs(cur_id)(3 downto 0)));
	
	with cur_id select digit_sel <=
		"01111111" when 0,
		"10111111" when 1,
		"11011111" when 2,
		"11101111" when 3,
		"11110111" when 4,
		"11111011" when 5,
		"11111101" when 6,
		"11111110" when 7;
end;
