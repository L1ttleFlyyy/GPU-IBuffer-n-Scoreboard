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
output reg [9:0] TA_Warp0_SIMT_IF,  // Target Address from SIMT per warp
output reg [9:0] TA_Warp1_SIMT_IF,
output reg [9:0] TA_Warp2_SIMT_IF,
output reg [9:0] TA_Warp3_SIMT_IF,
output reg [9:0] TA_Warp4_SIMT_IF,
output reg [9:0] TA_Warp5_SIMT_IF,
output reg [9:0] TA_Warp6_SIMT_IF,
output reg [9:0] TA_Warp7_SIMT_IF,

//interface with Instruction Decode
input CondBr_ID1_SIMT,
input CondBr_ID2_SIMT,
input DotS_ID1_SIMT,
input DotS_ID2_SIMT,
input Call_ID1_SIMT,
input Call_ID2_SIMT,
input Ret_ID1_SIMT,
input Ret_ID2_SIMT,
input Jump_ID1_SIMT,
input Jump_ID2_SIMT,
input [7:0] WarpOneHot_ID1_SIMT,
input [7:0] WarpOneHot_ID2_SIMT,
input [9:0] PCplus4_ID1_SIMT,
input [9:0] PCplus4_ID2_SIMT,

//interface with IBuffer
output reg [7:0] DropInstr_SIMT_IB,
output [7:0] AM_Warp0_SIMT_IB,
output [7:0] AM_Warp1_SIMT_IB,
output [7:0] AM_Warp2_SIMT_IB,
output [7:0] AM_Warp3_SIMT_IB,
output [7:0] AM_Warp4_SIMT_IB,
output [7:0] AM_Warp5_SIMT_IB,
output [7:0] AM_Warp6_SIMT_IB,
output [7:0] AM_Warp7_SIMT_IB

//interface with EX
input CondBr_Ex_SIMT,
input [7:0] CondOutcome_Ex_SIMT,
input [2:0] WarpID_Ex_SIMT

);



endmodule
