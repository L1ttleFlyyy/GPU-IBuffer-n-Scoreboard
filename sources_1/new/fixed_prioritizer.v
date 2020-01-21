`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2019 08:55:38 PM
// Design Name: 
// Module Name: fixed_prioritizer
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


module fixed_prioritizer #( // NOTE: give LSB the highest priority
    parameter WIDTH = 8
    ) (
    input [WIDTH-1:0] req,
    output reg [WIDTH-1:0] grt
    );
    integer i;
    always@(*) begin
        grt = 0;
        for (i = WIDTH - 1; i >= 0; i = i-1) begin: forloop
            if (req[i]) grt = 1 << i;
        end
    end
    
endmodule
