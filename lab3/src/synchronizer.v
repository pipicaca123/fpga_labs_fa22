module synchronizer #(parameter WIDTH = 1) (
    input [WIDTH-1:0] async_signal,
    input clk,
    output [WIDTH-1:0] sync_signal
);
    // Create your 2 flip-flop synchronizer here
    // This module takes in a vector of WIDTH-bit asynchronous
    // (from different clock domain or not clocked, such as button press) signals
    // and should output a vector of WIDTH-bit synchronous signals
    // that are synchronized to the input clk 
    reg [WIDTH-1:0] ff_async = 0;
    reg [WIDTH-1:0] ff_sync = 0;

    always @(posedge clk) begin
        ff_async <= async_signal;
        ff_sync <= ff_async;
    end
    
    assign sync_signal = ff_sync;
endmodule
