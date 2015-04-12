LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY top_tb IS
END top_tb;
 
ARCHITECTURE behavior OF top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT top
		PORT 
		(
			clk_in : IN  std_logic;
			reset : IN  std_logic;
			prog_request : IN  std_logic;
			freq_select : IN  std_logic;
			clk_out : OUT  std_logic;
			prog_done : OUT  std_logic;
			locked : OUT  std_logic
		);
    END COMPONENT;
    
	--Inputs
	signal clk_in : std_logic := '0';
	signal reset : std_logic := '1';
	signal prog_request : std_logic := '0';
	signal freq_select : std_logic := '0';
	
 	--Outputs
   signal clk_out : std_logic;
   signal prog_done : std_logic;
   signal locked : std_logic;
   
   -- Clock period definitions
   constant clk_period : time := 10 ns;
   
   	-- Delay definitions
	constant res_delay : time := 10 * clk_period;
	constant std_delay : time := 50 * clk_period;
	
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: top 
		PORT MAP (
			clk_in => clk_in,
			reset => reset,
			prog_request => prog_request,
			freq_select => freq_select,
			clk_out => clk_out,
			prog_done => prog_done,
			locked => locked
		);

	-- Clock process definitions
	clk_process: process
	begin
		clk_in <= '0';
		wait for clk_period/2;
		clk_in <= '1';
		wait for clk_period/2;
	end process;

	-- Stimulus process
	stim_proc: process
	begin
		-- Reset Circuit
		reset <= '1';
		wait for res_delay;	
		reset <= '0';
		wait for res_delay;
		
		freq_select <= '0';
		prog_request <= '1';
		wait for clk_period;
		prog_request <= '0';
		wait for 3*std_delay;
		
		freq_select <= '1';
		prog_request <= '1';
		wait for clk_period;
		prog_request <= '0';
		wait for 3*std_delay;
		
		wait;
	end process;

END;