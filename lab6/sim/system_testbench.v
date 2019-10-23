`timescale 1ns/100ps

`define SECOND 1000000000
`define MS 1000000
`define CLK_PERIOD 8
`define B_SAMPLE_COUNT_MAX 5
`define B_PULSE_COUNT_MAX 5

`define CLOCK_FREQ 125_000_000
`define BAUD_RATE 115_200
`define INITIAL_NOTELEN 100_000 // so reception is visible
`define NUMSEND 8

//`define INITIAL_NOTELEN 100_000 // BACKPRESSURE SETTINGS
//`define BAUD_RATE 115_200_0
//`define NUMSEND 36


module system_testbench();
    reg clk = 0;
    wire audio_pwm;
    wire [5:0] leds;
    reg [2:0] buttons = 0;
    reg [1:0] switches = 0;
    reg reset = 0;
    reg done = 0;

    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;

    // Generate system clock
    always #(`CLK_PERIOD/2) clk <= ~clk;

    z1top #(
        .B_SAMPLE_COUNT_MAX(`B_SAMPLE_COUNT_MAX),
        .B_PULSE_COUNT_MAX(`B_PULSE_COUNT_MAX),
        .CLOCK_FREQ(`CLOCK_FREQ),
        .BAUD_RATE(`BAUD_RATE),
        .INITIAL_NOTELEN(`INITIAL_NOTELEN)
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
    wire data_in_ready, data_out_valid; //, data_out_ready;
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
        .data_out_ready(1'b1),
        .serial_in(FPGA_SERIAL_TX), // Note these serial connections are the opposite of the connections to z1top
        .serial_out(FPGA_SERIAL_RX)
    );

    // TEST VARS
    reg [7:0] test_values[`NUMSEND:0];
    reg [7:0] received_values[`NUMSEND:0];
    

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

    integer i, j;
    initial begin
        $display("\n ----------- STARTING ----------- \n");

        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("system_testbench.fst");
            $dumpvars(0,system_testbench);
        `endif
        
        // Populate test values
        for (i = 0; i < `NUMSEND; i = i + 1) begin
            test_values[i] <= $urandom;
        end

        // Simulate pushing the reset button and holding it for a while
        reset = 1'b0;
        repeat (50) @(posedge clk); #1;
        reset = 1'b1;
        repeat (50) @(posedge clk); #1;
        reset = 1'b0;

        // Send a few characters through the off_chip_uart
        done = 0;

        $display("data to send");
        for (i = 0; i < `NUMSEND; i=i+1) $display("%d : %h", i, test_values[i]);

        $display("commence transmission");
        fork
            begin // transmit
                for (i = 0; i < `NUMSEND; i=i+1) begin
                    uart_transmit(test_values[i]); $display("%d : sent %h", i, test_values[i]);
                end
            end

            begin // recieve
                for (j = 0; j < `NUMSEND; j=j+1) begin
                    uart_recieve();
                    received_values[j] = data_out;
                    $display("\t%d recieved %h", j, data_out);
                    if (data_out !== test_values[j]) 
                        $display("\t\tERROR, got: %h expected: %h", data_out, test_values[j]);
                end
                done = 1;
            end

            begin // timeout check
                repeat (100000) begin 
                    repeat (50) @(posedge clk);
                    if (done) begin
                        $display("\n ----------- DONE ----------- \n");
                        $finish();
                    end
                end
                //repeat (1250000) @(posedge clk); #1; 
                $display("a thing");
                if (!done) begin
                    $display("asdf Failure: timing out");
                    $display(" ----------- DONE ----------- \n");
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
