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
	wire [2:0] wp_ind = wp[2:0];
	wire [2:0] rp_ind = rp[2:0];

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
	
	assign neg_feedback_addr	=	fifo_addr[rp_ind];
	assign neg_feedback_scbID	=	fifo_scbID[rp_ind];
	assign neg_feedback_warpID	=	fifo_warpID[rp_ind];
	
	assign neg_feedback_valid 	=	(fifo_latency[rp_ind]==5'b00001 && !empty);
	integer i;
	always@(posedge clk)
	begin
		if(!resetb)
		begin
			rp <= 0;
			wp <= 0;
			for(i = 0; i < 8; i = i + 1) begin: fifo_reset
				fifo_scbID[i] <= {2{1'bx}};
				fifo_warpID[i] <= {3{1'bx}};
				fifo_addr[i] <= {27{1'bx}};
				fifo_latency[i] <= {5{1'bx}};
			end
		end
		else
		begin
			if(neg_feedback_valid)
				rp <= rp + 1;
			if(fifo_latency[rp_ind])
				fifo_latency[rp_ind] <= fifo_latency[rp_ind] - 1;
				
				
			if(!cle_hit_missbar && !full && addr_valid)
			begin
				fifo_scbID[wp_ind]		<= 	scbID;
				fifo_warpID[wp_ind]		<=	warpID;
				fifo_addr[wp_ind]		<= 	cle_addr;
				fifo_latency[wp_ind]	<=	cle_latency;
				
				wp <= wp + 1;
			end
		end
	end

endmodule