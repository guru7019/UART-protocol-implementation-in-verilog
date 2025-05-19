module uart_loopback_test();

reg [7:0] test_data = 0;
reg clk_tb = 0;
reg start_tx_tb = 0;

wire tx_busy_flag;
wire data_received;
wire [7:0] received_data;

wire uart_loopback;
reg clear_ready_flag = 0;

uart_top uart_dut(
    .tx_data_in(test_data),
    .tx_start(start_tx_tb),
    .clk_50mhz(clk_tb),
    .uart_tx(uart_loopback),
    .tx_is_busy(tx_busy_flag),
    .uart_rx(uart_loopback),
    .rx_ready(data_received),
    .rx_ready_clear(clear_ready_flag),
    .rx_data_out(received_data)
);

initial begin
    $dumpfile("uart_output.vcd");
    $dumpvars(0, uart_loopback_test);
    start_tx_tb <= 1;
    #2 start_tx_tb <= 0;
end

always #1 clk_tb = ~clk_tb;

always @(posedge data_received) begin
    #2 clear_ready_flag <= 1;
    #2 clear_ready_flag <= 0;
    if (received_data != test_data) begin
        $display("FAIL: Received %x, Expected %x", received_data, test_data);
        $finish;
    end else if (received_data == 8'hff) begin
        $display("SUCCESS: All bytes transmitted and received correctly");
        $finish;
    end
    test_data <= test_data + 1;
    start_tx_tb <= 1;
    #2 start_tx_tb <= 0;
end

endmodule
