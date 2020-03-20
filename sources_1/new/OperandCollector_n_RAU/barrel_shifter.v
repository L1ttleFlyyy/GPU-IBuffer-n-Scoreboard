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
        output reg [WIDTH-1: 0] data_shifted
    );
    // WIDTH-to-1 mux (one-hot encoded) 
    wire [WIDTH-1: 0] data_array [0:WIDTH-1];
    wire [WIDTH-1: 0] shamt_off = (OFF == 0)? shamt : {shamt[WIDTH-OFF-1: 0], shamt[WIDTH-1: WIDTH-OFF]};
    genvar i;
    generate 
        if (DIR) begin // left shift
            assign data_array[0] = shamt_off[0]? data : 0;
            for (i = 1; i < WIDTH; i = i + 1) begin: mux_input_left
                assign data_array[i] = shamt_off[i]? {data[WIDTH-i-1: 0], data[WIDTH-1: WIDTH-i]}: 0;
            end
        end else begin // right shift
            assign data_array[0] = shamt_off[0]? data : 0;
            for (i = 1; i < WIDTH; i = i + 1) begin: mux_input_right
                assign data_array[i] = shamt_off[i]? {data[i-1: 0], data[WIDTH-1: i]}: 0;
            end
        end
    endgenerate
    // all cases ORed together
    integer j;
    always@(*)begin
        data_shifted = data_array[0];
        for (j = 1; j < WIDTH; j = j + 1) begin: output_or
            data_shifted = data_shifted | data_array[j];
        end
    end

endmodule