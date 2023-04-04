-- Copyright (C) 2016  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Intel and sold by Intel or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 16.1.0 Build 196 10/24/2016 SJ Lite Edition"
-- CREATED		"Tue Feb 09 13:35:47 2021"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY multifunctional_digital_watch IS 
	PORT
	(
		CLOCK_50 :  IN  STD_LOGIC;
		KEY :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		SW :  IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		GPIO_0 :  OUT  STD_LOGIC_VECTOR(0 DOWNTO 0);
		HEX0 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX1 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX2 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX3 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX4 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX5 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END multifunctional_digital_watch;

ARCHITECTURE bdf_type OF multifunctional_digital_watch IS

COMPONENT currenttime
	PORT(clock : IN STD_LOGIC;
		 clock1Hz : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 set : IN STD_LOGIC;
		 increment : IN STD_LOGIC;
		 decrement : IN STD_LOGIC;
		 hour0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 hour1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 minute0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 minute1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 second0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 second1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alarm
	PORT(clock : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 set : IN STD_LOGIC;
		 increment : IN STD_LOGIC;
		 decrement : IN STD_LOGIC;
		 alarm_enable : IN STD_LOGIC;
		 currentTime_hour0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 currentTime_hour1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 currentTime_minute0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 currentTime_minute1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 alarm_buzzer : OUT STD_LOGIC;
		 alarm_hour0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 alarm_hour1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 alarm_minute0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 alarm_minute1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 alarm_onoff : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT bcd7s
	PORT(input_BCD : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 output_7s : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END COMPONENT;

COMPONENT inputfsm
	PORT(TASTER1 : IN STD_LOGIC;
		 TASTER2 : IN STD_LOGIC;
		 TASTER3 : IN STD_LOGIC;
		 mode : IN STD_LOGIC;
		 set : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 inactiveFor10s : IN STD_LOGIC;
		 disableMode : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 stopwatchInactive : IN STD_LOGIC;
		 currentTime_set : OUT STD_LOGIC;
		 currentTime_increment : OUT STD_LOGIC;
		 currentTime_decrement : OUT STD_LOGIC;
		 alarm_set : OUT STD_LOGIC;
		 alarm_increment : OUT STD_LOGIC;
		 alarm_decrement : OUT STD_LOGIC;
		 stopwatch_start : OUT STD_LOGIC;
		 stopwatch_clear : OUT STD_LOGIC;
		 timer_set : OUT STD_LOGIC;
		 timer_increment : OUT STD_LOGIC;
		 timer_decrement : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT buzzcontroller
	PORT(clock : IN STD_LOGIC;
		 clock1kHz : IN STD_LOGIC;
		 clock1Hz : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 mode : IN STD_LOGIC;
		 AlarmBuzzer : IN STD_LOGIC;
		 TimerBuzzer : IN STD_LOGIC;
		 Buzz : OUT STD_LOGIC;
		 ModeDisable : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT buttonpresscircuit
	PORT(clock : IN STD_LOGIC;
		 alarmSwitch : IN STD_LOGIC;
		 taster0 : IN STD_LOGIC;
		 taster1 : IN STD_LOGIC;
		 taster2 : IN STD_LOGIC;
		 taster3 : IN STD_LOGIC;
		 alarmSwitchOutput : OUT STD_LOGIC;
		 taster0Output : OUT STD_LOGIC;
		 taster1Output : OUT STD_LOGIC;
		 taster2Output : OUT STD_LOGIC;
		 taster3Output : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT timer
	PORT(clock : IN STD_LOGIC;
		 clock1Hz : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 set : IN STD_LOGIC;
		 increment : IN STD_LOGIC;
		 decrement : IN STD_LOGIC;
		 timer_buzzer : OUT STD_LOGIC;
		 hour0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 hour1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 minute0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 minute1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 second0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 second1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT stopwatch
	PORT(clock : IN STD_LOGIC;
		 clock100Hz : IN STD_LOGIC;
		 start_stop : IN STD_LOGIC;
		 clear : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 hundert0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 hundert1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 minute0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 minute1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 second0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 second1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT timer10s
	PORT(reset : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 clockEnable : IN STD_LOGIC;
		 TASTER0 : IN STD_LOGIC;
		 TASTER1 : IN STD_LOGIC;
		 TASTER2 : IN STD_LOGIC;
		 TASTER3 : IN STD_LOGIC;
		 inactiveFor10s : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT outputfsm
	PORT(clock : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 mode : IN STD_LOGIC;
		 set : IN STD_LOGIC;
		 clock1Hz : IN STD_LOGIC;
		 inactiveFor10s : IN STD_LOGIC;
		 disableMode : IN STD_LOGIC;
		 alarm_hour0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 alarm_hour1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 alarm_minute0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 alarm_minute1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 alarm_onoff : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 currentTime_hour0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 currentTime_hour1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 currentTime_minute0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 currentTime_minute1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 currentTime_second0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 currentTime_second1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 stopwatch_hunderth0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 stopwatch_hunderth1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 stopwatch_minute0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 stopwatch_minute1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 stopwatch_second0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 stopwatch_second1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 timer_hour0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 timer_hour1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 timer_minute0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 timer_minute1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 timer_second0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 timer_second1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 stopWatchInactive : OUT STD_LOGIC;
		 toDisplay0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 toDisplay1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 toDisplay2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 toDisplay3 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 toDisplay4 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 toDisplay5 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT frequency_divider
	PORT(clk : IN STD_LOGIC;
		 clk1Hz : OUT STD_LOGIC;
		 clk100Hz : OUT STD_LOGIC;
		 clk1kHz : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	s_alarmBuzzer :  STD_LOGIC;
SIGNAL	s_clock :  STD_LOGIC;
SIGNAL	s_clock1Hz :  STD_LOGIC;
SIGNAL	s_disableMode :  STD_LOGIC;
SIGNAL	s_hour0 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	s_hour1 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	s_minute0 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	s_minute1 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	s_mode :  STD_LOGIC;
SIGNAL	s_reset :  STD_LOGIC;
SIGNAL	s_set :  STD_LOGIC;
SIGNAL	s_stopwatchInactive :  STD_LOGIC;
SIGNAL	s_timerBuzzer :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_45 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_46 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_47 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_24 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_25 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_26 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_27 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_28 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_29 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_30 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_31 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_32 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_33 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_34 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_35 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_36 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_37 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_38 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_39 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_40 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_41 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_42 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_43 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_44 :  STD_LOGIC_VECTOR(3 DOWNTO 0);


BEGIN 



b2v_inst : currenttime
PORT MAP(clock => s_clock,
		 clock1Hz => s_clock1Hz,
		 reset => s_reset,
		 set => SYNTHESIZED_WIRE_0,
		 increment => SYNTHESIZED_WIRE_1,
		 decrement => SYNTHESIZED_WIRE_2,
		 hour0 => s_hour0,
		 hour1 => s_hour1,
		 minute0 => s_minute0,
		 minute1 => s_minute1,
		 second0 => SYNTHESIZED_WIRE_29,
		 second1 => SYNTHESIZED_WIRE_30);


b2v_inst1 : alarm
PORT MAP(clock => s_clock,
		 reset => s_reset,
		 set => SYNTHESIZED_WIRE_3,
		 increment => SYNTHESIZED_WIRE_4,
		 decrement => SYNTHESIZED_WIRE_5,
		 alarm_enable => SYNTHESIZED_WIRE_6,
		 currentTime_hour0 => s_hour0,
		 currentTime_hour1 => s_hour1,
		 currentTime_minute0 => s_minute0,
		 currentTime_minute1 => s_minute1,
		 alarm_buzzer => s_alarmBuzzer,
		 alarm_hour0 => SYNTHESIZED_WIRE_24,
		 alarm_hour1 => SYNTHESIZED_WIRE_25,
		 alarm_minute0 => SYNTHESIZED_WIRE_26,
		 alarm_minute1 => SYNTHESIZED_WIRE_27,
		 alarm_onoff => SYNTHESIZED_WIRE_28);


b2v_inst10 : bcd7s
PORT MAP(input_BCD => SYNTHESIZED_WIRE_7,
		 output_7s => HEX2);


b2v_inst11 : bcd7s
PORT MAP(input_BCD => SYNTHESIZED_WIRE_8,
		 output_7s => HEX3);


b2v_inst12 : bcd7s
PORT MAP(input_BCD => SYNTHESIZED_WIRE_9,
		 output_7s => HEX4);


b2v_inst13 : bcd7s
PORT MAP(input_BCD => SYNTHESIZED_WIRE_10,
		 output_7s => HEX5);


b2v_inst14 : inputfsm
PORT MAP(TASTER1 => s_set,
		 TASTER2 => SYNTHESIZED_WIRE_45,
		 TASTER3 => SYNTHESIZED_WIRE_46,
		 mode => s_mode,
		 set => s_set,
		 reset => s_reset,
		 inactiveFor10s => SYNTHESIZED_WIRE_47,
		 disableMode => s_disableMode,
		 clock => s_clock,
		 stopwatchInactive => s_stopwatchInactive,
		 currentTime_set => SYNTHESIZED_WIRE_0,
		 currentTime_increment => SYNTHESIZED_WIRE_1,
		 currentTime_decrement => SYNTHESIZED_WIRE_2,
		 alarm_set => SYNTHESIZED_WIRE_3,
		 alarm_increment => SYNTHESIZED_WIRE_4,
		 alarm_decrement => SYNTHESIZED_WIRE_5,
		 stopwatch_start => SYNTHESIZED_WIRE_19,
		 stopwatch_clear => SYNTHESIZED_WIRE_20,
		 timer_set => SYNTHESIZED_WIRE_15,
		 timer_increment => SYNTHESIZED_WIRE_16,
		 timer_decrement => SYNTHESIZED_WIRE_17);


b2v_inst15 : buzzcontroller
PORT MAP(clock => s_clock,
		 clock1kHz => SYNTHESIZED_WIRE_14,
		 clock1Hz => s_clock1Hz,
		 reset => s_reset,
		 mode => s_mode,
		 AlarmBuzzer => s_alarmBuzzer,
		 TimerBuzzer => s_timerBuzzer,
		 Buzz => GPIO_0(0),
		 ModeDisable => s_disableMode);


b2v_inst16 : buttonpresscircuit
PORT MAP(clock => s_clock,
		 alarmSwitch => SW(0),
		 taster0 => KEY(0),
		 taster1 => KEY(1),
		 taster2 => KEY(2),
		 taster3 => KEY(3),
		 alarmSwitchOutput => SYNTHESIZED_WIRE_6,
		 taster0Output => s_mode,
		 taster1Output => s_set,
		 taster2Output => SYNTHESIZED_WIRE_45,
		 taster3Output => SYNTHESIZED_WIRE_46);


b2v_inst2 : timer
PORT MAP(clock => s_clock,
		 clock1Hz => s_clock1Hz,
		 reset => s_reset,
		 set => SYNTHESIZED_WIRE_15,
		 increment => SYNTHESIZED_WIRE_16,
		 decrement => SYNTHESIZED_WIRE_17,
		 timer_buzzer => s_timerBuzzer,
		 hour0 => SYNTHESIZED_WIRE_37,
		 hour1 => SYNTHESIZED_WIRE_38,
		 minute0 => SYNTHESIZED_WIRE_39,
		 minute1 => SYNTHESIZED_WIRE_40,
		 second0 => SYNTHESIZED_WIRE_41,
		 second1 => SYNTHESIZED_WIRE_42);


b2v_inst3 : stopwatch
PORT MAP(clock => s_clock,
		 clock100Hz => SYNTHESIZED_WIRE_18,
		 start_stop => SYNTHESIZED_WIRE_19,
		 clear => SYNTHESIZED_WIRE_20,
		 reset => s_reset,
		 hundert0 => SYNTHESIZED_WIRE_31,
		 hundert1 => SYNTHESIZED_WIRE_32,
		 minute0 => SYNTHESIZED_WIRE_33,
		 minute1 => SYNTHESIZED_WIRE_34,
		 second0 => SYNTHESIZED_WIRE_35,
		 second1 => SYNTHESIZED_WIRE_36);


b2v_inst4 : timer10s
PORT MAP(reset => s_reset,
		 clock => s_clock,
		 clockEnable => s_clock1Hz,
		 TASTER0 => s_mode,
		 TASTER1 => s_set,
		 TASTER2 => SYNTHESIZED_WIRE_45,
		 TASTER3 => SYNTHESIZED_WIRE_46,
		 inactiveFor10s => SYNTHESIZED_WIRE_47);


b2v_inst5 : outputfsm
PORT MAP(clock => s_clock,
		 reset => s_reset,
		 mode => s_mode,
		 set => s_set,
		 clock1Hz => s_clock1Hz,
		 inactiveFor10s => SYNTHESIZED_WIRE_47,
		 disableMode => s_disableMode,
		 alarm_hour0 => SYNTHESIZED_WIRE_24,
		 alarm_hour1 => SYNTHESIZED_WIRE_25,
		 alarm_minute0 => SYNTHESIZED_WIRE_26,
		 alarm_minute1 => SYNTHESIZED_WIRE_27,
		 alarm_onoff => SYNTHESIZED_WIRE_28,
		 currentTime_hour0 => s_hour0,
		 currentTime_hour1 => s_hour1,
		 currentTime_minute0 => s_minute0,
		 currentTime_minute1 => s_minute1,
		 currentTime_second0 => SYNTHESIZED_WIRE_29,
		 currentTime_second1 => SYNTHESIZED_WIRE_30,
		 stopwatch_hunderth0 => SYNTHESIZED_WIRE_31,
		 stopwatch_hunderth1 => SYNTHESIZED_WIRE_32,
		 stopwatch_minute0 => SYNTHESIZED_WIRE_33,
		 stopwatch_minute1 => SYNTHESIZED_WIRE_34,
		 stopwatch_second0 => SYNTHESIZED_WIRE_35,
		 stopwatch_second1 => SYNTHESIZED_WIRE_36,
		 timer_hour0 => SYNTHESIZED_WIRE_37,
		 timer_hour1 => SYNTHESIZED_WIRE_38,
		 timer_minute0 => SYNTHESIZED_WIRE_39,
		 timer_minute1 => SYNTHESIZED_WIRE_40,
		 timer_second0 => SYNTHESIZED_WIRE_41,
		 timer_second1 => SYNTHESIZED_WIRE_42,
		 stopWatchInactive => s_stopwatchInactive,
		 toDisplay0 => SYNTHESIZED_WIRE_43,
		 toDisplay1 => SYNTHESIZED_WIRE_44,
		 toDisplay2 => SYNTHESIZED_WIRE_7,
		 toDisplay3 => SYNTHESIZED_WIRE_8,
		 toDisplay4 => SYNTHESIZED_WIRE_9,
		 toDisplay5 => SYNTHESIZED_WIRE_10);


b2v_inst6 : frequency_divider
PORT MAP(clk => s_clock,
		 clk1Hz => s_clock1Hz,
		 clk100Hz => SYNTHESIZED_WIRE_18,
		 clk1kHz => SYNTHESIZED_WIRE_14);


b2v_inst8 : bcd7s
PORT MAP(input_BCD => SYNTHESIZED_WIRE_43,
		 output_7s => HEX0);


b2v_inst9 : bcd7s
PORT MAP(input_BCD => SYNTHESIZED_WIRE_44,
		 output_7s => HEX1);

s_clock <= CLOCK_50;
s_reset <= SW(1);

s_reset <= SW(1);
END bdf_type;