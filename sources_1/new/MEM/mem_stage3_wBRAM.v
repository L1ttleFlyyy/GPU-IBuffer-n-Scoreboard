`include "Inferable_BRAM.v"

module mem_stage3
#(
	parameter mem_size = 256,
	parameter shmem_size = 256,
	localparam addr_width = $clog2(mem_size+shmem_size)
)
(
	
	
	
	input clk, resetb, MemRead, MemWrite, hit_missbar, miss_wait, addr_valid,
	input [26:0] mem_addr,
	input [255:0] write_data,
	input [2:0] warp_ID,
	input [1:0] scb_ID,
	input [7:0] mem_write_mask,
	input [23:0] word_offset,
	input [4:0] reg_addr,
	input [7:0] thread_mask,
	input [4:0] miss_latency,
	
	input FIFO_MEMWRITE,
	input [255:0] FIFO_WRITE_DATA,
	input [addr_width-1:0] FIFO_ADDR,
	
	
	
	
	
	output reg reg_write_o, write_fb_valid_o,
	output reg [2:0] warp_ID_o,
	output reg [1:0] scb_ID_o,
	output reg [255:0] read_data_o,
	output reg [4:0] reg_addr_o,
	output reg [7:0] thread_mask_o,
	output reg [23:0] word_offset_o,
	
	output [26:0] mshr_neg_feedback_addr_o,
	output mshr_neg_feedback_valid_o,
	output [2:0] mshr_neg_feedback_warpID_o,
	output [1:0] mshr_neg_feedback_scbID_o
	
);
	
	
	
	
	
	
	
	
	wire [31:0] read_data [7:0];
	wire [4:0] miss_latency_int;
	wire [255:0] write_data_int;
	wire [addr_width-1:0] mem_addr_int;
	
	
	reg MemRead_R, MemWrite_R;
	reg [23:0] word_offset_R;
	reg [4:0] reg_addr_R;
	reg [7:0] thread_mask_R;
	reg [2:0] warp_ID_R;
	reg [1:0] scb_ID_R;
	
	

	integer data_file;
	integer scan_return;
	integer i, x;
	
	assign write_data_int	=	FIFO_MEMWRITE? FIFO_WRITE_DATA : write_data;
	assign mem_addr_int		=	FIFO_MEMWRITE? FIFO_ADDR : mem_addr[addr_width-1:0];
	
	
	
	mshr_fifo mf_inst(.clk(clk),.resetb(resetb), .cle_hit_missbar(hit_missbar), .scbID(scb_ID), .warpID(warp_ID), .cle_addr(addr_sel),
						.cle_latency(miss_latency_int), .addr_valid(addr_valid),.neg_feedback_scbID(mshr_neg_feedback_scbID_o), 
						.neg_feedback_warpID(mshr_neg_feedback_warpID_o), .neg_feedback_addr(mshr_neg_feedback_addr_o), 
						.neg_feedback_valid(mshr_neg_feedback_valid_o));
						
	
	// DATA CACHE INSTANTIATION
	
	
	Inferable_BRAM #(.OREG(0), .DATA(32), .ADDR(addr_width))
					D_cache0 (.a_clk(clk), .a_wr(0), .a_addr(mem_addr[addr_width-1:0]), .a_din(0), .a_dout(read_data[0]), 
								 .b_clk(clk), .b_wr(MemWrite && mem_write_mask[0] || FIFO_MEMWRITE), .b_addr(mem_addr_int), 
								 .b_din(write_data_int[31:0]), .b_dout());
								 
	Inferable_BRAM #(.OREG(0), .DATA(32), .ADDR(addr_width))
					D_cache1 (.a_clk(clk), .a_wr(0), .a_addr(mem_addr[addr_width-1:0]), .a_din(0), .a_dout(read_data[1]), 
								 .b_clk(clk), .b_wr(MemWrite && mem_write_mask[1] || FIFO_MEMWRITE), .b_addr(mem_addr_int), 
								 .b_din(write_data_int[63:32]), .b_dout());
								 
	Inferable_BRAM #(.OREG(0), .DATA(32), .ADDR(addr_width))
					D_cache2 (.a_clk(clk), .a_wr(0), .a_addr(mem_addr[addr_width-1:0]), .a_din(0), .a_dout(read_data[2]), 
								 .b_clk(clk), .b_wr(MemWrite && mem_write_mask[2] || FIFO_MEMWRITE), .b_addr(mem_addr_int), 
								 .b_din(write_data_int[95:64]), .b_dout());
								 
	Inferable_BRAM #(.OREG(0), .DATA(32), .ADDR(addr_width))
					D_cache3 (.a_clk(clk), .a_wr(0), .a_addr(mem_addr[addr_width-1:0]), .a_din(0), .a_dout(read_data[3]), 
								 .b_clk(clk), .b_wr(MemWrite && mem_write_mask[3] || FIFO_MEMWRITE), .b_addr(mem_addr_int), 
								 .b_din(write_data_int[127:96]), .b_dout());
								 
	Inferable_BRAM #(.OREG(0), .DATA(32), .ADDR(addr_width))
					D_cache4 (.a_clk(clk), .a_wr(0), .a_addr(mem_addr[addr_width-1:0]), .a_din(0), .a_dout(read_data[4]), 
								 .b_clk(clk), .b_wr(MemWrite && mem_write_mask[4] || FIFO_MEMWRITE), .b_addr(mem_addr_int), 
								 .b_din(write_data_int[159:128]), .b_dout());
								 
	Inferable_BRAM #(.OREG(0), .DATA(32), .ADDR(addr_width))
					D_cache5 (.a_clk(clk), .a_wr(0), .a_addr(mem_addr[addr_width-1:0]), .a_din(0), .a_dout(read_data[5]), 
								 .b_clk(clk), .b_wr(MemWrite && mem_write_mask[5] || FIFO_MEMWRITE), .b_addr(mem_addr_int), 
								 .b_din(write_data_int[191:160]), .b_dout());
								 
	Inferable_BRAM #(.OREG(0), .DATA(32), .ADDR(addr_width))
					D_cache6 (.a_clk(clk), .a_wr(0), .a_addr(mem_addr[addr_width-1:0]), .a_din(0), .a_dout(read_data[6]), 
								 .b_clk(clk), .b_wr(MemWrite && mem_write_mask[6] || FIFO_MEMWRITE), .b_addr(mem_addr_int), 
								 .b_din(write_data_int[223:192]), .b_dout());
								 
	Inferable_BRAM #(.OREG(0), .DATA(32), .ADDR(addr_width))
					D_cache7 (.a_clk(clk), .a_wr(0), .a_addr(mem_addr[addr_width-1:0]), .a_din(0), .a_dout(read_data[7]), 
								 .b_clk(clk), .b_wr(MemWrite && mem_write_mask[7] || FIFO_MEMWRITE), .b_addr(mem_addr_int), 
								 .b_din(write_data_int[255:224]), .b_dout());
	
	
	
	assign miss_latency_int = miss_wait? 1'b1 : miss_latency;
	
	
	
	
	
	
	always@(posedge clk, negedge resetb)
	begin
		if(!resetb)
		begin
			reg_write_o <= 0;
		end
		else
		begin
			
			
			if(MemRead)
			    read_data_o <= {read_data[7], read_data[6], read_data[5], read_data[4], read_data[3], read_data[2], read_data[1], read_data[0]};
			
			
			//INPUT REG
			
			
			MemRead_R		<=	MemRead;
			MemWrite_R		<=	MemWrite;
			word_offset_R	<=	word_offset;
			reg_addr_R		<=	reg_addr;
			thread_mask_R	<=	thread_mask;
			warp_ID_R		<=	warp_ID;
			scb_ID_R		<=	scb_ID;
			
			
			
			//OUTPUT REG
			
			reg_write_o 		<= 	MemRead_R;
			write_fb_valid_o	<=	MemWrite_R;
			warp_ID_o 			<= 	warp_ID_R;
			scb_ID_o 			<= 	scb_ID_R;
			reg_addr_o 			<= 	reg_addr_R;
			thread_mask_o 		<= 	thread_mask_R;
			word_offset_o 		<= 	word_offset_R;
			
			
		end
	end
	
	
endmodule