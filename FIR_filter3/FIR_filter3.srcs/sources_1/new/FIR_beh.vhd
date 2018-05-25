---------------------------------------------------------------------
--  9-tab FIR filter -- behavioral model
---------------------------------------------------------------------
--  Data word - 16 bits: sign, 5 bits left & 10 bits right of point
--    "sddddd.ffffffffff"  ["d"~integer, "f"~fraction]
--    1.0 == "0000010000000000", 0.125 == "0000000010000000", etc.
---------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity  fir_filter is
  port ( data_in: in signed (15 downto 0);
         data_out: out signed (15 downto 0);
         sample, clk: in bit );
end fir_filter;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture  behave  of  fir_filter  is
  type array_type is array (1 to 9) of signed (15 downto 0);
  -- (0.25, -0.25, 1.125, 1.25, 1.25, 1.25, 1.125, -0.25, 0.25)
  constant coeffs: array_type := (
    "0000000100000000", "1111111100000000", "0000010010000000",
    "0000010100000000", "0000010100000000", "0000010100000000",
    "0000010010000000", "1111111100000000", "0000000100000000" );
begin

  -- FIR filter as a single process
  process
    variable delayed: array_type;
    variable sum: signed (15 downto 0);
    variable tmp: signed (31 downto 0);
  begin
    -- Waiting for a new sample
    wait on clk until clk='1' and sample='1';

    -- Outputting results of the previous sample
    data_out <= sum;

    -- Shift and latch
    delayed (1 to 8) := delayed (2 to 9);
    delayed (9) := data_in;

    -- Calculate
    sum := (others=>'0');
    for i in array_type'range loop
      tmp := coeffs(i) * delayed(i);
      sum := sum + tmp(25 downto 10);
    end loop;

  end process;

end behave;
