module debouncer #(
    parameter width = 1,
    parameter sample_count_max = 25000,
    parameter pulse_count_max = 150,
    parameter wrapping_counter_width = $clog2(sample_count_max),
    parameter saturating_counter_width = $clog2(pulse_count_max))
(
    input clk,
    input [width-1:0] glitchy_signal,
    output reg [width-1:0] debounced_signal = 0
);
    // Create your debouncer circuit
    // The debouncer takes in a bus of 1-bit synchronized, but glitchy signals
    // and should output a bus of 1-bit signals that hold high when their respective counter saturates

    // Sample Pulse Generator
    reg sample_pulse;
    reg [wrapping_counter_width-1:0] sample_count = 0;
    always @(posedge clk) begin
        sample_pulse = 0;
        if (sample_count == sample_count_max) begin
            sample_pulse = 1;
            sample_count <= 0;
        end else sample_count <= sample_count + 1;
    end

    // Saturating Counter
    wire [saturating_counter_width-1:0] pulse_count_out [width-1:0];
    //wire [saturating_counter_width-1:0] pulse_count_in [width-1:0];

    genvar i;
    generate
        for (i = 0; i < width; i = i+1) begin: LOOP
            reg [saturating_counter_width-1:0] pulse_count = 0;
            assign pulse_count_out[i] = pulse_count;
            always @(posedge clk) begin
                if (glitchy_signal[i] == 0) begin pulse_count <= 1; debounced_signal[i] <= 0; end //rst
                else begin
                    if (sample_pulse) begin
                        if (pulse_count > pulse_count_max) debounced_signal[i] <= 1;
                        else pulse_count <= pulse_count + 1;
                    end
                end
            end
        end
    endgenerate

endmodule
