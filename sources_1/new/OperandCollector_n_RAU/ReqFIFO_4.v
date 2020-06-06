
module ReqFIFO_4(
    input rst,
    input clk,

    input Valid_RAU_OC,
    input WriteValid,

    input [1:0] WriteBank,
    input [2:0] WriteRow,
    
    input Src1_Valid,
    input [1:0] Src1_Phy_Bank_ID,
    input [2:0] Src1_Phy_Row_ID,
    input Src2_Valid,
    input [1:0] Src2_Phy_Bank_ID,
    input [2:0] Src2_Phy_Row_ID,
    input ReqFIFO_2op_EN,
    
    input [2:0] Src1_OCID_RAU_OC,
    input [2:0] Src2_OCID_RAU_OC,

    input [255:0] Data_CDB,
    input wire ReqFIFO_Same,


    output [2:0] RF_Addr_0,
    output [2:0] RF_Addr_1,
    output [2:0] RF_Addr_2,
    output [2:0] RF_Addr_3,

    output [3:0] ocid_out_0,
    output [3:0] ocid_out_1,
    output [3:0] ocid_out_2,
    output [3:0] ocid_out_3,

    output RF_WR_0,
    output RF_WR_1,
    output RF_WR_2,
    output RF_WR_3,

    output [255:0] WriteData_0,
    output [255:0] WriteData_1,
    output [255:0] WriteData_2,
    output [255:0] WriteData_3,

    output wire same_0,
    output wire same_1,
    output wire same_2,
    output wire same_3
);


wire ReqFIFO_2op_EN_0 = ReqFIFO_2op_EN & (Src1_Phy_Bank_ID == 2'b00);
wire ReqFIFO_2op_EN_1 = ReqFIFO_2op_EN & (Src1_Phy_Bank_ID == 2'b01);
wire ReqFIFO_2op_EN_2 = ReqFIFO_2op_EN & (Src1_Phy_Bank_ID == 2'b10);
wire ReqFIFO_2op_EN_3 = ReqFIFO_2op_EN & (Src1_Phy_Bank_ID == 2'b11);


wire ReqFIFO_Same_0 = ReqFIFO_Same & (Src1_Phy_Bank_ID == 2'b00);
wire ReqFIFO_Same_1 = ReqFIFO_Same & (Src1_Phy_Bank_ID == 2'b01);
wire ReqFIFO_Same_2 = ReqFIFO_Same & (Src1_Phy_Bank_ID == 2'b10);
wire ReqFIFO_Same_3 = ReqFIFO_Same & (Src1_Phy_Bank_ID == 2'b11);


wire [2:0] Src1_Phy_Row_ID_0 = Src1_Phy_Row_ID;
wire [2:0] Src1_Phy_Row_ID_1 = Src1_Phy_Row_ID;
wire [2:0] Src1_Phy_Row_ID_2 = Src1_Phy_Row_ID;
wire [2:0] Src1_Phy_Row_ID_3 = Src1_Phy_Row_ID;

wire [2:0] Src2_Phy_Row_ID_0 = Src2_Phy_Row_ID;
wire [2:0] Src2_Phy_Row_ID_1 = Src2_Phy_Row_ID;
wire [2:0] Src2_Phy_Row_ID_2 = Src2_Phy_Row_ID;
wire [2:0] Src2_Phy_Row_ID_3 = Src2_Phy_Row_ID;

wire [2:0] Src1_OCID_RAU_OC_0 = Src1_OCID_RAU_OC;
wire [2:0] Src1_OCID_RAU_OC_1 = Src1_OCID_RAU_OC;
wire [2:0] Src1_OCID_RAU_OC_2 = Src1_OCID_RAU_OC;
wire [2:0] Src1_OCID_RAU_OC_3 = Src1_OCID_RAU_OC;

wire [2:0] Src2_OCID_RAU_OC_0 = Src2_OCID_RAU_OC;
wire [2:0] Src2_OCID_RAU_OC_1 = Src2_OCID_RAU_OC;
wire [2:0] Src2_OCID_RAU_OC_2 = Src2_OCID_RAU_OC;
wire [2:0] Src2_OCID_RAU_OC_3 = Src2_OCID_RAU_OC;

wire RF_Read_Valid_0 = Valid_RAU_OC?((Src1_Phy_Bank_ID ==  2'b00)&(Src1_Valid)) | ((Src2_Phy_Bank_ID == 2'b00) & (Src2_Valid)) : 0;
wire RF_Read_Valid_1 = Valid_RAU_OC?((Src1_Phy_Bank_ID ==  2'b01)&(Src1_Valid)) | ((Src2_Phy_Bank_ID == 2'b01) & (Src2_Valid)) : 0;
wire RF_Read_Valid_2 = Valid_RAU_OC?((Src1_Phy_Bank_ID ==  2'b10)&(Src1_Valid)) | ((Src2_Phy_Bank_ID == 2'b10) & (Src2_Valid)) : 0;
wire RF_Read_Valid_3 = Valid_RAU_OC?((Src1_Phy_Bank_ID ==  2'b11)&(Src1_Valid)) | ((Src2_Phy_Bank_ID == 2'b11) & (Src2_Valid)) : 0;

wire RF_Write_Valid_0 = (WriteBank == 2'b00) & (WriteValid);
wire RF_Write_Valid_1 = (WriteBank == 2'b01) & (WriteValid);
wire RF_Write_Valid_2 = (WriteBank == 2'b10) & (WriteValid);
wire RF_Write_Valid_3 = (WriteBank == 2'b11) & (WriteValid);

wire Src1_Valid_0 = ((Src1_Phy_Bank_ID ==  2'b00)&(Src1_Valid));
wire Src1_Valid_1 = ((Src1_Phy_Bank_ID ==  2'b01)&(Src1_Valid));
wire Src1_Valid_2 = ((Src1_Phy_Bank_ID ==  2'b10)&(Src1_Valid));
wire Src1_Valid_3 = ((Src1_Phy_Bank_ID ==  2'b11)&(Src1_Valid));

wire Src2_Valid_0 = ((Src2_Phy_Bank_ID ==  2'b00)&(Src2_Valid));
wire Src2_Valid_1 = ((Src2_Phy_Bank_ID ==  2'b01)&(Src2_Valid));
wire Src2_Valid_2 = ((Src2_Phy_Bank_ID ==  2'b10)&(Src2_Valid));
wire Src2_Valid_3 = ((Src2_Phy_Bank_ID ==  2'b11)&(Src2_Valid));

ReqFIFO Req0(
    .rst(rst),
    .clk(clk),

    .ReqFIFO_2op_EN(ReqFIFO_2op_EN_0),
    .Src1_Valid(Src1_Valid_0),
    .Src2_Valid(Src2_Valid_0),
    .Src1_Phy_Row_ID(Src1_Phy_Row_ID_0), 
    .Src2_Phy_Row_ID(Src2_Phy_Row_ID_0),
    .Src1_OCID_RAU_OC(Src1_OCID_RAU_OC_0),
    .Src2_OCID_RAU_OC(Src2_OCID_RAU_OC_0),
    .RF_Read_Valid(RF_Read_Valid_0),
    .RF_Write_Valid(RF_Write_Valid_0),
    .WriteRow(WriteRow),
    .Data_CDB(Data_CDB),
    .ReqFIFO_Same(ReqFIFO_Same_0),

    .RF_Addr(RF_Addr_0),
    .ocid_out(ocid_out_0),
    .RF_WR(RF_WR_0),

    .WriteData(WriteData_0),
    .same(same_0)
);

ReqFIFO Req1(
    .rst(rst),
    .clk(clk),

    .ReqFIFO_2op_EN(ReqFIFO_2op_EN_1),
    .Src1_Valid(Src1_Valid_1),
    .Src2_Valid(Src2_Valid_1),
    .Src1_Phy_Row_ID(Src1_Phy_Row_ID_1), 
    .Src2_Phy_Row_ID(Src2_Phy_Row_ID_1),
    .Src1_OCID_RAU_OC(Src1_OCID_RAU_OC_1),
    .Src2_OCID_RAU_OC(Src2_OCID_RAU_OC_1),
    .RF_Read_Valid(RF_Read_Valid_1),
    .RF_Write_Valid(RF_Write_Valid_1),
    .WriteRow(WriteRow),
    .Data_CDB(Data_CDB),
    .ReqFIFO_Same(ReqFIFO_Same_1),

    .RF_Addr(RF_Addr_1),
    .ocid_out(ocid_out_1),
    .RF_WR(RF_WR_1),

    .WriteData(WriteData_1),
    .same(same_1)
);

ReqFIFO Req2(
    .rst(rst),
    .clk(clk),

    .ReqFIFO_2op_EN(ReqFIFO_2op_EN_2),
    .Src1_Valid(Src1_Valid_2),
    .Src2_Valid(Src2_Valid_2),
    .Src1_Phy_Row_ID(Src1_Phy_Row_ID_2), 
    .Src2_Phy_Row_ID(Src2_Phy_Row_ID_2),
    .Src1_OCID_RAU_OC(Src1_OCID_RAU_OC_2),
    .Src2_OCID_RAU_OC(Src2_OCID_RAU_OC_2),
    .RF_Read_Valid(RF_Read_Valid_2),
    .RF_Write_Valid(RF_Write_Valid_2),
    .WriteRow(WriteRow),
    .Data_CDB(Data_CDB),
    .ReqFIFO_Same(ReqFIFO_Same_2),

    .RF_Addr(RF_Addr_2),
    .ocid_out(ocid_out_2),
    .RF_WR(RF_WR_2),

    .WriteData(WriteData_2),
    .same(same_2)
);

ReqFIFO Req3(
    .rst(rst),
    .clk(clk),

    .ReqFIFO_2op_EN(ReqFIFO_2op_EN_3),
    .Src1_Valid(Src1_Valid_3),
    .Src2_Valid(Src2_Valid_3),
    .Src1_Phy_Row_ID(Src1_Phy_Row_ID_3), 
    .Src2_Phy_Row_ID(Src2_Phy_Row_ID_3),
    .Src1_OCID_RAU_OC(Src1_OCID_RAU_OC_3),
    .Src2_OCID_RAU_OC(Src2_OCID_RAU_OC_3),
    .RF_Read_Valid(RF_Read_Valid_3),
    .RF_Write_Valid(RF_Write_Valid_3),
    .WriteRow(WriteRow),
    .Data_CDB(Data_CDB),
    .ReqFIFO_Same(ReqFIFO_Same_3),

    .RF_Addr(RF_Addr_3),
    .ocid_out(ocid_out_3),
    .RF_WR(RF_WR_3),

    .WriteData(WriteData_3),
    .same(same_3)
);

endmodule
