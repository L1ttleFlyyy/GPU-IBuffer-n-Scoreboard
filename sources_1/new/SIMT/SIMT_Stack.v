module SIMT(
// Global Signals
input clk,
input rst,

//interface with Task Manager
input Update_TM_SIMT,
input [2:0] WarpID_TM_SIMT,
input [7:0] AM_TM_SIMT,

//interface with Fetch
output reg [7:0] UpdatePC_Qual1_SIMT_IF,
output reg [7:0] UpdatePC_Qual2_SIMT_IF,
  //--Moved to Decode stage--> output [7:0] UpdatePC_Qual3,
output [7:0] Stall_SIMT_IF,    //Stall signal from SIMT
// TODO: naming convention
// TODO: PC width 10 vs 32
output reg [9:0] TA_Warp0_SIMT_IF,  // Target Address from SIMT per warp
output reg [9:0] TA_Warp1_SIMT_IF,
output reg [9:0] TA_Warp2_SIMT_IF,
output reg [9:0] TA_Warp3_SIMT_IF,
output reg [9:0] TA_Warp4_SIMT_IF,
output reg [9:0] TA_Warp5_SIMT_IF,
output reg [9:0] TA_Warp6_SIMT_IF,
output reg [9:0] TA_Warp7_SIMT_IF,

//interface with Instruction Decode
input CondBr_ID0_SIMT, // TODO: BEQ | BLT
input CondBr_ID1_SIMT,
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
input [9:0] PCplus4_ID0_SIMT,
input [9:0] PCplus4_ID1_SIMT,

//interface with IBuffer
// TODO: flattened active mask
output reg [7:0] DropInstr_SIMT_IB,
output [8*8-1:0] ActiveMask_SIMT_IB_Flattened,

//interface with ALU
input CondBr_ALU_SIMT,
input [7:0] BrOutcome_ALU_SIMT,
input [2:0] WarpID_ALU_SIMT

);


endmodule
