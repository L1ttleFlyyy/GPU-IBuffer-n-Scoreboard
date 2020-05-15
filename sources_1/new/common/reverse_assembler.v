`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Designer: Eda Yan
// 
// Create Date: 2/25/2020
// Design Name: 
// Module Name: reverse_assembler
// Project Name: GP-GPU
// Target Devices: 
// Tool Versions: 
// Description: reverse_assembler reads the 32 bits instruction binary code and 
// reverse it into string format instruction so it is easy to debug;
// It can link to every module's output in GPU and generate reversed instruction
// set in a file named by this module name linked to
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reverse_assembler (

	// global signals
	input clk, rst_n,
	
	input [7:0] one_hot_warp_ID,  // one-hot code
    input [31:0] instruction_in,
	input [31:0] PC,
	input [8*10:0] module_name,
	
	output [2:0] warp_ID,
	output reg [8*20:1] instruction_out,
	output [31:0] PC_value,
	output [15:0] immediate,
	output [25:0] j_address
	
    );
	
	integer outfile;
	
	decode8_3 decode8_3_ID0_warp (one_hot_warp_ID, warp_ID);
	assign PC_value = PC;
	assign immediate = instruction_in[15:0];
	assign j_address = instruction_in[25:0];
	
	initial begin
		outfile = $fopen(module_name, "w");
	end
	
	always@(posedge clk) begin
		if(!rst_n) begin
			//warp_ID <= 3'bXXX;
			instruction_out <= "NOOP";
			end
		else begin
			reverse_instruction(instruction_in, instruction_out);
			$fwrite(outfile,"%s; imme = %d; j_addr = %h; PC = %h; warp_ID = %d\n", instruction_out, immediate, j_address, PC_value, warp_ID);
		end			
	end

	task reverse_instruction;
		input [31:0] instruction_in;
		output [8*20:1] instruction_out;
		reg [5:0] opcode;
		reg [4:0] rs, rt, rd;
		reg [4:0] shamt;
		reg [5:0] funct;
		reg [15:0] imme;
		reg [25:0] jump_address;
		reg [4:0] warp_id, number_of_reg_needed;
		reg dot_S;
		
		reg [8*4:1] inst_string;
		reg [8*4:1] rs_string;
		reg [8*4:1] rt_string;
		reg [8*4:1] rd_string;
		reg [8*2:1] dot_S_string;
	begin	
		assign opcode = instruction_in[31:26];
		assign rs = instruction_in[25:21];
		assign rt = instruction_in[20:16];
		assign rd = instruction_in[15:11];
		assign shamt = instruction_in[10:6];
		assign funct = instruction_in[5:0];
		assign imme = instruction_in[15:0];
		assign jump_address = instruction_in[25:0];
		assign warp_id = instruction_in[25:21];
		assign dot_S = instruction_in[30];		

			case(rs)
				5'b10000: rs_string = " $31";
				5'b01000: rs_string = " $15";
				5'b00111: rs_string = " $7 ";
				5'b00110: rs_string = " $6 ";
				5'b00101: rs_string = " $5 ";
				5'b00100: rs_string = " $4 ";
				5'b00011: rs_string = " $3 ";
				5'b00010: rs_string = " $2 ";
				5'b00001: rs_string = " $1 ";
				5'b00000: rs_string = " $0 ";
				default : rs_string = " UNK";
			endcase
			case(rt)
				5'b10000: rt_string = " $31";
				5'b01000: rt_string = " $15";
				5'b00111: rt_string = " $7 ";
				5'b00110: rt_string = " $6 ";
				5'b00101: rt_string = " $5 ";
				5'b00100: rt_string = " $4 ";
				5'b00011: rt_string = " $3 ";
				5'b00010: rt_string = " $2 ";
				5'b00001: rt_string = " $1 ";
				5'b00000: rt_string = " $0 ";
				default : rt_string = " UNK";
			endcase
			case(rd)
				5'b10000: rd_string = " $31";
				5'b01000: rd_string = " $15";
				5'b00111: rd_string = " $7 ";
				5'b00110: rd_string = " $6 ";
				5'b00101: rd_string = " $5 ";
				5'b00100: rd_string = " $4 ";
				5'b00011: rd_string = " $3 ";
				5'b00010: rd_string = " $2 ";
				5'b00001: rd_string = " $1 ";
				5'b00000: rd_string = " $0 ";
				default : rd_string = " UNK";
			endcase
			if (dot_S == 1)
				dot_S_string = ".S";
			else 
				dot_S_string = "  ";
			
			casex(opcode)
				// R type instructions
				6'b0?0000:  begin
								casex(funct)
									6'b100000:  begin   inst_string = "ADD "; 
														instruction_out = {inst_string, dot_S_string, rd_string, rs_string, rt_string};
												end
									6'b100010:  begin   inst_string = "SUB "; 
														instruction_out = {inst_string, dot_S_string, rd_string, rs_string, rt_string};
												end
									6'b011000:  begin   inst_string = "MUL "; 
														instruction_out = {inst_string, dot_S_string, rd_string, rs_string, rt_string};
												end
									6'b100100:  begin   inst_string = "AND "; 
														instruction_out = {inst_string, dot_S_string, rd_string, rs_string, rt_string};
												end
									6'b100101:  begin   inst_string = "OR  "; 
														instruction_out = {inst_string, dot_S_string, rd_string, rs_string, rt_string};
												end
									6'b100110:  begin   inst_string = "XOR "; 
														instruction_out = {inst_string, dot_S_string, rd_string, rs_string, rt_string};
												end
									6'b000010:  begin   inst_string = "SHR "; 
														instruction_out = {inst_string, dot_S_string, rd_string, rs_string, rt_string};
												end
									6'b000000:  begin   inst_string = "SHL "; 
														instruction_out = {inst_string, dot_S_string, rd_string, rs_string, rt_string};
												end
									default :   instruction_out = "Unknown"; // invalid instruction
								endcase
							end
				6'b0?1000:  begin   inst_string = "ADDI";
									instruction_out = {inst_string, dot_S_string, rt_string, rs_string, "  imme"};
							end
				6'b0?1100:  begin   inst_string = "ANDI";
									instruction_out = {inst_string, dot_S_string, rt_string, rs_string, "  imme"};
							end
				6'b0?1101:  begin   inst_string = "ORI ";
									instruction_out = {inst_string, dot_S_string, rt_string, rs_string, "  imme"};
							end
				6'b0?1110:  begin   inst_string = "XORI";
									instruction_out = {inst_string, dot_S_string, rt_string, rs_string, "  imme"};
							end
				6'b1?0011:  begin   inst_string = "LD  ";
									instruction_out = {inst_string, dot_S_string, rt_string, rs_string, "  imme"};
							end
				6'b1?0111:  begin   inst_string = "LDS ";
									instruction_out = {inst_string, dot_S_string, rt_string, rs_string, "  imme"};
							end
				6'b1?1011:  begin   inst_string = "SW  ";
									instruction_out = {inst_string, dot_S_string, rt_string, rs_string, "  imme"};
							end
				6'b1?1111:  begin   inst_string = "SWS ";
									instruction_out = {inst_string, dot_S_string, rt_string, rs_string, "  imme"};
							end
				6'b0?0100:  begin   inst_string = "BEQ ";
									instruction_out = {inst_string, dot_S_string, rs_string, rt_string, "  imme"};
							end
				6'b0?0111:  begin   inst_string = "BLT ";
									instruction_out = {inst_string, dot_S_string, rs_string, rt_string, "  imme"};
							end
				6'b0?0010:  begin   inst_string = "JMP ";
									instruction_out = {inst_string, dot_S_string, "  j_addr"};
							end
				6'b000011:  begin   inst_string = "CALL";
									instruction_out = {inst_string, "  imme"};
							end
				6'b000110:  begin   inst_string = "RET ";
									instruction_out = {inst_string};
							end
				6'b100001:  begin   inst_string = "EXIT";
									instruction_out = {inst_string, "  warp_id"};
							end
				6'b0?0001:  begin   inst_string = "NOOP";
									instruction_out = {inst_string};
							end
				default :   instruction_out = "Unknown";
			endcase
		end
	endtask

endmodule

module decode8_3 (
	input [7:0] one_hot_code,
	output reg [2:0] binary_code);
	always@(*) begin
		case(one_hot_code)
			8'b0000_0001: binary_code = 3'b000;
			8'b0000_0010: binary_code = 3'b001;
			8'b0000_0100: binary_code = 3'b010;
			8'b0000_1000: binary_code = 3'b011;
			8'b0001_0000: binary_code = 3'b100;
			8'b0010_0000: binary_code = 3'b101;
			8'b0100_0000: binary_code = 3'b110;
			8'b1000_0000: binary_code = 3'b111;
			default : binary_code = 3'bXXX;
		endcase
	end
endmodule



