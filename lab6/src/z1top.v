`timescale 1ns/1ns

module z1top #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200,
    /* verilator lint_off REALCVT */
    // Sample the button signal every 500us
    parameter integer B_SAMPLE_COUNT_MAX = 0.0005 * CLOCK_FREQ,
    // The button is considered 'pressed' after 100ms of continuous pressing
    parameter integer B_PULSE_COUNT_MAX = 0.100 / 0.0005
    /* lint_on */
) (
    input CLK_125MHZ_FPGA,
    input [3:0] BUTTONS,
    input [1:0] SWITCHES,
    output [5:0] LEDS,
    output aud_pwm,
    output aud_sd,
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
);
    assign aud_sd = 1'b1; // Enable the audio output

    wire [2:0] buttons_pressed;
    wire reset;
    button_parser #(
        .width(4),
        .sample_count_max(B_SAMPLE_COUNT_MAX),
        .pulse_count_max(B_PULSE_COUNT_MAX)
    ) bp (
        .clk(CLK_125MHZ_FPGA),
        .in(BUTTONS),
        .out({buttons_pressed, reset})
    );

    reg [7:0] data_in;
    wire [7:0] data_out;
    wire data_out_valid, data_out_ready;
    reg data_in_valid, data_in_ready; 

    // This UART is on the FPGA and communicates with your desktop
    // using the FPGA_SERIAL_TX, and FPGA_SERIAL_RX signals. The ready/valid
    // interface for this UART is used on the FPGA design.
    uart # (
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) on_chip_uart (
        .clk(CLK_125MHZ_FPGA),
        .reset(reset),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .data_out_ready(data_out_ready),
        .serial_in(FPGA_SERIAL_RX),
        .serial_out(FPGA_SERIAL_TX)
    );

    // WIRES
    wire [23:0] tone_to_play;
    wire tx_empty, tx_wr_en, tx_full;
    wire rx_empty, rx_full;
    assign data_out_ready = !rx_full;
    reg tx_rd_en;
    wire [7:0] tx_din, rx_dout;
    //assign data_in_ready = !tx_empty;

    always @(posedge CLK_125MHZ_FPGA) begin
        tx_rd_en <= !tx_empty && data_in_ready;
        data_in_valid <= tx_rd_en;
    end

    // FIFO
    // rx written by uart, read by piano
    fifo #(.data_width(8), .fifo_depth(32)) rx (
        .clk(CLK_125MHZ_FPGA), 
        .rst(reset),
        .wr_en(data_out_valid),
        .din(data_out),
        .full(rx_full),
        .rd_en(rx_rd_en),
        .dout(rx_dout),
        .empty(rx_empty)
    );
    // tx written by piano, read by uart
    fifo #(.data_width(8), .fifo_depth(32)) tx (
        .clk(CLK_125MHZ_FPGA), 
        .rst(reset),
        .wr_en(tx_wr_en),
        .din(tx_din),
        .full(tx_full),
        .rd_en(tx_rd_en),
        .dout(data_in),
        .empty(tx_empty)
    );

    // PIANO
    piano #(CLOCK_FREQ) pi (
        .clk(CLK_125MHZ_FPGA),
        .rst(reset),
        .buttons(buttons),
        .switches(switches),
        .leds(leds),
        .ua_tx_din(tx_din),
        .ua_tx_wr_en(tx_wr_en),
        .ua_tx_full(tx_full),
        .ua_rx_dout(rx_dout),
        .ua_rx_empty(rx_empty), 
        .ua_rx_rd_en(rx_rd_en),
        .tone(tone_to_play)
    );
    
    // TONE GENERATOR
    tone_generator tgen(
        .clk(CLK_125MHZ_FPGA),
        .rst(reset),
        .output_enable(switches[0]),
        .tone_switch_period(tone_to_play),
        .volume(switches[1]),
        .square_wave_out(aud_pwm)
    );

    //// TODO: Instantiate the UART FIFOs, tone_generator, and piano
    //assign aud_pwm = 0; // Comment this out when ready
    //assign LEDS[5:0] = 6'b11_0001; // Assign to output of the piano


endmodule
