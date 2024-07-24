// STATE MACHINE WILL BE SMARTER
// TODO: simutanous read/write sim
module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 32,
    parameter POINTER_WIDTH = $clog2(DEPTH)
) (
    input clk, rst,

    // Write side
    input wr_en,
    input [WIDTH-1:0] din,
    output full,

    // Read side
    input rd_en,
    output [WIDTH-1:0] dout,
    output empty
);

    reg [POINTER_WIDTH-1:0]read_ptr;
    reg [POINTER_WIDTH-1:0]write_ptr;
    reg [POINTER_WIDTH:0] bit_level;
    reg [WIDTH-1:0] dout_reg;
    reg [WIDTH-1:0] mem_buffer[DEPTH-1:0];

    assign empty = bit_level == 0;
     /* verilator lint_off WIDTH */
    assign full = bit_level == DEPTH;
     /* lint_on  */
    assign dout = dout_reg;

    always @(posedge clk) begin
        if(rst)begin
            bit_level <= 0;
            read_ptr <= 0;
            write_ptr <= 0;
        end
        if(wr_en && !full)begin
            write_ptr <= write_ptr + 1;
            bit_level = bit_level + 1; // TODO: better discription?
            mem_buffer[write_ptr] <= din;
        end
        if(rd_en && !empty)begin
            read_ptr <= read_ptr + 1;
            bit_level = bit_level - 1; // TODO: better discription?
            dout_reg <= mem_buffer[read_ptr];
        end
    end

endmodule