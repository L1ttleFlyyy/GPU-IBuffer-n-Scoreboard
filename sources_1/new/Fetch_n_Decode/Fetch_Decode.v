`timescale 1ns / 1ps

module Fetch_Decode #(
	parameter DATA = 32,
    parameter ADDR = 12  
) (
	input clk, 
	input rst_n,
	//From TM
	input [2:0] WarpID_TM_PC,
	input UpdatePC_TM_PC,
	input [31:0] StartingPC_TM_PC,	
	//From ALU
	input [32*8-1:0] TargetAddr_ALU_PC_Flattened, //work with UpdatePC_Qual1_SIMT_PC
	//From SIMT
	input [7:0] Stall_SIMT_PC,
	input [7:0] UpdatePC_Qual1_SIMT_PC,
	input [7:0] UpdatePC_Qual2_SIMT_PC,
	input [32*8-1:0] TargetAddr_SIMT_PC_Flattened, //work with UpdatePC_Qual2_SIMT_PC
	//From IB 
	input [7:0] Req_IB_PC,
	
	// To SMIT
	output [9:0] PCplus4_ID0_SIMT,
	output [9:0] PCplus4_ID1_SIMT,
	output DotS_ID0_SIMT,
	output DotS_ID1_SIMT,
	output Call_ID0_SIMT,
	output Call_ID1_SIMT,
	output Ret_ID0_SIMT,
	output Ret_ID1_SIMT,
	output Jmp_ID0_SIMT,
	output Jmp_ID1_SIMT,
	//To I-buffer
	output [7:0] Valid_IF_IB, // Data-stationary method of control
	output [4:0] Src1_ID0_IB, 
	output [4:0] Src1_ID1_IB,
	output [4:0] Src2_ID0_IB,
	output [4:0] Src2_ID1_IB,
	output [4:0] Dst_ID0_IB,
	output [4:0] Dst_ID1_IB,
	output [15:0] Imme_ID0_IB, 
	output [15:0] Imme_ID1_IB,
	output RegWrite_ID0_IB,
	output RegWrite_ID1_IB,
	output MemWrite_ID0_IB,
	output MemWrite_ID1_IB,
	output MemRead_ID0_IB,
	output MemRead_ID1_IB,
	output Exit_ID0_IB,
	output Exit_ID1_IB,
	output [3:0] ALUop_ID0_IB,
	output [3:0] ALUop_ID1_IB,
	output Shared_Globalbar_ID0_IB,
	output Shared_Globalbar_ID1_IB,
	output Src1_Valid_ID0_IB,
	output Src1_Valid_ID1_IB,
	output Src2_Valid_ID0_IB,
	output Src2_Valid_ID1_IB,
	output Imme_Valid_ID0_IB,
	output Imme_Valid_ID1_IB,
	output [31:0] Instr_ID0_IB,
	output [31:0] Instr_ID1_IB,
	//To both SMIT&I-buffer
	output BEQ_ID0_IB_SIMT,
	output BEQ_ID1_IB_SIMT,
	output BLT_ID0_IB_SIMT,
	output BLT_ID1_IB_SIMT,
	output [7:0] Valid_ID0_IB_SIMT,	//one-hot warpID
	output [7:0] Valid_ID1_IB_SIMT
);

wire [31:0] TargetAddr_ALU_PC [7:0];
wire [31:0] TargetAddr_SIMT_PC [7:0];



endmodule