`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2020 08:53:50 AM
// Design Name: 
// Module Name: IBuffer
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


module IBuffer_warp#(
    parameter NUM_ENTRIES = 4,
    parameter NUM_THREADS = 8
    ) (
    input clk,
    input rst,

    // signals to/from IF stage
    input valid_IF_IB, // data statioinary method of control
    output req_IB_IF,

    // signals from ID stage (dual decoding unit)
    input valid_Q1_ID_IB,
    input [31:0]instr_Q1_ID_IB,
    input [5:0]src1_Q1_ID_IB, // 5-bit RegID with MSB as valid
    input [5:0]src2_Q1_ID_IB,
    input [5:0]dst_Q1_ID_IB,
    input [3:0]ALUop_Q1_ID_IB,
    input [15:0]imme_Q1_ID_IB,
    input regwrite_Q1_ID_IB,
    input memwrite_Q1_ID_IB,
    input memread_Q1_ID_IB,
    input shared_globalbar_Q1_ID_IB,
    input BEQ_Q1_ID_IB_SIMT,
    input BLT_Q1_ID_IB_SIMT,
    input exit_Q1_ID_IB,

    input valid_Q2_ID_IB,
    input [31:0]instr_Q2_ID_IB,
    input [5:0]src1_Q2_ID_IB, // 5-bit RegID with MSB as valid
    input [5:0]src2_Q2_ID_IB,
    input [5:0]dst_Q2_ID_IB,
    input [3:0]ALUop_Q2_ID_IB,
    input [15:0]imme_Q2_ID_IB,
    input regwrite_Q2_ID_IB,
    input memwrite_Q2_ID_IB,
    input memread_Q2_ID_IB,
    input shared_globalbar_Q2_ID_IB,
    input BEQ_Q2_ID_IB_SIMT,
    input BLT_Q2_ID_IB_SIMT,
    input exit_Q2_ID_IB,

    // signals from SIMT 
    input drop_SIMT_IB,
    input [NUM_THREADS-1: 0]mask_SIMT_IB,

    // signals to/from IU
    output req_IB_IU,
    input grt_IU_IB,

    // signal to/from Operand Collector
    output valid_IB_OC,
    output valid_IB_OC,
    output [31:0]instr_OC_OC,
    output [5:0]src1_IB_OC, // 5-bit RegID with MSB as valid
    output [5:0]src2_IB_OC,
    output [5:0]dst_IB_OC,
    output [15:0]imme_IB_OC,
    output [3:0]ALUop_IB_OC,
    output regwrite_IB_OC,
    output memwrite_IB_OC,
    output memread_IB_OC,
    output shared_globalbar_IB_OC,
    output BEQ_IB_OC_SIMT,
    output BLT_IB_OC_SIMT,
    output exit_IB_OC,

    // signal to RAU TODO: this pair of signal actually come from IU
    output exit_IB_RAU,
    output [LOGNUM_WARPS-1: 0]warpID_IB_RAU,
    input [Instruction_Width-1: 0] Instruction_ID1_IB,
    input [Instruction_Width-1: 0] Instruction_ID2_IB,
    input valid_ID1_IB,
    input valid_ID2_IB,
    input [7:0] mask_SIMT_IB,
    input drop_SIMT_IB,
    input issue_grant, // from Issue unit
    output req_IB_IU,
    output req_IB_IF,
    output [Instruction_Width-1: 0] Instruction_IB_OC
    );
endmodule
