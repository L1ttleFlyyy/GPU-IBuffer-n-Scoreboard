module TaskManager(
// Global Signals
input clk,
input rst,

//interface with SIMT
output reg Update_TM_SIMT,
output reg [2:0] WarpID_TM_SIMT,
output reg [7:0] AM_TM_SIMT,

//interface with Fetch
output reg UpdatePC_TM_PC,
output reg [2:0] WarpID_TM_PC,
output reg [31:0] StartingPC_TM_PC,

//interface with Issue Unit
input Exit_IB_RAU_TM,
input [2:0] WarpID_IU_TM,

//interface with Register File Allocation Unit
input Alloc_BusyBar_RAU_TM,
output Update_TM_RAU,
output [2:0] Nreg_TM_RAU,
output [2:0] HWWarpID_TM_RAU,
output [7:0] SWWarpID_TM_RAU,

//interface with FileIO module
input Wen_FIO_TM,
input [28:0] Din_FIO_TM,
input start_FIO_TM,
input clear_FIO_TM,
// output busy, 
output reg finished_TM_FIO
);

// Tasks list Template example
// Din_FIO_TM[28:0]
// Din_FIO_TM[28] -> Valid=1
// Din_FIO_TM[27:20] -> Software Warp ID (8bits)
// Din_FIO_TM[19:11] -> PC bits
// Din_FIO_TM[10:3] -> Active Mask
// Din_FIO_TM[2:0] -> Number of Registers
//-------------------------------
//			bits -> actual req -> Now mapped as pairs of registers.
// #registers : 0-> 0,
//				1-> 2,
//				2-> 4,
//				3-> 6,
//				4-> 8,

reg [2:0] free_Warp [7:0]; // FIFO containing the list of free Hardware Warp which would be used to assign a new Software warp to SIMD.
reg [28:0] tasks [255:0]; // A list where all the tasks assigned to the GPU are stored.
reg [7:0] active_Warp [7:0]; // A mapping where each location represent a HW warp which stores SW warp location in tasks (Read Pointer) in it, for de-validation in the tasks list.

reg [3:0] free_Warp_rptr, free_Warp_wptr;
reg [8:0] tasks_rptr, tasks_wptr;

reg [7:0] active_tasks;
reg [5:0] free_registers;

//Pointers
wire free_Warp_empty, free_Warp_full;
wire tasks_empty, tasks_full;

//Internal raw signals
wire assign_warp_raw1;
wire assign_warp_raw2;
wire assign_warp_raw;

reg can_reg_alloc;
reg [5:0] reg_would_alloc;
reg [5:0] freed_reg;

//integers
integer i;

//State
reg [1:0] STATE;
localparam Waiting=2'b00;
localparam Working=2'b01;
localparam Complete=2'b10;
localparam Clear=2'b11;

assign free_Warp_empty = (free_Warp_wptr[2:0] == free_Warp_rptr[2:0] ) ? ~(free_Warp_wptr[3] ^ free_Warp_rptr[3]) : 1'b0;
assign free_Warp_full = (free_Warp_wptr[2:0] == free_Warp_rptr[2:0] ) ? (free_Warp_wptr[3] ^ free_Warp_rptr[3]) : 1'b0;

assign tasks_empty = (tasks_wptr[7:0] == tasks_rptr[7:0]) ? ~(tasks_rptr[8] ^ tasks_wptr[8]) : 1'b0;
assign tasks_full = (tasks_wptr[7:0] == tasks_rptr[7:0]) ? (tasks_rptr[8] ^ tasks_wptr[8]) : 1'b0;

assign assign_warp_raw1 = (~free_Warp_empty) & (~tasks_empty);
assign assign_warp_raw2 = can_reg_alloc & Alloc_BusyBar_RAU_TM & !Exit_IB_RAU_TM;
assign assign_warp_raw = assign_warp_raw1 & assign_warp_raw2;


assign Update_TM_RAU = (STATE == Working) & assign_warp_raw & tasks[tasks_rptr[7:0]][28];
assign HWWarpID_TM_RAU = free_Warp[free_Warp_rptr[2:0]];
assign Nreg_TM_RAU = tasks[tasks_rptr[7:0]][2:0];
assign SWWarpID_TM_RAU = tasks[tasks_rptr[7:0]][27:20];

always @ (posedge clk) begin
	if(rst==0) begin
		free_registers <= 6'b10_0000;	// Free registers represent the actual number of free registers.
		active_tasks <= 0;

		STATE<=Waiting;

		WarpID_TM_PC<=0;
		WarpID_TM_SIMT<=0;

		AM_TM_SIMT<=0;
		StartingPC_TM_PC<=0;

		UpdatePC_TM_PC<=0;
		Update_TM_SIMT<=0;
		// alloc_TM_RAU<=0;
		free_Warp_rptr<=0;
		tasks_rptr<=0;
		free_Warp_wptr<=4'b1000;
		tasks_wptr<=0;

		// busy<=0;
		finished_TM_FIO<=0;

		for(i=0;i<8;i=i+1) begin
			active_Warp[i] <= 0;
			free_Warp[i] <= i;
		end
		for(i=0;i<256;i=i+1) begin
			tasks[i] <= 0;
		end

	end
	else begin
		
	case (STATE)

		Waiting:
		begin
			if(clear_FIO_TM) begin
				STATE<=Clear;
			end
			else if(start_FIO_TM) begin
				STATE<=Working;
				// busy<=1;
			end
			else begin
				if(Wen_FIO_TM && Din_FIO_TM[28]) begin
					tasks[tasks_wptr[7:0]]<=Din_FIO_TM;
					tasks_wptr<=tasks_wptr+1;
				end
			end

		end // Working ends

		Working:
		begin
			WarpID_TM_PC<=free_Warp[free_Warp_rptr[2:0]];
			WarpID_TM_SIMT<=free_Warp[free_Warp_rptr[2:0]];
			AM_TM_SIMT<=tasks[tasks_rptr[7:0]][10:3];
			StartingPC_TM_PC<={21'b0,tasks[tasks_rptr[7:0]][19:11],2'b0};

			if(assign_warp_raw & tasks[tasks_rptr[7:0]][28]) begin
				UpdatePC_TM_PC<=1;
				Update_TM_SIMT<=1;
				free_Warp_rptr<=free_Warp_rptr+1;
				tasks_rptr<=tasks_rptr+1;
				free_registers<= free_registers - reg_would_alloc;
				active_Warp[free_Warp[free_Warp_rptr[2:0]]]<=tasks_rptr[7:0];
				active_tasks<=active_tasks+1;
			end
			else begin
				UpdatePC_TM_PC<=0;
				Update_TM_SIMT<=0;
				// alloc_TM_RAU<=0;
			end

			if(Exit_IB_RAU_TM) begin
				free_registers <= free_registers + freed_reg;
				tasks[active_Warp[WarpID_IU_TM]][28]<=0;
				free_Warp[free_Warp_wptr[2:0]]<=WarpID_IU_TM;
				free_Warp_wptr<=free_Warp_wptr+1;
				active_tasks<=active_tasks-1;
			end

			if((active_tasks==0) && (tasks[tasks_rptr[7:0]][28]==0)) begin
				STATE<=Complete;
				finished_TM_FIO<=1;
				// busy<=0;
			end
		end // Working ends

		Complete:
		begin
			if(clear_FIO_TM) begin
				STATE<=Clear;
				finished_TM_FIO<=0;
			end
		end // Complete ends

		Clear:
		begin
			free_registers <= 6'b10_0000;	// Free registers represent the actual number of free registers.
			active_tasks <= 0;

			STATE<=Waiting;

			WarpID_TM_PC<=0;
			WarpID_TM_SIMT<=0;
			// WarpID_TM_RAU<=0;

			AM_TM_SIMT<=0;
			StartingPC_TM_PC<=0;

			UpdatePC_TM_PC<=0;
			Update_TM_SIMT<=0;
			// alloc_TM_RAU<=0;
			free_Warp_rptr<=0;
			tasks_rptr<=0;
			free_Warp_wptr<=0;
			tasks_wptr<=0;

			for(i=0;i<8;i=i+1) begin
				active_Warp[i] <= 0;
				free_Warp[i] <= i;
			end
			for(i=0;i<256;i=i+1) begin
				tasks[i] <= 0;
			end
		end // Clear ends

	endcase
	end
end

always @(*) begin
	if(rst==0) begin
		can_reg_alloc = 0;
		reg_would_alloc = 0;
		freed_reg = 0;
	end
	else begin
		if(free_registers >= tasks[tasks_rptr[7:0]][2:0]) begin
			can_reg_alloc = 1;
		end
		else begin
			can_reg_alloc = 0;
		end

		freed_reg = {1'b0,tasks[active_Warp[WarpID_IU_TM]][2:0],1'b0};
		reg_would_alloc = {1'b0,tasks[tasks_rptr[7:0]][2:0],1'b0};
/*
		if(tasks[tasks_rptr[7:0]][0]) begin
			reg_would_alloc[3:0] = {1'b0,tasks[tasks_rptr[7:0]][2:0]} + 1;
		end
		else begin
			reg_would_alloc[3:0] = {1'b0,tasks[tasks_rptr[7:0]][2:0]} + 2;
		end
		if(tasks[active_Warp[WarpID_IU_TM]][0]) begin
			freed_reg [3:0] = {1'b0,tasks[active_Warp[WarpID_IU_TM]][2:0]} + 1;
		end
		else begin
			freed_reg [3:0] = {1'b0,tasks[active_Warp[WarpID_IU_TM]][2:0]} + 2;
		end
*/
	end
end
endmodule