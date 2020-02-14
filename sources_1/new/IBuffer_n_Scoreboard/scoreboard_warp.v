`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2020 03:12:16 PM
// Design Name: 
// Module Name: scoreboard_warp
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

endmodule
