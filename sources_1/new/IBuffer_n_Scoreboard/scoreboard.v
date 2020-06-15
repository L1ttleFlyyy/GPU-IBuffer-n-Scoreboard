`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2020 03:12:16 PM
// Design Name: 
// Module Name: scoreboard
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


module scoreboard#(
    parameter NUM_WARPS = 8,
    parameter LOGNUM_WARPS = $clog2(NUM_WARPS)
    ) (
    // common signals
    input clk,
    input rst,
    input [1:0] Clear_ScbID_ALU_Scb, // Clear signal from ALU
    input [LOGNUM_WARPS-1:0] Clear_WarpID_ALU_Scb,
    input Clear_Valid_ALU_Scb,

    // Warp specific signals
    // from IBuffer when depositing
    input [NUM_WARPS-1:0] RP_Grt_IB_Scb,
    input [5*NUM_WARPS-1:0] Src1_Flattened_IB_Scb, // Flattened RegID: 5 bit regID * 8 Warps
    input [5*NUM_WARPS-1:0] Src2_Flattened_IB_Scb,
    input [5*NUM_WARPS-1:0] Dst_Flattened_IB_Scb,
    input [NUM_WARPS-1:0] Src1_Valid_IB_Scb,
    input [NUM_WARPS-1:0] Src2_Valid_IB_Scb,
    input [NUM_WARPS-1:0] Dst_Valid_IB_Scb,
    // from IBuffer when Clearing
    input [2*NUM_WARPS-1:0] Replay_Complete_ScbID_Flattened_IB_Scb,
    input [NUM_WARPS-1:0] Replay_Complete_IB_Scb,
    // to IBuffer when issuing
    output [NUM_WARPS-1:0] Full_Scb_IB,
    output [NUM_WARPS-1:0] Empty_Scb_IB,
    output [NUM_WARPS-1:0] Dependent_Scb_IB,
    output [2*NUM_WARPS-1:0] ScbID_Flattened_Scb_IB
    );
    wire [4:0] Src1_IB_Scb [0:NUM_WARPS-1];
    wire [4:0] Src2_IB_Scb [0:NUM_WARPS-1];
    wire [4:0] Dst_IB_Scb [0:NUM_WARPS-1];
    wire [1:0] ScbID_Scb_IB [0:NUM_WARPS-1];
    wire [1:0] Replay_Complete_ScbID_IB_Scb [0:NUM_WARPS-1];

    // demux for the common signals    
    reg [NUM_WARPS-1:0]Clear_Valid_ALU_Scb_array;
    always@(*) begin
        Clear_Valid_ALU_Scb_array = 0;
        Clear_Valid_ALU_Scb_array[Clear_WarpID_ALU_Scb] = Clear_Valid_ALU_Scb;
    end

    // flatten and unflatten
    genvar i;
    generate
    for (i=0; i<NUM_WARPS; i=i+1) begin: scoreboard_loop
        assign Src1_IB_Scb[i] = Src1_Flattened_IB_Scb[i*5+4:i*5];
        assign Src2_IB_Scb[i] = Src2_Flattened_IB_Scb[i*5+4:i*5];
        assign Dst_IB_Scb[i] = Dst_Flattened_IB_Scb[i*5+4:i*5];
        assign Replay_Complete_ScbID_IB_Scb[i] = Replay_Complete_ScbID_Flattened_IB_Scb[2*i+1:2*i];
        assign ScbID_Flattened_Scb_IB[2*i+1:2*i] = ScbID_Scb_IB[i];
        scoreboard_warp scb (
            .clk(clk),
            .rst(rst),
            // signal from IBuffer when depositing
            .Src1(Src1_IB_Scb[i]),
            .Src2(Src2_IB_Scb[i]),
            .Dst(Dst_IB_Scb[i]),
            .Src1_Valid(Src1_Valid_IB_Scb[i]),
            .Src2_Valid(Src2_Valid_IB_Scb[i]),
            .Dst_Valid(Dst_Valid_IB_Scb[i]),
            .RP_Grt(RP_Grt_IB_Scb[i]), // only create Scb entry for RP_Grt (avoid duplicate entry for Replay instructions)
            // signal from IBuffer when Clearing
            .Replay_Complete_ScbID(Replay_Complete_ScbID_IB_Scb[i]), // mark the Scb entry as Complete
            .Replay_Complete(Replay_Complete_IB_Scb[i]),
            // signal from other modules
            .Clear_ScbID_ALU(Clear_ScbID_ALU_Scb), // common signals
            .Clear_Valid_ALU(Clear_Valid_ALU_Scb_array[i]), // after demux
            .Full(Full_Scb_IB[i]),
            .Empty(Empty_Scb_IB[i]),
            .Dependent(Dependent_Scb_IB[i]),
            .ScbID_Scb_IB(ScbID_Scb_IB[i]) // ScbID passed to Operand Collector (for future Clearing)
        ); 
    end
    endgenerate
    
endmodule
