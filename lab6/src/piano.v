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

    output reg [23:0] tone = 24'b0
    //output volume
);
    //assign tone = 'd0;
    //assign volume = 'd0;
    //assign ua_tx_din = 0;
    //assign ua_tx_wr_en = 0;
    //assign ua_rx_rd_en = 0;

    // CLOCKGEN Variables
    localparam NOTELEN_ADJUST  = CLOCK_FREQ / 20;
    localparam NOTE_WIDTH = $clog2(CLOCK_FREQ/5) + 2; // up to 4x default
    reg [NOTE_WIDTH-1:0] note_len  = INITIAL_NOTELEN; 
    reg [NOTE_WIDTH-1:0] note_counter = 0; 
    //reg note_clk = 0;
    wire note_clk;
    assign note_clk = (note_counter == note_len);
    
    // FIFOTONE Variables
    reg [2:0] fifo_state;

    // ROM Initialization
    reg [7:0] rom_addr = 0;
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
            default : note_len <= note_len;
        endcase
        
        // adjust note_counter
        if (note_clk || rst) note_counter <= 0;
        else note_counter <= note_counter + 1;

        ///// FIFO TASKS ///// // one more if and split into case
        if (rst || (note_clk && fifo_state == 3'b000)) begin
            // can trip asynchronously so reset all fifo signals here
            // normal function
            tone <= (rst) ? 24'b0 : rom_data;
            ua_rx_rd_en <= 1'b0;
            ua_tx_wr_en <= 1'b0;
            fifo_state  <= 3'b001;
        end else begin
            if (note_clk) begin tone <= 24'b0; rom_addr <= 8'b0; end // stall
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

        //if (note_clk) begin
        //    tone <= rom_data;
        //    fifo_await_data <= 1'b1;
        //    fifo_data_recieved <= 0'b1;
        //    ua_rx_ready <= 1'b1; // trigger fetch
        //end

        //if (!ua_rx_empty && await_data) begin
        //    fifo_await_data <= 1'b0;
        //    ua_rx_rd_en <= 1'b1;
        //end

        //if (ua_rx_rd_en) begin
        //    rom_addr <= ua_rx_dout;
        //    ua_rx_rd_en <= 1'b0;
        //    fifo_data_recieved <= 1'b1;
        //end

        //if (data_recieved && !ua_tx_full) begin
        //    ua_tx_din <= rom_addr;
        //    ua_tx_wr_en <= 1'b1;
        //    fifo_data_recieved <= 1'b0;
        //end

    end

endmodule
