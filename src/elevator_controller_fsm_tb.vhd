--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : MooreElevatorController_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner, Capt Dan Johnson, **Your Name Here**
--| CREATED       : 03/2017 Last modified on 06/24/2020
--| DESCRIPTION   : This file tests the Moore elevator controller module
--|
--| DOCUMENTATION : None
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std, unisim
--|    Files     : MooreElevatorController.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
 
entity elevator_controller_fsm_tb is
end elevator_controller_fsm_tb;

architecture test_bench of elevator_controller_fsm_tb is 
	
	component elevator_controller_fsm is
		Port ( i_clk 	 : in  STD_LOGIC;
			   i_reset 	 : in  STD_LOGIC; -- synchronous
			   is_stopped 	 : in  STD_LOGIC;
			   go_up_down : in  STD_LOGIC;
			   o_floor 	 : out STD_LOGIC_VECTOR (3 downto 0));
	end component elevator_controller_fsm;
	
	-- test signals
	signal w_clk, w_reset, w_stop, w_up_down : std_logic := '0';
	signal w_floor : std_logic_vector(3 downto 0) := (others => '0');
  
	-- 50 MHz clock
	constant k_clk_period : time := 2000 ns;
	
begin
	-- PORT MAPS ----------------------------------------

	uut_inst : elevator_controller_fsm port map (
		i_clk     => w_clk,
		i_reset   => w_reset,
		is_stopped    => w_stop,
		go_up_down => w_up_down,
		o_floor   => w_floor
	);
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------
	
	-- Clock Process ------------------------------------
	clk_process : process
	begin
		w_clk <= '0';
		wait for k_clk_period/2;
		
		w_clk <= '1';
		wait for k_clk_period/2;
	end process clk_process;
	
	
	-- Test Plan Process --------------------------------
	test_process : process 
	begin
	   -- offset to allow for prop delays
	   wait until falling_edge(w_clk);
        -- i_reset into initial state (o_floor 2)
        w_reset <= '1';  wait for k_clk_period; 
        -- clear reset
        w_reset <= '0';
		-- active UP signal
		w_up_down <= '1'; 
		
		-- go up a floor
        w_stop <= '0';  wait for k_clk_period;
		-- try waiting on a floor
        w_stop <= '1';  wait for k_clk_period * 2;
        --  go up again
		w_stop <= '0';
		w_up_down <= '1'; wait for k_clk_period;
		
		-- go back down one floor
		w_up_down <= '0'; wait for k_clk_period;
		
		-- go up the rest of the way
		w_up_down <= '1'; wait for k_clk_period * 7;

		
		-- stop at top
		w_stop <= '1';
		w_up_down <= '0'; wait for k_clk_period;

        
        -- go all the way down DOWN 
        w_stop <= '0';  wait for k_clk_period * 10;
  
	end process;	
	-----------------------------------------------------	
	
end test_bench;
