module mem_unit(clk, resetb, Instr_valid, MemRead, MemWrite, shared_global_bar, PAM, rs_data, offset, rt_data, reg_addr, neg_feedback_valid_o, neg_feedback_warpID_o, neg_feedback_scbID_o, pos_feedback_valid_o, pos_feedback_warpID_o, pos_feedback_scbID_o, pos_feedback_PAM_o, cdb_write_data, cdb_write_mask, cdb_reg_addr, cdb_regwrite)
	
	input clk, resetb, Instr_valid, MemRead, MemWrite, shared_global_bar;
	input [7:0] PAM;
	input [255:0] rs_data, rt_data;
	input [7:0] offset;
	input [4:0] reg_addr;
	
	output neg_feedback_valid_o, pos_feedback_valid_o, cdb_regwrite;
	output [2:0] neg_feedback_warpID_o, pos_feedback_warpID_o;
	output [1:0] neg_feedback_scbID_o, pos_feedback_scbID_o;
	output [7:0] pos_feedback_PAM_o, cdb_write_mask;
	output [255:0] cdb_write_data;
	output [4:0] cdb_reg_addr;
	
	
endmodule