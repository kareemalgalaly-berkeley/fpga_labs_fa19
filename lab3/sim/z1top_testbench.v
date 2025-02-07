`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000
`define CLOCKS_PER_SAMPLE 2500 // 125 Mhz clock, 50 kHz audio, 2500 clocks per sample

module z1top_testbench();
    reg clock;
    initial clock = 0;
    always #(4) clock <= ~clock;

    wire aud_pwm, aud_sd, speaker;
    wire [5:0] leds;
    reg [3:0] buttons = 4'h0;
    reg [1:0] switches = 2'b11;
    assign speaker = aud_pwm & aud_sd;

    z1top top (
        .CLK_125MHZ_FPGA(clock),
        .BUTTONS(buttons),
        .SWITCHES(switches),
        .LEDS(leds),
        .aud_pwm(aud_pwm),
        .aud_sd(aud_sd)
    );

    initial begin
        `ifdef IVERILOG
            $dumpfile("z1top_testbench.fst");
            $dumpvars(0,z1top_testbench);
        `endif
        //repeat (5) BEGIN
            buttons <= 4'b0001;
            #(50 * `MS);
            buttons <= 4'b0;
            #(50 * `MS);
            $finish();
            buttons <= 4'b0111;
            #(50 * `MS);
            buttons <= 4'b0001;
            #(50 * `MS);
            buttons <= 4'b1001;
            #(50 * `MS);
            switches <= switches - 1;
        //end
        //#(200 * `MS);
        $finish();
    end

    integer file;
    integer i;
    integer count;
    initial begin
        `ifndef IVERILOG
            $vcdpluson;
        `endif
        file = $fopen("output.txt", "w");
        forever begin
            count = 0;
            for (i = 0; i < `CLOCKS_PER_SAMPLE; i = i + 1) begin
                @(posedge clock);
                count = count + speaker;
            end
            $fwrite(file, "%d\n", count);
        end
        `ifndef IVERILOG
            $vcdplusoff;
        `endif
    end

endmodule
