`timescale 1ns/1ns

module z1top (
    input CLK_125MHZ_FPGA,
    input [3:0] BUTTONS,
    input [1:0] SWITCHES,
    output [5:0] LEDS,
    output aud_pwm,
    output aud_sd
);
    // TODO(you): Your code here. Remove the following lines once you add your implementation.
    assign aud_sd = 1;
    tone_generator dut(.clk(CLK_125MHZ_FPGA), .square_wave_out(aud_pwm), .tone_switch_period(24'd284091), .output_enable(1'b1));
endmodule
