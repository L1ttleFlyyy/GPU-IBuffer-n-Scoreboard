//-----------------------------------------------------------------------------
//
//  Copyright (c) 2009 Xilinx Inc.
//
//  Project  : Programmable Wave Generator
//  Module   : wave_gen.v
//  Parent   : None
//  Children : Many
//
//  Description:
//
//  Parameters:
//     BAUD_RATE:     Desired Baud rate for both RX and TX
//     CLOCK_RATE_RX: Clock rate for the RX domain
//     CLOCK_RATE_TX: Clock rate for the TX domain
//
//  Local Parameters:
//
//  Notes       :
//

`timescale 1ns/1ps


module uart_example (
  input            clk_pin,      // Clock input (from pin)
  input            rst_pin,        // Active HIGH reset (from pin)

  // RS232 signals
  input            rxd_pin,        // RS232 RXD pin
  output           txd_pin,        // RS232 RXD pin

  // button L
  input             BTNL,
//   input             BTNR,

  // LED outputs
  output     [15:0] led_pins         // 8 LED outputs
);


//***************************************************************************
// Parameter definitions
//***************************************************************************

  parameter BAUD_RATE           = 115_200;

  parameter CLOCK_RATE_RX       = 100_000_000;
  parameter CLOCK_RATE_TX       = 100_000_000;

  localparam
      ACK = 8'h06,
      SOH = 8'h01,
      EOT = 8'h03,
      SOT = 8'h02,
      EOM = 8'h19,
      CR = 8'h0d,
      LF = 8'h0a,
      EOF = 8'h04,
      SPACE = 8'h20,
      COM = 8'h2c;

//***************************************************************************
// Reg declarations
//***************************************************************************

//***************************************************************************
// Wire declarations
//***************************************************************************

  // To/From IBUFG/OBUFG
  // No pin for clock - the IBUFG is internal to clk_gen
  wire        rst_i;
  wire        rxd_i;
  (* mark_debug = "true"*) wire        txd_o;
  wire [15:0]  led_o;

  // From Clock Generator
  wire        clk_sys;         // Receive clock

  // From Reset Generator
  wire        rst_clk;     // Reset, synchronized to clk_rx

  // From the RS232 receiver
  wire        rxd_clk_rx;     // RXD signal synchronized to clk_rx
  wire        rx_data_rdy;    // New character is ready
  wire        rx_data_rdy_reg;
  wire [7:0]  rx_data;        // New character
  wire        rx_lost_data;   // Rx data lost

  // From the debouncer module
  wire        btnl_scen;        // SCEN of btnl
//   wire        btnr_scen;
  // From the UART transmitter
  wire        tx_fifo_full;  // Pop signal to the char FIFO

  // From the sending file module
  wire          send_fifo_full;     // the input fifo of this module is full
  wire          send_finish;        // the sending process has finished; 1 clock wide
  wire [7:0]    tx_din_send_module; // data to the tx module
  wire          tx_write_en_send_module;        // write enable signal to the tx module
  wire          rx_read_en_send_module;         // pop signal to the rx module

  // From the receiving file module
  wire          rx_read_en_receive_module;
  wire [7:0]    tx_din_receive_module;
  wire          tx_write_en_receive_module;
  wire [7:0]    receive_fifo_dout;          // the received data flow
  wire          receive_data_rdy;           // received data ready
  wire [7:0]    reg_addr;                   // reg address
  wire [7:0]    reg_pointer;                // reg pointer content
  wire          reg_ready;                  // reg information ready signal

  // Given in the current module
  // to the tx module
  wire [7:0]    tx_din;     // data to be sent in tx
  wire          tx_write_en;    // send signal to tx
  wire [7:0]    char_fifo_dout; //registered received data for chipscope
  // to the rx module
  wire          rx_read_en;     // pop an entry in the rx fifo
  wire [7:0]    rx_data_reg; //registered received data for chipscope
  // to the send file module
  reg [7:0]     send_fifo_din;      // the input data to the send module
  wire          send_fifo_we;       // signal to send data
  wire          start_send_file;         // start send signal
  // to the receive file module
  wire          receive_fifo_re;        // pop information from receive file module
  // decide if current is rx or tx
  wire           receive_sendbar;       // 1 means currently is receiving data; 0 mean currently is sending data

  // for debug

  // for chipscope
  wire [35:0]    control_bus;
  wire [23:0]    data;

//***************************************************************************
// Code
//***************************************************************************

  // Instantiate input/output buffers
  IBUF IBUF_rst_i0      (.I (rst_pin),      .O (rst_i));
  IBUF IBUF_rxd_i0      (.I (rxd_pin),      .O (rxd_i));

  OBUF OBUF_txd         (.I(txd_o),         .O(txd_pin));
  OBUF OBUF_led_i0      (.I(led_o[0]),      .O(led_pins[0]));
  OBUF OBUF_led_i1      (.I(led_o[1]),      .O(led_pins[1]));
  OBUF OBUF_led_i2      (.I(led_o[2]),      .O(led_pins[2]));
  OBUF OBUF_led_i3      (.I(led_o[3]),      .O(led_pins[3]));
  OBUF OBUF_led_i4      (.I(led_o[4]),      .O(led_pins[4]));
  OBUF OBUF_led_i5      (.I(led_o[5]),      .O(led_pins[5]));
  OBUF OBUF_led_i6      (.I(led_o[6]),      .O(led_pins[6]));
  OBUF OBUF_led_i7      (.I(led_o[7]),      .O(led_pins[7]));
  OBUF OBUF_led_i8      (.I(led_o[8]),      .O(led_pins[8]));
  OBUF OBUF_led_i9      (.I(led_o[9]),      .O(led_pins[9]));
  OBUF OBUF_led_i10     (.I(led_o[10]),     .O(led_pins[10]));
  OBUF OBUF_led_i11     (.I(led_o[11]),     .O(led_pins[11]));
  OBUF OBUF_led_i12     (.I(led_o[12]),     .O(led_pins[12]));
  OBUF OBUF_led_i13     (.I(led_o[13]),     .O(led_pins[13]));
  OBUF OBUF_led_i14     (.I(led_o[14]),     .O(led_pins[14]));
  OBUF OBUF_led_i15     (.I(led_o[15]),     .O(led_pins[15]));
  IBUF IBUFG_CLK       (.I(clk_pin),      .O(clk_sys));

    // This function takes the lower 7 bits of a character and converts them
    // to a hex digit. It returns 5 bits - the upper bit is set if the character
    // is not a valid hex digit (i.e. is not 0-9,a-f, A-F), and the remaining
    // 4 bits are the digit
    function [4:0] to_val;
        input [6:0] char;
        begin
            if ((char >= 7'h30) && (char <= 7'h39)) // 0-9
            begin
                to_val[4]   = 1'b0;
                to_val[3:0] = char[3:0];
            end
            else if (((char >= 7'h41) && (char <= 7'h46)) || // A-F
                ((char >= 7'h61) && (char <= 7'h66)) )  // a-f
            begin
                to_val[4]   = 1'b0;
                to_val[3:0] = char[3:0] + 4'h9; // gives 10 - 15
            end
            else
            begin
                to_val      = 5'b1_0000;
            end
        end
    endfunction

    function [7:0] to_char;
        input [3:0] val;
        begin
            if ((val >= 4'h0) && (val <= 4'h9)) // 0-9
            begin
                to_char = {4'h3, val};
            end
            else
            begin
                to_char = val + 8'h37; // gives 10 - 15
            end
        end
    endfunction

  // Instantiate the reset generator
  rst_gen rst_gen_i0 (
    .clk_i          (clk_sys),          // Receive clock
    .rst_i           (rst_i),           // Asynchronous input - from IBUF
    .rst_o      (rst_clk)      // Reset, synchronized to clk_rx
  );

  // Debouncing module for BTNL
  ee201_debouncer debouncer_i0(
      .CLK          (clk_sys),
      .RESET        (rst_clk),
      .PB           (BTNL),
      .DPB          (),
      .SCEN         (btnl_scen),
      .MCEN         (),
      .CCEN         ()
  );

/*    // Debouncing module for BTNR
  ee201_debouncer debouncer_i1(
      .CLK          (clk_sys),
      .RESET        (rst_clk),
      .PB           (BTNR),
      .DPB          (),
      .SCEN         (btnr_scen),
      .MCEN         (),
      .CCEN         ()
  );*/

  // file sending module
  send_file send_file_i0 (
      // for debug
      .state                (),
      // clock and reset
      .clk                  (clk_sys),
      .reset                (rst_clk),
      // communication with user
      .start_send           (start_send_file),     // start signal
      .send_fifo_din        (send_fifo_din),                // data input to the input fifo
      .send_fifo_we         (send_fifo_we),                 //write enable to the input fifo
      .send_fifo_full       (send_fifo_full),              // input fifo is full
      .finish_send          (send_finish),        // send finishes

      // communication with tx fifo
      .tx_fifo_full         (tx_fifo_full),           // tx fifo is full
      .tx_fifo_din          (tx_din_send_module),  // send data to the tx fifo
      .tx_fifo_we           (tx_write_en_send_module),           // write enable to tx fifo

      // communication with rx module
      .rx_data              (rx_data),  // Character to be parsed
      .rx_data_rdy          (rx_data_rdy), // Ready signal for rx_data
      .rx_read_en           (rx_read_en_send_module) // Pop entry from rx fifo
  );

  // file receiving module
  receive_file receive_file_i0(
      .state                (),     //for debug
      // clk and reset
      .clk                  (clk_sys),         // Clock input
      .reset                (rst_clk),     // Active HIGH reset - synchronous to clk_rx

      // communication with rx module
      .rx_data              (rx_data),        // Character to be parsed
      .rx_data_rdy          (rx_data_rdy),         // Ready signal for rx_data
      .rx_read_en           (rx_read_en_receive_module),       // pop entry in rx fifo

      // communication with tx module
      .tx_fifo_full         (tx_fifo_full),     // the tx fifo is full
      .tx_din               (tx_din_receive_module),         // data to be sent
      .tx_write_en          (tx_write_en_receive_module),          // write enable to tx

      // communication with user
      .receive_fifo_dout    (receive_fifo_dout),      // data output of the fifo
      .receive_data_rdy     (receive_data_rdy),         // there is data ready at the output fifo
      .receive_fifo_re      (receive_fifo_re),            // pop entry in the receive fifo

      // register information
      .reg_addr             (reg_addr),       // register address of the specifier
      .reg_pointer          (reg_pointer),    // content of the specifier
      .reg_ready            (reg_ready)      // indication when the reg data is available. It's available only
                                          // after both the address and the content is ready.
      );


  // Instantiate the UART receiver
  uart_rx #(
    .BAUD_RATE   (BAUD_RATE),
    .CLOCK_RATE  (CLOCK_RATE_RX)
  ) uart_rx_i0 (
  //system configuration:
    .clk_rx      (clk_sys),              // Receive clock
    .rst_clk_rx  (rst_clk),          // Reset, synchronized to clk_rx
    .rxd_i       (rxd_i),               // RS232 receive pin
    .rxd_clk_rx  (rxd_clk_rx),          // RXD pin after sync to clk_rx

  //user interface:
    .read_en     (rx_read_en),                    // input to the module: pop an element from the internal fifo
    .rx_data_rdy (rx_data_rdy),         // New data is ready
	 .rx_data_rdy_reg (rx_data_rdy_reg),
    .rx_data     (rx_data),             // New data
    .lost_data   (rx_lost_data),                    // fifo is full but new data still comes in, resulting in data lost
    .frm_err     (),                     // Framing error (unused)
	.rx_store_qual      (),
    .rx_frame_indicator (),
    .rx_bit_indicator   (),
    .rx_data_reg        ()

  );

  // Instantiate the UART transmitter
  uart_tx #(
    .BAUD_RATE    (BAUD_RATE),
    .CLOCK_RATE   (CLOCK_RATE_TX)
  ) uart_tx_i0 (
  //system configuration:
    .clk_tx             (clk_sys),          // Clock input
    .rst_clk_tx         (rst_clk),      // Reset - synchronous to clk_tx
    .txd_tx             (txd_o),           // The transmit serial signal

  //user interface:
    .write_en           (tx_write_en), // signal to send to data out
    .tx_din             (tx_din), // data to be sent
    .tx_fifo_full       (tx_fifo_full),  // the internal fifo is full, should stop sending data
	.tx_store_qual      (),
    .tx_frame_indicator (),
    .tx_bit_indicator   (),
    .char_fifo_dout     ()
  );

  // mux for input to rx and tx module
  assign tx_din = receive_sendbar ? tx_din_receive_module : tx_din_send_module;
  assign tx_write_en = receive_sendbar ? tx_write_en_receive_module : tx_write_en_send_module;
  assign rx_read_en = receive_sendbar ? rx_read_en_receive_module : rx_read_en_send_module;


//   fifo IO with division:
  localparam
    IDLE = 4'b0000,
    WAIT_RECV = 4'b0001,     // wait for the SOT signal for X
    RECV = 4'b0011,
    COMP = 4'b0101,
    SEND = 4'b0110,
	  WAIT_SEND_DONE = 4'b1000,
    DONE = 4'b1001;

  reg [3:0]         state;
  wire [4:0]        char_to_digit = to_val(receive_fifo_dout[6:0]);      // the hex result of the received data
  wire              done = (state == DONE);

  // for testing
//   assign led_o[0] = rx_lost_data;
//   assign led_o[1] = receive_sendbar;
//   assign led_o[2] = send_fifo_full;
//   assign led_o[0] = done;
//   assign led_o[2:0] = addr_cnt;
  assign led_o[7:4] = state;
//   assign led_o[9:8] = mem_sel;
  //assign led_o[5:4] = reg_pointer;
  //assign led_o[7:4] = state_temp;
//   assign led_o[15:13] = nibble_cnt;

  // combinational logic

  assign receive_fifo_re = (state == WAIT_RECV || state == RECV) && receive_data_rdy;
  assign start_send_file = (state == SEND);
  assign send_fifo_we = (state == SEND) && (~send_fifo_full);
  assign receive_sendbar = (state == IDLE || state == WAIT_RECV || state == RECV);

  /************************* Custom Parameters *************************/
  localparam NUM_MEMS = 4;
  localparam WIDTH = 8*4; // = 32, The WIDTH must be a multiple of 4
  localparam DEPTH = 8; // = 8
  /************************* Custom Parameters *************************/

  /************************* Derived Parameters ************************/
  localparam LOG_NUM_MEMS = $clog2(NUM_MEMS);
  localparam NUM_NIBBLES = WIDTH/4; // = 8
  localparam LOG_NUM_NIBBLES = $clog2(NUM_NIBBLES); // = 3
  localparam LOG_DEPTH = $clog2(DEPTH); // = 3

  localparam CNT_ROW_MAX = NUM_NIBBLES + 2; // NUM_NIBBLES + 2 (CR LF) = 10
  localparam LOG_CNT_ROW_MAX = $clog2(CNT_ROW_MAX); // = 4
  localparam CNT_MAX = 4 + DEPTH * CNT_ROW_MAX + 1; // 4 (header) + DEPTH * (NUM_NIBBLES + 2 (CR LF)) + EOF = 85
  localparam LOG_CNT_MAX = $clog2(CNT_MAX); // = 7
  /************************* Derived Parameters ************************/

  reg [LOG_CNT_MAX-1:0]         cnt_send;
  reg [LOG_CNT_ROW_MAX-1:0]         cnt_send_row;
  reg [LOG_NUM_NIBBLES-1:0]         nibble_cnt;

  reg [LOG_DEPTH-1:0] addr_cnt;
  reg [LOG_NUM_MEMS-1:0] mem_sel;
  reg [WIDTH-1:0] data_temp;
  wire [WIDTH-1:0] data_in_concatenated = {data_temp[WIDTH-1:4], char_to_digit[3:0]};
	wire [WIDTH-1:0] mem_out;

	reg fsm_start;
	wire fsm_done;

  core_fsm # (
    .NUM_MEMS(NUM_MEMS),
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
  ) core_fsm_inst (
    .clk(clk_sys),
    .rst(rst_clk),
    .FIO_wen((state == RECV) && (nibble_cnt == 0)),
    .FIO_sel(mem_sel),
    .FIO_in(data_in_concatenated),
    .FIO_addr(addr_cnt),
    .FIO_out(mem_out),

    .fsm_start(btnl_scen),
    .fsm_done(fsm_done)
  );

  wire [3:0] nibble_mux;
  assign nibble_mux[3] = mem_out[WIDTH-1-4*cnt_send_row[LOG_CNT_ROW_MAX-2:0]];
  assign nibble_mux[2] = mem_out[WIDTH-2-4*cnt_send_row[LOG_CNT_ROW_MAX-2:0]];
  assign nibble_mux[1] = mem_out[WIDTH-3-4*cnt_send_row[LOG_CNT_ROW_MAX-2:0]];
  assign nibble_mux[0] = mem_out[WIDTH-4-4*cnt_send_row[LOG_CNT_ROW_MAX-2:0]];

  // the logic for input to the send buffer. This is the entire character flow of sending a file, including controling characters
  always @ (*) //
  begin
    if (state == SEND)
    begin
        if (cnt_send == 0) send_fifo_din = SOH;
        else if (cnt_send == 1) send_fifo_din = to_char(mem_sel); // name of the file (0, 1, 2, 3...)
        else if (cnt_send == 2) send_fifo_din = EOT;
        else if (cnt_send == 3) send_fifo_din = SOT;
        else if (cnt_send >= 4 && cnt_send <= CNT_MAX - 2) begin
            if (cnt_send_row < NUM_NIBBLES) send_fifo_din = to_char(nibble_mux); // content of the row
            else if (cnt_send_row[0] == 0) send_fifo_din = CR; // line ending
            else if (cnt_send_row[1] == 1) send_fifo_din = LF;
            else send_fifo_din = 8'hXX;
        end else send_fifo_din = EOF; // cnt_send == 84 (CNT_MAX - 1)
    end
	 else send_fifo_din = 8'hXX;
  end

  always @ (posedge clk_sys)
  begin
    if (rst_clk)
    begin
        state <= IDLE;
        addr_cnt <= {LOG_DEPTH{1'bx}};
        cnt_send <= {LOG_CNT_MAX{1'bx}};
    end
    else
    case (state)
    IDLE:           // waiting for the reg ready signal; do not read incoming stream
    begin
        if (reg_ready && reg_pointer == 8'h00) begin
            state <= WAIT_RECV;
            mem_sel <= reg_addr;
        end
        if (btnl_scen) state <= COMP;
        addr_cnt <= 0;
    end
    WAIT_RECV:
        if (receive_data_rdy && receive_fifo_dout == SOT)       // ignore any non-SOT characters
        begin
            state <= RECV;
            addr_cnt <= 0;
            nibble_cnt <= NUM_NIBBLES-1;
        end
    RECV:
        if (receive_data_rdy && (~char_to_digit[4])) begin
            nibble_cnt <= nibble_cnt - 1'b1;
            data_temp[4*nibble_cnt]     <= char_to_digit[0];
            data_temp[4*nibble_cnt + 1] <= char_to_digit[1];
            data_temp[4*nibble_cnt + 2] <= char_to_digit[2];
            data_temp[4*nibble_cnt + 3] <= char_to_digit[3];
            if (nibble_cnt == 0) begin
                    addr_cnt <= addr_cnt + 1'b1;
                    if (addr_cnt == (DEPTH-1)) state <= IDLE;
            end 
        end
    COMP:            // Enter the div state: start running the sub state machine for division
    begin
        if (fsm_done) state <= SEND;
        cnt_send <= 0;
        mem_sel <= 0;
    end
    SEND: 
        if (~send_fifo_full)
        begin
            if (cnt_send == CNT_MAX - 1) begin // 4 (header) + 8 locations * (8 (nibbles) + 2 (/r/n)) + EOF
                cnt_send <= 0;
                mem_sel <= mem_sel + 1'b1;
                if(mem_sel == (NUM_MEMS-1)) state <= WAIT_SEND_DONE;
            end else begin
                cnt_send <= cnt_send + 1;
            end
            if ((mem_sel == (NUM_MEMS-1)) && (send_finish == 1'b1)) state <= IDLE;

            if (cnt_send < 4) begin // Sending header
                cnt_send_row <= 0;
            end else begin
                if (cnt_send_row == CNT_ROW_MAX - 1) begin
                    cnt_send_row <= 0;
                end else begin
                    cnt_send_row <= cnt_send_row + 1;
                end
            end

            if (cnt_send_row == CNT_ROW_MAX - 2) begin // address increment should be 1 clock ahead to accommodate for the IREG latency
                addr_cnt <= addr_cnt + 1;
            end
        end
	 WAIT_SEND_DONE:					// Wait for the entire sending process to finish;
												// After that go back to the receive mode (IDLE state)
			if (send_finish == 1'b1) state <= IDLE;
    endcase
  end
endmodule
