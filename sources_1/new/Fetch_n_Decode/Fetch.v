module Fetch (
PC0_PC_IF, PC1_PC_IF, PC2_PC_IF, PC3_PC_IF, PC4_PC_IF, PC5_PC_IF, PC6_PC_IF, PC7_PC_IF, 
GRT_raw_1_RR_IF, GRT_raw_2_RR_IF,
clk, rst_n,
UpdatePC_Qual1_SIMT_IF,
UpdatePC_Qual2_SIMT_IF,
UpdatePC_Qual3_ID0_IF,
UpdatePC_Qual3_ID1_IF,
Instr_IF_ID0, Instr_IF_ID1,
PC_plus4_IF_ID0, PC_plus4_IF_ID1,
Valid_2_IF_ID0, Valid_2_IF_ID1,
Valid_3_IF_ID0, Valid_3_IF_ID1
);

input clk, rst_n;
input wire [31:0] PC0_PC_IF, PC1_PC_IF, PC2_PC_IF, PC3_PC_IF, PC4_PC_IF, PC5_PC_IF, PC6_PC_IF, PC7_PC_IF;
input wire [7:0] GRT_raw_1_RR_IF, GRT_raw_2_RR_IF;
input wire [7:0] UpdatePC_Qual1_SIMT_IF, UpdatePC_Qual2_SIMT_IF, UpdatePC_Qual3_ID0_IF, UpdatePC_Qual3_ID1_IF;
output reg [31:0] Instr_IF_ID0, Instr_IF_ID1;
reg [31:0] PC_temp_Q1, PC_temp_Q2;
output reg [31:0] PC_plus4_IF_ID0, PC_plus4_IF_ID1;
output reg [7:0] Valid_3_IF_ID0, Valid_3_IF_ID1;
output reg [7:0] Valid_2_IF_ID0, Valid_2_IF_ID1;

wire [7:0] UpdatePC_Qual3_SIMT_IF;
wire [7:0] Flush_raw;
wire [7:0] Valid_Q1_1, Valid_Q2_1;
reg [31:0] PC_out1, PC_out2;
wire [31:0] PC_out1_minus_4, PC_out2_minus_4;

assign UpdatePC_Qual3_SIMT_IF = UpdatePC_Qual3_ID0_IF || UpdatePC_Qual3_ID1_IF;
assign PC_out1_minus_4 = PC_out1 - 4;
assign PC_out2_minus_4 = PC_out2 - 4;

mux_8_1 mux1 (PC0_PC_IF, PC1_PC_IF, PC2_PC_IF, PC3_PC_IF, PC4_PC_IF, PC5_PC_IF, PC6_PC_IF, PC7_PC_IF, GRT_raw_1_RR_IF, PC_out1);
mux_8_1 mux2 (PC0_PC_IF, PC1_PC_IF, PC2_PC_IF, PC3_PC_IF, PC4_PC_IF, PC5_PC_IF, PC6_PC_IF, PC7_PC_IF, GRT_raw_2_RR_IF, PC_out2);
I_cache Ic1 (clk, a_wr, PC_out1_minus_4, a_din, Instr_IF_ID0, clk, 0, PC_out2_minus_4, 32'b0, Instr_IF_ID1);  //a_din??

always@(posedge clk) begin
	if(!rst_n) begin
		PC_temp_Q1 <= 32'b0;
		PC_temp_Q2 <= 32'b0;
		PC_plus4_IF_ID0 <= 32'b0;
		PC_plus4_IF_ID1 <= 32'b0;
	end
	else begin
		PC_temp_Q1 <= PC_out1;
		PC_temp_Q2 <= PC_out2;
		PC_plus4_IF_ID0 <= PC_temp_Q1;
		PC_plus4_IF_ID1 <= PC_temp_Q2;
	end		
end

genvar i;
generate
for (i = 0; i < 8; i = i + 1) begin : flush_raw_g1
	assign Flush_raw[i] = !(UpdatePC_Qual1_SIMT_IF[i] || UpdatePC_Qual2_SIMT_IF[i] || UpdatePC_Qual3_SIMT_IF[i]);
end
for (i = 0; i < 8; i = i + 1) begin : valid_reg_g2
	assign Valid_Q1_1[i] = GRT_raw_1_RR_IF[i];
	always@(posedge clk) begin
		if (!rst_n) begin
			Valid_2_IF_ID0[i] <= 0;
			Valid_3_IF_ID0[i] <= 0;
		end
		else begin
			Valid_2_IF_ID0[i] <= Valid_Q1_1[i] && Flush_raw[i];
			Valid_3_IF_ID0[i] <= Valid_2_IF_ID0[i] && Flush_raw[i];
		end
	end 
end
for (i = 0; i < 8; i = i + 1) begin : valid_reg_g3
	assign Valid_Q2_1[i] = GRT_raw_2_RR_IF[i];
	always@(posedge clk) begin
		if (!rst_n) begin
			Valid_2_IF_ID1[i] <= 0;
			Valid_3_IF_ID1[i] <= 0;
		end
		else begin
			Valid_2_IF_ID1[i] <= Valid_Q2_1[i] && Flush_raw[i];
			Valid_3_IF_ID1[i] <= Valid_2_IF_ID1[i] && Flush_raw[i];
		end
	end 
end
endgenerate

endmodule

module mux_8_1 (
PC0, PC1, PC2, PC3, PC4, PC5, PC6, PC7, 
GRT_raw,
PC_out  );

input wire [31:0] PC0, PC1, PC2, PC3, PC4, PC5, PC6, PC7;
input wire [7:0] GRT_raw;
output reg [31:0] PC_out;

always@(*) begin
	PC_out = PC0;
	if (GRT_raw == 8'b0000_0001)
		PC_out = PC0;
	if (GRT_raw == 8'b0000_0010)
		PC_out = PC1;
	if (GRT_raw == 8'b0000_0100)
		PC_out = PC2;
	if (GRT_raw == 8'b0000_1000)
		PC_out = PC3;
	if (GRT_raw == 8'b0001_0000)
		PC_out = PC4;
	if (GRT_raw == 8'b0010_0000)
		PC_out = PC5;
	if (GRT_raw == 8'b0100_0000)
		PC_out = PC6;
	if (GRT_raw == 8'b1000_0000)
		PC_out = PC7;
end
endmodule
