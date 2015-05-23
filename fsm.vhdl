library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm is
	port
	(
		clk : in std_logic;
		reset : in std_logic;
		
		prog_request : in std_logic;
		freq_select : in std_logic;
		counter_count : in std_logic_vector (3 downto 0);
		dcm_prog_done : in std_logic;
		
		shift_shen : out std_logic;
		shift_lden : out std_logic;
		shift_ldval : out std_logic_vector (9 downto 0);
		counter_reset : out std_logic;
		dcm_prog_en : out std_logic
	);
end fsm;

architecture behavioral of fsm is
	type state_type is 
	(
		sloadd1arg_prep, sloadd2arg_prep, sloaddarg, sloaddarg_to_sloadmarg_prep, 
		sloadmarg_prep, sloadmarg, sgo_prep, sgo, swaitprog, sidle
	);
	signal current_state, next_state : state_type := sidle;
	
	signal count_1x : std_logic;
	signal count_10x : std_logic;
	
	constant zeroarg : std_logic_vector (9 downto 0) := "0000000000";
	constant gocom : std_logic_vector (9 downto 0) := "0000000000";
	constant marg  : std_logic_vector (9 downto 0) := "0000000111";
	constant d1arg : std_logic_vector (9 downto 0) := "0011000101";
	constant d2arg : std_logic_vector (9 downto 0) := "0010011101";
begin

	--- ========================================================================
	--- NEXT STATE AND TIMER RESET TRANSITIONS
	--- ========================================================================

	process(clk, reset)
	begin
		if (reset = '1') then
			current_state <= sidle;
		elsif (rising_edge(clk)) then
			current_state <= next_state;
		end if;
	end process;
	
	--- ========================================================================
	--- COUNTER LOGIC
	--- ========================================================================
	
	process(clk, counter_count)
	begin
		if (counter_count = "0000") then
			count_1x <= '1';
		else
			count_1x <= '0';
		end if;
		
		if (counter_count = "1001") then
			count_10x <= '1';
		else
			count_10x <= '0';
		end if;
	end process;
	
	--- ========================================================================
	--- NEXT STATE LOGIC
	--- ========================================================================

	process
	(
		clk, current_state, next_state, 
		prog_request, freq_select, 
		counter_count, dcm_prog_done, 
		count_1x, count_10x
	)
	begin
		case current_state is
		
			when sloadd1arg_prep =>
				if (count_1x = '1') then
					next_state <= sloaddarg;
				else
					next_state <= sloadd1arg_prep;
				end if;
			
			when sloadd2arg_prep =>
				if (count_1x = '1') then
					next_state <= sloaddarg;
				else
					next_state <= sloadd2arg_prep;
				end if;
				
			when sloaddarg =>
				if (count_10x = '1') then
					next_state <= sloaddarg_to_sloadmarg_prep;
				else
					next_state <= sloaddarg;
				end if;
			
			when sloaddarg_to_sloadmarg_prep =>
				next_state <= sloadmarg_prep;
			
			when sloadmarg_prep =>
				if (count_1x = '1') then
					next_state <= sloadmarg;
				else
					next_state <= sloadmarg_prep;
				end if;
				
			when sloadmarg =>
				if (count_10x = '1') then
					next_state <= sgo_prep;
				else
					next_state <= sloadmarg;
				end if;
				
			when sgo_prep =>
				if (count_1x = '1') then
					next_state <= sgo;
				else
					next_state <= sgo_prep;
				end if;
				
			when sgo =>
				if (count_1x = '1') then
					next_state <= swaitprog;
				else
					next_state <= sgo;
				end if;
				
			when swaitprog =>
				if (dcm_prog_done = '1') then
					next_state <= sidle;
				else
					next_state <= swaitprog;
				end if;

			when sidle =>
				if (prog_request = '1' and freq_select = '0') then
					next_state <= sloadd1arg_prep;
				elsif (prog_request = '1' and freq_select = '1') then
					next_state <= sloadd2arg_prep;
				else
					next_state <= sidle;
				end if;
				
		end case;
	end process;
	
	--- ========================================================================
	--- NEXT OUTPUT LOGIC
	--- ========================================================================

	process
	(
		clk, current_state, next_state, 
		prog_request, freq_select, 
		counter_count, dcm_prog_done,
		count_1x, count_10x
	)
	begin
		case current_state is
			when sloadd1arg_prep =>
				shift_lden <= '1';
				shift_ldval <= d1arg;
				shift_shen <= '0';
				counter_reset <= '1';
				dcm_prog_en <= '0';
			when sloadd2arg_prep =>
				shift_lden <= '1';
				shift_ldval <= d2arg;
				shift_shen <= '0';
				counter_reset <= '1';
				dcm_prog_en <= '0';
			when sloaddarg =>
				shift_lden <= '0';
				shift_ldval <= zeroarg;
				shift_shen <= '1';
				counter_reset <= '0';
				dcm_prog_en <= '1';
			when sloaddarg_to_sloadmarg_prep =>
				shift_lden <= '0';
				shift_ldval <= zeroarg;
				shift_shen <= '0';
				counter_reset <= '0';
				dcm_prog_en <= '0';
			when sloadmarg_prep =>
				shift_lden <= '1';
				shift_ldval <= marg;
				shift_shen <= '0';
				counter_reset <= '1';
				dcm_prog_en <= '0';
			when sloadmarg =>
				shift_lden <= '0';
				shift_ldval <= zeroarg;
				shift_shen <= '1';
				counter_reset <= '0';
				dcm_prog_en <= '1';
			when sgo_prep =>
				shift_lden <= '1';
				shift_ldval <= gocom;
				shift_shen <= '0';
				counter_reset <= '1';
				dcm_prog_en <= '0';
			when sgo =>
				shift_lden <= '0';
				shift_ldval <= zeroarg;
				shift_shen <= '1';
				counter_reset <= '0';
				dcm_prog_en <= '1';
			when swaitprog =>
				shift_lden <= '0';
				shift_ldval <= zeroarg;
				shift_shen <= '0';
				counter_reset <= '0';
				dcm_prog_en <= '0';
			when sidle =>
				shift_lden <= '0';
				shift_ldval <= zeroarg;
				shift_shen <= '0';
				counter_reset <= '0';
				dcm_prog_en <= '0';
		end case;
	end process;
				
end behavioral;