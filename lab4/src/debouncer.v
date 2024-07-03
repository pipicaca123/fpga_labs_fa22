module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX),
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output [WIDTH-1:0] debounced_signal
);
    // TODO: fill in neccesary logic to implement the wrapping counter and the saturating counters
    // Some initial code has been provided to you, but feel free to change it however you like
    // One wrapping counter is required
    // One saturating counter is needed for each bit of glitchy_signal
    // You need to think of the conditions for reseting, clock enable, etc. those registers
    // Refer to the block diagram in the spec

    reg [WRAPPING_CNT_WIDTH:0] wrapping_cnt;
    reg [SAT_CNT_WIDTH:0] saturating_counter [WIDTH-1:0];
    reg [WIDTH-1:0] debounce_buf = 0;
    integer iter;
    initial begin
        wrapping_cnt = 0;
        for(iter=0; iter < WIDTH; iter = iter +1) begin
            saturating_counter[iter] = 0;
        end
    end

    always @(posedge clk) begin
        // sample signal
        wrapping_cnt = wrapping_cnt + 1;
        if(wrapping_cnt >= SAMPLE_CNT_MAX) begin 
            for(iter=0; iter < WIDTH; iter = iter + 1 ) begin
                if(glitchy_signal[iter] == 1) begin
                    saturating_counter[iter] = saturating_counter[iter] + 1;
                end
                else begin
                    saturating_counter[iter] = 0;
                end
            end
            wrapping_cnt = 0;
        end

        // debouncer output
        for(iter=0; iter < WIDTH; iter = iter + 1 ) begin
            if(saturating_counter[iter] >= PULSE_CNT_MAX) begin
                debounce_buf[iter] = 1'b1;
            end else begin
                debounce_buf[iter] = 1'b0;
            end            
        end
    end
    assign debounced_signal = debounce_buf;

endmodule

