module Two_Grants_Rotating_Priority_Resolver (
clk, rst_n,
Req_IB_PC,  // 8 request signals
Stall_SIMT_PC,   // 8 stall signals from SIMT
PCValid_ID_IB,  // 8 PC Valid signals
GRT_RR_PC,            // 8 grant signals
GRT_raw_1_RR_IF, GRT_raw_2_RR_IF
);

input wire clk, rst_n;
input wire [7:0] Req_IB_PC;
input wire [7:0] Stall_SIMT_PC;
input wire [7:0] PCValid_ID_IB;
output wire [7:0] GRT_RR_PC;

wire [7:0] REQ;
output wire [7:0] GRT_raw_1_RR_IF;
output wire [7:0] GRT_raw_2_RR_IF;
reg [7:0] MR_REQ;
wire [7:0] up_rotator_output;
wire [7:0] fixed_priority_resolver_1_output;
wire [7:0] fixed_priority_resolver_2_output;
wire [7:0] fixed_priority_resolver_2_input;
wire [1:0] REQ_number; // the number of granted request

assign REQ[0] = !Stall_SIMT_PC[0] && (PCValid_ID_IB[0] && Req_IB_PC[0]);
assign REQ[1] = !Stall_SIMT_PC[1] && (PCValid_ID_IB[1] && Req_IB_PC[1]);
assign REQ[2] = !Stall_SIMT_PC[2] && (PCValid_ID_IB[2] && Req_IB_PC[2]);
assign REQ[3] = !Stall_SIMT_PC[3] && (PCValid_ID_IB[3] && Req_IB_PC[3]);
assign REQ[4] = !Stall_SIMT_PC[4] && (PCValid_ID_IB[4] && Req_IB_PC[4]);
assign REQ[5] = !Stall_SIMT_PC[5] && (PCValid_ID_IB[5] && Req_IB_PC[5]);
assign REQ[6] = !Stall_SIMT_PC[6] && (PCValid_ID_IB[6] && Req_IB_PC[6]);
assign REQ[7] = !Stall_SIMT_PC[7] && (PCValid_ID_IB[7] && Req_IB_PC[7]);

up_rotator up_rotator_1 (REQ[7:0], MR_REQ[7:0], up_rotator_output[7:0]);
fixed_priority_resolver FPR1 (up_rotator_output[7:0], fixed_priority_resolver_1_output[7:0]);

assign fixed_priority_resolver_2_input[7] = (!fixed_priority_resolver_1_output[7]) && up_rotator_output[7];
assign fixed_priority_resolver_2_input[6] = (!fixed_priority_resolver_1_output[6]) && up_rotator_output[6];
assign fixed_priority_resolver_2_input[5] = (!fixed_priority_resolver_1_output[5]) && up_rotator_output[5];
assign fixed_priority_resolver_2_input[4] = (!fixed_priority_resolver_1_output[4]) && up_rotator_output[4];
assign fixed_priority_resolver_2_input[3] = (!fixed_priority_resolver_1_output[3]) && up_rotator_output[3];
assign fixed_priority_resolver_2_input[2] = (!fixed_priority_resolver_1_output[2]) && up_rotator_output[2];
assign fixed_priority_resolver_2_input[1] = (!fixed_priority_resolver_1_output[1]) && up_rotator_output[1];
assign fixed_priority_resolver_2_input[0] = (!fixed_priority_resolver_1_output[0]) && up_rotator_output[0];

fixed_priority_resolver FPR2 (fixed_priority_resolver_2_input[7:0], fixed_priority_resolver_2_output[7:0]);
down_rotator down_rotator1 (fixed_priority_resolver_1_output[7:0], MR_REQ[7:0], GRT_raw_1_RR_IF[7:0]);
down_rotator down_rotator2 (fixed_priority_resolver_2_output[7:0], MR_REQ[7:0], GRT_raw_2_RR_IF[7:0]);

assign GRT_RR_PC[7] = GRT_raw_1_RR_IF[7] || GRT_raw_2_RR_IF[7];
assign GRT_RR_PC[6] = GRT_raw_1_RR_IF[6] || GRT_raw_2_RR_IF[6];
assign GRT_RR_PC[5] = GRT_raw_1_RR_IF[5] || GRT_raw_2_RR_IF[5];
assign GRT_RR_PC[4] = GRT_raw_1_RR_IF[4] || GRT_raw_2_RR_IF[4];
assign GRT_RR_PC[3] = GRT_raw_1_RR_IF[3] || GRT_raw_2_RR_IF[3];
assign GRT_RR_PC[2] = GRT_raw_1_RR_IF[2] || GRT_raw_2_RR_IF[2];
assign GRT_RR_PC[1] = GRT_raw_1_RR_IF[1] || GRT_raw_2_RR_IF[1];
assign GRT_RR_PC[0] = GRT_raw_1_RR_IF[0] || GRT_raw_2_RR_IF[0];

assign REQ_number[1] = |GRT_raw_2_RR_IF[7:0];
assign REQ_number[0] = |GRT_raw_1_RR_IF[7:0];

always@(posedge clk) begin
if (!rst_n)
    MR_REQ <= 8'b1000_0000;
else 
  begin
    if (REQ_number == 2'b01)
	    MR_REQ <= GRT_raw_1_RR_IF;
	else if (REQ_number == 2'b11)
	    MR_REQ <= GRT_raw_2_RR_IF;
  end
end

endmodule

module Generate_PCvalid_Logic (
Valid_ID0_IB, Valid_ID1_IB,
Exit_ID0_IB, Exit_ID1_IB,
UpdatePC_TM_PC, PCValid_PC_RR,
clk, rst_n
);

input clk, rst_n;
input wire [7:0] Valid_ID0_IB, Valid_ID1_IB, UpdatePC_TM_PC;
input wire Exit_ID0_IB, Exit_ID1_IB;
output reg [7:0] PCValid_PC_RR;
wire [7:0] Exit_ID_PC;

genvar i;
generate
for (i = 0; i < 8; i = i + 1) begin : pc_valid
	assign Exit_ID_PC[i] = (Valid_ID0_IB[i] && Exit_ID0_IB) || (Valid_ID1_IB[i] && Exit_ID1_IB);
	always@(posedge clk) begin
		if (!rst_n)
			PCValid_PC_RR[i] <= 1'b0;
		else begin
			if (Exit_ID_PC[i] == 1'b1)
				PCValid_PC_RR[i] <= 1'b0;
			else if (UpdatePC_TM_PC[i] == 1)
				PCValid_PC_RR[i] <= 1'b1;
		end
	end
end
endgenerate

endmodule


