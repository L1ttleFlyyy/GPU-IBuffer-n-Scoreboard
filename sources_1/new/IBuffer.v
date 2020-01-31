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


module IBuffer_per_warp#(
    parameter NUM_ENTRIES = 4,
    parameter Instruction_Width = 49
    ) (
    input clk,
    input rst,
    input [Instruction_Width-1: 0] Instruction_ID1_IB,
    input [Instruction_Width-1: 0] Instruction_ID2_IB,
    input valid_ID1_IB,
    input valid_ID2_IB,
    input [7:0] mask_SIMT_IB,
    input drop_SIMT_IB,
    input issue_grant, // from Issue unit
    // TODO: AllocReq_IBuffer_AllocFSM/Finished_AllocFSM_IBuffer
    output req_IB_IU,
    output req_IB_IF,
    output [Instruction_Width-1: 0] Instruction_IB_OC
    );
endmodule
