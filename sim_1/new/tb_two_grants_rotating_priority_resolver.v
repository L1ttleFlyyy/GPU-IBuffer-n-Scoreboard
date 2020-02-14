`timescale 1ns/1ps
module tb_two_grants_rotating_priority_resolver ();
reg clk, rst_n;
reg [7:0] REQ_IBuffer_PC, Stall_SIMT_PC, Stall_IBuffer_PC;
wire [7:0] GRT, GRT_raw_1, GRT_raw_2;

two_grants_rotating_priority_resolver tgrpr(
clk, rst_n,
REQ_IBuffer_PC,  // 8 request signals
Stall_SIMT_PC,   // 8 stall signals from SIMT
Stall_IBuffer_PC,  // 8 stall signals from I-buffer
GRT,            // 8 grant signals out
GRT_raw_1, GRT_raw_2 //out
);

always #1 clk = !clk;

initial begin
rst_n = 0;
#5 rst_n = 1;
Stall_SIMT_PC = 8'b0;
Stall_IBuffer_PC = 8'b0;
REQ_IBuffer_PC = 8'hff;
#10 REQ_IBuffer_PC = 8'b0000_1000;
#2 REQ_IBuffer_PC = 8'b0000_0100;
#2 REQ_IBuffer_PC = 8'b0101_0101;
#2 REQ_IBuffer_PC = 8'b0101_0101;
#2 REQ_IBuffer_PC = 8'b1111_0101;
#2 REQ_IBuffer_PC = 8'b0101_1111;
#2 REQ_IBuffer_PC = 8'b0000_0000;
#4 $stop;
end


endmodule