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
    // TODO: parameter LOG_NUM_ENTRIES = $clog2(NUM_ENTRIES)
    ) (
    input [2:0] Src1,
    input ValidSrc1,
    input [2:0] Src2,
    input ValidSrc2,
    input [2:0] Dst,
    input ValidDst,
    input DepositEN,
    // input [LOG_NUM_ENTRIES-1: 0] ScoreboardID_MEM_Scoreboard,
    input [NUM_ENTRIES-1: 0] ScoreboardID_Mem_Scoreboard,
    output Full,
    output Dependent,
    // output [LOG_NUM_ENTRIES-1: 0] ScoreboardID_Scoreboard_OperandCollector
    output [NUM_ENTRIES-1: 0] ScoreboardID_Scoreboard_OperandCollector
    );
    reg [2:0] Src1_Array[0: NUM_ENTRIES-1];
    reg ValidSrc1_Array[0: NUM_ENTRIES-1];
    reg [2:0] Src2_Array[0: NUM_ENTRIES-1];
    reg ValidSrc2_Array[0: NUM_ENTRIES-1];
    reg [2:0] Dst_Array[0: NUM_ENTRIES-1];
    reg ValidDst_Array[0: NUM_ENTRIES-1];
    reg [NUM_ENTRIES-1: 0] Valid_Array;
    wire [NUM_ENTRIES-1: 0] Valid_Array_next;
    
    // fixed prioritizer indicating the next available slot
    assign Valid_Array_next = Valid_Array & (~ScoreboardID_Mem_Scoreboard);
    /*
    always@(*) begin
        Valid_Array_next = Valid_Array;
        Valid_Array_next[ScoreboardID_Mem_Scoreboard] = 0;
    end
    */
    fixed_prioritizer#(.WIDTH(NUM_ENTRIES)) fp ( 
        .req(~Valid_Array_next),
        .grt(ScoreboardID_Scoreboard_OperandCollector)
    );
    assign Full = &Valid_Array_next; // all valid

    // storage maintaining
    integer i;
    always@(posedge clk or posedge rst) begin
        if (rst) begin
            Valid_Array <= 0;
        end else begin
            Valid_Array <= Valid_Array_next;
            if (DepositEN) begin
                for (i = 0; i < NUM_ENTRIES; i = i+1) begin: deposit_loop
                    if (ScoreboardID_Scoreboard_OperandCollector[i]) begin
                        Valid_Array[i] <= 1'b1;
                        Src1_Array[i] <= Src1;
                        ValidSrc1_Array[i] <= ValidSrc1;
                        Src2_Array[i] <= Scr2;
                        ValidSrc2_Array[i] <= ValidSrc1;
                        Dst_Array[i] <= Dst;
                    end
                end
            end
        end
    end

endmodule // scoreboard_inner

module scoreboard#(
    parameter NUM_WARPS = 8
    )   (
    input clk,
    input rst,
    input [NUM_WARPS-1: 0] ScoreboardID_Mem_Scoreboard
    );
    
endmodule
