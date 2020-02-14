`include "mshr_fifo.v"
`include "cache_latency_emulator.v"

module mem_stage2(clk, resetb, warp_ID, scb_ID, thread_select, PAM, MemRead, MemWrite, shared_global_bar, eff_addr, reg_addr, write_data, MemRead_o, MemWrite_o, mem_addr_o, write_data_o, warp_ID_o, reg_write_o, write_mask_o, word_offset_o, reg_addr_o, thread_mask_o, mshr_neg_feedback_valid_o, mshr_neg_feedback_warpID_o, mshr_neg_feedback_scbID_o);
	
	input clk, resetb, MemRead, MemWrite, shared_global_bar;
	input [2:0] warp_ID;
	input [1:0] scb_ID;
	input [7:0] thread_select, PAM;
	input [255:0] eff_addr, write_data;
	input [4:0] reg_addr;
	
	output reg MemRead_o, MemWrite_o, reg_write_o;
	output reg [26:0] mem_addr_o;
	output reg [255:0] write_data_o;
	output reg [2:0] warp_ID_o;
	output reg [7:0] write_mask_o;
	output reg [23:0] word_offset_o;
	output reg [4:0] reg_addr_o;
	output reg [7:0] thread_mask_o;
	output reg mshr_neg_feedback_valid_o;
	output reg [2:0] mshr_neg_feedback_warpID_o;
	output reg [1:0] mshr_neg_feedback_scbID_o;
	
	wire [31:0] eff_addr_int [7:0];
	wire [31:0] write_data_int [7:0], write_data_o_int [7:0];
	wire [4:0] miss_latency;
	wire hit_missbar, mshr_neg_feedback_valid;
	wire [26:0] mshr_neg_feedback_addr;
	wire [2:0] mshr_neg_feedback_warpID;
	wire [1:0] mshr_neg_feedback_scbID;
	
	reg [26:0] addr_sel;
	reg [7:0] thread_mask;
	reg [7:0] write_mask_int;
	reg [2:0] thread_grant [7:0];
	
	cache_latency_emulator cle_inst(.addr(addr_sel), addr_valid(!shared_global_bar && (MemRead || MemWrite)), .latency(miss_latency), .hit_missbar(hit_missbar), .addr_response(mshr_neg_feedback_addr), .addr_response_valid(mshr_neg_feedback_valid), .clk(clk), .resetb(resetb));
	
	mshr_fifo mf_inst(.clk(clk),.resetb(resetb), .cle_hit_missbar(hit_missbar), .scbID(scb_ID), .warpID(warp_ID), .cle_addr(addr_sel), .cle_latency(miss_latency), .addr_valid(!shared_global_bar && (MemRead || MemWrite)),.neg_feedback_scbID(mshr_neg_feedback_scbID), .neg_feedback_warpID(mshr_neg_feedback_warpID), .neg_feedback_addr(mshr_neg_feedback_addr), .neg_feedback_valid(mshr_neg_feedback_valid));
	
	
	assign eff_addr_int[0] = eff_addr[31:0];
	assign eff_addr_int[1] = eff_addr[63:32];
	assign eff_addr_int[2] = eff_addr[95:64];
	assign eff_addr_int[3] = eff_addr[127:96];
	assign eff_addr_int[4] = eff_addr[159:128];
	assign eff_addr_int[5] = eff_addr[191:160];
	assign eff_addr_int[6] = eff_addr[223:192];
	assign eff_addr_int[7] = eff_addr[255:224];
	
	assign write_data_int[0] = write_data[31:0];
	assign write_data_int[1] = write_data[63:32];
	assign write_data_int[2] = write_data[95:64];
	assign write_data_int[3] = write_data[127:96];
	assign write_data_int[4] = write_data[159:128];
	assign write_data_int[5] = write_data[191:160];
	assign write_data_int[6] = write_data[223:192];
	assign write_data_int[7] = write_data[255:224];
	
	
	// Selection of thread using thread_select
	
	integer i, j;
	always@(*)
	begin
		for(i=0; i<8; i=i+1)
		begin
			if(thread_select[i])
				addr_sel = eff_addr_int[i][31:5];
		end
	end
	
	
	
	
	always@(*)
	begin
	
		//Thread Mask Generator
		
		
		for(i=0; i<8; i=i+1)
		begin
			if(PAM[i] && (eff_addr_int[i][31:5]==addr_sel))
				thread_mask[i] = 1'b1;
			else
				thread_mask[i] = 1'b0;
		end
		
		
		
		//SW coalescing unit part 1
		
		
		for(j=0;j<8;j=j+1)
		begin
			write_mask_int[j] = 1'b0;
			thread_grant[j] = 3'b000;
			for(i=7; i>=0; i=i-1)
			begin
				
				if(thread_mask[i] && j==eff_addr_int[i][4:2])
				begin
					write_mask_int[j] = 1'b1;
					thread_grant[j] = i;
				end
			end
		end
		
		
		//SW coalescing unit part 2
		
		for(j=0;j<8;j=j+1)
		begin
			case(thread_grant[j])
				3'b000: write_data_o_int[j] <= write_data_int[0];
				3'b001: write_data_o_int[j] <= write_data_int[1];
				3'b010: write_data_o_int[j] <= write_data_int[2];
				3'b011: write_data_o_int[j] <= write_data_int[3];
				3'b100: write_data_o_int[j] <= write_data_int[4];
				3'b101: write_data_o_int[j] <= write_data_int[5];
				3'b110: write_data_o_int[j] <= write_data_int[6];
				3'b111: write_data_o_int[j] <= write_data_int[7];
			endcase
		end
		
		
		
	end
	
	always@(posedge clk, negedge resetb)
	begin
		if(~resetb)
		begin
			MemRead_o <= 1'b0;
			MemWrite_o <= 1'b0;
			reg_write_o <= 1'b0;
			
		end
		else
		begin
			write_data_o <= write_data_o_int;
			
			write_mask_o <= write_mask_int;
			
			MemRead_o <= MemRead && (hit_missbar || shared_global_bar);
			MemWrite_o <= MemWrite && (hit_missbar || shared_global_bar);
			reg_write_o <= MemRead && (hit_missbar || shared_global_bar);
			mem_addr_o <= addr_sel;
			warp_ID_o <= warp_ID;
			word_offset_o <= {eff_addr_int[7][4:2], eff_addr_int[6][4:2], eff_addr_int[5][4:2], eff_addr_int[4][4:2], eff_addr_int[3][4:2], eff_addr_int[2][4:2], eff_addr_int[1][4:2], eff_addr_int[0][4:2]};
			thread_mask_o <= thread_mask;
		end
	end
	
	
	
	

endmodule