
module mem_unit
#(
	parameter mem_size = 256,
	parameter shmem_size = 256,
	parameter cache_size = 32,
	localparam addr_width = $clog2(mem_size+shmem_size),
	localparam mem_addr_width = $clog2(mem_size)
)


(
	
	input clk, rst, Instr_valid_OC_MEM, MemRead_OC_MEM, MemWrite_OC_MEM, shared_global_bar_OC_MEM,
	input [7:0] PAM_OC_MEM,
	input [2:0] warp_ID_OC_MEM,
	input [1:0] scb_ID_o_OC_MEM,
	input [255:0] rs_data_OC_MEM, rt_data_OC_MEM,
	input [15:0] offset_OC_MEM,
	input [4:0] reg_addr_OC_MEM,
	input [31:0] Instr_OC_MEM,
	
	
	input Wen_FIO_MEM,
	input [addr_width-1:0] Addr_FIO_MEM,
	input [255:0] Din_FIO_MEM,
	output [255:0] Dout_FIO_MEM,
	
	input Wen_FIO_CLE,
	input [4:0] Din_FIO_CLE,
	output [4:0] FIO_CACHE_LAT_READ,
	input [mem_addr_width-1:0] Addr_FIO_CLE,
	
	output [2:0] WarpID_MEM_CDB,
	output [31:0] Instr_MEM_CDB,
	output neg_feedback_valid_o_MEM_Scb, pos_feedback_valid_o_MEM_Scb, cdb_regwrite_MEM_CDB,
	output [2:0] neg_feedback_warpID_o_MEM_Scb, pos_feedback_warpID_o_MEM_Scb,
	output [1:0] neg_feedback_scbID_o_MEM_Scb, pos_feedback_scbID_o_MEM_Scb,
	output [7:0] pos_feedback_mask_o_MEM_Scb, cdb_write_mask_MEM_CDB,
	output [255:0] cdb_write_data_MEM_CDB,
	output [4:0] cdb_reg_addr_MEM_CDB
	
);
	
	
	
	
	
	reg MemRead_q, MemWrite_q, shared_global_bar_q;
	reg [7:0] PAM_q;
	reg [2:0] warp_ID_q;
	reg [1:0] scb_ID_q;
	reg [255:0] rs_data_q, rt_data_q;
	reg [15:0] offset_q;
	reg [4:0] reg_addr_q;
	reg [31:0] Instr_OC_MEM_q;
	
	wire stage12_MemRead, stage12_MemWrite, stage12_shared_global_bar;
	wire [2:0] stage12_warp_ID;
	wire [1:0] stage12_scb_ID;
	wire [7:0] stage12_PAM;
	wire [255:0] stage12_eff_addr;
	wire [255:0] stage12_write_data;
	wire [4:0] stage12_reg_addr;
	wire [26:0] stage12_addr_sel;
	wire [31:0] stage12_Instr;
	
	
	wire stage32_neg_feedback_valid;
	wire [26:0] stage32_neg_feedback_addr;
	
	
	wire stage23_MemRead, stage23_MemWrite, stage23_hit_missbar, stage23_miss_wait, stage23_addr_valid;
	wire [26:0] stage23_mem_addr;
	wire [255:0] stage23_write_data;
	wire [2:0] stage23_warp_ID;
	wire [1:0] stage23_scb_ID;
	wire [7:0] stage23_mem_write_mask;
	wire [23:0] stage23_word_offset;
	wire [4:0] stage23_reg_addr;
	wire [7:0] stage23_thread_mask;
	wire [4:0] stage23_miss_latency;
	wire [31:0] stage23_Instr;
	
	
	
	wire stage34_reg_write, stage34_write_fb_valid;
	wire [2:0] stage34_warp_ID;
	wire [1:0] stage34_scb_ID;
	wire [255:0] stage34_read_data;
	wire [4:0] stage34_reg_addr;
	wire [7:0] stage34_thread_mask;
	wire [23:0] stage34_word_offset;
	wire [31:0] stage34_Instr;
	
	
	
	wire [2:0] stage4_warp_ID;
	
	
	
	assign neg_feedback_valid_o_MEM_Scb = stage32_neg_feedback_valid;
	assign pos_feedback_warpID_o_MEM_Scb = stage4_warp_ID;
	assign WarpID_MEM_CDB = stage4_warp_ID;
	
	mem_stage1 stage1_inst(.MemRead(MemRead_q), .MemWrite(MemWrite_q), .shared_global_bar(shared_global_bar_q),
							.warp_ID(warp_ID_q), .scb_ID(scb_ID_q), .PAM(PAM_q), .reg_addr(reg_addr_q), .rs_reg_data(rs_data_q), .offset(offset_q), 
			       .write_data(rt_data_q), .Instr(Instr_OC_MEM_q), 
	
	
							.MemRead_o(stage12_MemRead), .MemWrite_o(stage12_MemWrite), .shared_global_bar_o(stage12_shared_global_bar), 
							.warp_ID_o(stage12_warp_ID), .scb_ID_o(stage12_scb_ID), .PAM_o(stage12_PAM), .eff_addr_o(stage12_eff_addr), 
							.write_data_o(stage12_write_data), .reg_addr_o(stage12_reg_addr), .addr_sel_o(stage12_addr_sel), .Instr_o(stage12_Instr)
	);
	
	
	mem_stage2 #(.mem_size(mem_size), .cache_size(cache_size), .addr_width(mem_addr_width))
			stage2_inst(
	
							.clk(clk), .resetb(rst), .MemRead(stage12_MemRead), .MemWrite(stage12_MemWrite), 
							.shared_global_bar(stage12_shared_global_bar), .mshr_neg_feedback_valid(stage32_neg_feedback_valid),
							.warp_ID(stage12_warp_ID),
							.scb_ID(stage12_scb_ID),
							.PAM(stage12_PAM),
							.eff_addr(stage12_eff_addr), .write_data(stage12_write_data),
							.reg_addr(stage12_reg_addr),
							.addr_sel(stage12_addr_sel), .mshr_neg_feedback_addr(stage32_neg_feedback_addr), .Instr(stage12_Instr), 
							
							.Wen_FIO_CLE(Wen_FIO_CLE), .Din_FIO_CLE(Din_FIO_CLE),
							.Addr_FIO_CLE(Addr_FIO_CLE), .FIO_CACHE_LAT_READ(FIO_CACHE_LAT_READ),
							
							
							.MemRead_o(stage23_MemRead), .MemWrite_o(stage23_MemWrite), .hit_missbar_o(stage23_hit_missbar), 
							.miss_wait_o(stage23_miss_wait), .addr_valid_o(stage23_addr_valid),
							.mem_addr_o(stage23_mem_addr),
							.write_data_o(stage23_write_data),
							.warp_ID_o(stage23_warp_ID),
							.scb_ID_o(stage23_scb_ID),
							.mem_write_mask_o(stage23_mem_write_mask),
							.word_offset_o(stage23_word_offset),
							.reg_addr_o(stage23_reg_addr),
							.thread_mask_o(stage23_thread_mask),
							.miss_latency_o(stage23_miss_latency), 
							.Instr_o(stage23_Instr)
	
	);
	
	
	mem_stage3 #(.mem_size(mem_size), .shmem_size(shmem_size))
				stage3_inst(
							.clk(clk), .resetb(rst), .MemRead(stage23_MemRead), .MemWrite(stage23_MemWrite), .hit_missbar(stage23_hit_missbar), 
							.miss_wait(stage23_miss_wait), .addr_valid(stage23_addr_valid),
							.mem_addr(stage23_mem_addr),
							.write_data(stage23_write_data),
							.warp_ID(stage23_warp_ID),
							.scb_ID(stage23_scb_ID),
							.mem_write_mask(stage23_mem_write_mask),
							.word_offset(stage23_word_offset),
							.reg_addr(stage23_reg_addr),
							.thread_mask(stage23_thread_mask),
							.miss_latency(stage23_miss_latency), .Instr(stage23_Instr), 
							
							.Wen_FIO_MEM(Wen_FIO_MEM),
							.Addr_FIO_MEM(Addr_FIO_MEM),
							.Din_FIO_MEM(Din_FIO_MEM),
							.Dout_FIO_MEM(Dout_FIO_MEM),
							
							
							.reg_write_o(stage34_reg_write), .write_fb_valid_o(stage34_write_fb_valid),
							.warp_ID_o(stage34_warp_ID),
							.scb_ID_o(stage34_scb_ID),
							.read_data_o(stage34_read_data),
							.reg_addr_o(stage34_reg_addr),
							.thread_mask_o(stage34_thread_mask),
							.word_offset_o(stage34_word_offset),
							.Instr_o(stage34_Instr),
							
							.mshr_neg_feedback_addr_o(stage32_neg_feedback_addr),
							.mshr_neg_feedback_valid_o(stage32_neg_feedback_valid),
							.mshr_neg_feedback_warpID_o(neg_feedback_warpID_o_MEM_Scb),
							.mshr_neg_feedback_scbID_o(neg_feedback_scbID_o_MEM_Scb)
	);
	
	
	
	mem_stage4 stage4_inst(
							.reg_write(stage34_reg_write), .write_fb_valid(stage34_write_fb_valid),
							.warp_ID(stage34_warp_ID),
							.scb_ID(stage34_scb_ID),
							.read_data(stage34_read_data),
							.reg_addr(stage34_reg_addr),
							.thread_mask(stage34_thread_mask),
							.word_offset(stage34_word_offset),
							.Instr(stage34_Instr), 
							
							
							
							.reg_write_o(cdb_regwrite_MEM_CDB),
							.reg_addr_o(cdb_reg_addr_MEM_CDB),
							.thread_mask_o(cdb_write_mask_MEM_CDB),
							.reg_write_data_o(cdb_write_data_MEM_CDB), 
							.Instr_o(Instr_MEM_CDB),
							
							
							.pos_feedback_mask_o(pos_feedback_mask_o_MEM_Scb),
							.pos_feedback_valid_o(pos_feedback_valid_o_MEM_Scb),
							.pos_feedback_warpID_o(stage4_warp_ID),
							.pos_feedback_scbID_o(pos_feedback_scbID_o_MEM_Scb)
	);
	
	
	
	always@(posedge clk)
	begin
		if(Instr_valid_OC_MEM)
		begin
			shared_global_bar_q		<=	shared_global_bar_OC_MEM;
			PAM_q					<=	PAM_OC_MEM;
			warp_ID_q				<=	warp_ID_OC_MEM;
			scb_ID_q				<=	scb_ID_o_OC_MEM;
			rs_data_q				<=	rs_data_OC_MEM;
			rt_data_q				<=	rt_data_OC_MEM;
			offset_q				<=	offset_OC_MEM;
			reg_addr_q				<=	reg_addr_OC_MEM;
			Instr_OC_MEM_q				<=	Instr_OC_MEM;
			
		end
	end
	
	
	always@(posedge clk, negedge rst)
	begin
		if(!rst)
		begin
			MemRead_q	<=	1'b0;
			MemWrite_q	<=	1'b0;
		end
		else
		begin
		
			MemRead_q	<=	1'b0;
			MemWrite_q	<=	1'b0;
			
			if(Instr_valid_OC_MEM)
			begin
				MemRead_q 				<= 	MemRead_OC_MEM;
				MemWrite_q				<=	MemWrite_OC_MEM;
			end
		end
		
	end
	
	
	
	
	
endmodule
