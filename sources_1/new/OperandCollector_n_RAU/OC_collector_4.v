module OC_collector_4(
    input wire rst,
    input wire clk,

    input wire [3:0] ALU_Grt_Sched_OC,
    input wire [3:0] MEM_Grt_Sched_OC,

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

    input wire [2:0] Src1_OCID_RAU_OC,
    input wire [2:0] Src2_OCID_RAU_OC,

    input wire [255:0] DataOut_0,
    input wire [255:0] DataOut_1,
    input wire [255:0] DataOut_2,
    input wire [255:0] DataOut_3,//不能写wire？

    
    input wire [3:0] ocid_0,
    input wire [3:0] ocid_1,
    input wire [3:0] ocid_2,
    input wire [3:0] ocid_3,

    input wire RF_WR_0,
    input wire RF_WR_1,
    input wire RF_WR_2,
    input wire RF_WR_3,

    input wire [1:0] Src1_Phy_Bank_ID,
    input wire [1:0] Src2_Phy_Bank_ID,


    output wire [255:0] oc_0_data_0,
    output wire [255:0] oc_1_data_0,

    output RDY_0, 
    output valid_0,

    output Valid_Collecting_Ex_0 ,//use
    output [31:0] Instr_Collecting_Ex_0 ,//pass
    output RegWrite_Collecting_Ex_0,
    output [15:0] Imme_Collecting_Ex_0 ,//
    output Imme_Valid_Collecting_Ex_0 ,//
    output [3:0] ALUop_Collecting_Ex_0 ,//
    output MemWrite_Collecting_Ex_0 ,//
    output MemRead_Collecting_Ex_0 ,//
    output Shared_Globalbar_Collecting_Ex_0 ,//pass
    output BEQ_Collecting_Ex_0 ,//pass
    output BLT_Collecting_Ex_0 ,//pass
    output [1:0] ScbID_Collecting_Ex_0 ,//pass
    output [7:0] ActiveMask_Collecting_Ex_0,//pass
    

    output wire [255:0] oc_0_data_1,
    output wire [255:0] oc_1_data_1,

    output RDY_1, 
    output valid_1,

    output Valid_Collecting_Ex_1 ,//use
    output [31:0] Instr_Collecting_Ex_1 ,//pass
    output RegWrite_Collecting_Ex_1,
    output [15:0] Imme_Collecting_Ex_1 ,//
    output Imme_Valid_Collecting_Ex_1 ,//
    output [3:0] ALUop_Collecting_Ex_1 ,//
    output MemWrite_Collecting_Ex_1 ,//
    output MemRead_Collecting_Ex_1 ,//
    output Shared_Globalbar_Collecting_Ex_1 ,//pass
    output BEQ_Collecting_Ex_1 ,//pass
    output BLT_Collecting_Ex_1 ,//pass
    output [1:0] ScbID_Collecting_Ex_1 ,//pass
    output [7:0] ActiveMask_Collecting_Ex_1,//pass

    output wire [255:0] oc_0_data_2,
    output wire [255:0] oc_1_data_2,

    output RDY_2, 
    output valid_2,

    output Valid_Collecting_Ex_2 ,//use
    output [31:0] Instr_Collecting_Ex_2 ,//pass
    output RegWrite_Collecting_Ex_2,
    output [15:0] Imme_Collecting_Ex_2 ,//
    output Imme_Valid_Collecting_Ex_2 ,//
    output [3:0] ALUop_Collecting_Ex_2 ,//
    output MemWrite_Collecting_Ex_2 ,//
    output MemRead_Collecting_Ex_2 ,//
    output Shared_Globalbar_Collecting_Ex_2 ,//pass
    output BEQ_Collecting_Ex_2 ,//pass
    output BLT_Collecting_Ex_2 ,//pass
    output [1:0] ScbID_Collecting_Ex_2 ,//pass
    output [7:0] ActiveMask_Collecting_Ex_2,//pass

    output wire [255:0] oc_0_data_3,
    output wire [255:0] oc_1_data_3,

    output RDY_3, 
    output valid_3,

    output Valid_Collecting_Ex_3 ,//use
    output [31:0] Instr_Collecting_Ex_3 ,//pass
    output RegWrite_Collecting_Ex_3,
    output [15:0] Imme_Collecting_Ex_3 ,//
    output Imme_Valid_Collecting_Ex_3 ,//
    output [3:0] ALUop_Collecting_Ex_3 ,//
    output MemWrite_Collecting_Ex_3 ,//
    output MemRead_Collecting_Ex_3 ,//
    output Shared_Globalbar_Collecting_Ex_3 ,//pass
    output BEQ_Collecting_Ex_3 ,//pass
    output BLT_Collecting_Ex_3 ,//pass
    output [1:0] ScbID_Collecting_Ex_3 ,//pass
    output [7:0] ActiveMask_Collecting_Ex_3//pass
    

);

wire bank_0_valiud = ocid_0[3];
wire bank_1_valiud = ocid_1[3];
wire bank_2_valiud = ocid_2[3];
wire bank_3_valiud = ocid_3[3];

wire [1:0]WE_0 = {((ocid_0 == 3'b001) & (ocid_0[3] == 1'b1))|((ocid_1 == 3'b001) & (ocid_1[3] == 1'b1))|((ocid_2 == 3'b001) & (ocid_2[3] == 1'b1))|((ocid_3 == 3'b001) & (ocid_3[3] == 1'b1)),
             ((ocid_0 == 3'b000) & (ocid_0[3] == 1'b1))|((ocid_1 == 3'b000) & (ocid_1[3] == 1'b1))|((ocid_2 == 3'b000) & (ocid_2[3] == 1'b1))|((ocid_3 == 3'b000) & (ocid_3[3] == 1'b1))};
wire [1:0]WE_1 = {((ocid_0 == 3'b011) & (ocid_0[3] == 1'b1))|((ocid_1 == 3'b011) & (ocid_1[3] == 1'b1))|((ocid_2 == 3'b011) & (ocid_2[3] == 1'b1))|((ocid_3 == 3'b011) & (ocid_3[3] == 1'b1)),
             ((ocid_0 == 3'b010) & (ocid_0[3] == 1'b1))|((ocid_1 == 3'b010) & (ocid_1[3] == 1'b1))|((ocid_2 == 3'b010) & (ocid_2[3] == 1'b1))|((ocid_3 == 3'b010) & (ocid_3[3] == 1'b1))};
wire [1:0]WE_2 = {((ocid_0 == 3'b101) & (ocid_0[3] == 1'b1))|((ocid_1 == 3'b101) & (ocid_1[3] == 1'b1))|((ocid_2 == 3'b101) & (ocid_2[3] == 1'b1))|((ocid_3 == 3'b101) & (ocid_3[3] == 1'b1)),
             ((ocid_0 == 3'b100) & (ocid_0[3] == 1'b1))|((ocid_1 == 3'b100) & (ocid_1[3] == 1'b1))|((ocid_2 == 3'b100) & (ocid_2[3] == 1'b1))|((ocid_3 == 3'b100) & (ocid_3[3] == 1'b1))};
wire [1:0]WE_3 = {((ocid_0 == 3'b111) & (ocid_0[3] == 1'b1))|((ocid_1 == 3'b111) & (ocid_1[3] == 1'b1))|((ocid_2 == 3'b111) & (ocid_2[3] == 1'b1))|((ocid_3 == 3'b111) & (ocid_3[3] == 1'b1)),
             ((ocid_0 == 3'b110) & (ocid_0[3] == 1'b1))|((ocid_1 == 3'b110) & (ocid_1[3] == 1'b1))|((ocid_2 == 3'b110) & (ocid_2[3] == 1'b1))|((ocid_3 == 3'b110) & (ocid_3[3] == 1'b1))};

wire [4:0]c_0_reg_id_in = {Src1_Phy_Bank_ID, 3'b000};///////??????
wire [4:0]c_1_reg_id_in = {Src2_Phy_Bank_ID, 3'b000};///////??????


wire RE_0 = ALU_Grt_Sched_OC[0] & ALU_Grt_Sched_OC[0];
wire RE_1 = ALU_Grt_Sched_OC[1] & ALU_Grt_Sched_OC[1];
wire RE_2 = ALU_Grt_Sched_OC[2] & ALU_Grt_Sched_OC[2];
wire RE_3 = ALU_Grt_Sched_OC[3] & ALU_Grt_Sched_OC[3];


OC_collector_unit#(
    .ocid(0)
) unit0(
    .clk(clk), 
    .rst(rst),
    .bk_0_data(DataOut_0), 
    .bk_1_data(DataOut_1), 
    .bk_2_data(DataOut_2), 
    .bk_3_data(DataOut_3),
    .bk_0_ocid(ocid_0[2:0]),
    .bk_1_ocid(ocid_1[2:0]),
    .bk_2_ocid(ocid_2[2:0]),
    .bk_3_ocid(ocid_3[2:0]),
    .bk_0_bz(RF_WR_0),
    .bk_1_bz(RF_WR_1),
    .bk_2_bz(RF_WR_2),
    .bk_3_bz(RF_WR_3),
    .bk_0_vld(bank_0_valiud),
    .bk_1_vld(bank_1_valiud),
    .bk_2_vld(bank_2_valiud),
    .bk_3_vld(bank_3_valiud),
    .c_0_reg_id_in(c_0_reg_id_in),
    .c_1_reg_id_in(c_1_reg_id_in),
    .WE(WE_0),
    .RE(RE_0), 


    .Valid_RAU_Collecting(Valid_RAU_Collecting) ,//use
    .Instr_RAU_Collecting(Instr_RAU_Collecting) ,//pass

    .Imme_RAU_Collecting(Imme_RAU_Collecting) ,//
    .Imme_Valid_RAU_Collecting(Imme_Valid_RAU_Collecting) ,//
    .ALUop_RAU_Collecting(ALUop_RAU_Collecting) ,//
    .MemWrite_RAU_Collecting(MemWrite_RAU_Collecting) ,//
    .MemRead_RAU_Collecting(MemRead_RAU_Collecting) ,//
    .Shared_Globalbar_RAU_Collecting(Shared_Globalbar_RAU_Collecting) ,//pass
    .BEQ_RAU_Collecting(BEQ_RAU_Collecting) ,//pass
    .BLT_RAU_Collecting(BLT_RAU_Collecting) ,//pass
    .ScbID_RAU_Collecting(ScbID_RAU_Collecting) ,//pass
    .ActiveMask_RAU_Collecting(ActiveMask_RAU_Collecting) ,//pass
    .RDY(RDY_0), 
    .valid(valid_0),

    .oc_0_data(oc_0_data_0),
    .oc_1_data(oc_1_data_0),

    .Valid_Collecting_Ex(Valid_Collecting_Ex_0) ,//use
    .Instr_Collecting_Ex(Instr_Collecting_Ex_0) ,//pass

    .RegWrite_Collecting_Ex(RegWrite_Collecting_Ex_0),
    .Imme_Collecting_Ex(Imme_Collecting_Ex_0) ,//
    .Imme_Valid_Collecting_Ex(Imme_Valid_Collecting_Ex_0) ,//
    .ALUop_Collecting_Ex(ALUop_Collecting_Ex_0) ,//
    .MemWrite_Collecting_Ex(MemWrite_Collecting_Ex_0) ,//
    .MemRead_Collecting_Ex(MemRead_Collecting_Ex_0) ,//  
    .Shared_Globalbar_Collecting_Ex(Shared_Globalbar_Collecting_Ex_0) ,//pass
    .BEQ_Collecting_Ex(BEQ_Collecting_Ex_0) ,//pass
    .BLT_Collecting_Ex(BLT_Collecting_Ex_0) ,//pass
    .ScbID_Collecting_Ex(ScbID_Collecting_Ex_0) ,//pass
    .ActiveMask_Collecting_Ex(ActiveMask_Collecting_Ex_0)//pass
);

OC_collector_unit#(
    .ocid(1)
) unit1(
    .clk(clk), 
    .rst(rst),
    .bk_0_data(DataOut_0), 
    .bk_1_data(DataOut_1), 
    .bk_2_data(DataOut_2), 
    .bk_3_data(DataOut_3),
    .bk_0_ocid(ocid_0[2:0]),
    .bk_1_ocid(ocid_1[2:0]),
    .bk_2_ocid(ocid_2[2:0]),
    .bk_3_ocid(ocid_3[2:0]),
    .bk_0_bz(RF_WR_0),
    .bk_1_bz(RF_WR_1),
    .bk_2_bz(RF_WR_2),
    .bk_3_bz(RF_WR_3),
    .bk_0_vld(bank_0_valiud),
    .bk_1_vld(bank_1_valiud),
    .bk_2_vld(bank_2_valiud),
    .bk_3_vld(bank_3_valiud),
    .c_0_reg_id_in(c_0_reg_id_in),
    .c_1_reg_id_in(c_1_reg_id_in),
    .WE(WE_1),
    .RE(RE_1), 


    .Valid_RAU_Collecting(Valid_RAU_Collecting) ,//use
    .Instr_RAU_Collecting(Instr_RAU_Collecting) ,//pass

    .RegWrite_Collecting_Ex(RegWrite_Collecting_Ex_1),
    .Imme_RAU_Collecting(Imme_RAU_Collecting) ,//
    .Imme_Valid_RAU_Collecting(Imme_Valid_RAU_Collecting) ,//
    .ALUop_RAU_Collecting(ALUop_RAU_Collecting) ,//
    .MemWrite_RAU_Collecting(MemWrite_RAU_Collecting) ,//
    .MemRead_RAU_Collecting(MemRead_RAU_Collecting) ,//
    .Shared_Globalbar_RAU_Collecting(Shared_Globalbar_RAU_Collecting) ,//pass
    .BEQ_RAU_Collecting(BEQ_RAU_Collecting) ,//pass
    .BLT_RAU_Collecting(BLT_RAU_Collecting) ,//pass
    .ScbID_RAU_Collecting(ScbID_RAU_Collecting) ,//pass
    .ActiveMask_RAU_Collecting(ActiveMask_RAU_Collecting) ,//pass
    .RDY(RDY_1), 
    .valid(valid_1),

    .oc_0_data(oc_0_data_1),
    .oc_1_data(oc_1_data_1),

    .Valid_Collecting_Ex(Valid_Collecting_Ex_1) ,//use
    .Instr_Collecting_Ex(Instr_Collecting_Ex_1) ,//pass

    .Imme_Collecting_Ex(Imme_Collecting_Ex_1) ,//
    .Imme_Valid_Collecting_Ex(Imme_Valid_Collecting_Ex_1) ,//
    .ALUop_Collecting_Ex(ALUop_Collecting_Ex_1) ,//
    .MemWrite_Collecting_Ex(MemWrite_Collecting_Ex_1) ,//
    .MemRead_Collecting_Ex(MemRead_Collecting_Ex_1) ,//  
    .Shared_Globalbar_Collecting_Ex(Shared_Globalbar_Collecting_Ex_1) ,//pass
    .BEQ_Collecting_Ex(BEQ_Collecting_Ex_1) ,//pass
    .BLT_Collecting_Ex(BLT_Collecting_Ex_1) ,//pass
    .ScbID_Collecting_Ex(ScbID_Collecting_Ex_1) ,//pass
    .ActiveMask_Collecting_Ex(ActiveMask_Collecting_Ex_1)//pass
);

OC_collector_unit#(
    .ocid(2)
) unit2(
    .clk(clk), 
    .rst(rst),
    .bk_0_data(DataOut_0), 
    .bk_1_data(DataOut_1), 
    .bk_2_data(DataOut_2), 
    .bk_3_data(DataOut_3),
    .bk_0_ocid(ocid_0[2:0]),
    .bk_1_ocid(ocid_1[2:0]),
    .bk_2_ocid(ocid_2[2:0]),
    .bk_3_ocid(ocid_3[2:0]),
    .bk_0_bz(RF_WR_0),
    .bk_1_bz(RF_WR_1),
    .bk_2_bz(RF_WR_2),
    .bk_3_bz(RF_WR_3),
    .bk_0_vld(bank_0_valiud),
    .bk_1_vld(bank_1_valiud),
    .bk_2_vld(bank_2_valiud),
    .bk_3_vld(bank_3_valiud),
    .c_0_reg_id_in(c_0_reg_id_in),
    .c_1_reg_id_in(c_1_reg_id_in),
    .WE(WE_2),
    .RE(RE_2), 


    .Valid_RAU_Collecting(Valid_RAU_Collecting) ,//use
    .Instr_RAU_Collecting(Instr_RAU_Collecting) ,//pass

    .Imme_RAU_Collecting(Imme_RAU_Collecting) ,//
    .Imme_Valid_RAU_Collecting(Imme_Valid_RAU_Collecting) ,//
    .ALUop_RAU_Collecting(ALUop_RAU_Collecting) ,//
    .MemWrite_RAU_Collecting(MemWrite_RAU_Collecting) ,//
    .MemRead_RAU_Collecting(MemRead_RAU_Collecting) ,//
    .Shared_Globalbar_RAU_Collecting(Shared_Globalbar_RAU_Collecting) ,//pass
    .BEQ_RAU_Collecting(BEQ_RAU_Collecting) ,//pass
    .BLT_RAU_Collecting(BLT_RAU_Collecting) ,//pass
    .ScbID_RAU_Collecting(ScbID_RAU_Collecting) ,//pass
    .ActiveMask_RAU_Collecting(ActiveMask_RAU_Collecting) ,//pass
    .RDY(RDY_2), 
    .valid(valid_2),

    .oc_0_data(oc_0_data_0),
    .oc_1_data(oc_1_data_0),

    .Valid_Collecting_Ex(Valid_Collecting_Ex_2) ,//use
    .Instr_Collecting_Ex(Instr_Collecting_Ex_2) ,//pass

    .RegWrite_Collecting_Ex(RegWrite_Collecting_Ex_2),
    .Imme_Collecting_Ex(Imme_Collecting_Ex_2) ,//
    .Imme_Valid_Collecting_Ex(Imme_Valid_Collecting_Ex_2) ,//
    .ALUop_Collecting_Ex(ALUop_Collecting_Ex_2) ,//
    .MemWrite_Collecting_Ex(MemWrite_Collecting_Ex_2) ,//
    .MemRead_Collecting_Ex(MemRead_Collecting_Ex_2) ,//  
    .Shared_Globalbar_Collecting_Ex(Shared_Globalbar_Collecting_Ex_2) ,//pass
    .BEQ_Collecting_Ex(BEQ_Collecting_Ex_2) ,//pass
    .BLT_Collecting_Ex(BLT_Collecting_Ex_2) ,//pass
    .ScbID_Collecting_Ex(ScbID_Collecting_Ex_2) ,//pass
    .ActiveMask_Collecting_Ex(ActiveMask_Collecting_Ex_2)//pass
);
OC_collector_unit#(
    .ocid(3)
) unit3(
    .clk(clk), 
    .rst(rst),
    .bk_0_data(DataOut_0), 
    .bk_1_data(DataOut_1), 
    .bk_2_data(DataOut_2), 
    .bk_3_data(DataOut_3),
    .bk_0_ocid(ocid_0[2:0]),
    .bk_1_ocid(ocid_1[2:0]),
    .bk_2_ocid(ocid_2[2:0]),
    .bk_3_ocid(ocid_3[2:0]),
    .bk_0_bz(RF_WR_0),
    .bk_1_bz(RF_WR_1),
    .bk_2_bz(RF_WR_2),
    .bk_3_bz(RF_WR_3),
    .bk_0_vld(bank_0_valiud),
    .bk_1_vld(bank_1_valiud),
    .bk_2_vld(bank_2_valiud),
    .bk_3_vld(bank_3_valiud),
    .c_0_reg_id_in(c_0_reg_id_in),
    .c_1_reg_id_in(c_1_reg_id_in),
    .WE(WE_3),
    .RE(RE_3), 


    .Valid_RAU_Collecting(Valid_RAU_Collecting) ,//use
    .Instr_RAU_Collecting(Instr_RAU_Collecting) ,//pass

    .Imme_RAU_Collecting(Imme_RAU_Collecting) ,//
    .Imme_Valid_RAU_Collecting(Imme_Valid_RAU_Collecting) ,//
    .ALUop_RAU_Collecting(ALUop_RAU_Collecting) ,//
    .MemWrite_RAU_Collecting(MemWrite_RAU_Collecting) ,//
    .MemRead_RAU_Collecting(MemRead_RAU_Collecting) ,//
    .Shared_Globalbar_RAU_Collecting(Shared_Globalbar_RAU_Collecting) ,//pass
    .BEQ_RAU_Collecting(BEQ_RAU_Collecting) ,//pass
    .BLT_RAU_Collecting(BLT_RAU_Collecting) ,//pass
    .ScbID_RAU_Collecting(ScbID_RAU_Collecting) ,//pass
    .ActiveMask_RAU_Collecting(ActiveMask_RAU_Collecting) ,//pass
    .RDY(RDY_3), 
    .valid(valid_3),

    .oc_0_data(oc_0_data_3),
    .oc_1_data(oc_1_data_3),

    .Valid_Collecting_Ex(Valid_Collecting_Ex_3) ,//use
    .Instr_Collecting_Ex(Instr_Collecting_Ex_3) ,//pass

    .RegWrite_Collecting_Ex(RegWrite_Collecting_Ex_3),
    .Imme_Collecting_Ex(Imme_Collecting_Ex_3) ,//
    .Imme_Valid_Collecting_Ex(Imme_Valid_Collecting_Ex_3) ,//
    .ALUop_Collecting_Ex(ALUop_Collecting_Ex_3) ,//
    .MemWrite_Collecting_Ex(MemWrite_Collecting_Ex_3) ,//
    .MemRead_Collecting_Ex(MemRead_Collecting_Ex_3) ,//  
    .Shared_Globalbar_Collecting_Ex(Shared_Globalbar_Collecting_Ex_3) ,//pass
    .BEQ_Collecting_Ex(BEQ_Collecting_Ex_3) ,//pass
    .BLT_Collecting_Ex(BLT_Collecting_Ex_3) ,//pass
    .ScbID_Collecting_Ex(ScbID_Collecting_Ex_3) ,//pass
    .ActiveMask_Collecting_Ex(ActiveMask_Collecting_Ex_3)//pass
);
endmodule