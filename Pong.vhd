----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2020 17:04:40
-- Design Name: 
-- Module Name: Pong - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity Pong is
--  Port ( );
end Pong;

architecture Behavioral of Pong is

-- componenten
component scorebord is port
    ( Input: in unsigned(15 downto 0); 
       AN: out std_logic_vector(7 downto 0);
       CA: out std_logic;
       CB: out std_logic;
       CC: out std_logic;
       CD: out std_logic;
       CE: out std_logic;
       CF: out std_logic;
       CG: out std_logic);
end component;

component Vga is
    Port ( clk : in STD_LOGIC;
            Hsync: out std_logic;
            Vsync: out std_logic;
            VGA_R: out std_logic_vector(3 downto 0);
            VGA_G: out std_logic_vector(3 downto 0);
            VGA_B: out std_logic_vector(3 downto 0));
end component;

begin


end Behavioral;
