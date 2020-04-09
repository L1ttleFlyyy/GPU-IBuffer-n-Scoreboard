`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2019 08:55:38 PM
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU (
    // interface with OC
	input clk,
	input rst,
    input Valid_OC_ALU,
	input [7:0] ActiveMask_OC_ALU,
    input [2:0] WarpID_OC_ALU,
    input [31:0] Instr_OC_ALU,
    input [32*8-1:0] Src1_Data_OC_ALU,
    input [32*8-1:0] Src2_Data_OC_ALU,
    input [4:0] Dst_OC_ALU,
    input [15:0] Imme_OC_ALU,
    input Imme_Valid_OC_ALU,
    input RegWrite_OC_ALU,
    input [3:0] ALUop_OC_ALU,
    input BEQ_OC_ALU,
    input BLT_OC_ALU,
    input [1:0] ScbID_OC_ALU, // for BEQ and BLT only, to clear Scb entry

    // output to Fetch
    output reg [32*8-1:0] TargetAddr_ALU_PC_Flattened,
	
	// output to SIMT 
	output Br_ALU_SIMT,
	output reg [7:0] BrOutcome_ALU_SIMT,
	output [2:0] WarpID_ALU_SIMT,

    // output to CDB
	output [7:0] ActiveMask_ALU_CDB,
    output [31:0] Instr_ALU_CDB,
    output [2:0] WarpID_ALU_CDB, 
    output RegWrite_ALU_CDB,
    output [4:0] Dst_ALU_CDB,
    output reg [8*32-1:0] Dst_Data_ALU_CDB,
    output [1:0] Clear_ScbID_ALU_CDB,

    
    // output to Scb (to clear Scb entry. Branch only, which do not go onto CDB)
    output Clear_Valid_ALU_Scb,
    output [2:0] Clear_WarpID_ALU_Scb,
    output [1:0] Clear_ScbID_ALU_Scb
    );
	// input registers
    reg Valid_reg;
	reg [7:0] ActiveMask_reg;
    reg [2:0] WarpID_reg;
    reg [31:0] Instr_reg;
    reg [32*8-1:0] Src1_Data_reg;
    reg [32*8-1:0] Src2_Data_reg;
    reg [4:0] Dst_reg;
    reg [15:0] Imme_reg;
    reg Imme_Valid_reg;
    reg RegWrite_reg;
    reg [3:0] ALUop_reg;
    reg BEQ_reg;
    reg BLT_reg;
    reg [1:0] ScbID_reg; // for BEQ and BLT only, to clear Scb entry

	always@(posedge clk, negedge rst) begin
		if (!rst) begin
			Valid_reg <= 0;
			ActiveMask_reg <= {8{1'bx}};
			WarpID_reg <= {3{1'bx}};
			Instr_reg <= {32{1'bx}};
			Src1_Data_reg <= {256{1'bx}};
			Src2_Data_reg <= {256{1'bx}};
			Dst_reg <= {5{1'bx}};
			Imme_reg <= {16{1'bx}};
			Imme_Valid_reg <= 1'bx;
			RegWrite_reg <= 1'bx;
			ALUop_reg <= {4{1'bx}};
			BEQ_reg <= 1'bx;
			BLT_reg <= 1'bx;
			ScbID_reg <= {2{1'bx}};
		end else begin
			Valid_reg <= Valid_OC_ALU;
			ActiveMask_reg <= ActiveMask_OC_ALU;
			WarpID_reg <= WarpID_OC_ALU;
			Instr_reg <= Instr_OC_ALU;
			Src1_Data_reg <= Src1_Data_OC_ALU;
			Src2_Data_reg <= Src2_Data_OC_ALU;
			Dst_reg <= Dst_OC_ALU;
			Imme_reg <= Imme_OC_ALU;
			Imme_Valid_reg <= Imme_Valid_OC_ALU;
			RegWrite_reg <= RegWrite_OC_ALU;
			ALUop_reg <= ALUop_OC_ALU;
			BEQ_reg <= BEQ_OC_ALU;
			BLT_reg <= BLT_OC_ALU;
			ScbID_reg <= ScbID_OC_ALU;
		end
	end
    
	wire [4:0] Shamt_reg; // shift amount of shift instructions
	assign ActiveMask_ALU_CDB = ActiveMask_reg;
	assign Shamt_reg = Imme_reg[11:7];
	assign Clear_ScbID_ALU_Scb = ScbID_reg;
	assign Clear_ScbID_ALU_CDB = ScbID_reg;
	assign Clear_WarpID_ALU_Scb = WarpID_reg;
	assign WarpID_ALU_CDB = WarpID_reg;
	assign Instr_ALU_CDB = Instr_reg;
	assign Dst_ALU_CDB = Dst_reg;
	assign RegWrite_ALU_CDB = RegWrite_reg;
    assign Clear_Valid_ALU_Scb = Valid_reg & (BLT_reg | BEQ_reg);
	assign Br_ALU_SIMT = Valid_reg & (BLT_reg | BEQ_reg);
	assign WarpID_ALU_SIMT = WarpID_reg;
	
	genvar i;
	generate
		for (i = 0; i < 8; i = i + 1) begin : alu
			always@(*) begin
				Dst_Data_ALU_CDB[i*32+31:i*32] = 32'b0;
				BrOutcome_ALU_SIMT[i] = 1'b0;
				TargetAddr_ALU_PC_Flattened[i*32+31:i*32] = 32'b0;
				if (Valid_reg == 1) begin
					if (RegWrite_reg == 1) begin
						case (ALUop_reg)
							4'b0000: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_reg[i*32+31:i*32] + (Imme_Valid_reg ? 
											{{16{Imme_reg[15]}},Imme_reg[15:0]} : Src2_Data_reg[i*32+31:i*32]); //add & imme add
							4'b0001: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_reg[i*32+31:i*32] - Src2_Data_reg[i*32+31:i*32]; //sub
							4'b0010: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_reg[i+15:i] * Src2_Data_reg[i+15:i]; //mult
							4'b0011: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_reg[i*32+31:i*32] & (Imme_Valid_reg ? 
											{{16{Imme_reg[15]}},Imme_reg} : Src2_Data_reg[i*32+31:i*32]); //and & imme and
							4'b0100: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_reg[i*32+31:i*32] | (Imme_Valid_reg ? 
											{{16{Imme_reg[15]}},Imme_reg} : Src2_Data_reg[i*32+31:i*32]); //or & imme and
							4'b0101: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_reg[i*32+31:i*32] ^ (Imme_Valid_reg ? 
											{{16{Imme_reg[15]}},Imme_reg} : Src2_Data_reg[i*32+31:i*32]); //xor & imme xor
							4'b0110: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_reg[i*32+31:i*32] >>> Shamt_reg; //shr
							4'b0111: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_reg[i*32+31:i*32] <<< Shamt_reg; //shl
							default: Dst_Data_ALU_CDB[i*32+31:i*32] = 32'b0;
						endcase
					end
					else if (BEQ_reg == 1) begin // beq
						TargetAddr_ALU_PC_Flattened[i*32+31:i*32] = {{16{1'b0}},Imme_reg};
						if (Src1_Data_reg[i*32+31:i*32] == Src2_Data_reg[i*32+31:i*32])
							BrOutcome_ALU_SIMT[i] = 1;
						else 
							BrOutcome_ALU_SIMT[i] = 0;
					end
					else if (BLT_reg == 1) begin // blt
						TargetAddr_ALU_PC_Flattened[i*32+31:i*32] = {{16{1'b0}},Imme_reg};
						if (Src1_Data_reg[i*32+31:i*32] < Src2_Data_reg[i*32+31:i*32])
							BrOutcome_ALU_SIMT[i] = 1;
						else 
							BrOutcome_ALU_SIMT[i] = 0;
					end
					
				end
			end
		end
	endgenerate
endmodule




