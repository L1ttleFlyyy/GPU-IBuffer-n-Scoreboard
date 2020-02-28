`timescale 1ns / 1ps

module Fetch_Decode #(
	parameter DATA = 32,
    parameter ADDR = 12  
) (
	input clk, 
	input rst_n,
	// FileIO
	input FileIO_Wen_ICache,
	input [11:0] FileIO_Addr_ICache,
	input [31:0] FileIO_Din_ICache,
	output [31:0] FileIO_Dout_ICache,
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
	output [31:0] PCplus4_ID0_SIMT,
	output [31:0] PCplus4_ID1_SIMT,
	output DotS_ID0_SIMT,
	output DotS_ID1_SIMT,
	output Call_ID0_SIMT,
	output Call_ID1_SIMT,
	output Ret_ID0_SIMT,
	output Ret_ID1_SIMT,
	output Jmp_ID0_SIMT,
	output Jmp_ID1_SIMT,
	//To I-buffer
	output [31:0] Instr_ID0_IB,
	output [31:0] Instr_ID1_IB,
	output [7:0] Valid_IF_ID0_IB, // Data-stationary method of control
	output [7:0] Valid_IF_ID1_IB, // Data-stationary method of control
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
reg [7:0] WarpID_onehot_TM_PC;
wire [7:0] UpdatePC_mature_TM_PC;
wire [31:0] PC_out [7:0];
wire [7:0] Valid_3_ID0_PC, Valid_3_ID1_PC;
wire [7:0] PC_Valid;
wire [7:0] GRT;
wire [7:0] GRT_raw_1, GRT_raw_2;
wire [7:0] UpdatePC_Qual3_ID0_PC, UpdatePC_Qual3_ID1_PC;
wire [31:0] TargetAddr_ID0_PC, TargetAddr_ID1_PC;
wire [31:0] Instr_IF_ID0, Instr_IF_ID1;
wire [31:0] PC_plus4_IF_ID0, PC_plus4_IF_ID1;
wire [7:0] Valid_2_IF_ID0, Valid_2_IF_ID1, Valid_3_IF_ID0, Valid_3_IF_ID1;

//1st Stage: PC
always @(*) begin	//3-8 deocde
	case (WarpID_TM_PC)
		3'b000: WarpID_onehot_TM_PC = 8'b00000001;
		3'b001: WarpID_onehot_TM_PC = 8'b00000010;
		3'b010: WarpID_onehot_TM_PC = 8'b00000100;
		3'b011: WarpID_onehot_TM_PC = 8'b00001000;
		3'b100: WarpID_onehot_TM_PC = 8'b00010000;
		3'b101: WarpID_onehot_TM_PC = 8'b00100000;
		3'b110: WarpID_onehot_TM_PC = 8'b01000000;
		3'b111: WarpID_onehot_TM_PC = 8'b10000000;
		default: WarpID_onehot_TM_PC = 8'b00000000;
	endcase
end

genvar i;
generate
	for (i = 0; i < 8 ; i = i+1) begin: g1
		assign TargetAddr_ALU_PC[i] = TargetAddr_ALU_PC_Flattened[i*32+31: i*32];
		assign TargetAddr_SIMT_PC[i] = TargetAddr_SIMT_PC_Flattened[i*32+31: i*32];
		assign UpdatePC_mature_TM_PC[i] = WarpID_onehot_TM_PC[i] && UpdatePC_TM_PC;
		PC_update pc(
			.clk(clk), 
			.rst_n(rst_n), 
			.UpdatePC_TM_PC(UpdatePC_mature_TM_PC[i]), 
			.StartingPC_TM_PC(StartingPC_TM_PC),
			.TargetAddr_ALU_PC(TargetAddr_ALU_PC[i]),
			.Stall_SIMT_PC(Stall_SIMT_PC[i]),
			.UpdatePC_Qual1_SIMT_PC(UpdatePC_Qual1_SIMT_PC[i]),
			.UpdatePC_Qual2_SIMT_PC(UpdatePC_Qual2_SIMT_PC[i]),
			.TargetAddr_SIMT_PC(TargetAddr_SIMT_PC[i]),
			.GRT_RR_PC(GRT[i]),
			.valid_1_IF_PC(GRT[i]),
			.valid_2_IF_PC(Valid_2_IF_ID0 || Valid_2_IF_ID1),
			.valid_3_IF_PC(Valid_3_IF_ID0 || Valid_3_IF_ID1),
			.Valid_3_ID1_PC(Valid_3_ID1_PC[i]),
			.UpdatePC_Qual3_ID0_PC(UpdatePC_Qual3_ID0_PC[i]),
			.UpdatePC_Qual3_ID1_PC(UpdatePC_Qual3_ID1_PC[i]),
			.TargetAddr_ID0_PC(TargetAddr_ID0_PC),
			.TargetAddr_ID1_PC(TargetAddr_ID1_PC),

			.PC_out_IF_PC(PC_out[i])
		);
	end
endgenerate

Two_Grants_Rotating_Priority_Resolver rr(
	.clk(clk), 
	.rst_n(rst_n),
	.Req_IB_PC(Req_IB_PC), 
	.Stall_SIMT_PC(Stall_SIMT_PC), 
	.PCValid_ID_IB(PC_Valid), 

	.GRT_RR_PC(GRT), 
	.GRT_raw_1_RR_IF(GRT_raw_1),
	.GRT_raw_2_RR_IF(GRT_raw_2)
);

Generate_PCvalid_Logic pc_valid(
	.clk(clk), 
	.rst_n(rst_n),
	.Valid_ID0_IB(Valid_3_ID0_PC), 
	.Valid_ID1_IB(Valid_3_ID1_PC),
	.Exit_ID0_IB(Exit_ID0_IB), 
	.Exit_ID1_IB(Exit_ID1_IB),
	.UpdatePC_TM_PC(UpdatePC_mature_TM_PC),

	.PCValid_PC_RR(PC_Valid)
);

//2nd Stage: IF
Fetch ifetch(
	.clk(clk), 
	.rst_n(rst_n),

	.FileIO_Wen_ICache(FileIO_Wen_ICache),
	.FileIO_Addr_ICache(FileIO_Addr_ICache),
	.FileIO_Din_ICache(FileIO_Din_ICache),
	.FileIO_Dout_ICache(FileIO_Dout_ICache),
	.PC0_PC_IF(PC_out[0]), 
	.PC1_PC_IF(PC_out[1]), 
	.PC2_PC_IF(PC_out[2]), 
	.PC3_PC_IF(PC_out[3]), 
	.PC4_PC_IF(PC_out[4]), 
	.PC5_PC_IF(PC_out[5]), 
	.PC6_PC_IF(PC_out[6]), 
	.PC7_PC_IF(PC_out[7]), 
	.GRT_raw_1_RR_IF(GRT_raw_1), 
	.GRT_raw_2_RR_IF(GRT_raw_2),
	.UpdatePC_Qual1_SIMT_IF(UpdatePC_Qual1_SIMT_PC),
	.UpdatePC_Qual2_SIMT_IF(UpdatePC_Qual2_SIMT_PC),
	.UpdatePC_Qual3_ID0_IF(UpdatePC_Qual3_ID0_PC),
	.UpdatePC_Qual3_ID1_IF(UpdatePC_Qual3_ID1_PC),

	.Instr_IF_ID0(Instr_IF_ID0), 
	.Instr_IF_ID1(Instr_IF_ID1),
	.PC_plus4_IF_ID0(PC_plus4_IF_ID0), 
	.PC_plus4_IF_ID1(PC_plus4_IF_ID1),
	.Valid_2_IF_ID0(Valid_2_IF_ID0), 
	.Valid_2_IF_ID1(Valid_2_IF_ID1),
	.Valid_3_IF_ID0(Valid_3_IF_ID0), 
	.Valid_3_IF_ID1(Valid_3_IF_ID1)
);

//3rd Stage: ID
Decode id(
	//From IF 
	.PCplus4_IF_ID0(PC_plus4_IF_ID0),
	.PCplus4_IF_ID1(PC_plus4_IF_ID1),
	.Instr_in_IF_ID0(Instr_IF_ID0),
	.Instr_in_IF_ID1(Instr_IF_ID1),
	.Valid_2_IF_ID0(Valid_2_IF_ID0),
	.Valid_2_IF_ID1(Valid_2_IF_ID1),
	.Valid_3_IF_ID0(Valid_3_IF_ID0),
	.Valid_3_IF_ID1(Valid_3_IF_ID1),
	//To PC
	.Valid_3_ID0_PC(Valid_3_ID0_PC),
	.Valid_3_ID1_PC(Valid_3_ID1_PC),
	.UpdatePC_Qual3_ID0_PC(UpdatePC_Qual3_ID0_PC),
	.UpdatePC_Qual3_ID1_PC(UpdatePC_Qual3_ID1_PC),
	.TargetAddr_ID0_PC(TargetAddr_ID0_PC),
	.TargetAddr_ID1_PC(TargetAddr_ID1_PC),
	//To SMIT
	.PCplus4_ID0_SIMT(PCplus4_ID0_SIMT),
	.PCplus4_ID1_SIMT(PCplus4_ID1_SIMT),
	.DotS_ID0_SIMT(DotS_ID0_SIMT),
	.DotS_ID1_SIMT(DotS_ID1_SIMT),
	.Call_ID0_SIMT(Call_ID0_SIMT),
	.Call_ID1_SIMT(Call_ID1_SIMT),
	.Ret_ID0_SIMT(Ret_ID0_SIMT),
	.Ret_ID1_SIMT(Ret_ID1_SIMT),
	.Jmp_ID0_SIMT(Jmp_ID0_SIMT),
	.Jmp_ID1_SIMT(Jmp_ID1_SIMT),
	//To I-buffer
	.Instr_ID0_IB(Instr_ID0_IB),
	.Instr_ID1_IB(Instr_ID1_IB),
	.Valid_IF_ID0_IB(Valid_IF_ID0_IB), // Data-stationary method of control
	.Valid_IF_ID1_IB(Valid_IF_ID1_IB), // Data-stationary method of control
	.Src1_ID0_IB(Src1_ID0_IB), 
	.Src1_ID1_IB(Src1_ID1_IB),
	.Src2_ID0_IB(Src2_ID0_IB),
	.Src2_ID1_IB(Src2_ID1_IB),
	.Dst_ID0_IB(Dst_ID0_IB),
	.Dst_ID1_IB(Dst_ID1_IB),
	.Imme_ID0_IB(Imme_ID0_IB), 
	.Imme_ID1_IB(Imme_ID1_IB),
	.RegWrite_ID0_IB(RegWrite_ID0_IB),
	.RegWrite_ID1_IB(RegWrite_ID1_IB),
	.MemWrite_ID0_IB(MemWrite_ID0_IB),
	.MemWrite_ID1_IB(MemWrite_ID1_IB),
	.MemRead_ID0_IB(MemRead_ID0_IB),
	.MemRead_ID1_IB(MemRead_ID1_IB),
	.Exit_ID0_IB(Exit_ID0_IB),
	.Exit_ID1_IB(Exit_ID1_IB),
	.ALUop_ID0_IB(ALUop_ID0_IB),
	.ALUop_ID1_IB(ALUop_ID1_IB),
	.Shared_Globalbar_ID0_IB(Shared_Globalbar_ID0_IB),
	.Shared_Globalbar_ID1_IB(Shared_Globalbar_ID1_IB),
	.Src1_Valid_ID0_IB(Src1_Valid_ID0_IB),
	.Src1_Valid_ID1_IB(Src1_Valid_ID1_IB),
	.Src2_Valid_ID0_IB(Src2_Valid_ID0_IB),
	.Src2_Valid_ID1_IB(Src2_Valid_ID1_IB),
	.Imme_Valid_ID0_IB(Imme_Valid_ID0_IB),
	.Imme_Valid_ID1_IB(Imme_Valid_ID1_IB),
	//To both SMIT & I-buffer
	.BEQ_ID0_IB_SIMT(BEQ_ID0_IB_SIMT),
	.BEQ_ID1_IB_SIMT(BEQ_ID1_IB_SIMT),
	.BLT_ID0_IB_SIMT(BLT_ID0_IB_SIMT),
	.BLT_ID1_IB_SIMT(BLT_ID1_IB_SIMT),
	.Valid_ID0_IB_SIMT(Valid_ID0_IB_SIMT),	//one-hot warpID
	.Valid_ID1_IB_SIMT(Valid_ID1_IB_SIMT)
);
endmodule