library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vcpu816;

entity timothy is
	port(
		clk, nrst: in std_logic;
--		btns: in std_logic_vector(1 to 4);
		leds: out std_logic_vector(0 to 3);
		segments: out std_logic_vector(1 to 7);
		dp: out std_logic;
		digit_select: out std_logic_vector(0 to 7)
	);
end;

architecture struct of timothy is

component vcpu816 is
	port(
		clk, nrst, irq: in std_logic;
		din: in std_logic_vector(7 downto 0);
		write_mem: out std_logic;
		dout: out std_logic_vector(7 downto 0);
		addr: out std_logic_vector(15 downto 0)
	);
end component;

component prescaller is
	port(
		clk_in: in std_logic;
		clk_out: out std_logic
	);
end component;

component rom0 is
	port(
		clka: in std_logic;
		addra: in std_logic_vector(10 downto 0);
		douta: out std_logic_vector(7 downto 0)
	);
end component;

component ndisp is
	port(
		inter_clk, io_clk, wr, nrst: in std_logic;
		addr: in std_logic_vector(2 downto 0);
		data_bus: in std_logic_vector(7 downto 0);
		segments: out std_logic_vector(1 to 7);
		dp: out std_logic;
		digit_sel: out std_logic_vector(0 to 7)
	);
end component;

signal write_mem, io_clk, sel_ndisp, allow_start: std_logic := '0';
signal din, dout, rom0_out: std_logic_vector(7 downto 0);
signal addr: std_logic_vector(15 downto 0);
signal mem_bank: integer range 0 to 31;
signal start_cycle: integer range 0 to 127 := 0;

begin
	start_p: process(clk)
	begin
		if clk'event and clk = '1' then
			start_cycle <= start_cycle + 1;
			if start_cycle = 127 then
				allow_start <= '1';
			end if;
		end if;
	end process;

	leds <= addr(3 downto 0);

	cpu: vcpu816 port map(
		irq => '0',
		clk => io_clk,
		nrst => nrst and allow_start,
		din => din,
		dout => dout,
		addr => addr,
		write_mem => write_mem
	);
	
	mem_bank <= to_integer(unsigned(addr(15 downto 11)));
	sel_ndisp <= '1' when mem_bank = 31 and addr(10 downto 3) = "00000001" else '0';
	
	with mem_bank select din <=
		rom0_out when 0,
		"00000000" when others;
	
	rom0_inst: rom0 port map(
		clka => clk,
		addra => addr(10 downto 0),
		douta => rom0_out
	);
	
	io_psc: prescaller port map(
		clk_in => clk,
		clk_out => io_clk
	);
	
	ndisp_inst: ndisp port map(
		inter_clk => io_clk,
		io_clk => io_clk,
		wr => write_mem,
		nrst => nrst,
		addr => addr(2 downto 0),
		data_bus => dout,
		segments => segments,
		dp => dp,
		digit_sel => digit_select
	);
end;
