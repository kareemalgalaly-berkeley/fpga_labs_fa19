`timescale 1ns/1ns
module tone_generator (
    input clk,
    input output_enable,
    input [23:0] tone_switch_period,
    input volume,
    output square_wave_out,
    output [32:0] _counter
);
    reg [32:0] counter = 32'h0000_0001; // true min is 20 for the default settings
    reg pwm_out;

    assign square_wave_out = pwm_out;
    assign _counter = counter;

    always @(posedge clk or negedge clk) begin
        if (counter == 32'h0000_0001) begin
            pwm_out <= ~pwm_out;
            counter <= tone_switch_period;
            //counter <= 284091;
        end else begin
            counter <= counter - 1;
        end
    end
endmodule
