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
input [4:0] c_0_reg_id_in, 
input [4:0] c_1_reg_id_in,
input [1:0] WE,
input RE, 
input clk, 
input rst,

input wire Valid_RAU_Collecting ,//use
input wire [31:0] Instr_RAU_Collecting ,//pass

input wire RegWrite_RAU_Collecting,

input wire [15:0] Imme_RAU_Collecting ,//
input wire Imme_Valid_RAU_Collecting ,//
input wire [3:0] ALUop_RAU_Collecting ,//
input wire MemWrite_RAU_Collecting ,//
input wire MemRead_RAU_Collecting ,//
input wire Shared_Globalbar_RAU_Collecting ,//pass
input wire BEQ_RAU_Collecting ,//pass
input wire BLT_RAU_Collecting ,//pass
input wire [1:0] ScbID_RAU_Collecting ,//pass
input wire [7:0] ActiveMask_RAU_Collecting ,//pass
output RDY, 
output valid,

output [255:0] oc_0_data,
output [255:0] oc_1_data,

output reg Valid_Collecting_Ex ,//use
output reg [31:0] Instr_Collecting_Ex ,//pass

output reg RegWrite_Collecting_Ex,
output reg [15:0] Imme_Collecting_Ex ,//
output reg Imme_Valid_Collecting_Ex ,//
output reg [3:0] ALUop_Collecting_Ex ,//
output reg MemWrite_Collecting_Ex ,//
output reg MemRead_Collecting_Ex ,//
output reg Shared_Globalbar_Collecting_Ex ,//pass
output reg BEQ_Collecting_Ex ,//pass
output reg BLT_Collecting_Ex ,//pass
output reg [1:0] ScbID_Collecting_Ex ,//pass
output reg [7:0] ActiveMask_Collecting_Ex//pass
);
/*---------wire/reg-------*/
wire RDY;
reg valid;
reg [10:0] bypass_pyld;
reg [4:0] oc_0_reg_id;
reg [4:0] oc_1_reg_id;
reg oc_0_valid;
reg oc_1_valid;
reg oc_0_rdy;
reg oc_1_rdy;
reg [255:0] oc_0_data;
reg [255:0] oc_1_data;
/*-------------------------*/

reg [255:0] oc_0_data_in;
reg [255:0] oc_1_data_in;

wire OC_0_WE;
wire OC_1_WE;

assign RDY = valid && ~(oc_0_valid && ~oc_0_rdy) && ~(oc_1_valid && ~oc_1_rdy);

assign OC_0_WE = ((bk_0_ocid == ocid << 1) &&  !bk_0_bz && bk_0_vld)|| 
				 ((bk_1_ocid == ocid << 1) &&  !bk_1_bz && bk_1_vld)|| 
				 ((bk_2_ocid == ocid << 1) &&  !bk_2_bz && bk_2_vld)|| 
				 ((bk_3_ocid == ocid << 1) &&  !bk_3_bz && bk_3_vld);
assign OC_1_WE = ((bk_0_ocid == ocid << 1 + 1) &&  !bk_0_bz && bk_0_vld)|| 
				 ((bk_1_ocid == ocid << 1 + 1) &&  !bk_1_bz && bk_1_vld)|| 
				 ((bk_2_ocid == ocid << 1 + 1) &&  !bk_2_bz && bk_2_vld)|| 
				 ((bk_3_ocid == ocid << 1 + 1) &&  !bk_3_bz && bk_3_vld);
always @ *
begin 
	case (oc_0_reg_id[4:3])
		2'b00:  oc_0_data_in = bk_0_data;
		2'b01:	oc_0_data_in = bk_1_data;
		2'b10:	oc_0_data_in = bk_2_data;
		2'b11:	oc_0_data_in = bk_3_data;
		default: oc_0_data_in = 32'bz;
	endcase
	case (oc_1_reg_id[4:3])
		2'b00:  oc_1_data_in = bk_0_data;
		2'b01:	oc_1_data_in = bk_1_data;
		2'b10:	oc_1_data_in = bk_2_data;
		2'b11:	oc_1_data_in = bk_3_data;
		default: oc_1_data_in = 32'bz;
	endcase
end

always @ (posedge clk)
begin
	if (rst)
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
				Valid_Collecting_Ex <= Valid_RAU_Collecting ;//use
				Instr_Collecting_Ex <= Instr_RAU_Collecting ;//pass
				

				RegWrite_Collecting_Ex <= RegWrite_RAU_Collecting;
				Imme_Collecting_Ex <= Imme_RAU_Collecting ;//
				Imme_Valid_Collecting_Ex <= Imme_Valid_RAU_Collecting ;//
				ALUop_Collecting_Ex <= ALUop_RAU_Collecting ;//
				MemWrite_Collecting_Ex <= MemWrite_RAU_Collecting ;//
				MemRead_Collecting_Ex <= MemRead_RAU_Collecting ;//
				Shared_Globalbar_Collecting_Ex <= Shared_Globalbar_RAU_Collecting ;//pass
				BEQ_Collecting_Ex <= BEQ_RAU_Collecting ;//pass
				BLT_Collecting_Ex <= BLT_RAU_Collecting ;//pass
				ScbID_Collecting_Ex <= ScbID_RAU_Collecting ;//pass
				ActiveMask_Collecting_Ex <= ActiveMask_RAU_Collecting ;//pass
				

				if (WE[0] == 1)
				begin
					oc_0_valid <= 1;
					oc_0_reg_id <= c_0_reg_id_in;
				end
				if (WE[1] == 1)
				begin
					oc_1_valid <= 1;
					oc_1_reg_id <= c_1_reg_id_in;
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
				if (oc_0_valid && OC_0_WE)
				begin
					oc_0_data <= oc_0_data_in;
					oc_0_rdy <= 1;
				end
				if (oc_1_valid && OC_1_WE)
				begin
					oc_1_data <= oc_1_data_in;
					oc_1_rdy <= 1;
				end
			end
		end
end

endmodule //OC_collector_unit