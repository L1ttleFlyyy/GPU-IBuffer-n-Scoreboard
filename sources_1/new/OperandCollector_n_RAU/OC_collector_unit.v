module OC_collector_unit 
#(
parameter ocid = 0
)
(

	//"WE" is the WE from upstream (2-bit)
	//"RE" means downstream is going to read
	//"RDY" means operand collected
	//"c_0_reg_id_in" src 0 id 
	//"c_1_reg_id_in" src 1 id 
	//"bypass_pyld_in" instruction type & by pass data 
	
input 	[255:0] bk_0_data, 
input 	[255:0] bk_1_data, 
input 	[255:0] bk_2_data, 
input 	[255:0] bk_3_data,
input [2:0] bk_0_ocid,
input [2:0] bk_1_ocid,
input [2:0] bk_2_ocid,
input [2:0] bk_3_ocid,
input  bk_0_bz,
input  bk_1_bz,
input  bk_2_bz,
input  bk_3_bz,
input bk_0_vld,
input bk_1_vld,
input bk_2_vld,
input bk_3_vld,
input [1:0] Src1_Phy_Bank_ID, 
input [1:0] Src2_Phy_Bank_ID,
input [1:0] WE,
input RE, 
input clk, 
input rst,

input same_OC_0,
input same_OC_1,
input same_OC_2,
input same_OC_3,

input wire [2:0] WarpID_RAU_OC,
input wire Valid_RAU_OC ,//use
input wire [31:0] Instr_RAU_OC ,//pass

input wire RegWrite_RAU_OC,

input wire [15:0] Imme_RAU_OC ,//
input wire Imme_Valid_RAU_OC ,//
input wire [3:0] ALUop_RAU_OC ,//
input wire MemWrite_RAU_OC ,//
input wire MemRead_RAU_OC ,//
input wire Shared_Globalbar_RAU_OC ,//pass
input wire BEQ_RAU_OC ,//pass
input wire BLT_RAU_OC ,//pass
input wire [1:0] ScbID_RAU_OC ,//pass
input wire [7:0] ActiveMask_RAU_OC ,//pass
input wire [4:0] Dst_RAU_OC,


input wire [1:0] SPEslot_RAU_OC,
input wire [255:0] SPEvalue_RAU_OC,
input wire [1:0] SPEv2slot_RAU_OC,
input wire [255:0] SPEv2value_RAU_OC,


output RDY, 
output reg valid,

output reg [255:0] oc_0_data,
output reg [255:0] oc_1_data,

output reg Valid_OC_Ex ,//use
output reg [31:0] Instr_OC_Ex ,//pass
output reg [2:0] WarpID_OC_Ex,
output reg RegWrite_OC_Ex,
output reg [15:0] Imme_OC_Ex ,//
output reg Imme_Valid_OC_Ex ,//
output reg [3:0] ALUop_OC_Ex ,//
output reg MemWrite_OC_Ex ,//
output reg MemRead_OC_Ex ,//
output reg Shared_Globalbar_OC_Ex ,//pass
output reg BEQ_OC_Ex ,//pass
output reg BLT_OC_Ex ,//pass
output reg [1:0] ScbID_OC_Ex ,//pass
output reg [7:0] ActiveMask_OC_Ex,//pass
output reg [4:0] Dst_OC_Ex
);
/*---------wire/reg-------*/
reg [1:0] oc_0_banksel;
reg [1:0] oc_1_banksel;
reg oc_0_valid;
reg oc_1_valid;
reg oc_0_rdy;
reg oc_1_rdy;
/*-------------------------*/

reg [255:0] oc_0_data_in;
reg [255:0] oc_1_data_in;

wire OC_0_WE;
wire OC_1_WE;

assign RDY = valid && ~(oc_0_valid && ~oc_0_rdy) && ~(oc_1_valid && ~oc_1_rdy);

wire OC_0_bk0 = oc_0_banksel == 2'b00 & (bk_0_ocid == {ocid[1:0], 1'b0}) &&  !bk_0_bz && bk_0_vld;
wire OC_0_bk1 = oc_0_banksel == 2'b01 & (bk_1_ocid == {ocid[1:0], 1'b0}) &&  !bk_1_bz && bk_1_vld;
wire OC_0_bk2 = oc_0_banksel == 2'b10 & (bk_2_ocid == {ocid[1:0], 1'b0}) &&  !bk_2_bz && bk_2_vld;
wire OC_0_bk3 = oc_0_banksel == 2'b11 & (bk_3_ocid == {ocid[1:0], 1'b0}) &&  !bk_3_bz && bk_3_vld;

// assign OC_0_WE = ((bk_0_ocid == {ocid[1:0], 1'b0}) &&  !bk_0_bz && bk_0_vld)|| 
// 				 ((bk_1_ocid == {ocid[1:0], 1'b0}) &&  !bk_1_bz && bk_1_vld)|| 
// 				 ((bk_2_ocid == {ocid[1:0], 1'b0}) &&  !bk_2_bz && bk_2_vld)|| 
// 				 ((bk_3_ocid == {ocid[1:0], 1'b0}) &&  !bk_3_bz && bk_3_vld);

assign OC_0_WE = OC_0_bk0 || OC_0_bk1 || OC_0_bk2 || OC_0_bk3;

assign OC_1_WE = ((oc_1_banksel == 2'b00 & (bk_0_ocid == {ocid[1:0], 1'b1}) &&  !bk_0_bz && bk_0_vld) | (OC_0_WE & (same_OC_0 === 1'b1)))|| 
				 ((oc_1_banksel == 2'b01 & (bk_1_ocid == {ocid[1:0], 1'b1}) &&  !bk_1_bz && bk_1_vld) | (OC_0_WE & (same_OC_1 === 1'b1)))|| 
				 ((oc_1_banksel == 2'b10 & (bk_2_ocid == {ocid[1:0], 1'b1}) &&  !bk_2_bz && bk_2_vld) | (OC_0_WE & (same_OC_2 === 1'b1)))|| 
				 ((oc_1_banksel == 2'b11 & (bk_3_ocid == {ocid[1:0], 1'b1}) &&  !bk_3_bz && bk_3_vld) | (OC_0_WE & (same_OC_3 === 1'b1)));



always @ *
begin 
	case (oc_0_banksel)
		2'b00:  oc_0_data_in = bk_0_data;
		2'b01:	oc_0_data_in = bk_1_data;
		2'b10:	oc_0_data_in = bk_2_data;
		2'b11:	oc_0_data_in = bk_3_data;
		default: oc_0_data_in = 256'bz;
	endcase
	if (SPEslot_RAU_OC[0])
		oc_0_data_in = SPEvalue_RAU_OC;
	else if (SPEv2slot_RAU_OC[0])
		oc_0_data_in = SPEv2value_RAU_OC;
	case (oc_1_banksel)
		2'b00:  oc_1_data_in = bk_0_data;
		2'b01:	oc_1_data_in = bk_1_data;
		2'b10:	oc_1_data_in = bk_2_data;
		2'b11:	oc_1_data_in = bk_3_data;
		default: oc_1_data_in = 256'bz;
	endcase
	if (SPEslot_RAU_OC[1])
		oc_1_data_in = SPEvalue_RAU_OC;
	else if (SPEv2slot_RAU_OC[1])
		oc_1_data_in = SPEv2value_RAU_OC;
end

always @ (posedge clk)
begin
	if (!rst)
		begin
			valid <= 0;
			oc_0_valid <= 0;
			oc_1_valid <= 0;
		end
	else 
		begin

			if (WE != 2'b00)
			begin
				valid <= 1;
				oc_0_rdy <= 0;
				oc_1_rdy <= 0;
				Valid_OC_Ex <= Valid_RAU_OC ;//use
				Instr_OC_Ex <= Instr_RAU_OC ;//pass
				
				WarpID_OC_Ex <= WarpID_RAU_OC;
				RegWrite_OC_Ex <= RegWrite_RAU_OC;
				Imme_OC_Ex <= Imme_RAU_OC ;//
				Imme_Valid_OC_Ex <= Imme_Valid_RAU_OC ;//
				ALUop_OC_Ex <= ALUop_RAU_OC ;//
				MemWrite_OC_Ex <= MemWrite_RAU_OC ;//
				MemRead_OC_Ex <= MemRead_RAU_OC ;//
				Shared_Globalbar_OC_Ex <= Shared_Globalbar_RAU_OC ;//pass
				BEQ_OC_Ex <= BEQ_RAU_OC ;//pass
				BLT_OC_Ex <= BLT_RAU_OC ;//pass
				ScbID_OC_Ex <= ScbID_RAU_OC ;//pass
				ActiveMask_OC_Ex <= ActiveMask_RAU_OC ;//pass
				Dst_OC_Ex <= Dst_RAU_OC;
				

				if (WE[0])
				begin
					oc_0_valid <= 1;
					oc_0_banksel <= Src1_Phy_Bank_ID;
					if (SPEslot_RAU_OC[0]) begin
						oc_0_data <= SPEvalue_RAU_OC;
						oc_0_rdy <= 1;
						oc_0_valid <= 0;
					end else if (SPEv2slot_RAU_OC[0]) begin
						oc_0_data <= SPEv2value_RAU_OC;
						oc_0_rdy <= 1;
						oc_0_valid <= 0;
					end
				end
				if (WE[1])
				begin
					oc_1_valid <= 1;
					oc_1_banksel <= Src2_Phy_Bank_ID;
					if (SPEslot_RAU_OC[1]) begin
						oc_1_data = SPEvalue_RAU_OC;
						oc_1_rdy <= 1;
						oc_1_valid <= 0;
					end else if (SPEv2slot_RAU_OC[1]) begin
						oc_1_data = SPEv2value_RAU_OC;
						oc_1_rdy <= 1;
						oc_1_valid <= 0;
					end
				end				
			end
			else if (RE == 1)
			begin
				valid <= 0;
				oc_0_valid <= 0;
				oc_1_valid <= 0;
			end
			else 
			begin
				if (oc_0_valid & OC_0_WE)
				begin
					oc_0_data <= oc_0_data_in;
					oc_0_rdy <= 1;
				end
				if (oc_1_valid & OC_1_WE)
				begin
					oc_1_data <= oc_1_data_in;
					oc_1_rdy <= 1;
				end
			end
		end
end

endmodule //OC_collector_unit