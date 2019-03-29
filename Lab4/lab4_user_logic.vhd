library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab4_user_logic is
	generic (
        LED_WIDTH	: integer	:= 8
		);
	port(
	    S_AXI_ACLK    : in std_logic;
		S_AXI_ARESETN : in std_logic;
		S_AXI_WDATA   : in std_logic_vector(31 downto 0);
        mult_out      : in std_logic_vector(7 downto 0);
        slv_reg_wren  : in std_logic;
        slv_reg_rden  : in std_logic;
        axi_awaddr    : in std_logic_vector(1 downto 0);
        axi_araddr    : in std_logic_vector(1 downto 0);
		LED_out       : out std_logic_vector(7 downto 0)		
		);
end lab4_user_logic;

architecture arch_imp of lab4_user_logic is

begin

	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      LED_out  <= (others => '0');
	    else
	      if (slv_reg_wren = '1' and ((axi_awaddr = "00") or (axi_awaddr = "01"))) then
	        -- When slv_reg0 or slv_reg1 is written by the processor then LED will display the least significant 8-bits
	          LED_out <= S_AXI_WDATA(LED_WIDTH-1 downto 0);  -- wdata is written to the LED_out data
	      end if; 
	      if  (slv_reg_rden = '1' and (axi_araddr = "10")) then
	          LED_out <= mult_out;  -- the result of the operation is written to the LEDs
	      end if; 
	    end if;
	  end if;
	end process;		

end arch_imp;