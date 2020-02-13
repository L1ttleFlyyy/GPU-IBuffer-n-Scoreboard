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
    input [4:0] Src1, // RegID is 5-bit (R8: thrID, R16: warpID)
    input [4:0] Src2,
    input [4:0] Dst,
    input Src1_Valid,
    input Src2_Valid,
    input Dst_Valid,
    input issue_grant,
    input [1:0] ScbID_MEM_Scb, // clear signal from MEM (SW only)
    input [1:0] ScbID_ALU_Scb, // clear signal from ALU (branch only)
    input [1:0] ScbID_CDB_Scb, // clear signal from CDB (for all regwrite)
    input ScbID_Valid_MEM_Scb,
    input ScbID_Valid_ALU_Scb,
    input ScbID_Valid_CDB_Scb,
    output full,
    output dependent,
    output [1:0] ScbID_Scb_OC // ScbID passed to Operand Collector (for future clearing)
    );
    reg [4:0] Src1_array [3:0];
    reg [4:0] Src2_array [3:0];
    reg [4:0] Dst_array [3:0];
    reg [3:0] Src1_Valid_array;
    reg [3:0] Src2_Valid_array;
    reg [3:0] Dst_Valid_array;
    reg [3:0] valid_array;

    // clear signal received from Mem/ALU/CDB?
    reg [3:0] valid_array_cleared;
    always@(*) begin
        valid_array_cleared = valid_array;
        if (ScbID_Valid_MEM_Scb) valid_array_cleared[ScbID_MEM_Scb] = 0;
        if (ScbID_Valid_ALU_Scb) valid_array_cleared[ScbID_ALU_Scb] = 0;
        if (ScbID_Valid_CDB_Scb) valid_array_cleared[ScbID_CDB_Scb] = 0;
    end
    assign full = &valid_array_cleared;

    // find empty slot for a new instruction
    wire [3:0] empty_array = ~valid_array_cleared;
    reg [1:0] next_empty;
    integer i;
    always@(*) begin
        next_empty = 0;
        for (i=3; i>=0; i=i-1) begin: empty_loop
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
            Src1_array[next_empty] <= Src1;
            Src2_array[next_empty] <= Src2;
            Dst_array[next_empty] <= Dst;
            Src1_Valid_array[next_empty] <= Src1_Valid;
            Src2_Valid_array[next_empty] <= Src2_Valid;
            Dst_Valid_array[next_empty] <= Dst_Valid;
        end
    end

    // check all possible data hazards
    reg [3: 0] dependent_array;
    always@(*) begin
        // for each of the pending instructions, check RAW, WAW, WAR
        for (i = 0; i < 4; i = i+1) begin: dependent_loop
            // RAW:
            dependent_array[i] = 
                (Src1_Valid && Src1_Valid_array[i] && (Src1 == Dst_array[i])) | 
                (Src2_Valid && Src2_Valid_array[i] && (Src2 == Dst_array[i]));
            // WAW:
            dependent_array[i] = dependent_array[i] |
                (Dst_Valid && Dst_Valid_array[i] && (Dst == Dst_array[i]));
            // WAR:
            dependent_array[i] = dependent_array[i] |
                (Dst_Valid && Src1_Valid_array[i] && (Dst == Src1_array[i])) |
                (Dst_Valid && Src2_Valid_array[i] && (Dst == Src2_array[i])); 
        end
        dependent_array = dependent_array & valid_array_cleared; // Note here use valid_cleared to save one clock
    end
    // overall dependent bit:
    assign dependent = |dependent_array;

endmodule // scoreboard_inner

module scoreboard#(
    parameter NUM_WARPS = 8,
    parameter NUM_WARPS = $clog2(NUM_WARPS)
    ) (
    // common signals
    input clk,
    input rst,
    input [3: 0] ScbID_MEM_Scb, // clear signal from MEM (SW only)
    input [3: 0] ScbID_ALU_Scb, // clear signal from ALU (branch only)
    input [3: 0] ScbID_CDB_Scb, // clear signal from CDB (for all regwrite)
    input ScbID_Valid_MEM_Scb,
    input ScbID_Valid_ALU_Scb,
    input ScbID_Valid_CDB_Scb,

    // warp specific signals
    input [NUM_WARPS-1: 0] Grant_IU_IB_Scb, // grant from issue unit
    input [5*NUM_WARPS-1: 0] Src1_Flattened_IB_Scb, // Flattened RegID: 5 bit regID * 8 waprs
    input [5*NUM_WARPS-1: 0] Src2_Flattened_IB_Scb,
    input [5*NUM_WARPS-1: 0] Dst_Flattened_IB_Scb,
    output [2*NUM_WARPS-1: 0] ScbID_Flattened_Scb_IB, // ScbID to be passed to Operand Collector
    input [NUM_WARPS-1: 0] Src1_Valid,
    input [NUM_WARPS-1: 0] Src2_Valid,
    input [NUM_WARPS-1: 0] Dst_Valid,
    output [NUM_WARPS-1: 0] Full_Scb_IB,
    output [NUM_WARPS-1: 0] Dependent_Scb_IB
    );

    wire [4:0] Scr1_IB_Scb [0:NUM_WARPS-1];
    wire [4:0] Scr2_IB_Scb [0:NUM_WARPS-1];
    wire [4:0] Dst_IB_Scb [0:NUM_WARPS-1];
    wire [3:0] ScbID_Scb_IB[0:NUM_WARPS-1];

    // flatten and unflatten
    genvar i;
    generate
    for (i=0; i<NUM_WARPS; i=i+1) begin: scoreboard_loop
        assign Src1_IB_Scb[i] = Src1_Flattened_IB_Scb[i*5:i*5+4];
        assign Src2_IB_Scb[i] = Src2_Flattened_IB_Scb[i*5:i*5+4];
        assign Dst_IB_Scb[i] = Dst_Flattened_IB_Scb[i*5:i*5+4];
        assign ScbID_Flattened_Scb_IB[i*4+3:i*4] = ScbID_Scb_IB[i];
    end
    endgenerate
    
endmodule
