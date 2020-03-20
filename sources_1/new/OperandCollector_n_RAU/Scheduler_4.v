module schedular_4(
    input wire clk,
    input wire rst,
    input wire RDY_0,
    input wire RDY_1,
    input wire RDY_2,
    input wire RDY_3,
    input wire RegWrite_Collecting_Ex_0,
    input wire RegWrite_Collecting_Ex_1,
    input wire RegWrite_Collecting_Ex_2,
    input wire RegWrite_Collecting_Ex_3,
    input wire MemWrite_Collecting_Ex_0,
    input wire MemWrite_Collecting_Ex_1,
    input wire MemWrite_Collecting_Ex_2,
    input wire MemWrite_Collecting_Ex_3,
    input wire MemRead_Collecting_Ex_0,
    input wire MemRead_Collecting_Ex_1,
    input wire MemRead_Collecting_Ex_2,
    input wire MemRead_Collecting_Ex_3,

    input wire RegWrite_LastStage_MEM_Sched,
    
    output [3:0] ALU_Grt_Sched_OC,
    output [3:0] MEM_Grt_Sched_OC
);

wire [3:0] MEM_Req_OC_Sched = {(RDY_3 & (MemRead_Collecting_Ex_3| MemWrite_Collecting_Ex_3)),(RDY_2 & (MemRead_Collecting_Ex_2| MemWrite_Collecting_Ex_2)),(RDY_1 & (MemRead_Collecting_Ex_1| MemWrite_Collecting_Ex_1)),(RDY_0 & (MemRead_Collecting_Ex_0| MemWrite_Collecting_Ex_0))};
wire [3:0] ALU_Req_OC_Sched = {(RDY_3 & ~(MemRead_Collecting_Ex_3| MemWrite_Collecting_Ex_3)),(RDY_2 & ~(MemRead_Collecting_Ex_2| MemWrite_Collecting_Ex_2)),(RDY_1 & ~(MemRead_Collecting_Ex_1| MemWrite_Collecting_Ex_1)),(RDY_0 & ~(MemRead_Collecting_Ex_0| MemWrite_Collecting_Ex_0))};
wire [3:0] ALU_RegWrite_OC_Sched = ALU_Req_OC_Sched & {RegWrite_Collecting_Ex_3,RegWrite_Collecting_Ex_2,RegWrite_Collecting_Ex_1,RegWrite_Collecting_Ex_0};

Scheduler schedular_4(
    .clk(clk),
    .rst(rst),
    .RegWrite_LastStage_MEM_Sched(RegWrite_LastStage_MEM_Sched),
    .ALU_RegWrite_OC_Sched(ALU_RegWrite_OC_Sched),
    .ALU_Req_OC_Sched(ALU_Req_OC_Sched),
    .MEM_Req_OC_Sched(MEM_Req_OC_Sched),
    .ALU_Grt_Sched_OC(ALU_Grt_Sched_OC),
    .MEM_Grt_Sched_OC(MEM_Grt_Sched_OC)

);

endmodule