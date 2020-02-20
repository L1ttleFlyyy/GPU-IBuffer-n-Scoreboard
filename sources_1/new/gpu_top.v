`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2020 03:02:28 PM
// Design Name: 
// Module Name: gpu_top
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


module gpu_top#(
    parameter NUM_WARPS = 8,
    parameter NUM_THREADS = 8,
    parameter LOGNUM_WARPS = $clog2(NUM_WARPS)
    )(
    input clk,
    input rst
    );

    /* connections to/from I-Buffer */
    // signals to/from IF stage (warp specific)
    wire [NUM_WARPS-1:0]Valid_IF_IB; 
    wire [NUM_WARPS-1:0]Req_IB_IF;
    
    // signals from SIMT (warp specific)
    wire [NUM_WARPS-1:0]DropInstr_SIMT_IB;
    wire [NUM_WARPS*NUM_THREADS-1:0]AM_Flattened_SIMT_IB; //TODO: Flattened I/O or not?

    // signals from ID stage (dual decoding unit)
    wire Valid_ID0_IB_SIMT;
    wire [31:0] Instr_ID0_IB;
    wire [4:0] Src1_ID0_IB;
    wire [4:0] Src2_ID0_IB;
    wire [4:0] Dst_ID0_IB;
	wire Src1_Valid_ID0_IB;
	wire Src2_Valid_ID0_IB;
	wire Dst_Valid_ID0_IB;
    wire [3:0] ALUop_ID0_IB;
    wire [15:0] Imme_ID0_IB;
    wire RegWrite_ID0_IB;
    wire MemWrite_ID0_IB;
    wire MemRead_ID0_IB;
    wire Shared_Globalbar_ID0_IB;
    wire BEQ_ID0_IB_SIMT;
    wire BLT_ID0_IB_SIMT;
    wire Exit_ID0_IB;

    wire Valid_ID1_IB_SIMT;
    wire [31:0] Instr_ID1_IB;
    wire [4:0] Src1_ID1_IB;
    wire [4:0] Src2_ID1_IB;
    wire [4:0] Dst_ID1_IB;
	wire Src1_Valid_ID1_IB;
	wire Src2_Valid_ID1_IB;
	wire Dst_Valid_ID1_IB;
    wire [3:0] ALUop_ID1_IB;
    wire [15:0] Imme_ID1_IB;
    wire RegWrite_ID1_IB;
    wire MemWrite_ID1_IB;
    wire MemRead_ID1_IB;
    wire Shared_Globalbar_ID1_IB;
    wire BEQ_ID1_IB_SIMT;
    wire BLT_ID1_IB_SIMT;
    wire Exit_ID1_IB;

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

    // signal to/from Operand Collector // TODO: OC_Full
    wire Valid_IB_OC;
    wire [LOGNUM_WARPS-1:0] WarpID_IB_OC;
    wire [31:0] Instr_IB_OC;
    wire [5:0] Src1_IB_OC; // 5-bit RegID with MSB as Valid
    wire [5:0] Src2_IB_OC;
    wire [5:0] Dst_IB_OC;
    wire [15:0] Imme_IB_OC;
    wire [3:0] ALUop_IB_OC;
    wire RegWrite_IB_OC;
    wire MemWrite_IB_OC;
    wire MemRead_IB_OC;
    wire Shared_Globalbar_IB_OC;
    wire BEQ_IB_OC;
    wire BLT_IB_OC;
    wire [1:0] ScbID_IB_OC;

    // signals to RAU
    wire Exit_IB_RAU_TM;
    wire [LOGNUM_WARPS-1:0] Exit_WarpID_IB_RAU_TM;

    // feedback from MEM
    wire [NUM_THREADS-1:0] PosFB_MEM_IB;
    wire PosFB_Valid_MEM_IB;
    wire ZeroFB_Valid_MEM_IB;
    wire [LOGNUM_WARPS-1:0] PosFB_WarpID_MEM_IB;
    wire [LOGNUM_WARPS-1:0] ZeroFB_WarpID_MEM_IB;

    /* signals to/from Scoreboard*/
    wire [1:0] Clear_ScbID_ALU_Scb; // Clear signal from ALU (branch only)
    wire [1:0] Clear_ScbID_CDB_Scb; // Clear signal from CDB (for all regwrite)
    wire [LOGNUM_WARPS-1:0] Clear_WarpID_ALU_Scb;
    wire [LOGNUM_WARPS-1:0] Clear_WarpID_CDB_Scb;
    wire Clear_Valid_ALU_Scb;
    wire Clear_Valid_CDB_Scb;

    IBuffer IB(
    .clk(clk),
    .rst(rst),
    // signals to/from IF stage (warp specific)
    .Valid_IF_IB(Valid_IF_IB), 
    .Req_IB_IF(Req_IB_IF),
    
    // signals from SIMT (warp specific)
    .DropInstr_SIMT_IB(DropInstr_SIMT_IB),
    .AM_Flattened_SIMT_IB(AM_Flattened_SIMT_IB), //TODO: Flattened I/O or not?

    // signals from ID stage (dual decoding unit)
    .Valid_ID0_IB_SIMT(Valid_ID0_IB_SIMT),
    .Instr_ID0_IB(Instr_ID0_IB),
    .Src1_ID0_IB(Src1_ID0_IB),
    .Src2_ID0_IB(Src2_ID0_IB),
    .Dst_ID0_IB(Dst_ID0_IB),
	.Src1_Valid_ID0_IB(Src1_Valid_ID0_IB),
	.Src2_Valid_ID0_IB(Src2_Valid_ID0_IB),
	.Dst_Valid_ID0_IB(Dst_Valid_ID0_IB),
    .ALUop_ID0_IB(ALUop_ID0_IB),
    .Imme_ID0_IB(Imme_ID0_IB),
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
	.Dst_Valid_ID1_IB(Dst_Valid_ID1_IB),
    .ALUop_ID1_IB(ALUop_ID1_IB),
    .Imme_ID1_IB(Imme_ID1_IB),
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

    // signal to/from Operand Collector // TODO: OC_Full
    .Valid_IB_OC(Valid_IB_OC),
    .WarpID_IB_OC(WarpID_IB_OC),
    .Instr_IB_OC(Instr_IB_OC),
    .Src1_IB_OC(Src1_IB_OC), // 5-bit RegID with MSB as Valid
    .Src2_IB_OC(Src2_IB_OC),
    .Dst_IB_OC(Dst_IB_OC),
    .Imme_IB_OC(Imme_IB_OC),
    .ALUop_IB_OC(ALUop_IB_OC),
    .RegWrite_IB_OC(RegWrite_IB_OC),
    .MemWrite_IB_OC(MemWrite_IB_OC),
    .MemRead_IB_OC(MemRead_IB_OC),
    .Shared_Globalbar_IB_OC(Shared_Globalbar_IB_OC),
    .BEQ_IB_OC(BEQ_IB_OC),
    .BLT_IB_OC(BLT_IB_OC),
    .ScbID_IB_OC(ScbID_IB_OC),

    // signals to RAU
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

endmodule
