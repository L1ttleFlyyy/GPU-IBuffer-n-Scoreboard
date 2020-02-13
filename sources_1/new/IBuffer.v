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


module IBuffer_warp#(
    parameter NUM_THREADS = 8
    ) (
    input clk,
    input rst,

    // signals to/from IF stage
    input valid_IF_IB, // data statioinary method of control
    output req_IB_IF,

    // signals from ID stage (dual decoding unit)
    input valid_Q1_ID_IB,
    input [31:0] instr_Q1_ID_IB,
    input [5:0] src1_Q1_ID_IB, // 5-bit RegID with MSB as valid
    input [5:0] src2_Q1_ID_IB,
    input [5:0] dst_Q1_ID_IB,
    input [3:0] ALUop_Q1_ID_IB,
    input [15:0] imme_Q1_ID_IB,
    input regwrite_Q1_ID_IB,
    input memwrite_Q1_ID_IB,
    input memread_Q1_ID_IB,
    input shared_globalbar_Q1_ID_IB,
    input BEQ_Q1_ID_IB_SIMT,
    input BLT_Q1_ID_IB_SIMT,
    input exit_Q1_ID_IB,

    input valid_Q2_ID_IB,
    input [31:0] instr_Q2_ID_IB,
    input [5:0] src1_Q2_ID_IB, // 5-bit RegID with MSB as valid
    input [5:0] src2_Q2_ID_IB,
    input [5:0] dst_Q2_ID_IB,
    input [3:0] ALUop_Q2_ID_IB,
    input [15:0] imme_Q2_ID_IB,
    input regwrite_Q2_ID_IB,
    input memwrite_Q2_ID_IB,
    input memread_Q2_ID_IB,
    input shared_globalbar_Q2_ID_IB,
    input BEQ_Q2_ID_IB_SIMT,
    input BLT_Q2_ID_IB_SIMT,
    input exit_Q2_ID_IB,

    // signals from SIMT 
    input drop_SIMT_IB,
    input [NUM_THREADS-1: 0]mask_SIMT_IB,

    // signals to/from IU
    output req_IB_IU,
    input grt_IU_IB,

    // signal to/from OC
    output valid_IB_OC,
    output [31:0] instr_IB_OC,
    output [5:0] src1_IB_OC, // 5-bit RegID with MSB as valid
    output [5:0] src2_IB_OC,
    output [5:0] dst_IB_OC,
    output [15:0] imme_IB_OC,
    output [3:0] ALUop_IB_OC,
    output regwrite_IB_OC,
    output memwrite_IB_OC,
    output memread_IB_OC,
    output shared_globalbar_IB_OC,
    output BEQ_IB_OC_SIMT,
    output BLT_IB_OC_SIMT,
    output [1:0] ScbID_IB_OC,

    // signal to RAU
    output exit_IB_RAU,

    // signal from/to Scb
    // signals for depositing/issuing
    input full_Scb_IB,
    input dependent_Scb_IB,
    input [1:0] ScbID_Scb_IB, // ScbID passed to IBuffer (for future clearing)
    output [4:0] src1_IB_Scb, // RegID is 5-bit (R8: thrID, R16: warpID)
    output [4:0] src2_IB_Scb,
    output [4:0] dst_IB_Scb,
    output src1_valid_IB_Scb,
    output src2_valid_IB_Scb,
    output dst_valid_IB_Scb,
    output RP_grt_IB_Scb, // only create Scb entry for RP_grt (avoid duplicate entry for replay instructions)
    output replayable_IB_Scb, // if it is LW/SW, the Scb entry will be marked as "incomplete"
    // signal for clearing
    output [1:0] replay_complete_ScbID, // mark the Scb entry as complete
    output replay_complete,
    output replay_SW_LWbar, // distinguish between SW/LW

    // signal from MEM for replay instructions
    input PosFB_valid_MEM_IB,
    input [NUM_THREADS-1:0] PosFB_MEM_IB,
    input ZeroFB_valid_MEM_IB // indicating the cache miss has been served
    );

    reg [31:0] instr_array[0:3]; // binary code
    reg [3:0] valid_array, replay_array;
    reg [NUM_THREADS-1:0] PAM_array[0:3]; // private active mask for each instruction
    reg [4:0] src1_array[0:3], src2_array[0:3], dst_array[0:3];
    reg [3:0] src1_valid_array, src2_valid_array, dst_valid_array;
    reg [4:0] ALUop_array[0:3],
    reg [15:0] imme_array[0:3],
    reg [3:0] regwrite_array, memwrite_array, memread_array, shared_globalbar_array;
    reg [3:0] BEQ_array, BLT_array, exit_array;

    reg RP_req, IRP_req;
    assign req_IB_IU = RP_req | IRP_req;
    wire IRP_grt = IRP_req & grt_IU_IB;
    wire RP_grt = !IRP_req & RP_req & grt_IU_IB; // replay request is given higher priority
    assign RP_grt_IB_Scb = RP_grt;

    reg [2:0] RP, WP, IRP; // 4-deep FIFO, 3-bit pointer
    wire [2:0] RP_next, WP_next, IRP_next;
    wire WP_EN, RP_EN, IRP_EN;
    wire [1:0] RP_ind = RP[1:0];
    wire [1:0] WP_ind = WP[1:0];
    wire [1:0] IRP_ind = IRP[1:0];
    wire [2:0] depth = WP-IRP;
    wire full = depth == 3'b100;
    // a more aggresive implementation can be:
    // depth = WP - IRP_next

    // for the instruction currently being replayed
    wire [NUM_THREADS-1:0] PAM_next = PosFB_valid_MEM_IB? (PAM_array[IRP_ind] & (~PosFB_MEM_IB)): PAM_array[IRP_ind];
    wire IRP_complete = PAM_next == 0;
    // clear the Inst[IRP] in the same clock as PosFB is received

    // pointer management
    assign WP_EN = !drop_SIMT_IB & (valid_Q1_ID_IB | valid_Q2_ID_IB);
    assign WP_next = WP_EN? (WP+1'b1):WP;
    assign RP_EN = RP_grt;
    assign RP_next = RP_EN? (RP+1'b1):RP;
    assign IRP_EN = !valid_array[IRP_ind];
    assign IRP_next = IRP_EN? RP:IRP;
    // note there is a more aggresive implementation:
    // IRP_EN = !valid_array_cleared[IRP_ind];
    // IRP_next = IRP_EN? RP_next:IRP;
    // although this implementation might save clocks, 
    // it results in a very long comb path

    reg [3:0] valid_array_cleared;
    always@(*) begin
        valid_array_cleared = valid_array;
        if (IRP_complete) valid_array_cleared[IRP_ind] = 1'b0;
        if (RP_grt & !replay_array[RP_ind]) valid_array_cleared[RP_ind] = 1'b0; // non-replayable instruction
    end

    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            valid_array <= 0;
        end else begin
            valid_array <= valid_array_cleared;
            if (WP_EN) begin
                valid_array[WP_ind] <= 1'b1;
            end
        end
    end

    assign req_IB_IF = (depth + valid_IF_IB + WP_EN) < 3'b4;

    //similarly, relay_array_set, replay_array_cleared
    reg [3:0] replay_array_next;
    always@(*) begin
        replay_array_next = replay_array;
        if (ZeroFB_valid_MEM_IB | (PosFB_valid_MEM_IB & PAM_next!=0)) replay_array_next[IRP_ind] = 1'b1;
        if (IRP_grt) replay_array_next[IRP_ind] = 1'b0;
        if (RP_grt) replay_array_next[RP_ind] <= 1'b0;
        if (valid_Q2_ID_IB) replay_array_next[WP_ind] <= memwrite_Q2_ID_IB | memread_Q2_ID_IB;
        if (valid_Q1_ID_IB) replay_array_next[WP_ind] <= memwrite_Q1_ID_IB | memread_Q1_ID_IB;  
    end

    always@(posedge clk) begin
        replay_array <= replay_array_next;
        if (valid_Q1_ID_IB) begin
            instr_array[WP_ind] <= instr_Q1_ID_IB;
            src1_valid_array[WP_ind] <= src1_Q1_ID_IB[5];
            src1_array[WP_ind] <= src1_Q1_ID_IB[4:0];
            src2_valid_array[WP_ind] <= src2_Q1_ID_IB[5];
            src2_array[WP_ind] <= src2_Q1_ID_IB[4:0];
            dst_valid_array[WP_ind] <= dst_Q1_ID_IB[5];
            dst_array[WP_ind] <= dst_Q1_ID_IB[4:0];
            regwrite_array[WP_ind] <= regwrite_Q1_ID_IB;
            memread_array[WP_ind] <= memread_Q1_ID_IB;
            memwrite_array[WP_ind] <= memwrite_Q1_ID_IB;
            shared_globalbar_array[WP_ind] <= shared_globalbar_Q1_ID_IB;
            BEQ_array[WP_ind] <= BEQ_Q1_ID_IB_SIMT;
            BLT_array[WP_ind] <= BLT_Q1_ID_IB_SIMT;
            exit_array[WP_ind] <= exit_Q1_ID_IB;
        end
        if (valid_Q2_ID_IB) begin
            instr_array[WP_ind] <= instr_Q2_ID_IB;
            src1_valid_array[WP_ind] <= src1_Q2_ID_IB[5];
            src1_array[WP_ind] <= src1_Q2_ID_IB[4:0];
            src2_valid_array[WP_ind] <= src2_Q2_ID_IB[5];
            src2_array[WP_ind] <= src2_Q2_ID_IB[4:0];
            dst_valid_array[WP_ind] <= dst_Q2_ID_IB[5];
            dst_array[WP_ind] <= dst_Q2_ID_IB[4:0];
            regwrite_array[WP_ind] <= regwrite_Q2_ID_IB;
            memread_array[WP_ind] <= memread_Q2_ID_IB;
            memwrite_array[WP_ind] <= memwrite_Q2_ID_IB;
            shared_globalbar_array[WP_ind] <= shared_globalbar_Q2_ID_IB;
            BEQ_array[WP_ind] <= BEQ_Q2_ID_IB_SIMT;
            BLT_array[WP_ind] <= BLT_Q2_ID_IB_SIMT;
            exit_array[WP_ind] <= exit_Q2_ID_IB;
        end
    end

    always@(*) begin
        RP_req = 1'b0;
        IRP_req = 1'b0;
        if (RP == IRP | !valid_array[IRP_ind]) begin
            RP_req = valid_array[RP_ind] & !full_Scb_IB & !dependent_Scb_IB;// TODO: DIV stall, Operand collector full
        end else begin // RP != IRP & IRPvalid
            if (replay_array[IRP_ind] | ZeroFB_valid_MEM_IB | (PosFB_valid_MEM_IB & PAM_next != 0)) begin // ready to replay
                IRP_req = 1'b1;
            end else if (valid_array[RP_ind] & !replay_array[RP_ind]) begin // RP valid && RP is not another replayable inst
                RP_req = !full_Scb_IB & !dependent_Scb_IB;// TODO: DIV stall, Operand collector full
            end
        end
    end

    assign replayable_IB_Scb = replay_array[RP_ind];

endmodule

module IBuffer_wrapper#(
    parameter NUM_WARPS = 8,
    parameter NUM_THREADS = 8,
    parameter LOGNUM_WARPS = $clog2(NUM_WARPS)
    ) (
    input clk,
    input rst,

    // signals to/from IF stage (warp specific)
    input [NUM_WARPS-1: 0]valid_IF_IB, 
    output [NUM_WARPS-1: 0]req_IB_IF,
    
    // signals from SIMT (warp specific)
    input [NUM_WARPS-1: 0]drop_SIMT_IB,
    input [NUM_WARPS*NUM_THREADS-1: 0]mask_flattened_SIMT_IB,

    // signals to/from scoreboard (warp specific)
    output [5*NUM_WARPS-1: 0] src1_Flattened_IB_Scb, // Flattened RegID: 5 bit regID * 8 waprs
    output [5*NUM_WARPS-1: 0] src2_Flattened_IB_Scb,
    output [5*NUM_WARPS-1: 0] dst_Flattened_IB_Scb,
    input [2*NUM_WARPS-1: 0] ScbID_Flattened_Scb_IB, // ScbID to be passed to Operand Collector
    input [NUM_WARPS-1: 0] src1_valid,
    input [NUM_WARPS-1: 0] src2_valid,
    input [NUM_WARPS-1: 0] dst_valid,
    output [NUM_WARPS-1: 0] full_Scb_IB,
    output [NUM_WARPS-1: 0] dependent_Scb_IB,

    // signals from ID stage (dual decoding unit)
    input valid_Q1_ID_IB,
    input [31:0]instr_Q1_ID_IB,
    input [5:0]src1_Q1_ID_IB, // 5-bit RegID with MSB as valid
    input [5:0]src2_Q1_ID_IB,
    input [5:0]dst_Q1_ID_IB,
    input [3:0]ALUop_Q1_ID_IB,
    input [15:0]imme_Q1_ID_IB,
    input regwrite_Q1_ID_IB,
    input memwrite_Q1_ID_IB,
    input memread_Q1_ID_IB,
    input shared_globalbar_Q1_ID_IB,
    input BEQ_Q1_ID_IB_SIMT,
    input BLT_Q1_ID_IB_SIMT,
    input exit_Q1_ID_IB,

    input valid_Q2_ID_IB,
    input [31:0]instr_Q2_ID_IB,
    input [5:0]src1_Q2_ID_IB, // 5-bit RegID with MSB as valid
    input [5:0]src2_Q2_ID_IB,
    input [5:0]dst_Q2_ID_IB,
    input [3:0]ALUop_Q2_ID_IB,
    input [15:0]imme_Q2_ID_IB,
    input regwrite_Q2_ID_IB,
    input memwrite_Q2_ID_IB,
    input memread_Q2_ID_IB,
    input shared_globalbar_Q2_ID_IB,
    input BEQ_Q2_ID_IB_SIMT,
    input BLT_Q2_ID_IB_SIMT,
    input exit_Q2_ID_IB,

    // signal to/from Operand Collector
    output valid_IB_OC,
    output [31:0]instr_IB_OC,
    output [LOGNUM_WARPS-1: 0]warpID_IB_OC,
    output [1:0]ScbID_IB_OC,
    output [5:0]src1_IB_OC, // 5-bit RegID with MSB as valid
    output [5:0]src2_IB_OC,
    output [5:0]dst_IB_OC,
    output [15:0]imme_IB_OC,
    output [3:0]ALUop_IB_OC,
    output regwrite_IB_OC,
    output memwrite_IB_OC,
    output memread_IB_OC,
    output shared_globalbar_IB_OC,
    output BEQ_IB_OC_SIMT,
    output BLT_IB_OC_SIMT,

    // signal to RAU
    output exit_IB_RAU,
    output [LOGNUM_WARPS-1: 0]warpID_IB_RAU
    );
    wire [NUM_WARPS-1: 0]req_IB_IU;
    wire [NUM_WARPS-1: 0]grt_IU_IB;
    
    // signal for scoreboard clearing

endmodule
