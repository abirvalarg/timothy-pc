library ieee;
use ieee.std_logic_1164.all;

entity pointer_reg is
	port(
		data_bus: in std_logic_vector(7 downto 0);
		wr, high, clk, nrst: in std_logic;
		output: out std_logic_vector(15 downto 0)
	);
end;

architecture struct of pointer_reg is

signal value: std_logic_vector(15 downto 0);

begin
	upd_p: process(clk, nrst)
	begin
		if nrst = '0' then
			value <= "0000000000000000";
		elsif wr and clk'event and clk = '1' then
			if high = '1' then
				value(15 downto 8) <= data_bus;
			else
				value(7 downto 0) <= data_bus;
			end if;
		end if;
	end process;
	
	output <= value;
end;
