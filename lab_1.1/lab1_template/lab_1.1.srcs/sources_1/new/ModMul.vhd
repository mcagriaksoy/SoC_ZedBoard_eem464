library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity ModMul is 
port(x : in INTEGER range 0 to 9999;
	 y : in INTEGER range 0 to 9999;
	 clk: in std_logic;
	 reset: in std_logic; 
	 start: in std_logic;
	 z: out INTEGER range 0 to 9999;
	 done1: out std_logic );
end ModMul;

architecture Behavioral of ModMul is
   component MonPro is
        port(a_mon : in INTEGER range 0 to 9999;
	         b_mon : in INTEGER range 0 to 9999;
	         returns :out INTEGER range 0 to 9999);
    end component;
    
signal x_mon,y_mon,z_mon : INTEGER range 0 to 9999;
signal t,m,u : INTEGER range 0 to 9999;
signal k,l,o : INTEGER range 0 to 9999;
    
constant r :INTEGER:= 2**(16);
constant n :INTEGER:= 121;
begin
    x_mon <= (x*r) mod n;
    y_mon <= (y*r) mod n ;
    
    process(clk)
        begin
            if reset = '1' then
                 done1<='0';   
            elsif start = '0' then
                 done1<='0';
                 
            end if;      
       end process;
         
    C0:MonPro port map (x_mon, y_mon,z_mon);
    C1: MonPro port map (z_mon,1,z);
    done1<='1';
                
end Behavioral;
