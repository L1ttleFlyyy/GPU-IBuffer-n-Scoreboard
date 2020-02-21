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


module ALU #(
    parameter DATA_WIDTH = 32,
    parameter NUM_THREADS = 8
    ) (
    // interface with OC
    input Valid_OC_ALU,
    input [2:0] WarpID_OC_ALU,
    input [31:0] Instr_OC_ALU,
    input [NUM_THREADS*DATA_WIDTH-1:0] Src1_Data_OC_ALU,
    input [NUM_THREADS*DATA_WIDTH-1:0] Src2_Data_OC_ALU,
    input [4:0] Dst_OC_ALU,
    input [15:0] Imme_OC_ALU,
    input Imme_Valid_OC_ALU,
    input RegWrite_OC_ALU,
    input [3:0] ALUop_OC_ALU,
    input BEQ_OC_ALU,
    input BLT_OC_ALU,
    input [1:0] ScbID_OC_ALU, // for BEQ and BLT only, to clear Scb entry

    // output to Fetch
    output [32*8-1:0] TargetAddr_ALU_PC_Flattened,

    // output to CDB
    output [31:0] Instr_ALU_CDB,
    output [2:0] WarpID_ALU_CDB, 
    output RegWrite_ALU_CDB,
    output [4:0] Dst_OC_ALU,
    output [NUM_THREADS*DATA_WIDTH-1:0] Dst_Data_ALU_CDB,
    
    // output to Scb (to clear Scb entry. Branch only, which do not go onto CDB)
    output Clear_Valid_ALU_Scb,
    output [2:0] Clear_WarpID_ALU_Scb,
    output [1:0] Clear_ScbID_ALU_Scb
    );
    
endmodule
