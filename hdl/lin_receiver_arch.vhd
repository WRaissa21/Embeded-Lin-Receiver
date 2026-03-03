--
-- VHDL Architecture RecepteurLIN_lib.InterfaceMicroprocesseur.arch
--
-- Created:
--          by - lenours-s.UNKNOWN (IREENA-SLN-B)
--          at - 11:25:52 13/05/2014
--
-- using Mentor Graphics HDL Designer(TM) 2013.1 (Build 6)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY InterfaceMicroprocesseur IS
   PORT( 
      CnD        : IN     std_logic;
      OctetLu    : IN     std_logic_vector (7 DOWNTO 0);
      EtatLu     : IN     std_logic_vector (7 DOWNTO 0);
      H          : IN     std_logic;
      RnW        : IN     std_logic;
      nCS        : IN     std_logic;
      nRST       : IN     std_logic;
      DecNbOctet : OUT    std_logic;
      SelAdr     : OUT    std_logic_vector (7 DOWNTO 0);
      M_Received : OUT    std_logic;
      EtatLu_RST : OUT    std_logic;
      OctetLu_RD : OUT    std_logic;
      D07        : INOUT  std_logic_vector (7 DOWNTO 0)
   );

-- Declarations

END InterfaceMicroprocesseur ;

--
ARCHITECTURE arch OF InterfaceMicroprocesseur IS
--Architecture declarations
TYPE DefEtat IS (Attente, LectureData, LectureEtat, EcritureFiltre);
  
SIGNAL EtatCourant, EtatSuivant : DefEtat;

SIGNAL nCS_Synchro, RnW_Synchro, CnD_Synchro : STD_LOGIC;

SIGNAL D07_Synchro : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

ClockedProc : PROCESS(H, nRST)
BEGIN
  IF (nRST='0') THEN
    EtatCourant <= Attente;
  ELSIF (H'EVENT AND H='1') THEN
    EtatCourant <= EtatSuivant;
  END IF;
END PROCESS ClockedProc;

InputProc_Synchro :  PROCESS(H, nRST)
BEGIN
  IF (nRST='0') THEN 
    nCS_Synchro <= '1';
    RnW_Synchro <= '1';
    CnD_Synchro <= '1';
    D07_Synchro <= (others => '0');
  ELSIF (H'EVENT AND H='1') THEN
    nCS_Synchro <= nCS;
    RnW_Synchro <= RnW;
    CnD_Synchro <= CnD;
    D07_Synchro <= D07;
  END IF;
END PROCESS InputProc_Synchro;
    
  
NextStateProc : PROCESS(nCS_Synchro, CnD_Synchro, RnW_Synchro, EtatCourant)
BEGIN
  EtatSuivant <= EtatCourant;
  CASE EtatCourant IS
  WHEN Attente =>
    IF (nCS_Synchro='0' AND CnD_Synchro='0' AND RnW_Synchro='1') THEN
      EtatSuivant <= LectureData;
    ELSIF (nCS_Synchro='0' AND CnD_Synchro='1' AND RnW_Synchro='1') THEN
      EtatSuivant <= LectureEtat;
    ELSIF (nCS_Synchro='0' AND CnD_Synchro='0' AND RnW_Synchro='0') THEN
      EtatSuivant <= EcritureFiltre;
    ELSE
      EtatSuivant <= Attente;
    END IF;
    WHEN LectureData =>
      IF (nCS_Synchro='1') THEN
        EtatSuivant <= Attente;
      ELSE
        EtatSuivant <= LectureData;
      END IF;
    WHEN LectureEtat =>
      IF (nCS_Synchro='1') THEN
        EtatSuivant <= Attente;
      ELSE
        EtatSuivant <= LectureEtat;
      END IF;
    WHEN EcritureFiltre =>
      IF (nCS_Synchro='1') THEN
        EtatSuivant <= Attente;
      ELSE 
        EtatSuivant <= EcritureFiltre;
      END IF;
  END CASE;
END PROCESS NextStateProc;

OutputProc_Comb : PROCESS(nCS_Synchro, CnD_Synchro, RnW_Synchro, EtatCourant, OctetLu, EtatLu)
BEGIN
  D07 <= (others => 'Z');
  OctetLu_RD <= '0';
  EtatLu_RST <= '0';
  DecNbOctet <= '0';
  CASE EtatCourant IS
    WHEN Attente =>
      IF (nCS_Synchro='0' AND CnD_Synchro='0' AND RnW_Synchro='1') THEN
        OctetLu_RD <= '1';
      END IF;
    WHEN LectureData =>
      D07 <= OctetLu;
      IF (nCS_Synchro='1') THEN
        DecNbOctet <= '1';
      END IF;
    WHEN LectureEtat =>
      D07 <= EtatLu;
      IF (nCS_Synchro='1') THEN
        EtatLu_RST <= '1';
      END IF;
    WHEN EcritureFiltre =>   
    END CASE;
END PROCESS OutputProc_Comb;

OutputProc_Synchro : PROCESS(H, nRST)
BEGIN 
  IF (nRST='0') THEN
    SelAdr <= (others => '0');
  ELSIF (H'EVENT AND H='1') THEN 
    CASE EtatCourant IS 
    WHEN EcritureFiltre =>
      IF (nCS_Synchro='1') THEN
        SelAdr <= D07_Synchro;
      END IF;
    WHEN OTHERS =>
    END CASE;
  END IF;
END PROCESS OutputProc_Synchro;
  
M_Received <= EtatLu(4);

END ARCHITECTURE arch;

