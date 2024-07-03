module dac #(
    parameter CYCLES_PER_WINDOW = 1024,
    parameter CODE_WIDTH = $clog2(CYCLES_PER_WINDOW)
)(
    input clk,
    input rst,
    input [CODE_WIDTH-1:0] code,
    output next_sample,
    output reg pwm
);
    reg volt_level;
    reg [CODE_WIDTH:0] cycle_cnt;
    reg [CODE_WIDTH-1:0] pulse_width_cnt;
    reg next_sample_buf;
    reg rst_delay;

    assign pwm = volt_level;
    assign next_sample = next_sample_buf;


    always @(posedge clk) begin
        if(rst)begin
            volt_level <= 0;
            cycle_cnt <= 0;
            pulse_width_cnt <= 0;
            next_sample_buf <= 0;
            rst_delay <= 1;
        end
        else begin
            if(rst_delay)
                rst_delay <= 0;
            else begin
                cycle_cnt = cycle_cnt + 1;
                pulse_width_cnt = pulse_width_cnt + 1; 
                if(pulse_width_cnt <= code)
                    volt_level <= 1;
                else
                    volt_level <= 0;
            end

            if(cycle_cnt >= CYCLES_PER_WINDOW) begin
                cycle_cnt <= 0;
                pulse_width_cnt <= 0;
            end

            if(cycle_cnt == CYCLES_PER_WINDOW-1) 
                next_sample_buf <= 1;
            else
                next_sample_buf <= 0;

        
        end
    end
endmodule
