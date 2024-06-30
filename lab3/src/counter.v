module counter #(
    parameter CYCLES_PER_SECOND = 125_000_000
)(
    input clk,
    input [3:0] buttons,
    output [3:0] leds
);
    reg [3:0] counter = 0;
    reg dynamic_mode = 0;
    reg [$clog2(CYCLES_PER_SECOND):0] time_counter = 0;
    assign leds = counter;
    

    always @(posedge clk) begin
        if (buttons[0])
            counter <= counter + 4'd1;
        else if (buttons[1])
            counter <= counter - 4'd1;
        else if(buttons[2])
            dynamic_mode <= ~dynamic_mode;
        else if (buttons[3])
            counter <= 4'd0;
        else
            counter <= counter;

        if(dynamic_mode == 1'b1) 
            time_counter <= time_counter + 1;
        else
            time_counter <= 0;
        
        if(time_counter >= CYCLES_PER_SECOND) begin
            counter <= counter + 1;
            time_counter <= 0;
        end

    end



endmodule

