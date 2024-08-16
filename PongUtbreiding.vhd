----------------------------------------------------------------------------------
-- Company: Universiteit Antwerpen
-- Engineer: Jazzmin De Bie
-- Create Date: 15.11.2020 15:06:50
-- Module Name: VgaRoodScherm - Behavioral
-- Description: 
-- 640x 480 @60Hz

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity Vga is
    Port (CLK100MHZ: in STD_LOGIC;
        
            -- besturing
            BTN_U: in std_logic;
            BTN_L: in std_logic;
            BTN_R: in std_logic;
            BTN_D: in std_logic;
            reset: in std_logic;  -- BTN_C
            
            SW0: in std_logic; -- pallet speed * 2
            SW1: in std_logic; -- ball speed * 3
            SW2: in std_logic; --ball speed * 4
            SW3: in std_logic; -- Alles Blauw
            
            
            SW15: in std_logic; -- pallet speed * 2
            SW14: in std_logic; -- pallet speed * 3
            SW13: in std_logic; -- pallet speed * 4
            SW12: in std_logic;  -- modus aanraken is versnellen
            
            
            
            -- VGA signals
            Hsync: out std_logic;
            Vsync: out std_logic;
            VGA_R: out std_logic_vector(3 downto 0);
            VGA_G: out std_logic_vector(3 downto 0);
            VGA_B: out std_logic_vector(3 downto 0);
            
            -- score bord
            AN: out std_logic_vector(3 downto 0);
            KAT: out std_logic_vector(6 downto 0)
            );
    end Vga;




architecture Behavioral of Vga is
    
    -- Besturing
    signal PalletL_Y: natural:= 325;        -- posities steeds de rechter onder hoek
    signal PalletL_X: natural:=219;   -- deze waarde blijft ongewijzigd
    signal PalletR_Y: natural:=325;
    signal PalletR_X: natural := 695; -- deze waarde blijft ongewijzigd
    signal Ball_Y: natural:=300;
    signal Ball_X: natural:=472;
    
    signal Rechts: integer := 1;
    signal Onder: integer := 0;
    
    signal ball_speed: natural;
    signal pallet_speed: natural;
    signal Teller: natural := 1;

 
    -- VGA signals
    signal R: std_logic_vector(3 downto 0):= "0000";
    signal G: std_logic_vector(3 downto 0):="0000";
    signal B: std_logic_vector(3 downto 0):="0000";
    signal wit: std_logic;
           
    signal clkCount: integer := 1; 
    signal clkcount1: integer :=1;
    signal clk25: std_logic;
    signal clk100HZ: std_logic; 
    signal HC: integer := 1;
    signal VC: integer := 1;  
    signal VideoActive: std_logic;
    
    -- scorebord
    
    signal ScoreL: natural:=0;
    signal ScoreR: natural:=0;
    signal DK: unsigned (1 downto 0):= "00";
    
    component ScoreBord is port(Score1: in natural;
                                Score2: in natural;
                                DK: in unsigned (1 downto 0);
                                AN: out std_logic_vector(3 downto 0);
                                Sevensegm: out std_logic_vector(6 downto 0));
    end component;
  

begin 
    
    
    -- Tellers en klokken
        clkconversie: process (CLK100MHZ) is
            begin
                if rising_edge(CLK100MHZ) then          
                    If clkcount = 2  then--- dit was 4 maar dat is voor een klok van 12,5 MHZ
                        clkcount <= clkcount + 1;
                        clk25 <= '0';
                    elsif clkCount =  4 then --- dit was 8
                        clkCount <= 1;
                        clk25 <= '1';
                    else
                        clkCount <= clkCount + 1;
                    end if;
                end if;
            end process;
        
        clkconversieScorebord: process (CLK100MHZ) is
        begin
            if rising_edge (CLK100MHZ) then 
                if clkcount1 = 5000 then
                    clkcount1 <= clkcount1 + 1;
                    clk100HZ <= '0';
                elsif clkcount1 = 10000
                    then clkcount1 <= 1; 
                    clk100Hz <= '1'; 
                else 
                    clkcount1 <= clkcount1 +1;
                end if;
            end if; 
        end process;
 
        Hcounter: process (clk25) is
        begin
            if rising_edge (clk25) then
                --if reset = '1' then
                    --HC <= 0;
                if HC = 800 then -- whole horizontal line is 800 pixels
                    HC <= 1;        -- (inclusief non visable)
                else
                    HC <= HC +1;
                end if;
            end if; 
        end process;
    
        Vcounter: process (clk25) is 
        begin
            if rising_edge (clk25) then
                -- if reset = '1' then
                -- VC <= 0;
                if HC = 800 then -- VCEN
                    if VC = 525 then -- 525 lines in one image
                        VC <= 1;
                    else
                        VC <= VC + 1;
                    end if;
                end if;
            end if;
        end process;
        
        DKpulsatie: process (clk100hz) is
        begin
            if rising_edge (clk100hz) then
                if DK < "11" then
                    DK <= DK + 1;
                else
                    DK <= "00";
                end if;
            end if;
        end process;
              
        
    -- bewegen ----- 30/11
    
pallet_speed <= 5 when sw2 = '1' else
                4 when sw1 = '1' else
                3 when sw0 = '1' else
                2;

ball_speed <= Teller when SW12 = '1' else
              6 when sw13 = '1' else
              5 when sw14 = '1' else
              4 when sw15 = '1' else
              2;
        Objecten_Bewegen: process (clk25) is
        begin
            if rising_edge (clk25)  then         
                if reset = '1' then
                    ScoreL <= 0;
                    ScoreR <= 0;
                    Rechts <= 2;
                    Onder <= 2;
                    PalletL_Y <= 325;        -- posities steeds de rechter onder hoek
                    PalletL_X <= 219;   -- deze waarde blijft ongewijzigd
                    PalletR_Y <= 325;
                    PalletR_X <= 695; -- deze waarde blijft ongewijzigd
                    Ball_Y <= 200;
                    Ball_X <= 472;
                    Teller <= 1;
                    
                elsif  (VC = 1 and HC = 1) then   
                
                -- palletL
                    if BTN_U = '1' and palletL_Y > 160 then -- naarboven , met grens zodat niet uit kader
                    PalletL_Y <= PalletL_Y - (2*pallet_speed);
            
                    elsif BTN_L = '1' and palletL_Y < 465 then                    -- naar onder , met grens zodat niet uit kader
                    palletL_Y <= palletL_Y + (2*pallet_speed);
  
                    end if;
                
                -- PalletR
                    if BTN_R = '1' and palletR_Y > 160 then -- naar boven --> Vc neemt af
                    PalletR_Y <= PalletR_Y - (2*pallet_speed);
            
                    elsif BTN_D = '1' and palletR_Y < 465 then
                    palletR_Y <= palletR_Y + (2*pallet_speed);
            
                    end if;  

               -- Bal Bewegen
                    
                    if 86 > ball_Y - 15 then -- bal raakt boven     -- palletten : h = 75, b = 15
                        Onder <= 1;                                 -- ball   15 x 15
                        if teller > 1 then
                            Teller <= Teller - 1;
                        end if;

                    elsif ball_Y > 465 then -- bal raakt onder
                        onder <= -1;
                        if teller > 1 then
                            Teller <= Teller - 1;
                        end if;
                    end if;
                   
                     
                    if (PalletL_Y > ball_Y - 15 and ball_Y > PalletL_Y - 75) and (PalletL_X + 15 >= Ball_X) then  -- bal raakt linker pallet
                        Rechts <= 2;
                        Teller <= Teller + 1;
                
                    elsif (PalletR_Y > ball_Y - 15 and ball_Y > PalletR_Y - 75) and (PalletR_X  <= Ball_X + 15) then -- bal raakt rechter pallet
                        Rechts <= -2;
                        Teller <= Teller + 1;
                    end if;
                    
                    Ball_X <= Ball_X + (Rechts*ball_speed);
                    Ball_Y <= Ball_Y + (Onder*ball_speed);
                
                -- als bal links rechts raakt kader --> punt
                    if Ball_X < 194 or Ball_X > 720 then
                        
                        if Ball_X < 194 then    -- raakt linker kant
                            scoreR <= scoreR + 1;
                            rechts <= 1; 
                        elsif Ball_X > 720 then
                            ScoreL <= ScoreL + 1;
                            rechts <= -1;
                        end if;
                        
                        --PalletL_Y <= 325;     
                        --PalletR_Y <= 325;
                        Ball_Y <= 300;
                        Ball_X <= 472;
                        Teller <= 1;
                    
                    end if;
                   
                                   
                -- bal bewegen
                  
                end if;         -- reset
            end if;             -- rising_edge

        end process;
                
                
                
              
        
    -- tekenen
        tekenen: process (PalletL_X,PalletL_Y, PalletR_X, PalletR_Y, Ball_X, Ball_Y, HC, VC) is 
        begin
            if (PalletL_X -1 < HC and  HC < PalletL_X +16) and (PalletL_Y -76 < VC and VC < PalletL_Y +1)then
                Wit <= '1';
            elsif (PalletR_X -1 < HC and HC < PalletR_X +16) and (PalletR_Y -76 < VC and VC < PalletR_Y +1)then
                Wit <= '1';
            elsif (Ball_X -1 < HC and HC < Ball_X + 16) and (Ball_Y - 16 < VC and VC < Ball_Y + 1) then
                Wit <= '1';
              -- kader
            elsif  (((75 < VC and VC < 86) or (465 < VC and VC < 476)) and (194 < HC and HC < 745)) then--- de 2 horizontale lijnen 
                Wit <= '1';
                
            elsif (((194 < HC and HC < 205) or (734 < HC and HC < 745) or (472 < HC and HC < 477 )) and (75 < VC and VC < 476)) then -- de 3 verticale lijnen (middellijn)  
                Wit <= '1';
               
            --elsif  (((75 < VC and VC < 86) or (465 < VC and VC < 476)) and (144 < HC and HC < 735)) then--- de 2 horizontale lijnen 
                --Wit <= '1';
                
           -- elsif (((184 < HC and HC < 195) or (724 < HC and HC < 735) or (462 < HC and HC < 467 )) and (75 < VC and VC < 476)) then -- de 3 verticale lijnen (middellijn)  
               --Wit <= '1';
                    
            else
                Wit <= '0';
            end if;
        end process;
                
                     
    
    -- VGA aansturen
        Hsyncp: process (HC)is 
        begin
            if  0 < HC and HC < 97 then -- sync pulse = 96 pixels
                Hsync <= '0';
            else
                Hsync <= '1';
            end if;
        end process;
    
        Vsyncp: process (VC)
        begin
            if 0 < VC and VC < 3 then       -- sync pulse = 2 lines
                Vsync <= '0';
            else
                Vsync <= '1';
            end if;
        end process;
        
        inzichtbaargebied: process (VC, HC) is
        begin
            if (144 < HC and HC < 785)    and (35 < VC and VC < 516) then
                VideoActive <= '1';
            else
                VideoActive <= '0'; 
            end if;
        end process;      
 
        Kleurdoorlaten: process (VideoActive, wit)is
        begin
            if VideoActive = '0' then
                VGA_R <= "0000";
                VGA_G <= "0000";
                VGA_B <= "0000";
                
            elsif Wit = '1' and SW3 = '1' then
                VGA_R <= "0010";
                VGA_G <= "0010";
                VGA_B <= "1111";
                
            elsif Wit = '1' then
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "1111";
           
           else
                VGA_R <= "1001";
                VGA_G <= "0000";
                VGA_B <= "0000";
            
            
                
                
            -- kader
            --elsif  (((75 < VC and VC < 86) or (465 < VC and VC < 476)) and (154 < HC and HC < 745)) then--- de 2 horizontale lijnen 
                --VGA_R <= "1111";
                --VGA_G <= "1111";
                --VGA_B <= "1111";
                
           -- elsif (((154 < HC and HC < 165) or (734 < HC and HC < 745) or (472 < HC and HC < 477 )) and (75 < VC and VC < 476)) then -- de 3 verticale lijnen (middellijn)  
                --VGA_R <= "1111";
                --VGA_G <= "1111";
               -- VGA_B <= "1111";
               
               -- staat nu bij tekenen
            

            -- bewegende componenten
            --else
                --VGA_R <= R;   
               -- VGA_G <= G;
                --VGA_B <= B;
            end if;
        end process;
        
        -- Score
        sturen_naar_ScoreBord: Scorebord Port map ( Score1 => ScoreL,
                                                    Score2 => ScoreR,
                                                    DK => DK,
                                                    AN => AN,
                                                    Sevensegm => KAT);
                                                    
                

        


end Behavioral;

