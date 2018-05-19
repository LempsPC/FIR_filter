----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 03/02/2018 12:00:01 PM
-- Design Name:
-- Module Name: FIR_tester1 - Behavioral
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
use IEEE.std_logic_arith.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
 
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
 
entity FIR_tester1 is
--  Port ( );
end FIR_tester1;
 
architecture Behavioral of FIR_tester1 is
 
component  fir_filter_syn is
  port ( data_in: in signed (15 downto 0);
         data_out: out signed (15 downto 0);
         sample, clk: in bit );
end component fir_filter_syn;
 
signal data_in, data_out: signed (15 downto 0);
signal sample, clk: bit;
 
procedure cycle (signal data_in : out signed(15 downto 0);
                 signal sample :out bit;
                 signal clk : out bit ) is
begin
    clk <= '1';
    sample <= '1';
    wait for 10ns;
    
    clk <= '0';
    
    wait for 10ns;
    sample <= '0';
    --clk <= '0';
    
    --wait for 10ns;
    
    for i in 0 to 2 loop
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        wait for 10ns;
    end loop;
    
end cycle;
 
 
begin
 
UUT: fir_filter_syn
Port map (data_in => data_in,
          data_out => data_out,
          sample => sample,
          clk => clk);
 
stimuli: process
begin
   
--    clk <= '1';
--    wait for 10ns;
--    clk <= '0';
--    wait for 10ns;
--    clk <= '1';
--    wait for 10ns;
--    clk <= '0';
--    wait for 10ns;
--    clk <= '1';
--    wait for 10ns;
    
    for i in 0 to 10 loop
        data_in <= "0000000000000000";
        cycle(data_in, sample, clk);
    end loop;
   
    data_in <= "0000010000000000";
    cycle(data_in, sample, clk);
   
end process;
 
end Behavioral;