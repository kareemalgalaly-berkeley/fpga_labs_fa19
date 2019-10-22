`timescale 1ns/100ps

`define SECOND 1000000000
`define MS 1000000
`define CLK_PERIOD 8
`define B_SAMPLE_COUNT_MAX 5
`define B_PULSE_COUNT_MAX 5

`define CLOCK_FREQ 125_000_000
`define BAUD_RATE 115_200

module system_testbench();
    reg clk = 0;
    wire audio_pwm;
    wire [5:0] leds;
    reg [2:0] buttons;
    reg [1:0] switches;
    reg reset;
    reg done;

    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;

    // Generate system clock
    always #(`CLK_PERIOD/2) clk <= ~clk;

    z1top #(
        .B_SAMPLE_COUNT_MAX(`B_SAMPLE_COUNT_MAX),
        .B_PULSE_COUNT_MAX(`B_PULSE_COUNT_MAX),
        .CLOCK_FREQ(`CLOCK_FREQ),
        .BAUD_RATE(`BAUD_RATE)
    ) top (
        .CLK_125MHZ_FPGA(clk),
        .BUTTONS({buttons, reset}),
        .SWITCHES(switches),
        .LEDS(leds),
        .aud_pwm(audio_pwm),
        .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
        .FPGA_SERIAL_TX(FPGA_SERIAL_TX)
    );

    // Instantiate an off-chip UART here that uses the RX and TX lines
    // You can refer to the echo_testbench from lab 4
    
    // The off-chip UART (on your desktop/workstation computer)
    reg data_in_valid;
    wire data_in_ready, data_out_valid, data_out_ready;
    reg [7:0] data_in;
    wire [7:0] data_out;
    uart # (
        .CLOCK_FREQ(`CLOCK_FREQ),
        .BAUD_RATE(`BAUD_RATE)
    ) off_chip_uart (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .data_out_ready(data_out_ready),
        .serial_in(FPGA_SERIAL_TX), // Note these serial connections are the opposite of the connections to z1top
        .serial_out(FPGA_SERIAL_RX)
    );

    // tasks
    task uart_transmit;
        input [7:0] write_data;
        // Wait until the off_chip_uart's transmitter is ready
        while (data_in_ready == 1'b0) @(posedge clk); #1;
        // Send a character to the off chip UART's transmitter to transmit over the serial line
        data_in = write_data;
        data_in_valid = 1'b1;
        @(posedge clk); #1;
        data_in_valid = 1'b0;
    endtask

    task uart_recieve;
        // We wait until the on chip UART's receiver indicates that is has valid data it has received
        while (data_out_valid == 1'b0) @(posedge clk); #1;
    endtask

    // tests

    initial begin
        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("system_testbench.fst");
            $dumpvars(0,system_testbench);
        `endif
        // Simulate pushing the reset button and holding it for a while
        reset = 1'b0;
        repeat (50) @(posedge clk); #1;
        reset = 1'b1;
        repeat (50) @(posedge clk); #1;
        reset = 1'b0;

        // Send a few characters through the off_chip_uart
        done = 0;

        fork
            begin // transmit
                uart_transmit(8'h5a);
                $display("sent");
                repeat (10) begin
                    @(posedge clk);
                    $display("%b", FPGA_SERIAL_RX);
                end
            end

            begin // recieve
                uart_recieve();
                $display("recieved");
                if (data_out != 8'h5a) $display("ERROR, did not recieve what was sent %h", data_out);
                done = 1;
            end

            begin // timeout check
                repeat (50000) begin 
                    repeat (50) @(posedge clk);
                    if (done) begin
                        $display("---------------DONE--------------");
                        $finish();
                    end
                end
                if (!done) begin
                    $display("Failure: timing out");
                    $finish();
                end
            end
        join
        //#(`MS * 20); // 1/5 sec

        // TODO: Add some more stuff to test the piano
        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end
endmodule
