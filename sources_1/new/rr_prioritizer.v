`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2020 05:04:55 PM
// Design Name: 
// Module Name: rr_prioritizer
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


module rr_prioritizer #(
    parameter WIDTH = 8
    ) (
    input clk,
    input rst,
    input [WIDTH-1: 0] req,
    output [WIDTH-1: 0] grt
    );

    // NOTE: the requesters should subpress their requests if they cannot untilize the grant within clock
    reg [WIDTH-1: 0] MRG; // most recent grantee, one-hot encoded
    wire ALORP = |req; // at least one request is present

    always@(posedge clk or posedge rst) begin
        if (rst) begin
            MRG <= 1 << (WIDTH-1); // on initial, give highest priority to req[0]
        end else if (ALORP) begin
            MRG <= grt;
        end
    end

    wire [WIDTH-1: 0] req_bs0_to_fp, grt_fp_to_bs1;
    // right shift first
    barrel_shifter#(.DIR(0), .OFF(1), .WIDTH(WIDTH)) bs0 (
        .shamt(MRG),
        .data(req),
        .data_shifted(req_bs0_to_fp)
    );
    // fixed prioritizer (LSB has the highest priority)
    fixed_prioritizer#(.WIDTH(WIDTH)) fp (
        .req(req_bs0_to_fp),
        .grt(grt_fp_to_bs1)
    );
    // left shift back
    barrel_shifter#(.DIR(1), .OFF(1), .WIDTH(WIDTH)) bs1 (
        .shamt(MRG),
        .data(grt_fp_to_bs1),
        .data_shifted(grt)
    );

endmodule
