`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2020 06:28:47 PM
// Design Name: 
// Module Name: BRAM_SinglePort
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


// A parameterized, inferable, true dual-port, dual-clock block RAM in Verilog.
 
module BRAM_SinglePort #(
    parameter OREG = 0,
    parameter DATA = 32,
    parameter ADDR = 9
) (
    // Port A
    input   wire                a_clk,
    input   wire                a_wr,
    input   wire    [ADDR-1:0]  a_addr,
    input   wire    [DATA-1:0]  a_din,
    output  reg     [DATA-1:0]  a_dout
);
 
// Shared memory
reg [DATA-1:0] mem [(2**ADDR)-1:0];

integer i;
initial begin
    for (i = 0; i < (2**ADDR); i = i + 1) begin: initialmem
        mem[i] <= i;
    end
end

generate
if (OREG) begin // pipelined BRAM
    // Port A
    reg     [DATA-1:0]  a_oreg, b_oreg;
    always @(posedge a_clk) begin
        a_dout <= a_oreg;
        a_oreg <= mem[a_addr];
        if(a_wr) begin
            a_oreg      <= a_din;
            mem[a_addr] <= a_din;
        end
    end
end else begin // flow-through BRAM
    // Port A
    always @(posedge a_clk) begin
        a_dout      <= mem[a_addr];
        if(a_wr) begin
            a_dout      <= a_din;
            mem[a_addr] <= a_din;
        end
    end
end
endgenerate
 
endmodule