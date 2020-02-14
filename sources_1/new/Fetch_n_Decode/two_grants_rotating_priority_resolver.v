module two_grants_rotating_priority_resolver (
clk, rst_n,
REQ_IBuffer_PC,  // 8 request signals
Stall_SIMT_PC,   // 8 stall signals from SIMT
Stall_IBuffer_PC,  // 8 stall signals from I-buffer
GRT,            // 8 grant signals
GRT_raw_1, GRT_raw_2
);

input wire clk, rst_n;
input wire [7:0] REQ_IBuffer_PC;
input wire [7:0] Stall_SIMT_PC;
input wire [7:0] Stall_IBuffer_PC;
output wire [7:0] GRT;

wire [7:0] REQ;
output wire [7:0] GRT_raw_1;
output wire [7:0] GRT_raw_2;
reg [7:0] MR_REQ;
wire [7:0] up_rotator_output;
wire [7:0] fixed_priority_resolver_1_output;
wire [7:0] fixed_priority_resolver_2_output;
wire [7:0] fixed_priority_resolver_2_input;
wire [1:0] REQ_number; // the number of granted request

assign REQ[0] = (!(Stall_SIMT_PC[0] || Stall_IBuffer_PC[0])) && REQ_IBuffer_PC[0];
assign REQ[1] = (!(Stall_SIMT_PC[1] || Stall_IBuffer_PC[1])) && REQ_IBuffer_PC[1];
assign REQ[2] = (!(Stall_SIMT_PC[2] || Stall_IBuffer_PC[2])) && REQ_IBuffer_PC[2];
assign REQ[3] = (!(Stall_SIMT_PC[3] || Stall_IBuffer_PC[3])) && REQ_IBuffer_PC[3];
assign REQ[4] = (!(Stall_SIMT_PC[4] || Stall_IBuffer_PC[4])) && REQ_IBuffer_PC[4];
assign REQ[5] = (!(Stall_SIMT_PC[5] || Stall_IBuffer_PC[5])) && REQ_IBuffer_PC[5];
assign REQ[6] = (!(Stall_SIMT_PC[6] || Stall_IBuffer_PC[6])) && REQ_IBuffer_PC[6];
assign REQ[7] = (!(Stall_SIMT_PC[7] || Stall_IBuffer_PC[7])) && REQ_IBuffer_PC[7];

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
down_rotator down_rotator1 (fixed_priority_resolver_1_output[7:0], MR_REQ[7:0], GRT_raw_1[7:0]);
down_rotator down_rotator2 (fixed_priority_resolver_2_output[7:0], MR_REQ[7:0], GRT_raw_2[7:0]);

assign GRT[7] = GRT_raw_1[7] || GRT_raw_2[7];
assign GRT[6] = GRT_raw_1[6] || GRT_raw_2[6];
assign GRT[5] = GRT_raw_1[5] || GRT_raw_2[5];
assign GRT[4] = GRT_raw_1[4] || GRT_raw_2[4];
assign GRT[3] = GRT_raw_1[3] || GRT_raw_2[3];
assign GRT[2] = GRT_raw_1[2] || GRT_raw_2[2];
assign GRT[1] = GRT_raw_1[1] || GRT_raw_2[1];
assign GRT[0] = GRT_raw_1[0] || GRT_raw_2[0];

assign REQ_number[1] = |GRT_raw_2[7:0];
assign REQ_number[0] = |GRT_raw_1[7:0];

always@(posedge clk) begin
if (!rst_n)
    MR_REQ <= 8'b0;
else 
  begin
    if (REQ_number == 2'b01)
	    MR_REQ <= GRT_raw_1;
	else if (REQ_number == 2'b11)
	    MR_REQ <= GRT_raw_2;
  end
end

endmodule


