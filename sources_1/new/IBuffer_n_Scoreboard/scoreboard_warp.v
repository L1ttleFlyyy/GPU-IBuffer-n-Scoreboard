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
    input [4:0] Src1, // RegID is 5-bit (R8: thrID, R16: warpID)
    input [4:0] Src2,
    input [4:0] Dst,
    input Src1_Valid,
    input Src2_Valid,
    input Dst_Valid,
    input RP_Grt, // only create Scb entry for RP_Grt (avoid duplicate entry for Replay instructions)
    input Replayable, // if it is LW/SW, the Scb entry will be marked as "inComplete"
    //signal for clearing
    input [1:0] Replay_Complete_ScbID, // mark the Scb entry as Complete
    input Replay_Complete,
    input Replay_Complete_SW_LWbar, // distinguish between SW/LW
    // signal from other modules
    input [1:0] Clear_ScbID_Br, // clear signal from ALU (for branch only)
    input [1:0] Clear_ScbID_regwr, // clear signal from CDB (for all regwrite)
    input Clear_Valid_Br,
    input Clear_Valid_regwr,
    output Full,
    output Empty, // for exit
    output Dependent,
    output [1:0] ScbID_Scb_IB // ScbID passed to IBuffer (for future clearing)
    );
    reg [4:0] Src1_array [3:0];
    reg [4:0] Src2_array [3:0];
    reg [4:0] Dst_array [3:0];
    reg [3:0] Src1_Valid_array;
    reg [3:0] Src2_Valid_array;
    reg [3:0] Dst_Valid_array;
    reg [3:0] Valid_array;
    reg [3:0] Replay_Complete_array;

    // Valid array after Scb entries cleared by Mem/ALU/CDB
    reg [3:0] Valid_array_cleared;
    always@(*) begin
        Valid_array_cleared = Valid_array;
        if (Replay_Complete & Replay_Complete_SW_LWbar) // from IBuffer for SW
            Valid_array_cleared[Replay_Complete_ScbID] = 0;
        if (Clear_Valid_regwr & Replay_Complete_array[Clear_ScbID_regwr]) // from CDB
            Valid_array_cleared[Clear_ScbID_regwr] = 0; // clear only when finished (in case of LW)
        if (Clear_Valid_Br) // from ALU for branch
            Valid_array_cleared[Clear_ScbID_Br] = 0;
    end
    assign Full = &Valid_array_cleared;

    // find Empty slot for a new instruction
    wire [3:0] Empty_array = ~Valid_array_cleared;
    assign Empty = &Empty_array;
    reg [1:0] next_Empty;
    integer i;
    always@(*) begin
        next_Empty = 0;
        for (i=3; i>=0; i=i-1) begin: Empty_loop
            if(Empty_array[i])
                next_Empty = i;
        end
    end
    assign ScbID_Scb_IB = next_Empty;

    // store a new instruction if granted by Issue unit
    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            Valid_array <= 0;
        end else begin
            Valid_array <= Valid_array_cleared;
            if (RP_Grt)
                Valid_array[next_Empty] <= 1'b1;      
        end
    end

    always@(posedge clk) begin
        if (RP_Grt) begin
            Src1_array[next_Empty] <= Src1;
            Src2_array[next_Empty] <= Src2;
            Dst_array[next_Empty] <= Dst;
            Src1_Valid_array[next_Empty] <= Src1_Valid;
            Src2_Valid_array[next_Empty] <= Src2_Valid;
            Dst_Valid_array[next_Empty] <= Dst_Valid;
            if (Replayable) 
                Replay_Complete_array[next_Empty] <= 1'b0;
            else
                Replay_Complete_array[next_Empty] <= 1'b1;
        end
        if (Replay_Complete) begin
            Replay_Complete_array[Replay_Complete_ScbID] <= 1'b1;
        end
    end

    // check all possible data hazards
    reg [3: 0] Dependent_array;
    always@(*) begin
        // for each of the pending instructions, check RAW, WAW, WAR
        for (i = 0; i < 4; i = i+1) begin: Dependent_loop
            // RAW:
            Dependent_array[i] = 
                (Src1_Valid && Src1_Valid_array[i] && (Src1 == Dst_array[i])) | 
                (Src2_Valid && Src2_Valid_array[i] && (Src2 == Dst_array[i]));
            // WAW:
            Dependent_array[i] = Dependent_array[i] |
                (Dst_Valid && Dst_Valid_array[i] && (Dst == Dst_array[i]));
            // WAR:
            Dependent_array[i] = Dependent_array[i] |
                (Dst_Valid && Src1_Valid_array[i] && (Dst == Src1_array[i])) |
                (Dst_Valid && Src2_Valid_array[i] && (Dst == Src2_array[i])); 
        end
        Dependent_array = Dependent_array & Valid_array_cleared; // Note here use Valid_cleared to save one clock
    end
    // overall Dependent bit:
    assign Dependent = |Dependent_array;

endmodule
