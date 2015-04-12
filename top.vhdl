library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity top is
	port
	(
		clk_in : in std_logic;
		reset : in std_logic;
		
		prog_request : in std_logic;
		freq_select : in std_logic;
		
		clk_out : out std_logic;
		
		prog_done : out std_logic;
		locked : out std_logic
	);
end top;

architecture structural of top is

	component counter4
    port
	(
		clk : in STD_LOGIC;
		enable : in STD_LOGIC;
		reset : in STD_LOGIC;
		output : out STD_LOGIC_VECTOR (3 downto 0)
	);
	end component;
	
	component shiftreg10
    port
	(
		clk : in STD_LOGIC;
		shen : in STD_LOGIC;
		lden : in STD_LOGIC;
		ldval : in STD_LOGIC_VECTOR (9 downto 0);
		shout : out STD_LOGIC
	);
	end component;
	
	component fsm
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
	end component;

	signal prog_data_internal : std_logic;
	signal prog_en_internal : std_logic;
	
	signal clk_out_internal : std_logic;
	signal prog_done_internal : std_logic;
	signal locked_internal : std_logic;
	
	signal shift_shen : std_logic;
	signal shift_lden : std_logic;
	signal shift_ldval : std_logic_vector (9 downto 0);
	signal counter_count : std_logic_vector (3 downto 0);
	signal counter_reset : std_logic;

begin

	clk_out <= clk_out_internal;
	prog_done <= prog_done_internal;
	locked <= locked_internal;
	
	DCM1: DCM_CLKGEN
	generic map
	(
		CLKFX_MULTIPLY => 2,
		CLKFX_DIVIDE => 40
	)
	port map
	(
		CLKIN => clk_in,
		CLKFX => clk_out_internal,
		PROGDATA => prog_data_internal,
		PROGEN => prog_en_internal,
		PROGCLK => clk_in,
		PROGDONE => prog_done_internal,
		LOCKED => locked_internal,
		RST => reset
	);
	
	CNT1: counter4
	port map
	(
		clk => clk_in,
		enable => '1',
		reset => counter_reset,
		output => counter_count
	);
	
	SR1: shiftreg10
	port map
	(
		clk => clk_in,
		shen => shift_shen,
		lden => shift_lden,
		ldval => shift_ldval,
		shout => prog_data_internal
	);
	
	FSM1: fsm
	port map
	(
		clk => clk_in,
		reset => reset,
		prog_request => prog_request,
		freq_select => freq_select,
		counter_count => counter_count,
		dcm_prog_done => prog_done_internal,
		shift_shen => shift_shen,
		shift_lden => shift_lden,
		shift_ldval => shift_ldval,
		counter_reset => counter_reset,
		dcm_prog_en => prog_en_internal
	);

end structural;	