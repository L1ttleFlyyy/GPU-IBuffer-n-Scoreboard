module mem_stage1(
	
	input clk, resetb, MemRead, MemWrite, shared_global_bar,
	input [2:0] warp_ID,
	input [1:0] scb_ID,
	input [7:0] PAM,
	input [4:0] reg_addr,
	input [255:0] rs_reg_data,
	input [15:0] offset,
	input [255:0] write_data,
	
	
	output MemRead_o, MemWrite_o, shared_global_bar_o,
	output [2:0] warp_ID_o,
	output [1:0] scb_ID_o,
	output [7:0] PAM_o,
	output [255:0] eff_addr_o, write_data_o,
	output [4:0] reg_addr_o,
	output [26:0] addr_sel_o
);
	
	
	
	reg [31:0] eff_addr [7:0];
	reg [2:0] thread_select;
	reg [26:0] addr_sel;
	
	integer i;
	
	
	always@(rs_reg_data, offset)
	begin
	
		eff_addr[0] 	= 	rs_reg_data[31:0] 		+ 	{{16{offset[15]}},offset};
		eff_addr[1] 	= 	rs_reg_data[63:32] 		+ 	{{16{offset[15]}},offset};
		eff_addr[2] 	= 	rs_reg_data[95:64] 		+ 	{{16{offset[15]}},offset};
		eff_addr[3] 	= 	rs_reg_data[127:96] 	+ 	{{16{offset[15]}},offset};
		eff_addr[4] 	= 	rs_reg_data[159:128] 	+ 	{{16{offset[15]}},offset};
		eff_addr[5] 	= 	rs_reg_data[191:160] 	+ 	{{16{offset[15]}},offset};
		eff_addr[6] 	= 	rs_reg_data[223:192] 	+ 	{{16{offset[15]}},offset};
		eff_addr[7] 	= 	rs_reg_data[255:224] 	+ 	{{16{offset[15]}},offset};
		
	end
	
	always@(PAM or eff_addr[0] or eff_addr[1] or eff_addr[2] or eff_addr[3] or eff_addr[4] or eff_addr[5] or eff_addr[6] or eff_addr[7])
	begin
		for(i=7; i>=0; i=i-1)
		begin
			if(PAM[i])
				thread_select = i;
		end
		
		addr_sel = eff_addr[thread_select][31:5];
		
	end
	
	
		
		
			
	assign eff_addr_o[31:0] 		= 	eff_addr[0];
	assign eff_addr_o[63:32] 		= 	eff_addr[1];
	assign eff_addr_o[95:64] 		= 	eff_addr[2];
	assign eff_addr_o[127:96] 		= 	eff_addr[3];
	assign eff_addr_o[159:128] 		= 	eff_addr[4];
	assign eff_addr_o[191:160] 		= 	eff_addr[5];
	assign eff_addr_o[223:192] 		= 	eff_addr[6];
	assign eff_addr_o[255:224] 		= 	eff_addr[7];
	
	
	
	assign MemRead_o 			=	MemRead;
	assign MemWrite_o 			=	MemWrite;
	assign shared_global_bar_o	=	shared_global_bar;
	assign warp_ID_o			=	warp_ID;
	assign scb_ID_o				=	scb_ID;
	assign PAM_o				=	PAM;
	assign write_data_o			=	write_data;
	assign reg_addr_o			=	reg_addr;
	assign addr_sel_o			=	addr_sel;
			
	
	
	
endmodule