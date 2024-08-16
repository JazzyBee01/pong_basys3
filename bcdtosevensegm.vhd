library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity bcdtosevensegm is
 port ( BCD: in unsigned(3 downto 0);
 SevenSegm: out std_logic_vector(6 downto 0));
end bcdtosevensegm;

architecture Behavioral of bcdtosevensegm is
type tSegm is array(0 to 10) of std_logic_vector(6 downto 0);
constant cSegm : tSegm := ("0000001", -- 0
                           "1001111", -- 1
                           "0010010", -- 2
                           "0000110", -- 3
                           "1001100", -- 4
                           "0100100", -- 5
                           "0100000", -- 6
                           "0001111", -- 7
                           "0000000", -- 8 niet 1111111 !!
                           "0000100", -- 9
                           "0110000"); -- E
                           
signal cijfer : std_logic_vector(6 downto 0);
begin
cijfer <= cSegm (0) when BCD = "0000" else
          cSegm (1) when BCD = "0001" else
          cSegm (2) when BCD = "0010" else
          cSegm (3) when BCD = "0011" else
          cSegm (4) when BCD = "0100" else
          cSegm (5) when BCD = "0101" else
          cSegm (6) when BCD = "0110" else
          cSegm (7) when BCD = "0111" else
          cSegm (8) when BCD = "1000" else
          cSegm (9) when BCD = "1001" else
          cSegm (10);  -- when  ( BCD = "1010" or
                            --BCD = "1011" or
                            --BCD = "1100" or 
                            --BCD = "1101" or 
                            --BCD = "1110" or
                            --BCD = "1111")
SevenSegm <= cijfer;                      

end Behavioral;
