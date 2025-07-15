onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_uart_tx/i_test_harness/clk
add wave -noupdate -color Cyan -expand -subitemconfig {/tb_uart_tx/i_test_harness/avalon_st_source_if.channel {-color Cyan} /tb_uart_tx/i_test_harness/avalon_st_source_if.data {-color Cyan} /tb_uart_tx/i_test_harness/avalon_st_source_if.data_error {-color Cyan} /tb_uart_tx/i_test_harness/avalon_st_source_if.ready {-color Cyan} /tb_uart_tx/i_test_harness/avalon_st_source_if.valid {-color Cyan} /tb_uart_tx/i_test_harness/avalon_st_source_if.empty {-color Cyan} /tb_uart_tx/i_test_harness/avalon_st_source_if.end_of_packet {-color Cyan} /tb_uart_tx/i_test_harness/avalon_st_source_if.start_of_packet {-color Cyan}} /tb_uart_tx/i_test_harness/avalon_st_source_if
add wave -noupdate /tb_uart_tx/i_test_harness/uart_vvc_rx
add wave -noupdate -expand -group Uart_TX /tb_uart_tx/i_test_harness/i_uart_tx/o_tx
add wave -noupdate -expand -group Uart_TX -expand /tb_uart_tx/i_test_harness/i_uart_tx/i_data
add wave -noupdate -expand -group Uart_TX /tb_uart_tx/i_test_harness/i_uart_tx/o_ready
add wave -noupdate -expand -group Uart_TX -childformat {{/tb_uart_tx/i_test_harness/i_uart_tx/R.baud_strobe_counter -radix unsigned} {/tb_uart_tx/i_test_harness/i_uart_tx/R.data_bit_count -radix unsigned}} -expand -subitemconfig {/tb_uart_tx/i_test_harness/i_uart_tx/R.baud_strobe_counter {-color Coral -format Analog-Step -height 74 -max 433.0 -radix unsigned} /tb_uart_tx/i_test_harness/i_uart_tx/R.data_bit_count {-format Analog-Step -height 74 -max 7.0 -radix unsigned}} /tb_uart_tx/i_test_harness/i_uart_tx/R
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1439799046 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {492226381 ps}
