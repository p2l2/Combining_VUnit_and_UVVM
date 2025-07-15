-- Copyright (c) <2024> P2L2 GmbH <info@p2l2.com> <Markus Leiter>
-- License: MIT
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
-- documentation files (the “Software”), to deal in the Software without restriction, including without limitation 
-- the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
-- LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
-- SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
-- OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.uart_tx_pkg.all;

-- This is a very simple UART transmitter used for teaching at the University of Applied Sciences Upper Austria in Hagenberg. 
entity uart_tx is
  generic (
    g_clk_frequency : natural := 50E6; -- [Hz]
    g_baudrate : natural := 115200; -- Hz
    g_data_bits : natural := 8
  );
  port (
    i_clk : in std_ulogic;
    i_n_reset : in std_ulogic;
    -- UART tx line
    o_tx : out std_ulogic;
    -- streaming sink interface
    i_data : in std_ulogic_vector(g_data_bits - 1 downto 0);
    i_valid : in std_ulogic;
    o_ready : out std_ulogic
  );
end entity uart_tx;

architecture Rtl of uart_tx is

  constant c_clock_per_baud : natural := g_clk_frequency/g_baudrate;
  constant cbaud_strobe_bits : natural := natural(ceil(log2(real(c_clock_per_baud))));

  type State_t is (Idle, Start, data, Stop);

  -- Register set
  type reg_set_t is record
    State : State_t;
    baud_strobe_counter : unsigned(cbaud_strobe_bits - 1 downto 0); -- strobe gen counter
    baud_strobe : std_ulogic;
    data_bit_count : natural range 0 to g_data_bits - 1;
    data : std_ulogic_vector(g_data_bits - 1 downto 0);
    valid : std_ulogic;
    tx : std_ulogic;

  end record;

  -- Reset Values
  constant cInitValR : reg_set_t := (
    State => Idle,
    baud_strobe_counter => (others => '0'),
    baud_strobe => '0',
    data => (others => '0'),
    data_bit_count => 0,
    valid => '0',
    tx => '1' -- idle high
  );

  -- Define the Register signals
  signal R, nxr : reg_set_t;

begin

  Registers : process (i_clk, i_n_reset)
  begin
    if i_n_reset = '0' then
      R <= cInitValR;
    elsif rising_edge(i_clk) then
      R <= nxr;
    end if;
  end process;

  process (all)
  begin
    nxr <= R;
    o_ready <= '0'; -- the unit is not ready per default. It is only ready during the Idle state.
    -- baud_strobe gen
    nxr.baud_strobe <= '0';
    nxr.baud_strobe_counter <= R.baud_strobe_counter + 1;
    if R.baud_strobe_counter = c_clock_per_baud - 1 then
      nxr.baud_strobe_counter <= (others => '0');
      nxr.baud_strobe <= '1';
    end if;

    case R.State is
      when Idle =>
        nxr.tx <= '1';
        o_ready <= '1';
        -- detect an input on the streaming interface
        if i_valid = '1' then
          nxr.data <= i_data;
          nxr.baud_strobe_counter <= (others => '0');
          nxr.baud_strobe <= '0';
          nxr.State <= Start;
        end if;

      when Start =>
        nxr.tx <= '0';
        if R.baud_strobe = '1' then
          nxr.State <= data;
        end if;

      when data =>
        nxr.tx <= R.data(R.data_bit_count);

        if R.baud_strobe = '1' then
          if R.data_bit_count = g_data_bits - 1 then
            nxr.State <= Stop;
            nxr.data_bit_count <= 0; -- reset the bit counter
          else
            nxr.data_bit_count <= R.data_bit_count + 1;
          end if;

        end if;

      when Stop =>
        nxr.tx <= '1';
        if R.baud_strobe = '1' then -- center of the Stop bit
          nxr.State <= Idle;
        end if;

      when others =>
        nxr.State <= Idle;
    end case;

  end process;

  o_tx <= R.tx;

end architecture;