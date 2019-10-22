module music_streamer (
    input clk,
    input rst,
    input tempo_up,
    input tempo_down,
    input play_pause,
    input reverse,
    output [2:0] leds,
    output [23:0] tone
);
    // Instantiations
    reg [22:0] counter = 0;
    reg [22:0] max_counter = 23'd5_000_000; // for tempo up/down
    reg [1:0] state = 2'b01; // 00 paused, 01 play, 11 reverse play
    reg [23:0] tone_reg = 0;

    // Output Wire
    assign tone    = state[0] ? tone_reg : 0; // pause
    assign leds[0] = state == 2'b01;
    assign leds[1] = ~state[0];
    assign leds[2] = state[1];

    // ROM 
    reg [9:0] rom_addr = 0;
    wire [23:0] rom_data;
    wire [9:0] rom_ladd;
    rom musicrom(.address(rom_addr), .data(rom_data), .last_address(rom_ladd));

    // counter / rom access loop
    always @(posedge clk) begin
        if (rst) begin
            counter = 0;
            rom_addr = 0;
            max_counter = 23'd5_000_000;
        end
        if (tempo_up) max_counter = max_counter + 23'd500_000;
        if (tempo_down) max_counter = max_counter - 23'd500_000;

        if (counter >= max_counter) begin
            counter = 0;
            tone_reg <= rom_data;
            case (state)
                2'b01 : rom_addr <= (rom_addr == rom_ladd) ? 0 : rom_addr + 1;
                2'b11 : rom_addr <= (rom_addr == 0) ? rom_ladd : rom_addr - 1;
                default : rom_addr <= rom_addr;
            endcase
            //if (state[1]) rom_addr <= (rom_addr == 0) ? rom_ladd : rom_addr - state[0];
            //else rom_addr <= (rom_addr == rom_ladd) ? 0 : rom_addr + state[0];
        end else counter = counter + 1;
    end

    // state machine (lol)
    always @(posedge clk) begin
        casez ({play_pause, reverse, state[0]})
            3'b1?0 : state <= 2'b01; //pause->play
            3'b1?1 : state <= 2'b00; //play->pause
            3'b011 : state[1] <= ~state[1]; // reverse (while playing)
            default : state <= state; 
        endcase
    end

endmodule

