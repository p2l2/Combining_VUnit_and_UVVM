-- Copyright (c) <2024> <Markus Leiter>
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
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package uart_tx_pkg is
  constant c_clk_frequency : natural := 50E6; -- 50 MHz
  constant c_clk_period : time := (1 sec)/c_clk_frequency;

  -- uart parameters
  constant c_baudrate : natural := 115200;
  constant c_baud_period : time := (1 sec) / c_baudrate;
  constant c_data_bits : natural := 8;

  -- VVC idx
  constant C_AVALON_ST_VVC       : natural := 1;
  constant C_UART_RX_VVC   : natural := 1;
  constant C_CLOCK_GEN_VVC : natural := 1;


end uart_tx_pkg;

package body uart_tx_pkg is

end uart_tx_pkg;