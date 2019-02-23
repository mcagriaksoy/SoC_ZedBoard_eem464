
library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_unsigned.all;
use ieee.numeric_std.ALL;
entity mod_mul_with_oled is
    port (  clk         : in std_logic;
            rst         : in std_logic;
            start       : in std_logic;
            ready       : in std_logic;
            sw_in       : in std_logic_vector(7 downto 0);
            
            en          : in std_logic; 
            oled_sdin   : out std_logic;
            oled_sclk   : out std_logic;
            oled_dc     : out std_logic;
            oled_res    : out std_logic;
            oled_vbat   : out std_logic;
            oled_vdd    : out std_logic);
end mod_mul_with_oled;

architecture behavioral of mod_mul_with_oled is

component ModMul is port(
	x : in INTEGER range 0 to 9999;
	y : in INTEGER range 0 to 9999;
	clk: in std_logic;
	reset: in std_logic; 
	start: in std_logic;
	z: out INTEGER range 0 to 9999;
	done1: out std_logic
    );
    end component;

    component debounce IS
  GENERIC(
    counter_size  :  INTEGER := 20); --counter size (19 bits gives 10.5ms with 50MHz clock)
  PORT(
    clk     : IN  STD_LOGIC;  --input clock
    button  : IN  STD_LOGIC;  --input signal to be debounced
    result  : OUT STD_LOGIC); --debounced signal
END component;

    component oled_init is
        port (  clk         : in std_logic;
                rst         : in std_logic;
                en          : in std_logic;
                sdout       : out std_logic;
                oled_sclk   : out std_logic;
                oled_dc     : out std_logic;
                oled_res    : out std_logic;
                oled_vbat   : out std_logic;
                oled_vdd    : out std_logic;
                fin         : out std_logic);
    end component;

    component oled_drive is
        port (  clk         : in std_logic;
                rst         : in std_logic;
                en          : in std_logic;
                a_reg       : in std_logic_vector(15 downto 0);
                b_reg       : in std_logic_vector(15 downto 0);
                n_reg       : in std_logic_vector(15 downto 0);
                z_reg       : in std_logic_vector(15 downto 0);
                sdout       : out std_logic;
                oled_sclk   : out std_logic;
                oled_dc     : out std_logic;
                fin         : out std_logic);
    end component;

    type states is (Idle,OledInitialize, LoadA_0, LoadA_1, LoadB_0, LoadB_1, LoadN_0, LoadN_1, OledExample, OledExample2, DoMult, WaitMult, Done);
    signal current_state, next_state : states := Idle;
    signal init_en          : std_logic := '0';
    signal init_done        : std_logic;
    signal init_sdata       : std_logic;
    signal init_spi_clk     : std_logic;
    signal init_dc          : std_logic;
    signal example_en       : std_logic := '0';
    signal example_sdata    : std_logic;
    signal example_spi_clk  : std_logic;
    signal example_dc       : std_logic;
    signal example_done,done1     : std_logic;
   
    signal a_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal b_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal n_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal z_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal ready_mult : std_logic;
    signal start_mult : std_logic := '0';
    signal a1,b1 : std_logic_vector(15 downto 0);
    signal t,m,u : std_logic_vector(15 downto 0);
    signal x,y,z : Integer range 0 to 9999 ;
    signal en_db : std_logic;
    signal x0,x1, y0,y1, z0,z1: unsigned(7 downto 0);
begin 
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= Idle;
                start_mult <= '0';
            else
                case current_state is
                    when Idle =>
                        current_state <= OledInitialize;        
                                                 
                    when LoadA_0 =>
                        x0 <= unsigned(sw_in);
                        if ready = '1' then 
                            next_state <= LoadA_1;
                        else
                            next_state <= LoadA_0;
                        end if;
                    when LoadA_1 =>
                        x1 <= unsigned(sw_in);
                        if ready = '1' then 
                            next_state <= LoadB_0;
                        else
                            next_state <= LoadA_1;
                        end if;
                        
                    when LoadB_0 =>
                        y0 <= unsigned(sw_in);
                        
                        if ready = '1' then 
                            next_state <= LoadB_1;
                          else
                            next_state <= LoadB_0;
                        end if;
                     when LoadB_1 =>
                        y1 <= unsigned(sw_in);
                        
                        if ready = '1' then 
                            next_state <= WaitMult;
                          else
                            next_state <= LoadB_0;
                        end if;
                    when WaitMult =>
                        if start = '1' then
                           next_state <= DoMult;
                        else
                            next_state <= WaitMult;
                        end if;
                    when DoMult =>
                         x <= to_integer(x1&x0);
                         y <= to_integer(y1&y0);
                     if done1 = '1' then
                         next_state <= Done;
                     else
                        next_state <= WaitMult;   
                     end if;
                     
                    when OledInitialize =>
                        if init_done = '1' then
                            current_state <= OledExample;
                            next_state <= Done;
                        end if;
                        
                    -- Do example and do nothing when finished
                    when OledExample =>
                        if example_done = '1' then
                            current_state <= next_state;
                        end if;  
                                 
                    when Done =>
                        current_state <= Done;
                    when others =>
                        current_state <= Idle;
                end case;
            end if;
        end if;
    end process;
    

      -- MUXes to indicate which outputs are routed out depending on which block is enabled
    oled_sdin <= init_sdata when current_state = OledInitialize else example_sdata;
    oled_sclk <= init_spi_clk when current_state = OledInitialize else example_spi_clk;
    oled_dc <= init_dc when current_state = OledInitialize else example_dc;
    -- End output MUXes

    -- MUXes that enable blocks when in the proper states
    init_en <= '1' when current_state = OledInitialize else '0';
    example_en <= '1' when current_state = OledExample  else
                  '1' when current_state = OledExample2 else '0';
    
    a_reg <= std_logic_vector(x1&x0);
    b_reg <= std_logic_vector(y1&y0);
    z_reg <= std_logic_vector(to_unsigned(z,U'length));
    
    MOD_MUL: ModMul port map (x,y,clk,rst,start,z,done1);
    
    Debouncing: debounce port map(clk, en, en_db);

    Initialize: oled_init port map (clk,rst,init_en,init_sdata,init_spi_clk,init_dc,oled_res,oled_vbat,oled_vdd,init_done);

    Drive_OLED_Screen: oled_drive port map ( clk,
                                            rst,
                                            example_en,
                                            a_reg,
                                            b_reg,
                                            n_reg,
                                            z_reg,
                                            example_sdata,
                                            example_spi_clk,
                                            example_dc,
                                            example_done);
    
    
     
     
end behavioral;
