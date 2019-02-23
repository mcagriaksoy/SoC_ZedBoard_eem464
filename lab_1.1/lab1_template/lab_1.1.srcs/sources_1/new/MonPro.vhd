

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity MonPro is
port(a_mon : in INTEGER range 0 to 9999;
	 b_mon : in INTEGER range 0 to 9999;
	 returns :out INTEGER range 0 to 9999);
end MonPro;

architecture Behavioral of MonPro is
    signal t,m,u : INTEGER range 0 to 9999;
    signal k,l,o : INTEGER range 0 to 9999;
    constant r :INTEGER:= 2**(16);
    constant n :INTEGER:= 121;
begin
    
    t <=  (a_mon*b_mon) mod r;
    m <= (t*n) mod r; --n üssü ne ? --
    u <= (a_mon*b_mon + m*n) / r;
    process(t,m,u)
        begin
            if ( u >= n ) then
                returns <= u - n ;
            else
                returns <= u;
            end if;
    end process;

end Behavioral;
