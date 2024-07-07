module sq_wave_gen #(
    parameter STEP = 10
)(
    input clk,
    input rst,
    input next_sample,
    input [2:0] buttons,
    output [9:0] code,
    output [3:0] leds
);
    reg [9:0] code_buffer;
    reg [17:0] freq;
    reg gen_val_state;
    reg [31:0] freq_sig_invert_cnt;
    reg [31:0] gen_wave_cycle; // 10Hz will have largest gen wave cycle

    assign code = code_buffer;

    initial begin
        code_buffer = 0;
        gen_val_state = 0;
        gen_wave_cycle = 0;
    end

    always @(posedge clk) begin
        if(rst == 1) begin
            freq <= 440;
            code_buffer <= 0;
            gen_val_state <= 0;
            gen_wave_cycle <= 0;   
        end

        if(next_sample == 1)
            gen_wave_cycle <= gen_wave_cycle + 1;

        freq_sig_invert_cnt <=  $rtoi(125e6 / (1024 * 2 * freq));
        if(gen_wave_cycle >= freq_sig_invert_cnt) begin
            gen_val_state <= ~gen_val_state;
            gen_wave_cycle <= 0;
        end
        
        if(gen_val_state == 1)
            code_buffer <= 462;
        else
            code_buffer <= 562;

    end 
endmodule
