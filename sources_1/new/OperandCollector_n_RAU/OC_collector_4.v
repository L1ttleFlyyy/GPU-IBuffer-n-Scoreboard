module OC_collector_4(
    input wire rst,
    input wire clk,

    input wire [3:0] ALU_Grt_Sched_OC,
    input wire [3:0] MEM_Grt_Sched_OC,

    input wire Valid_RAU_OC ,//use
    input wire [31:0] Instr_RAU_OC ,//pass

    input wire [2:0] WarpID_RAU_OC,
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

    input [2:0] Src1_OCID_RAU_OC,
    input [2:0] Src2_OCID_RAU_OC,

    input wire [255:0] DataOut_0,
    input wire [255:0] DataOut_1,
    input wire [255:0] DataOut_2,
    input wire [255:0] DataOut_3,//不能写wire？

    
    input wire [3:0] ocid_0,
    input wire [3:0] ocid_1,
    input wire [3:0] ocid_2,
    input wire [3:0] ocid_3,

    input wire [1:0]Src1_Phy_Bank_ID,
    input wire [1:0]Src2_Phy_Bank_ID,

    input wire [1:0] SPEslot_RAU_OC,
    input wire [255:0] SPEvalue_RAU_OC,
    input wire [1:0] SPEv2slot_RAU_OC,
    input wire [255:0] SPEv2value_RAU_OC,

    input same_OC_0,
    input same_OC_1,
    input same_OC_2,
    input same_OC_3,

    output wire [255:0] oc_0_data_0,
    output wire [255:0] oc_1_data_0,

    output RDY_0, 
    output valid_0,

    output [2:0] WarpID_OC_Ex_0,
    output Valid_OC_Ex_0 ,//use
    output [31:0] Instr_OC_Ex_0 ,//pass
    output RegWrite_OC_Ex_0,
    output [15:0] Imme_OC_Ex_0 ,//
    output Imme_Valid_OC_Ex_0 ,//
    output [3:0] ALUop_OC_Ex_0 ,//
    output MemWrite_OC_Ex_0 ,//
    output MemRead_OC_Ex_0 ,//
    output Shared_Globalbar_OC_Ex_0 ,//pass
    output BEQ_OC_Ex_0 ,//pass
    output BLT_OC_Ex_0 ,//pass
    output [1:0] ScbID_OC_Ex_0 ,//pass
    output [7:0] ActiveMask_OC_Ex_0,//pass
    output [4:0] Dst_OC_Ex_0,

    output wire [255:0] oc_0_data_1,
    output wire [255:0] oc_1_data_1,

    output RDY_1, 
    output valid_1,

    output [2:0] WarpID_OC_Ex_1,
    output Valid_OC_Ex_1 ,//use
    output [31:0] Instr_OC_Ex_1 ,//pass
    output RegWrite_OC_Ex_1,
    output [15:0] Imme_OC_Ex_1 ,//
    output Imme_Valid_OC_Ex_1 ,//
    output [3:0] ALUop_OC_Ex_1 ,//
    output MemWrite_OC_Ex_1 ,//
    output MemRead_OC_Ex_1 ,//
    output Shared_Globalbar_OC_Ex_1 ,//pass
    output BEQ_OC_Ex_1 ,//pass
    output BLT_OC_Ex_1 ,//pass
    output [1:0] ScbID_OC_Ex_1 ,//pass
    output [7:0] ActiveMask_OC_Ex_1,//pass
    output [4:0] Dst_OC_Ex_1,
    output wire [255:0] oc_0_data_2,
    output wire [255:0] oc_1_data_2,

    output RDY_2, 
    output valid_2,

    output [2:0] WarpID_OC_Ex_2,
    output Valid_OC_Ex_2 ,//use
    output [31:0] Instr_OC_Ex_2 ,//pass
    output RegWrite_OC_Ex_2,
    output [15:0] Imme_OC_Ex_2 ,//
    output Imme_Valid_OC_Ex_2 ,//
    output [3:0] ALUop_OC_Ex_2 ,//
    output MemWrite_OC_Ex_2 ,//
    output MemRead_OC_Ex_2 ,//
    output Shared_Globalbar_OC_Ex_2 ,//pass
    output BEQ_OC_Ex_2 ,//pass
    output BLT_OC_Ex_2 ,//pass
    output [1:0] ScbID_OC_Ex_2 ,//pass
    output [7:0] ActiveMask_OC_Ex_2,//pass
    output [4:0] Dst_OC_Ex_2,
    output wire [255:0] oc_0_data_3,
    output wire [255:0] oc_1_data_3,

    output RDY_3, 
    output valid_3,

    output [2:0] WarpID_OC_Ex_3,
    output Valid_OC_Ex_3 ,//use
    output [31:0] Instr_OC_Ex_3 ,//pass
    output RegWrite_OC_Ex_3,
    output [15:0] Imme_OC_Ex_3 ,//
    output Imme_Valid_OC_Ex_3 ,//
    output [3:0] ALUop_OC_Ex_3 ,//
    output MemWrite_OC_Ex_3 ,//
    output MemRead_OC_Ex_3 ,//
    output Shared_Globalbar_OC_Ex_3 ,//pass
    output BEQ_OC_Ex_3 ,//pass
    output BLT_OC_Ex_3 ,//pass
    output [1:0] ScbID_OC_Ex_3 ,//pass
    output [7:0] ActiveMask_OC_Ex_3,//pass
    output [4:0] Dst_OC_Ex_3,

    input wire Src2_Valid,
    input wire Src1_Valid

);

wire bank_0_valid = ocid_0[3];
wire bank_1_valid = ocid_1[3];
wire bank_2_valid = ocid_2[3];
wire bank_3_valid = ocid_3[3];

wire [1:0]WE_0 = Valid_RAU_OC?{((Src2_OCID_RAU_OC[2:1] == 2'b00) & Src2_Valid) , ((Src1_OCID_RAU_OC[2:1] == 2'b00) & Src1_Valid)}:2'b00;
wire [1:0]WE_1 = Valid_RAU_OC?{((Src2_OCID_RAU_OC[2:1] == 2'b01) & Src2_Valid) , ((Src1_OCID_RAU_OC[2:1] == 2'b01) & Src1_Valid)}:2'b00;
wire [1:0]WE_2 = Valid_RAU_OC?{((Src2_OCID_RAU_OC[2:1] == 2'b10) & Src2_Valid) , ((Src1_OCID_RAU_OC[2:1] == 2'b10) & Src1_Valid)}:2'b00;
wire [1:0]WE_3 = Valid_RAU_OC?{((Src2_OCID_RAU_OC[2:1] == 2'b11) & Src2_Valid) , ((Src1_OCID_RAU_OC[2:1] == 2'b11) & Src1_Valid)}:2'b00;

wire [1:0] SPEslot_RAU_OC_0 = {(Src2_OCID_RAU_OC[2:1] == 2'b00) & Src2_Valid & SPEslot_RAU_OC[1] , (Src1_OCID_RAU_OC[2:1] == 2'b00) & Src1_Valid & SPEslot_RAU_OC[0]};
wire [1:0] SPEslot_RAU_OC_1 = {(Src2_OCID_RAU_OC[2:1] == 2'b01) & Src2_Valid & SPEslot_RAU_OC[1] , (Src1_OCID_RAU_OC[2:1] == 2'b01) & Src1_Valid & SPEslot_RAU_OC[0]};
wire [1:0] SPEslot_RAU_OC_2 = {(Src2_OCID_RAU_OC[2:1] == 2'b10) & Src2_Valid & SPEslot_RAU_OC[1] , (Src1_OCID_RAU_OC[2:1] == 2'b10) & Src1_Valid & SPEslot_RAU_OC[0]};
wire [1:0] SPEslot_RAU_OC_3 = {(Src2_OCID_RAU_OC[2:1] == 2'b11) & Src2_Valid & SPEslot_RAU_OC[1] , (Src1_OCID_RAU_OC[2:1] == 2'b11) & Src1_Valid & SPEslot_RAU_OC[0]};

wire [1:0] SPEv2slot_RAU_OC_0 = {(Src2_OCID_RAU_OC[2:1] == 2'b00) & Src2_Valid & SPEv2slot_RAU_OC[1] , (Src1_OCID_RAU_OC[2:1] == 2'b00) & Src1_Valid & SPEv2slot_RAU_OC[0]};
wire [1:0] SPEv2slot_RAU_OC_1 = {(Src2_OCID_RAU_OC[2:1] == 2'b01) & Src2_Valid & SPEv2slot_RAU_OC[1] , (Src1_OCID_RAU_OC[2:1] == 2'b01) & Src1_Valid & SPEv2slot_RAU_OC[0]};
wire [1:0] SPEv2slot_RAU_OC_2 = {(Src2_OCID_RAU_OC[2:1] == 2'b10) & Src2_Valid & SPEv2slot_RAU_OC[1] , (Src1_OCID_RAU_OC[2:1] == 2'b10) & Src1_Valid & SPEv2slot_RAU_OC[0]};
wire [1:0] SPEv2slot_RAU_OC_3 = {(Src2_OCID_RAU_OC[2:1] == 2'b11) & Src2_Valid & SPEv2slot_RAU_OC[1] , (Src1_OCID_RAU_OC[2:1] == 2'b11) & Src1_Valid & SPEv2slot_RAU_OC[0]};

wire RE_0 = ALU_Grt_Sched_OC[0] | MEM_Grt_Sched_OC[0];
wire RE_1 = ALU_Grt_Sched_OC[1] | MEM_Grt_Sched_OC[1];
wire RE_2 = ALU_Grt_Sched_OC[2] | MEM_Grt_Sched_OC[2];
wire RE_3 = ALU_Grt_Sched_OC[3] | MEM_Grt_Sched_OC[3];


OC_collector_unit#(
    .ocid(0)
) unit0(
    .clk(clk), 
    .rst(rst),
    .SPEslot_RAU_OC(SPEslot_RAU_OC_0),
    .SPEvalue_RAU_OC(SPEvalue_RAU_OC),
    .SPEv2slot_RAU_OC(SPEv2slot_RAU_OC_0),
    .SPEv2value_RAU_OC(SPEv2value_RAU_OC),
    .Src1_Phy_Bank_ID(Src1_Phy_Bank_ID),
    .Src2_Phy_Bank_ID(Src2_Phy_Bank_ID),
    .same_OC_0(same_OC_0),
    .same_OC_1(same_OC_1),
    .same_OC_2(same_OC_2),
    .same_OC_3(same_OC_3),


    .bk_0_data(DataOut_0), 
    .bk_1_data(DataOut_1), 
    .bk_2_data(DataOut_2), 
    .bk_3_data(DataOut_3),
    .bk_0_ocid(ocid_0[2:0]),
    .bk_1_ocid(ocid_1[2:0]),
    .bk_2_ocid(ocid_2[2:0]),
    .bk_3_ocid(ocid_3[2:0]),
    .bk_0_vld(bank_0_valid),
    .bk_1_vld(bank_1_valid),
    .bk_2_vld(bank_2_valid),
    .bk_3_vld(bank_3_valid),

    .WE(WE_0),
    .RE(RE_0), 

    .WarpID_RAU_OC(WarpID_RAU_OC),
    .Valid_RAU_OC(Valid_RAU_OC) ,//use
    .Instr_RAU_OC(Instr_RAU_OC) ,//pass
    .RegWrite_RAU_OC(RegWrite_RAU_OC),
    .Imme_RAU_OC(Imme_RAU_OC) ,//
    .Imme_Valid_RAU_OC(Imme_Valid_RAU_OC) ,//
    .ALUop_RAU_OC(ALUop_RAU_OC) ,//
    .MemWrite_RAU_OC(MemWrite_RAU_OC) ,//
    .MemRead_RAU_OC(MemRead_RAU_OC) ,//
    .Shared_Globalbar_RAU_OC(Shared_Globalbar_RAU_OC) ,//pass
    .BEQ_RAU_OC(BEQ_RAU_OC) ,//pass
    .BLT_RAU_OC(BLT_RAU_OC) ,//pass
    .ScbID_RAU_OC(ScbID_RAU_OC) ,//pass
    .ActiveMask_RAU_OC(ActiveMask_RAU_OC) ,//pass
    .Dst_RAU_OC(Dst_RAU_OC),  
    .RDY(RDY_0), 
    .valid(valid_0),

    .oc_0_data(oc_0_data_0),
    .oc_1_data(oc_1_data_0),

    .Valid_OC_Ex(Valid_OC_Ex_0) ,//use
    .Instr_OC_Ex(Instr_OC_Ex_0) ,//pass

    .WarpID_OC_Ex(WarpID_OC_Ex_0),
    .RegWrite_OC_Ex(RegWrite_OC_Ex_0),
    .Imme_OC_Ex(Imme_OC_Ex_0) ,//
    .Imme_Valid_OC_Ex(Imme_Valid_OC_Ex_0) ,//
    .ALUop_OC_Ex(ALUop_OC_Ex_0) ,//
    .MemWrite_OC_Ex(MemWrite_OC_Ex_0) ,//
    .MemRead_OC_Ex(MemRead_OC_Ex_0) ,//  
    .Shared_Globalbar_OC_Ex(Shared_Globalbar_OC_Ex_0) ,//pass
    .BEQ_OC_Ex(BEQ_OC_Ex_0) ,//pass
    .BLT_OC_Ex(BLT_OC_Ex_0) ,//pass
    .ScbID_OC_Ex(ScbID_OC_Ex_0) ,//pass
    .ActiveMask_OC_Ex(ActiveMask_OC_Ex_0),//pass
    .Dst_OC_Ex(Dst_OC_Ex_0)
);

OC_collector_unit#(
    .ocid(1)
) unit1(
    .clk(clk), 
    .rst(rst),
    .SPEslot_RAU_OC(SPEslot_RAU_OC_1),
    .SPEvalue_RAU_OC(SPEvalue_RAU_OC),
    .SPEv2slot_RAU_OC(SPEv2slot_RAU_OC_1),
    .SPEv2value_RAU_OC(SPEv2value_RAU_OC),
    .Src1_Phy_Bank_ID(Src1_Phy_Bank_ID),
    .Src2_Phy_Bank_ID(Src2_Phy_Bank_ID),
    .same_OC_0(same_OC_0),
    .same_OC_1(same_OC_1),
    .same_OC_2(same_OC_2),
    .same_OC_3(same_OC_3),

    .bk_0_data(DataOut_0), 
    .bk_1_data(DataOut_1), 
    .bk_2_data(DataOut_2), 
    .bk_3_data(DataOut_3),
    .bk_0_ocid(ocid_0[2:0]),
    .bk_1_ocid(ocid_1[2:0]),
    .bk_2_ocid(ocid_2[2:0]),
    .bk_3_ocid(ocid_3[2:0]),
    .bk_0_vld(bank_0_valid),
    .bk_1_vld(bank_1_valid),
    .bk_2_vld(bank_2_valid),
    .bk_3_vld(bank_3_valid),

    .WE(WE_1),
    .RE(RE_1), 


    .WarpID_RAU_OC(WarpID_RAU_OC),
    .Valid_RAU_OC(Valid_RAU_OC) ,//use
    .Instr_RAU_OC(Instr_RAU_OC) ,//pass
    .RegWrite_RAU_OC(RegWrite_RAU_OC),

    .RegWrite_OC_Ex(RegWrite_OC_Ex_1),
    .Imme_RAU_OC(Imme_RAU_OC) ,//
    .Imme_Valid_RAU_OC(Imme_Valid_RAU_OC) ,//
    .ALUop_RAU_OC(ALUop_RAU_OC) ,//
    .MemWrite_RAU_OC(MemWrite_RAU_OC) ,//
    .MemRead_RAU_OC(MemRead_RAU_OC) ,//
    .Shared_Globalbar_RAU_OC(Shared_Globalbar_RAU_OC) ,//pass
    .BEQ_RAU_OC(BEQ_RAU_OC) ,//pass
    .BLT_RAU_OC(BLT_RAU_OC) ,//pass
    .ScbID_RAU_OC(ScbID_RAU_OC) ,//pass
    .ActiveMask_RAU_OC(ActiveMask_RAU_OC) ,//pass
    .Dst_RAU_OC(Dst_RAU_OC),
    .RDY(RDY_1), 
    .valid(valid_1),

    .oc_0_data(oc_0_data_1),
    .oc_1_data(oc_1_data_1),

    .Valid_OC_Ex(Valid_OC_Ex_1) ,//use
    .Instr_OC_Ex(Instr_OC_Ex_1) ,//pass

    .WarpID_OC_Ex(WarpID_OC_Ex_1),
    .Imme_OC_Ex(Imme_OC_Ex_1) ,//
    .Imme_Valid_OC_Ex(Imme_Valid_OC_Ex_1) ,//
    .ALUop_OC_Ex(ALUop_OC_Ex_1) ,//
    .MemWrite_OC_Ex(MemWrite_OC_Ex_1) ,//
    .MemRead_OC_Ex(MemRead_OC_Ex_1) ,//  
    .Shared_Globalbar_OC_Ex(Shared_Globalbar_OC_Ex_1) ,//pass
    .BEQ_OC_Ex(BEQ_OC_Ex_1) ,//pass
    .BLT_OC_Ex(BLT_OC_Ex_1) ,//pass
    .ScbID_OC_Ex(ScbID_OC_Ex_1) ,//pass
    .ActiveMask_OC_Ex(ActiveMask_OC_Ex_1),//pass
    .Dst_OC_Ex(Dst_OC_Ex_1)
);

OC_collector_unit#(
    .ocid(2)
) unit2(
    .clk(clk), 
    .rst(rst),
    .SPEslot_RAU_OC(SPEslot_RAU_OC_2),
    .SPEvalue_RAU_OC(SPEvalue_RAU_OC),
    .SPEv2slot_RAU_OC(SPEv2slot_RAU_OC_2),
    .SPEv2value_RAU_OC(SPEv2value_RAU_OC),
    .Src1_Phy_Bank_ID(Src1_Phy_Bank_ID),
    .Src2_Phy_Bank_ID(Src2_Phy_Bank_ID),
    .same_OC_0(same_OC_0),
    .same_OC_1(same_OC_1),
    .same_OC_2(same_OC_2),
    .same_OC_3(same_OC_3),


    .bk_0_data(DataOut_0), 
    .bk_1_data(DataOut_1), 
    .bk_2_data(DataOut_2), 
    .bk_3_data(DataOut_3),
    .bk_0_ocid(ocid_0[2:0]),
    .bk_1_ocid(ocid_1[2:0]),
    .bk_2_ocid(ocid_2[2:0]),
    .bk_3_ocid(ocid_3[2:0]),
    .bk_0_vld(bank_0_valid),
    .bk_1_vld(bank_1_valid),
    .bk_2_vld(bank_2_valid),
    .bk_3_vld(bank_3_valid),

    .WE(WE_2),
    .RE(RE_2), 


    .WarpID_RAU_OC(WarpID_RAU_OC),
    .Valid_RAU_OC(Valid_RAU_OC) ,//use
    .Instr_RAU_OC(Instr_RAU_OC) ,//pass
    .RegWrite_RAU_OC(RegWrite_RAU_OC),

    .Imme_RAU_OC(Imme_RAU_OC) ,//
    .Imme_Valid_RAU_OC(Imme_Valid_RAU_OC) ,//
    .ALUop_RAU_OC(ALUop_RAU_OC) ,//
    .MemWrite_RAU_OC(MemWrite_RAU_OC) ,//
    .MemRead_RAU_OC(MemRead_RAU_OC) ,//
    .Shared_Globalbar_RAU_OC(Shared_Globalbar_RAU_OC) ,//pass
    .BEQ_RAU_OC(BEQ_RAU_OC) ,//pass
    .BLT_RAU_OC(BLT_RAU_OC) ,//pass
    .ScbID_RAU_OC(ScbID_RAU_OC) ,//pass
    .ActiveMask_RAU_OC(ActiveMask_RAU_OC) ,//pass
    .Dst_RAU_OC(Dst_RAU_OC),
    .RDY(RDY_2), 
    .valid(valid_2),

    .oc_0_data(oc_0_data_2),
    .oc_1_data(oc_1_data_2),

    .Valid_OC_Ex(Valid_OC_Ex_2) ,//use
    .Instr_OC_Ex(Instr_OC_Ex_2) ,//pass

    .WarpID_OC_Ex(WarpID_OC_Ex_2),
    .RegWrite_OC_Ex(RegWrite_OC_Ex_2),
    .Imme_OC_Ex(Imme_OC_Ex_2) ,//
    .Imme_Valid_OC_Ex(Imme_Valid_OC_Ex_2) ,//
    .ALUop_OC_Ex(ALUop_OC_Ex_2) ,//
    .MemWrite_OC_Ex(MemWrite_OC_Ex_2) ,//
    .MemRead_OC_Ex(MemRead_OC_Ex_2) ,//  
    .Shared_Globalbar_OC_Ex(Shared_Globalbar_OC_Ex_2) ,//pass
    .BEQ_OC_Ex(BEQ_OC_Ex_2) ,//pass
    .BLT_OC_Ex(BLT_OC_Ex_2) ,//pass
    .ScbID_OC_Ex(ScbID_OC_Ex_2) ,//pass
    .ActiveMask_OC_Ex(ActiveMask_OC_Ex_2),//pass
    .Dst_OC_Ex(Dst_OC_Ex_2)
);
OC_collector_unit#(
    .ocid(3)
) unit3(
    .clk(clk), 
    .rst(rst),
    .SPEslot_RAU_OC(SPEslot_RAU_OC_3),
    .SPEvalue_RAU_OC(SPEvalue_RAU_OC),
    .SPEv2slot_RAU_OC(SPEv2slot_RAU_OC_3),
    .SPEv2value_RAU_OC(SPEv2value_RAU_OC),
    .Src1_Phy_Bank_ID(Src1_Phy_Bank_ID),
    .Src2_Phy_Bank_ID(Src2_Phy_Bank_ID),
    .same_OC_0(same_OC_0),
    .same_OC_1(same_OC_1),
    .same_OC_2(same_OC_2),
    .same_OC_3(same_OC_3),


    .bk_0_data(DataOut_0), 
    .bk_1_data(DataOut_1), 
    .bk_2_data(DataOut_2), 
    .bk_3_data(DataOut_3),
    .bk_0_ocid(ocid_0[2:0]),
    .bk_1_ocid(ocid_1[2:0]),
    .bk_2_ocid(ocid_2[2:0]),
    .bk_3_ocid(ocid_3[2:0]),
    .bk_0_vld(bank_0_valid),
    .bk_1_vld(bank_1_valid),
    .bk_2_vld(bank_2_valid),
    .bk_3_vld(bank_3_valid),

    .WE(WE_3),
    .RE(RE_3), 


    .WarpID_RAU_OC(WarpID_RAU_OC),
    .Valid_RAU_OC(Valid_RAU_OC) ,//use
    .Instr_RAU_OC(Instr_RAU_OC) ,//pass
    .RegWrite_RAU_OC(RegWrite_RAU_OC),

    .Imme_RAU_OC(Imme_RAU_OC) ,//
    .Imme_Valid_RAU_OC(Imme_Valid_RAU_OC) ,//
    .ALUop_RAU_OC(ALUop_RAU_OC) ,//
    .MemWrite_RAU_OC(MemWrite_RAU_OC) ,//
    .MemRead_RAU_OC(MemRead_RAU_OC) ,//
    .Shared_Globalbar_RAU_OC(Shared_Globalbar_RAU_OC) ,//pass
    .BEQ_RAU_OC(BEQ_RAU_OC) ,//pass
    .BLT_RAU_OC(BLT_RAU_OC) ,//pass
    .ScbID_RAU_OC(ScbID_RAU_OC) ,//pass
    .ActiveMask_RAU_OC(ActiveMask_RAU_OC) ,//pass
    .Dst_RAU_OC(Dst_RAU_OC),
    .RDY(RDY_3), 
    .valid(valid_3),

    .oc_0_data(oc_0_data_3),
    .oc_1_data(oc_1_data_3),

    .Valid_OC_Ex(Valid_OC_Ex_3) ,//use
    .Instr_OC_Ex(Instr_OC_Ex_3) ,//pass

    .WarpID_OC_Ex(WarpID_OC_Ex_3),
    .RegWrite_OC_Ex(RegWrite_OC_Ex_3),
    .Imme_OC_Ex(Imme_OC_Ex_3) ,//
    .Imme_Valid_OC_Ex(Imme_Valid_OC_Ex_3) ,//
    .ALUop_OC_Ex(ALUop_OC_Ex_3) ,//
    .MemWrite_OC_Ex(MemWrite_OC_Ex_3) ,//
    .MemRead_OC_Ex(MemRead_OC_Ex_3) ,//  
    .Shared_Globalbar_OC_Ex(Shared_Globalbar_OC_Ex_3) ,//pass
    .BEQ_OC_Ex(BEQ_OC_Ex_3) ,//pass
    .BLT_OC_Ex(BLT_OC_Ex_3) ,//pass
    .ScbID_OC_Ex(ScbID_OC_Ex_3) ,//pass
    .ActiveMask_OC_Ex(ActiveMask_OC_Ex_3),//pass
    .Dst_OC_Ex(Dst_OC_Ex_3)
);
endmodule