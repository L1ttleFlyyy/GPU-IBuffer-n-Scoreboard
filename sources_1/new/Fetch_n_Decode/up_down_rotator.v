module up_rotator (
REQ,
MR_REQ,
out        );

input wire [7:0] REQ;
input wire [7:0] MR_REQ;
output reg [7:0] out;

always@(*) begin
	out = 8'd0;  //avoid latches
	if (MR_REQ == 8'b0000_0001)
		out[7:0] = {REQ[0], REQ[7:1]};
	if (MR_REQ == 8'b0000_0010)
		out[7:0] = {REQ[1:0], REQ[7:2]};
	if (MR_REQ == 8'b0000_0100)
		out[7:0] = {REQ[2:0], REQ[7:3]};
	if (MR_REQ == 8'b0000_1000)
		out[7:0] = {REQ[3:0], REQ[7:4]};
	if (MR_REQ == 8'b0001_0000)
		out[7:0] = {REQ[4:0], REQ[7:5]};
	if (MR_REQ == 8'b0010_0000)
		out[7:0] = {REQ[5:0], REQ[7:6]};
	if (MR_REQ == 8'b0100_0000)
		out[7:0] = {REQ[6:0], REQ[7]};
	if (MR_REQ == 8'b1000_0000)
		out[7:0] = REQ[7:0];
end

endmodule;

module down_rotator (
REQ,
MR_REQ,
out        );

input wire [7:0] REQ;
input wire [7:0] MR_REQ;
output reg [7:0] out;

always@(*) begin
	out = 8'd0;
	if (MR_REQ == 8'b0000_0001)
		out[7:0] = {REQ[6:0], REQ[7]};
	if (MR_REQ == 8'b0000_0010)
		out[7:0] = {REQ[5:0], REQ[7:6]};
	if (MR_REQ == 8'b0000_0100)
		out[7:0] = {REQ[4:0], REQ[7:5]};
	if (MR_REQ == 8'b0000_1000)
		out[7:0] = {REQ[3:0], REQ[7:4]};
	if (MR_REQ == 8'b0001_0000)
		out[7:0] = {REQ[2:0], REQ[7:3]};
	if (MR_REQ == 8'b0010_0000)
		out[7:0] = {REQ[1:0], REQ[7:2]};
	if (MR_REQ == 8'b0100_0000)
		out[7:0] = {REQ[0], REQ[7:1]};
	if (MR_REQ == 8'b1000_0000)
		out[7:0] = REQ[7:0];
end

endmodule