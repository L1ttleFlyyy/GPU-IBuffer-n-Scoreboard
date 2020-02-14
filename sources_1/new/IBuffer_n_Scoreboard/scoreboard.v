`timescale 1ns / 1ps
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
    input [1:0] clear_ScbID_ALU_Scb, // clear signal from ALU (branch only)
    input [1:0] clear_ScbID_CDB_Scb, // clear signal from CDB (for all regwrite)
    input [LOGNUM_WARPS-1:0] clear_warpID_ALU_Scb,
    input [LOGNUM_WARPS-1:0] clear_warpID_CDB_Scb,
    input clear_valid_ALU_Scb,
    input clear_valid_CDB_Scb,

    // warp specific signals
    // from IBuffer when depositing
    input [NUM_WARPS-1:0] RP_grt_IB_Scb,
    input [5*NUM_WARPS-1:0] src1_flattened_IB_Scb, // flattened RegID: 5 bit regID * 8 warps
    input [5*NUM_WARPS-1:0] src2_flattened_IB_Scb,
    input [5*NUM_WARPS-1:0] dst_flattened_IB_Scb,
    input [NUM_WARPS-1:0] src1_valid_IB_Scb,
    input [NUM_WARPS-1:0] src2_valid_IB_Scb,
    input [NUM_WARPS-1:0] dst_valid_IB_Scb,
    input [NUM_WARPS-1:0] replayable_IB_Scb,
    // from IBuffer when clearing
    input [2*NUM_WARPS-1:0] replay_complete_ScbID_flattened_IB_Scb,
    input [NUM_WARPS-1:0] replay_complete_IB_Scb,
    input [NUM_WARPS-1:0] replay_SW_LWbar_IB_Scb,
    // to IBuffer when issuing
    output [NUM_WARPS-1:0] full_Scb_IB,
    output [NUM_WARPS-1:0] empty_Scb_IB,
    output [NUM_WARPS-1:0] dependent_Scb_IB,
    output [2*NUM_WARPS-1:0] ScbID_flattened_Scb_IB
    );
    wire [4:0] src1_IB_Scb [0:NUM_WARPS-1];
    wire [4:0] src2_IB_Scb [0:NUM_WARPS-1];
    wire [4:0] dst_IB_Scb [0:NUM_WARPS-1];
    wire [1:0] ScbID_Scb_IB [0:NUM_WARPS-1];
    wire [1:0] replay_complete_ScbID_IB_Scb [0:NUM_WARPS-1];

    // demux for the common signals    
    reg [NUM_WARPS-1:0]clear_valid_ALU_Scb_array;
    reg [NUM_WARPS-1:0]clear_valid_CDB_Scb_array;
    always@(*) begin
        clear_valid_ALU_Scb_array = 0;
        clear_valid_ALU_Scb_array[clear_warpID_ALU_Scb] = clear_valid_ALU_Scb;
        clear_valid_CDB_Scb_array = 0;
        clear_valid_CDB_Scb_array[clear_warpID_CDB_Scb] = clear_valid_CDB_Scb;
    end

    // flatten and unflatten
    genvar i;
    generate
    for (i=0; i<NUM_WARPS; i=i+1) begin: scoreboard_loop
        assign src1_IB_Scb[i] = src1_flattened_IB_Scb[i*5+4:i*5];
        assign src2_IB_Scb[i] = src2_flattened_IB_Scb[i*5+4:i*5];
        assign dst_IB_Scb[i] = dst_flattened_IB_Scb[i*5+4:i*5];
        assign replay_complete_ScbID_IB_Scb[i] = replay_complete_ScbID_flattened_IB_Scb[2*i+1:2*i];
        assign ScbID_flattened_Scb_IB[2*i+1:2*i] = ScbID_Scb_IB[i];
        scoreboard_warp scb (
            .clk(clk),
            .rst(rst),
            // signal from IBuffer when depositing
            .src1(src1_IB_Scb[i]),
            .src2(src2_IB_Scb[i]),
            .dst(dst_IB_Scb[i]),
            .src1_valid(src1_valid_IB_Scb[i]),
            .src2_valid(src2_valid_IB_Scb[i]),
            .dst_valid(dst_valid_IB_Scb[i]),
            .RP_grt(RP_grt_IB_Scb[i]), // only create Scb entry for RP_grt (avoid duplicate entry for replay instructions)
            .replayable(replayable_IB_Scb[i]), // if it is LW, the Scb entry will be marked as "incomplete"
            // signal from IBuffer when clearing
            .replay_complete_ScbID(replay_complete_ScbID_IB_Scb[i]), // mark the Scb entry as complete
            .replay_complete(replay_complete_IB_Scb[i]),
            .replay_SW_LWbar(replay_SW_LWbar_IB_Scb[i]),
            // signal from other modules
            .clear_ScbID_Br(clear_ScbID_ALU_Scb), // common signals
            .clear_ScbID_regwr(clear_ScbID_CDB_Scb),
            .clear_valid_Br(clear_valid_ALU_Scb_array[i]), // after demux
            .clear_valid_regwr(clear_valid_CDB_Scb_array[i]),
            .full(full_Scb_IB[i]),
            .empty(empty_Scb_IB[i]),
            .dependent(dependent_Scb_IB[i]),
            .ScbID_Scb_IB(ScbID_Scb_IB[i]) // ScbID passed to Operand Collector (for future clearing)
        ); 
    end
    endgenerate
    
endmodule
