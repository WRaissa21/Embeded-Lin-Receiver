--
-- VHDL Architecture LINReceiver_lib.EvnTest_InterfaceMicroprocesseur.TestbenchArchitecture
--
-- Created:
--          by - E24A503D.UNKNOWN (923-P-207955)
--          at - 17:10:47 10/09/2025
--
-- using Mentor Graphics HDL Designer(TM) 2022.1 Built on 21 Jan 2022 at 13:00:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY EvnTest_InterfaceMicroprocesseur IS
   GENERIC( 
      CLOCK_PERIOD   : time := 50 ns;
      RESET_OFFSET   : time := 500 ns;
      RESET_DURATION : time := 300 ns;
      ACCESS_TIME    : time := 40 ns;
      HOLD_TIME      : time := 70 ns
   );
   PORT( 
      M_Received : IN     std_logic;
      CnD        : OUT    std_logic;
      H          : OUT    std_logic;
      RnW        : OUT    std_logic;
      nCS        : OUT    std_logic;
      nRST       : OUT    std_logic;
      D07        : INOUT  std_logic_vector (7 DOWNTO 0)
   );

-- Declarations

END EvnTest_InterfaceMicroprocesseur ;

--
ARCHITECTURE TestbenchArchitecture OF EvnTest_InterfaceMicroprocesseur IS
TYPE DefState IS (Waiting, DataReading, StateReading, FilterWriting);

SIGNAL ProcessorState : DefState;

BEGIN
  
ClockGeneratorProc : PROCESS
BEGIN
  H <= '0';
  WAIT FOR CLOCK_PERIOD/2;
  H <= '1';
  WAIT FOR CLOCK_PERIOD/2;
END PROCESS ClockGeneratorProc;

ResetGeneratorProc : PROCESS
BEGIN
  nRST <= '1';
  WAIT FOR RESET_OFFSET;
  nRST <= '0';
  WAIT FOR RESET_DURATION;
  nRST <= '1';
  WAIT;
END PROCESS ResetGeneratorProc;

ProcessorBehaviorProc : PROCESS
BEGIN
  D07 <= (others => 'Z');
--Waiting cycle--
  ProcessorState <= Waiting;
  nCS <= '1';
  CnD <= '1';
  RnW <= '1';
  WAIT FOR RESET_OFFSET+RESET_DURATION+2*CLOCK_PERIOD;    
--Reading data cycle--
  ProcessorState <= DataReading;
  WAIT FOR ACCESS_TIME;
  nCS <= '0';
  CnD <= '0';
  RnW <= '1';
  WAIT FOR 2*CLOCK_PERIOD;
--Waiting cycle--
  ProcessorState <= Waiting;
  nCS <= '1'; 
  CnD <= '1';
  RnW <= '1';
  WAIT FOR 2*CLOCK_PERIOD-ACCESS_TIME;
--Reading state cycle--
  ProcessorState <= StateReading;
  WAIT FOR ACCESS_TIME;
  nCS <= '0';
  CnD <= '1';
  RnW <= '1';
  WAIT FOR 2*CLOCK_PERIOD;
--Waiting cycle--
  ProcessorState <= Waiting;
  nCS <= '1';
  CnD <= '1';
  RnW <= '1';
  WAIT FOR 2*CLOCK_PERIOD-ACCESS_TIME;
--Writing cycle--
  ProcessorState <= FilterWriting;
  WAIT FOR ACCESS_TIME;
  nCS <= '0';
  CnD <= '0';
  RnW <= '0';
  D07 <= (others => '1');
  WAIT FOR 2*CLOCK_PERIOD;
--Waiting cycle--
  ProcessorState <= Waiting;
  nCS <= '1';
  CnD <= '1';
  RnW <= '1';
  WAIT FOR HOLD_TIME;
  D07 <= (others => 'Z');
  WAIT;
END PROCESS ProcessorBehaviorProc;

--END ARCHITECTURE arch;

END ARCHITECTURE TestbenchArchitecture;

