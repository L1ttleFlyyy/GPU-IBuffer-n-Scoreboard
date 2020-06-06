module RFOC(
    input wire rst,
    input wire clk,
    
    input wire Valid_IB_OC,
    input wire [31:0] Instr_IB_OC,
    input wire [4:0] Src1_IB_OC,// MSB 是 取R16 下一位是specialreg
    input wire Src1_Valid_IB_OC,
    input wire [4:0] Src2_IB_OC,
    input wire Src2_Valid_IB_OC,
    input wire [4:0] Dst_IB_OC,
    input wire [15:0] Imme_IB_OC,
    input wire Imme_Valid_IB_OC,
    input wire [3:0] ALUop_IB_OC,
    input wire RegWrite_IB_OC,
    input wire MemWrite_IB_OC,//区分是给ALU还是MEN，再分具体的操作
    input wire MemRead_IB_OC,
    input wire Shared_Globalbar_IB_OC,
    input wire BEQ_IB_OC,
    input wire BLT_IB_OC,
    input wire [1:0] ScbID_IB_OC,
    input wire [7:0] ActiveMask_IB_OC,

    //Allo or exit
    //Exit
    input wire [2:0] Exit_WarpID_IB_RAU_TM,
    input wire Exit_IB_RAU_TM,

    //Allo
    input wire Update_TM_RAU,
    input wire [2:0] HWWarpID_TM_RAU,
    input wire [7:0] SWWarpID_TM_RAU,
    input wire [2:0] Nreg_TM_RAU,
    output Alloc_BusyBar_RAU_TM,

    //Read 
    input wire [2:0] WarpID_IB_OC, //with valid?
    output wire Full_OC_IB,
    //Write
    output wire [7:0] AllocStall_RAU_IB,


    input wire RegWrite_CDB_RAU,
    input wire [2:0] WriteAddr_CDB_RAU,
    input wire [2:0] HWWarp_CDB_RAU,
    input wire [255:0] Data_CDB_RAU,
    input wire [31:0] Instr_CDB_RAU,
    input wire [7:0] ActiveMask_CDB_RAU,


    output [255:0] Src1_Data_ALU,
    output [255:0] Src2_Data_ALU,

    output Valid_OC_ALU,//use
    output [2:0] WarpID_OC_ALU,
    output [31:0] Instr_OC_ALU,//pass
    output RegWrite_OC_ALU,
    output [15:0] Imme_OC_ALU,//
    output Imme_Valid_OC_ALU,//
    output [3:0] ALUop_OC_ALU,//
    output MemWrite_OC_ALU,//
    output MemRead_OC_ALU,//
    output Shared_Globalbar_OC_ALU,//pass
    output BEQ_OC_ALU,//pass
    output BLT_OC_ALU,//pass
    output [1:0] ScbID_OC_ALU,//pass
    output [7:0] ActiveMask_OC_ALU,//pass
    output [4:0] Dst_OC_ALU,

    output [255:0]Src1_Data_MEM,
    output [255:0]Src2_Data_MEM,

    output Valid_OC_MEM,//use
    output [2:0] WarpID_OC_MEM,
    output [31:0]Instr_OC_MEM,//pass
    output RegWrite_OC_MEM,
    output [15:0]Imme_OC_MEM,//
    output Imme_Valid_OC_MEM,//
    output [3:0] ALUop_OC_MEM,//
    output MemWrite_OC_MEM,//
    output MemRead_OC_MEM,//
    output Shared_Globalbar_OC_MEM,//pass
    output BEQ_OC_MEM,//pass
    output BLT_OC_MEM,//pass
    output [1:0] ScbID_OC_MEM,//pass
    output [7:0] ActiveMask_OC_MEM,//pass
    output [4:0] Dst_OC_MEM
);


wire [2:0] WriteRow;
wire [1:0] WriteBank;
wire Src1_Valid;
wire Src2_Valid;
wire [1:0] Src1_Phy_Bank_ID;
wire [1:0] Src2_Phy_Bank_ID;
wire [2:0] Src1_Phy_Row_ID;
wire [2:0] Src2_Phy_Row_ID;
wire ReqFIFO_2op_EN;
wire [2:0] Src1_OCID_RAU_OC;
wire [2:0] Src2_OCID_RAU_OC;
wire [255:0]Data_CDB;

wire [7:0] ActiveMask_RAU_OC;//pass

wire [2:0] RF_Addr_0;
wire [2:0] RF_Addr_1;
wire [2:0] RF_Addr_2;
wire [2:0] RF_Addr_3;

wire [3:0] ocid_out_0;
wire [3:0] ocid_out_1;
wire [3:0] ocid_out_2;
wire [3:0] ocid_out_3;

wire RF_WR_0;
wire RF_WR_1;
wire RF_WR_2;
wire RF_WR_3;

wire [255:0] WriteData_0;
wire [255:0] WriteData_1;
wire [255:0] WriteData_2;
wire [255:0] WriteData_3;

wire [3:0] ALU_Grt_Sched_OC;
wire [3:0] MEM_Grt_Sched_OC;

wire Valid_RAU_OC;//use
wire [2:0] WarpID_RAU_OC;
wire [31:0]Instr_RAU_OC;
wire [15:0] Imme_RAU_OC ;//
wire Imme_Valid_RAU_OC;
wire [3:0] ALUop_RAU_OC ;
wire RegWrite_RAU_OC;
wire MemWrite_RAU_OC;
wire MemRead_RAU_OC;
wire Shared_Globalbar_RAU_OC;
wire BEQ_RAU_OC;//pass
wire BLT_RAU_OC;//pass
wire [1:0]ScbID_RAU_OC;//pass
wire [4:0]Dst_RAU_OC;

wire RDY_0;
wire RDY_1;
wire RDY_2;
wire RDY_3;

wire RegWrite_OC_Ex_0; 
wire RegWrite_OC_Ex_1; 
wire RegWrite_OC_Ex_2; 
wire RegWrite_OC_Ex_3; 
wire MemWrite_OC_Ex_0; 
wire MemWrite_OC_Ex_1; 
wire MemWrite_OC_Ex_2; 
wire MemWrite_OC_Ex_3; 
wire MemRead_OC_Ex_0; 
wire MemRead_OC_Ex_1; 
wire MemRead_OC_Ex_2; 
wire MemRead_OC_Ex_3; 

wire [255:0] DataOut_0;
wire [255:0] DataOut_1;
wire [255:0] DataOut_2;
wire [255:0] DataOut_3;//不能写wire？


wire [3:0] ocid_0;
wire [3:0] ocid_1;
wire [3:0] ocid_2;
wire [3:0] ocid_3;

wire valid_0;
wire valid_1;
wire valid_2;
wire valid_3;

assign Full_OC_IB = valid_0 & valid_1 & valid_2 & valid_3;
wire oc_0_empty = ~valid_0;
wire oc_1_empty = ~valid_1;
wire oc_2_empty = ~valid_2;
wire oc_3_empty = ~valid_3;

assign Alloc_BusyBar_RAU_TM = !(|AllocStall_RAU_IB);

wire [1:0] SPEslot_RAU_OC;
wire [255:0] SPEvalue_RAU_OC;
wire [1:0] SPEv2slot_RAU_OC;
wire [255:0] SPEv2value_RAU_OC;
wire ReqFIFO_Same;
wire same_0;
wire same_1;
wire same_2;
wire same_3;
wire same_OC_0;
wire same_OC_1;
wire same_OC_2;
wire same_OC_3;


wire [255:0] oc_0_data_0;
wire [255:0] oc_1_data_0;

wire [255:0] oc_0_data_1;
wire [255:0] oc_1_data_1;

wire [255:0] oc_0_data_2;
wire [255:0] oc_1_data_2;

wire [255:0] oc_0_data_3;
wire [255:0] oc_1_data_3;

wire [2:0] WarpID_OC_Ex_0;
wire Valid_OC_Ex_0 ;//use
wire [31:0] Instr_OC_Ex_0 ;//pass
wire [15:0] Imme_OC_Ex_0 ;//
wire Imme_Valid_OC_Ex_0 ;//
wire [3:0] ALUop_OC_Ex_0 ;//
wire Shared_Globalbar_OC_Ex_0 ;//pass
wire BEQ_OC_Ex_0 ;//pass
wire BLT_OC_Ex_0 ;//pass
wire [1:0] ScbID_OC_Ex_0 ;//pass
wire [7:0] ActiveMask_OC_Ex_0;//pass
wire [4:0] Dst_OC_Ex_0;

wire [2:0] WarpID_OC_Ex_1;
wire Valid_OC_Ex_1 ;//use
wire [31:0] Instr_OC_Ex_1 ;//pass
wire [15:0] Imme_OC_Ex_1 ;//
wire Imme_Valid_OC_Ex_1 ;//
wire [3:0] ALUop_OC_Ex_1 ;//
wire Shared_Globalbar_OC_Ex_1 ;//pass
wire BEQ_OC_Ex_1 ;//pass
wire BLT_OC_Ex_1 ;//pass
wire [1:0] ScbID_OC_Ex_1 ;//pass
wire [7:0] ActiveMask_OC_Ex_1;//pass
wire [4:0] Dst_OC_Ex_1;

wire [2:0] WarpID_OC_Ex_2;
wire Valid_OC_Ex_2 ;//use
wire [31:0] Instr_OC_Ex_2 ;//pass
wire [15:0] Imme_OC_Ex_2 ;//
wire Imme_Valid_OC_Ex_2 ;//
wire [3:0] ALUop_OC_Ex_2 ;//
wire Shared_Globalbar_OC_Ex_2 ;//pass
wire BEQ_OC_Ex_2 ;//pass
wire BLT_OC_Ex_2 ;//pass
wire [1:0] ScbID_OC_Ex_2 ;//pass
wire [7:0] ActiveMask_OC_Ex_2;//pass
wire [4:0] Dst_OC_Ex_2;

wire [2:0] WarpID_OC_Ex_3;
wire Valid_OC_Ex_3 ;//use
wire [31:0] Instr_OC_Ex_3 ;//pass
wire [15:0] Imme_OC_Ex_3 ;//
wire Imme_Valid_OC_Ex_3 ;//
wire [3:0] ALUop_OC_Ex_3 ;//
wire Shared_Globalbar_OC_Ex_3 ;//pass
wire BEQ_OC_Ex_3 ;//pass
wire BLT_OC_Ex_3 ;//pass
wire [1:0] ScbID_OC_Ex_3 ;//pass
wire [7:0] ActiveMask_OC_Ex_3;//pass
wire [4:0] Dst_OC_Ex_3;

Mapping MappingUnit(
    .rst(rst),
    .clk(clk),

    //every
    .Valid_IB_RAU(Valid_IB_OC),//use
    .Instr_IB_RAU(Instr_IB_OC),//pass
    .Src1_IB_RAU(Src1_IB_OC),//use; MSB->SpecialReg
    .Src1_Valid_IB_RAU(Src1_Valid_IB_OC),//?????
    .Src2_IB_RAU(Src2_IB_OC),//use; MSB->SpecialReg
    .Src2_Valid_IB_RAU(Src2_Valid_IB_OC),//?????
    .RegWrite_IB_OC(RegWrite_IB_OC),
    .Dst_IB_OC(Dst_IB_OC),
    .Imme_IB_RAU(Imme_IB_OC),//use
    .Imme_Valid_IB_RAU(Imme_Valid_IB_OC),//?????
    .ALUop_IB_RAU(ALUop_IB_OC),//?????
    .MemWrite_IB_RAU(MemWrite_IB_OC),//judge 1 src
    .MemRead_IB_RAU(MemRead_IB_OC),//judge 1 src
    .Shared_Globalbar_IB_RAU(Shared_Globalbar_IB_OC),//pass
    .BEQ_IB_RAU(BEQ_IB_OC),//pass
    .BLT_IB_RAU(BLT_IB_OC),//pass
    .ScbID_IB_RAU(ScbID_IB_OC),//pass
    .ActiveMask_IB_RAU(ActiveMask_IB_OC),//pass

    //Allo or exit
    //Exit
    .Exit_WarpID_IB_RAU(Exit_WarpID_IB_RAU_TM),
    .Exit_IB_RAU_TM(Exit_IB_RAU_TM),

    //Allo
    .HWWarpID_TM_RAU(HWWarpID_TM_RAU),
    .Update_TM_RAU(Update_TM_RAU),
    .Nreg_TM_RAU(Nreg_TM_RAU),
    .SWWarpID_TM_RAU(SWWarpID_TM_RAU),

    //output reg [4:0] Available_RAU_TM,
    .AllocStall_RAU_IB(AllocStall_RAU_IB),//IF?

    //Read 
    .HWWarp_IB_RAU(WarpID_IB_OC), //with valid?

    //Write
    .WriteAddr_CDB_RAU(WriteAddr_CDB_RAU),
    .HWWarp_CDB_RAU(HWWarp_CDB_RAU),
    .Data_CDB_RAU(Data_CDB_RAU),
    .Instr_CDB_RAU(Instr_CDB_RAU),

    //OCID
    .oc_0_empty(oc_0_empty),
    .oc_1_empty(oc_1_empty),
    .oc_2_empty(oc_2_empty),
    .oc_3_empty(oc_3_empty),

    //OCID

    .Src1_OCID_RAU_OC(Src1_OCID_RAU_OC),
    .Src2_OCID_RAU_OC(Src2_OCID_RAU_OC),

    //read write output
    .Src1_Valid(Src1_Valid),
    .Src2_Valid(Src2_Valid),
    .Src1_Phy_Bank_ID(Src1_Phy_Bank_ID),
    .Src2_Phy_Bank_ID(Src2_Phy_Bank_ID),
    .Src1_Phy_Row_ID(Src1_Phy_Row_ID),
    .Src2_Phy_Row_ID(Src2_Phy_Row_ID),

    .ReqFIFO_2op_EN(ReqFIFO_2op_EN),

    .WriteRow(WriteRow),
    .WriteBank(WriteBank),

    //every
    .Valid_RAU_OC(Valid_RAU_OC) ,//use
    .Instr_RAU_OC(Instr_RAU_OC) ,//pass

    .WarpID_RAU_OC(WarpID_RAU_OC),
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

    .RegWrite_RAU_OC(RegWrite_RAU_OC),
    .Dst_RAU_OC(Dst_RAU_OC),

    .Data_CDB(Data_CDB),
    .Instr_CDB(),  //////////////////////!@DASDUFHEFIUABEIPFULKBASEIUDKIALEBFCILWSBHD

    .SPEslot_RAU_OC(SPEslot_RAU_OC),
    .SPEvalue_RAU_OC(SPEvalue_RAU_OC),
    .SPEv2slot_RAU_OC(SPEv2slot_RAU_OC),
    .SPEv2value_RAU_OC(SPEv2value_RAU_OC),

    .ReqFIFO_Same(ReqFIFO_Same)
);

ReqFIFO_4 ReqFIFO_4(
    .rst(rst),
    .clk(clk),

    .Valid_RAU_OC(Valid_RAU_OC),
    .WriteValid(RegWrite_CDB_RAU),

    .WriteBank(WriteBank),
    .WriteRow(WriteRow),
    
    .Src1_Valid(Src1_Valid),
    .Src1_Phy_Bank_ID(Src1_Phy_Bank_ID),
    .Src1_Phy_Row_ID(Src1_Phy_Row_ID),
    .Src2_Valid(Src2_Valid),
    .Src2_Phy_Bank_ID(Src2_Phy_Bank_ID),
    .Src2_Phy_Row_ID(Src2_Phy_Row_ID),
    .ReqFIFO_2op_EN(ReqFIFO_2op_EN),
    
    .Src1_OCID_RAU_OC(Src1_OCID_RAU_OC),
    .Src2_OCID_RAU_OC(Src2_OCID_RAU_OC),

    .Data_CDB(Data_CDB),
    .ReqFIFO_Same(ReqFIFO_Same),

    .RF_Addr_0(RF_Addr_0),
    .RF_Addr_1(RF_Addr_1),
    .RF_Addr_2(RF_Addr_2),
    .RF_Addr_3(RF_Addr_3),

    .ocid_out_0(ocid_out_0),
    .ocid_out_1(ocid_out_1),
    .ocid_out_2(ocid_out_2),
    .ocid_out_3(ocid_out_3),

    .RF_WR_0(RF_WR_0),
    .RF_WR_1(RF_WR_1),
    .RF_WR_2(RF_WR_2),
    .RF_WR_3(RF_WR_3),

    .WriteData_0(WriteData_0),
    .WriteData_1(WriteData_1),
    .WriteData_2(WriteData_2),
    .WriteData_3(WriteData_3),

    .same_0(same_0),
    .same_1(same_1),
    .same_2(same_2),
    .same_3(same_3)
);

RegisterFile RegisterFile(
    .clk(clk),

    .same_0(same_0),
    .same_1(same_1),
    .same_2(same_2),
    .same_3(same_3),
    .RF_WR_MASK(ActiveMask_CDB_RAU),
    .RF_Addr_0(RF_Addr_0),
    .RF_Addr_1(RF_Addr_1),
    .RF_Addr_2(RF_Addr_2),
    .RF_Addr_3(RF_Addr_3),

    .ocid_out_0(ocid_out_0),
    .ocid_out_1(ocid_out_1),
    .ocid_out_2(ocid_out_2),
    .ocid_out_3(ocid_out_3),

    .RF_WR_0(RF_WR_0),
    .RF_WR_1(RF_WR_1),
    .RF_WR_2(RF_WR_2),
    .RF_WR_3(RF_WR_3),

    .WriteData_0(WriteData_0),
    .WriteData_1(WriteData_1),
    .WriteData_2(WriteData_2),
    .WriteData_3(WriteData_3),

    .DataOut_0(DataOut_0),
    .DataOut_1(DataOut_1),
    .DataOut_2(DataOut_2),
    .DataOut_3(DataOut_3),//不能写wire？

    
    .ocid_0(ocid_0),
    .ocid_1(ocid_1),
    .ocid_2(ocid_2),
    .ocid_3(ocid_3),
    .same_OC_0(same_OC_0),
    .same_OC_1(same_OC_1),
    .same_OC_2(same_OC_2),
    .same_OC_3(same_OC_3)
);

OC_collector_4 OC_collector_4(
    .rst(rst),
    .clk(clk),

    .same_OC_0(same_OC_0),
    .same_OC_1(same_OC_1),
    .same_OC_2(same_OC_2),
    .same_OC_3(same_OC_3),

    .SPEslot_RAU_OC(SPEslot_RAU_OC),
    .SPEvalue_RAU_OC(SPEvalue_RAU_OC),
    .SPEv2slot_RAU_OC(SPEv2slot_RAU_OC),
    .SPEv2value_RAU_OC(SPEv2value_RAU_OC),
    

    .ALU_Grt_Sched_OC(ALU_Grt_Sched_OC),
    .MEM_Grt_Sched_OC(MEM_Grt_Sched_OC),

    .Valid_RAU_OC(Valid_RAU_OC),//use
    .Instr_RAU_OC(Instr_RAU_OC) ,//pass
    .WarpID_RAU_OC(WarpID_RAU_OC),
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


    .DataOut_0(DataOut_0),
    .DataOut_1(DataOut_1),
    .DataOut_2(DataOut_2),
    .DataOut_3(DataOut_3),//不能写wire？

    
    .ocid_0(ocid_0),
    .ocid_1(ocid_1),
    .ocid_2(ocid_2),
    .ocid_3(ocid_3),

    .Src1_Phy_Bank_ID(Src1_Phy_Bank_ID),
    .Src2_Phy_Bank_ID(Src2_Phy_Bank_ID),

    .Src1_OCID_RAU_OC(Src1_OCID_RAU_OC),
    .Src2_OCID_RAU_OC(Src2_OCID_RAU_OC),

    .oc_0_data_0(oc_0_data_0),
    .oc_1_data_0(oc_1_data_0),

    .RDY_0(RDY_0), 
    .valid_0(valid_0),

    .WarpID_OC_Ex_0(WarpID_OC_Ex_0),
    .Valid_OC_Ex_0(Valid_OC_Ex_0) ,//use
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

    .RDY_1(RDY_1), 
    .valid_1(valid_1),

    .WarpID_OC_Ex_1(WarpID_OC_Ex_1),
    .Valid_OC_Ex_1(Valid_OC_Ex_1) ,//use
    .Instr_OC_Ex_1(Instr_OC_Ex_1) ,//pass
    .RegWrite_OC_Ex_1(RegWrite_OC_Ex_1),
    .Imme_OC_Ex_1(Imme_OC_Ex_1) ,//
    .Imme_Valid_OC_Ex_1(Imme_Valid_OC_Ex_1) ,//
    .ALUop_OC_Ex_1(ALUop_OC_Ex_1) ,//
    .MemWrite_OC_Ex_1(MemWrite_OC_Ex_1),//
    .MemRead_OC_Ex_1(MemRead_OC_Ex_1) ,//
    .Shared_Globalbar_OC_Ex_1(Shared_Globalbar_OC_Ex_1) ,//pass
    .BEQ_OC_Ex_1(BEQ_OC_Ex_1) ,//pass
    .BLT_OC_Ex_1(BLT_OC_Ex_1) ,//pass
    .ScbID_OC_Ex_1(ScbID_OC_Ex_1) ,//pass
    .ActiveMask_OC_Ex_1(ActiveMask_OC_Ex_1),//pass
    .Dst_OC_Ex_1(Dst_OC_Ex_1),
    .oc_0_data_2(oc_0_data_2),
    .oc_1_data_2(oc_1_data_2),

    .RDY_2(RDY_2), 
    .valid_2(valid_2),

    .WarpID_OC_Ex_2(WarpID_OC_Ex_2),
    .Valid_OC_Ex_2(Valid_OC_Ex_2) ,//use
    .Instr_OC_Ex_2(Instr_OC_Ex_2) ,//pass
    .RegWrite_OC_Ex_2(RegWrite_OC_Ex_2),
    .Imme_OC_Ex_2(Imme_OC_Ex_2) ,//
    .Imme_Valid_OC_Ex_2(Imme_Valid_OC_Ex_2) ,//
    .ALUop_OC_Ex_2(ALUop_OC_Ex_2) ,//
    .MemWrite_OC_Ex_2(MemWrite_OC_Ex_2),//
    .MemRead_OC_Ex_2(MemRead_OC_Ex_2) ,//
    .Shared_Globalbar_OC_Ex_2(Shared_Globalbar_OC_Ex_2) ,//pass
    .BEQ_OC_Ex_2(BEQ_OC_Ex_2) ,//pass
    .BLT_OC_Ex_2(BLT_OC_Ex_2) ,//pass
    .ScbID_OC_Ex_2(ScbID_OC_Ex_2) ,//pass
    .ActiveMask_OC_Ex_2(ActiveMask_OC_Ex_2),//pass
    .Dst_OC_Ex_2(Dst_OC_Ex_2),
    .oc_0_data_3(oc_0_data_3),
    .oc_1_data_3(oc_1_data_3),

    .RDY_3(RDY_3), 
    .valid_3(valid_3),

    .WarpID_OC_Ex_3(WarpID_OC_Ex_3),
    .Valid_OC_Ex_3(Valid_OC_Ex_3) ,//use
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

    .Src1_Valid(Src1_Valid),
    .Src2_Valid(Src2_Valid)
);

scheduler_4 sched_4(
    .rst(rst),
    .clk(clk),
    .RDY_0(RDY_0),
    .RDY_1(RDY_1),
    .RDY_2(RDY_2),
    .RDY_3(RDY_3),
    .RegWrite_OC_Ex_0(RegWrite_OC_Ex_0),
    .RegWrite_OC_Ex_1(RegWrite_OC_Ex_1),
    .RegWrite_OC_Ex_2(RegWrite_OC_Ex_2),
    .RegWrite_OC_Ex_3(RegWrite_OC_Ex_3),
    .MemWrite_OC_Ex_0(MemWrite_OC_Ex_0),
    .MemWrite_OC_Ex_1(MemWrite_OC_Ex_1),
    .MemWrite_OC_Ex_2(MemWrite_OC_Ex_2),
    .MemWrite_OC_Ex_3(MemWrite_OC_Ex_3),
    .MemRead_OC_Ex_0(MemRead_OC_Ex_0),
    .MemRead_OC_Ex_1(MemRead_OC_Ex_1),
    .MemRead_OC_Ex_2(MemRead_OC_Ex_2),
    .MemRead_OC_Ex_3(MemRead_OC_Ex_3),

    
    .ALU_Grt_Sched_OC(ALU_Grt_Sched_OC),
    .MEM_Grt_Sched_OC(MEM_Grt_Sched_OC)
);

MUX_ALU_MEM MUX_ALU_MEM(
    .MEM_Grt(MEM_Grt_Sched_OC),
    .ALU_Grt(ALU_Grt_Sched_OC),

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


    .Src1_Data_ALU(Src1_Data_ALU),
    .Src2_Data_ALU(Src2_Data_ALU),

    .Valid_OC_ALU(Valid_OC_ALU) ,//use
    .WarpID_OC_ALU(WarpID_OC_ALU) ,
    .Instr_OC_ALU(Instr_OC_ALU) ,//pass
    .RegWrite_OC_ALU(RegWrite_OC_ALU),
    .Imme_OC_ALU(Imme_OC_ALU) ,//
    .Imme_Valid_OC_ALU(Imme_Valid_OC_ALU) ,//
    .ALUop_OC_ALU(ALUop_OC_ALU) ,//
    .MemWrite_OC_ALU(MemWrite_OC_ALU) ,//
    .MemRead_OC_ALU(MemRead_OC_ALU) ,//
    .Shared_Globalbar_OC_ALU(Shared_Globalbar_OC_ALU) ,//pass
    .BEQ_OC_ALU(BEQ_OC_ALU) ,//pass
    .BLT_OC_ALU(BLT_OC_ALU) ,//pass
    .ScbID_OC_ALU(ScbID_OC_ALU) ,//pass
    .ActiveMask_OC_ALU(ActiveMask_OC_ALU),//pass
    .Dst_OC_ALU(Dst_OC_ALU),

    .Src1_Data_MEM(Src1_Data_MEM),
    .Src2_Data_MEM(Src2_Data_MEM),

    .Valid_OC_MEM(Valid_OC_MEM) ,//use
    .WarpID_OC_MEM(WarpID_OC_MEM) ,
    .Instr_OC_MEM(Instr_OC_MEM) ,//pass
    .RegWrite_OC_MEM(RegWrite_OC_MEM),
    .Imme_OC_MEM(Imme_OC_MEM) ,//
    .Imme_Valid_OC_MEM(Imme_Valid_OC_MEM) ,//
    .ALUop_OC_MEM(ALUop_OC_MEM) ,//
    .MemWrite_OC_MEM(MemWrite_OC_MEM) ,//
    .MemRead_OC_MEM(MemRead_OC_MEM) ,//
    .Shared_Globalbar_OC_MEM(Shared_Globalbar_OC_MEM) ,//pass
    .BEQ_OC_MEM(BEQ_OC_MEM) ,//pass
    .BLT_OC_MEM(BLT_OC_MEM) ,//pass
    .ScbID_OC_MEM(ScbID_OC_MEM) ,//pass
    .ActiveMask_OC_MEM(ActiveMask_OC_MEM),//pass
    .Dst_OC_MEM(Dst_OC_MEM)
);

endmodule