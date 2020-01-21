`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2020 05:09:17 PM
// Design Name: 
// Module Name: barrel_shifter
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


module barrel_shifter # (
    parameter DIR = 0, // 0 -> right, 1 -> left
    parameter OFF = 0, // offset
    parameter WIDTH = 8 // number of input requests
    ) (
        input [WIDTH-1: 0] shamt, // NOTE: this shamt should be one-hot encoded
        input [WIDTH-1: 0] data,
        output [WIDTH-1: 0] data_shifted
    );
    localparam LOGWIDTH = $clog2(WIDTH);
    reg [LOGWIDTH-1: 0] shamt_decoded;
    integer i;
    always@ (shamt) begin
        shamt_decoded = 0;
        for (i = 0; i < WIDTH; i = i + 1) begin: decoder
            if (shamt[i]) 
                shamt_decoded = i;
        end
    end

    wire [LOGWIDTH-1: 0] shamt_off = shamt_decoded + OFF;

    generate 
        if (DIR) begin // left shift
            assign data_shifted = (data << shamt_off) | (data >> (WIDTH - shamt_off));
        end else begin // right shift
            assign data_shifted = (data << (WIDTH - shamt_off)) | (data >> shamt_off);
        end
    endgenerate

endmodule
