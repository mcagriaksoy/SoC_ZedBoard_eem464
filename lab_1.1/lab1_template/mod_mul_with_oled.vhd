--Mehmet Cagri Aksoy--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mod_mul_with_oled is
    port (  clk         : in std_logic;
            rst         : in std_logic;
            sw_in       : in std_logic_vector(7 downto 0);
            en          : in std_logic;
            start       : in std_logic;
            oled_sdin   : out std_logic;
            oled_sclk   : out std_logic;
            oled_dc     : out std_logic;
            oled_res    : out std_logic;
            oled_vbat   : out std_logic;
            oled_vdd    : out std_logic);
end mod_mul_with_oled;

architecture behavioral of mod_mul_with_oled is

component MonPro is port(
     a_mon : in unsigned (15 downto 0);
	 b_mon : in unsigned (15 downto 0);
	 clk: in std_logic;
	 reset: in std_logic; 
	 start: in std_logic;
	 returns :out unsigned (15 downto 0);
	 done1: out std_logic);
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

    type states is (Idle, OledInitialize, LoadA_0, LoadA_1, LoadB_0, LoadB_1, LoadN_0, LoadN_1, OledExample, OledExample2, DoMult, WaitMult, Done);

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
    signal example_done     : std_logic;
    
    signal a_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal b_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal n_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal z_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal ready_mult,done1,done2 : std_logic;
    signal start_mult : std_logic := '0';

    signal en_db : std_logic;
    
    --KODDDDDD--
    signal n  :unsigned(15 downto 0) := "0000000001111001";
    signal z_temp  :unsigned(15 downto 0);
    signal temp: unsigned(7 downto 0) := (others => '0');
    signal start1 : std_logic ;
    signal z,x,y : std_logic_vector(15 downto 0) := (others => '0');
    
begin
    
    Debouncing: debounce port map(clk, en, en_db);

    Initialize: oled_init port map (clk,
                                    rst,
                                    init_en,
                                    init_sdata,
                                    init_spi_clk,
                                    init_dc,
                                    oled_res,
                                    oled_vbat,
                                    oled_vdd,
                                    init_done);

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
                                            
    COMP1: MonPro port map (unsigned(x),unsigned(y),clk,rst,start,temp,done1);
    
    COMP2: MonPro port map (temp,"0000000000000001",clk,rst,done1,z_temp,done2);
    
    -- MUXes to indicate which outputs are routed out depending on which block is enabled
    oled_sdin <= init_sdata when current_state = OledInitialize else example_sdata;
    oled_sclk <= init_spi_clk when current_state = OledInitialize else example_spi_clk;
    oled_dc <= init_dc when current_state = OledInitialize else example_dc;
    -- End output MUXes

    -- MUXes that enable blocks when in the proper states
    init_en <= '1' when current_state = OledInitialize else '0';
    example_en <= '1' when current_state = OledExample  else
                  '1' when current_state = OledExample2 else '0';
    -- End enable MUXes
    
    a_reg <= x;
    b_reg <= y;
    n_reg <= std_logic_vector(n);
    
    process (clk,rst)
    begin     
            if rst = '1' then
                current_state <= Idle;
                start_mult <= '0';
                

            elsif (clk'event and clk='1') then
                current_state <= next_state;
            end if;
     end process;

            process(clk,current_state,sw_in,en_db,en,init_done,example_done)
                begin
                case current_state is
                    when Idle =>
                        next_state <= OledInitialize;
                    -- Go through the initialization sequence
                    when OledInitialize =>
                        if init_done = '1' then
                            next_state <= OledExample;
                        end if;
                        
                    -- Do example and do nothing when finished
                    when OledExample =>
                        if example_done = '1' then
                            next_state <= LoadA_0;
                        end if;    
                    
                    when LoadA_0 =>
                        
                        if en_db = '1' then
                            x(7 downto 0) <= sw_in;
                            next_state <= LoadA_1;
                        else
                            next_state <= LoadA_0;
                        end if;
                   when LoadA_1 =>
                        if en_db = '1' then
                            x(15 downto 8) <= sw_in;
                            next_state <= LoadB_0;
                        else
                            next_state <= LoadA_1;
                        end if;
                    when LoadB_0 =>      
                        if en_db = '1' then
                            y(7 downto 0) <= sw_in;
                            next_state <= LoadB_1;
                        else
                            next_state <= LoadB_0;
                        end if;
                    when LoadB_1 =>
                        if en_db = '1' then
                            y(15 downto 8) <= sw_in;
                            next_state <= WaitMult ;
                        else
                            next_state <= LoadB_1;
                        end if;
                    when WaitMult =>     
                        if start = '1' then          
                            next_state <= Done;
                        else
                            next_state <= WaitMult;
                        end if;
                      
                    when Done =>
                        next_state <= Done;
                        
                    when others =>
                        next_state <= Idle;
                end case;
        end process;

end behavioral;
