`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2020 08:53:50 AM
// Design Name: 
// Module Name: IBuffer
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


module IBuffer#(
    parameter NUM_WARPS = 8,
    parameter NUM_THREADS = 8,
    parameter LOGNUM_WARPS = $clog2(NUM_WARPS)
    ) (
    input clk,
    input rst,

    // signals to/from IF stage (warp specific)
    input [NUM_WARPS-1:0]Valid_IF_ID0_IB, 
    input [NUM_WARPS-1:0]Valid_IF_ID1_IB, 
    output [NUM_WARPS-1:0]Req_IB_IF,
    
    // signals from SIMT (warp specific)
    input [NUM_WARPS-1:0]DropInstr_SIMT_IB,
    input [NUM_WARPS*NUM_THREADS-1:0]ActiveMask_SIMT_IB_Flattened, //TODO: Flattened I/O or not?

    // signals from ID stage (dual decoding unit)
    input [NUM_WARPS-1:0] Valid_ID0_IB_SIMT,
    input [31:0] Instr_ID0_IB,
    input [4:0] Src1_ID0_IB,
    input [4:0] Src2_ID0_IB,
    input [4:0] Dst_ID0_IB,
	input Src1_Valid_ID0_IB,
	input Src2_Valid_ID0_IB,
    input [3:0] ALUop_ID0_IB,
    input [15:0] Imme_ID0_IB,
    input Imme_Valid_ID0_IB,
    input RegWrite_ID0_IB,
    input MemWrite_ID0_IB,
    input MemRead_ID0_IB,
    input Shared_Globalbar_ID0_IB,
    input BEQ_ID0_IB_SIMT,
    input BLT_ID0_IB_SIMT,
    input Exit_ID0_IB,

    input [NUM_WARPS-1:0] Valid_ID1_IB_SIMT,
    input [31:0] Instr_ID1_IB,
    input [4:0] Src1_ID1_IB,
    input [4:0] Src2_ID1_IB,
    input [4:0] Dst_ID1_IB,
	input Src1_Valid_ID1_IB,
	input Src2_Valid_ID1_IB,
    input [3:0] ALUop_ID1_IB,
    input [15:0] Imme_ID1_IB,
    input Imme_Valid_ID1_IB,
    input RegWrite_ID1_IB,
    input MemWrite_ID1_IB,
    input MemRead_ID1_IB,
    input Shared_Globalbar_ID1_IB,
    input BEQ_ID1_IB_SIMT,
    input BLT_ID1_IB_SIMT,
    input Exit_ID1_IB,

    // signals to/from scoreboard (warp specific)
    output [NUM_WARPS-1:0] RP_Grt_IB_Scb,
    output [5*NUM_WARPS-1:0] Src1_Flattened_IB_Scb,
    output [5*NUM_WARPS-1:0] Src2_Flattened_IB_Scb,
    output [5*NUM_WARPS-1:0] Dst_Flattened_IB_Scb,
    output [NUM_WARPS-1:0] Src1_Valid_IB_Scb,
    output [NUM_WARPS-1:0] Src2_Valid_IB_Scb,
    output [NUM_WARPS-1:0] Dst_Valid_IB_Scb,
    output [NUM_WARPS-1:0] Replayable_IB_Scb,
    // when clearing
    output [2*NUM_WARPS-1:0] Replay_Complete_ScbID_Flattened_IB_Scb,
    output [NUM_WARPS-1:0] Replay_Complete_IB_Scb,
    output [NUM_WARPS-1:0] Replay_Complete_SW_LWbar_IB_Scb,
    // when issuing
    input [NUM_WARPS-1:0] Full_Scb_IB,
    input [NUM_WARPS-1:0] Empty_Scb_IB,
    input [NUM_WARPS-1:0] Dependent_Scb_IB,
    input [2*NUM_WARPS-1:0] ScbID_Flattened_Scb_IB,

    // signal to/from IU
    output [NUM_WARPS-1:0] Req_IB_IU,
    input [NUM_WARPS-1:0] Grt_IU_IB,
    output [NUM_WARPS-1:0] Exit_Req_IB_IU,
    input [NUM_WARPS-1:0] Exit_Grt_IU_IB,

    // signal to/from Operand Collector
    input Full_OC_IB,
    output Valid_IB_OC,
    output reg [NUM_THREADS-1:0] ActiveMask_IB_OC,
    output reg [LOGNUM_WARPS-1:0] WarpID_IB_OC,
    output reg [31:0] Instr_IB_OC,
    output reg [4:0] Src1_IB_OC,
    output reg [4:0] Src2_IB_OC,
    output reg [4:0] Dst_IB_OC,
    output reg Src1_Valid_IB_OC,
    output reg Src2_Valid_IB_OC,
    output reg [15:0] Imme_IB_OC,
    output reg Imme_Valid_IB_OC,
    output reg [3:0] ALUop_IB_OC,
    output reg RegWrite_IB_OC,
    output reg MemWrite_IB_OC,
    output reg MemRead_IB_OC,
    output reg Shared_Globalbar_IB_OC,
    output reg BEQ_IB_OC,
    output reg BLT_IB_OC,
    output reg [1:0] ScbID_IB_OC,

    // signals from/to RAU
    input [NUM_WARPS-1:0] AllocStall_RAU_IB,
    output Exit_IB_RAU_TM,
    output reg [LOGNUM_WARPS-1:0] Exit_WarpID_IB_RAU_TM,

    // feedback from MEM
    input [NUM_THREADS-1:0] PosFB_MEM_IB,
    input PosFB_Valid_MEM_IB,
    input ZeroFB_Valid_MEM_IB,
    input [LOGNUM_WARPS-1:0] PosFB_WarpID_MEM_IB,
    input [LOGNUM_WARPS-1:0] ZeroFB_WarpID_MEM_IB
    );
    wire [NUM_THREADS-1:0] ActiveMask_SIMT_IB[0:NUM_WARPS-1];

    // signals to/from scoreboard (warp specific)
    wire [4:0] Src1_IB_Scb[0:NUM_WARPS-1];
    wire [4:0] Src2_IB_Scb[0:NUM_WARPS-1];
    wire [4:0] Dst_IB_Scb[0:NUM_WARPS-1];  
    wire [1:0] ScbID_Scb_IB[0:NUM_WARPS-1];
    wire [1:0] Replay_Complete_ScbID_IB_Scb[0:NUM_WARPS-1];


    integer j;
    // input demux
    reg [NUM_WARPS-1:0] PosFB_Valid_array;
    reg [NUM_WARPS-1:0] ZeroFB_Valid_array;
    always@(*) begin
        PosFB_Valid_array = 0;
        ZeroFB_Valid_array = 0;
        PosFB_Valid_array[PosFB_WarpID_MEM_IB] = PosFB_Valid_MEM_IB;
        ZeroFB_Valid_array[ZeroFB_WarpID_MEM_IB] = ZeroFB_Valid_MEM_IB;
    end


    // output mux
    assign Valid_IB_OC = Grt_IU_IB != 0;
    assign Exit_IB_RAU_TM = Exit_Grt_IU_IB != 0;
    always@(*) begin
        WarpID_IB_OC = 0;
        Exit_WarpID_IB_RAU_TM = 0;
        for (j=1; j<NUM_WARPS; j=j+1) begin: Exit_mux
            if (Exit_Grt_IU_IB[j])
                Exit_WarpID_IB_RAU_TM = j;
            if (Grt_IU_IB[j]) 
                WarpID_IB_OC = j;
        end
    end

    // output to OC
    wire [NUM_THREADS-1:0] ActiveMask_array[0:NUM_WARPS-1];
    wire [31:0] Instr_array[0:NUM_WARPS-1];
    wire [4:0] Src1_array[0:NUM_WARPS-1];
    wire [4:0] Src2_array[0:NUM_WARPS-1];
    wire [4:0] Dst_array[0:NUM_WARPS-1];
    wire [15:0] Imme_array[0:NUM_WARPS-1];
    wire [3:0] ALUop_array[0:NUM_WARPS-1];
    wire [NUM_WARPS-1:0] Src1_Valid_array;
    wire [NUM_WARPS-1:0] Src2_Valid_array;
    wire [NUM_WARPS-1:0] Imme_Valid_array;
    wire [NUM_WARPS-1:0] RegWrite_array;
    wire [NUM_WARPS-1:0] MemWrite_array;
    wire [NUM_WARPS-1:0] MemRead_array;
    wire [NUM_WARPS-1:0] Shared_Globalbar_array;
    wire [NUM_WARPS-1:0] BEQ_array;
    wire [NUM_WARPS-1:0] BLT_array;
    wire [1:0] ScbID_array[0:NUM_WARPS-1];


    always@(*) begin
        Instr_IB_OC = Instr_array[0];
        ActiveMask_IB_OC = ActiveMask_array[0];
        Src1_IB_OC = Src1_array[0];
        Src2_IB_OC = Src2_array[0];
        Src1_Valid_IB_OC = Src1_Valid_array[0];
        Src2_Valid_IB_OC = Src2_Valid_array[0];
        Dst_IB_OC = Dst_array[0];
        Imme_IB_OC = Imme_array[0];
        Imme_Valid_IB_OC = Imme_Valid_array[0];
        ALUop_IB_OC = ALUop_array[0];
        RegWrite_IB_OC = RegWrite_array[0];
        MemWrite_IB_OC = MemWrite_array[0];
        MemRead_IB_OC = MemRead_array[0];
        Shared_Globalbar_IB_OC = Shared_Globalbar_array[0];
        BEQ_IB_OC = BEQ_array[0];
        BLT_IB_OC = BLT_array[0];
        ScbID_IB_OC = ScbID_array[0];
        for (j=1; j<NUM_WARPS; j=j+1) begin: IB_OC_mux
            if (Grt_IU_IB[j]) begin   
                ActiveMask_IB_OC = ActiveMask_array[j];    
                Instr_IB_OC = Instr_array[j];
                Src1_IB_OC = Src1_array[j];
                Src2_IB_OC = Src2_array[j];
                Src1_Valid_IB_OC = Src1_Valid_array[j];
                Src2_Valid_IB_OC = Src2_Valid_array[j];
                Dst_IB_OC = Dst_array[j];
                Imme_IB_OC = Imme_array[j];
                Imme_Valid_IB_OC = Imme_Valid_array[j];
                ALUop_IB_OC = ALUop_array[j];
                RegWrite_IB_OC = RegWrite_array[j];
                MemWrite_IB_OC = MemWrite_array[j];
                MemRead_IB_OC = MemRead_array[j];
                Shared_Globalbar_IB_OC = Shared_Globalbar_array[j];
                BEQ_IB_OC = BEQ_array[j];
                BLT_IB_OC = BLT_array[j];
                ScbID_IB_OC = ScbID_array[j];
            end   
        end
    end

    // flatten and unflatten
    genvar i;
    generate
    for (i=0; i<NUM_WARPS; i=i+1) begin: IBuffer_loop
        assign ActiveMask_SIMT_IB[i] = ActiveMask_SIMT_IB_Flattened[NUM_THREADS*(i+1)-1:NUM_THREADS*i];
        assign Src1_Flattened_IB_Scb[5*i+4:5*i] = Src1_IB_Scb[i];
        assign Src2_Flattened_IB_Scb[5*i+4:5*i] = Src2_IB_Scb[i];
        assign Dst_Flattened_IB_Scb[5*i+4:5*i] = Dst_IB_Scb[i];
        assign Replay_Complete_ScbID_Flattened_IB_Scb[2*i+1:2*i] = Replay_Complete_ScbID_IB_Scb[i];
        assign ScbID_Scb_IB[i] = ScbID_Flattened_Scb_IB[2*i+1:2*i];

        IBuffer_warp IBuffer (
            .clk(clk),
            .rst(rst),

            // signals to/from IF stage
            .Valid_IF_ID0_IB(Valid_IF_ID0_IB[i]),
            .Valid_IF_ID1_IB(Valid_IF_ID1_IB[i]),
            .Req_IB_IF(Req_IB_IF[i]),

            // signals from ID stage (dual decoding unit)
            .Valid_ID0_IB_SIMT(Valid_ID0_IB_SIMT[i]),
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

            .Valid_ID1_IB_SIMT(Valid_ID1_IB_SIMT[i]),
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

            // signals from SIMT 
            .DropInstr_SIMT_IB(DropInstr_SIMT_IB[i]),
            .ActiveMask_SIMT_IB(ActiveMask_SIMT_IB[i]),

            // signals to/from IU
            .Req_IB_IU(Req_IB_IU[i]),
            .Grt_IU_IB(Grt_IU_IB[i]),

            // signal to/from OC
            .Full_OC_IB(Full_OC_IB),
            .ActiveMask_IB_OC(ActiveMask_array[i]),
            .Instr_IB_OC(Instr_array[i]),
            .Src1_IB_OC(Src1_array[i]),
            .Src2_IB_OC(Src2_array[i]),
            .Src1_Valid_IB_OC(Src1_Valid_array[i]),
            .Src2_Valid_IB_OC(Src2_Valid_array[i]),
            .Dst_IB_OC(Dst_array[i]),
            .Imme_IB_OC(Imme_array[i]),
            .Imme_Valid_IB_OC(Imme_Valid_array[i]),
            .ALUop_IB_OC(ALUop_array[i]),
            .RegWrite_IB_OC(RegWrite_array[i]),
            .MemWrite_IB_OC(MemWrite_array[i]),
            .MemRead_IB_OC(MemRead_array[i]),
            .Shared_Globalbar_IB_OC(Shared_Globalbar_array[i]),
            .BEQ_IB_OC(BEQ_array[i]),
            .BLT_IB_OC(BLT_array[i]),
            .ScbID_IB_OC(ScbID_array[i]),

            // signal from/to RAU
            .AllocStall_RAU_IB(AllocStall_RAU_IB[i]),
            .Exit_Req_IB_IU(Exit_Req_IB_IU[i]),
            .Exit_Grt_IU_IB(Exit_Grt_IU_IB[i]),

            // signal from/to Scb
            // signals for depositing/issuing
            .Full_Scb_IB(Full_Scb_IB[i]),
            .Empty_Scb_IB(Empty_Scb_IB[i]),
            .Dependent_Scb_IB(Dependent_Scb_IB[i]),
            .ScbID_Scb_IB(ScbID_Scb_IB[i]), // ScbID passed to IBuffer (for future clearing)
            .Src1_IB_Scb(Src1_IB_Scb[i]), // RegID is 5-bit (R8: thrID, R16: WarpID)
            .Src2_IB_Scb(Src2_IB_Scb[i]),
            .Dst_IB_Scb(Dst_IB_Scb[i]),
            .Src1_Valid_IB_Scb(Src1_Valid_IB_Scb[i]),
            .Src2_Valid_IB_Scb(Src2_Valid_IB_Scb[i]),
            .Dst_Valid_IB_Scb(Dst_Valid_IB_Scb[i]),
            .RP_Grt_IB_Scb(RP_Grt_IB_Scb[i]), // only create Scb entry for RP_Grt (avoid duplicate entry for Replay instructions)
            .Replayable_IB_Scb(Replayable_IB_Scb[i]), // if it is LW/SW, the Scb entry will be marked as "inComplete"
            // signal for clearing
            .Replay_Complete_ScbID_IB_Scb(Replay_Complete_ScbID_IB_Scb[i]), // mark the Scb entry as Complete
            .Replay_Complete_IB_Scb(Replay_Complete_IB_Scb[i]),
            .Replay_Complete_SW_LWbar_IB_Scb(Replay_Complete_SW_LWbar_IB_Scb[i]), // distinguish between SW/LW

            // signal from MEM for Replay instructions
            .PosFB_Valid_MEM_IB(PosFB_Valid_array[i]),
            .PosFB_MEM_IB(PosFB_MEM_IB),
            .ZeroFB_Valid_MEM_IB(ZeroFB_Valid_array[i]) // indicating the cache miss has been served
        );
    end
    endgenerate
    
endmodule
