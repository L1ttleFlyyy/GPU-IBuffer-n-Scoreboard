`timescale 1ns / 1ps

module Fetch_Decode #(
	parameter DATA = 32,
    parameter ADDR = 12  //TODO: These two params are not used?
) (
	input clk, 
	input rst_n,
	//From TM
	input [2:0] WarpID_TM_PC,	//TODO: _PC or _IF? pipelined/flow-through
	input UpdatePC_TM_PC,
	input [31:0] StartingPC_TM_PC,	//TODO:one or eight
	//From SIMT
	// TODO: shall we use flattened I/O? i.e.: 
	// input [32*8-1:0] TargetAddr_ALU_PC_Flattened,
	// and internally: wire [31:0] TargetAddr_ALU_PC [0:7];
	input [7:0] UpdatePC_Qual1_SIMT_PC,
	input [31:0] TargetAddr_ALU_PC_Warp0, // EX -> ALU follow the naming convention in Short Names.xlsx
	input [31:0] TargetAddr_ALU_PC_Warp1,
	input [31:0] TargetAddr_ALU_PC_Warp2,
	input [31:0] TargetAddr_ALU_PC_Warp3,
	input [31:0] TargetAddr_ALU_PC_Warp4,
	input [31:0] TargetAddr_ALU_PC_Warp5,
	input [31:0] TargetAddr_ALU_PC_Warp6,
	input [31:0] TargetAddr_ALU_PC_Warp7,
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
	input [7:0] Req_IB_PC,
	// input [7:0] Stall_IB_PC, 
	// TODO:instead of giving a stall signal, IB will simply supress Req internally
	
	// To SMIT 
	// FIXME: missing valid signals
	output [7:0] Valid_IF_IB, // Data-stationary method of control
	
	// FIXME: PCplus4 is missing
	input [9:0] PCplus4_ID0_SIMT,
	input [9:0] PCplus4_ID1_SIMT,
	// TODO: ID0 and ID1 Or combined as array?
	output DotS_ID0_SIMT,
	output DotS_ID1_SIMT,
	output Call_ID0_SIMT,
	output Call_ID1_SIMT,
	output Ret_ID0_SIMT,
	output Ret_ID1_SIMT,
	output Jmp_ID0_SIMT,
	output Jmp_ID1_SIMT,
	//To I-buffer
	// FIXME: The orignal instruction should also be passed through the pipeline?
	// for debugging purpose (reverse assembler)
	output [31:0] Inst_ID0_IB,
	output [31:0] Inst_ID1_IB,

	output [4:0] Src1_ID0_IB, // again, follow the naming convention
	output [4:0] Src1_ID1_IB,
	output [4:0] Src2_ID0_IB,
	output [4:0] Src2_ID1_IB,
	output [4:0] Dst_ID0_IB,
	output [4:0] Dst_ID1_IB,
	output [15:0] Offset_ID0_IB, // TODO: Offset or Imme
	output [15:0] Offset_ID1_IB,
	output RegWrite_ID0_IB,
	output RegWrite_ID1_IB,
	output MemWrite_ID0_IB,
	output MemWrite_ID1_IB,
	output MemRead_ID0_IB,
	output MemRead_ID1_IB,
	output [1:0] ALUit_decode_IB, // TODO: what is this signal?
	output [3:0] ALUop_ID0_IB,
	output [3:0] ALUop_ID1_IB,
	output Shared_Globalbar_ID0_IB,
	output Shared_Globalbar_ID1_IB,
	// FIXME: valid bit attached to each of the registers
	output Src1_Valid_ID0_IB,
	output Src1_Valid_ID1_IB,
	output Src2_Valid_ID0_IB,
	output Src2_Valid_ID1_IB,
	output Dst_Valid_ID0_IB,
	output Dst_Valid_ID1_IB,
	// FIXME: decoding for exit?
	output Exit_ID0_IB,
	output Exit_ID1_IB,
	//To both SMIT&I-buffer
	output BEQ_ID0_IB_SIMT,
	output BEQ_ID1_IB_SIMT,
	output BLT_ID0_IB_SIMT,
	output BLT_ID1_IB_SIMT,
	output [7:0] Valid_ID0_IB_SIMT,
	output [7:0] Valid_ID1_IB_SIMT
);



endmodule