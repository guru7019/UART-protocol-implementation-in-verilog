module uart_transmitter(
    input wire [7:0] data_in,
    input wire start_tx,
    input wire clk,
    input wire baud_enable,
    output reg serial_out,
    output wire busy
);

initial begin
    serial_out = 1'b1;
end

parameter IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;

reg [7:0] tx_buffer = 8'h00;
reg [2:0] bit_index = 3'h0;
reg [1:0] tx_state = IDLE;

always @(posedge clk) begin
    case (tx_state)
        IDLE: begin
            if (start_tx) begin
                tx_buffer <= data_in;
                bit_index <= 0;
                tx_state <= START;
            end
        end
        START: if (baud_enable) begin
            serial_out <= 0;
            tx_state <= DATA;
        end
        DATA: if (baud_enable) begin
            serial_out <= tx_buffer[bit_index];
            if (bit_index == 3'h7)
                tx_state <= STOP;
            else
                bit_index <= bit_index + 1;
        end
        STOP: if (baud_enable) begin
            serial_out <= 1;
            tx_state <= IDLE;
        end
        default: begin
            serial_out <= 1;
            tx_state <= IDLE;
        end
    endcase
end

assign busy = (tx_state != IDLE);

endmodule
