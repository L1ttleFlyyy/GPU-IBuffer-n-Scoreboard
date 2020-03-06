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

    //Write
    input wire RegWrite_CDB_OC,
    input wire [2:0] WriteAddr_CDB_OC,
    input wire [2:0] HWWarp_CDB_OC,
    input wire [255:0] Data_CDB_OC,
    input wire [31:0] Instr_CDB_OC,

    // REMOVE: output reg [4:0] Available_RAU_TM,
    // TODO:record num of regs in TM 
    // (instead of requesting and then see if RAU has enough space)
    output reg [7:0] AllocStall_RAU_IB,// TODO: stall IF?

    output reg [255:0] Data1_OC_EX,
    output reg [255:0] Data2_OC_EX,

    output reg Full_OC_IB,//FULL_OC_IF

    output reg Valid_OC_EX,
    output reg [31:0] Instr_OC_EX,
    output reg [4:0] Src1_OC_EX,// MSB 是 取R16 下一位是specialreg
    output reg Src1_Valid_OC_EX,
    output reg [4:0] Src2_OC_EX,
    output reg Src2_Valid_OC_EX,
    output reg [15:0] Imme_OC_EX,
    output reg Imme_Valid_OC_EX,
    output reg [3:0] ALUop_OC_EX,
    output reg RegWrite_OC_EX,
    output reg MemWrite_OC_EX,//区分是给ALU还是MEN，再分具体的操作
    output reg MemRead_OC_EX,
    output reg Shared_Globalbar_OC_EX,
    output reg BEQ_OC_EX,
    output reg BLT_OC_EX,
    output reg [1:0] ScbID_OC_EX,
    output reg [7:0] ActiveMask_OC_EX


);
endmodule