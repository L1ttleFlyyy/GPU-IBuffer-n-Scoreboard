`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2020 05:10:59 PM
// Design Name: 
// Module Name: Scheduler
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


module Scheduler(
    input clk,
    input rst,
    // interface with ALU/MEM TODO: How many clocks does a LW hit take?
    input RegWrite_LastStage_MEM_Sched,
    // interface with OC
    input [3:0] ALU_RegWrite_OC_Sched,
    input [3:0] ALU_Req_OC_Sched,
    input [3:0] MEM_Req_OC_Sched,
    output [3:0] ALU_Grt_Sched_OC,
    output [3:0] MEM_Grt_Sched_OC
    );

    wire [3:0] ALU_Req_Qualified;

    assign ALU_Req_Qualified = RegWrite_LastStage_MEM_Sched? 
        (~ALU_RegWrite_OC_Sched & ALU_Req_OC_Sched) : ALU_Req_OC_Sched;

    rr_prioritizer #(
        .WIDTH(4)
    ) Sched_ALU (
        .clk(clk),
        .rst(rst),
        .req(ALU_Req_Qualified),
        .grt(ALU_Grt_Sched_OC)
    );

    rr_prioritizer #(
        .WIDTH(4)
    ) Sched_MEM (
        .clk(clk),
        .rst(rst),
        .req(MEM_Req_OC_Sched),
        .grt(MEM_Grt_Sched_OC)
    );

endmodule