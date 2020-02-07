`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2020 08:53:50 AM
// Design Name: 
// Module Name: top_SIMT_IB_Scb_IU
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


module top_SIMT_IB_Scb_IU#(
    parameter NUM_WARPS = 8,
    parameter LOGNUM_WARPS = 3,
    parameter NUM_THREADS = 8
    ) (
    input clk,
    input rst,

    /*** begin: signals for SIMT stack ***/

    // interface with Task Manager
    input [7:0] Update_TM_SIMT,
    input [7:0] AM_TM_SIMT,

    // interface with Fetch // FIXME: TA_Warp_SIMT_IF also seems to be a 2-D I/O signal 
    output [7:0]UpdatePC_Qual1_SIMT_IF, // TODO: to Tridash: [7:0] or scalar?
    output [7:0]UpdatePC_Qual2_SIMT_IF,
    // Moved to Decode stage--> output [7:0] UpdatePC_Qual3,
    output [7:0]Stall_SIMT_IF,
    output reg [9:0] TA_Warp_SIMT_IF,   // Target Address from SIMT per warp

    // interface with Instruction Decode
    input DotS_Q1_ID_SIMT,
    input CondBr_Q1_ID_SIMT,
    input Call_Q1_ID_SIMT,
    input Ret_Q1_ID_SIMT,
    input Jump_Q1_ID_SIMT,
    input [9:0] PCplus4_Q1_ID_SIMT,
    
    input DotS_Q2_ID_SIMT,
    input CondBr_Q2_ID_SIMT,
    input Call_Q2_ID_SIMT,
    input Ret_Q2_ID_SIMT,
    input Jump_Q2_ID_SIMT,
    input [9:0] PCplus4_Q2_ID_SIMT,

    // interface with EX
    input CondBr_EX_SIMT,
    input [LOGNUM_WARPS-1: 0]WarpID_EX_SIMT,
    input [7:0] CondOutcome_EX_SIMT,
    /*** end: signals for SIMT stack ***/

    /*** begin: signals for I-Buffer ***/
    // IF to/from IB
    input [NUM_WARPS-1: 0]valid_IF_IB, // data statioinary method of control
    output [NUM_WARPS-1: 0]req_IB_IF,

    // ID stage (dual decoding unit) to IB 
    input [NUM_WARPS-1: 0]valid_Q1_ID_IB,
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

    input [NUM_WARPS-1: 0]valid_Q2_ID_IB,
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


    // Operand Collector to/from I-Buffer
    input full_OC_IB,
    output [LOGNUM_WARPS-1: 0]warpID_IB_OC,
    output valid_IB_OC,
    output [31:0]instr_IB_OC,
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

    // IB to RAU
    output exit_IB_RAU,
    output [LOGNUM_WARPS-1: 0]warpID_IB_RAU,
    
    // MEM to IB
    input Valid_Zerofb_MEM_IB,
    input [LOGNUM_WARPS-1: 0]WarpID_Zerofb_MEM_IB,
    input [NUM_THREADS-1: 0]Zerofb_MEM_IB,
    
    input Valid_Posfb_MEM_IB,
    input [LOGNUM_WARPS-1: 0]WarpID_Posfb_MEM_IB,
    input [NUM_THREADS-1: 0]Posfb_MEM_IB,
    /*** end: signals for I-Buffer ***/

    /*** begin: signals for Scoreboard ***/
    input Valid_MEM_Scb,
    input [1:0] ScbID_MEM_Scb,
    input [LOGNUM_WARPS-1: 0]WarpID_MEM_Scb,
    input Valid_ALU_Scb,
    input [1:0] ScbID_ALU_Scb,
    input [LOGNUM_WARPS-1: 0]WarpID_ALU_Scb,
    input Valid_CDB_Scb,
    input [1:0] Scb_CDB_Scb,
    input [LOGNUM_WARPS-1: 0]WarpID_CDB_Scb,
    output [LOGNUM_WARPS-1: 0]ScbID_Scb_OC
    /*** end: signals for Scoreboard ***/

    );
    
    // signals between IB & SIMT
    wire [NUM_WARPS-1: 0] DropInstr_SIMT_IB;
    wire [NUM_THREADS-1: 0] ActiveMask_SIMT_IB[0:NUM_WARPS];

    // signals between IB & IU
    wire [NUM_WARPS-1: 0]req_IB_IU;
    wire [NUM_WARPS-1: 0]grt_IU_IB;

    // signals between IB & Scb
    wire [4:0]src1[0:NUM_WARPS-1];
    wire [4:0]src2[0:NUM_WARPS-1];
    wire [4:0]dst[0:NUM_WARPS-1];
    wire [NUM_WARPS-1: 0] src1_valid, src2_valid, dst_valid;
    wire [NUM_WARPS-1: 0] Scb_full, Scb_dependent;


endmodule
