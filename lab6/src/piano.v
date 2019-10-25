`define VARIABLE_LENGTH

module piano #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter INITIAL_NOTELEN = CLOCK_FREQ / 5
) (
    input clk,
    input rst,

    input [2:0] buttons,
    input [1:0] switches,
    output [5:0] leds,

    output reg [7:0] ua_tx_din = 8'b0,
    output reg ua_tx_wr_en = 1'b0,
    input ua_tx_full,

    input [7:0] ua_rx_dout,
    input ua_rx_empty, 
    output reg ua_rx_rd_en = 1'b0,

    output [23:0] tone
    //output volume
);

    // CLOCKGEN Variables
    localparam NOTELEN_ADJUST  = CLOCK_FREQ / 20;
    localparam NOTE_WIDTH = $clog2(CLOCK_FREQ/5) + 2; // up to 4x default
    reg [NOTE_WIDTH-1:0] note_len  = INITIAL_NOTELEN; 
    reg [NOTE_WIDTH-1:0] note_counter = 0; 
    //reg note_clk = 0;
    wire note_clk;
    assign note_clk = (note_counter == note_len);
    
    // FIFOTONE Variables
    reg [7:0] curr_char = 8'b0;
    reg curr_pressed = 1'b0;
    reg reading_id = 1'b0;

    // ROM Initialization
    reg [7:0] rom_addr = 0;
    wire [23:0] rom_data;
    wire [7:0] rom_laddr;
    piano_scale_rom rom(rom_addr, rom_data, rom_laddr);

`ifndef VARIABLE_LENGTH
    // FIXED LENGTH
    reg [2:0] fifo_state;
    reg [23:0] tone_fixed = 24'b0;
    assign tone = tone_fixed;
    // main
    always @(posedge clk) begin
        ///// BACKGROUND TASKS ///// 
        
        // adjust note_len
        casez ({rst, buttons[0], switches[0]})
            3'b1?? : note_len <= INITIAL_NOTELEN; // reset
            3'b011 : note_len <= INITIAL_NOTELEN + NOTELEN_ADJUST; // increase
            3'b010 : note_len <= INITIAL_NOTELEN - NOTELEN_ADJUST; // decrease
            default : note_len <= note_len;
        endcase
        
        // adjust note_counter
        if (note_clk || rst) note_counter <= 0;
        else note_counter <= note_counter + 1;

        ///// FIFO TASKS ///// // one more if and split into case
        if (rst || (note_clk && fifo_state == 3'b000)) begin
            // can trip asynchronously so reset all fifo signals here
            // normal function
            tone_fixed <= (rst) ? 24'b0 : rom_data;
            ua_rx_rd_en <= 1'b0;
            ua_tx_wr_en <= 1'b0;
            fifo_state  <= 3'b001;
        end else begin
            if (note_clk) begin tone_fixed <= 24'b0; rom_addr <= 8'b0; end // stall
            else case (fifo_state) 
                //fifo_state = 2'b00 < nothing, 2'b01 < look to read, 2'b11 < reading, 2'b10 look to write
                3'b001 : if (!ua_rx_empty) begin // wait until data arrive
                            ua_rx_rd_en <= 1'b1;
                            fifo_state  <= 3'b011;
                        end
                3'b011 : begin // data neady next cycle
                            ua_rx_rd_en <= 1'b0;
                            fifo_state <= 3'b010;
                        end
                3'b010 : begin // data here
                            rom_addr <= ua_rx_dout;
                            fifo_state  <= 3'b110;
                        end
                3'b110 : if (!ua_tx_full) begin // wait until next fifo ready
                            ua_tx_din <= rom_addr;
                            ua_tx_wr_en <= 1'b1;
                            fifo_state  <= 3'b000;
                        end
                default : begin
                            ua_tx_wr_en <= 1'b0;
                            fifo_state <= 3'b000;
                        end
            endcase
        end
    end
`endif

`ifdef VARIABLE_LENGTH
    // ADJUSTABLE LENGTH
    reg [3:0] fifo_state = 0;
    assign tone = (curr_pressed) ? rom_data : 24'b0;
    assign leds[5] = curr_pressed;

    always @(posedge clk) begin
        //reg curr_pressed = 1'b0;
        //reg reading_id = 1'b0;
        //state
        case (fifo_state) 
            4'b0000 : begin // waiting for id keypress
                          ua_rx_rd_en <= 1'b1;
                          if (!ua_rx_empty) begin
                              fifo_state  <= 4'b0001;
                          end
                      end
            4'b0001 : begin // id ready next cycle
                        ua_rx_rd_en <= 1'b0;
                        fifo_state <= 4'b0011;
                      end
            4'b0011 : begin // id data here
                        if (ua_rx_dout == 8'h81) fifo_state <= 4'b1010; //1 means released
                        else fifo_state <= 4'b0010; //0 means pressed
                      end
            4'b0010 : begin // waiting for char keypress (PRESS MODE)
                          ua_rx_rd_en <= 1'b1;
                          if (!ua_rx_empty) begin
                              fifo_state  <= 4'b0110;
                          end
                      end
            4'b0110 : begin // char ready next cycle
                        ua_rx_rd_en <= 1'b0;
                        fifo_state <= 4'b0111;
                      end
            4'b0111 : begin // char data here
                        if (!curr_pressed) begin 
                            rom_addr <= ua_rx_dout;
                            curr_pressed <= 1'b1;
                        end
                        fifo_state <= 4'b0000;
                      end
            4'b1010 : begin // waiting for char keypress (RELEASE MODE)
                          ua_rx_rd_en <= 1'b1;
                          if (!ua_rx_empty) begin
                              fifo_state  <= 4'b1110;
                          end
                      end
            4'b1110 : begin // char ready next cycle
                        ua_rx_rd_en <= 1'b0;
                        fifo_state <= 4'b1111;
                      end
            4'b1111 : begin // char data here
                        if (curr_pressed && (rom_addr == ua_rx_dout)) curr_pressed <= 1'b0;
                        fifo_state <= 4'b0000;
                      end
            default : fifo_state <= 4'b0000;
        endcase
    end
`endif
endmodule

