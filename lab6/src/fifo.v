module fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = $clog2(fifo_depth)
) (
    input clk, rst,

    // Write side
    input wr_en,
    input [data_width-1:0] din,
    output full,

    // Read side
    input rd_en,
    output reg [data_width-1:0] dout,
    output empty
);
    //assign full = 1'b1;
    //assign empty = 1'b0;
    //assign dout = 0;

    // Initialization
    reg [addr_width-1:0] write_pointer = 0;
    reg [addr_width-1:0] read_pointer = 0; 
    reg [data_width-1:0] data [fifo_depth-1:0];

    reg _full = 0;

    // Always
    //assign dout = data[read_pointer];
    assign full = _full;
    assign empty = (write_pointer == read_pointer) && !(full);

    always @(posedge clk) 
        if (rst) begin
            genvar i;
            generate
                for (i = 0; i < fifo_depth; i = i + 1) begin : genreset
                    data[i] = addr_width'b0;
                end
            endgenerate
        end else begin
            // main
            if (wr_en && !full) begin
                write_pointer <= write_pointer + 1;
                data[write_pointer] <= din;
                if ((write_pointer + 1) == read_pointer) _full <= 1'b1;
                else _full <= 1'b0;
            end else if (rd_en && !empty) begin
                read_pointer <= read_pointer + 1;
                dout <= data[read_pointer];
                _full <= 1'b0;
            end
        end
    end


endmodule
