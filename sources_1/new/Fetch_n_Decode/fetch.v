module fetch (
PC0, PC1, PC2, PC3, PC4, PC5, PC6, PC7, 
GRT_raw_1, GRT_raw_2,
clk, rst_n,
UpdatePC_Qual1_SIMT_IF,
UpdatePC_Qual2_SIMT_IF,
UpdatePC_Qual3_SIMT_IF,
Instr_1, Instr_2,
PC_plus4_Q1_ID_SIMT, PC_plus4_Q2_ID_SIMT,
Valid_Q1_3, Valid_Q2_3
);

input clk, rst_n;
input wire [31:0] PC0, PC1, PC2, PC3, PC4, PC5, PC6, PC7;
input wire [7:0] GRT_raw_1, GRT_raw_2;
input wire [7:0] UpdatePC_Qual1_SIMT_IF, UpdatePC_Qual2_SIMT_IF, UpdatePC_Qual3_SIMT_IF;
output reg [31:0] Instr_1, Instr_2;
reg [31:0] PC_temp_Q1, PC_temp_Q2;
output reg [31:0] PC_plus4_Q1_ID_SIMT, PC_plus4_Q2_ID_SIMT;
output reg [7:0] Valid_Q1_3, Valid_Q2_3;

wire [7:0] Flush_raw;
wire [7:0] Valid_Q1_1, Valid_Q2_1;
reg [7:0] Valid_Q1_2, Valid_Q2_2;
reg [31:0] selected_PC_Q1, selected_PC_Q2;

mux_8_1 mux1 (PC0, PC1, PC2, PC3, PC4, PC5, PC6, PC7, GRT_raw_1, PC_out1);
mux_8_1 mux2 (PC0, PC1, PC2, PC3, PC4, PC5, PC6, PC7, GRT_raw_2, PC_out2);
I_cache Ic1 (clk, a_wr, PC_out1, a_din, Instr_1, clk, 0, PC_out2, 32'b0, Instr_2);  //a_din??

always@(posedge clk) begin
	if(!rst_n) begin
		PC_temp_Q1 <= 32'b0;
		PC_temp_Q2 <= 32'b0;
		PC_plus4_Q1_ID_SIMT <= 32'b0;
		PC_plus4_Q2_ID_SIMT <= 32'b0;
	end
	else begin
		PC_temp_Q1 <= PC_out1 + 4;
		PC_temp_Q2 <= PC_out2 + 4;
		PC_plus4_Q1_ID_SIMT <= PC_temp_Q1;
		PC_plus4_Q2_ID_SIMT <= PC_temp_Q2;
	end		
end

genvar i;
generate
for (i = 1; i < 9; i = i + 1) begin
	assign Flush_raw[i] = !(UpdatePC_Qual1_SIMT_IF[i] || UpdatePC_Qual2_SIMT_IF[i] || UpdatePC_Qual3_SIMT_IF[i]);
end
for (i = 1; i < 9; i = i + 1) begin
	assign Valid_Q1_1[i] = GRT_raw_1[i];
	always@(posedge clk) begin
		if (!rst_n) begin
			Valid_Q1_2[i] <= 0;
			Valid_Q1_3[i] <= 0;
		end
		else begin
			Valid_Q1_2[i] <= Valid_Q1_1[i] && Flush_raw[i];
			Valid_Q1_3[i] <= Valid_Q1_2[i] && Flush_raw[i];
		end
	end 
end
for (i = 1; i < 9; i = i + 1) begin
	assign Valid_Q2_1[i] = GRT_raw_2[i];
	always@(posedge clk) begin
		if (!rst_n) begin
			Valid_Q2_2[i] <= 0;
			Valid_Q2_3[i] <= 0;
		end
		else begin
			Valid_Q2_2[i] <= Valid_Q2_1[i] && Flush_raw[i];
			Valid_Q2_3[i] <= Valid_Q2_2[i] && Flush_raw[i];
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
