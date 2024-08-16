----------------------------------------------------------------------------------
-- Institution: Universiteit antwerpen
-- Engineer: Jazzmin De Bie
-- Create Date: 13.10.2020 17:51:16
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity ScoreBord is
 port ( Score1: in natural; -- Mag dit (15 downto 9) zijn?
        Score2: in natural;
        DK: in unsigned (1 downto 0); -- "Display kiezer"   mag dit 8 downto 7 zijn?
       -- Score2: in unsigned(7 downto 0)); -- 6 downto 0?   
       AN: out std_logic_vector(3 downto 0); -- was 7 downto 0
       Sevensegm: out std_logic_vector(6 downto 0));
         
end ScoreBord;

architecture Behavioral of ScoreBord is

--signal Score1: unsigned(7 downto 0);
--signal DK: unsigned (1 downto 0); -- display kiezer
--signal Score2: unsigned(7downto 0);
signal getal99: unsigned(6 downto 0);     -- decimaal getal (eenheden en tientallen tesamen)

-- signal EenheidTijdelijk: unsigned(6 downto 0);
signal Eenheid: unsigned(3 downto 0);
signal EenheidV: unsigned (7 downto 0);
-- signal Tiental7bits: unsigned (6 downto 0);
signal Tiental: unsigned(3 downto 0);
signal getal: unsigned (3 downto 0);      -- decimaal cijfer

component bcdtosevensegm is
port ( BCD: in unsigned(3 downto 0);
SevenSegm: out std_logic_vector(6 downto 0));
end component;

--signal SevenSegm: std_logic_vector (6 downto 0);






begin
-- DK ophalen
--DK <= Input (8 downto 7);

-- Scre1 of score2?
getal99 <= to_unsigned(Score1,7) when (DK = "00" or DK= "01")else
           to_unsigned(Score2,7);              



-- Tientallen bepalen
Tiental <= "0000" when getal99 <10 else                     -- 0
           "0001" when getal99> 9  and getal99 < 20 else    -- 1
           "0010" when getal99> 19 and getal99 < 30 else    -- 2
           "0011" when getal99> 29 and getal99 < 40 else    -- 3
           "0100" when getal99> 39 and getal99 < 50 else    -- 4
           "0101" when getal99> 49 and getal99 < 60 else    -- 5
           "0110" when getal99> 59 and getal99 < 70 else    -- 6
           "0111" when getal99> 69 and getal99 < 80 else    -- 7
           "1000" when getal99> 79 and getal99 < 90 else    -- 8
           "1001" when getal99> 89 and getal99 < 100 else   -- 9
           "1010";                                      -- 10 --> E
           
EenheidV <= (getal99 - (Tiental*10));
Eenheid <= "1010" when (Tiental = "1010") else
            EenheidV(3 downto 0);

    
-- Eenheid of Tiental?
getal <= Tiental when (DK = "00" or DK = "10") else
         Eenheid; -- when DK = 01 or DK is 11

-- BCD (getal) --> 7 segm
Testing: bcdtosevensegm port map(
                                    BCD => getal,
                                    SevenSegm => SevenSegm);
 
-- anode kiest display, kathode stuurt SevenSegm code
AN <= "0111" when DK = "00" else
      "1011" when DK = "01" else
      "1101" when DK = "10" else
      "1110"; -- when DK = "11"
      
-- SevenSegm code distribueren over de kathodes
    --CA <= SevenSegm(6);
    --CB <= SevenSegm(5);
    --CC <= SevenSegm(4);
    --CD <= SevenSegm(3);
    --CE <= SevenSegm(2);
    --CF <= SevenSegm(1);
    --CG <= SevenSegm(0);



end Behavioral;

