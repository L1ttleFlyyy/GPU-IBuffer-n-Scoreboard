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
	input [7:0] ActiveMask_OC_ALU,
    input Valid_OC_ALU,
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
    
    // output to Scb (to clear Scb entry. Branch only, which do not go onto CDB)
    output Clear_Valid_ALU_Scb,
    output [2:0] Clear_WarpID_ALU_Scb,
    output [1:0] Clear_ScbID_ALU_Scb
    );
    
	wire [4:0] Shamt_OC_ALU; // shift amount of shift instructions
	assign ActiveMask_ALU_CDB = ActiveMask_OC_ALU;
	assign Shamt_OC_ALU = Imme_OC_ALU[11:7];
	assign Clear_ScbID_ALU_Scb = ScbID_OC_ALU;
	assign Clear_WarpID_ALU_Scb = WarpID_OC_ALU;
	assign WarpID_ALU_CDB = WarpID_OC_ALU;
	assign Instr_ALU_CDB = Instr_OC_ALU;
	assign Dst_ALU_CDB = Dst_OC_ALU;
	assign RegWrite_ALU_CDB = RegWrite_OC_ALU;
    assign Clear_Valid_ALU_Scb = Valid_OC_ALU & (BLT_OC_ALU | BEQ_OC_ALU);
	assign Br_ALU_SIMT = Valid_OC_ALU & (BLT_OC_ALU | BEQ_OC_ALU);
	assign WarpID_ALU_SIMT = WarpID_OC_ALU;
	
	genvar i;
	generate
		for (i = 0; i < 8; i = i + 1) begin : alu
			always@(*) begin
				Dst_Data_ALU_CDB[i*32+31:i*32] = 32'b0;
				BrOutcome_ALU_SIMT[i] = 1'b0;
				TargetAddr_ALU_PC_Flattened[i*32+31:i*32] = 32'b0;
				if (Valid_OC_ALU == 1) begin
					if (RegWrite_OC_ALU == 1) begin
						case (ALUop_OC_ALU)
							4'b0000: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_OC_ALU[i*32+31:i*32] + (Imme_Valid_OC_ALU ? 
											{{16{Imme_OC_ALU[15]}},Imme_OC_ALU[15:0]} : Src2_Data_OC_ALU[i*32+31:i*32]); //add & imme add
							4'b0001: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_OC_ALU[i*32+31:i*32] - Src2_Data_OC_ALU[i*32+31:i*32]; //sub
							4'b0010: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_OC_ALU[i+15:i] * Src2_Data_OC_ALU[i+15:i]; //mult
							4'b0011: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_OC_ALU[i*32+31:i*32] & (Imme_Valid_OC_ALU ? 
											{{16{Imme_OC_ALU[15]}},Imme_OC_ALU} : Src2_Data_OC_ALU[i*32+31:i*32]); //and & imme and
							4'b0100: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_OC_ALU[i*32+31:i*32] | (Imme_Valid_OC_ALU ? 
											{{16{Imme_OC_ALU[15]}},Imme_OC_ALU} : Src2_Data_OC_ALU[i*32+31:i*32]); //or & imme and
							4'b0101: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_OC_ALU[i*32+31:i*32] ^ (Imme_Valid_OC_ALU ? 
											{{16{Imme_OC_ALU[15]}},Imme_OC_ALU} : Src2_Data_OC_ALU[i*32+31:i*32]); //xor & imme xor
							4'b0110: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_OC_ALU[i*32+31:i*32] >>> Shamt_OC_ALU; //shr
							4'b0111: Dst_Data_ALU_CDB[i*32+31:i*32] = Src1_Data_OC_ALU[i*32+31:i*32] <<< Shamt_OC_ALU; //shl
							default: Dst_Data_ALU_CDB[i*32+31:i*32] = 32'b0;
						endcase
					end
					else if (BEQ_OC_ALU == 1) begin // beq
						TargetAddr_ALU_PC_Flattened[i*32+31:i*32] = {{16{1'b0}},Imme_OC_ALU};
						if (Src1_Data_OC_ALU[i*32+31:i*32] == Src2_Data_OC_ALU[i*32+31:i*32])
							BrOutcome_ALU_SIMT[i] = 1;
						else 
							BrOutcome_ALU_SIMT[i] = 0;
					end
					else if (BLT_OC_ALU == 1) begin // blt
						TargetAddr_ALU_PC_Flattened[i*32+31:i*32] = {{16{1'b0}},Imme_OC_ALU};
						if (Src1_Data_OC_ALU[i*32+31:i*32] < Src2_Data_OC_ALU[i*32+31:i*32])
							BrOutcome_ALU_SIMT[i] = 1;
						else 
							BrOutcome_ALU_SIMT[i] = 0;
					end
					
				end
			end
		end
	endgenerate
endmodule




