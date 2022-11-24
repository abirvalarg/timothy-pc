library ieee;
use ieee.std_logic_1164.all;

entity rom_tb is
end;

architecture struct of rom_tb is

component rom0 is
	port(
		clka: in std_logic;
		addra: in std_logic_vector(10 downto 0);
		douta: out std_logic_vector(7 downto 0)
	);
end component;

signal clk: std_logic := '0';
signal addr: std_logic_vector(10 downto 0) := "00000000000";
signal val: std_logic_vector(7 downto 0);

begin
	rom0_inst: rom0 port map(
		clka => clk,
		addra => addr,
		douta => val
	);
end;
