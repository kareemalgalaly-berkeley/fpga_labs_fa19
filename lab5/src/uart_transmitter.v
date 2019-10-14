module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);

    // Initializations
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter = 0;
    reg transmit_clock = 0;
    reg [8:0] data_in_hold;
    wire busy;

    reg [9:0] shift_reg = 10'b1111111111;
    reg [3:0] bits_remaining = 0;

    // Wires
    assign data_in_ready = !busy;
    assign busy = |bits_remaining;
    assign serial_out = shift_reg[0];

    // generate transmit clock
    always @(posedge clk) begin
        if (clock_counter == 0) begin
            clock_counter <= SYMBOL_EDGE_TIME;
            transmit_clock <= 1'b1; // posedge
        end else begin
            clock_counter <= clock_counter - 1;
            transmit_clock <= 1'b0; // negedge
        end
        if (data_in_valid) data_in_hold = {1'b1, data_in};
        else if (busy) data_in_hold[8] = 1'b0;
    end

    // transmission
    always @(posedge transmit_clock) begin
        // prepare to send
        if (data_in_hold[8] && !busy) begin
            shift_reg <= {1'b1, data_in_hold[7:0], 1'b0};
            bits_remaining <= 4'd10;
        end else begin
            // shift away
            shift_reg <= {1'b1, shift_reg[9:1]}; // shift (pad with 1)
            bits_remaining <= (bits_remaining - 1) && busy; // min_clamp@0
        end
    end

endmodule
