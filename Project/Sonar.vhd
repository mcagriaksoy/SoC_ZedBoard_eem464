----------------------------------------------
-- Mehmet Cagri Aksoy github.com/mcagriaksoy some elements from, Mike Field's repo
----------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sonar is
    Port ( clk        : in  STD_LOGIC;
           sonar_trig : out STD_LOGIC;
           sonar_echo : in  STD_LOGIC;
           output_ones: out unsigned(3 downto 0);
		   output_tens: out unsigned(3 downto 0));
		   
end sonar;

architecture Behavioral of sonar is
    signal count            : unsigned(16 downto 0) := (others => '0');
    signal centimeters      : unsigned(15 downto 0) := (others => '0');
    signal centimeters_ones : unsigned(3 downto 0)  := (others => '0');
    signal centimeters_tens : unsigned(3 downto 0)  := (others => '0');
	

  
    signal echo_last        : std_logic := '0';
    signal echo_synced      : std_logic := '0';
    signal echo_unsynced    : std_logic := '0';
    signal waiting          : std_logic := '0'; 
    signal seven_seg_count  : unsigned(15 downto 0) := (others => '0');
begin

process(clk)
    begin
        if rising_edge(clk) then
            if waiting = '0' then
                if count = 1000 then -- Assumes 100MHz                 
                   sonar_trig <= '0';
                   waiting    <= '1';
                   count       <= (others => '0');
                else
                   sonar_trig <= '1';
                   count <= count+1;
                end if;
            elsif echo_last = '0' and echo_synced = '1' then
                -- Seen rising edge - start count
                count       <= (others => '0');
                centimeters <= (others => '0');
                centimeters_ones <= (others => '0');
                centimeters_tens <= (others => '0');			
            elsif echo_last = '1' and echo_synced = '0' then
                -- Seen falling edge, so capture count
                output_ones <= centimeters_ones; 
                output_tens <= centimeters_tens;				
            elsif count = 2900*2 -1 then
                -- advance the counter
                if centimeters_ones = 9 then
                    centimeters_ones <= (others => '0');
                    centimeters_tens <= centimeters_tens + 1;
                else
                    centimeters_ones <= centimeters_ones + 1;
                end if;		
                centimeters <= centimeters + 1;
                count <= (others => '0');		
                if centimeters = 3448 then
                    -- time out - send another pulse
                    waiting <= '0';
                end if;
            else
                count <= count + 1; 				
            end if;
            echo_last     <= echo_synced;
            echo_synced   <= echo_unsynced;
            echo_unsynced <= sonar_echo;
        end if;
       
    end process;
end Behavioral;