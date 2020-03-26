module MUX_4_1 (
    input [3:0] Grt,

    input wire [255:0] oc_0_data_0,
    input wire [255:0] oc_1_data_0,

    input Valid_Collecting_Ex_0 ,//use
    input [31:0] Instr_Collecting_Ex_0 ,//pass
    input RegWrite_Collecting_Ex_0,
    input [15:0] Imme_Collecting_Ex_0 ,//
    input Imme_Valid_Collecting_Ex_0 ,//
    input [3:0] ALUop_Collecting_Ex_0 ,//
    input MemWrite_Collecting_Ex_0 ,//
    input MemRead_Collecting_Ex_0 ,//
    input Shared_Globalbar_Collecting_Ex_0 ,//pass
    input BEQ_Collecting_Ex_0 ,//pass
    input BLT_Collecting_Ex_0 ,//pass
    input [1:0] ScbID_Collecting_Ex_0 ,//pass
    input [7:0] ActiveMask_Collecting_Ex_0,//pass
    input [4:0] Dst_Collecting_Ex_0,

    input wire [255:0] oc_0_data_1,
    input wire [255:0] oc_1_data_1,

    input Valid_Collecting_Ex_1 ,//use
    input [31:0] Instr_Collecting_Ex_1 ,//pass
    input RegWrite_Collecting_Ex_1,
    input [15:0] Imme_Collecting_Ex_1 ,//
    input Imme_Valid_Collecting_Ex_1 ,//
    input [3:0] ALUop_Collecting_Ex_1 ,//
    input MemWrite_Collecting_Ex_1 ,//
    input MemRead_Collecting_Ex_1 ,//
    input Shared_Globalbar_Collecting_Ex_1 ,//pass
    input BEQ_Collecting_Ex_1 ,//pass
    input BLT_Collecting_Ex_1 ,//pass
    input [1:0] ScbID_Collecting_Ex_1 ,//pass
    input [7:0] ActiveMask_Collecting_Ex_1,//pass
    input [4:0] Dst_Collecting_Ex_1,

    input wire [255:0] oc_0_data_2,
    input wire [255:0] oc_1_data_2,

    input Valid_Collecting_Ex_2 ,//use
    input [31:0] Instr_Collecting_Ex_2 ,//pass
    input RegWrite_Collecting_Ex_2,
    input [15:0] Imme_Collecting_Ex_2 ,//
    input Imme_Valid_Collecting_Ex_2 ,//
    input [3:0] ALUop_Collecting_Ex_2 ,//
    input MemWrite_Collecting_Ex_2 ,//
    input MemRead_Collecting_Ex_2 ,//
    input Shared_Globalbar_Collecting_Ex_2 ,//pass
    input BEQ_Collecting_Ex_2 ,//pass
    input BLT_Collecting_Ex_2 ,//pass
    input [1:0] ScbID_Collecting_Ex_2 ,//pass
    input [7:0] ActiveMask_Collecting_Ex_2,//pass
    input [4:0] Dst_Collecting_Ex_2,

    input wire [255:0] oc_0_data_3,
    input wire [255:0] oc_1_data_3,

    input Valid_Collecting_Ex_3 ,//use
    input [31:0] Instr_Collecting_Ex_3 ,//pass
    input RegWrite_Collecting_Ex_3,
    input [15:0] Imme_Collecting_Ex_3 ,//
    input Imme_Valid_Collecting_Ex_3 ,//
    input [3:0] ALUop_Collecting_Ex_3 ,//
    input MemWrite_Collecting_Ex_3 ,//
    input MemRead_Collecting_Ex_3 ,//
    input Shared_Globalbar_Collecting_Ex_3 ,//pass
    input BEQ_Collecting_Ex_3 ,//pass
    input BLT_Collecting_Ex_3 ,//pass
    input [1:0] ScbID_Collecting_Ex_3 ,//pass
    input [7:0] ActiveMask_Collecting_Ex_3,//pass
    input [4:0] Dst_Collecting_Ex_3,


    output wire [255:0] oc_0_data,
    output wire [255:0] oc_1_data,

    output Valid_Collecting_Ex ,//use
    output [31:0] Instr_Collecting_Ex ,//pass
    output RegWrite_Collecting_Ex,
    output [15:0] Imme_Collecting_Ex ,//
    output Imme_Valid_Collecting_Ex ,//
    output [3:0] ALUop_Collecting_Ex ,//
    output MemWrite_Collecting_Ex ,//
    output MemRead_Collecting_Ex ,//
    output Shared_Globalbar_Collecting_Ex ,//pass
    output BEQ_Collecting_Ex ,//pass
    output BLT_Collecting_Ex ,//pass
    output [1:0] ScbID_Collecting_Ex ,//pass
    output [7:0] ActiveMask_Collecting_Ex,//pass
    output [4:0] Dst_Collecting_Ex,

    output reg Valid_EX
);

always @ (*)
begin
    Valid_EX = |Grt;

    case (Grt)
    0001:
        begin
            oc_0_data = oc_0_data_0;
            oc_1_data = oc_1_data_0;

            Valid_Collecting_Ex = Valid_Collecting_Ex_0 ;//use
            Instr_Collecting_Ex = Instr_Collecting_Ex_0 ;//pass
            RegWrite_Collecting_Ex = RegWrite_Collecting_Ex_0;
            Imme_Collecting_Ex = Imme_Collecting_Ex_0 ;//
            Imme_Valid_Collecting_Ex = Imme_Valid_Collecting_Ex_0 ;//
            ALUop_Collecting_Ex = ALUop_Collecting_Ex_0 ;//
            MemWrite_Collecting_Ex = MemWrite_Collecting_Ex_0;//
            MemRead_Collecting_Ex = MemRead_Collecting_Ex_0 ;//
            Shared_Globalbar_Collecting_Ex = Shared_Globalbar_Collecting_Ex_0;//pass
            BEQ_Collecting_Ex = BEQ_Collecting_Ex_0 ;//pass
            BLT_Collecting_Ex = BLT_Collecting_Ex_0 ;//pass
            ScbID_Collecting_Ex = ScbID_Collecting_Ex_0 ;//pass
            ActiveMask_Collecting_Ex = ActiveMask_Collecting_Ex_0;//pass
            Dst_Collecting_Ex = Dst_Collecting_Ex_0;
        end

    0010:
        begin
            oc_0_data = oc_0_data_1;
            oc_1_data = oc_1_data_1;

            Valid_Collecting_Ex = Valid_Collecting_Ex_1 ;//use
            Instr_Collecting_Ex = Instr_Collecting_Ex_1 ;//pass
            RegWrite_Collecting_Ex = RegWrite_Collecting_Ex_1;
            Imme_Collecting_Ex = Imme_Collecting_Ex_1 ;//
            Imme_Valid_Collecting_Ex = Imme_Valid_Collecting_Ex_1 ;//
            ALUop_Collecting_Ex = ALUop_Collecting_Ex_1 ;//
            MemWrite_Collecting_Ex = MemWrite_Collecting_Ex_1;//
            MemRead_Collecting_Ex = MemRead_Collecting_Ex_1 ;//
            Shared_Globalbar_Collecting_Ex = Shared_Globalbar_Collecting_Ex_1;//pass
            BEQ_Collecting_Ex = BEQ_Collecting_Ex_1 ;//pass
            BLT_Collecting_Ex = BLT_Collecting_Ex_1 ;//pass
            ScbID_Collecting_Ex = ScbID_Collecting_Ex_1 ;//pass
            ActiveMask_Collecting_Ex = ActiveMask_Collecting_Ex_1;//pass
            Dst_Collecting_Ex = Dst_Collecting_Ex_1;
        end
    
    0100:
        begin
            oc_0_data = oc_0_data_2;
            oc_1_data = oc_1_data_2;

            Valid_Collecting_Ex = Valid_Collecting_Ex_2 ;//use
            Instr_Collecting_Ex = Instr_Collecting_Ex_2 ;//pass
            RegWrite_Collecting_Ex = RegWrite_Collecting_Ex_2;
            Imme_Collecting_Ex = Imme_Collecting_Ex_2 ;//
            Imme_Valid_Collecting_Ex = Imme_Valid_Collecting_Ex_2 ;//
            ALUop_Collecting_Ex = ALUop_Collecting_Ex_2 ;//
            MemWrite_Collecting_Ex = MemWrite_Collecting_Ex_2;//
            MemRead_Collecting_Ex = MemRead_Collecting_Ex_2 ;//
            Shared_Globalbar_Collecting_Ex = Shared_Globalbar_Collecting_Ex_2;//pass
            BEQ_Collecting_Ex = BEQ_Collecting_Ex_2 ;//pass
            BLT_Collecting_Ex = BLT_Collecting_Ex_2 ;//pass
            ScbID_Collecting_Ex = ScbID_Collecting_Ex_2 ;//pass
            ActiveMask_Collecting_Ex = ActiveMask_Collecting_Ex_2;//pass
            Dst_Collecting_Ex = Dst_Collecting_Ex_2;
        end
    
    default:
        begin
            oc_0_data = oc_0_data_3;
            oc_1_data = oc_1_data_3;

            Valid_Collecting_Ex = Valid_Collecting_Ex_3 ;//use
            Instr_Collecting_Ex = Instr_Collecting_Ex_3 ;//pass
            RegWrite_Collecting_Ex = RegWrite_Collecting_Ex_3;
            Imme_Collecting_Ex = Imme_Collecting_Ex_3 ;//
            Imme_Valid_Collecting_Ex = Imme_Valid_Collecting_Ex_3 ;//
            ALUop_Collecting_Ex = ALUop_Collecting_Ex_3 ;//
            MemWrite_Collecting_Ex = MemWrite_Collecting_Ex_3;//
            MemRead_Collecting_Ex = MemRead_Collecting_Ex_3 ;//
            Shared_Globalbar_Collecting_Ex = Shared_Globalbar_Collecting_Ex_3;//pass
            BEQ_Collecting_Ex = BEQ_Collecting_Ex_3 ;//pass
            BLT_Collecting_Ex = BLT_Collecting_Ex_3 ;//pass
            ScbID_Collecting_Ex = ScbID_Collecting_Ex_3 ;//pass
            ActiveMask_Collecting_Ex = ActiveMask_Collecting_Ex_3;//pass
            Dst_Collecting_Ex = Dst_Collecting_Ex_3;
        end



end

endmodule