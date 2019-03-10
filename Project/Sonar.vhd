----------------------------------------------
-- Interfacing a low-cost sonar module with
-- an FPGA 
-- Author: Mike Field <hamster@snap.net.nz>
----------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sonar is
    Port ( clk        : in  STD_LOGIC;
           sonar_trig : out STD_LOGIC;
           sonar_echo : in  STD_LOGIC;
           anodes     : out STD_LOGIC_VECTOR (3 downto 0);
           segments   : out STD_LOGIC_VECTOR (6 downto 0));
end sonar;

architecture Behavioral of sonar is
    signal count            : unsigned(16 downto 0) := (others => '0');
    signal centimeters      : unsigned(15 downto 0) := (others => '0');
    signal centimeters_ones : unsigned(3 downto 0)  := (others => '0');
    signal centimeters_tens : unsigned(3 downto 0)  := (others => '0');
    signal output_ones      : unsigned(3 downto 0)  := (others => '0');
    signal output_tens      : unsigned(3 downto 0)  := (others => '0');
    signal digit            : unsigned(3 downto 0)  := (others => '0');
    signal echo_last        : std_logic := '0';
    signal echo_synced      : std_logic := '0';
    signal echo_unsynced    : std_logic := '0';
    signal waiting          : std_logic := '0'; 
    signal seven_seg_count  : unsigned(15 downto 0) := (others => '0');
begin

decode: process(digit)
    begin
        case digit is 
           when "0001" => segments <= "1111001";
           when "0010" => segments <= "0100100";
           when "0011" => segments <= "0110000";
           when "0100" => segments <= "0011001";
           when "0101" => segments <= "0010010";
           when "0110" => segments <= "0000010";
           when "0111" => segments <= "1111000";
           when "1000" => segments <= "0000000";
           when "1001" => segments <= "0010000";
           when "1010" => segments <= "0001000";
           when "1011" => segments <= "0000011";
           when "1100" => segments <= "1000110";
           when "1101" => segments <= "0100001";
           when "1110" => segments <= "0000110";
           when "1111" => segments <= "0001110";
           when others => segments <= "1000000";
        end case;
    end process;

seven_seg: process(clk)
    begin
        if rising_edge(clk) then
            if seven_seg_count(seven_seg_count'high) = '1' then
                digit <= output_ones;
                anodes <= "1110";
            else
                digit <= output_tens;
                anodes <= "1101";
            end if;        
            seven_seg_count <= seven_seg_count +1; 
        end if;
    end process;
    
process(clk)
    begin
        if rising_edge(clk) then
            if waiting = '0' then
                if count = 1000 then -- Assumes 100MHz
                   -- After 10us then go into waiting mode
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