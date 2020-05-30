`timescale 1ns / 1ps

module MUX_4_1 (
    input [3:0] Grt,

    input wire [255:0] oc_0_data_0,
    input wire [255:0] oc_1_data_0,

    input [2:0] WarpID_OC_Ex_0,
    input [31:0] Instr_OC_Ex_0 ,//pass
    input RegWrite_OC_Ex_0,
    input [15:0] Imme_OC_Ex_0 ,//
    input Imme_Valid_OC_Ex_0 ,//
    input [3:0] ALUop_OC_Ex_0 ,//
    input MemWrite_OC_Ex_0 ,//
    input MemRead_OC_Ex_0 ,//
    input Shared_Globalbar_OC_Ex_0 ,//pass
    input BEQ_OC_Ex_0 ,//pass
    input BLT_OC_Ex_0 ,//pass
    input [1:0] ScbID_OC_Ex_0 ,//pass
    input [7:0] ActiveMask_OC_Ex_0,//pass
    input [4:0] Dst_OC_Ex_0,

    input wire [255:0] oc_0_data_1,
    input wire [255:0] oc_1_data_1,

    input [2:0] WarpID_OC_Ex_1,
    input [31:0] Instr_OC_Ex_1 ,//pass
    input RegWrite_OC_Ex_1,
    input [15:0] Imme_OC_Ex_1 ,//
    input Imme_Valid_OC_Ex_1 ,//
    input [3:0] ALUop_OC_Ex_1 ,//
    input MemWrite_OC_Ex_1 ,//
    input MemRead_OC_Ex_1 ,//
    input Shared_Globalbar_OC_Ex_1 ,//pass
    input BEQ_OC_Ex_1 ,//pass
    input BLT_OC_Ex_1 ,//pass
    input [1:0] ScbID_OC_Ex_1 ,//pass
    input [7:0] ActiveMask_OC_Ex_1,//pass
    input [4:0] Dst_OC_Ex_1,

    input wire [255:0] oc_0_data_2,
    input wire [255:0] oc_1_data_2,

    input [2:0] WarpID_OC_Ex_2,
    input [31:0] Instr_OC_Ex_2 ,//pass
    input RegWrite_OC_Ex_2,
    input [15:0] Imme_OC_Ex_2 ,//
    input Imme_Valid_OC_Ex_2 ,//
    input [3:0] ALUop_OC_Ex_2 ,//
    input MemWrite_OC_Ex_2 ,//
    input MemRead_OC_Ex_2 ,//
    input Shared_Globalbar_OC_Ex_2 ,//pass
    input BEQ_OC_Ex_2 ,//pass
    input BLT_OC_Ex_2 ,//pass
    input [1:0] ScbID_OC_Ex_2 ,//pass
    input [7:0] ActiveMask_OC_Ex_2,//pass
    input [4:0] Dst_OC_Ex_2,

    input wire [255:0] oc_0_data_3,
    input wire [255:0] oc_1_data_3,

    input [2:0] WarpID_OC_Ex_3,
    input [31:0] Instr_OC_Ex_3 ,//pass
    input RegWrite_OC_Ex_3,
    input [15:0] Imme_OC_Ex_3 ,//
    input Imme_Valid_OC_Ex_3 ,//
    input [3:0] ALUop_OC_Ex_3 ,//
    input MemWrite_OC_Ex_3 ,//
    input MemRead_OC_Ex_3 ,//
    input Shared_Globalbar_OC_Ex_3 ,//pass
    input BEQ_OC_Ex_3 ,//pass
    input BLT_OC_Ex_3 ,//pass
    input [1:0] ScbID_OC_Ex_3 ,//pass
    input [7:0] ActiveMask_OC_Ex_3,//pass
    input [4:0] Dst_OC_Ex_3,


    output reg [255:0] oc_0_data,
    output reg [255:0] oc_1_data,

    output reg Valid_OC_Ex,
    
    output reg [2:0] WarpID_OC_Ex,
    output reg [31:0] Instr_OC_Ex ,//pass
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

always @ (*)
begin
    Valid_OC_Ex = |Grt;

    case (Grt)
    4'b0001:
        begin
            oc_0_data = oc_0_data_0;
            oc_1_data = oc_1_data_0;

            WarpID_OC_Ex = WarpID_OC_Ex_0;
            Instr_OC_Ex = Instr_OC_Ex_0 ;//pass
            RegWrite_OC_Ex = RegWrite_OC_Ex_0;
            Imme_OC_Ex = Imme_OC_Ex_0 ;//
            Imme_Valid_OC_Ex = Imme_Valid_OC_Ex_0 ;//
            ALUop_OC_Ex = ALUop_OC_Ex_0 ;//
            MemWrite_OC_Ex = MemWrite_OC_Ex_0;//
            MemRead_OC_Ex = MemRead_OC_Ex_0 ;//
            Shared_Globalbar_OC_Ex = Shared_Globalbar_OC_Ex_0;//pass
            BEQ_OC_Ex = BEQ_OC_Ex_0 ;//pass
            BLT_OC_Ex = BLT_OC_Ex_0 ;//pass
            ScbID_OC_Ex = ScbID_OC_Ex_0 ;//pass
            ActiveMask_OC_Ex = ActiveMask_OC_Ex_0;//pass
            Dst_OC_Ex = Dst_OC_Ex_0;
        end

    4'b0010:
        begin
            oc_0_data = oc_0_data_1;
            oc_1_data = oc_1_data_1;

            WarpID_OC_Ex = WarpID_OC_Ex_1;
            Instr_OC_Ex = Instr_OC_Ex_1 ;//pass
            RegWrite_OC_Ex = RegWrite_OC_Ex_1;
            Imme_OC_Ex = Imme_OC_Ex_1 ;//
            Imme_Valid_OC_Ex = Imme_Valid_OC_Ex_1 ;//
            ALUop_OC_Ex = ALUop_OC_Ex_1 ;//
            MemWrite_OC_Ex = MemWrite_OC_Ex_1;//
            MemRead_OC_Ex = MemRead_OC_Ex_1 ;//
            Shared_Globalbar_OC_Ex = Shared_Globalbar_OC_Ex_1;//pass
            BEQ_OC_Ex = BEQ_OC_Ex_1 ;//pass
            BLT_OC_Ex = BLT_OC_Ex_1 ;//pass
            ScbID_OC_Ex = ScbID_OC_Ex_1 ;//pass
            ActiveMask_OC_Ex = ActiveMask_OC_Ex_1;//pass
            Dst_OC_Ex = Dst_OC_Ex_1;
        end
    
    4'b0100:
        begin
            oc_0_data = oc_0_data_2;
            oc_1_data = oc_1_data_2;

            WarpID_OC_Ex = WarpID_OC_Ex_2;
            Instr_OC_Ex = Instr_OC_Ex_2 ;//pass
            RegWrite_OC_Ex = RegWrite_OC_Ex_2;
            Imme_OC_Ex = Imme_OC_Ex_2 ;//
            Imme_Valid_OC_Ex = Imme_Valid_OC_Ex_2 ;//
            ALUop_OC_Ex = ALUop_OC_Ex_2 ;//
            MemWrite_OC_Ex = MemWrite_OC_Ex_2;//
            MemRead_OC_Ex = MemRead_OC_Ex_2 ;//
            Shared_Globalbar_OC_Ex = Shared_Globalbar_OC_Ex_2;//pass
            BEQ_OC_Ex = BEQ_OC_Ex_2 ;//pass
            BLT_OC_Ex = BLT_OC_Ex_2 ;//pass
            ScbID_OC_Ex = ScbID_OC_Ex_2 ;//pass
            ActiveMask_OC_Ex = ActiveMask_OC_Ex_2;//pass
            Dst_OC_Ex = Dst_OC_Ex_2;
        end
    
    default:
        begin
            oc_0_data = oc_0_data_3;
            oc_1_data = oc_1_data_3;

            WarpID_OC_Ex = WarpID_OC_Ex_3;
            Instr_OC_Ex = Instr_OC_Ex_3 ;//pass
            RegWrite_OC_Ex = RegWrite_OC_Ex_3;
            Imme_OC_Ex = Imme_OC_Ex_3 ;//
            Imme_Valid_OC_Ex = Imme_Valid_OC_Ex_3 ;//
            ALUop_OC_Ex = ALUop_OC_Ex_3 ;//
            MemWrite_OC_Ex = MemWrite_OC_Ex_3;//
            MemRead_OC_Ex = MemRead_OC_Ex_3 ;//
            Shared_Globalbar_OC_Ex = Shared_Globalbar_OC_Ex_3;//pass
            BEQ_OC_Ex = BEQ_OC_Ex_3 ;//pass
            BLT_OC_Ex = BLT_OC_Ex_3 ;//pass
            ScbID_OC_Ex = ScbID_OC_Ex_3 ;//pass
            ActiveMask_OC_Ex = ActiveMask_OC_Ex_3;//pass
            Dst_OC_Ex = Dst_OC_Ex_3;
        end
    endcase


end

endmodule