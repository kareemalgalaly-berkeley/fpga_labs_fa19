`timescale 1ns/1ns

module z1top (
    input CLK_125MHZ_FPGA,
    input [3:0] BUTTONS,
    input [1:0] SWITCHES,
    output [5:0] LEDS,
    output aud_pwm,
    output aud_sd
);
    wire [31:0] counter;

    assign aud_sd = 1;

    tone_generator dut(.clk(CLK_125MHZ_FPGA), .square_wave_out(aud_pwm), .tone_switch_period(BUTTONS[3:0] << 16), .output_enable(SWITCHES[0]), .volume(SWITCHES[1]), ._counter(counter));
endmodule
