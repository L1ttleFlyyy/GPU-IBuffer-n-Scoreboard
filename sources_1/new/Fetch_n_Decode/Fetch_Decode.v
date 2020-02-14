`timescale 1ns / 1ps

module Fetch_Decode(
	parameter DATA = 32,
    parameter ADDR = 12 
) (
	input clk, 
	input rst_n
	//From TM
	input [2:0] WarpID_TM_PC,	
	input UpdataPC_TM_PC,
	input [31:0] StartingPC_TM_PC,	//???one or eight
	//From SIMT
	input [7:0] UpdatePC_Qual1_SIMT_PC,
	input [31:0] TargetAddr_EX_PC_Warp0,
	input [31:0] TargetAddr_EX_PC_Warp1,
	input [31:0] TargetAddr_EX_PC_Warp2,
	input [31:0] TargetAddr_EX_PC_Warp3,
	input [31:0] TargetAddr_EX_PC_Warp4,
	input [31:0] TargetAddr_EX_PC_Warp5,
	input [31:0] TargetAddr_EX_PC_Warp6,
	input [31:0] TargetAddr_EX_PC_Warp7,
	input [7:0] UpdatePC_Qual2_SIMT_PC,
	input [31:0] TargetAddr_SIMT_PC_Warp0,
	input [31:0] TargetAddr_SIMT_PC_Warp1,
	input [31:0] TargetAddr_SIMT_PC_Warp2,
	input [31:0] TargetAddr_SIMT_PC_Warp3,
	input [31:0] TargetAddr_SIMT_PC_Warp4,
	input [31:0] TargetAddr_SIMT_PC_Warp5,
	input [31:0] TargetAddr_SIMT_PC_Warp6,
	input [31:0] TargetAddr_SIMT_PC_Warp7,
	input [7:0] Stall_SIMT_PC,
	//From IB
	input [7:0] REQ_IB_PC,
	input [7:0] Stall_IB_PC,
	
	//To SMIT
	output [1:0] S_decode_SIMT,
	output [1:0] Call_decode_SIMT,
	output [1:0] Ret_decode_SIMT,
	output [1:0] Jmp_decode_SIMT,
	//To I-buffer
	output [4:0] R1_decode0_Ibuffer,
	output [4:0] R1_decode1_Ibuffer,
	output [4:0] R2_decode0_Ibuffer,
	output [4:0] R2_decode1_Ibuffer,
	output [4:0] R3_decode0_Ibuffer,
	output [4:0] R3_decode1_Ibuffer,
	output [15:0] Offset_decode0_Ibuffer,
	output [15:0] Offset_decode1_Ibuffer,
	output [1:0] RegWrite_decode_Ibuffer,
	output [1:0] MemWrite_decode_Ibuffer,
	output [1:0] MemRead_decode_Ibuffer,
	output [1:0] Exit_decode_Ibuffer,
	output [3:0] ALUop_decode0_Ibuffer,
	output [3:0] ALUop_decode1_Ibuffer,
	output [1:0] Shared_Globalbar_decode_Ibuffer,
	output [1:0] R1_R2_Valid_decode_Ibuffer,
	output [1:0] R3_Valid_decode_Ibuffer,
	//To both SMIT&I-buffer
	output [1:0] BeanchEQ_decode_Ibuffer_SIMT,
	output [1:0] BranchLT_decode_Ibuffer_SIMT
);



endmodule