`timescale 1ns / 1ps

module MUX_ALU_MEM(
    input [3:0] MEM_Grt,
    input [3:0] ALU_Grt,

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


    output wire [255:0] Src1_Data_ALU,
    output wire [255:0] Src2_Data_ALU,

    output Valid_OC_ALU ,//use
    output [2:0] WarpID_OC_ALU,
    output [31:0] Instr_OC_ALU ,//pass
    output RegWrite_OC_ALU,
    output [15:0] Imme_OC_ALU ,//
    output Imme_Valid_OC_ALU ,//
    output [3:0] ALUop_OC_ALU ,//
    output MemWrite_OC_ALU ,//
    output MemRead_OC_ALU ,//
    output Shared_Globalbar_OC_ALU ,//pass
    output BEQ_OC_ALU ,//pass
    output BLT_OC_ALU ,//pass
    output [1:0] ScbID_OC_ALU ,//pass
    output [7:0] ActiveMask_OC_ALU,//pass
    output [4:0] Dst_OC_ALU,


    output wire [255:0] Src1_Data_MEM,
    output wire [255:0] Src2_Data_MEM,

    output Valid_OC_MEM ,//use
    output [2:0] WarpID_OC_MEM,
    output [31:0] Instr_OC_MEM ,//pass
    output RegWrite_OC_MEM,
    output [15:0] Imme_OC_MEM ,//
    output Imme_Valid_OC_MEM ,//
    output [3:0] ALUop_OC_MEM ,//
    output MemWrite_OC_MEM ,//
    output MemRead_OC_MEM ,//
    output Shared_Globalbar_OC_MEM ,//pass
    output BEQ_OC_MEM ,//pass
    output BLT_OC_MEM ,//pass
    output [1:0] ScbID_OC_MEM ,//pass
    output [7:0] ActiveMask_OC_MEM,//pass
    output [4:0] Dst_OC_MEM
);



MUX_4_1 MEM_MUX (
    .Grt(MEM_Grt),

    .oc_0_data_0(oc_0_data_0),
    .oc_1_data_0(oc_1_data_0),

    .WarpID_OC_Ex_0(WarpID_OC_Ex_0),
    .Instr_OC_Ex_0(Instr_OC_Ex_0) ,//pass
    .RegWrite_OC_Ex_0(RegWrite_OC_Ex_0),
    .Imme_OC_Ex_0(Imme_OC_Ex_0) ,//
    .Imme_Valid_OC_Ex_0(Imme_Valid_OC_Ex_0) ,//
    .ALUop_OC_Ex_0(ALUop_OC_Ex_0) ,//
    .MemWrite_OC_Ex_0(MemWrite_OC_Ex_0) ,//
    .MemRead_OC_Ex_0(MemRead_OC_Ex_0) ,//
    .Shared_Globalbar_OC_Ex_0(Shared_Globalbar_OC_Ex_0) ,//pass
    .BEQ_OC_Ex_0(BEQ_OC_Ex_0) ,//pass
    .BLT_OC_Ex_0(BLT_OC_Ex_0) ,//pass
    .ScbID_OC_Ex_0(ScbID_OC_Ex_0) ,//pass
    .ActiveMask_OC_Ex_0(ActiveMask_OC_Ex_0),//pass
    .Dst_OC_Ex_0(Dst_OC_Ex_0),

    .oc_0_data_1(oc_0_data_1),
    .oc_1_data_1(oc_1_data_1),

    .WarpID_OC_Ex_1(WarpID_OC_Ex_1),
    .Instr_OC_Ex_1(Instr_OC_Ex_1) ,//pass
    .RegWrite_OC_Ex_1(RegWrite_OC_Ex_1),
    .Imme_OC_Ex_1(Imme_OC_Ex_1) ,//
    .Imme_Valid_OC_Ex_1(Imme_Valid_OC_Ex_1) ,//
    .ALUop_OC_Ex_1(ALUop_OC_Ex_1) ,//
    .MemWrite_OC_Ex_1(MemWrite_OC_Ex_1) ,//
    .MemRead_OC_Ex_1(MemRead_OC_Ex_1) ,//
    .Shared_Globalbar_OC_Ex_1(Shared_Globalbar_OC_Ex_1) ,//pass
    .BEQ_OC_Ex_1(BEQ_OC_Ex_1) ,//pass
    .BLT_OC_Ex_1(BLT_OC_Ex_1) ,//pass
    .ScbID_OC_Ex_1(ScbID_OC_Ex_1) ,//pass
    .ActiveMask_OC_Ex_1(ActiveMask_OC_Ex_1),//pass
    .Dst_OC_Ex_1(Dst_OC_Ex_1),

    .oc_0_data_2(oc_0_data_2),
    .oc_1_data_2(oc_1_data_2),

    .WarpID_OC_Ex_2(WarpID_OC_Ex_2),
    .Instr_OC_Ex_2(Instr_OC_Ex_2) ,//pass
    .RegWrite_OC_Ex_2(RegWrite_OC_Ex_2),
    .Imme_OC_Ex_2(Imme_OC_Ex_2) ,//
    .Imme_Valid_OC_Ex_2(Imme_Valid_OC_Ex_2) ,//
    .ALUop_OC_Ex_2(ALUop_OC_Ex_2) ,//
    .MemWrite_OC_Ex_2(MemWrite_OC_Ex_2) ,//
    .MemRead_OC_Ex_2(MemRead_OC_Ex_2) ,//
    .Shared_Globalbar_OC_Ex_2(Shared_Globalbar_OC_Ex_2) ,//pass
    .BEQ_OC_Ex_2(BEQ_OC_Ex_2) ,//pass
    .BLT_OC_Ex_2(BLT_OC_Ex_2) ,//pass
    .ScbID_OC_Ex_2(ScbID_OC_Ex_2) ,//pass
    .ActiveMask_OC_Ex_2(ActiveMask_OC_Ex_2),//pass
    .Dst_OC_Ex_2(Dst_OC_Ex_2),
    
    .oc_0_data_3(oc_0_data_3),
    .oc_1_data_3(oc_1_data_3),

    .WarpID_OC_Ex_3(WarpID_OC_Ex_3),
    .Instr_OC_Ex_3(Instr_OC_Ex_3) ,//pass
    .RegWrite_OC_Ex_3(RegWrite_OC_Ex_3),
    .Imme_OC_Ex_3(Imme_OC_Ex_3) ,//
    .Imme_Valid_OC_Ex_3(Imme_Valid_OC_Ex_3) ,//
    .ALUop_OC_Ex_3(ALUop_OC_Ex_3) ,//
    .MemWrite_OC_Ex_3(MemWrite_OC_Ex_3) ,//
    .MemRead_OC_Ex_3(MemRead_OC_Ex_3) ,//
    .Shared_Globalbar_OC_Ex_3(Shared_Globalbar_OC_Ex_3) ,//pass
    .BEQ_OC_Ex_3(BEQ_OC_Ex_3) ,//pass
    .BLT_OC_Ex_3(BLT_OC_Ex_3) ,//pass
    .ScbID_OC_Ex_3(ScbID_OC_Ex_3) ,//pass
    .ActiveMask_OC_Ex_3(ActiveMask_OC_Ex_3),//pass
    .Dst_OC_Ex_3(Dst_OC_Ex_3),


    .oc_0_data(Src1_Data_MEM),
    .oc_1_data(Src2_Data_MEM),

    .Valid_OC_Ex(Valid_OC_MEM) ,//use
    .WarpID_OC_Ex(WarpID_OC_MEM),
    .Instr_OC_Ex(Instr_OC_MEM) ,//pass
    .RegWrite_OC_Ex(RegWrite_OC_MEM),
    .Imme_OC_Ex(Imme_OC_MEM) ,//
    .Imme_Valid_OC_Ex(Imme_Valid_OC_MEM) ,//
    .ALUop_OC_Ex(ALUop_OC_MEM) ,//
    .MemWrite_OC_Ex(MemWrite_OC_MEM) ,//
    .MemRead_OC_Ex(MemRead_OC_MEM) ,//
    .Shared_Globalbar_OC_Ex(Shared_Globalbar_OC_MEM) ,//pass
    .BEQ_OC_Ex(BEQ_OC_MEM) ,//pass
    .BLT_OC_Ex(BLT_OC_MEM) ,//pass
    .ScbID_OC_Ex(ScbID_OC_MEM) ,//pass
    .ActiveMask_OC_Ex(ActiveMask_OC_MEM),//pass
    .Dst_OC_Ex(Dst_OC_MEM)
);

MUX_4_1 ALU_MUX (
    .Grt(ALU_Grt),

    .oc_0_data_0(oc_0_data_0),
    .oc_1_data_0(oc_1_data_0),

    .WarpID_OC_Ex_0(WarpID_OC_Ex_0),
    .Instr_OC_Ex_0(Instr_OC_Ex_0) ,//pass
    .RegWrite_OC_Ex_0(RegWrite_OC_Ex_0),
    .Imme_OC_Ex_0(Imme_OC_Ex_0) ,//
    .Imme_Valid_OC_Ex_0(Imme_Valid_OC_Ex_0) ,//
    .ALUop_OC_Ex_0(ALUop_OC_Ex_0) ,//
    .MemWrite_OC_Ex_0(MemWrite_OC_Ex_0) ,//
    .MemRead_OC_Ex_0(MemRead_OC_Ex_0) ,//
    .Shared_Globalbar_OC_Ex_0(Shared_Globalbar_OC_Ex_0) ,//pass
    .BEQ_OC_Ex_0(BEQ_OC_Ex_0) ,//pass
    .BLT_OC_Ex_0(BLT_OC_Ex_0) ,//pass
    .ScbID_OC_Ex_0(ScbID_OC_Ex_0) ,//pass
    .ActiveMask_OC_Ex_0(ActiveMask_OC_Ex_0),//pass
    .Dst_OC_Ex_0(Dst_OC_Ex_0),

    .oc_0_data_1(oc_0_data_1),
    .oc_1_data_1(oc_1_data_1),

    .WarpID_OC_Ex_1(WarpID_OC_Ex_1),
    .Instr_OC_Ex_1(Instr_OC_Ex_1) ,//pass
    .RegWrite_OC_Ex_1(RegWrite_OC_Ex_1),
    .Imme_OC_Ex_1(Imme_OC_Ex_1) ,//
    .Imme_Valid_OC_Ex_1(Imme_Valid_OC_Ex_1) ,//
    .ALUop_OC_Ex_1(ALUop_OC_Ex_1) ,//
    .MemWrite_OC_Ex_1(MemWrite_OC_Ex_1) ,//
    .MemRead_OC_Ex_1(MemRead_OC_Ex_1) ,//
    .Shared_Globalbar_OC_Ex_1(Shared_Globalbar_OC_Ex_1) ,//pass
    .BEQ_OC_Ex_1(BEQ_OC_Ex_1) ,//pass
    .BLT_OC_Ex_1(BLT_OC_Ex_1) ,//pass
    .ScbID_OC_Ex_1(ScbID_OC_Ex_1) ,//pass
    .ActiveMask_OC_Ex_1(ActiveMask_OC_Ex_1),//pass
    .Dst_OC_Ex_1(Dst_OC_Ex_1),

    .oc_0_data_2(oc_0_data_2),
    .oc_1_data_2(oc_1_data_2),

    .WarpID_OC_Ex_2(WarpID_OC_Ex_2),
    .Instr_OC_Ex_2(Instr_OC_Ex_2) ,//pass
    .RegWrite_OC_Ex_2(RegWrite_OC_Ex_2),
    .Imme_OC_Ex_2(Imme_OC_Ex_2) ,//
    .Imme_Valid_OC_Ex_2(Imme_Valid_OC_Ex_2) ,//
    .ALUop_OC_Ex_2(ALUop_OC_Ex_2) ,//
    .MemWrite_OC_Ex_2(MemWrite_OC_Ex_2) ,//
    .MemRead_OC_Ex_2(MemRead_OC_Ex_2) ,//
    .Shared_Globalbar_OC_Ex_2(Shared_Globalbar_OC_Ex_2) ,//pass
    .BEQ_OC_Ex_2(BEQ_OC_Ex_2) ,//pass
    .BLT_OC_Ex_2(BLT_OC_Ex_2) ,//pass
    .ScbID_OC_Ex_2(ScbID_OC_Ex_2) ,//pass
    .ActiveMask_OC_Ex_2(ActiveMask_OC_Ex_2),//pass
    .Dst_OC_Ex_2(Dst_OC_Ex_2),
    
    .oc_0_data_3(oc_0_data_3),
    .oc_1_data_3(oc_1_data_3),

    .WarpID_OC_Ex_3(WarpID_OC_Ex_3),
    .Instr_OC_Ex_3(Instr_OC_Ex_3) ,//pass
    .RegWrite_OC_Ex_3(RegWrite_OC_Ex_3),
    .Imme_OC_Ex_3(Imme_OC_Ex_3) ,//
    .Imme_Valid_OC_Ex_3(Imme_Valid_OC_Ex_3) ,//
    .ALUop_OC_Ex_3(ALUop_OC_Ex_3) ,//
    .MemWrite_OC_Ex_3(MemWrite_OC_Ex_3) ,//
    .MemRead_OC_Ex_3(MemRead_OC_Ex_3) ,//
    .Shared_Globalbar_OC_Ex_3(Shared_Globalbar_OC_Ex_3) ,//pass
    .BEQ_OC_Ex_3(BEQ_OC_Ex_3) ,//pass
    .BLT_OC_Ex_3(BLT_OC_Ex_3) ,//pass
    .ScbID_OC_Ex_3(ScbID_OC_Ex_3) ,//pass
    .ActiveMask_OC_Ex_3(ActiveMask_OC_Ex_3),//pass
    .Dst_OC_Ex_3(Dst_OC_Ex_3),


    .oc_0_data(Src1_Data_ALU),
    .oc_1_data(Src2_Data_ALU),

    .Valid_OC_Ex(Valid_OC_ALU) ,//use
    .WarpID_OC_Ex(WarpID_OC_ALU),
    .Instr_OC_Ex(Instr_OC_ALU) ,//pass
    .RegWrite_OC_Ex(RegWrite_OC_ALU),
    .Imme_OC_Ex(Imme_OC_ALU) ,//
    .Imme_Valid_OC_Ex(Imme_Valid_OC_ALU) ,//
    .ALUop_OC_Ex(ALUop_OC_ALU) ,//
    .MemWrite_OC_Ex(MemWrite_OC_ALU) ,//
    .MemRead_OC_Ex(MemRead_OC_ALU) ,//
    .Shared_Globalbar_OC_Ex(Shared_Globalbar_OC_ALU) ,//pass
    .BEQ_OC_Ex(BEQ_OC_ALU) ,//pass
    .BLT_OC_Ex(BLT_OC_ALU) ,//pass
    .ScbID_OC_Ex(ScbID_OC_ALU) ,//pass
    .ActiveMask_OC_Ex(ActiveMask_OC_ALU),//pass
    .Dst_OC_Ex(Dst_OC_ALU)
);

endmodule