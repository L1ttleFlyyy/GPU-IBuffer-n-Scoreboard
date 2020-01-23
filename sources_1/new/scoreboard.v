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


module scoreboard_inner#(
    parameter NUM_ENTRIES = 4
    ) (
    // TODO: RegID is actually 5-bit (R8 is thrID, R16 is warpID)
    // to ID stage: Decoding unit should treat R8/R16 as NON-Valid registers
    input clk,
    input rst, // TODO: rst/rst_n
    input [2:0] Src1,
    input [2:0] Src2,
    input [2:0] Dst,
    input ValidSrc1,
    input ValidSrc2,
    input ValidDst,
    input IssueGrant,
    // TODO: to all the backend: should we use one-hot encoded IDs everywhere to save the extra codec logic?
    // If so, we do not need Valid signal for the IDs, since all-zero means invalid
    // parameter LOG_NUM_ENTRIES = $clog2(NUM_ENTRIES)
    // input [LOG_NUM_ENTRIES-1: 0] Clear_ScoreboardID_Mem_Scoreboard,
    // output [LOG_NUM_ENTRIES-1: 0] ScoreboardID_Scoreboard_OperandCollector
    input [NUM_ENTRIES-1: 0] Clear_ScoreboardID_Mem_Scoreboard,
    // TODO: naming WB: Write-back stage?
    input [NUM_ENTRIES-1: 0] Clear_ScoreboardID_WB_Scoreboard,
    output Full,
    output Dependent,
    // TODO: name too long, needs abbreviation
    output [NUM_ENTRIES-1: 0] ScoreboardID_Scoreboard_OperandCollector
    );
    reg [2:0] Src1_Array [NUM_ENTRIES-1: 0];
    reg [2:0] Src2_Array [NUM_ENTRIES-1: 0];
    reg [2:0] Dst_Array [NUM_ENTRIES-1: 0];
    reg [NUM_ENTRIES-1: 0] ValidSrc1_Array;
    reg [NUM_ENTRIES-1: 0] ValidSrc2_Array;
    reg [NUM_ENTRIES-1: 0] ValidDst_Array;
    reg [NUM_ENTRIES-1: 0] Valid_Array;

    // TODO: clear signal received from Mem, Write-back any other stages?
    wire [NUM_ENTRIES-1: 0] Valid_Array_cleared = Valid_Array & (~Clear_ScoreboardID_Mem_Scoreboard) & (~Clear_ScoreboardID_WB_Scoreboard);
    wire [NUM_ENTRIES-1: 0] empty_Array = ~Valid_Array_cleared;
    wire [NUM_ENTRIES-1: 0] next_empty; 
    // one-hot encoded next empty slot
    fixed_prioritizer#(.WIDTH(NUM_ENTRIES)) fp ( 
        .req(empty_Array),
        .grt(next_empty)
    );

    always@(posedge clk or posedge rst) begin
        if (rst) begin
            Valid_Array <= 0;
        end else if (IssueGrant) begin
                Valid_Array <= Valid_Array_cleared | next_empty;
        end else begin
                Valid_Array <= Valid_Array_cleared;         
        end
    end

    // storage maintaining
    integer i;
    always@(posedge clk) begin
        for (i = 0; i < NUM_ENTRIES; i = i+1) begin: deposit_content_loop
            if (IssueGrant & ScoreboardID_Scoreboard_OperandCollector[i]) begin
                Src1_Array[i] <= Src1;
                Src2_Array[i] <= Src2;
                Dst_Array[i] <= Dst;
                ValidSrc1_Array[i] <= ValidSrc1;
                ValidSrc2_Array[i] <= ValidSrc2;
                ValidDst_Array[i] <= ValidDst;
            end
        end
    end

    // generate output
    reg [NUM_ENTRIES-1: 0] Dependent_Array;
    always@(*) begin
        // for each of the pending instructions, check RAW, WAW, WAR
        for (i = 0; i < NUM_ENTRIES; i = i+1) begin: dependent_loop
            // RAW:
            Dependent_Array[i] = 
                (ValidSrc1 && ValidDst_Array[i] && (Src1 == Dst_Array[i])) | 
                (ValidSrc2 && ValidDst_Array[i] && (Src2 == Dst_Array[i]));
            // WAW:
            Dependent_Array[i] = Dependent_Array[i] |
                (ValidDst && ValidDst_Array[i] && (Dst == Dst_Array[i]));
            // WAR:
            Dependent_Array[i] = Dependent_Array[i] |
                (ValidDst && ValidSrc1_Array[i] && (Dst == Src1_Array[i])) |
                (ValidDst && ValidSrc2_Array[i] && (Dst == Src2_Array[i]));
            Dependent_Array[i] = Dependent_Array[i] & Valid_Array_cleared[i]; // Note here use Valid_next to possibly save one clock
        end
    end

    assign Dependent = |Dependent_Array;
    assign Full = (empty_Array == 0); // all not empty
    assign ScoreboardID_Scoreboard_OperandCollector = next_empty;

endmodule // scoreboard_inner

// module scoreboard#(
//     parameter NUM_WARPS = 8,
//     parameter NUM_ENTRIES = 4
//     )   (
//     input clk,
//     input rst,
//     input [NUM_WARPS-1: 0] WarpID_Mem_Scoreboard,
//     input [NUM_ENTRIES-1: 0] ScoreboardID_Mem_Scoreboard
//     );
    
// endmodule
