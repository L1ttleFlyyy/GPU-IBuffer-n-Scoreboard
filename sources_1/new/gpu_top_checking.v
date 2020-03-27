`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2020 03:02:28 PM
// Design Name: 
// Module Name: gpu_top_checking
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gpu_top_checking#(
    parameter NUM_WARPS = 8,
    parameter NUM_THREADS = 8,
    parameter LOGNUM_WARPS = $clog2(NUM_WARPS)
    )(
    input clk,
    input rst,
    
    // FileIO to TM
    
    input Write_Enable_FIO_TM,
    input [28:0] Write_Data_FIO_TM,
    input start_FIO_TM,
    input clear_FIO_TM,
    output finished_TM_FIO,

    // FileIO to ICache
	input FileIO_Wen_ICache,
	input [11:0] FileIO_Addr_ICache,
	input [31:0] FileIO_Din_ICache,
	output [31:0] FileIO_Dout_ICache,

    // From CDB to Scoreboard
    input [1:0] Clear_ScbID_CDB_Scb, // Clear signal from CDB (for all regwrite)
    input [LOGNUM_WARPS-1:0] Clear_WarpID_CDB_Scb,
    input Clear_Valid_CDB_Scb,

    // feedback from MEM
    input [NUM_THREADS-1:0] PosFB_MEM_IB,
    input PosFB_Valid_MEM_IB,
    input ZeroFB_Valid_MEM_IB,
    input [LOGNUM_WARPS-1:0] PosFB_WarpID_MEM_IB,
    input [LOGNUM_WARPS-1:0] ZeroFB_WarpID_MEM_IB,

    //Write
    input RegWrite_CDB_RAU,
    input [2:0] WriteAddr_CDB_RAU,
    input [2:0] HWWarp_CDB_RAU,
    input [255:0] Data_CDB_RAU,
    input [31:0] Instr_CDB_RAU,
    input [7:0] ActiveMask_CDB_RAU,

    output [255:0]Src1_Data_OC_MEM,
    output [255:0]Src2_Data_OC_MEM,

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
    output [4:0] Dst_OC_MEM,

    // TODO: ALU internal signals
    
	output [7:0] ActiveMask_ALU_CDB,
    output [31:0] Instr_ALU_CDB,
    output [2:0] WarpID_ALU_CDB, 
    output RegWrite_ALU_CDB,
    output [4:0] Dst_ALU_CDB,
    output [8*32-1:0] Dst_Data_ALU_CDB
    );

    // TM to IF_ID
    wire UpdatePC_TM_PC;
    wire [2:0] WarpID_TM_PC;
    wire [31:0] StartingPC_TM_PC;
    
    // TM to/from SIMT
    wire Update_TM_SIMT;
    wire [2:0] WarpID_TM_SIMT;
    wire [7:0] AM_TM_SIMT;

    // TM to/from RAU
    wire Update_TM_RAU;
    wire [2:0] HWWarpID_TM_RAU;
    wire [7:0] SWWarpID_TM_RAU;
    wire [2:0] Nreg_TM_RAU;
    wire Alloc_BusyBar_RAU_TM;

	// From SIMT to ID
	wire [7:0] Stall_SIMT_PC;
	wire [7:0] UpdatePC_Qual1_SIMT_PC;
	wire [7:0] UpdatePC_Qual2_SIMT_PC;
	wire [32*8-1:0] TargetAddr_SIMT_PC_Flattened; //work with UpdatePC_Qual2_SIMT_PC
	
	// ID To SMIT
	wire [31:0] PCplus4_ID0_SIMT;
	wire [31:0] PCplus4_ID1_SIMT;
	wire DotS_ID0_SIMT;
	wire DotS_ID1_SIMT;
	wire Call_ID0_SIMT;
	wire Call_ID1_SIMT;
	wire Ret_ID0_SIMT;
	wire Ret_ID1_SIMT;
	wire Jmp_ID0_SIMT;
	wire Jmp_ID1_SIMT;

	//From IB to PC
	wire [7:0] Req_IB_IF;

    // ID to IB
	wire [7:0] Valid_IF_ID0_IB;
	wire [7:0] Valid_IF_ID1_IB;
	wire [4:0] Src1_ID0_IB; 
	wire [4:0] Src1_ID1_IB;
	wire [4:0] Src2_ID0_IB;
	wire [4:0] Src2_ID1_IB;
	wire [4:0] Dst_ID0_IB;
	wire [4:0] Dst_ID1_IB;
	wire [15:0] Imme_ID0_IB; 
	wire [15:0] Imme_ID1_IB;
	wire RegWrite_ID0_IB;
	wire RegWrite_ID1_IB;
	wire MemWrite_ID0_IB;
	wire MemWrite_ID1_IB;
	wire MemRead_ID0_IB;
	wire MemRead_ID1_IB;
	wire Exit_ID0_IB;
	wire Exit_ID1_IB;
	wire [3:0] ALUop_ID0_IB;
	wire [3:0] ALUop_ID1_IB;
	wire Shared_Globalbar_ID0_IB;
	wire Shared_Globalbar_ID1_IB;
	wire Src1_Valid_ID0_IB;
	wire Src1_Valid_ID1_IB;
	wire Src2_Valid_ID0_IB;
	wire Src2_Valid_ID1_IB;
	wire Imme_Valid_ID0_IB;
	wire Imme_Valid_ID1_IB;
	wire [31:0] Instr_ID0_IB;
	wire [31:0] Instr_ID1_IB;
	//To both SMIT&I-buffer
	wire BEQ_ID0_IB_SIMT;
	wire BEQ_ID1_IB_SIMT;
	wire BLT_ID0_IB_SIMT;
	wire BLT_ID1_IB_SIMT;
	wire [7:0] Valid_ID0_IB_SIMT;	//one-hot warpID
	wire [7:0] Valid_ID1_IB_SIMT;
    
    // signals from SIMT (warp specific)
    wire [NUM_WARPS-1:0]DropInstr_SIMT_IB;
    wire [NUM_WARPS*NUM_THREADS-1:0]ActiveMask_SIMT_IB_Flattened;

    // signals to/from scoreboard (warp specific)
    wire [NUM_WARPS-1:0] RP_Grt_IB_Scb;
    wire [5*NUM_WARPS-1:0] Src1_Flattened_IB_Scb;
    wire [5*NUM_WARPS-1:0] Src2_Flattened_IB_Scb;
    wire [5*NUM_WARPS-1:0] Dst_Flattened_IB_Scb;
    wire [NUM_WARPS-1:0] Src1_Valid_IB_Scb;
    wire [NUM_WARPS-1:0] Src2_Valid_IB_Scb;
    wire [NUM_WARPS-1:0] Dst_Valid_IB_Scb;
    wire [NUM_WARPS-1:0] Replayable_IB_Scb;
    // when clearing
    wire [2*NUM_WARPS-1:0] Replay_Complete_ScbID_Flattened_IB_Scb;
    wire [NUM_WARPS-1:0] Replay_Complete_IB_Scb;
    wire [NUM_WARPS-1:0] Replay_Complete_SW_LWbar_IB_Scb;
    // when issuing
    wire [NUM_WARPS-1:0] Full_Scb_IB;
    wire [NUM_WARPS-1:0] Empty_Scb_IB;
    wire [NUM_WARPS-1:0] Dependent_Scb_IB;
    wire [2*NUM_WARPS-1:0] ScbID_Flattened_Scb_IB;

    // signal to/from IU
    wire [NUM_WARPS-1:0] Req_IB_IU;
    wire [NUM_WARPS-1:0] Grt_IU_IB;
    wire [NUM_WARPS-1:0] Exit_Req_IB_IU;
    wire [NUM_WARPS-1:0] Exit_Grt_IU_IB;

    // IB to/from OC
    wire Valid_IB_OC;
    wire Full_OC_IB;
    wire [2:0] WarpID_IB_OC; //with valid?
    wire [31:0] Instr_IB_OC;
    wire [4:0] Src1_IB_OC;// MSB 是 取R16 下一位是specialreg
    wire Src1_Valid_IB_OC;
    wire [4:0] Src2_IB_OC;
    wire Src2_Valid_IB_OC;
    wire [4:0] Dst_IB_OC;
    wire [15:0] Imme_IB_OC;
    wire Imme_Valid_IB_OC;
    wire [3:0] ALUop_IB_OC;
    wire RegWrite_IB_OC;
    wire MemWrite_IB_OC;//区分是给ALU还是MEN，再分具体的操作
    wire MemRead_IB_OC;
    wire Shared_Globalbar_IB_OC;
    wire BEQ_IB_OC;
    wire BLT_IB_OC;
    wire [1:0] ScbID_IB_OC;
    wire [7:0] ActiveMask_IB_OC;

    // IB to RAU/TM
    wire [2:0] Exit_WarpID_IB_RAU_TM;
    wire Exit_IB_RAU_TM;
    wire [7:0] AllocStall_RAU_IB;

    // RFOC output

    wire [255:0] Src1_Data_OC_ALU;
    wire [255:0] Src2_Data_OC_ALU;

    wire Valid_OC_ALU;//use
    wire [2:0] WarpID_OC_ALU;
    wire [31:0] Instr_OC_ALU;//pass
    wire RegWrite_OC_ALU;
    wire [15:0] Imme_OC_ALU;//
    wire Imme_Valid_OC_ALU;//
    wire [3:0] ALUop_OC_ALU;//
    wire MemWrite_OC_ALU;//
    wire MemRead_OC_ALU;//
    wire Shared_Globalbar_OC_ALU;//pass
    wire BEQ_OC_ALU;//pass
    wire BLT_OC_ALU;//pass
    wire [1:0] ScbID_OC_ALU;//pass
    wire [7:0] ActiveMask_OC_ALU;//pass
    wire [4:0] Dst_OC_ALU;


	// From ALU to ID
	wire [32*8-1:0] TargetAddr_ALU_PC_Flattened;
    
    // From ALU to SIMT
    wire Br_ALU_SIMT;
    wire [7:0] BrOutcome_ALU_SIMT;
    wire [2:0] WarpID_ALU_SIMT;

    // ALU to Scb
    wire [1:0] Clear_ScbID_ALU_Scb; // Clear signal from ALU (branch only)
    wire [LOGNUM_WARPS-1:0] Clear_WarpID_ALU_Scb;
    wire Clear_Valid_ALU_Scb;

    TaskManager TM(
    // Global Signals
    .clk(clk),
    .rst(rst),

    //interface with SIMT
    .Update_TM_SIMT(Update_TM_SIMT),
    .WarpID_TM_SIMT(WarpID_TM_SIMT),
    .AM_TM_SIMT(AM_TM_SIMT),

    //interface with Fetch
    .UpdatePC_TM_PC(UpdatePC_TM_PC),
    .WarpID_TM_PC(WarpID_TM_PC),
    .StartingPC_TM_PC(StartingPC_TM_PC[9:0]),

    //interface with Issue Unit
    .Exit_IB_RAU_TM(Exit_IB_RAU_TM),
    .Exit_WarpID_IB_RAU_TM(Exit_WarpID_IB_RAU_TM),

    //interface with Register File Allocation Unit
    .Update_TM_RAU(Update_TM_RAU),
    .HWWarpID_TM_RAU(HWWarpID_TM_RAU),
    .SWWarpID_TM_RAU(SWWarpID_TM_RAU),
    .Nreg_TM_RAU(Nreg_TM_RAU),
    .Alloc_BusyBar_RAU_TM(Alloc_BusyBar_RAU_TM),
    .Write_Enable_FIO_TM(Write_Enable_FIO_TM),
    .Write_Data_FIO_TM(Write_Data_FIO_TM),
    .start_FIO_TM(start_FIO_TM),
    .clear_FIO_TM(clear_FIO_TM),
    .finished_TM_FIO(finished_TM_FIO)
    );

    Fetch_Decode IF_ID (
	.clk(clk), 
	.rst_n(rst),
	// FileIO
	.FileIO_Wen_ICache(FileIO_Wen_ICache),
	.FileIO_Addr_ICache(FileIO_Addr_ICache),
	.FileIO_Din_ICache(FileIO_Din_ICache),
	.FileIO_Dout_ICache(FileIO_Dout_ICache),
	//From TM
	.WarpID_TM_PC(WarpID_TM_PC),
	.UpdatePC_TM_PC(UpdatePC_TM_PC),
	.StartingPC_TM_PC(StartingPC_TM_PC),	
	//From ALU
	.TargetAddr_ALU_PC_Flattened(TargetAddr_ALU_PC_Flattened), //work with UpdatePC_Qual1_SIMT_PC
	//From SIMT
	.Stall_SIMT_PC(Stall_SIMT_PC),
	.UpdatePC_Qual1_SIMT_PC(UpdatePC_Qual1_SIMT_PC),
	.UpdatePC_Qual2_SIMT_PC(UpdatePC_Qual2_SIMT_PC),
	.TargetAddr_SIMT_PC_Flattened(TargetAddr_SIMT_PC_Flattened), //work with UpdatePC_Qual2_SIMT_PC
	//From IB 
	.Req_IB_PC(Req_IB_IF),// TODO: IF or PC?
	
	// To SMIT
	.PCplus4_ID0_SIMT(PCplus4_ID0_SIMT),
	.PCplus4_ID1_SIMT(PCplus4_ID1_SIMT),
	.DotS_ID0_SIMT(DotS_ID0_SIMT),
	.DotS_ID1_SIMT(DotS_ID1_SIMT),
	.Call_ID0_SIMT(Call_ID0_SIMT),
	.Call_ID1_SIMT(Call_ID1_SIMT),
	.Ret_ID0_SIMT(Ret_ID0_SIMT),
	.Ret_ID1_SIMT(Ret_ID1_SIMT),
	.Jmp_ID0_SIMT(Jmp_ID0_SIMT),
	.Jmp_ID1_SIMT(Jmp_ID1_SIMT),
	//To I-buffer
	.Instr_ID0_IB(Instr_ID0_IB),
	.Instr_ID1_IB(Instr_ID1_IB),
	.Valid_IF_ID0_IB(Valid_IF_ID0_IB),
	.Valid_IF_ID1_IB(Valid_IF_ID1_IB),
	.Src1_ID0_IB(Src1_ID0_IB), 
	.Src1_ID1_IB(Src1_ID1_IB),
	.Src2_ID0_IB(Src2_ID0_IB),
	.Src2_ID1_IB(Src2_ID1_IB),
	.Dst_ID0_IB(Dst_ID0_IB),
	.Dst_ID1_IB(Dst_ID1_IB),
	.Imme_ID0_IB(Imme_ID0_IB), 
	.Imme_ID1_IB(Imme_ID1_IB),
	.RegWrite_ID0_IB(RegWrite_ID0_IB),
	.RegWrite_ID1_IB(RegWrite_ID1_IB),
	.MemWrite_ID0_IB(MemWrite_ID0_IB),
	.MemWrite_ID1_IB(MemWrite_ID1_IB),
	.MemRead_ID0_IB(MemRead_ID0_IB),
	.MemRead_ID1_IB(MemRead_ID1_IB),
	.Exit_ID0_IB(Exit_ID0_IB),
	.Exit_ID1_IB(Exit_ID1_IB),
	.ALUop_ID0_IB(ALUop_ID0_IB),
	.ALUop_ID1_IB(ALUop_ID1_IB),
	.Shared_Globalbar_ID0_IB(Shared_Globalbar_ID0_IB),
	.Shared_Globalbar_ID1_IB(Shared_Globalbar_ID1_IB),
	.Src1_Valid_ID0_IB(Src1_Valid_ID0_IB),
	.Src1_Valid_ID1_IB(Src1_Valid_ID1_IB),
	.Src2_Valid_ID0_IB(Src2_Valid_ID0_IB),
	.Src2_Valid_ID1_IB(Src2_Valid_ID1_IB),
	.Imme_Valid_ID0_IB(Imme_Valid_ID0_IB),
	.Imme_Valid_ID1_IB(Imme_Valid_ID1_IB),
	//To both SMIT&I-buffer
	.BEQ_ID0_IB_SIMT(BEQ_ID0_IB_SIMT),
	.BEQ_ID1_IB_SIMT(BEQ_ID1_IB_SIMT),
	.BLT_ID0_IB_SIMT(BLT_ID0_IB_SIMT),
	.BLT_ID1_IB_SIMT(BLT_ID1_IB_SIMT),
	.Valid_ID0_IB_SIMT(Valid_ID0_IB_SIMT),	//one-hot warpID
	.Valid_ID1_IB_SIMT(Valid_ID1_IB_SIMT)
    );

    SIMT simt_stack(
    // Global Signals
    .clk(clk),
    .rst(rst),

    //interface with Task Manager
    .Update_TM_SIMT(Update_TM_SIMT),
    .WarpID_TM_SIMT(WarpID_TM_SIMT),
    .AM_TM_SIMT(AM_TM_SIMT),

    //interface with Fetch (PC)
    .UpdatePC_Qual1_SIMT_PC(UpdatePC_Qual1_SIMT_PC),
    .UpdatePC_Qual2_SIMT_PC(UpdatePC_Qual2_SIMT_PC),
    .Stall_SIMT_PC(Stall_SIMT_PC),    //Stall signal from SIMT
    .TargetAddr_SIMT_PC_Flattened(TargetAddr_SIMT_PC_Flattened),

    //interface with Instruction Decode
    .BEQ_ID0_IB_SIMT(BEQ_ID0_IB_SIMT),
    .BEQ_ID1_IB_SIMT(BEQ_ID1_IB_SIMT),
    .BLT_ID0_IB_SIMT(BLT_ID0_IB_SIMT),
    .BLT_ID1_IB_SIMT(BLT_ID1_IB_SIMT),
    .DotS_ID0_SIMT(DotS_ID0_SIMT),
    .DotS_ID1_SIMT(DotS_ID1_SIMT),
    .Call_ID0_SIMT(Call_ID0_SIMT),
    .Call_ID1_SIMT(Call_ID1_SIMT),
    .Ret_ID0_SIMT(Ret_ID0_SIMT),
    .Ret_ID1_SIMT(Ret_ID1_SIMT),
    .Jmp_ID0_SIMT(Jmp_ID0_SIMT),
    .Jmp_ID1_SIMT(Jmp_ID1_SIMT),
    .Valid_ID0_IB_SIMT(Valid_ID0_IB_SIMT),
    .Valid_ID1_IB_SIMT(Valid_ID1_IB_SIMT),
    .PCplus4_ID0_SIMT(PCplus4_ID0_SIMT),
    .PCplus4_ID1_SIMT(PCplus4_ID1_SIMT),

    //interface with IBuffer
    .DropInstr_SIMT_IB(DropInstr_SIMT_IB),
    .ActiveMask_SIMT_IB_Flattened(ActiveMask_SIMT_IB_Flattened),

    //interface with ALU
    .Br_ALU_SIMT(Br_ALU_SIMT),
    .BrOutcome_ALU_SIMT(BrOutcome_ALU_SIMT),
    .WarpID_ALU_SIMT(WarpID_ALU_SIMT)

    );

    IBuffer IB(
    .clk(clk),
    .rst(rst),
    // signals to/from IF stage (warp specific)
    .Valid_IF_ID0_IB(Valid_IF_ID0_IB), 
    .Valid_IF_ID1_IB(Valid_IF_ID1_IB), 
    .Req_IB_IF(Req_IB_IF),
    
    // signals from SIMT (warp specific)
    .DropInstr_SIMT_IB(DropInstr_SIMT_IB),
    .ActiveMask_SIMT_IB_Flattened(ActiveMask_SIMT_IB_Flattened), //TODO: Flattened I/O or not?

    // signals from ID stage (dual decoding unit)
    .Valid_ID0_IB_SIMT(Valid_ID0_IB_SIMT),
    .Instr_ID0_IB(Instr_ID0_IB),
    .Src1_ID0_IB(Src1_ID0_IB),
    .Src2_ID0_IB(Src2_ID0_IB),
    .Dst_ID0_IB(Dst_ID0_IB),
	.Src1_Valid_ID0_IB(Src1_Valid_ID0_IB),
	.Src2_Valid_ID0_IB(Src2_Valid_ID0_IB),
    .ALUop_ID0_IB(ALUop_ID0_IB),
    .Imme_ID0_IB(Imme_ID0_IB),
    .Imme_Valid_ID0_IB(Imme_Valid_ID0_IB),
    .RegWrite_ID0_IB(RegWrite_ID0_IB),
    .MemWrite_ID0_IB(MemWrite_ID0_IB),
    .MemRead_ID0_IB(MemRead_ID0_IB),
    .Shared_Globalbar_ID0_IB(Shared_Globalbar_ID0_IB),
    .BEQ_ID0_IB_SIMT(BEQ_ID0_IB_SIMT),
    .BLT_ID0_IB_SIMT(BLT_ID0_IB_SIMT),
    .Exit_ID0_IB(Exit_ID0_IB),

    .Valid_ID1_IB_SIMT(Valid_ID1_IB_SIMT),
    .Instr_ID1_IB(Instr_ID1_IB),
    .Src1_ID1_IB(Src1_ID1_IB),
    .Src2_ID1_IB(Src2_ID1_IB),
    .Dst_ID1_IB(Dst_ID1_IB),
	.Src1_Valid_ID1_IB(Src1_Valid_ID1_IB),
	.Src2_Valid_ID1_IB(Src2_Valid_ID1_IB),
    .ALUop_ID1_IB(ALUop_ID1_IB),
    .Imme_ID1_IB(Imme_ID1_IB),
    .Imme_Valid_ID1_IB(Imme_Valid_ID1_IB),
    .RegWrite_ID1_IB(RegWrite_ID1_IB),
    .MemWrite_ID1_IB(MemWrite_ID1_IB),
    .MemRead_ID1_IB(MemRead_ID1_IB),
    .Shared_Globalbar_ID1_IB(Shared_Globalbar_ID1_IB),
    .BEQ_ID1_IB_SIMT(BEQ_ID1_IB_SIMT),
    .BLT_ID1_IB_SIMT(BLT_ID1_IB_SIMT),
    .Exit_ID1_IB(Exit_ID1_IB),

    // signals to/from scoreboard (warp specific)
    .RP_Grt_IB_Scb(RP_Grt_IB_Scb),
    .Src1_Flattened_IB_Scb(Src1_Flattened_IB_Scb),
    .Src2_Flattened_IB_Scb(Src2_Flattened_IB_Scb),
    .Dst_Flattened_IB_Scb(Dst_Flattened_IB_Scb),
    .Src1_Valid_IB_Scb(Src1_Valid_IB_Scb),
    .Src2_Valid_IB_Scb(Src2_Valid_IB_Scb),
    .Dst_Valid_IB_Scb(Dst_Valid_IB_Scb),
    .Replayable_IB_Scb(Replayable_IB_Scb),
    // when clearing
    .Replay_Complete_ScbID_Flattened_IB_Scb(Replay_Complete_ScbID_Flattened_IB_Scb),
    .Replay_Complete_IB_Scb(Replay_Complete_IB_Scb),
    .Replay_Complete_SW_LWbar_IB_Scb(Replay_Complete_SW_LWbar_IB_Scb),
    // when issuing
    .Full_Scb_IB(Full_Scb_IB),
    .Empty_Scb_IB(Empty_Scb_IB),
    .Dependent_Scb_IB(Dependent_Scb_IB),
    .ScbID_Flattened_Scb_IB(ScbID_Flattened_Scb_IB),

    // signal to/from IU
    .Req_IB_IU(Req_IB_IU),
    .Grt_IU_IB(Grt_IU_IB),
    .Exit_Req_IB_IU(Exit_Req_IB_IU),
    .Exit_Grt_IU_IB(Exit_Grt_IU_IB),

    // signal to/from Operand Collector
    .Full_OC_IB(Full_OC_IB),
    .ActiveMask_IB_OC(ActiveMask_IB_OC),
    .Valid_IB_OC(Valid_IB_OC),
    .WarpID_IB_OC(WarpID_IB_OC),
    .Instr_IB_OC(Instr_IB_OC),
    .Src1_IB_OC(Src1_IB_OC),
    .Src2_IB_OC(Src2_IB_OC),
    .Dst_IB_OC(Dst_IB_OC),
	.Src1_Valid_IB_OC(Src1_Valid_IB_OC),
	.Src2_Valid_IB_OC(Src2_Valid_IB_OC),
    .Imme_IB_OC(Imme_IB_OC),
    .Imme_Valid_IB_OC(Imme_Valid_IB_OC),
    .ALUop_IB_OC(ALUop_IB_OC),
    .RegWrite_IB_OC(RegWrite_IB_OC),
    .MemWrite_IB_OC(MemWrite_IB_OC),
    .MemRead_IB_OC(MemRead_IB_OC),
    .Shared_Globalbar_IB_OC(Shared_Globalbar_IB_OC),
    .BEQ_IB_OC(BEQ_IB_OC),
    .BLT_IB_OC(BLT_IB_OC),
    .ScbID_IB_OC(ScbID_IB_OC),

    // signals from/to RAU
    .AllocStall_RAU_IB(AllocStall_RAU_IB),
    .Exit_IB_RAU_TM(Exit_IB_RAU_TM),
    .Exit_WarpID_IB_RAU_TM(Exit_WarpID_IB_RAU_TM),

    // feedback from MEM
    .PosFB_MEM_IB(PosFB_MEM_IB),
    .PosFB_Valid_MEM_IB(PosFB_Valid_MEM_IB),
    .ZeroFB_Valid_MEM_IB(ZeroFB_Valid_MEM_IB),
    .PosFB_WarpID_MEM_IB(PosFB_WarpID_MEM_IB),
    .ZeroFB_WarpID_MEM_IB(ZeroFB_WarpID_MEM_IB)
    );

    rr_prioritizer#(
        .WIDTH(8)
    ) IU_normal (
        .clk(clk),
        .rst(rst),
        .req(Req_IB_IU),
        .grt(Grt_IU_IB)
    );

    fixed_prioritizer#(
        .WIDTH(8)
    ) IU_exit (
        .req(Exit_Req_IB_IU),
        .grt(Exit_Grt_IU_IB)
    );

    scoreboard Scb(
    .clk(clk),
    .rst(rst),
    .Clear_ScbID_ALU_Scb(Clear_ScbID_ALU_Scb), // Clear signal from ALU (branch only)
    .Clear_ScbID_CDB_Scb(Clear_ScbID_CDB_Scb), // Clear signal from CDB (for all regwrite)
    .Clear_WarpID_ALU_Scb(Clear_WarpID_ALU_Scb),
    .Clear_WarpID_CDB_Scb(Clear_WarpID_CDB_Scb),
    .Clear_Valid_ALU_Scb(Clear_Valid_ALU_Scb),
    .Clear_Valid_CDB_Scb(Clear_Valid_CDB_Scb),

    // Warp specific signals
    // from IBuffer when depositing
    .RP_Grt_IB_Scb(RP_Grt_IB_Scb),
    .Src1_Flattened_IB_Scb(Src1_Flattened_IB_Scb), // Flattened RegID: 5 bit regID * 8 Warps
    .Src2_Flattened_IB_Scb(Src2_Flattened_IB_Scb),
    .Dst_Flattened_IB_Scb(Dst_Flattened_IB_Scb),
    .Src1_Valid_IB_Scb(Src1_Valid_IB_Scb),
    .Src2_Valid_IB_Scb(Src2_Valid_IB_Scb),
    .Dst_Valid_IB_Scb(Dst_Valid_IB_Scb),
    .Replayable_IB_Scb(Replayable_IB_Scb),
    // from IBuffer when Clearing
    .Replay_Complete_ScbID_Flattened_IB_Scb(Replay_Complete_ScbID_Flattened_IB_Scb),
    .Replay_Complete_IB_Scb(Replay_Complete_IB_Scb),
    .Replay_Complete_SW_LWbar_IB_Scb(Replay_Complete_SW_LWbar_IB_Scb),
    // to IBuffer when issuing
    .Full_Scb_IB(Full_Scb_IB),
    .Empty_Scb_IB(Empty_Scb_IB),
    .Dependent_Scb_IB(Dependent_Scb_IB),
    .ScbID_Flattened_Scb_IB(ScbID_Flattened_Scb_IB)
    );

    RFOC OC_RAU (
    .rst(rst),
    .clk(clk),
    
    .Valid_IB_OC(Valid_IB_OC),
    .Instr_IB_OC(Instr_IB_OC),
    .Src1_IB_OC(Src1_IB_OC),// MSB 是 取R16 下一位是specialreg
    .Src1_Valid_IB_OC(Src1_Valid_IB_OC),
    .Src2_IB_OC(Src2_IB_OC),
    .Src2_Valid_IB_OC(Src2_Valid_IB_OC),
    .Dst_IB_OC(Dst_IB_OC),
    .Imme_IB_OC(Imme_IB_OC),
    .Imme_Valid_IB_OC(Imme_Valid_IB_OC),
    .ALUop_IB_OC(Imme_Valid_IB_OC),
    .RegWrite_IB_OC(RegWrite_IB_OC),
    .MemWrite_IB_OC(MemWrite_IB_OC),//区分是给ALU还是MEN，再分具体的操作
    .MemRead_IB_OC(MemRead_IB_OC),
    .Shared_Globalbar_IB_OC(Shared_Globalbar_IB_OC),
    .BEQ_IB_OC(BEQ_IB_OC),
    .BLT_IB_OC(BLT_IB_OC),
    .ScbID_IB_OC(ScbID_IB_OC),
    .ActiveMask_IB_OC(ActiveMask_IB_OC),

    //Allo or exit
    //Exit
    .Update_TM_RAU(Update_TM_RAU),
    .Alloc_BusyBar_RAU_TM(Alloc_BusyBar_RAU_TM),
    .Exit_WarpID_IB_RAU_TM(Exit_WarpID_IB_RAU_TM),
    .Exit_IB_RAU_TM(Exit_IB_RAU_TM),

    //Allo
    .HWWarpID_TM_RAU(HWWarpID_TM_RAU),
    .Nreg_TM_RAU(Nreg_TM_RAU),
    .SWWarpID_TM_RAU(SWWarpID_TM_RAU),

    //Read 
    .WarpID_IB_OC(WarpID_IB_OC), //with valid?
    .Full_OC_IB(Full_OC_IB),//FULL_OC_IF
    .AllocStall_RAU_IB(AllocStall_RAU_IB),

    //Write
    .RegWrite_CDB_RAU(RegWrite_CDB_RAU),
    .WriteAddr_CDB_RAU(WriteAddr_CDB_RAU),
    .HWWarp_CDB_RAU(HWWarp_CDB_RAU),
    .Data_CDB_RAU(Data_CDB_RAU),
    .Instr_CDB_RAU(Instr_CDB_RAU),
    .ActiveMask_CDB_RAU(ActiveMask_CDB_RAU),

    .Src1_Data_ALU(Src1_Data_OC_ALU),
    .Src2_Data_ALU(Src2_Data_OC_ALU),

    .Valid_OC_ALU(Valid_OC_ALU),//use
    .WarpID_OC_ALU(WarpID_OC_ALU),
    .Instr_OC_ALU(Instr_OC_ALU),//pass
    .RegWrite_OC_ALU(RegWrite_OC_ALU),
    .Imme_OC_ALU(Imme_OC_ALU),//
    .Imme_Valid_OC_ALU(Imme_Valid_OC_ALU),//
    .ALUop_OC_ALU(ALUop_OC_ALU),//
    .MemWrite_OC_ALU(MemWrite_OC_ALU),//
    .MemRead_OC_ALU(MemRead_OC_ALU),//
    .Shared_Globalbar_OC_ALU(Shared_Globalbar_OC_ALU),//pass
    .BEQ_OC_ALU(BEQ_OC_ALU),//pass
    .BLT_OC_ALU(BLT_OC_ALU),//pass
    .ScbID_OC_ALU(ScbID_OC_ALU),//pass
    .ActiveMask_OC_ALU(ActiveMask_OC_ALU),//pass
    .Dst_OC_ALU(Dst_OC_ALU),

    .Src1_Data_MEM(Src1_Data_OC_MEM),
    .Src2_Data_MEM(Src2_Data_OC_MEM),

    .Valid_OC_MEM(Valid_OC_MEM),//use
    .WarpID_OC_MEM(WarpID_OC_MEM),
    .Instr_OC_MEM(Instr_OC_MEM),//pass
    .RegWrite_OC_MEM(RegWrite_OC_MEM),
    .Imme_OC_MEM(Imme_OC_MEM),//
    .Imme_Valid_OC_MEM(Imme_Valid_OC_MEM),//
    .ALUop_OC_MEM(ALUop_OC_MEM),//
    .MemWrite_OC_MEM(MemWrite_OC_MEM),//
    .MemRead_OC_MEM(MemRead_OC_MEM),//
    .Shared_Globalbar_OC_MEM(Shared_Globalbar_OC_MEM),//pass
    .BEQ_OC_MEM(BEQ_OC_MEM),//pass
    .BLT_OC_MEM(BLT_OC_MEM),//pass
    .ScbID_OC_MEM(ScbID_OC_MEM),//pass
    .ActiveMask_OC_MEM(ActiveMask_OC_MEM),//pass
    .Dst_OC_MEM(Dst_OC_MEM)
    );

    ALU alu1 (
    // interface with OC
	.clk(clk),
	.rst(rst),
    .Valid_OC_ALU(Valid_OC_ALU),
	.ActiveMask_OC_ALU(ActiveMask_OC_ALU),
    .WarpID_OC_ALU(WarpID_OC_ALU),
    .Instr_OC_ALU(Instr_OC_ALU),
    .Src1_Data_OC_ALU(Src1_Data_OC_ALU),
    .Src2_Data_OC_ALU(Src2_Data_OC_ALU),
    .Dst_OC_ALU(Dst_OC_ALU),
    .Imme_OC_ALU(Imme_OC_ALU),
    .Imme_Valid_OC_ALU(Imme_Valid_OC_ALU),
    .RegWrite_OC_ALU(RegWrite_OC_ALU),
    .ALUop_OC_ALU(ALUop_OC_ALU),
    .BEQ_OC_ALU(BEQ_OC_ALU),
    .BLT_OC_ALU(BLT_OC_ALU),
    .ScbID_OC_ALU(ScbID_OC_ALU), // for BEQ and BLT only, to clear Scb entry

    // output to Fetch
    .TargetAddr_ALU_PC_Flattened(TargetAddr_ALU_PC_Flattened),
	
	// output to SIMT 
	.Br_ALU_SIMT(Br_ALU_SIMT),
	.BrOutcome_ALU_SIMT(BrOutcome_ALU_SIMT),
	.WarpID_ALU_SIMT(WarpID_ALU_SIMT),

    // output to CDB
	.ActiveMask_ALU_CDB(ActiveMask_ALU_CDB),
    .Instr_ALU_CDB(Instr_ALU_CDB),
    .WarpID_ALU_CDB(WarpID_ALU_CDB), 
    .RegWrite_ALU_CDB(RegWrite_ALU_CDB),
    .Dst_ALU_CDB(Dst_ALU_CDB),
    .Dst_Data_ALU_CDB(Dst_Data_ALU_CDB),
    
    // output to Scb (to clear Scb entry. Branch only, which do not go onto CDB)
    .Clear_Valid_ALU_Scb(Clear_Valid_ALU_Scb),
    .Clear_WarpID_ALU_Scb(Clear_WarpID_ALU_Scb),
    .Clear_ScbID_ALU_Scb(Clear_ScbID_ALU_Scb)
    );

endmodule
