module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);
    // status 
    localparam IDLE_STATUS = 0;
    localparam TRANSMIT_STATUS = 1;

    // reg & wire
    wire symbol_edge;
    wire tx_running;
    wire serial_send;

    reg serial_out_reg;
    reg [9:0] tx_shift;
    reg [7:0] data_buf; // avoid data_in change when serial is sending
    reg [3:0] bit_counter;
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter;

    assign symbol_edge = clock_counter == (SYMBOL_EDGE_TIME - 1);
    assign tx_running = bit_counter != 4'd0;
    assign serial_send = data_in_ready && data_in_valid;
    assign data_in_ready = !tx_running;
    
    always @(*) begin
        tx_shift[8:1] = data_buf;
        tx_shift[0] = 1'b0;
        tx_shift[9] = 1'b1; 
    end

    always @(posedge clk) begin
        clock_counter <= (serial_send || reset || symbol_edge) ? 0 : clock_counter + 1;
    end
    always @(posedge clk) begin
        if(reset) begin
            bit_counter <= 0;
        end
        else if(serial_send)begin
            bit_counter <= 10;
            data_buf <= data_in;
        end
        else if(symbol_edge && tx_running)begin
            bit_counter <= bit_counter - 1;
        end
    end

    always @(posedge clk) begin
        if(!tx_running)
            serial_out_reg <= 1;
        else 
            serial_out_reg <= tx_shift[10 - bit_counter];
    end

    assign serial_out = serial_out_reg;

endmodule
