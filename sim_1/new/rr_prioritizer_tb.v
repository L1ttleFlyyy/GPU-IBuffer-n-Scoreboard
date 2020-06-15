`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2020 06:18:08 PM
// Design Name: 
// Module Name: rr_prioritizer_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_rr_prioritizer;

// rr_prioritizer Parameters
parameter PERIOD = 10;
parameter WIDTH  = 8;

// rr_prioritizer Inputs
reg   clk                                  = 0 ;
reg   rst                                  = 0 ;
reg   [WIDTH - 1: 0]  req                  = 0 ;

// rr_prioritizer Outputs
wire  [WIDTH - 1: 0]  grt                  ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst  =  1;
end

rr_prioritizer #(
    .WIDTH ( WIDTH ))
 u_rr_prioritizer (
    .clk                     ( clk                 ),
    .rst                     ( rst                 ),
    .req                     ( req  [WIDTH - 1: 0] ),

    .grt                     ( grt  [WIDTH - 1: 0] )
);

initial
begin
    #(PERIOD*10)req = 0;
    #(PERIOD*10)req = {WIDTH{1'b1}};
    #(PERIOD*10)req = {{(WIDTH/2){1'b0}}, {(WIDTH/2){1'b1}}};
    #(PERIOD*10)req = {(WIDTH/2){2'b01}};
    #(PERIOD*10)req = {(WIDTH/2){2'b10}};
    #(PERIOD*10)req = 0;
    $finish;
end

endmodule
