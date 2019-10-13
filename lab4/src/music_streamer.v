module music_streamer (
    input clk,
    input rst,
    input tempo_up,
    input tempo_down,
    input play_pause,
    input reverse,
    output [2:0] leds,
    output reg [23:0] tone = 0
);
    // Instantiations
    reg [22:0] counter = 0;
    reg [22:0] max_counter = 23'd5_000_000;

    // ROM 
    reg [9:0] rom_addr = 0;
    wire [23:0] rom_data;
    wire [9:0] rom_ladd;
    rom musicrom(.address(rom_addr), .data(rom_data), .last_address(rom_ladd));

    // main
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
            tone <= rom_data;
            rom_addr <= rom_addr + 1;
        end
        else counter = counter + 1;
    end
endmodule
