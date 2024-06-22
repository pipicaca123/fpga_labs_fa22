 module counter (
  input clk,
  input ce,
  output [3:0] LEDS
);
// TODO: better way to set these parameter? can't init. in testbench.
// parameter clk_ms_cnt = 125000;
// parameter acc_ms = 1000;
parameter clk_ms_cnt = 10;
parameter acc_ms = 1;
    initial begin
      $display("show para:clk_ms_cnt=%d, acc_ms=%d",clk_ms_cnt,acc_ms);
    end
    // Some initial code has been provided for you
    // You can change this code if needed
    reg [3:0] led_cnt_value = 4'h0;
    assign LEDS = led_cnt_value;
    integer iter = 0;

    // TODO: Instantiate a reg net to count the number of cycles
    // required to reach one second. Note that our clock period is 8ns.
    // Think about how many bits are needed for your reg.

    always @(posedge clk) begin
      if(ce == 1'b1) begin
        iter = iter+1;
      end 
      if (iter >= clk_ms_cnt * acc_ms) begin
        led_cnt_value = led_cnt_value+1;
        iter = 0;
      end
      led_cnt_value = led_cnt_value & 4'hF;
    end

endmodule

