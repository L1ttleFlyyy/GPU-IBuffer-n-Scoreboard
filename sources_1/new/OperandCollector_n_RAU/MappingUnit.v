module Mapping(
    input wire rst,
    input wire clk,

    //every
    input wire Valid_IB_RAU,//use

    input wire [31:0] Instr_IB_RAU,//pass
    //
    input wire [4:0] Src1_IB_RAU,//use; MSB->SpecialReg
    input wire Src1_Valid_IB_RAU,//?????
    input wire [4:0] Src2_IB_RAU,//use; MSB->SpecialReg
    input wire Src2_Valid_IB_RAU,//?????
    //
    input wire RegWrite_IB_RAU,
    input wire [4:0] Dst_IB_OC,
    input wire [15:0] Imme_IB_RAU,//use
    input wire Imme_Valid_IB_RAU,//?????
    input wire [3:0] ALUop_IB_RAU,//?????
    input wire MemWrite_IB_RAU,//judge 1 src
    input wire MemRead_IB_RAU,//judge 1 src
    input wire Shared_Globalbar_IB_RAU,//pass
    input wire BEQ_IB_RAU,//pass
    input wire BLT_IB_RAU,//pass
    input wire [1:0] ScbID_IB_RAU,//pass
    input wire [7:0] ActiveMask_IB_RAU,//pass

    //Allo or exit
    //Exit
    input wire [2:0] ExitWarpID_IB_RAU,
    input wire Exit_IB_RAU_TM,

    //Allo
    input wire [2:0] HWWarp_TM_RAU,
    input wire AlloEN_TM_RAU,
    input wire [2:0] Nreq_TM_RAU,
    input wire [7:0] SWWarp_TM_RAU,

    //output reg [4:0] Available_RAU_TM,
    output reg [8:0] AllocStall_RAU_IB,//IF?

    //Read 
    input wire [2:0] HWWarp_IB_RAU, //with valid?

    //Write
    input wire RegWrite_CDB_RAU,
    input wire [2:0] WriteAddr_CDB_RAU,
    input wire [2:0] HWWarp_CDB_RAU,
    input wire [255:0] Data_CDB_RAU,
    input wire [31:0] Instr_CDB_RAU,

    //OCID
    input wire oc_0_empty,
    input wire oc_1_empty,
    input wire oc_2_empty,
    input wire oc_3_empty,

    //OCID
    output reg [1:0] OCID_RAU_OC,
    output wire [2:0] Src1_OCID_RAU_OC,
    output wire [2:0] Src2_OCID_RAU_OC,

    //read write output
    output wire Src1_Valid,
    output wire Src2_Valid,
    output wire [1:0] Src1_Phy_Bank_ID,
    output wire [1:0] Src2_Phy_Bank_ID,
    output wire [2:0] Src1_Phy_Row_ID,
    output wire [2:0] Src2_Phy_Row_ID,

    output wire ReqFIFO_2op_EN,

    output wire [2:0] WriteRow,
    output wire [1:0] WriteBank,
    output wire WriteValid,

    //every
    output wire Valid_RAU_Collecting ,//use
    output wire [31:0] Instr_RAU_Collecting ,//pass

    output wire [15:0] Imme_RAU_Collecting ,//
    output wire Imme_Valid_RAU_Collecting ,//
    output wire [3:0] ALUop_RAU_Collecting ,//
    output wire MemWrite_RAU_Collecting ,//
    output wire MemRead_RAU_Collecting ,//
    output wire Shared_Globalbar_RAU_Collecting ,//pass
    output wire BEQ_RAU_Collecting ,//pass
    output wire BLT_RAU_Collecting ,//pass
    output wire [1:0] ScbID_RAU_Collecting ,//pass
    output wire [7:0] ActiveMask_RAU_Collecting ,//pass

    output wire [255:0]Data_CDB,
    output wire [31:0]Instr_CDB
);






localparam READY  = 3'b001;
localparam ALLO   = 3'b010;
localparam DEALLO = 3'b100;



reg [2:0] state;
reg [2:0] next_state;

reg Req_Done_RAU_IB;


reg [2:0] Nreq;
reg [2:0] HWWarp;
reg [4:0] LUT_StartAddr;
reg [4:0] LUT_Addr;

reg [2:0] LUT_RF_Row;
reg LUT_RF_Bank;
reg [3:0] MTptr;
reg [31:0] SpecialReg[7:0]; //special register file

reg MT [15:0];
reg [4:0] LUT [31:0];

//FSM
//state changing
always @ (posedge clk)
begin
    if (rst == 1'b0) begin
        state <= READY;
    end else begin
        state <= next_state;
    end
end

//conditions
always @ (*)
begin
    case(state)
        READY: begin 
            if (!Exit_IB_RAU_TM & AlloEN_TM_RAU) begin
                next_state = ALLO;
            end else if (Exit_IB_RAU_TM) begin
                next_state = DEALLO;
            end else begin
                next_state = READY;
            end
        end
        ALLO:begin
            if (Req_Done_RAU_IB == 1'b1) begin //defined in next always block
                next_state = READY;

            end else begin
                next_state = ALLO;
            end
        end
        DEALLO:begin
            next_state = READY;
        end
    endcase
end

//Output
always @ (posedge clk)
begin
    if (rst == 1'b0) begin
        Nreq <= 0;
        HWWarp <= 0;
        LUT_StartAddr = 0;
        LUT_RF_Bank = 0;
        LUT_RF_Row = 0;
        MTptr <= 0;
        Req_Done_RAU_IB = 0;
    end else begin


    case(state)
        READY: begin
            AllocStall_RAU_IB = 0;
            if (AlloEN_TM_RAU) begin
                Nreq <= Nreq_TM_RAU;
                HWWarp <= HWWarp_TM_RAU; //SWWARP
                SpecialReg[HWWarp_TM_RAU] <= SWWarp_TM_RAU; // special reg
            end else begin
                HWWarp <= ExitWarpID_IB_RAU; //how to write certain bits in instrcution
            end
        end

        ALLO: begin // regular and special
            AllocStall_RAU_IB = HWWarp; //////TODO！！！！8bit！！！！！！
            LUT_StartAddr = HWWarp * 4;  //LUT starting Addr (Row)
            LUT_RF_Row = MTptr / 2;
            LUT_RF_Bank = MTptr % 2; // gets the mapping of register
                                    //LUT defined as consequtive registers
            LUT_Addr = LUT_StartAddr; 
            while (Nreq != 0) begin
                MTptr <= MTptr + 1;
                if (MT[MTptr] == 1'b0) begin
                    LUT_Addr <= LUT_Addr + 1;//for loop statement//不能用<=??associative？
                    Nreq <= Nreq - 2;
                    LUT[LUT_Addr] <= {1'b1, LUT_RF_Row, LUT_RF_Bank};
                    //Available_RAU_TM <= Available_RAU_TM - 2;
                    Req_Done_RAU_IB = 1'b0;
                end
                else begin
                    Req_Done_RAU_IB = 1'b1;
                    AllocStall_RAU_IB = 0;
                end
                //for (integer i = 0; i<)
            end
        end


        DEALLO: begin
            AllocStall_RAU_IB = 0;
            if (LUT[HWWarp * 4][4] == 1'b1) begin
                MT[LUT[HWWarp * 4][3:1] * 2 + LUT[HWWarp * 4][0]] <= 1'b0;	//MT corresponding bit reset
                LUT[HWWarp * 4][4] <= 1'b0; //LUT valid bit reset
                //Available_RAU_TM <= Available_RAU_TM + 2;
                
            end

            if (LUT[HWWarp * 4 + 1][4] == 1'b1) begin
                MT[LUT[HWWarp * 4 + 1][3:1] * 2 + LUT[HWWarp * 4 + 1][0]] <= 1'b0;
                LUT[HWWarp * 4 + 1][4] <= 1'b0;
                //Available_RAU_TM <= Available_RAU_TM + 4;
                
            end

            if (LUT[HWWarp * 4 + 2][4] == 1'b1) begin
                MT[LUT[HWWarp * 4 + 2][3:1] * 2 + LUT[HWWarp * 4 + 2][0]] <= 1'b0;
                LUT[HWWarp * 4 + 2][4] <= 1'b0;
                //Available_RAU_TM <= Available_RAU_TM + 6;
                
            end
            
            if (LUT[HWWarp * 4 + 3][4] == 1'b1) begin
                MT[LUT[HWWarp * 4 + 3][3:1] * 2 + LUT[HWWarp * 4 + 3][0]] <= 1'b0;			
                LUT[HWWarp * 4 + 3][4] <= 1'b0;
                //Available_RAU_TM <= Available_RAU_TM + 8; // later one will mask the previous ones
            end
        end
    endcase
    end
end




assign WriteValid = RegWrite_CDB_RAU;
assign WriteRow = LUT[(HWWarp_CDB_RAU)*4 + (WriteAddr_CDB_RAU>>1)][3:1];
assign WriteBank = {LUT[(HWWarp_CDB_RAU)*4 + (WriteAddr_CDB_RAU >> 1)][0], 1'b0} + WriteAddr_CDB_RAU[0];

assign Src1_Valid = Src1_Valid_IB_RAU;
assign Src1_Phy_Row_ID = LUT[(HWWarp_IB_RAU*4) + Src1_IB_RAU[2:0]>>1][3:1];
assign Src1_Phy_Bank_ID = {LUT[(HWWarp_IB_RAU*4) + Src1_IB_RAU[2:0]>>1][0]<<1, 1'b0} + Src1_IB_RAU[0];

assign Src2_Valid = Src2_Valid_IB_RAU;
assign Src2_Phy_Row_ID = LUT[(HWWarp_IB_RAU*4) + Src2_IB_RAU[2:0]>>1][3:1];
assign Src2_Phy_Bank_ID = {LUT[(HWWarp_IB_RAU*4) + Src2_IB_RAU[2:0]>>1][0]<<1, 1'b0} + Src2_IB_RAU[0];

//same bank or not?
assign ReqFIFO_2op_EN = (Src1_Phy_Bank_ID == Src2_Phy_Bank_ID) & (Src1_Valid_IB_RAU & Src2_Valid_IB_RAU);
//给到ReqFIFO再到rf


always @ (*)
begin
    if (oc_0_empty == 1)
        OCID_RAU_OC = 2'b00;
    else if (oc_1_empty == 1)
        OCID_RAU_OC = 2'b01;
    else if (oc_2_empty == 1)
        OCID_RAU_OC = 2'b10;
    else if (oc_3_empty == 1)
        OCID_RAU_OC = 2'b11;
end


assign Src1_OCID_RAU_OC = {OCID_RAU_OC , 1'b0};
assign Src2_OCID_RAU_OC = {OCID_RAU_OC , 1'b1};

//occupied to OC


assign Valid_RAU_Collecting = Valid_IB_RAU;
assign Instr_RAU_Collecting = Instr_IB_RAU;

assign Imme_RAU_Collecting =Imme_IB_RAU;
assign Imme_Valid_RAU_Collecting = Imme_Valid_IB_RAU;
assign ALUop_RAU_Collecting = ALUop_IB_RAU;
assign MemWrite_RAU_Collecting = MemWrite_IB_RAU;
assign MemRead_RAU_Collecting = MemRead_IB_RAU;
assign Shared_Globalbar_RAU_Collecting = Shared_Globalbar_IB_RAU;
assign BEQ_RAU_Collecting = BEQ_IB_RAU;
assign BLT_RAU_Collecting = BLT_IB_RAU;
assign ScbID_RAU_Collecting = ScbID_IB_RAU;
assign ActiveMask_RAU_Collecting = ActiveMask_IB_RAU;
assign RegWrite_RAU_Collecting = RegWrite_IB_RAU;


assign Data_CDB = Data_CDB_RAU;
assign Instr_CDB = Instr_CDB_RAU;



endmodule