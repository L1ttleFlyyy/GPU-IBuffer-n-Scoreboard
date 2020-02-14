module mshr_fifo(clk, resetb, cle_hit_missbar, scbID, warpID, cle_addr, cle_latency, addr_valid, neg_feedback_scbID, neg_feedback_warpID, neg_feedback_addr, neg_feedback_valid);
	
	input clk, resetb, cle_hit_missbar, addr_valid;
	input [1:0] scbID;
	input [2:0] warpID;
	input [26:0] cle_addr;
	input [4:0] cle_latency;
	output [1:0] neg_feedback_scbID;
	output [2:0] neg_feedback_warpID;
	output [26:0] neg_feedback_addr;
	output neg_feedback_valid;
	
	reg [1:0] fifo_scbID [7:0];
	reg [2:0] fifo_warpID [7:0];
	reg [26:0] fifo_addr [7:0];
	reg [4:0] fifo_latency [7:0];
	
	reg [3:0] wp, rp;
	
	wire [3:0] depth;
	wire empty, full;
	
	initial
	begin
		wp = 0;
		rp = 0;
	end
	
	assign depth = wp - rp;
	assign empty = (wp == rp);
	assign full = depth[3];
	
	assign neg_feedback_addr	=	fifo_addr[rp];
	assign neg_feedback_scbID	=	fifo_scbID[rp];
	assign neg_feedback_warpID	=	fifo_warpID[rp];
	
	assign neg_feedback_valid 	=	(fifo_latency[rp]==5'b00001 && !empty);
	
	always@(posedge clk, negedge resetb)
	begin
		if(!resetb)
		begin
			rp <= 0;
			wp <= 0;
			
		end
		else
		begin
			if(neg_feedback_valid)
				rp <= rp + 1;
			if(fifo_latency[rp])
				fifo_latency[rp] <= fifo_latency[rp] - 1;
				
				
			if(!cle_hit_missbar && !full && addr_valid)
			begin
				fifo_scbID[wp]		<= 	scbID;
				fifo_warpID[wp]		<=	warpID;
				fifo_addr[wp]		<= 	cle_addr;
				fifo_latency[wp]	<=	cle_latency;
				
				wp <= wp + 1;
			end
			
		end
	end

endmodule