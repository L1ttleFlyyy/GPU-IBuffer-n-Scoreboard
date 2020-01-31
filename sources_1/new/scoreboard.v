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


module scoreboard_per_warp#(
    parameter NUM_ENTRIES = 4, 
    parameter LOG_NUM_ENTRIES = $clog2(NUM_ENTRIES)
    ) (
    input clk,
    input rst,
    input [4:0] src1, // RegID is 5-bit (R8: thrID, R16: warpID)
    input [4:0] src2,
    input [4:0] dst,
    input src1_valid,
    input src2_valid,
    input dst_valid,
    input issue_grant,
    input [LOG_NUM_ENTRIES-1: 0] ScbID_MEM_Scb, // clear signal from MEM (SW only)
    input [LOG_NUM_ENTRIES-1: 0] ScbID_ALU_Scb, // clear signal from ALU (branch only)
    input [LOG_NUM_ENTRIES-1: 0] ScbID_CDB_Scb, // clear signal from CDB (for all regwrite)
    input ScbID_valid_MEM_Scb,
    input ScbID_valid_ALU_Scb,
    input ScbID_valid_CDB_Scb,
    output full,
    output dependent,
    output [LOG_NUM_ENTRIES-1: 0] ScbID_Scb_OC // ScbID passed to Operand Collector (for future clearing)
    );
    reg [4:0] src1_array [NUM_ENTRIES-1: 0];
    reg [4:0] src2_array [NUM_ENTRIES-1: 0];
    reg [4:0] dst_array [NUM_ENTRIES-1: 0];
    reg [NUM_ENTRIES-1: 0] src1_valid_array;
    reg [NUM_ENTRIES-1: 0] src2_valid_array;
    reg [NUM_ENTRIES-1: 0] dst_valid_array;
    reg [NUM_ENTRIES-1: 0] valid_array;

    // clear signal received from Mem/ALU/CDB?
    reg [NUM_ENTRIES-1: 0] valid_array_cleared;
    always@(*) begin
        valid_array_cleared = valid_array;
        if (ScbID_valid_MEM_Scb) valid_array_cleared[ScbID_MEM_Scb] = 0;
        if (ScbID_valid_ALU_Scb) valid_array_cleared[ScbID_ALU_Scb] = 0;
        if (ScbID_valid_CDB_Scb) valid_array_cleared[ScbID_CDB_Scb] = 0;
    end
    assign full = &valid_array_cleared;

    // find empty slot for a new instruction
    wire [NUM_ENTRIES-1: 0] empty_array = ~valid_array_cleared;
    reg [LOG_NUM_ENTRIES-1: 0] next_empty;
    integer i;
    always@(*) begin
        next_empty = 0;
        for (i = NUM_ENTRIES-1; i>=0; i = i-1) begin: empty_loop
            if(empty_array[i])
                next_empty = i;
        end
    end
    assign ScbID_Scb_OC = next_empty;

    // store a new instruction if granted by Issue unit
    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            valid_array <= 0;
        end else begin
            valid_array <= valid_array_cleared;
            if (issue_grant)
                valid_array[next_empty] <= 1;      
        end
    end
    always@(posedge clk) begin
        if (issue_grant) begin
            src1_array[next_empty] <= src1;
            src2_array[next_empty] <= src2;
            dst_array[next_empty] <= dst;
            src1_valid_array[next_empty] <= src1_valid;
            src2_valid_array[next_empty] <= src2_valid;
            dst_valid_array[next_empty] <= dst_valid;
        end
    end

    // check all possible data hazards
    reg [NUM_ENTRIES-1: 0] dependent_array;
    always@(*) begin
        // for each of the pending instructions, check RAW, WAW, WAR
        for (i = 0; i < NUM_ENTRIES; i = i+1) begin: dependent_loop
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
