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
    input [NUM_WARPS-1:0]Valid_IF_IB, 
    output [NUM_WARPS-1:0]Req_IB_IF,
    
    // signals from SIMT (warp specific)
    input [NUM_WARPS-1:0]DropInstr_SIMT_IB,
    input [NUM_WARPS*NUM_THREADS-1:0]AM_flattened_SIMT_IB, //TODO: flattened I/O or not?

    // signals from ID stage (dual decoding unit)
    input Valid_ID0_IB,
    input [31:0] Inst_ID0_IB,
    input [4:0] Src1_ID0_IB,
    input [4:0] Src2_ID0_IB,
    input [4:0] Dst_ID0_IB,
	input Src1_Valid_ID0_IB,
	input Src2_Valid_ID0_IB,
	input Dst_Valid_ID0_IB,
    input [3:0] ALUop_ID0_IB,
    input [15:0] Imme_ID0_IB,
    input RegWrite_ID0_IB,
    input MemWrite_ID0_IB,
    input MemRead_ID0_IB,
    input Shared_Globalbar_ID0_IB,
    input BEQ_ID0_IB_SIMT,
    input BLT_ID0_IB_SIMT,
    input Exit_ID0_IB,

    input Valid_ID1_IB,
    input [31:0] Inst_ID1_IB,
    input [4:0] Src1_ID1_IB,
    input [4:0] Src2_ID1_IB,
    input [4:0] Dst_ID1_IB,
	input Src1_Valid_ID1_IB,
	input Src2_Valid_ID1_IB,
	input Dst_Valid_ID1_IB,
    input [3:0] ALUop_ID1_IB,
    input [15:0] Imme_ID1_IB,
    input RegWrite_ID1_IB,
    input MemWrite_ID1_IB,
    input MemRead_ID1_IB,
    input Shared_Globalbar_ID1_IB,
    input BEQ_ID1_IB_SIMT,
    input BLT_ID1_IB_SIMT,
    input Exit_ID1_IB,

    // signals to/from scoreboard (warp specific)
    output [NUM_WARPS-1:0] RP_grt_IB_Scb,
    output [5*NUM_WARPS-1:0] src1_flattened_IB_Scb,
    output [5*NUM_WARPS-1:0] src2_flattened_IB_Scb,
    output [5*NUM_WARPS-1:0] dst_flattened_IB_Scb,
    output [NUM_WARPS-1:0] src1_valid_IB_Scb,
    output [NUM_WARPS-1:0] src2_valid_IB_Scb,
    output [NUM_WARPS-1:0] dst_valid_IB_Scb,
    output [NUM_WARPS-1:0] replayable_IB_Scb,
    // when clearing
    output [2*NUM_WARPS-1:0] replay_complete_ScbID_flattened_IB_Scb,
    output [NUM_WARPS-1:0] replay_complete_IB_Scb,
    output [NUM_WARPS-1:0] replay_SW_LWbar_IB_Scb,
    // when issuing
    input [NUM_WARPS-1:0] full_Scb_IB,
    input [NUM_WARPS-1:0] empty_Scb_IB,
    input [NUM_WARPS-1:0] dependent_Scb_IB,
    input [2*NUM_WARPS-1:0] ScbID_flattened_Scb_IB,

    // signal to/from IU
    output [NUM_WARPS-1:0] req_IB_IU,
    input [NUM_WARPS-1:0] grt_IU_IB,
    output [NUM_WARPS-1:0] exit_req_IB_IU,
    input [NUM_WARPS-1:0] exit_grt_IU_IB,

    // signal to/from Operand Collector // TODO: OC_full
    output valid_IB_OC,
    output reg [LOGNUM_WARPS-1:0] warpID_IB_OC,
    output reg [31:0] instr_IB_OC,
    output reg [5:0] src1_IB_OC, // 5-bit RegID with MSB as valid
    output reg [5:0] src2_IB_OC,
    output reg [5:0] dst_IB_OC,
    output reg [15:0] imme_IB_OC,
    output reg [3:0] ALUop_IB_OC,
    output reg regwrite_IB_OC,
    output reg memwrite_IB_OC,
    output reg memread_IB_OC,
    output reg shared_globalbar_IB_OC,
    output reg BEQ_IB_OC,
    output reg BLT_IB_OC,
    output reg [1:0] ScbID_IB_OC,

    // signals to RAU
    output exit_IB_RAU,
    output reg [LOGNUM_WARPS-1:0] exit_warpID_IB_RAU,

    // feedback from MEM
    input [NUM_THREADS-1:0] PosFB_MEM_IB,
    input PosFB_valid_MEM_IB,
    input ZeroFB_valid_MEM_IB,
    input [LOGNUM_WARPS-1:0] PosFB_warpID_MEM_IB,
    input [LOGNUM_WARPS-1:0] ZeroFB_warpID_MEM_IB
    );
    wire [NUM_THREADS-1:0] AM_SIMT_IB[0:NUM_WARPS-1];

    // signals to/from scoreboard (warp specific)
    wire [4:0] src1_IB_Scb[0:NUM_WARPS-1];
    wire [4:0] src2_IB_Scb[0:NUM_WARPS-1];
    wire [4:0] dst_IB_Scb[0:NUM_WARPS-1];  
    wire [1:0] ScbID_Scb_IB[0:NUM_WARPS-1];
    wire [1:0] replay_complete_ScbID_IB_Scb[0:NUM_WARPS-1];


    integer j;
    // input demux
    reg [NUM_WARPS-1:0] PosFB_valid_array;
    reg [NUM_WARPS-1:0] ZeroFB_valid_array;
    always@(*) begin
        PosFB_valid_array = 0;
        ZeroFB_valid_array = 0;
        PosFB_valid_array[PosFB_warpID_MEM_IB] = PosFB_valid_MEM_IB;
        ZeroFB_valid_array[ZeroFB_warpID_MEM_IB] = ZeroFB_valid_MEM_IB;
    end


    // output mux
    assign valid_IB_OC = grt_IU_IB != 0;
    assign exit_IB_RAU = exit_grt_IU_IB != 0;
    always@(*) begin
        warpID_IB_OC = 0;
        exit_warpID_IB_RAU = 0;
        for (j=1; j<NUM_WARPS; j=j+1) begin: exit_mux
            if (exit_grt_IU_IB[j])
                exit_warpID_IB_RAU = j;
            if (grt_IU_IB[j]) 
                warpID_IB_OC = j;
        end
    end

    // output to OC
    wire [31:0] instr_array[0:NUM_WARPS-1];
    wire [5:0] src1_array[0:NUM_WARPS-1];
    wire [5:0] src2_array[0:NUM_WARPS-1];
    wire [5:0] dst_array[0:NUM_WARPS-1];
    wire [15:0] imme_array[0:NUM_WARPS-1];
    wire [3:0] ALUop_array[0:NUM_WARPS-1];
    wire [NUM_WARPS-1:0] regwrite_array;
    wire [NUM_WARPS-1:0] memwrite_array;
    wire [NUM_WARPS-1:0] memread_array;
    wire [NUM_WARPS-1:0] shared_globalbar_array;
    wire [NUM_WARPS-1:0] BEQ_array;
    wire [NUM_WARPS-1:0] BLT_array;
    wire [1:0] ScbID_array[0:NUM_WARPS-1];


    always@(*) begin
        instr_IB_OC = instr_array[0];
        src1_IB_OC = src1_array[0];
        src2_IB_OC = src2_array[0];
        dst_IB_OC = dst_array[0];
        imme_IB_OC = imme_array[0];
        ALUop_IB_OC = ALUop_array[0];
        regwrite_IB_OC = regwrite_array[0];
        memwrite_IB_OC = memwrite_array[0];
        memread_IB_OC = memread_array[0];
        shared_globalbar_IB_OC = shared_globalbar_array[0];
        BEQ_IB_OC = BEQ_array[0];
        BLT_IB_OC = BLT_array[0];
        ScbID_IB_OC = ScbID_array[0];
        for (j=1; j<NUM_WARPS; j=j+1) begin: IB_OC_mux
            if (grt_IU_IB[j]) begin       
                instr_IB_OC = instr_array[j];
                src1_IB_OC = src1_array[j];
                src2_IB_OC = src2_array[j];
                dst_IB_OC = dst_array[j];
                imme_IB_OC = imme_array[j];
                ALUop_IB_OC = ALUop_array[j];
                regwrite_IB_OC = regwrite_array[j];
                memwrite_IB_OC = memwrite_array[j];
                memread_IB_OC = memread_array[j];
                shared_globalbar_IB_OC = shared_globalbar_array[j];
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
        assign AM_SIMT_IB[i] = AM_flattened_SIMT_IB[NUM_THREADS*(i+1)-1:NUM_THREADS*i];
        assign src1_flattened_IB_Scb[5*i+4:5*i] = src1_IB_Scb[i];
        assign src2_flattened_IB_Scb[5*i+4:5*i] = src2_IB_Scb[i];
        assign dst_flattened_IB_Scb[5*i+4:5*i] = dst_IB_Scb[i];
        assign replay_complete_ScbID_flattened_IB_Scb[2*i+1:2*i] = replay_complete_ScbID_IB_Scb[i];
        assign ScbID_Scb_IB[i] = ScbID_flattened_Scb_IB[2*i+1:2*i];

        IBuffer_warp IBuffer (
            .clk(clk),
            .rst(rst),

            // signals to/from IF stage
            .Valid_IF_IB(Valid_IF_IB[i]), // data statioinary method of control
            .Req_IB_IF(Req_IB_IF[i]),

            // signals from ID stage (dual decoding unit)
            .Valid_ID0_IB(Valid_ID0_IB),
            .Inst_ID0_IB(Inst_ID0_IB),
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

            .Valid_ID1_IB(Valid_ID1_IB),
            .Inst_ID1_IB(Inst_ID1_IB),
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

            // signals from SIMT 
            .DropInstr_SIMT_IB(DropInstr_SIMT_IB[i]),
            .AM_SIMT_IB(AM_SIMT_IB[i]),

            // signals to/from IU
            .req_IB_IU(req_IB_IU[i]),
            .grt_IU_IB(grt_IU_IB[i]),

            // signal to/from OC
            // .valid_IB_OC, TODO: .OC_full?
            .instr_IB_OC(instr_array[i]),
            .src1_IB_OC(src1_array[i]), // 5-bit RegID with MSB as valid
            .src2_IB_OC(src2_array[i]),
            .dst_IB_OC(dst_array[i]),
            .imme_IB_OC(imme_array[i]),
            .ALUop_IB_OC(ALUop_array[i]),
            .regwrite_IB_OC(regwrite_array[i]),
            .memwrite_IB_OC(memwrite_array[i]),
            .memread_IB_OC(memread_array[i]),
            .shared_globalbar_IB_OC(shared_globalbar_array[i]),
            .BEQ_IB_OC(BEQ_array[i]),
            .BLT_IB_OC(BLT_array[i]),
            .ScbID_IB_OC(ScbID_array[i]),

            // signal to RAU
            .exit_req_IB_IU(exit_req_IB_IU[i]),
            .exit_grt_IU_IB(exit_grt_IU_IB[i]),

            // signal from/to Scb
            // signals for depositing/issuing
            .full_Scb_IB(full_Scb_IB[i]),
            .empty_Scb_IB(empty_Scb_IB[i]),
            .dependent_Scb_IB(dependent_Scb_IB[i]),
            .ScbID_Scb_IB(ScbID_Scb_IB[i]), // ScbID passed to IBuffer (for future clearing)
            .src1_IB_Scb(src1_IB_Scb[i]), // RegID is 5-bit (R8: thrID, R16: warpID)
            .src2_IB_Scb(src2_IB_Scb[i]),
            .dst_IB_Scb(dst_IB_Scb[i]),
            .src1_valid_IB_Scb(src1_valid_IB_Scb[i]),
            .src2_valid_IB_Scb(src2_valid_IB_Scb[i]),
            .dst_valid_IB_Scb(dst_valid_IB_Scb[i]),
            .RP_grt_IB_Scb(RP_grt_IB_Scb[i]), // only create Scb entry for RP_grt (avoid duplicate entry for replay instructions)
            .replayable_IB_Scb(replayable_IB_Scb[i]), // if it is LW/SW, the Scb entry will be marked as "incomplete"
            // signal for clearing
            .replay_complete_ScbID_IB_Scb(replay_complete_ScbID_IB_Scb[i]), // mark the Scb entry as complete
            .replay_complete_IB_Scb(replay_complete_IB_Scb[i]),
            .replay_SW_LWbar_IB_Scb(replay_SW_LWbar_IB_Scb[i]), // distinguish between SW/LW

            // signal from MEM for replay instructions
            .PosFB_valid_MEM_IB(PosFB_valid_array[i]),
            .PosFB_MEM_IB(PosFB_MEM_IB),
            .ZeroFB_valid_MEM_IB(ZeroFB_valid_array[i]) // indicating the cache miss has been served
        );
    end
    endgenerate
    
endmodule
