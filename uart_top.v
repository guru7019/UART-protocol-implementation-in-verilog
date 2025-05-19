module uart_top(
    input wire [7:0] tx_data_in,
    input wire tx_start,
    input wire clk_50mhz,
    output wire uart_tx,
    output wire tx_is_busy,
    input wire uart_rx,
    output wire rx_ready,
    input wire rx_ready_clear,
    output wire [7:0] rx_data_out
);

wire rx_baud_enable, tx_baud_enable;

baud_generator baud_inst(
    .clk_50mhz(clk_50mhz),
    .rx_clk_enable(rx_baud_enable),
    .tx_clk_enable(tx_baud_enable)
);

uart_transmitter tx_module(
    .data_in(tx_data_in),
    .start_tx(tx_start),
    .clk(clk_50mhz),
    .baud_enable(tx_baud_enable),
    .serial_out(uart_tx),
    .busy(tx_is_busy)
);

uart_receiver rx_module(
    .serial_in(uart_rx),
    .data_ready(rx_ready),
    .clear_ready(rx_ready_clear),
    .clk(clk_50mhz),
    .baud_enable(rx_baud_enable),
    .data_out(rx_data_out)
);

endmodule
