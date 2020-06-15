`timescale 1ns / 100ps
 
module I_Cache #(
    parameter DATA = 32,
    parameter ADDR = 10
) (
    // Port A
    input   wire                a_clk,
    input   wire                a_wr,
    input   wire    [ADDR-1:0]  a_addr,
    input   wire    [DATA-1:0]  a_din,
    output  reg     [DATA-1:0]  a_dout,
     
    // Port B
    input   wire                b_clk,
    input   wire    [ADDR-1:0]  b_addr,
    output  reg     [DATA-1:0]  b_dout
);

reg [DATA-1:0] mem [(2**ADDR)-1:0];
reg	[DATA-1:0] a_oreg, b_oreg;
// pipelined BRAM
// Port A
always @(posedge a_clk) begin
    a_dout <= a_oreg;
    a_oreg <= mem[a_addr];
	if(a_wr) begin
        a_oreg <= a_din;
		mem[a_addr] <= a_din;
	end
end
 
// Port B
always @(posedge b_clk) begin
	b_dout <= b_oreg;
	b_oreg <= mem[b_addr];
end
endmodule