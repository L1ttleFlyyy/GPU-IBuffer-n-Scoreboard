`timescale 1ns / 1ps

module PC_update #(
	parameter DATA = 32,
    parameter ADDR = 12
)(
	input clk, 
	input rst_n,
	//From TM
	input UpdatePC_TM_PC,
	input [31:0] StartingPC_TM_PC,
	//From ALU
	input [31:0] TargetAddr_ALU_PC, //work with UpdatePC_Qual1_SIMT_PC
	//From SIMT
	input Stall_SIMT_PC,
	input UpdatePC_Qual1_SIMT_PC,
	input UpdatePC_Qual2_SIMT_PC,
	input [31:0] TargetAddr_SIMT_PC, //work with UpdatePC_Qual2_SIMT_PC
	//From RR(PC)
	input GRT_RR_PC,
	//From IF
	input valid_1_IF_PC, valid_2_IF_PC, valid_3_IF_PC,
	//From ID
	input Valid_3_ID1_PC,
	input UpdatePC_Qual3_ID0_PC,
	input UpdatePC_Qual3_ID1_PC,
	input [31:0] TargetAddr_ID0_PC,
	input [31:0] TargetAddr_ID1_PC,
	
	//To IF
	output [31:0] PC_out_IF_PC
);

reg [31:0] PC_reg;
reg [31:0] PC_next;
wire UpdatePC_Qual3_ID_PC;

assign PC_out_IF_PC = PC_next;
assign UpdatePC_Qual3_ID_PC = UpdatePC_Qual3_ID0_PC || UpdatePC_Qual3_ID1_PC;

//Update_PC
always @(*) begin
	PC_next = PC_reg;
	if (!rst_n)
		PC_next = 32'b0;
	else if (UpdatePC_TM_PC)
		PC_next = StartingPC_TM_PC;
	else if (valid_1_IF_PC && valid_2_IF_PC && valid_3_IF_PC && Stall_SIMT_PC)
		PC_next = PC_reg - 4;
	else if (!UpdatePC_Qual1_SIMT_PC && !UpdatePC_Qual2_SIMT_PC && UpdatePC_Qual3_ID_PC)
		if (Valid_3_ID1_PC)
			PC_next = TargetAddr_ID1_PC;
		else
			PC_next = TargetAddr_ID0_PC;
	else if (!UpdatePC_Qual1_SIMT_PC && UpdatePC_Qual2_SIMT_PC && !UpdatePC_Qual3_ID_PC)
		PC_next = TargetAddr_SIMT_PC;
	else if (UpdatePC_Qual1_SIMT_PC && !UpdatePC_Qual2_SIMT_PC && !UpdatePC_Qual3_ID_PC)
		PC_next = TargetAddr_ALU_PC;
	else if (GRT_RR_PC)
		PC_next = PC_reg + 4;
end
always @(posedge clk) begin
	PC_reg <= PC_next;
end



endmodule