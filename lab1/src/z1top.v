/**
* target design function: 
*   - switch 0 for blinking 25Hz when pressing BUTTONS N
*   - switch 1 multiple XOR gate(BUTTONS[3:0]) and output to LED[1]
*/


`timescale 1ns / 1ps


module z1top(
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output reg [5:0] LEDS
);
  // and(LEDS[0], BUTTONS[0], SWITCHES[0]);
  // assign LEDS[5:1] = 0;
  reg [31:0] counter = 0;
  reg [3:0] led_state = 4'b0000;
  
  always @(posedge CLK_125MHZ_FPGA) begin
    counter <= counter + 1;
    if(counter == 25000000) begin // 125000000 / 5 = 25000000
      led_state <= ~led_state;
      counter <= 0;
    end

    case(SWITCHES) 
    2'b00: LEDS <= led_state & BUTTONS;
    2'b11: LEDS[1] = ^BUTTONS;
    2'b01, 2'b10: LEDS = 6'b001111;
    default:LEDS = 5'b00000;
    endcase
  end
endmodule
