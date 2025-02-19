`timescale 1ns/100ps

`define CLK_PERIOD 8
`define DATA_WIDTH 32
`define FIFO_DEPTH 8
//`define IVERILOG

module fifo_testbench();
    reg clk = 0;
    reg rst = 0;

    always #(`CLK_PERIOD/2) clk <= ~clk;

    // Write side signals
    reg [`DATA_WIDTH-1:0] din = 0;
    reg wr_en = 0;
    wire full;

    // Read side signals
    wire [`DATA_WIDTH-1:0] dout;
    reg rd_en = 0;
    wire empty;

    // Reg filled with test vectors for the testbench
    reg [`DATA_WIDTH-1:0] test_values[`FIFO_DEPTH-1:0];
    // Reg used to collect the data read from the FIFO
    reg [`DATA_WIDTH-1:0] received_values[`FIFO_DEPTH-1:0];

    fifo #(
        .data_width(`DATA_WIDTH),
        .fifo_depth(`FIFO_DEPTH)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .din(din),
        .full(full),
        .rd_en(rd_en),
        .dout(dout),
        .empty(empty)
    );

    // This task will push some data to the FIFO through the write interface
    // If violate_interface == 1'b1, we will force wr_en high even if the FIFO indicates it is full
    // If violate_interface == 1'b0, we won't write if the FIFO indicates it is full
    task write_to_fifo;
        input [`DATA_WIDTH-1:0] write_data;
        input violate_interface;
        begin
            // If we want to not violate the interface agreement, if we are already full, don't write
            if (!violate_interface && full) begin
                wr_en <= 1'b0;
            end
            // In all other cases, we will force a write
            else begin
                wr_en <= 1'b1;
            end

            // Apply the data input
            din <= write_data;

            // Wait for the clock edge to perform the write
            @(posedge clk);
            #1;

            // Deassert the write enable
            wr_en <= 1'b0;
        end
    endtask

    // This task will read some data from the FIFO through the read interface
    // violate_interface does the same as for the write_to_fifo task
    task read_from_fifo;
        input violate_interface;
        output [`DATA_WIDTH-1:0] read_data;
        begin
            if (!violate_interface && empty) begin
                rd_en <= 1'b0;
            end
            else begin
                rd_en <= 1'b1;
            end
            // Wait for the clock edge to get the read data
            @(posedge clk);
            #1;

            read_data = dout;
            rd_en <= 1'b0;
        end
    endtask

    // This task will read some data from the FIFO through the read interface
    // violate_interface does the same as for the write_to_fifo task
    task rw_from_fifo;
        input violate_interface;
        input [`DATA_WIDTH-1:0] write_data;
        output [`DATA_WIDTH-1:0] read_data;
        begin
            if (!violate_interface && empty) rd_en <= 1'b0;
            else rd_en <= 1'b1;
            if (!violate_interface && full) wr_en <= 1'b0;
            else begin wr_en <= 1'b1; din <= write_data; end
            // Wait for the clock edge to get the read data
            @(posedge clk);
            #1;

            read_data = dout;
            rd_en <= 1'b0;
            wr_en <= 1'b0;
        end
    endtask

    integer i;
    initial begin: TB
        `ifndef IVERILOG
            $vcdpluson;
        `endif
        `ifdef IVERILOG
            $dumpfile("fifo_testbench.fst");
            $dumpvars(0,fifo_testbench);
        `endif
        // Generate the random data to write to the FIFO
        for (i = 0; i < `FIFO_DEPTH; i = i + 1) begin
            test_values[i] <= $urandom;
        end

        rst = 1'b1;
        @(posedge clk); #1;
        rst = 1'b0;
        @(posedge clk); #1;

        // Let's begin with a simple complete write and read sequence to the FIFO

        // Check initial conditions, verify that the FIFO is not full, it is empty
        if (empty !== 1'b1) begin
            $display("Failure: After reset, the FIFO isn't empty. empty = %b", empty);
        end

        if (full !== 1'b0) begin
            $display("Failure: After reset, the FIFO is full. full = %b", full);
        end

        @(posedge clk);

        // Begin pushing data into the FIFO with a 1 cycle delay in between each write operation

        for (i = 0; i < `FIFO_DEPTH - 1; i = i + 1) begin
            write_to_fifo(test_values[i], 1'b0);

            // Perform checks on empty, full (disable check on empty for async FIFO due to synchronization delay)
            if (empty === 1'b1) begin
                $display("Failure: While being filled, FIFO said it was empty %d", i);
            end
            if (full === 1'b1) begin
                $display("Failure: While being filled, FIFO was full before all entries were written %d", i);
            end

            // Insert single-cycle delay between each write
            @(posedge clk);
        end

        // Perform the final write
        write_to_fifo(test_values[`FIFO_DEPTH-1], 1'b0);

        // Check that the FIFO is now full
        if (full !== 1'b1 || empty === 1'b1) begin
            $display("Failure: FIFO wasn't full or empty went high after writing all values. full = %b, empty = %b", full, empty);
        end

        // Cycle the clock, the FIFO should still be full!
        repeat (10) @(posedge clk);
        // The FIFO should still be full!
        if (full !== 1'b1 || empty == 1'b1) begin
            $display("Failure: Cycling the clock while the FIFO is full shouldn't change its state! full = %b, empty = %b", full, empty);
        end

        // Try stuffing the FIFO with more data while it's full (overflow protection check)
        repeat (20) begin
            write_to_fifo(0, 1'b1);
            // Check that the FIFO is still full, has the max num of entries, and isn't empty
            if (full !== 1'b1 || empty == 1'b1) begin
                $display("Failure: Overflowing the FIFO changed its state (your FIFO should have overflow protection) full = %b, empty = %b", full, empty);
            end
        end

        repeat (5) @(posedge clk);

        // Read from the FIFO one by one with a 1 cycle delay in between reads
        for (i = 0; i < `FIFO_DEPTH - 1; i = i + 1) begin
            read_from_fifo(1'b0, received_values[i]);

            // Perform checks on empty, full
            if (empty === 1'b1) begin
                $display("Failure: FIFO was empty as its being drained");
            end
            if (full === 1'b1) begin
                $display("Failure: FIFO was full as its being drained");
            end

            @(posedge clk);
        end

        // Perform the final read
        read_from_fifo(1'b0, received_values[`FIFO_DEPTH-1]);
        // Check that the FIFO is now empty
        if (full !== 1'b0 || empty !== 1'b1) begin
            $display("Failure: FIFO wasn't empty or full is high after the FIFO has been drained. full = %b, empty = %b", full, empty);
        end

        // Cycle the clock and perform the same checks
        repeat (10) @(posedge clk);
        if (full !== 1'b0 || empty !== 1'b1) begin
            $display("Failure: FIFO should be empty after it has been drained. full = %b, empty = %b", full, empty);
        end

        // Finally, let's check that the data we received from the FIFO equals the data that we wrote to it
        for (i = 0; i < `FIFO_DEPTH; i = i + 1) begin
            if (test_values[i] !== received_values[i]) begin
                $display("Failure: Data received from FIFO not equal to data written. Entry %d, got %d, expected %d", i, received_values[i], test_values[i]);
            end
        end

        // Now attempt a read underflow
        repeat (10) read_from_fifo(1'b1, received_values[0]);
        // Nothing should change, perform the same checks on full and empty
        if (full !== 1'b0 || empty !== 1'b1) begin
            $display("Failure: Empty FIFO wasn't empty or full went high when trying to read. full = %b, empty = %b", full, empty);
        end

        /* ------------- MY TESTS ------------- */
        // TEST 1 : readwrite same cycle
        // @empty should only write
        rw_from_fifo(1'b0, 5, received_values[0]);
        if (empty == 1'b1) $display("ERROR : FIFO empty on rw from empty");
        if (full == 1'b1) $display("ERROR : FIFO full on rw from empty");
        // @notempty should do both
        rw_from_fifo(1'b0, 7, received_values[0]);
        if (empty == 1'b1) $display("ERROR : FIFO empty on rw from single");
        if (full == 1'b1) $display("ERROR : FIFO full on rw from single ");
        if (received_values[0] != 5) $display("ERROR : wrong value read from FIFO (single)");
        // fill fifo
        for (i = 1; i < `FIFO_DEPTH; i = i + 1) begin
            write_to_fifo(test_values[i], 1'b0);
        end
        if (full == 1'b0) $display("FIFO should be full");
        // should be full and not write
        // rw should not write
        rw_from_fifo(1'b0, 79, received_values[0]);
        if (received_values[0] != 7) $display("rw corrupted write when full");
        for (i = 1; i < `FIFO_DEPTH - 1; i = i + 1) begin
            read_from_fifo(1'b0, received_values[i]);
            if (received_values[i] != test_values[i]) $display("FIFO being bad");
        end

        // SUCCESS! Print out some debug info.
        $display("This testbench was run with these params:");
        $display("CLK_PERIOD = %d, DATA_WIDTH = %d, FIFO_DEPTH = %d", `CLK_PERIOD, `DATA_WIDTH, `FIFO_DEPTH);
        $display("If no failures were printed, this test passed");
        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end
endmodule
