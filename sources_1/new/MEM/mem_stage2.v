

module mem_stage2
#(
	parameter mem_size = 256,
	parameter cache_size = 32,
	parameter addr_width = 8
)
(
	
	input clk, resetb, MemRead, MemWrite, shared_global_bar, mshr_neg_feedback_valid,
	input [2:0] warp_ID,
	input [1:0] scb_ID,
	input [7:0] PAM,
	input [255:0] eff_addr, write_data,
	input [4:0] reg_addr,
	input [26:0] addr_sel, mshr_neg_feedback_addr,
	input [31:0] Instr,
	
	input Wen_FIO_CLE,
	output [4:0] FIO_CACHE_LAT_READ,
	input [4:0] Din_FIO_CLE,
	input [addr_width-1:0] Addr_FIO_CLE,
	
	output reg addr_valid_o,
	output MemRead_o, MemWrite_o, hit_missbar_o, miss_wait_o,
	output [26:0] mem_addr_o,
	output [255:0] write_data_o,
	output [2:0] warp_ID_o,
	output [1:0] scb_ID_o,
	output [7:0] mem_write_mask_o,
	output [23:0] word_offset_o,
	output [4:0] reg_addr_o,
	output [7:0] thread_mask_o,
	output [4:0] miss_latency_o,
	output reg [31:0] Instr_o
);
	
	
	
	
	
	
	wire [4:0] miss_latency;
	wire hit_missbar, miss_wait;
	wire cache_addr_valid;
	
	
	reg [31:0] eff_addr_int [7:0];
	reg [31:0] write_data_int [7:0];
	reg MemRead_R, MemWrite_R, shared_global_bar_R;
	reg [2:0] warp_ID_R;
	reg [1:0] scb_ID_R;
	reg [7:0] PAM_R;
	reg [4:0] reg_addr_R;
	reg [26:0] addr_sel_R;
	
	
	reg [31:0] write_data_o_int [7:0];
	reg [7:0] thread_mask;
	reg [7:0] mem_write_mask_int;
	reg [2:0] thread_grant [7:0];
	
	
	integer i, j;
	
	cache_latency_emulator #(.mem_size(mem_size), .cache_size(cache_size), .addr_width(addr_width))
							cle_inst (.addr(addr_sel), .addr_valid(cache_addr_valid), .latency(miss_latency), .hit_missbar(hit_missbar), 
									.addr_response(mshr_neg_feedback_addr), .addr_response_valid(mshr_neg_feedback_valid), .clk(clk), 
									.resetb(resetb), .miss_wait(miss_wait),
									.Wen_FIO_CLE(Wen_FIO_CLE), .Din_FIO_CLE(Din_FIO_CLE), 
									.FIO_CACHE_LAT_READ(FIO_CACHE_LAT_READ),
									.Addr_FIO_CLE(Addr_FIO_CLE));
	
	
	
	assign cache_addr_valid = !shared_global_bar && (MemRead || MemWrite);
	
	
	
	
	
	always@(*)
	begin
	
		//Thread Mask Generator
		
		
		for(i=0; i<8; i=i+1)
		begin
			if(PAM_R[i] && (eff_addr_int[i][31:5]==addr_sel_R))
				thread_mask[i] = 1'b1;
			else
				thread_mask[i] = 1'b0;
		end
		
		
		
		//SW coalescing unit part 1
		
		
		for(j=0;j<8;j=j+1)
		begin
			mem_write_mask_int[j] = 1'b0;
			thread_grant[j] = 3'b000;
			for(i=7; i>=0; i=i-1)
			begin
				
				if(thread_mask[i] && j==eff_addr_int[i][4:2])
				begin
					mem_write_mask_int[j] = 1'b1;
					thread_grant[j] = i;
				end
			end
		end
		
		
		//SW coalescing unit part 2
		
		for(j=0;j<8;j=j+1)
		begin
			case(thread_grant[j])
				3'b000: write_data_o_int[j] = write_data_int[0];
				3'b001: write_data_o_int[j] = write_data_int[1];
				3'b010: write_data_o_int[j] = write_data_int[2];
				3'b011: write_data_o_int[j] = write_data_int[3];
				3'b100: write_data_o_int[j] = write_data_int[4];
				3'b101: write_data_o_int[j] = write_data_int[5];
				3'b110: write_data_o_int[j] = write_data_int[6];
				3'b111: write_data_o_int[j] = write_data_int[7];
			endcase
		end
		
		
		
	end
	
	always@(posedge clk, negedge resetb)
	begin
		if(~resetb)
		begin
			MemRead_R <= 1'b0;
			MemWrite_R <= 1'b0;
			eff_addr_int[0]	<= {32{1'bx}};
			eff_addr_int[1] <= {32{1'bx}};
			eff_addr_int[2] <= {32{1'bx}};
			eff_addr_int[3] <= {32{1'bx}};
			eff_addr_int[4] <= {32{1'bx}};
			eff_addr_int[5] <= {32{1'bx}};
			eff_addr_int[6] <= {32{1'bx}};
			eff_addr_int[7] <= {32{1'bx}};
			write_data_int[0] <= {32{1'bx}};
			write_data_int[1] <= {32{1'bx}};
			write_data_int[2] <= {32{1'bx}};
			write_data_int[3] <= {32{1'bx}};
			write_data_int[4] <= {32{1'bx}};
			write_data_int[5] <= {32{1'bx}};
			write_data_int[6] <= {32{1'bx}};
			write_data_int[7] <= {32{1'bx}};
			shared_global_bar_R <= 1'bx;
			warp_ID_R			<=	{3{1'bx}};
			scb_ID_R			<=	{2{1'bx}};
			PAM_R				<=	{8{1'bx}};
			reg_addr_R			<=	{5{1'bx}};
			addr_sel_R			<=	{27{1'bx}};
			addr_valid_o		<=	1'bx;
			Instr_o				<=	{32{1'bx}};
		end
		else
		begin
			
			//INPUT REG
			
			eff_addr_int[0]	<= eff_addr[31:0];
			eff_addr_int[1] <= eff_addr[63:32];
			eff_addr_int[2] <= eff_addr[95:64];
			eff_addr_int[3] <= eff_addr[127:96];
			eff_addr_int[4] <= eff_addr[159:128];
			eff_addr_int[5] <= eff_addr[191:160];
			eff_addr_int[6] <= eff_addr[223:192];
			eff_addr_int[7] <= eff_addr[255:224];
			
			write_data_int[0] <= write_data[31:0];
			write_data_int[1] <= write_data[63:32];
			write_data_int[2] <= write_data[95:64];
			write_data_int[3] <= write_data[127:96];
			write_data_int[4] <= write_data[159:128];
			write_data_int[5] <= write_data[191:160];
			write_data_int[6] <= write_data[223:192];
			write_data_int[7] <= write_data[255:224];
			
			MemRead_R			<=	MemRead;
			MemWrite_R			<=	MemWrite;
			shared_global_bar_R	<=	shared_global_bar;
			warp_ID_R			<=	warp_ID;
			scb_ID_R			<=	scb_ID;
			PAM_R				<=	PAM;
			reg_addr_R			<=	reg_addr;
			addr_sel_R			<=	addr_sel;
			
			
			
			//OUTPUT REG
			
			addr_valid_o		<=	cache_addr_valid;
			Instr_o				<=	Instr;
			
			
		end
	end
	
	
	assign write_data_o 		= 	{write_data_o_int[7], write_data_o_int[6], write_data_o_int[5], write_data_o_int[4], write_data_o_int[3], write_data_o_int[2], write_data_o_int[1], write_data_o_int[0]} ;
	
	assign mem_write_mask_o 	= 	mem_write_mask_int;
	
	assign MemRead_o 			= 	MemRead_R && (hit_missbar || shared_global_bar_R);
	assign MemWrite_o 			= 	MemWrite_R && (hit_missbar || shared_global_bar_R);
	assign mem_addr_o			= 	addr_sel_R;
	assign warp_ID_o			= 	warp_ID_R;
	assign scb_ID_o				=	scb_ID_R;
	assign word_offset_o		= 	{eff_addr_int[7][4:2], eff_addr_int[6][4:2], eff_addr_int[5][4:2], eff_addr_int[4][4:2], eff_addr_int[3][4:2], eff_addr_int[2][4:2], eff_addr_int[1][4:2], eff_addr_int[0][4:2]};
	assign thread_mask_o		= 	thread_mask;
	assign reg_addr_o			= 	reg_addr_R;
	assign hit_missbar_o		= 	hit_missbar;
	assign miss_latency_o		=	miss_latency;
	assign miss_wait_o			=	miss_wait;
	
	

endmodule