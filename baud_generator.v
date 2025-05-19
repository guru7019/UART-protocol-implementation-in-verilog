module baud_generator(
    input wire clk_50mhz,
    output wire rx_clk_enable,
    output wire tx_clk_enable
);

parameter RX_DIVISOR = 50000000 / (115200 * 16);
parameter TX_DIVISOR = 50000000 / 115200;

parameter RX_WIDTH = $clog2(RX_DIVISOR);
parameter TX_WIDTH = $clog2(TX_DIVISOR);

reg [RX_WIDTH - 1:0] rx_counter = 0;
reg [TX_WIDTH - 1:0] tx_counter = 0;

assign rx_clk_enable = (rx_counter == 0);
assign tx_clk_enable = (tx_counter == 0);

always @(posedge clk_50mhz) begin
    if (rx_counter == RX_DIVISOR[RX_WIDTH - 1:0])
        rx_counter <= 0;
    else
        rx_counter <= rx_counter + 1;
end

always @(posedge clk_50mhz) begin
    if (tx_counter == TX_DIVISOR[TX_WIDTH - 1:0])
        tx_counter <= 0;
    else
        tx_counter <= tx_counter + 1;
end

endmodule
