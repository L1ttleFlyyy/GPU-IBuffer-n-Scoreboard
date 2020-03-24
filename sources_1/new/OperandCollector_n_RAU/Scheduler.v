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

/*
 * NOTE: CDB is the only shared resource between the function units
 * All the scheduling logic here is to maximize the throughput
 * as well as to avoid CDB conflicts
 * In any case, a non-regwrite instruction can always be scheduled
 * since it does not go onto CDB
 */

module Scheduler # (
    parameter NUM_MEM_STAGES = 4 // TODO: How many clocks does a LW hit take?
    ) (
    input clk,
    input rst,
    input [3:0] RegWrite_OC_Sched,
    input [3:0] ALU_Req,
    input [3:0] MEM_Req,
    output [3:0] ALU_Grt,
    output [3:0] MEM_Grt
    );

    wire [3:0] MEM_Grt_RegWrite = MEM_Grt & RegWrite_OC_Sched;
    wire MEM_RegWrite_in = MEM_Grt_RegWrite != 0;

    reg [NUM_MEM_STAGES-2:0] MEM_RegWrite_SftReg;
    always@ (posedge clk, negedge rst) begin
        if (!rst) begin
            MEM_RegWrite_SftReg <= 0;
        end else begin
            MEM_RegWrite_SftReg <= {MEM_RegWrite_SftReg[NUM_MEM_STAGES-3:0], MEM_RegWrite_in};
        end
    end

    // If there is a LW entering the last stage of MEM, then we cannot schedule ALU regwrite
    // But we will not block non-regwrite ALU instructions such as BEQ/BLT
    wire [3:0] ALU_Req_Qualified = MEM_RegWrite_SftReg[NUM_MEM_STAGES-2]? 
        (~RegWrite_OC_Sched & ALU_Req) : ALU_Req;

    // If there is an ALU regwrite awaiting, 
    // AND MEM has been filled up with LWs, 
    // then we will block any incoming LW requests
    // This provides the ALU RegWrite a slot to breathe. After 3 clocks, it will get a chance to go
    // Note that SWs can still get grant and be scheduled
    wire ALU_RegWrite_Awaiting = (ALU_Req & RegWrite_OC_Sched) != 0;
    wire [3:0] MEM_Req_Qualified = (ALU_RegWrite_Awaiting && (&MEM_RegWrite_SftReg))? 
        (~RegWrite_OC_Sched & MEM_Req) : MEM_Req;

    rr_prioritizer #(
        .WIDTH(4)
    ) Sched_ALU (
        .clk(clk),
        .rst(rst),
        .req(ALU_Req_Qualified),
        .grt(ALU_Grt)
    );

    rr_prioritizer #(
        .WIDTH(4)
    ) Sched_MEM (
        .clk(clk),
        .rst(rst),
        .req(MEM_Req_Qualified),
        .grt(MEM_Grt)
    );

endmodule
