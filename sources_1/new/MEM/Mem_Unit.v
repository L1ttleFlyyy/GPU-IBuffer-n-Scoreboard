module mem_unit(clk, rst, Instr_valid, MemRead, MemWrite, shared_global_bar, PAM, rs_data, offset, rt_data, reg_addr, neg_feedback_valid_o, neg_feedback_warpID_o, neg_feedback_scbID_o, pos_feedback_valid_o, pos_feedback_warpID_o, pos_feedback_scbID_o, pos_feedback_PAM_o, cdb_write_data, cdb_write_mask, cdb_reg_addr, cdb_regwrite)
	
	// FIXME: interface with OC
	input clk, rst, Instr_valid, MemRead_OC, MemWrite_OC, Shared_Globalbar_OC;
	input [7:0] PAM_OC;
	input [255:0] rs_data_OC, rt_data_OC;
	input [7:0] offset;
	input [4:0] reg_addr;
	
	output ZeroFB_Valid_MEM_IB, PosFB_Valid_MEM_IB, RegWrite_MEM_CDB;
	output [2:0] ZeroFB_WarpID_MEM_IB, PosFB_WarpID_MEM_IB;
	// output [1:0] neg_feedback_scbID_o, pos_feedback_scbID_o; no longer need this
	output [7:0] PosFB_MEM_IB, AM_MEM_CDB;
	output [255:0] write_data_MEM_CDB;
	output [4:0] reg_addr_MEM_CDB;
	
	
endmodule