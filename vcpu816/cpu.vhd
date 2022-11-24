library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vcpu816 is
	port(
		clk, nrst, irq: in std_logic;
		din: in std_logic_vector(7 downto 0);
		write_mem: out std_logic;
		dout: out std_logic_vector(7 downto 0);
		addr: out std_logic_vector(15 downto 0)
	);
end;

architecture struct of vcpu816 is

component control_unit is
	port(
		clk, nrst, irq, irq_en: in std_logic;
		data_bus: in std_logic_vector(7 downto 0);
		mux_sel: out integer range 0 to 5;
		alu_cmd: out integer range 0 to 9;
		reg_sel, tgt_sel: out integer range 0 to 3;
		rctl_cmd: out integer range 0 to 5;
		set_acc, set_alu_flags, set_offset, high_reg,
			use_offset, use_rel, set_addr, save_flags, set_res,
			write_mem, set_dis_irq, set_en_irq: out std_logic;
		bus_output: out std_logic_vector(7 downto 0)
	);
end component;

component alu is
	port(
		cmd: in integer range 0 to 9;
		a, b: in std_logic_vector(7 downto 0);
		carry_in: in std_logic;
		result: out std_logic_vector(7 downto 0);
		sign, carry_out, zero: out std_logic
	);
end component;

component rctl is
	port(
		clk, nrst, high: in std_logic;
		data_bus: in std_logic_vector(7 downto 0);
		reg_sel, target_sel: in integer range 0 to 3;
		cmd: in integer range 0 to 5;
		addr_back: in std_logic_vector(15 downto 0);
		addr: out std_logic_vector(15 downto 0);
		value: out std_logic_vector(7 downto 0)
	);
end component;

signal acc, res_reg, alu_res, rctl_out, cu_out,
	core_bus: std_logic_vector(7 downto 0);
signal rctl_addr, addr_buf, offset: std_logic_vector(15 downto 0);
signal f_sign, f_carry, f_zero, f_irq, f_res_sign,
	f_res_carry, f_res_zero, cmd_set_res, cmd_set_addr,
	cmd_set_flags, cmd_set_acc, cmd_high_reg, cmd_set_offset,
	cmd_use_offset, cmd_use_rel, cmd_set_alu_flags,
	cmd_set_regs, set_dis_irq, set_en_irq: std_logic;
signal mux_sel: integer range 0 to 5;
signal alu_cmd: integer range 0 to 9;
signal reg_sel, target_reg_sel: integer range 0 to 3;
signal rctl_cmd: integer range 0 to 4;

begin
	with mux_sel select core_bus <=
		cu_out when 0,
		din when 1,
		acc when 2,
		res_reg when 3,
		"0000" & (f_irq, f_sign, f_carry, f_zero) when 4,
		rctl_out when 5;
	
	cu: control_unit port map(
		clk => clk,
		nrst => nrst,
		irq => irq,
		irq_en => f_irq,
		data_bus => core_bus,
		mux_sel => mux_sel,
		alu_cmd => alu_cmd,
		reg_sel => reg_sel,
		tgt_sel => target_reg_sel,
		rctl_cmd => rctl_cmd,
		set_acc => cmd_set_acc,
		set_alu_flags => cmd_set_alu_flags,
		set_offset => cmd_set_offset,
		high_reg => cmd_high_reg,
		use_offset => cmd_use_offset,
		use_rel => cmd_use_rel,
		set_addr => cmd_set_addr,
		save_flags => cmd_set_flags,
		set_res => cmd_set_res,
		bus_output => cu_out,
		write_mem => write_mem,
		set_dis_irq => set_dis_irq,
		set_en_irq => set_en_irq
	);
	
	alu_inst: alu port map(
		cmd => alu_cmd,
		a => acc,
		b => core_bus,
		carry_in => f_carry,
		result => alu_res,
		sign => f_res_sign,
		carry_out => f_res_carry,
		zero => f_res_zero
	);
	
	rctl_inst: rctl port map(
		clk => clk,
		nrst => nrst,
		high => cmd_high_reg,
		data_bus => core_bus,
		reg_sel => reg_sel,
		target_sel => target_reg_sel,
		cmd => rctl_cmd,
		addr_back => addr_buf,
		addr => rctl_addr,
		value => rctl_out
	);
	
	upd_p: process(clk, nrst)
	begin
		if nrst = '0' then
			acc <= "00000000";
			f_sign <= '0';
			f_carry <= '0';
			f_zero <= '0';
			f_irq <= '0';
		elsif clk'event and clk = '1' then
			if cmd_set_acc = '1' then
				acc <= core_bus;
			end if;
			
			if cmd_set_addr = '1' then
				if cmd_use_offset = '1' and cmd_use_rel = '1' then
					addr_buf <= std_logic_vector(unsigned(rctl_addr) + unsigned(offset));
				elsif cmd_use_offset = '1' then
					addr_buf <= offset;
				elsif cmd_use_rel = '1' then
					addr_buf <= rctl_addr;
				end if;
			end if;
			
			if cmd_set_offset = '1' then
				if cmd_high_reg = '1' then
					offset <= core_bus & offset(7 downto 0);
				else
					offset <= "00000000" & core_bus;
				end if;
			end if;
			
			if cmd_set_res = '1' then
				res_reg <= alu_res;
			end if;
			
			if cmd_set_alu_flags = '1' then
				f_sign <= f_res_sign;
				f_carry <= f_res_carry;
				f_zero <= f_res_zero;
			end if;
			
			if set_dis_irq = '1' then
				f_irq <= '0';
			elsif set_en_irq = '1' then
				f_irq <= '1';
			end if;
		end if;
	end process;

	dout <= core_bus;
	addr <= addr_buf;
end;
