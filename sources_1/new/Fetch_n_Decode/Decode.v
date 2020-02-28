`timescale 1ns / 1ps

module Decode (
	//From IF 
	input [31:0] PCplus4_IF_ID0,
	input [31:0] PCplus4_IF_ID1,
	input [31:0] Instr_in_IF_ID0,
	input [31:0] Instr_in_IF_ID1,
	input [7:0] Valid_2_IF_ID0,
	input [7:0] Valid_2_IF_ID1,
	input [7:0] Valid_3_IF_ID0,
	input [7:0] Valid_3_IF_ID1,

	//To PC
	output [7:0] Valid_3_ID0_PC,
	output [7:0] Valid_3_ID1_PC,
	output [7:0] UpdatePC_Qual3_ID0_PC,
	output [7:0] UpdatePC_Qual3_ID1_PC,
	output [31:0] TargetAddr_ID0_PC,
	output [31:0] TargetAddr_ID1_PC,
	//To SMIT
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
	output [31:0] Inst_ID0_IB,
	output [31:0] Inst_ID1_IB,
	output [7:0] Valid_2_ID0_IB, // Data-stationary method of control
	output [7:0] Valid_2_ID1_IB, // Data-stationary method of control
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
	output reg [3:0] ALUop_ID0_IB,
	output reg [3:0] ALUop_ID1_IB,
	output Shared_Globalbar_ID0_IB,
	output Shared_Globalbar_ID1_IB,
	output Src1_Valid_ID0_IB,
	output Src1_Valid_ID1_IB,
	output Src2_Valid_ID0_IB,
	output Src2_Valid_ID1_IB,
	output Imme_Valid_ID0_IB,
	output Imme_Valid_ID1_IB,
	//To both SMIT & I-buffer
	output BEQ_ID0_IB_SIMT,
	output BEQ_ID1_IB_SIMT,
	output BLT_ID0_IB_SIMT,
	output BLT_ID1_IB_SIMT,
	output [7:0] Valid_ID0_IB_SIMT,	//one-hot warpID
	output [7:0] Valid_ID1_IB_SIMT
);

wire [5:0] opcode_ID0 = Instr_in_IF_ID0[31:26];
wire [4:0] rs_ID0 = Instr_in_IF_ID0[25:21];
wire [4:0] rt_ID0 = Instr_in_IF_ID0[20:16];
wire [4:0] rd_ID0 = Instr_in_IF_ID0[15:11];
wire [4:0] shamt_ID0 = Instr_in_IF_ID0[10:6];
wire [5:0] funct_ID0 = Instr_in_IF_ID0[5:0];
wire [15:0] imme_ID0 = Instr_in_IF_ID0[15:0];
wire [25:0] tar_addr_ID0 = Instr_in_IF_ID0[25:0];

wire [5:0] opcode_ID1 = Instr_in_IF_ID1[31:26];
wire [4:0] rs_ID1 = Instr_in_IF_ID1[25:21];
wire [4:0] rt_ID1 = Instr_in_IF_ID1[20:16];
wire [4:0] rd_ID1 = Instr_in_IF_ID1[15:11];
wire [4:0] shamt_ID1 = Instr_in_IF_ID1[10:6];
wire [5:0] funct_ID1 = Instr_in_IF_ID1[5:0];
wire [15:0] imme_ID1 = Instr_in_IF_ID1[15:0];
wire [25:0] tar_addr_ID1 = Instr_in_IF_ID1[25:0];

//To PC
assign Valid_3_ID0_PC = Valid_3_IF_ID0;
assign Valid_3_ID1_PC = Valid_3_IF_ID1;
//Qual_3
genvar i;
generate
	for (i = 0; i < 8; i = i+1) begin: g1
		assign UpdatePC_Qual3_ID0_PC[i] = (Call_ID0_SIMT || Jmp_ID0_SIMT) && Valid_3_IF_ID0[i];
		assign UpdatePC_Qual3_ID1_PC[i] = (Call_ID1_SIMT || Jmp_ID1_SIMT) && Valid_3_IF_ID1[i];
	end
endgenerate
assign TargetAddr_ID0_PC = {6'b0, tar_addr_ID0};
assign TargetAddr_ID1_PC = {6'b0, tar_addr_ID1};

//To SMIT
assign PCplus4_ID0_SIMT = PCplus4_IF_ID0;
assign PCplus4_ID1_SIMT = PCplus4_IF_ID1;
assign DotS_ID0_SIMT = opcode_ID0[5];	//.S
assign DotS_ID1_SIMT = opcode_ID1[5];
assign Call_ID0_SIMT = (opcode_ID0 == 6'b000011);	//CALL
assign Call_ID1_SIMT = (opcode_ID1 == 6'b000011);
assign Ret_ID0_SIMT = (opcode_ID0 == 6'b000110);	//RET
assign Ret_ID1_SIMT = (opcode_ID1 == 6'b000110);
assign Jmp_ID0_SIMT = (opcode_ID0 == 6'b000010 || opcode_ID0 == 6'b010010);	//J
assign Jmp_ID1_SIMT = (opcode_ID1 == 6'b000010 || opcode_ID1 == 6'b010010);

//To I-buffer
assign Inst_ID0_IB = Instr_in_IF_ID0;
assign Inst_ID1_IB = Instr_in_IF_ID1;
assign Valid_2_ID0_IB = Valid_2_IF_ID0;
assign Valid_2_ID1_IB = Valid_2_IF_ID1;
assign Src1_ID0_IB = rs_ID0;
assign Src1_ID1_IB = rs_ID1;
assign Src2_ID0_IB = rt_ID0;
assign Src2_ID1_IB = rt_ID1;
assign Dst_ID0_IB = rd_ID0;
assign Dst_ID1_IB = rd_ID1;
assign Imme_ID0_IB = imme_ID0; 
assign Imme_ID1_IB = imme_ID1; 
assign RegWrite_ID0_IB = (opcode_ID0 == 6'b000000 || opcode_ID0 == 6'b010000 	//Integer Instr
						|| opcode_ID0 == 6'b001000 || opcode_ID0 == 6'b011000 	//ADDI
						|| opcode_ID0 == 6'b001100 || opcode_ID0 == 6'b011100 	//ANDI
						|| opcode_ID0 == 6'b001101 || opcode_ID0 == 6'b011101 	//ORI
						|| opcode_ID0 == 6'b001110 || opcode_ID0 == 6'b011110 	//XORI
						|| opcode_ID0 == 6'b100011 || opcode_ID0 == 6'b110011 	//LD
						|| opcode_ID0 == 6'b100111 || opcode_ID0 == 6'b110111 	//LDS
						);
assign RegWrite_ID1_IB = (opcode_ID1 == 6'b000000 || opcode_ID1 == 6'b010000 	//Integer Instr
						|| opcode_ID1 == 6'b001000 || opcode_ID1 == 6'b011000 	//ADDI
						|| opcode_ID1 == 6'b001100 || opcode_ID1 == 6'b011100 	//ANDI
						|| opcode_ID1 == 6'b001101 || opcode_ID1 == 6'b011101 	//ORI
						|| opcode_ID1 == 6'b001110 || opcode_ID1 == 6'b011110 	//XORI
						|| opcode_ID1 == 6'b100011 || opcode_ID1 == 6'b110011 	//LD
						|| opcode_ID1 == 6'b100111 || opcode_ID1 == 6'b110111 	//LDS
						);
assign MemWrite_ID0_IB = (opcode_ID0 == 6'b101011 || opcode_ID0 == 6'b111011 	//SW
						|| opcode_ID0 == 6'b101111 || opcode_ID0 == 6'b111111 	//SWS
						);
assign MemWrite_ID1_IB = (opcode_ID1 == 6'b101011 || opcode_ID1 == 6'b111011 	//SW
						|| opcode_ID1 == 6'b101111 || opcode_ID1 == 6'b111111 	//SWS
						);
assign MemRead_ID0_IB = (opcode_ID0 == 6'b100011 || opcode_ID0 == 6'b110011 	//LD
						|| opcode_ID0 == 6'b100111 || opcode_ID0 == 6'b110111 	//LDS
						);
assign MemRead_ID1_IB = (opcode_ID1 == 6'b100011 || opcode_ID1 == 6'b110011 	//LD
						|| opcode_ID1 == 6'b100111 || opcode_ID1 == 6'b110111 	//LDS
						);
assign Exit_ID0_IB = (opcode_ID0 == 6'b100001);	//EXIT
assign Exit_ID1_IB = (opcode_ID1 == 6'b100001);	//EXIT
//Only R-tpye
always @(*) begin
	case (funct_ID0)
		6'b100000 : ALUop_ID0_IB = 4'b0000;	//ADD
		6'b100010 : ALUop_ID0_IB = 4'b0001;	//SUB
		6'b011000 : ALUop_ID0_IB = 4'b0010;	//MUL
		6'b100100 : ALUop_ID0_IB = 4'b0011;	//AND
		6'b100101 : ALUop_ID0_IB = 4'b0100;	//OR
		6'b100110 : ALUop_ID0_IB = 4'b0101;	//XOR
		6'b000010 : ALUop_ID0_IB = 4'b0110;	//SHR
		6'b000000 : ALUop_ID0_IB = 4'b0111;	//SHL
		default:  ALUop_ID0_IB = 4'bxxxx;
	endcase
end
always @(*) begin
	case (funct_ID0)
		6'b100000 : ALUop_ID1_IB = 4'b0000;	//ADD
		6'b100010 : ALUop_ID1_IB = 4'b0001;	//SUB
		6'b011000 : ALUop_ID1_IB = 4'b0010;	//MUL
		6'b100100 : ALUop_ID1_IB = 4'b0011;	//AND
		6'b100101 : ALUop_ID1_IB = 4'b0100;	//OR
		6'b100110 : ALUop_ID1_IB = 4'b0101;	//XOR
		6'b000010 : ALUop_ID1_IB = 4'b0110;	//SHR
		6'b000000 : ALUop_ID1_IB = 4'b0111;	//SHL
		default:  ALUop_ID1_IB = 4'bxxxx;
	endcase
end
assign Shared_Globalbar_ID0_IB = (opcode_ID0 == 6'b101111 || opcode_ID0 == 6'b111111 	//SWS
								|| opcode_ID0 == 6'b100111 || opcode_ID0 == 6'b110111 	//LDS	
								);
assign Shared_Globalbar_ID1_IB = (opcode_ID1 == 6'b101111 || opcode_ID1 == 6'b111111 	//SWS
								|| opcode_ID1 == 6'b100111 || opcode_ID1 == 6'b110111 	//LDS	
								);
assign Src1_Valid_ID0_IB = (opcode_ID0 == 6'b000000 || opcode_ID0 == 6'b010000		//Integer Instr
							|| opcode_ID0 == 6'b001000 || opcode_ID0 == 6'b011000 	//ADDI
							|| opcode_ID0 == 6'b001100 || opcode_ID0 == 6'b011100 	//ANDI
							|| opcode_ID0 == 6'b001101 || opcode_ID0 == 6'b011101 	//ORI
							|| opcode_ID0 == 6'b001110 || opcode_ID0 == 6'b011110 	//XORI
							|| opcode_ID0 == 6'b100011 || opcode_ID0 == 6'b110011 	//LD
							|| opcode_ID0 == 6'b100111 || opcode_ID0 == 6'b110111 	//LDS
							|| opcode_ID0 == 6'b101011 || opcode_ID0 == 6'b111011 	//SW
							|| opcode_ID0 == 6'b101111 || opcode_ID0 == 6'b111111 	//SWS
							|| opcode_ID0 == 6'b000100 || opcode_ID0 == 6'b010100	//BEQ
							|| opcode_ID0 == 6'b000111 || opcode_ID0 == 6'b010111	//BLT
							);
assign Src1_Valid_ID1_IB = (opcode_ID1 == 6'b000000 || opcode_ID1 == 6'b010000 		//Integer Instr
							|| opcode_ID1 == 6'b001000 || opcode_ID1 == 6'b011000 	//ADDI
							|| opcode_ID1 == 6'b001100 || opcode_ID1 == 6'b011100 	//ANDI
							|| opcode_ID1 == 6'b001101 || opcode_ID1 == 6'b011101 	//ORI
							|| opcode_ID1 == 6'b001110 || opcode_ID1 == 6'b011110 	//XORI
							|| opcode_ID1 == 6'b100011 || opcode_ID1 == 6'b110011 	//LD
							|| opcode_ID1 == 6'b100111 || opcode_ID1 == 6'b110111 	//LDS
							|| opcode_ID1 == 6'b101011 || opcode_ID1 == 6'b111011 	//SW
							|| opcode_ID1 == 6'b101111 || opcode_ID1 == 6'b111111 	//SWS
							|| opcode_ID1 == 6'b000100 || opcode_ID1 == 6'b010100	//BEQ
							|| opcode_ID1 == 6'b000111 || opcode_ID1 == 6'b010111	//BLT
							);
assign Src2_Valid_ID0_IB = (opcode_ID0 == 6'b000000 || opcode_ID0 == 6'b010000 		//Integer Instr
							|| opcode_ID0 == 6'b001000 || opcode_ID0 == 6'b011000 	//ADDI
							|| opcode_ID0 == 6'b001100 || opcode_ID0 == 6'b011100 	//ANDI
							|| opcode_ID0 == 6'b001101 || opcode_ID0 == 6'b011101 	//ORI
							|| opcode_ID0 == 6'b001110 || opcode_ID0 == 6'b011110 	//XORI
							|| opcode_ID0 == 6'b100011 || opcode_ID0 == 6'b110011 	//LD
							|| opcode_ID0 == 6'b100111 || opcode_ID0 == 6'b110111 	//LDS
							|| opcode_ID0 == 6'b101011 || opcode_ID0 == 6'b111011 	//SW
							|| opcode_ID0 == 6'b101111 || opcode_ID0 == 6'b111111 	//SWS
							|| opcode_ID0 == 6'b000100 || opcode_ID0 == 6'b010100	//BEQ
							|| opcode_ID0 == 6'b000111 || opcode_ID0 == 6'b010111	//BLT
								);
assign Src2_Valid_ID1_IB = (opcode_ID1 == 6'b000000 || opcode_ID1 == 6'b010000 		//Integer Instr
							|| opcode_ID1 == 6'b001000 || opcode_ID1 == 6'b011000 	//ADDI
							|| opcode_ID1 == 6'b001100 || opcode_ID1 == 6'b011100 	//ANDI
							|| opcode_ID1 == 6'b001101 || opcode_ID1 == 6'b011101 	//ORI
							|| opcode_ID1 == 6'b001110 || opcode_ID1 == 6'b011110 	//XORI
							|| opcode_ID1 == 6'b100011 || opcode_ID1 == 6'b110011 	//LD
							|| opcode_ID1 == 6'b100111 || opcode_ID1 == 6'b110111 	//LDS
							|| opcode_ID1 == 6'b101011 || opcode_ID1 == 6'b111011 	//SW
							|| opcode_ID1 == 6'b101111 || opcode_ID1 == 6'b111111 	//SWS
							|| opcode_ID1 == 6'b000100 || opcode_ID1 == 6'b010100	//BEQ
							|| opcode_ID1 == 6'b000111 || opcode_ID1 == 6'b010111	//BLT
							);
assign Imme_Valid_ID0_IB = (opcode_ID0 == 6'b001000 || opcode_ID0 == 6'b011000		//ADDI
							|| opcode_ID0 == 6'b001100 || opcode_ID0 == 6'b011100 	//ANDI
							|| opcode_ID0 == 6'b001101 || opcode_ID0 == 6'b011101 	//ORI
							|| opcode_ID0 == 6'b001110 || opcode_ID0 == 6'b011110 	//XORI
							);
assign Imme_Valid_ID1_IB = (opcode_ID1 == 6'b001000 || opcode_ID1 == 6'b011000 		//ADDI
							|| opcode_ID1 == 6'b001100 || opcode_ID1 == 6'b011100 	//ANDI
							|| opcode_ID1 == 6'b001101 || opcode_ID1 == 6'b011101 	//ORI
							|| opcode_ID1 == 6'b001110 || opcode_ID1 == 6'b011110 	//XORI
							);

//To both SMIT & I-buffer
assign BEQ_ID0_IB_SIMT = (opcode_ID0 == 6'b000100 || opcode_ID0 == 6'b010100);	//BEQ
assign BEQ_ID1_IB_SIMT = (opcode_ID1 == 6'b000100 || opcode_ID1 == 6'b010100);	//BEQ
assign BLT_ID0_IB_SIMT = (opcode_ID0 == 6'b000111 || opcode_ID0 == 6'b010111);	//BLT
assign BLT_ID1_IB_SIMT = (opcode_ID1 == 6'b000111 || opcode_ID1 == 6'b010111);	//BLT
assign Valid_ID0_IB_SIMT = Valid_3_IF_ID0;	//one-hot warpID
assign Valid_ID1_IB_SIMT = Valid_3_IF_ID1;

endmodule