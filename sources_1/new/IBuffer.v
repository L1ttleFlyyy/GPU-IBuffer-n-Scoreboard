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
    // output valid_IB_OC, TODO: input OC_full?
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
    output BEQ_IB_OC,
    output BLT_IB_OC,
    output [1:0] ScbID_IB_OC,

    // signal to RAU
    output exit_req_IB_IU,
    input exit_grt_IU_IB,

    // signal from/to Scb
    // signals for depositing/issuing
    input full_Scb_IB,
    input empty_Scb_IB,
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
    output [1:0] replay_complete_ScbID_IB_Scb, // mark the Scb entry as complete
    output replay_complete_IB_Scb,
    output replay_SW_LWbar_IB_Scb, // distinguish between SW/LW

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
    reg [3:0] ALUop_array[0:3];
    reg [15:0] imme_array[0:3];
    reg [3:0] regwrite_array, memwrite_array, memread_array, shared_globalbar_array;
    reg [3:0] BEQ_array, BLT_array, exit_array;
    reg [1:0] ScbID_array[0:3];

    reg RP_req, IRP_req;
    assign req_IB_IU = RP_req | IRP_req;
    wire IRP_grt = IRP_req & grt_IU_IB;
    wire RP_grt = RP_req & grt_IU_IB;

    reg [2:0] RP, WP, IRP; // 4-deep FIFO, 3-bit pointer
    wire [2:0] RP_next, WP_next, IRP_next;
    wire WP_EN, RP_EN, IRP_EN;
    wire [1:0] RP_ind = RP[1:0];
    wire [1:0] WP_ind = WP[1:0];
    wire [1:0] IRP_ind = IRP[1:0];
    wire [2:0] depth = WP-IRP;
    wire full = depth == 3'b100;

    // for the instruction currently being replayed
    wire [NUM_THREADS-1:0] PAM_next = PosFB_valid_MEM_IB? (PAM_array[IRP_ind] & (~PosFB_MEM_IB)): PAM_array[IRP_ind];
    // clear the Inst[IRP_ind] in the same clock as PosFB is received

    // pointer management
    assign WP_EN = !drop_SIMT_IB & (valid_Q1_ID_IB | valid_Q2_ID_IB);
    assign WP_next = WP_EN? (WP+1'b1):WP;
    assign RP_EN = RP_grt;
    assign RP_next = RP_EN? (RP+1'b1):RP;
    assign IRP_EN = !valid_array_cleared[IRP_ind];
    assign IRP_next = IRP_EN? RP_next:IRP;
    // note there is a simpler implementation:
    // assign IRP_EN = !valid_array[IRP_ind];
    // assign IRP_next = IRP_EN? RP:IRP;
    // although the current implementation might save clocks, 
    // it results in a very long comb path
    // we can even do FWFT from ID to OC totally bypassing IB

    reg [3:0] valid_array_cleared;
    always@(*) begin
        valid_array_cleared = valid_array;
        if (PAM_next == 0) valid_array_cleared[IRP_ind] = 1'b0;
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
            if (exit_grt_IU_IB) begin
                valid_array[RP_ind] <= 1'b0;
            end
        end
    end

    // TODO: should I supress req_IB_IF when I see an "EXIT"?
    assign req_IB_IF = (depth + valid_IF_IB + WP_EN) < 3'b100;

    //similarly, replay_array_set, replay_array_cleared
    reg [3:0] replay_array_next;
    always@(*) begin
        replay_array_next = replay_array;
        if (ZeroFB_valid_MEM_IB | (PosFB_valid_MEM_IB & PAM_next!=0)) replay_array_next[IRP_ind] = 1'b1;
        if (IRP_grt) replay_array_next[IRP_ind] = 1'b0;
        if (RP_grt) replay_array_next[RP_ind] = 1'b0;
        if (valid_Q2_ID_IB) replay_array_next[WP_ind] = memwrite_Q2_ID_IB | memread_Q2_ID_IB;
        if (valid_Q1_ID_IB) replay_array_next[WP_ind] = memwrite_Q1_ID_IB | memread_Q1_ID_IB;  
    end

    always@(posedge clk) begin
        WP <= WP_next;
        RP <= RP_next;
        IRP <= IRP_next;
        replay_array <= replay_array_next;
        if (RP_grt) begin
            ScbID_array[RP_ind] <= ScbID_Scb_IB;
        end
        if (valid_Q1_ID_IB & !drop_SIMT_IB) begin
            PAM_array[WP_ind] <= mask_SIMT_IB;
            instr_array[WP_ind] <= instr_Q1_ID_IB;
            src1_valid_array[WP_ind] <= src1_Q1_ID_IB[5];
            src1_array[WP_ind] <= src1_Q1_ID_IB[4:0];
            src2_valid_array[WP_ind] <= src2_Q1_ID_IB[5];
            src2_array[WP_ind] <= src2_Q1_ID_IB[4:0];
            dst_valid_array[WP_ind] <= dst_Q1_ID_IB[5];
            dst_array[WP_ind] <= dst_Q1_ID_IB[4:0];
            ALUop_array[WP_ind] <= ALUop_Q1_ID_IB;
            imme_array[WP_ind] <= imme_Q1_ID_IB;
            regwrite_array[WP_ind] <= regwrite_Q1_ID_IB;
            memread_array[WP_ind] <= memread_Q1_ID_IB;
            memwrite_array[WP_ind] <= memwrite_Q1_ID_IB;
            shared_globalbar_array[WP_ind] <= shared_globalbar_Q1_ID_IB;
            BEQ_array[WP_ind] <= BEQ_Q1_ID_IB_SIMT;
            BLT_array[WP_ind] <= BLT_Q1_ID_IB_SIMT;
            exit_array[WP_ind] <= exit_Q1_ID_IB;
        end
        if (valid_Q2_ID_IB & !drop_SIMT_IB) begin
            PAM_array[WP_ind] <= mask_SIMT_IB;
            instr_array[WP_ind] <= instr_Q2_ID_IB;
            src1_valid_array[WP_ind] <= src1_Q2_ID_IB[5];
            src1_array[WP_ind] <= src1_Q2_ID_IB[4:0];
            src2_valid_array[WP_ind] <= src2_Q2_ID_IB[5];
            src2_array[WP_ind] <= src2_Q2_ID_IB[4:0];
            dst_valid_array[WP_ind] <= dst_Q2_ID_IB[5];
            dst_array[WP_ind] <= dst_Q2_ID_IB[4:0];
            ALUop_array[WP_ind] <= ALUop_Q2_ID_IB;
            imme_array[WP_ind] <= imme_Q2_ID_IB;
            regwrite_array[WP_ind] <= regwrite_Q2_ID_IB;
            memread_array[WP_ind] <= memread_Q2_ID_IB;
            memwrite_array[WP_ind] <= memwrite_Q2_ID_IB;
            shared_globalbar_array[WP_ind] <= shared_globalbar_Q2_ID_IB;
            BEQ_array[WP_ind] <= BEQ_Q2_ID_IB_SIMT;
            BLT_array[WP_ind] <= BLT_Q2_ID_IB_SIMT;
            exit_array[WP_ind] <= exit_Q2_ID_IB;
        end
    end

    // request generation logic
    always@(*) begin
        RP_req = 1'b0;
        IRP_req = 1'b0;
        if (RP == IRP | !valid_array[IRP_ind]) begin // !valid_array[IRP_ind] is kind of redundant
            RP_req = valid_array[RP_ind] & !exit_array[RP_ind] & !full_Scb_IB & !dependent_Scb_IB;// TODO: DIV stall, Operand collector full
        end else begin // RP != IRP && IRPvalid
            // give priority to the replay instruction
            if (replay_array[IRP_ind] | ZeroFB_valid_MEM_IB | (PosFB_valid_MEM_IB & PAM_next != 0)) begin
                IRP_req = 1'b1;
            end else if (valid_array[RP_ind] & !replay_array[RP_ind]) begin // RP is valid && RP is not another replayable inst
                RP_req = !exit_array[RP_ind] & !full_Scb_IB & !dependent_Scb_IB;// TODO: DIV stall, Operand collector full
            end
        end
    end

    // output to OC
    assign instr_IB_OC = IRP_req? instr_array[IRP_ind]:instr_array[RP_ind];
    assign src1_IB_OC = IRP_req? {src1_valid_array[IRP_ind], src1_array[IRP_ind]}:{src1_valid_array[RP_ind], src1_array[RP_ind]};
    assign src2_IB_OC = IRP_req? {src2_valid_array[IRP_ind], src2_array[IRP_ind]}:{src2_valid_array[RP_ind], src2_array[RP_ind]};
    assign dst_IB_OC = IRP_req? {dst_valid_array[IRP_ind], dst_array[IRP_ind]}:{dst_valid_array[RP_ind], dst_array[RP_ind]};
    assign imme_IB_OC = IRP_req? imme_array[IRP_ind]:imme_array[RP_ind];
    assign ALUop_IB_OC = IRP_req? ALUop_array[IRP_ind]:ALUop_array[RP_ind];
    assign regwrite_IB_OC = IRP_req? regwrite_array[IRP_ind]:regwrite_array[RP_ind];
    assign memwrite_IB_OC = IRP_req? memwrite_array[IRP_ind]:memwrite_array[RP_ind];
    assign memread_IB_OC = IRP_req? memread_array[IRP_ind]:memread_array[RP_ind];
    assign shared_globalbar_IB_OC = IRP_req? shared_globalbar_array[IRP_ind]:shared_globalbar_array[RP_ind];
    assign BEQ_IB_OC = IRP_req? BEQ_array[IRP_ind]:BEQ_array[RP_ind];
    assign BLT_IB_OC = IRP_req? BLT_array[IRP_ind]:BLT_array[RP_ind];
    assign ScbID_IB_OC = IRP_req? ScbID_array[IRP_ind]:ScbID_array[RP_ind];

    // output to Scb
    assign src1_IB_Scb = src1_array[RP_ind];
    assign src2_IB_Scb = src2_array[RP_ind];
    assign dst_IB_Scb = dst_array[RP_ind];
    assign src1_valid_IB_Scb = src1_valid_array[RP_ind];
    assign src2_valid_IB_Scb = src2_valid_array[RP_ind];
    assign dst_valid_IB_Scb = dst_valid_array[RP_ind];
    assign RP_grt_IB_Scb = RP_grt;
    assign replayable_IB_Scb = replay_array[RP_ind];

    // signal for clearing
    assign replay_complete_ScbID_IB_Scb = ScbID_array[IRP_ind]; // mark the Scb entry as complete
    assign replay_complete_IB_Scb = PAM_next == 0;
    assign replay_SW_LWbar_IB_Scb = memwrite_array[IRP_ind]; // distinguish between SW/LW
    
    // signal to RAU/IU
    assign exit_req_IB_IU = valid_array[RP_ind] & exit_array[RP_ind] & empty_Scb_IB;

endmodule

module IBuffer_IssueUnit_wrapper#(
    parameter NUM_WARPS = 8,
    parameter NUM_THREADS = 8,
    parameter LOGNUM_WARPS = $clog2(NUM_WARPS)
    ) (
    input clk,
    input rst,

    // signals to/from IF stage (warp specific)
    input [NUM_WARPS-1:0]valid_IF_IB, 
    output [NUM_WARPS-1:0]req_IB_IF,
    
    // signals from SIMT (warp specific)
    input [NUM_WARPS-1:0]drop_SIMT_IB,
    input [NUM_WARPS*NUM_THREADS-1:0]mask_flattened_SIMT_IB,

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
    wire [NUM_THREADS-1:0] mask_SIMT_IB[0:NUM_WARPS-1];

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
        assign mask_SIMT_IB[i] = mask_flattened_SIMT_IB[NUM_THREADS*(i+1)-1:NUM_THREADS*i];
        assign src1_flattened_IB_Scb[5*i+4:5*i] = src1_IB_Scb[i];
        assign src2_flattened_IB_Scb[5*i+4:5*i] = src2_IB_Scb[i];
        assign dst_flattened_IB_Scb[5*i+4:5*i] = dst_IB_Scb[i];
        assign replay_complete_ScbID_flattened_IB_Scb[2*i+1:2*i] = replay_complete_ScbID_IB_Scb[i];
        assign ScbID_Scb_IB[i] = ScbID_flattened_Scb_IB[2*i+1:2*i];

        IBuffer_warp IBuffer (
            .clk(clk),
            .rst(rst),

            // signals to/from IF stage
            .valid_IF_IB(valid_IF_IB[i]), // data statioinary method of control
            .req_IB_IF(req_IB_IF[i]),

            // signals from ID stage (dual decoding unit)
            .valid_Q1_ID_IB(valid_Q1_ID_IB),
            .instr_Q1_ID_IB(instr_Q1_ID_IB),
            .src1_Q1_ID_IB(src1_Q1_ID_IB),
            .src2_Q1_ID_IB(src2_Q1_ID_IB),
            .dst_Q1_ID_IB(dst_Q1_ID_IB),
            .ALUop_Q1_ID_IB(ALUop_Q1_ID_IB),
            .imme_Q1_ID_IB(imme_Q1_ID_IB),
            .regwrite_Q1_ID_IB(regwrite_Q1_ID_IB),
            .memwrite_Q1_ID_IB(memwrite_Q1_ID_IB),
            .memread_Q1_ID_IB(memread_Q1_ID_IB),
            .shared_globalbar_Q1_ID_IB(shared_globalbar_Q1_ID_IB),
            .BEQ_Q1_ID_IB_SIMT(BEQ_Q1_ID_IB_SIMT),
            .BLT_Q1_ID_IB_SIMT(BLT_Q1_ID_IB_SIMT),
            .exit_Q1_ID_IB(exit_Q1_ID_IB),

            .valid_Q2_ID_IB(valid_Q2_ID_IB),
            .instr_Q2_ID_IB(instr_Q2_ID_IB),
            .src1_Q2_ID_IB(src1_Q2_ID_IB),
            .src2_Q2_ID_IB(src2_Q2_ID_IB),
            .dst_Q2_ID_IB(dst_Q2_ID_IB),
            .ALUop_Q2_ID_IB(ALUop_Q2_ID_IB),
            .imme_Q2_ID_IB(imme_Q2_ID_IB),
            .regwrite_Q2_ID_IB(regwrite_Q2_ID_IB),
            .memwrite_Q2_ID_IB(memwrite_Q2_ID_IB),
            .memread_Q2_ID_IB(memread_Q2_ID_IB),
            .shared_globalbar_Q2_ID_IB(shared_globalbar_Q2_ID_IB),
            .BEQ_Q2_ID_IB_SIMT(BEQ_Q2_ID_IB_SIMT),
            .BLT_Q2_ID_IB_SIMT(BLT_Q2_ID_IB_SIMT),
            .exit_Q2_ID_IB(exit_Q2_ID_IB),

            // signals from SIMT 
            .drop_SIMT_IB(drop_SIMT_IB[i]),
            .mask_SIMT_IB(mask_SIMT_IB[i]),

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
