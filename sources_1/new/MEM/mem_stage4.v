module mem_stage4(
	
	
	input clk, resetb, reg_write, write_fb_valid,
	input [2:0] warp_ID,
	input [1:0] scb_ID,
	input [255:0] read_data,
	input [4:0] reg_addr,
	input [7:0] thread_mask,
	input [23:0] word_offset,
	
	
	
	output reg reg_write_o,
	output reg [4:0] reg_addr_o,
	output reg [7:0] thread_mask_o,
	output reg [255:0] reg_write_data_o,
	
	
	output reg [7:0] pos_feedback_mask_o,
	output reg pos_feedback_valid_o,
	output reg [2:0] pos_feedback_warpID_o,
	output reg [1:0] pos_feedback_scbID_o
);
	
	
	wire [31:0] read_data_int [7:0];
	wire [2:0] word_offset_int [7:0];
	
	reg [31:0] reg_write_data_int [7:0];
	
	integer i;
	
	
	
	assign read_data_int[0] = read_data[31:0];
	assign read_data_int[1] = read_data[63:32];
	assign read_data_int[2] = read_data[95:64];
	assign read_data_int[3] = read_data[127:96];
	assign read_data_int[4] = read_data[159:128];
	assign read_data_int[5] = read_data[191:160];
	assign read_data_int[6] = read_data[223:192];
	assign read_data_int[7] = read_data[255:224];
	
	
	assign word_offset_int[0] = word_offset[2:0];
	assign word_offset_int[1] = word_offset[5:3];
	assign word_offset_int[2] = word_offset[8:6];
	assign word_offset_int[3] = word_offset[11:9];
	assign word_offset_int[4] = word_offset[14:12];
	assign word_offset_int[5] = word_offset[17:15];
	assign word_offset_int[6] = word_offset[20:18];
	assign word_offset_int[7] = word_offset[23:21];
	
	
	
	
	
	
	always@(*)
	begin
	    
		for(i=0; i<8; i=i+1)
			reg_write_data_int[i] = read_data_int[word_offset_int[i]];
			
		reg_write_data_o = {reg_write_data_int[7], reg_write_data_int[6], reg_write_data_int[5], reg_write_data_int[4], reg_write_data_int[3], reg_write_data_int[2], reg_write_data_int[1], reg_write_data_int[0]};
		
		
		reg_write_o		=	reg_write;
		reg_addr_o		=	reg_addr;
		thread_mask_o	=	thread_mask;
		
		
		pos_feedback_warpID_o		=	warp_ID;
		pos_feedback_scbID_o		=	scb_ID;
		pos_feedback_valid_o		=	(reg_write || write_fb_valid);
		pos_feedback_mask_o			=	thread_mask;
		
	end
	
	
	
endmodule