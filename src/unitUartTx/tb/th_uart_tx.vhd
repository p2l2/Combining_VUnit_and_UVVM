--================================================================================================================================
-- Copyright 2024 UVVM
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and in the provided LICENSE.TXT.
--
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
-- an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and limitations under the License.
--================================================================================================================================
-- Note : Any functionality not explicitly described in the documentation is subject to change at any time
----------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Description   : See library quick reference (under 'doc') and README-file(s)
------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library uvvm_util;
context uvvm_util.uvvm_util_context; 

library bitvis_vip_avalon_st;
context bitvis_vip_avalon_st.vvc_context;

library bitvis_vip_uart;
context bitvis_vip_uart.vvc_context;

library bitvis_vip_clock_generator;

library bitvis_vip_scoreboard;
use bitvis_vip_scoreboard.generic_sb_support_pkg.all;

use work.uart_tx_pkg.all;

-- Test harness entity
entity th_uart_tx is
end entity th_uart_tx;

-- Test harness architecture
architecture struct of th_uart_tx is

  -- Clock and reset signals
  signal clk  : std_logic := '0';
  signal n_reset : std_logic := '0';

-- Avalon Streaming Interface
  signal avalon_st_source_if : t_avalon_st_if(
    channel(0 downto 0),
    data(c_data_bits - 1 downto 0),
    data_error(0 downto 0),
    empty(0 downto 0)
    ) := init_avalon_st_if_signals(true, 1, c_data_bits, 1, 1);

  -- UART VVC signals
  signal uart_vvc_rx : std_logic := '1';

  
    ----------------------------------------
  -- avalon streaming source BFM configuration
  ----------------------------------------
  constant C_AVALON_ST_SOURCE_BFM_CONFIG : t_avalon_st_bfm_config := (
    max_wait_cycles                => 5000,
    max_wait_cycles_severity       => error,
    clock_period                   => c_clk_period,
    clock_period_margin            => 0 ns,
    clock_margin_severity          => TB_ERROR,
    setup_time                     => c_clk_period/4,
    hold_time                      => c_clk_period/4,
    bfm_sync                       => SYNC_ON_CLOCK_ONLY,
    match_strictness               => MATCH_EXACT,
    symbol_width                   => c_data_bits,
    first_symbol_in_msb            => true,
    max_channel                    => 1,
    use_packet_transfer            => true,
    valid_low_at_word_idx          => 0,
    valid_low_multiple_random_prob => 0.5,
    valid_low_duration             => 0,
    valid_low_max_random_duration  => 5,
    ready_low_at_word_idx          => 0,
    ready_low_multiple_random_prob => 0.5,
    ready_low_duration             => 0,
    ready_low_max_random_duration  => 5,
    ready_default_value            => '0',
    id_for_bfm                     => ID_BFM
    );

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  -----------------------------------------------------------------------------
  -- Instantiate DUT
  -----------------------------------------------------------------------------
  i_uart_tx : entity work.uart_tx
    generic map(
      g_clk_frequency => c_clk_frequency, 
      g_baudrate     => c_baudrate,       
      g_data_bits    => c_data_bits
    )
    port map(
      i_clk     => clk,
      i_n_reset => n_reset,
      o_tx      => uart_vvc_rx,
      i_data    =>  avalon_st_source_if.data,
      i_valid   =>  avalon_st_source_if.valid,
      o_ready   =>  avalon_st_source_if.ready
    );

  -----------------------------------------------------------------------------
  -- Avalon Streaming
  -----------------------------------------------------------------------------
  i_avalon_st_source : entity bitvis_vip_avalon_st.avalon_st_vvc
    generic map(
      GC_VVC_IS_MASTER        => true,
      GC_CHANNEL_WIDTH        => avalon_st_source_if.channel'length,
      GC_DATA_WIDTH           => avalon_st_source_if.data'length,
      GC_DATA_ERROR_WIDTH     => avalon_st_source_if.data_error'length,
      GC_EMPTY_WIDTH          => avalon_st_source_if.empty'length,
      GC_INSTANCE_IDX         => C_AVALON_ST_VVC,
      GC_AVALON_ST_BFM_CONFIG => C_AVALON_ST_SOURCE_BFM_CONFIG)
    port map(
      clk              => clk,
      avalon_st_vvc_if => avalon_st_source_if);

  -----------------------------------------------------------------------------
  -- UART VVC
  -----------------------------------------------------------------------------
  i1_uart_vvc : entity bitvis_vip_uart.uart_vvc
    generic map(
      GC_INSTANCE_IDX => C_UART_RX_VVC
    )
    port map(
      uart_vvc_rx => uart_vvc_rx,
      uart_vvc_tx => open
    );

  -----------------------------------------------------------------------------
  -- Clock Generator VVC
  -----------------------------------------------------------------------------

  i_clock_generator_vvc : entity bitvis_vip_clock_generator.clock_generator_vvc
    generic map(
      GC_INSTANCE_IDX    => C_CLOCK_GEN_VVC,
      GC_CLOCK_NAME      => "Clock",
      GC_CLOCK_PERIOD    => c_clk_period,
      GC_CLOCK_HIGH_TIME => c_clk_period / 2
    )
    port map(
      clk => clk
    );

  -----------------------------------------------------------------------------
  -- Reset
  -----------------------------------------------------------------------------

  -- Toggle the reset after 5 clock periods
  p_n_reset : n_reset <= '0', '1' after 5 * c_clk_period;

end struct;
