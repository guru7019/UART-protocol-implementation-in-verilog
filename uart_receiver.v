module uart_receiver(
    input wire serial_in,
    output reg data_ready,
    input wire clear_ready,
    input wire clk,
    input wire baud_enable,
    output reg [7:0] data_out
);

initial begin
    data_ready = 0;
    data_out = 0;
end

parameter START = 2'b00, DATA = 2'b01, STOP = 2'b10;

reg [1:0] rx_state = START;
reg [3:0] sample_count = 0;
reg [3:0] bit_counter = 0;
reg [7:0] temp_data = 0;

always @(posedge clk) begin
    if (clear_ready)
        data_ready <= 0;

    if (baud_enable) begin
        case (rx_state)
            START: begin
                if (!serial_in || sample_count != 0)
                    sample_count <= sample_count + 1;
                if (sample_count == 15) begin
                    rx_state <= DATA;
                    sample_count <= 0;
                    bit_counter <= 0;
                    temp_data <= 0;
                end
            end
            DATA: begin
                sample_count <= sample_count + 1;
                if (sample_count == 8) begin
                    temp_data[bit_counter] <= serial_in;
                    bit_counter <= bit_counter + 1;
                end
                if (bit_counter == 8 && sample_count == 15)
                    rx_state <= STOP;
            end
            STOP: begin
                if (sample_count == 15 || (sample_count >= 8 && !serial_in)) begin
                    data_out <= temp_data;
                    data_ready <= 1;
                    sample_count <= 0;
                    rx_state <= START;
                end else begin
                    sample_count <= sample_count + 1;
                end
            end
            default: rx_state <= START;
        endcase
    end
end

endmodule
