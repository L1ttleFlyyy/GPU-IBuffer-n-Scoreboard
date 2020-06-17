`timescale 1ns / 100ps

module scheduler_4(
    input wire clk,
    input wire rst,
    input wire RDY_0,
    input wire RDY_1,
    input wire RDY_2,
    input wire RDY_3,
    input wire RegWrite_OC_Ex_0,
    input wire RegWrite_OC_Ex_1,
    input wire RegWrite_OC_Ex_2,
    input wire RegWrite_OC_Ex_3,
    input wire MemWrite_OC_Ex_0,
    input wire MemWrite_OC_Ex_1,
    input wire MemWrite_OC_Ex_2,
    input wire MemWrite_OC_Ex_3,
    input wire MemRead_OC_Ex_0,
    input wire MemRead_OC_Ex_1,
    input wire MemRead_OC_Ex_2,
    input wire MemRead_OC_Ex_3,

    
    output [3:0] ALU_Grt_Sched_OC,
    output [3:0] MEM_Grt_Sched_OC
);

wire [3:0] MEM_Req_OC_Sched = {(RDY_3 & (MemRead_OC_Ex_3| MemWrite_OC_Ex_3)),(RDY_2 & (MemRead_OC_Ex_2| MemWrite_OC_Ex_2)),(RDY_1 & (MemRead_OC_Ex_1| MemWrite_OC_Ex_1)),(RDY_0 & (MemRead_OC_Ex_0| MemWrite_OC_Ex_0))};
wire [3:0] ALU_Req_OC_Sched = {(RDY_3 & ~(MemRead_OC_Ex_3| MemWrite_OC_Ex_3)),(RDY_2 & ~(MemRead_OC_Ex_2| MemWrite_OC_Ex_2)),(RDY_1 & ~(MemRead_OC_Ex_1| MemWrite_OC_Ex_1)),(RDY_0 & ~(MemRead_OC_Ex_0| MemWrite_OC_Ex_0))};
wire [3:0] RegWrite_OC_Sched = {RegWrite_OC_Ex_3,RegWrite_OC_Ex_2,RegWrite_OC_Ex_1,RegWrite_OC_Ex_0};

Scheduler sched (
    .clk(clk),
    .rst(rst),
    .RegWrite_OC_Sched(RegWrite_OC_Sched),
    .ALU_Req(ALU_Req_OC_Sched),
    .MEM_Req(MEM_Req_OC_Sched),
    .ALU_Grt(ALU_Grt_Sched_OC),
    .MEM_Grt(MEM_Grt_Sched_OC)

);

endmodule