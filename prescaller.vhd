library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity prescaller is
	port(
		clk_in: in std_logic;
		clk_out: out std_logic
	);
end;

architecture struct of prescaller is

signal counter: std_logic_vector(10 downto 0) := "00000000000";

begin
	upd: process(clk_in)
	begin
		if clk_in'event and clk_in = '1' then
			counter <= counter + "00000000001";
		end if;
	end process;
	
	clk_out <= counter(7);
end;
