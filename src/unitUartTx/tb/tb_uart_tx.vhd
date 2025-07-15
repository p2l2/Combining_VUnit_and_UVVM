-- Copyright (c) <2025> P2L2 GmbH <info@p2l2.com> <Markus Leiter>
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_run_context;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_avalon_st;
context bitvis_vip_avalon_st.vvc_context;

library bitvis_vip_uart;
context bitvis_vip_uart.vvc_context;

library bitvis_vip_clock_generator;
context bitvis_vip_clock_generator.vvc_context;

use work.uart_tx_pkg.all;

-- Test bench entity
entity tb_uart_tx is
  generic (
    runner_cfg : string := runner_cfg_default);
end entity tb_uart_tx;

-- Test bench architecture
architecture behav of tb_uart_tx is

begin
  -----------------------------------------------------------------------------
  -- Instantiate test harness
  -----------------------------------------------------------------------------
  i_test_harness : entity work.th_uart_tx;

  ------------------------------------------------
  -- PROCESS: p_main: The test sequencer
  ------------------------------------------------
  p_main : process
    variable v_data : t_slv_array(0 to 3)(c_data_bits - 1 downto 0);  -- data to be sent
  begin

    -- initialize VUnit
    test_runner_setup(runner, runner_cfg);

    -- Wait for UVVM to finish initialization
    await_uvvm_initialization(VOID);

    -- Set verbosity level
    --============================================================================================================
    --enable_log_msg(ALL_MESSAGES);
    disable_log_msg(ALL_MESSAGES);
    enable_log_msg(ID_LOG_HDR);
    enable_log_msg(ID_LOG_HDR_XL);
    enable_log_msg(ID_SEQUENCER);
    enable_log_msg(ID_SEQUENCER_SUB);
    enable_log_msg(ID_UVVM_SEND_CMD);
    enable_log_msg(ID_AWAIT_UVVM_COMPLETION);
    --enable_log_msg(ID_BFM);

    disable_log_msg(AVALON_ST_VVCT, C_AVALON_ST_VVC, ALL_MESSAGES);
    enable_log_msg(AVALON_ST_VVCT, C_AVALON_ST_VVC, ID_BFM);
    enable_log_msg(AVALON_ST_VVCT, C_AVALON_ST_VVC, ID_FINISH_OR_STOP);

    disable_log_msg(UART_VVCT, C_UART_RX_VVC, RX, ALL_MESSAGES);
    enable_log_msg(UART_VVCT, C_UART_RX_VVC, RX, ID_BFM);

    -- Print the configuration to the log
    -- report_global_ctrl(VOID);
    -- report_msg_id_panel(VOID);


    log(ID_LOG_HDR, "Configure UART VVC 1", C_SCOPE);
    --============================================================================================================
    shared_uart_vvc_config(RX, C_UART_RX_VVC).bfm_config.bit_time        := c_baud_period;
    shared_uart_vvc_config(RX, C_UART_RX_VVC).bfm_config.num_stop_bits   := STOP_BITS_ONE;
    shared_uart_vvc_config(RX, C_UART_RX_VVC).bfm_config.parity          := PARITY_NONE;
    shared_uart_vvc_config(RX, C_UART_RX_VVC).unwanted_activity_severity := NO_ALERT;

    -----------------------------------------------------------------------------
    -- Tests
    --   Comment out tests below to run a selection of tests.
    -----------------------------------------------------------------------------
    -- common part of all test cases: start clock and await reset release
    wait for 2 * c_clk_period;
    start_clock(CLOCK_GENERATOR_VVCT, C_CLOCK_GEN_VVC, "Start clock generator");
    -- for simplification of the test harness, the reset is released after 10 clock cycles always
    -- wait for 10 * c_clk_period to await for the reset release
    wait for 10 * c_clk_period;


    if run("single_byte") then          -- first test case
      v_data(0) := x"AB";
      avalon_st_transmit(AVALON_ST_VVCT, C_AVALON_ST_VVC, v_data(0 to 0), "Send" & to_hex_string(v_data(0)));  -- send single byte
      uart_expect(UART_VVCT, C_UART_RX_VVC, RX, v_data(0), "Expect " & to_hex_string(v_data(0)));  -- expect the same byte on the UART RX line
      await_completion(UART_VVCT, C_UART_RX_VVC, RX, 11 * c_baud_period);  -- await for the completion of the UART RX VVC -> wait until the expected byte is received

    elsif run("4_bytes") then           -- second test case
      v_data := (x"FF", x"00", x"41", x"10");
      avalon_st_transmit(AVALON_ST_VVCT, C_AVALON_ST_VVC, v_data, "Send 4 bytes");
      for i in v_data'range loop
        uart_expect(UART_VVCT, C_UART_RX_VVC, RX, v_data(i), "Expect " & to_hex_string(v_data(i)));
      end loop;

    elsif run("simple_random") then     -- third test case
      for i in 0 to 100 loop
        v_data(0) := random(v_data(0)'length);
        avalon_st_transmit(AVALON_ST_VVCT, C_AVALON_ST_VVC, v_data(0 to 0), "Send " & to_hex_string(v_data(0)));
        uart_expect(UART_VVCT, C_UART_RX_VVC, RX, v_data(0), "Expect " & to_hex_string(v_data(0)));
        await_completion(UART_VVCT, C_UART_RX_VVC, RX, 11 * c_baud_period);
      end loop;

    end if;

    -----------------------------------------------------------------------------
    -- Ending the simulation
    -----------------------------------------------------------------------------
    await_uvvm_completion(10 ms, error, 1 ns, REPORT_ALERT_COUNTERS_FINAL, REPORT_SCOREBOARDS, REPORT_VVCS, C_SCOPE);

    -- check if expected and actual number of errors/failures match
    -- This is necessary to ensure VUnit detects unexpected UVVM errors
    check_value(shared_uvvm_status.mismatch_on_expected_simulation_errors_or_worse, 0, failure, "mismatch on expected and actual alerts!");

    -- Finish the simulation
    test_runner_cleanup(runner);

  end process p_main;

end behav;
