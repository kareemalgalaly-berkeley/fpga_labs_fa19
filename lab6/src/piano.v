module piano #(
    parameter CLOCK_FREQ = 125_000_000
) (
    input clk,
    input rst,

    input [2:0] buttons,
    input [1:0] switches,
    output [5:0] leds,

    output [7:0] ua_tx_din,
    output ua_tx_wr_en,
    input ua_tx_full,

    input [7:0] ua_rx_dout,
    input ua_rx_empty, 
    output reg ua_rx_rd_en,

    output reg [23:0] tone,
    output volume
);
    //assign tone = 'd0;
    //assign volume = 'd0;
    //assign ua_tx_din = 0;
    //assign ua_tx_wr_en = 0;
    //assign ua_rx_rd_en = 0;

    // CLOCKGEN Variables
    localparam INITIAL_NOTELEN = CLOCK_FREQ / 5;
    localparam NOTELEN_ADJUST  = CLOCK_FREQ / 20;
    localparam NOTE_WIDTH = $clog2(CLOCK_FREQ/5) + 1;
    reg [NOTE_WIDTH-1:0] note_len  = INITIAL_NOTELEN; // can fit double default
    reg [NOTE_WIDTH-1:0] note_counter = 0; // counts up to note_len
    //reg note_clk = 0;
    wire note_clk;
    assign note_clk = (note_counter == note_len);
    
    // FIFOTONE Variables
    reg [7:0] transmit_data;
    reg transmit_data_ready;
    reg tone_read;

    // ROM Initialization
    reg [7:0] rom_addr;
    wire [23:0] rom_data;
    wire [7:0] rom_laddr;
    piano_scale_rom rom(rom_addr, rom_data, rom_laddr);

    // always 
    
    /*// note_clock generator 
    always @(posedge clk) begin
        //if (rst) begin
        //    note_counter <= 1'b0;
        //    note_clk;
        //end else begin
        if (note_counter == note_len || rst) begin
            note_counter <= 0;
            note_clk <= ~rst;
        else begin
            note_counter <= note_counter + 1;
            note_clk <= 1'b0;
        end
        //end
    end*/

    //// note_len adjuster, and tone output
    // main
    always @(posedge clk) begin
        ///// BACKGROUND TASKS ///// 
        
        // adjust note_len
        casez ({rst, buttons[0], switches[0]})
            3'b1?? : note_len <= INITIAL_NOTELEN; // reset
            3'b011 : note_len <= INITIAL_NOTELEN + NOTELEN_ADJUST; // increase
            3'b010 : note_len <= INITIAL_NOTELEN - NOTELEN_ADJUST; // decrease
        endcase
        
        // adjust note_counter
        if (note_clk || rst) begin
            note_counter <= 0;
        else begin
            note_counter <= note_counter + 1;
        end

        ///// FIFO TASKS ///// 
        // broken
        
        if (note_clk) begin
            tone <= rom_data;
            tone_read <= 1'b1;
            ua_rx_ready <= 1'b1; // trigger fetch
        end

        // write condition
        if (transmit_data_ready && !ua_tx_full) begin
            ua_tx_din <= transmit_data;
            ua_tx_wr_en <= 1'b1;
            transmit_data_ready <= 1'b0;
        end else ua_tx_wr_en <= 0;

        if (ua_rx_valid) begin
            // read
            ua_rx_ready <= 1'b0;
            rom_addr <= ua_rx_dout;
        end


    end

endmodule
