--Mehmet Cagri Aksoy--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MonPro is
port(a_mon : in unsigned (15 downto 0);
	 b_mon : in unsigned (15 downto 0);
	 clk: in std_logic;
	 reset: in std_logic; 
	 start: in std_logic;
	 returns :out unsigned (15 downto 0);
	 done1: out std_logic);
end MonPro;

architecture Behavioral of MonPro is

signal t0,m0,u0 : unsigned(31 downto 0);
signal t,m,u : unsigned(15 downto 0);

--predefined variables--
signal r  :unsigned(15 downto 0) := "1000000000000000";
signal n1 :unsigned(15 downto 0) := "0110100111001001";
signal n  :unsigned(15 downto 0) := "0000000001111001";


begin
   process(clk,reset,start)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                done1 <= '0';
            elsif start = '0' then
                done1 <= '0';
            else
                t0 <= a_mon*b_mon ;
                t <= t0(15 downto 0);
                m0 <= t*n1;
                m <= m0(15 downto 0);
                u0 <= (a_mon*b_mon + m*n);
                u <= u0(31 downto 16);   
            end if;
        end if;
     end process;   

    process(t,m,n,u)
        begin
            if ( u >= n ) then
                done1 <= '1';
                returns <= u - n ;
            else
                done1 <= '1';
                returns <= u;
            end if;
    end process;

end Behavioral;
