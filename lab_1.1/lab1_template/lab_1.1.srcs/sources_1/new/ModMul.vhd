library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity ModMul is 
port(
    x : in std_logic_vector(7 downto 0);
	y : in std_logic_vector(7 downto 0);
	clk: in std_logic;
	reset: in std_logic; 
	start: in std_logic;
	z: out std_logic_vector(7 downto 0);
	done1: out std_logic
	);
end ModMul;

architecture Behavioral of ModMul is
   component MonPro is
        port(a_mon : in std_logic_vector(7 downto 0);
	         b_mon : in std_logic_vector(7 downto 0);
	         returns :out std_logic_vector(7 downto 0);
    end component;
    
    
constant r :INTEGER:= 2**(16);
constant n :INTEGER:= 121;
begin
   r1 = std_logic_vector(to_unsigned(r,U'length));
   temp = a*r1
   a_mon = a*r1 (15 downto 0);
   
   
    
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
