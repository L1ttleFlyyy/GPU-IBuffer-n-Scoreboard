`timescale  1ns / 100ps       

module tb_Inferable_BRAM;   

// Inferable_BRAM Parameters
parameter PERIOD = 10;      
parameter OREG  = 0 ;
parameter DATA  = 32;
parameter ADDR  = 9 ;

// Inferable_BRAM Inputs
reg   a_clk                                = 0 ;
reg   a_wr                                 = 0 ;
reg   [ADDR-1:0]  a_addr                   = 0 ;
reg   [DATA-1:0]  a_din                    = 0 ;
reg   b_clk                                = 0 ;
reg   b_wr                                 = 0 ;
reg   [ADDR-1:0]  b_addr                   = 0 ;
reg   [DATA-1:0]  b_din                    = 0 ;

// Inferable_BRAM Outputs
wire  [DATA-1:0]  a_dout                   ;
wire  [DATA-1:0]  b_dout                   ;


initial
begin
    forever #(PERIOD/2)  a_clk=~a_clk;
    forever #(PERIOD/2)  b_clk=~b_clk;
end


Inferable_BRAM #(
    .OREG ( OREG ),
    .DATA ( DATA ),
    .ADDR ( ADDR ))
 u_Inferable_BRAM (
    .a_clk                   ( a_clk              ),
    .a_wr                    ( a_wr               ),
    .a_addr                  ( a_addr  [ADDR-1:0] ),
    .a_din                   ( a_din   [DATA-1:0] ),
    .b_clk                   ( b_clk              ),
    .b_wr                    ( b_wr               ),
    .b_addr                  ( b_addr  [ADDR-1:0] ),

    .a_dout                  ( a_dout  [DATA-1:0] ),
    .b_dout                  ( b_dout  [DATA-1:0] )
);

initial
begin
    a_addr = 9'h1;
    #(PERIOD*2);
    a_wr = 1;
    a_din = 32'h55555555;
    #(PERIOD);
    a_wr = 0;
    a_addr = 9'h2;
    #(PERIOD);
    a_addr = 9'h1;
    #(PERIOD*2);
    
    
    $finish;
end

endmodule