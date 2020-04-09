
module cache_latency_emulator(addr, addr_valid, addr_response, addr_response_valid, clk, resetb, FIO_CACHE_LAT_WRITE, FIO_CACHE_LAT_VALUE, FIO_CACHE_MEM_ADDR,
latency, hit_missbar, miss_wait);
	parameter mem_size = 256;
	parameter cache_size = 32;
	parameter addr_width = 8;
	
	input clk;
	input resetb;
	input addr_response_valid;

	input addr_valid;
	input [26:0] addr, addr_response;
	
	input FIO_CACHE_LAT_WRITE;
	input [4:0] FIO_CACHE_LAT_VALUE;
	input [addr_width-1:0] FIO_CACHE_MEM_ADDR;
	
	
	output [4:0] latency;
	output reg hit_missbar, miss_wait;
	
	
	reg addr_response_valid_R;
	reg addr_valid_R;
	reg [26:0] addr_R, addr_response_R;
	
	
	reg [4:0] latency_value [mem_size-1:0];
	reg mem_wait [mem_size-1:0];
	reg [26:0] cache_tag_ram [cache_size-1:0];
	reg tag_valid [cache_size-1:0];
	reg tag_match;
	reg [($clog2(cache_size))-1:0] wp;
	
	integer data_file;
	integer scan_return;
	integer i, x;
	
	
	
	Inferable_BRAM #(.OREG(0), .DATA(5), .ADDR(addr_width))
					latency_RAM (.a_clk(clk), .a_wr(0), .a_addr(addr[addr_width-1:0]), .a_din(0), .a_dout(latency), 
								 .b_clk(clk), .b_wr(FIO_CACHE_LAT_WRITE), .b_addr(FIO_CACHE_MEM_ADDR), .b_din(FIO_CACHE_LAT_VALUE), .b_dout());
	
	
	
	
	always@(*)
	begin
		hit_missbar = 0;
		tag_match = 0;
		// TODO: confirm with Dipayan
		miss_wait = 0;
		if(addr_valid_R)
		begin
		
			if(addr_R>=mem_size)
				$display("Invalid Input Address");
				
			miss_wait = mem_wait[addr_R];
			
			for(i=0;i<cache_size;i=i+1)
				if(tag_valid[i]&&(cache_tag_ram[i]==addr_R))
				begin
					hit_missbar = 1;
					tag_match = 1;
				end
				
			if(addr_response_valid_R && addr_response_R == addr_R)
			begin
				hit_missbar = 1;
				tag_match = 1;
			end
		end
	end
	
	always@(posedge clk, negedge resetb)
	begin
		if(!resetb)
		begin
			for(i=0; i<mem_size; i=i+1)
				mem_wait[i]<=1'b0;
			for(i=0;i<cache_size;i=i+1) begin
				tag_valid[i]<=1'b0;
				cache_tag_ram[i]<={27{1'bx}};
			end
			wp<=0;
			addr_valid_R <= 0;
			addr_response_valid_R <= 1'bx; // confirm with Dipayan
			addr_R <= {27{1'bx}};
			addr_response_R <= {27{1'bx}};
		end
		else
		begin
			if(addr_valid_R && !tag_match)
				mem_wait[addr_R] <= 1'b1;
			if(addr_response_valid_R)
			begin
				cache_tag_ram[wp] <= addr_response_R;
				tag_valid[wp] <= 1'b1;
				mem_wait[addr_response_R] <= 1'b0;
				wp <= wp + 1;
			end
			
			
			
			addr_response_valid_R	<=	addr_response_valid;
			addr_valid_R			<=	addr_valid;
			addr_R					<=	addr;
			addr_response_R			<=	addr_response;
			
			
		end
	end
	
endmodule