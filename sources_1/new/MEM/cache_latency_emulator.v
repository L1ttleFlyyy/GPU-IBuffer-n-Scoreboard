module cache_latency_emulator(addr, addr_valid, addr_response, addr_response_valid, clk, resetb, latency, hit_missbar);
	parameter mem_size = 256;
	parameter cache_size = 32;
	input clk;
	input resetb;
	input addr_response_valid;
	input [26:0] addr, addr_response;
	output reg [4:0] latency;
	output reg hit_missbar;
	
	reg [4:0] latency_value [mem_size-1:0];
	reg mem_wait [mem_size-1:0];
	reg [26:0] cache_tag_ram [cache_size-1:0];
	reg tag_valid [cache_size-1:0];
	reg tag_match;
	reg [($clog2(cache_size))-1:0] wp;
	
	integer data_file;
	integer scan_return;
	integer i, x;
	
	initial
	begin
		data_file = $fopen("mem_file.txt","r");
		if (data_file == 0)
		begin
			$display("Error Opening Mem file");
			$finish;
		end
		
		for(i=0; i<mem_size; i=i+1)
		begin
			if($feof(data_file))
			begin
				$display("Reached end of file");
				$finish;
			end
			scan_return = $fscanf(data_file, "%b %d\n", x, latency_value[i]);
			if(x!=i)
				$display("Latency Values not continuous at %d",i);
			mem_wait[i]=1'b0;
		end
		for(i=0; i<cache_size; i=i+1)
			tag_valid[i]=1'b0;
		wp = 0;
	end
	
	always@(*)
	begin
		hit_missbar = 0;
		tag_match = 0;
		if(addr_valid)
			if(addr>=mem_size)
				$display("Invalid Input Address");
			else
			begin
				if(addr_response_valid && addr_response == addr)
				begin
					latency = 0;
					tag_match = 1;
					hit_missbar = 1;
					
				end
				else
				begin
					if(mem_wait[addr])
						latency = 5'b00001;
					else
					begin
						latency = latency_value[addr];
						for(i=0;i<cache_size;i=i+1)
							if(tag_valid[i]&&(cache_tag_ram[i]==addr))
							begin
								latency = 0;
								tag_match = 1;
								hit_missbar = 1;
							end
					end
				end
			end
	end
	
	always@(posedge clk, negedge resetb)
	begin
		if(!resetb)
		begin
			for(i=0; i<mem_size; i=i+1)
				mem_wait[i]=1'b0;
			for(i=0; i<cache_size; i=i+1)
				tag_valid[i]=1'b0;
			wp<=0;
		end
		else
		begin
			if(addr_valid && !tag_match)
				mem_wait[addr] <= 1;
			if(addr_response_valid)
			begin
				cache_tag_ram[wp] <= addr_response;
				tag_valid[wp] <= 1'b1;
				mem_wait[addr_response] <= 0;
				wp <= wp + 1;
			end
		end
	end
	
endmodule