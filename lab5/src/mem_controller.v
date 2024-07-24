module mem_controller #(
  parameter FIFO_WIDTH = 8
) (
  input clk,
  input rst,
  input rx_fifo_empty,
  input tx_fifo_full,
  input [FIFO_WIDTH-1:0] din,

  output rx_fifo_rd_en,
  output tx_fifo_wr_en,
  output [FIFO_WIDTH-1:0] dout,
  output [5:0] state_leds
);

  localparam MEM_WIDTH = 8;   /* Width of each mem entry (word) */
  localparam MEM_DEPTH = 256; /* Number of entries */
  localparam NUM_BYTES_PER_WORD = MEM_WIDTH/8;
  localparam MEM_ADDR_WIDTH = $clog2(MEM_DEPTH); 

  reg [NUM_BYTES_PER_WORD-1:0] mem_we = 0;
  reg [MEM_ADDR_WIDTH-1:0] mem_addr;
  reg [MEM_WIDTH-1:0] mem_din;
  wire [MEM_WIDTH-1:0] mem_dout;

  memory #(
    .MEM_WIDTH(MEM_WIDTH),
    .DEPTH(MEM_DEPTH)
  ) mem(
    .clk(clk),
    .en(1'b1),
    .we(mem_we),
    .addr(mem_addr),
    .din(mem_din),
    .dout(mem_dout)
  );

  localparam 
    IDLE = 3'd0,
    READ_CMD = 3'd1,
    READ_ADDR = 3'd2,
    READ_DATA = 3'd3,
    READ_MEM_VAL = 3'd4,
    ECHO_VAL = 3'd5,
    WRITE_MEM_VAL = 3'd6;

  localparam  
    READ_PKT = 8'd48,
    WRITE_PKT = 8'd49;

  reg [2:0] curr_state;
  reg [2:0] next_state;

  reg rx_fifo_rd_en_reg;
  reg mem_rd_en_reg;
  reg tx_fifo_wr_en_reg;
  reg data_available;

  // data processor
  reg start_process; // trig by state combinational block
  reg [FIFO_WIDTH-1:0] data_buf[2:0];


  always @(posedge clk) begin
    /* state reg update */
    curr_state <= next_state;
  end

  reg [2:0] pkt_rd_cnt;
  reg [MEM_WIDTH-1:0] cmd;
  reg [MEM_WIDTH-1:0] addr;
  reg [MEM_WIDTH-1:0] data;
  reg handshake;


  always @(*) begin
    
    /* initial values to avoid latch synthesis */
    if(rst)begin
      next_state = IDLE;
    end
    case (curr_state)

      /* next state logic */
      IDLE:begin
        if(handshake)
          next_state = READ_CMD;
      end
      READ_CMD:begin
        if(handshake)
          next_state = READ_ADDR;
      end
      READ_ADDR:begin
        if(handshake)begin
          if(cmd == READ_PKT)begin
            next_state = READ_MEM_VAL;
          end
          else if(cmd == WRITE_PKT)begin
            next_state = READ_DATA;
          end
        end
      end
      READ_DATA:begin
        next_state = WRITE_MEM_VAL;
      end
      READ_MEM_VAL:begin
        next_state = ECHO_VAL;
      end
      ECHO_VAL:begin
        next_state = IDLE;
      end
      WRITE_MEM_VAL:begin
        next_state = IDLE;
      end
      default:begin

        
      end

    endcase

  end

  always @(*) begin
    
    /* initial values to avoid latch synthesis */
    if(rst)begin
      tx_fifo_wr_en_reg = 0;
      mem_we = 0;
    end
    
    case (curr_state)

      /* output and mem signal logic */
      IDLE:begin
        tx_fifo_wr_en_reg = 0;
        mem_we = 0;
      end
      READ_CMD:begin
        tx_fifo_wr_en_reg = 0;
        mem_we = 0;
      end
      READ_ADDR:begin
        tx_fifo_wr_en_reg = 0;
        mem_we = 0;
      end
      READ_DATA:begin
        tx_fifo_wr_en_reg = 0;
        mem_we = 0;
      end
      READ_MEM_VAL:begin
        tx_fifo_wr_en_reg = 0;
        mem_we = 0;
      end
      WRITE_MEM_VAL:begin
        tx_fifo_wr_en_reg = 0;
        mem_we = 1;
      end
      ECHO_VAL:begin
        tx_fifo_wr_en_reg = 1;
        mem_we = 0;
      end
      default:begin
        
      end
    endcase

  end


  always @(posedge clk) begin

    /* byte reading and packet counting */
    if(rst)begin
      pkt_rd_cnt <= 0;
      start_process <= 0;
    end

    if(curr_state == IDLE && !rx_fifo_empty && !start_process)begin
      rx_fifo_rd_en_reg <= 1;
      handshake <= 1;
      start_process <= 1;
      pkt_rd_cnt <= 0;
    end
    else if (curr_state == READ_CMD && !rx_fifo_empty)begin
      rx_fifo_rd_en_reg <= 1;
      start_process <= 0;
    end
    else if(curr_state == READ_ADDR && cmd == WRITE_PKT && !rx_fifo_empty)begin
      rx_fifo_rd_en_reg <= 1;
    end
    else if(curr_state == READ_ADDR && cmd == READ_PKT)begin
      mem_rd_en_reg <= 1;
    end

    if(handshake) // trig signal, retrieve
      handshake <= 0;

    if(rx_fifo_rd_en_reg || mem_rd_en_reg) begin
      data_available <= 1; // delay for data stable
      rx_fifo_rd_en_reg <= 0;
      mem_rd_en_reg <= 0;
    end

    if(data_available)
      data_available <= 0;

    if(data_available)begin
        if(pkt_rd_cnt == 2 && cmd == READ_PKT)
          data_buf[pkt_rd_cnt] <= mem_dout;
        else
        data_buf[pkt_rd_cnt] <= din;
        pkt_rd_cnt <= pkt_rd_cnt + 1;
        handshake <= 1;
    end

  end

  assign state_leds = 'd0;

  assign rx_fifo_rd_en = rx_fifo_rd_en_reg;
  assign tx_fifo_wr_en = tx_fifo_wr_en_reg;
  assign dout = data;

  assign cmd = data_buf[0];
  assign addr = data_buf[1];
  assign data = data_buf[2];

  assign mem_addr = addr;
  assign mem_din = data;

endmodule
