`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2020 06:28:47 PM
// Design Name: 
// Module Name: Inferable_BRAM
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
 
module Inferable_BRAM #(
    parameter OREG = 0, //要不要？？？
    parameter DATA = 256,    // 32 * 8 bits for each warp with 8 threads
    parameter ADDR = 3      // 8 loc each bank
) (
        // Port A
    input   wire                a_clk,
    input   wire                a_wr,
    input   wire    [ADDR-1:0]  a_addr,
    input   wire    [DATA-1:0]  a_din,
    output  reg     [DATA-1:0]  a_dout,
     
    // Port B
    input   wire                b_clk,
    input   wire                b_wr,
    input   wire    [ADDR-1:0]  b_addr,
    input   wire    [DATA-1:0]  b_din,
    output  reg     [DATA-1:0]  b_dout

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
     
    // Port B
    always @(posedge b_clk) begin
        b_dout <= b_oreg;
        b_oreg <= mem[b_addr];
        if(b_wr) begin
            b_oreg      <= b_din;
            mem[b_addr] <= b_din;
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
     
    // Port B
    always @(posedge b_clk) begin
        b_dout      <= mem[b_addr];
        if(b_wr) begin
            b_dout      <= b_din;
            mem[b_addr] <= b_din;
        end
    end

end
endgenerate
 
endmodule