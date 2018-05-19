---------------------------------------------------------------------

--  9-tab FIR filter -- synthesizable model

--  Refined from the synthesizable RTL model [fir_filter_syn(behave_rtl_2)]

--    by creating explicit state machine

---------------------------------------------------------------------

--  Data word - 16 bits: sign, 5 bits left & 10 bits right of point

--    "sddddd.ffffffffff"  ["d"~integer, "f"~fraction]

--    1.0 == "0000010000000000", 0.125 == "0000000010000000", etc.

---------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;

use IEEE.std_logic_arith.all;



entity  fir_filter_syn is

  port ( data_in: in signed (15 downto 0);

         data_out: out signed (15 downto 0);

         sample, clk: in bit );

end fir_filter_syn;



library IEEE;

use IEEE.std_logic_1164.all;

use IEEE.std_logic_arith.all;



architecture  rtl  of  fir_filter_syn  is

  -- Constants

  type array_type is array (1 to 9) of signed (15 downto 0);

  -- (0.125, 0.25, -0.75, 1.25, 1.0, 1.25, -0.75, 0.25, 0.125)

  constant coeffs: array_type := (
    "0000000100000000", "1111111100000000", "0000010010000000",
    "0000010100000000", "0000010100000000", "0000010100000000",
    "0000010010000000", "1111111100000000", "0000000100000000" );

  constant who_cares: signed (15 downto 0) := "----------------";



  -- State - type & signals

  type state_type is (S0, S1, S2, S3);

  signal state, next_state: state_type;



  -- Signals

  signal del_1, del_2, del_3, del_4, del_5, del_6, del_7, del_8,

    data_in_bf, reg1, reg2, reg3, reg4,

    add1_out, add2_out, add3_out, sub4_out: signed (15 downto 0);



  -- Shifters

  function asr3 ( inp: signed (15 downto 0) ) return signed is begin

    return inp(15) & inp(15) & inp(15) & inp(15 downto 3);

  end asr3;

  function asr2 ( inp: signed (15 downto 0) ) return signed is begin

    return inp(15) & inp(15) & inp(15 downto 2);

  end asr2;



begin

  -- Next state function of the state machine

  process (state, sample) begin

    case state is

      when S0 =>  if sample='1' then  next_state <= S1;

                  else                next_state <= S0;  end if;

      when S1 =>  next_state <= S2;

      when S2 =>  next_state <= S3;

      when S3 =>  next_state <= S0;

    end case;

  end process;



  -- State register

  process (clk) begin

    if clk'event and clk='1' then  state <= next_state;  end if;

  end process;



  -- Input/output buffers

  process (clk) begin

    if clk'event and clk='1' then

      if state=S0 then

        data_out <= reg1;    data_in_bf <= data_in;

      end if;

    end if;

  end process;



  -- Data registers

  process (clk) begin

    if clk'event and clk='1' then

      reg1 <= add1_out;    reg2 <= add2_out;

      reg3 <= add3_out;    reg4 <= sub4_out;

    end if;

  end process;



  -- Shift register

  process (clk) begin

    if clk'event and clk='1' then

      if state=S3 then

        del_8 <= del_7;  del_7 <= del_6;

        del_6 <= del_5;  del_5 <= del_4;

        del_4 <= del_3;  del_3 <= del_2;

        del_2 <= del_1;  del_1 <= data_in_bf;

      end if;

    end if;

  end process;



  -- Adder #1 & its multiplexers

  process (del_1, del_7, data_in_bf, del_8, reg1, reg2, reg4, state)

    variable op1, op2: signed (15 downto 0);

  begin

    case state is

      when S0 =>  op1 := del_1;       op2 := del_7;

      when S1 =>  op1 := data_in_bf;  op2 := del_8;

      when S2 =>  op1 := asr3(reg1);  op2 := reg2;

      when S3 =>  op1 := reg1;        op2 := reg4;

    end case;

    add1_out <= op1 + op2;

  end process;



  -- Adder #2 & its multiplexers

  process (del_2, del_6, del_4, reg1, state)

    variable op1, op2: signed (15 downto 0);

  begin

    case state is

      when S0 =>  op1 := del_2;       op2 := del_6;

      when S1 =>  op1 := del_4;       op2 := asr2(reg1);

      when S2 =>  op1 := who_cares;   op2 := who_cares;

      when S3 =>  op1 := who_cares;   op2 := who_cares;

    end case;

    add2_out <= op1 + op2;

  end process;



  -- Adder #3 & its multiplexers

  process (del_3, del_5, reg3, state)

    variable op1, op2: signed (15 downto 0);

  begin

    case state is

      when S0 =>  op1 := del_3;       op2 := del_5;

      when S1 =>  op1 := reg3;        op2 := asr2(reg3);

      when S2 =>  op1 := who_cares;   op2 := who_cares;

      when S3 =>  op1 := who_cares;   op2 := who_cares;

    end case;

    add3_out <= op1 + op2;

  end process;



  -- Subtracter (#4) & its multiplexers

  process (reg2, reg3, reg4, state)

    variable op1, op2: signed (15 downto 0);

  begin

    case state is

      when S0 =>  op1 := who_cares;   op2 := who_cares;

      when S1 =>  op1 := reg2;        op2 := asr2(reg2);

      when S2 =>  op1 := reg3;        op2 := reg4;

      when S3 =>  op1 := who_cares;   op2 := who_cares;

    end case;

    sub4_out <= op1 - op2;

  end process;



end rtl;
