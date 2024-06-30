module sq_wave_gen (
    input clk,
    input next_sample,
    output [9:0] code
);
    reg [9:0] code_buffer;
    reg gen_val_state;
    reg [$clog2(138)+1:0] gen_wave_cycle;

    assign code = code_buffer;

    initial begin
        code_buffer = 0;
        gen_val_state = 0;
        gen_wave_cycle = 0;
    end

    always @(posedge clk) begin
        if(next_sample == 1)
            gen_wave_cycle <= gen_wave_cycle + 1;

        if(gen_wave_cycle >= 138) begin
            gen_val_state <= ~gen_val_state;
            gen_wave_cycle <= 0;
        end
        
        if(gen_val_state == 1)
            code_buffer <= 462;
        else
            code_buffer <= 562;


    end 
endmodule
