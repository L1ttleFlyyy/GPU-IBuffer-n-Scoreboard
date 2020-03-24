
`timescale 1 ns / 100 ps

module Mem_Unit_tb;
	
	
	reg clk_tb, rst_tb, Instr_valid_OC_MEM_tb, MemRead_OC_MEM_tb, MemWrite_OC_MEM_tb, shared_global_bar_OC_MEM_tb;
	reg [7:0] PAM_OC_MEM_tb;
	reg [2:0] warp_ID_OC_MEM_tb;
	reg [1:0] scb_ID_o_OC_MEM_tb;
	reg [255:0] rs_data_OC_MEM_tb, rt_data_OC_MEM_tb;
	reg [15:0] offset_OC_MEM_tb;
	reg [4:0] reg_addr_OC_MEM_tb;
	
	
	reg FIO_MEMWRITE_tb;
	reg [8:0] FIO_ADDR_tb;
	reg [255:0] FIO_WRITE_DATA_tb;
	
	reg FIO_CACHE_LAT_WRITE_tb;
	reg [4:0] FIO_CACHE_LAT_VALUE_tb;
	reg [7:0] FIO_CACHE_MEM_ADDR_tb;
	
	wire neg_feedback_valid_o_MEM_Scb_tb, pos_feedback_valid_o_MEM_Scb_tb, cdb_regwrite_MEM_CDB_tb;
	wire [2:0] neg_feedback_warpID_o_MEM_Scb_tb, pos_feedback_warpID_o_MEM_Scb_tb;
	wire [1:0] neg_feedback_scbID_o_MEM_Scb_tb, pos_feedback_scbID_o_MEM_Scb_tb;
	wire [7:0] pos_feedback_mask_o_MEM_Scb_tb, cdb_write_mask_MEM_CDB_tb;
	wire [255:0] cdb_write_data_MEM_CDB_tb;
	wire [4:0] cdb_reg_addr_MEM_CDB_tb;

	integer i, clk_count;
	
	
	mem_unit mem_inst_test(
	.clk(clk_tb), 
	.rst(rst_tb), 
	.Instr_valid_OC_MEM(Instr_valid_OC_MEM_tb), 
	.MemRead_OC_MEM(MemRead_OC_MEM_tb), 
	.MemWrite_OC_MEM(MemWrite_OC_MEM_tb), 
	.shared_global_bar_OC_MEM(shared_global_bar_OC_MEM_tb),
	.PAM_OC_MEM(PAM_OC_MEM_tb),
	.warp_ID_OC_MEM(warp_ID_OC_MEM_tb),
	.scb_ID_o_OC_MEM(scb_ID_o_OC_MEM_tb),
	.rs_data_OC_MEM(rs_data_OC_MEM_tb), 
	.rt_data_OC_MEM(rt_data_OC_MEM_tb),
	.offset_OC_MEM(offset_OC_MEM_tb),
	.reg_addr_OC_MEM(reg_addr_OC_MEM_tb),
	
	
	.FIO_MEMWRITE(FIO_MEMWRITE_tb),
	.FIO_ADDR(FIO_ADDR_tb),
	.FIO_WRITE_DATA(FIO_WRITE_DATA_tb),
	
	.FIO_CACHE_LAT_WRITE(FIO_CACHE_LAT_WRITE_tb),
	.FIO_CACHE_LAT_VALUE(FIO_CACHE_LAT_VALUE_tb),
	.FIO_CACHE_MEM_ADDR(FIO_CACHE_MEM_ADDR_tb),
	
	.neg_feedback_valid_o_MEM_Scb(neg_feedback_valid_o_MEM_Scb_tb), 
	.pos_feedback_valid_o_MEM_Scb(pos_feedback_valid_o_MEM_Scb_tb), 
	.cdb_regwrite_MEM_CDB(cdb_regwrite_MEM_CDB_tb),
	.neg_feedback_warpID_o_MEM_Scb(neg_feedback_warpID_o_MEM_Scb_tb), 
	.pos_feedback_warpID_o_MEM_Scb(pos_feedback_warpID_o_MEM_Scb_tb),
	.neg_feedback_scbID_o_MEM_Scb(neg_feedback_scbID_o_MEM_Scb_tb), 
	.pos_feedback_scbID_o_MEM_Scb(pos_feedback_scbID_o_MEM_Scb_tb),
	.pos_feedback_mask_o_MEM_Scb(pos_feedback_mask_o_MEM_Scb_tb), 
	.cdb_write_mask_MEM_CDB(cdb_write_mask_MEM_CDB_tb),
	.cdb_write_data_MEM_CDB(cdb_write_data_MEM_CDB_tb),
	.cdb_reg_addr_MEM_CDB(cdb_reg_addr_MEM_CDB_tb)
	);
	
	
	initial
	begin
		clk_count = 0;
		clk_tb = 1;
		rst_tb = 0;
		Instr_valid_OC_MEM_tb = 0;
		FIO_MEMWRITE_tb = 0;
		FIO_CACHE_LAT_WRITE_tb = 0;
		
		#80
		
		rst_tb = 1;
		
		#1
		
		/*for(i=0; i<256; i=i+1)
		begin
			#40
			FIO_CACHE_LAT_WRITE_tb			=	1;
			FIO_CACHE_LAT_VALUE_tb			=	(i+1)%32;
			FIO_CACHE_MEM_ADDR_tb			=	i;
			
		end*/
		
		/*for(i=0; i<512; i=i+1)
		begin
			#40
			FIO_MEMWRITE_tb			=	1;
			FIO_WRITE_DATA_tb		=	(i+1)%32;
			FIO_ADDR_tb			=	i;
			
		end*/
		
		#40
		
		//Instr_valid_OC_MEM_tb			=	
		MemRead_OC_MEM_tb				=	0;
		MemWrite_OC_MEM_tb				=	1;
		shared_global_bar_OC_MEM_tb		=	1;
		PAM_OC_MEM_tb					=	8'b11110000;
		warp_ID_OC_MEM_tb				=	3'b000;
		scb_ID_o_OC_MEM_tb				=	2'b00;
		rs_data_OC_MEM_tb				=	0;
		rt_data_OC_MEM_tb				=	0;
		offset_OC_MEM_tb				=	16'h0000;
		reg_addr_OC_MEM_tb				=	0;
		FIO_MEMWRITE_tb				=	0;
		FIO_ADDR_tb					=	0;
		FIO_WRITE_DATA_tb				=	0;
		FIO_CACHE_LAT_WRITE_tb			=	0;
		FIO_CACHE_LAT_VALUE_tb			=	0;
		FIO_CACHE_MEM_ADDR_tb			=	0;
		
		#40
		
		//Instr_valid_OC_MEM_tb			=	
		MemRead_OC_MEM_tb				=	1;
		MemWrite_OC_MEM_tb				=	0;
		/*shared_global_bar_OC_MEM_tb		=	
		PAM_OC_MEM_tb					=	
		warp_ID_OC_MEM_tb				=	
		scb_ID_o_OC_MEM_tb				=	
		rs_data_OC_MEM_tb				=	
		rt_data_OC_MEM_tb				=	
		offset_OC_MEM_tb				=	
		reg_addr_OC_MEM_tb				=	
		FIO_MEMWRITE_tb				=	
		FIO_ADDR_tb					=	
		FIO_WRITE_DATA_tb				=	*/
		
		#40
		
		Instr_valid_OC_MEM_tb				=	1;
		MemRead_OC_MEM_tb				=	0;
		MemWrite_OC_MEM_tb				=	1;
		shared_global_bar_OC_MEM_tb			=	0;
		PAM_OC_MEM_tb					=	8'b11111111;
		warp_ID_OC_MEM_tb				=	3'b001;
		scb_ID_o_OC_MEM_tb				=	2'b01;
		rs_data_OC_MEM_tb				=	256'h0000006000000064000000680000006C000000C0000000C4000000C8000000CC;
		rt_data_OC_MEM_tb				=	256'h00000000FFFFFFFF00000000FFFFFFFF44444444AAAAAAAA44444444AAAAAAAA;
		offset_OC_MEM_tb				=	16'h0000;
		reg_addr_OC_MEM_tb				=	0;
		FIO_MEMWRITE_tb					=	0;
		FIO_ADDR_tb					=	0;
		FIO_WRITE_DATA_tb				=	0;
		FIO_CACHE_LAT_WRITE_tb				=	0;
		FIO_CACHE_LAT_VALUE_tb				=	0;
		FIO_CACHE_MEM_ADDR_tb				=	0;
		
		#40
		
		Instr_valid_OC_MEM_tb				=	0;
		
		#320
		
		Instr_valid_OC_MEM_tb				=	1;
		MemRead_OC_MEM_tb				=	0;
		MemWrite_OC_MEM_tb				=	1;
		shared_global_bar_OC_MEM_tb			=	0;
		PAM_OC_MEM_tb					=	8'b11111111;
		warp_ID_OC_MEM_tb				=	3'b010;
		scb_ID_o_OC_MEM_tb				=	2'b01;
		rs_data_OC_MEM_tb				=	256'h0000006000000064000000680000006C000000C0000000C4000000C8000000CC;
		rt_data_OC_MEM_tb				=	256'h00000000FFFFFFFF00000000FFFFFFFF44444444AAAAAAAA44444444AAAAAAAA;
		offset_OC_MEM_tb				=	0;
		reg_addr_OC_MEM_tb				=	0;
		FIO_MEMWRITE_tb					=	0;
		FIO_ADDR_tb					=	0;
		FIO_WRITE_DATA_tb				=	0;
		FIO_CACHE_LAT_WRITE_tb				=	0;
		FIO_CACHE_LAT_VALUE_tb				=	0;
		FIO_CACHE_MEM_ADDR_tb				=	0;
		
		#40
		
		Instr_valid_OC_MEM_tb				=	0;
		
		#160
		
		Instr_valid_OC_MEM_tb				=	1;
		MemRead_OC_MEM_tb				=	0;
		MemWrite_OC_MEM_tb				=	1;
		shared_global_bar_OC_MEM_tb			=	0;
		PAM_OC_MEM_tb					=	8'b11110000;
		warp_ID_OC_MEM_tb				=	3'b011;
		scb_ID_o_OC_MEM_tb				=	2'b01;
		rs_data_OC_MEM_tb				=	256'h0000006000000064000000680000006C000000C0000000C4000000C8000000CC;
		rt_data_OC_MEM_tb				=	256'h00000000FFFFFFFF00000000FFFFFFFF44444444AAAAAAAA44444444AAAAAAAA;
		offset_OC_MEM_tb				=	0;
		reg_addr_OC_MEM_tb				=	0;
		FIO_MEMWRITE_tb					=	0;
		FIO_ADDR_tb					=	0;
		FIO_WRITE_DATA_tb				=	0;
		FIO_CACHE_LAT_WRITE_tb				=	0;
		FIO_CACHE_LAT_VALUE_tb				=	0;
		FIO_CACHE_MEM_ADDR_tb				=	0;
		
		#40
		
		Instr_valid_OC_MEM_tb				=	0;
		
		#200
		
		Instr_valid_OC_MEM_tb				=	1;
		MemRead_OC_MEM_tb				=	0;
		MemWrite_OC_MEM_tb				=	1;
		shared_global_bar_OC_MEM_tb			=	0;
		PAM_OC_MEM_tb					=	8'b11110000;
		warp_ID_OC_MEM_tb				=	3'b100;
		scb_ID_o_OC_MEM_tb				=	2'b01;
		rs_data_OC_MEM_tb				=	256'h0000006000000064000000680000006C000000C0000000C4000000C8000000CC;
		rt_data_OC_MEM_tb				=	256'h00000000FFFFFFFF00000000FFFFFFFF44444444AAAAAAAA44444444AAAAAAAA;
		offset_OC_MEM_tb				=	0;
		reg_addr_OC_MEM_tb				=	0;
		FIO_MEMWRITE_tb					=	0;
		FIO_ADDR_tb					=	0;
		FIO_WRITE_DATA_tb				=	0;
		FIO_CACHE_LAT_WRITE_tb				=	0;
		FIO_CACHE_LAT_VALUE_tb				=	0;
		FIO_CACHE_MEM_ADDR_tb				=	0;
		
		#40
		
		Instr_valid_OC_MEM_tb				=	0;
		
		#40
		
		Instr_valid_OC_MEM_tb				=	1;
		MemRead_OC_MEM_tb				=	1;
		MemWrite_OC_MEM_tb				=	0;
		shared_global_bar_OC_MEM_tb			=	0;
		PAM_OC_MEM_tb					=	8'b11111111;
		warp_ID_OC_MEM_tb				=	3'b000;
		scb_ID_o_OC_MEM_tb				=	2'b01;
		rs_data_OC_MEM_tb				=	256'h0000006000000064000000680000006C000000C0000000C4000000C8000000CC;
		rt_data_OC_MEM_tb				=	0;
		offset_OC_MEM_tb				=	0;
		reg_addr_OC_MEM_tb				=	5'b00011;
		FIO_MEMWRITE_tb					=	0;
		FIO_ADDR_tb					=	0;
		FIO_WRITE_DATA_tb				=	0;
		FIO_CACHE_LAT_WRITE_tb				=	0;
		FIO_CACHE_LAT_VALUE_tb				=	0;
		FIO_CACHE_MEM_ADDR_tb				=	0;
		
		#40
		
		Instr_valid_OC_MEM_tb				=	1;
		MemRead_OC_MEM_tb				=	1;
		MemWrite_OC_MEM_tb				=	0;
		shared_global_bar_OC_MEM_tb			=	0;
		PAM_OC_MEM_tb					=	8'b11110000;
		warp_ID_OC_MEM_tb				=	3'b000;
		scb_ID_o_OC_MEM_tb				=	2'b01;
		rs_data_OC_MEM_tb				=	256'h0000006000000064000000680000006C000000C0000000C4000000C8000000CC;
		rt_data_OC_MEM_tb				=	0;
		offset_OC_MEM_tb				=	0;
		reg_addr_OC_MEM_tb				=	5'b00011;
		FIO_MEMWRITE_tb					=	0;
		FIO_ADDR_tb					=	0;
		FIO_WRITE_DATA_tb				=	0;
		FIO_CACHE_LAT_WRITE_tb				=	0;
		FIO_CACHE_LAT_VALUE_tb				=	0;
		FIO_CACHE_MEM_ADDR_tb				=	0;	
		
		#40
		
		Instr_valid_OC_MEM_tb				=	0;
		
		#200
		
		
		// Shared Mem
		
		
		Instr_valid_OC_MEM_tb				=	1;
		MemRead_OC_MEM_tb				=	0;
		MemWrite_OC_MEM_tb				=	1;
		shared_global_bar_OC_MEM_tb			=	1;
		PAM_OC_MEM_tb					=	8'b11111111;
		warp_ID_OC_MEM_tb				=	3'b001;
		scb_ID_o_OC_MEM_tb				=	2'b01;
		rs_data_OC_MEM_tb				=	256'h0000206000002064000020680000206C000020C0000020C4000020C8000020CC;
		rt_data_OC_MEM_tb				=	256'h00000000FFFFFFFF00000000FFFFFFFF44444444AAAAAAAA44444444AAAAAAAA;
		offset_OC_MEM_tb				=	16'h0000;
		reg_addr_OC_MEM_tb				=	0;
		FIO_MEMWRITE_tb					=	0;
		FIO_ADDR_tb					=	0;
		FIO_WRITE_DATA_tb				=	0;
		FIO_CACHE_LAT_WRITE_tb				=	0;
		FIO_CACHE_LAT_VALUE_tb				=	0;
		FIO_CACHE_MEM_ADDR_tb				=	0;
		
		#40
		
		Instr_valid_OC_MEM_tb				=	0;
		
		#320
		
		Instr_valid_OC_MEM_tb				=	1;
		MemRead_OC_MEM_tb				=	0;
		MemWrite_OC_MEM_tb				=	1;
		shared_global_bar_OC_MEM_tb			=	1;
		PAM_OC_MEM_tb					=	8'b11110000;
		warp_ID_OC_MEM_tb				=	3'b010;
		scb_ID_o_OC_MEM_tb				=	2'b01;
		rs_data_OC_MEM_tb				=	256'h0000206000002064000020680000206C000020C0000020C4000020C8000020CC;
		rt_data_OC_MEM_tb				=	256'h00000000FFFFFFFF00000000FFFFFFFF44444444AAAAAAAA44444444AAAAAAAA;
		offset_OC_MEM_tb				=	0;
		reg_addr_OC_MEM_tb				=	0;
		FIO_MEMWRITE_tb					=	0;
		FIO_ADDR_tb					=	0;
		FIO_WRITE_DATA_tb				=	0;
		FIO_CACHE_LAT_WRITE_tb				=	0;
		FIO_CACHE_LAT_VALUE_tb				=	0;
		FIO_CACHE_MEM_ADDR_tb				=	0;
		
		#40
		
		Instr_valid_OC_MEM_tb				=	0;
		
		#160
		
		Instr_valid_OC_MEM_tb				=	1;
		MemRead_OC_MEM_tb				=	1;
		MemWrite_OC_MEM_tb				=	0;
		shared_global_bar_OC_MEM_tb			=	1;
		PAM_OC_MEM_tb					=	8'b11111111;
		warp_ID_OC_MEM_tb				=	3'b000;
		scb_ID_o_OC_MEM_tb				=	2'b01;
		rs_data_OC_MEM_tb				=	256'h0000206000002064000020680000206C000020C0000020C4000020C8000020CC;
		rt_data_OC_MEM_tb				=	0;
		offset_OC_MEM_tb				=	0;
		reg_addr_OC_MEM_tb				=	5'b00011;
		FIO_MEMWRITE_tb					=	0;
		FIO_ADDR_tb					=	0;
		FIO_WRITE_DATA_tb				=	0;
		FIO_CACHE_LAT_WRITE_tb				=	0;
		FIO_CACHE_LAT_VALUE_tb				=	0;
		FIO_CACHE_MEM_ADDR_tb				=	0;
		
		#40
		
		Instr_valid_OC_MEM_tb				=	1;
		MemRead_OC_MEM_tb				=	1;
		MemWrite_OC_MEM_tb				=	0;
		shared_global_bar_OC_MEM_tb			=	1;
		PAM_OC_MEM_tb					=	8'b11110000;
		warp_ID_OC_MEM_tb				=	3'b000;
		scb_ID_o_OC_MEM_tb				=	2'b01;
		rs_data_OC_MEM_tb				=	256'h0000206000002064000020680000206C000020C0000020C4000020C8000020CC;
		rt_data_OC_MEM_tb				=	0;
		offset_OC_MEM_tb				=	0;
		reg_addr_OC_MEM_tb				=	5'b00011;
		FIO_MEMWRITE_tb					=	0;
		FIO_ADDR_tb					=	0;
		FIO_WRITE_DATA_tb				=	0;
		FIO_CACHE_LAT_WRITE_tb				=	0;
		FIO_CACHE_LAT_VALUE_tb				=	0;
		FIO_CACHE_MEM_ADDR_tb				=	0;	
		
		#40
		
		Instr_valid_OC_MEM_tb				=	0;
		
		#200
		
	/*	#40
		
		Instr_valid_OC_MEM_tb			=	
		MemRead_OC_MEM_tb				=	
		MemWrite_OC_MEM_tb				=	
		shared_global_bar_OC_MEM_tb		=	
		PAM_OC_MEM_tb					=	
		warp_ID_OC_MEM_tb				=	
		scb_ID_o_OC_MEM_tb				=	
		rs_data_OC_MEM_tb				=	
		rt_data_OC_MEM_tb				=	
		offset_OC_MEM_tb				=	
		reg_addr_OC_MEM_tb				=	
		FIO_MEMWRITE_tb				=	
		FIO_ADDR_tb					=	
		FIO_WRITE_DATA_tb				=	
		
		#40
		
		Instr_valid_OC_MEM_tb			=	
		MemRead_OC_MEM_tb				=	
		MemWrite_OC_MEM_tb				=	
		shared_global_bar_OC_MEM_tb		=	
		PAM_OC_MEM_tb					=	
		warp_ID_OC_MEM_tb				=	
		scb_ID_o_OC_MEM_tb				=	
		rs_data_OC_MEM_tb				=	
		rt_data_OC_MEM_tb				=	
		offset_OC_MEM_tb				=	
		reg_addr_OC_MEM_tb				=	
		FIO_MEMWRITE_tb				=	
		FIO_ADDR_tb					=	
		FIO_WRITE_DATA_tb				=	*/
		
		#40
		
		$stop;
		
	end
	
	always
		#20	clk_tb = !clk_tb;
	
	always@(posedge clk_tb)
		clk_count = clk_count+1;
	
endmodule