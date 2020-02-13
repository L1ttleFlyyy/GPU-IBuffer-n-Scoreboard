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


module scoreboard_warp(
    input clk,
    input rst,
    // signal from IBuffer when issuing
    input [4:0] src1, // RegID is 5-bit (R8: thrID, R16: warpID)
    input [4:0] src2,
    input [4:0] dst,
    input src1_valid,
    input src2_valid,
    input dst_valid,
    input RP_grt, // only create Scb entry for RP_grt (avoid duplicate entry for replay instructions)
    input replayable, // if it is LW/SW, the Scb entry will be marked as "incomplete"
    //signal for clearing
    input [1:0] replay_complete_ScbID, // mark the Scb entry as complete
    input replay_complete,
    input replay_SW_LWbar, // distinguish between SW/LW
    // signal from other modules
    input [1:0] clear_ScbID_Br, // clear signal from ALU (for branch only)
    input [1:0] clear_ScbID_regwr, // clear signal from CDB (for all regwrite)
    input clear_valid_Br,
    input clear_valid_regwr,
    output full,
    output empty, // for exit
    output dependent,
    output [1:0] ScbID_Scb_IB // ScbID passed to IBuffer (for future clearing)
    );
    reg [4:0] src1_array [3:0];
    reg [4:0] src2_array [3:0];
    reg [4:0] dst_array [3:0];
    reg [3:0] src1_valid_array;
    reg [3:0] src2_valid_array;
    reg [3:0] dst_valid_array;
    reg [3:0] valid_array;
    reg [3:0] replay_complete_array;

    // valid array after Scb entries cleared by Mem/ALU/CDB
    reg [3:0] valid_array_cleared;
    always@(*) begin
        valid_array_cleared = valid_array;
        if (replay_complete & replay_SW_LWbar) // from IBuffer for SW
            valid_array_cleared[replay_complete_ScbID] = 0;
        if (clear_valid_regwr & replay_complete_array[clear_ScbID_regwr]) // from CDB
            valid_array_cleared[clear_ScbID_regwr] = 0; // clear only when finished (in case of LW)
        if (clear_valid_Br) // from ALU for branch
            valid_array_cleared[clear_ScbID_Br] = 0;
    end
    assign full = &valid_array_cleared;

    // find empty slot for a new instruction
    wire [3:0] empty_array = ~valid_array_cleared;
    assign empty = &empty_array;
    reg [1:0] next_empty;
    integer i;
    always@(*) begin
        next_empty = 0;
        for (i=3; i>=0; i=i-1) begin: empty_loop
            if(empty_array[i])
                next_empty = i;
        end
    end
    assign ScbID_Scb_IB = next_empty;

    // store a new instruction if granted by Issue unit
    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            valid_array <= 0;
        end else begin
            valid_array <= valid_array_cleared;
            if (RP_grt)
                valid_array[next_empty] <= 1'b1;      
        end
    end

    always@(posedge clk) begin
        if (RP_grt) begin
            src1_array[next_empty] <= src1;
            src2_array[next_empty] <= src2;
            dst_array[next_empty] <= dst;
            src1_valid_array[next_empty] <= src1_valid;
            src2_valid_array[next_empty] <= src2_valid;
            dst_valid_array[next_empty] <= dst_valid;
            if (replayable) 
                replay_complete_array[next_empty] <= 1'b0;
            else
                replay_complete_array[next_empty] <= 1'b1;
        end
        if (replay_complete) begin
            replay_complete_array[replay_complete_ScbID] <= 1'b1;
        end
    end

    // check all possible data hazards
    reg [3: 0] dependent_array;
    always@(*) begin
        // for each of the pending instructions, check RAW, WAW, WAR
        for (i = 0; i < 4; i = i+1) begin: dependent_loop
            // RAW:
            dependent_array[i] = 
                (src1_valid && src1_valid_array[i] && (src1 == dst_array[i])) | 
                (src2_valid && src2_valid_array[i] && (src2 == dst_array[i]));
            // WAW:
            dependent_array[i] = dependent_array[i] |
                (dst_valid && dst_valid_array[i] && (dst == dst_array[i]));
            // WAR:
            dependent_array[i] = dependent_array[i] |
                (dst_valid && src1_valid_array[i] && (dst == src1_array[i])) |
                (dst_valid && src2_valid_array[i] && (dst == src2_array[i])); 
        end
        dependent_array = dependent_array & valid_array_cleared; // Note here use valid_cleared to save one clock
    end
    // overall dependent bit:
    assign dependent = |dependent_array;

endmodule // scoreboard_inner

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
    reg [NUM_WARPS-1:0]clear_valid_ALU_Scb_array;
    reg [NUM_WARPS-1:0]clear_valid_CDB_Scb_array;

    // demux for the common signals
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
