module SIMT(
// Global Signals
input clk,
input rst,

//interface with Task Manager
input Update_TM_SIMT,
input [2:0] WarpID_TM_SIMT,
input [7:0] AM_TM_SIMT,

//interface with Fetch (PC)
output reg [7:0] UpdatePC_Qual1_SIMT_PC,
output reg [7:0] UpdatePC_Qual2_SIMT_PC,
  //--Moved to Decode stage--> output [7:0] UpdatePC_Qual3,
output [7:0] Stall_SIMT_PC,    //Stall signal from SIMT
// TODO: naming convention
// TODO: PC width 10 vs 32
output [32*8-1:0] TargetAddr_SIMT_PC_Flattened,

//interface with Instruction Decode
// input CondBr_ID0_SIMT, // TODO: BEQ | BLT
// input CondBr_ID1_SIMT,
input BEQ_ID0_IB_SIMT,
input BEQ_ID1_IB_SIMT,
input BLT_ID0_IB_SIMT,
input BLT_ID1_IB_SIMT,
input DotS_ID0_SIMT,
input DotS_ID1_SIMT,
input Call_ID0_SIMT,
input Call_ID1_SIMT,
input Ret_ID0_SIMT,
input Ret_ID1_SIMT,
input Jmp_ID0_SIMT,
input Jmp_ID1_SIMT,
input [7:0] Valid_ID0_IB_SIMT, // TODO: both IB and SIMT need this
input [7:0] Valid_ID1_IB_SIMT,
input [31:0] PCplus4_ID0_SIMT,
input [31:0] PCplus4_ID1_SIMT,

//interface with IBuffer
// TODO: flattened active mask
output reg [7:0] DropInstr_SIMT_IB,
output [8*8-1:0] ActiveMask_SIMT_IB_Flattened,

//interface with ALU
input Br_ALU_SIMT,
input [7:0] BrOutcome_ALU_SIMT,
input [2:0] WarpID_ALU_SIMT

);


endmodule
