module fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = $clog2(fifo_depth)
) (
    input clk, 
    input rst,

    // Write side
    input wr_en,
    input [data_width-1:0] din,
    output full,

    // Read side
    input rd_en,
    output reg [data_width-1:0] dout,
    output empty
);
    // Initialization
    reg [addr_width-1:0] write_pointer = 0;
    reg [addr_width-1:0] read_pointer = 0; 
    reg [data_width-1:0] data [fifo_depth-1:0];

    wire [addr_width-1:0] next_write;
    wire [addr_width-1:0] next_read;
    assign next_write = write_pointer + 1;
    assign next_read = read_pointer + 1;

    reg _empty = 1;

    assign full =  (write_pointer == read_pointer) && !(_empty);
    assign empty = (write_pointer == read_pointer) && _empty; 

    // Everything block
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i=0; i<fifo_depth; i=i+1) data[i] <= {data_width{1'b0}};
            _empty <= 1'b1;
        end else begin
            if (wr_en && !full) begin
                data[write_pointer] <= din;
                write_pointer <= next_write;
                if (next_write == read_pointer) _empty = 1'b0;
            end /*else*/ if (rd_en && !empty) begin
                dout <= data[read_pointer];
                read_pointer <= next_read;
                if (next_read == write_pointer) _empty <= 1'b1;
            end
        end
    end
endmodule

