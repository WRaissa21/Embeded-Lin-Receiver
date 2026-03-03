--
-- VHDL Architecture operative_part_lib.command_unit.arch
--
-- Created:
--          by - e229154f.UNKNOWN (923-P-209517)
--          at - 10:04:33 23/09/2025
--
-- using Mentor Graphics HDL Designer(TM) 2022.1 Built on 21 Jan 2022 at 13:00:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY command_unit IS
   PORT( 
      H            : IN     std_logic;
      LinSynchro   : IN     std_logic;
      NbBit_0      : IN     std_logic;
      nCLR         : IN     std_logic;
      n_0          : IN     std_logic;
      DataFieldNb_0:	IN	    std_logic;
      SelAdr       :	IN	    std_logic_vector (7 DOWNTO 0);
      NbBit_EN     : OUT    std_logic;
      NbBit_LOAD   : OUT    std_logic;
      NbBit_SELECT : OUT    std_logic;
      n_EN         : OUT    std_logic;
      n_LOAD       : OUT    std_logic;
      n_SELECT     : OUT    std_logic;
      RecByte_EN   : OUT    std_logic;
      IdentifierField_EN	 : OUT	std_logic;
      DataFieldNb_EN      : OUT	std_logic;
      DataFieldNb_Load    : OUT	std_logic;
      Error_synchro	      : OUT	std_logic;
      Error_start         : OUT	std_logic;
      Error_stop          : OUT	std_logic;
      NbByteInc	          : OUT	std_logic;
      MessageReceived_SET :	OUT	std_logic;
      NbRecByte_RST	      : OUT	std_logic;
      RecByte_WR	         : OUT	std_logic;
      RecByte_RST	        : OUT	std_logic
   );

-- Declarations       -- gestion des erreurs n est pas enocre faite

END command_unit ;

--
ARCHITECTURE arch OF command_unit IS
  
  type states is (
                  WAITING,
                  
                  RECEP_SYNC_BREAK_0,
                  RECEP_SYNC_BREAK_1,
                  
                  SYNCH_FIELD_WAIT,
                  SYNCH_FIELD_START,
                  SYNCH_FIELD_DATA,
                  SYNCH_FIELD_STOP,
                  
                  ID_FIELD_WAIT,
                  ID_FIELD_START,
                  ID_FIELD_DATA,
                  ID_FIELD_STOP,
                  
                  FRAME_FIELD_WAIT,
                  FRAME_FIELD_START,
                  FRAME_FIELD_DATA,
                  FRAME_FIELD_STOP,
                  
                  CHECKSUM_FIELD_WAIT,
                  CHECKSUM_FIELD_START,
                  CHECKSUM_FIELD_DATA,
                  CHECKSUM_FIELD_STOP
                  );

  signal NextState, CurrentState: states := WAITING;
  
BEGIN
  
StateRegisterP: process(H) is -- Reset and update
begin
    RecByte_RST <= '0';
    NbRecByte_RST <= '0';
    if rising_edge(H) then
        if nCLR = '0' then
            CurrentState <= WAITING;
            RecByte_RST <= '1';
            NbRecByte_RST <= '1';
        else
            CurrentState <= NextState;
        end if;
    end if;
end process StateRegisterP;

OutputP: process(CurrentState,LinSynchro,n_0,NbBit_0) is  -- for every state set output
begin
  
    NbBit_EN <= '0';  
    NbBit_LOAD <= '0';
    NbBit_SELECT <= '0';
    n_EN <= '0';  
    n_LOAD <= '0';  
    n_SELECT <= '0';
    RecByte_EN <= '0';
    Error_synchro <= '0';
    Error_start <= '0';
    Error_stop <= '0';
    IdentifierField_EN <= '0';
    DataFieldNb_EN <= '0';
    DataFieldNb_Load <= '0';
    NbByteInc <= '0';
    MessageReceived_SET <= '0';
    RecByte_WR <= '0';

    case CurrentState is
      
        when WAITING =>
          
          if LinSynchro = '0' then
            NbBit_EN <= '1';  
            NbBit_LOAD <= '1';
            n_EN <= '1';  
            n_LOAD <= '1';  
          end if;
 
        when RECEP_SYNC_BREAK_0 =>

          if (LinSynchro = '0') and (NbBit_0 = '0') then  -- connection à jour et décompteur synchro en cours (pas encore compté 13 bits)
            if (n_0 = '0') then   -- continue de compter jusqu à 2000
              n_EN <= '1';
            
            else -- (n_0 = '1') on a compté jusqu à 2000, on retire 1 au 13 bits
              NbBit_EN <= '1';
              n_EN <= '1';
              n_LOAD <= '1';
            end if;
 
          end if;
          
      when RECEP_SYNC_BREAK_1 =>
        if LinSynchro = '0' then -- on a cassé la com lin
          Error_synchro <= '1';
        
        elsif n_0 = '0' then -- on n a pas cassé la com lin mais on a toujours pas compté le temps d un bit
          n_EN <= '1';
          
        -- sinon rien à faire dans le cas d un changement d état
        
        end if;
      
      ------------------------------------------------------------- Synchronization
      when SYNCH_FIELD_WAIT =>
          if LinSynchro = '0' then  -- la com est réinitialisée
            n_SELECT <= '1';
            n_LOAD <= '1';
            n_EN <= '1';
          end if;
          
      when SYNCH_FIELD_START =>
        if (LinSynchro = '0') then
          if (n_0 = '1') then -- fin du start sans erreur
            n_EN <= '1';
            NbBit_SELECT <= '1';
            NbBit_EN <= '1';
            NbBit_LOAD <= '1';
            
            n_SELECT <= '0';
            n_LOAD <= '1';
            n_EN <= '1';
          else                -- continue le start
            n_EN <= '1';
        end if;
          
        elsif (LinSynchro = '1') then -- error
          Error_start <= '1';
        end if;
         
      when SYNCH_FIELD_DATA =>
        if (n_0 = '1') then
          if (NbBit_0 = '1') then
            -- reset le compteur
            n_SELECT <= '0';
            n_LOAD <= '1';
            n_EN <= '1';
            
            RecByte_EN <= '1'; -- on lit le bit
          else
            -- reset le compteur
            n_SELECT <= '0';
            n_LOAD <= '1';
            n_EN <= '1';
            
            RecByte_EN <= '1'; -- on lit le bit
            NbBit_EN <= '1'; -- décompte nombre de bits
          end if;
          
        else
          n_EN <= '1';
            
        end if;
          
      when SYNCH_FIELD_STOP =>
        if (n_0 = '1') then
          if (LinSynchro = '1') then
            RecByte_WR <= '1';
          else  -- n_0 = '1'
            Error_stop <= '1';
          end if;
        
        else
          n_EN <= '1';
        end if;
              
      ------------------------------------------------------------- Identifier
      when ID_FIELD_WAIT =>
          if LinSynchro = '0' then  -- la com est réinitialisée
            n_SELECT <= '1';
            n_LOAD <= '1';
            n_EN <= '1';
          end if;
          
      when ID_FIELD_START =>
        if (LinSynchro = '0') then
          if (n_0 = '1') then -- fin du start sans erreur
            n_EN <= '1';
            NbBit_SELECT <= '1';
            NbBit_EN <= '1';
            NbBit_LOAD <= '1';
            
            n_SELECT <= '0';
            n_LOAD <= '1';
            n_EN <= '1';
          else                -- continue le start
            n_EN <= '1';
        end if;
          
        elsif (LinSynchro = '1') then -- error
          Error_start <= '1';
        end if;
         
      when ID_FIELD_DATA =>
        if (n_0 = '1') then
          if (NbBit_0 = '1') then
            -- reset le compteur
            n_SELECT <= '0';
            n_LOAD <= '1';
            n_EN <= '1';
            
            RecByte_EN <= '1'; -- on lit le bit
          else
            -- reset le compteur
            n_SELECT <= '0';
            n_LOAD <= '1';
            n_EN <= '1';
            
            RecByte_EN <= '1'; -- on lit le bit
            NbBit_EN <= '1'; -- décompte nombre de bits
          end if;
          
        else
          n_EN <= '1';
            
        end if;
          
      when ID_FIELD_STOP =>
        if (n_0 = '1') then
          if (LinSynchro = '1') then
            RecByte_WR <= '1';
            IdentifierField_EN <= '1';
            
            -- load le nombre d octets à lire
            DataFieldNb_Load <= '1';
            DataFieldNb_EN <= '1';
          else  -- n_0 = '1'
            Error_stop <= '1';
          end if;
        
        else
          n_EN <= '1';
        end if;
        
      ------------------------------------------------------------- Frame reception
      when FRAME_FIELD_WAIT =>
          if LinSynchro = '0' then  -- la com est réinitialisée
            n_SELECT <= '1';
            n_LOAD <= '1';
            n_EN <= '1';
          end if;
          
      when FRAME_FIELD_START =>
        if (LinSynchro = '0') then
          if (n_0 = '1') then -- fin du start sans erreur
            NbBit_SELECT <= '1';
            NbBit_EN <= '1';
            NbBit_LOAD <= '1';
            
            n_SELECT <= '0';
            n_LOAD <= '1';
            n_EN <= '1';
          else                -- continue le start
            n_EN <= '1';
        end if;
          
        elsif (LinSynchro = '1') then -- error
          Error_start <= '1';
        end if;
         
      when FRAME_FIELD_DATA =>
        if (n_0 = '1') then
          if (NbBit_0 = '1') then
            -- reset le compteur
            n_SELECT <= '0';
            n_LOAD <= '1';
            n_EN <= '1';
            
            RecByte_EN <= '1'; -- on lit le dernier bit
          else
            -- reset le compteur
            n_SELECT <= '0';
            n_LOAD <= '1';
            n_EN <= '1';
            
            RecByte_EN <= '1'; -- on lit le bit
            NbBit_EN <= '1'; -- décompte nombre de bits
          end if;
          
        else
          n_EN <= '1';
            
        end if;
          
      when FRAME_FIELD_STOP =>
          if (n_0 = '1') then -- fini de décompter
            if (LinSynchro = '1') then  -- communication pas brisée
              if (DataFieldNb_0 = '1') then --fini de recevoir tous les bits de la trame
                RecByte_WR <= '1';
                NbByteInc <= '1';
              else
                DataFieldNb_EN <= '1';
                RecByte_WR <= '1';
                NbByteInc <= '1';
              end if;
            elsif (LinSynchro = '0') then
              Error_stop <= '1';
            end if;
          else
            n_EN <= '1';
          end if;
      
      ------------------------------------------------------------- Checksum
      when CHECKSUM_FIELD_WAIT =>
          if LinSynchro = '0' then  -- la com est réinitialisée
            n_SELECT <= '1';
            n_LOAD <= '1';
            n_EN <= '1';
          end if;
          
      when CHECKSUM_FIELD_START =>
        if (LinSynchro = '0') then
          if (n_0 = '1') then -- fin du start sans erreur
            n_EN <= '1';
            NbBit_SELECT <= '1';
            NbBit_EN <= '1';
            NbBit_LOAD <= '1';
            
            n_SELECT <= '0';
            n_LOAD <= '1';
            n_EN <= '1';
          else                -- continue le start
            n_EN <= '1';
        end if;
          
        elsif (LinSynchro = '1') then -- error
          Error_start <= '1';
        end if;
         
      when CHECKSUM_FIELD_DATA =>
        if (n_0 = '1') then
          if (NbBit_0 = '1') then
            -- reset le compteur
            n_SELECT <= '0';
            n_LOAD <= '1';
            n_EN <= '1';
            
            RecByte_EN <= '1'; -- on lit le bit
          else
            -- reset le compteur
            n_SELECT <= '0';
            n_LOAD <= '1';
            n_EN <= '1';
            
            RecByte_EN <= '1'; -- on lit le bit
            NbBit_EN <= '1'; -- décompte nombre de bits
          end if;
          
        else
          n_EN <= '1';
            
        end if;
          
      when CHECKSUM_FIELD_STOP =>
        if (n_0 = '1') then
          if (LinSynchro = '1') then
            RecByte_WR <= '1';
            IdentifierField_EN <= '1';
            
            -- load le nombre d octets à lire
            DataFieldNb_Load <= '1';
            DataFieldNb_EN <= '1';
          else  -- n_0 = '1'
            Error_stop <= '1';
          end if;
        
        else
          n_EN <= '1';
        end if;
        
      ------------------------------------------------------------- END Output P
      when others =>
         null;
         
    end case;
end process OutputP;
 
NextStateP: process(CurrentState, LinSynchro, n_0) is  -- compute next state
begin
    NextState <= CurrentState; --default values
 
    case CurrentState is
      
        when WAITING =>
          
          if LinSynchro = '0' then
            NextState <= RECEP_SYNC_BREAK_0;
          end if;
 
        when RECEP_SYNC_BREAK_0 =>
          
          if (linSynchro = '1') then
            if (NbBit_0 = '0') then
              NextState <= WAITING;
          
            else  -- NbBit_0 = 1
              NextState <= RECEP_SYNC_BREAK_1;
              
            end if;
 
          elsif (LinSynchro = '0') then
            NextState <= RECEP_SYNC_BREAK_0;
            
          end if;
          
        when RECEP_SYNC_BREAK_1 =>
          if LinSynchro = '0' then  -- on a cassé la com lin
            NextState <= WAITING; -- retour en wating de base
        
          elsif n_0 = '1' then      -- com pas cassée et un bit vient de passer
            NextState <= SYNCH_FIELD_WAIT;
          
          -- sinon on reste dans cet état
        
          end if;
        
        ------------------------------------------------------------- Synchronization
        when SYNCH_FIELD_WAIT =>
          if LinSynchro = '0' then  -- la com est réinitialisée
            NextState <= SYNCH_FIELD_START;
          end if;
          
        when SYNCH_FIELD_START =>
          if (n_0 = '1') and (LinSynchro = '0') then  -- la com est réinitialisée
            NextState <= SYNCH_FIELD_DATA;
            
          elsif (LinSynchro = '1') then -- error
            NextState <= WAITING; -- retour en wating de base
          end if;
          
        when SYNCH_FIELD_DATA =>
          if (n_0 = '1') and (NbBit_0 = '1') then
            NextState <= SYNCH_FIELD_STOP;
          end if;
          
        when SYNCH_FIELD_STOP =>
          if (n_0 = '1') then
            if (LinSynchro = '1') then
              NextState <= ID_FIELD_WAIT;
            else
              NextState <= WAITING;
            end if;
          end if;
        
        ------------------------------------------------------------- Identifier
        when ID_FIELD_WAIT =>
          if LinSynchro = '0' then  -- la com est réinitialisée
            NextState <= ID_FIELD_START;
          end if;
          
        when ID_FIELD_START =>
          if (n_0 = '1') and (LinSynchro = '0') then  -- la com est réinitialisée
            NextState <= ID_FIELD_DATA;
            
          elsif (LinSynchro = '1') then -- error
            NextState <= WAITING; -- retour en wating de base
          end if;
          
        when ID_FIELD_DATA =>
          if (n_0 = '1') and (NbBit_0 = '1') then
            NextState <= ID_FIELD_STOP;
          end if;
          
        when ID_FIELD_STOP =>
          if (n_0 = '1') then
            if (LinSynchro = '1') then
              NextState <= FRAME_FIELD_WAIT;
            else
              NextState <= WAITING;
            end if;
          end if;
        
        ------------------------------------------------------------- Frame Reception
        when FRAME_FIELD_WAIT =>
          if LinSynchro = '0' then  -- la com est réinitialisée
            NextState <= FRAME_FIELD_START;
          end if;
          
        when FRAME_FIELD_START =>
          if (n_0 = '1') and (LinSynchro = '0') then  -- la com est réinitialisée
            NextState <= FRAME_FIELD_DATA;
            
          elsif (LinSynchro = '1') then -- error
            NextState <= WAITING; -- retour en wating de base
          end if;
          
        when FRAME_FIELD_DATA =>
          if (n_0 = '1') and (NbBit_0 = '1') then
            NextState <= FRAME_FIELD_STOP;
          end if;
          
        when FRAME_FIELD_STOP =>
          if (n_0 = '1') then -- 
            if (LinSynchro = '1') then
              if (DataFieldNb_0 = '1') then -- fini de lire les octets
                NextState <= CHECKSUM_FIELD_WAIT;
              else  -- pas fini de lire les octets
                NextState <= FRAME_FIELD_WAIT;
              end if;
            elsif (LinSynchro = '0') then
              NextState <= WAITING;
            end if;
          end if;
        
                
        ------------------------------------------------------------- Checksum
        when CHECKSUM_FIELD_WAIT =>
          if LinSynchro = '0' then  -- la com est réinitialisée
            NextState <= CHECKSUM_FIELD_START;
          end if;
          
        when CHECKSUM_FIELD_START =>
          if (n_0 = '1') and (LinSynchro = '0') then  -- la com est réinitialisée
            NextState <= CHECKSUM_FIELD_DATA;
            
          elsif (LinSynchro = '1') then -- error
            NextState <= WAITING; -- retour en wating de base
          end if;
          
        when CHECKSUM_FIELD_DATA =>
          if (n_0 = '1') and (NbBit_0 = '1') then
            NextState <= CHECKSUM_FIELD_STOP;
          end if;
          
        when CHECKSUM_FIELD_STOP =>
          if (n_0 = '1') then
            if (LinSynchro = '1') then
              -- 2 cases that leads to waiting?
              NextState <= CHECKSUM_FIELD_STOP; -- waiting normally
            else
              NextState <= CHECKSUM_FIELD_STOP; -- waiting normally
            end if;
          end if;
        
        ------------------------------------------------------------- END NextState P
        when others =>
          null;
        
    end case; 
end process NextStateP;
  
END ARCHITECTURE arch;

