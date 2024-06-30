module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);
    reg [WIDTH-1:0] prev_state = 0;
    reg [WIDTH-1:0] edp_buf = 0;
    // TODO: implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' at the next clock edge
    // Feel free to use as many number of registers you like
    always @(posedge clk) begin
        edp_buf <= (~prev_state) & signal_in;
        prev_state <= signal_in;
    end

    assign edge_detect_pulse = edp_buf;
endmodule
