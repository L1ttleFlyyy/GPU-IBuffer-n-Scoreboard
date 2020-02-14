`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2020 08:53:50 AM
// Design Name: 
// Module Name: IBuffer_warp
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
    input Valid_IF_IB, // data statioinary method of control
    output Req_IB_IF,

    // signals from ID stage (dual decoding unit)
    input Valid_ID0_IB,
    input [31:0] Inst_ID0_IB,
    input [4:0] Src1_ID0_IB, // 5-bit RegID with MSB as valid
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
    input [4:0] Src1_ID1_IB, // 5-bit RegID with MSB as valid
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

    // signals from SIMT 
    input DropInstr_SIMT_IB,
    input [NUM_THREADS-1: 0]AM_SIMT_IB,

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
    reg [NUM_THREADS-1:0] PAM_array[0:3]; // private active AM for each instruction
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
    assign WP_EN = !DropInstr_SIMT_IB & (Valid_ID0_IB | Valid_ID1_IB);
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
    assign Req_IB_IF = (depth + Valid_IF_IB + WP_EN) < 3'b100;

    //similarly, replay_array_set, replay_array_cleared
    reg [3:0] replay_array_next;
    always@(*) begin
        replay_array_next = replay_array;
        if (ZeroFB_valid_MEM_IB | (PosFB_valid_MEM_IB & PAM_next!=0)) replay_array_next[IRP_ind] = 1'b1;
        if (IRP_grt) replay_array_next[IRP_ind] = 1'b0;
        if (RP_grt) replay_array_next[RP_ind] = 1'b0;
        if (Valid_ID1_IB) replay_array_next[WP_ind] = MemWrite_ID1_IB | MemRead_ID1_IB;
        if (Valid_ID0_IB) replay_array_next[WP_ind] = MemWrite_ID0_IB | MemRead_ID0_IB;  
    end

    always@(posedge clk) begin
        WP <= WP_next;
        RP <= RP_next;
        IRP <= IRP_next;
        replay_array <= replay_array_next;
        if (RP_grt) begin
            ScbID_array[RP_ind] <= ScbID_Scb_IB;
        end
        if (Valid_ID0_IB & !DropInstr_SIMT_IB) begin
            PAM_array[WP_ind] <= AM_SIMT_IB;
            instr_array[WP_ind] <= Inst_ID0_IB;
            src1_valid_array[WP_ind] <= Src1_Valid_ID0_IB;
            src1_array[WP_ind] <= Src1_ID0_IB[4:0];
            src2_valid_array[WP_ind] <= Src2_Valid_ID0_IB;
            src2_array[WP_ind] <= Src2_ID0_IB[4:0];
            dst_valid_array[WP_ind] <= Dst_Valid_ID0_IB;
            dst_array[WP_ind] <= Dst_ID0_IB[4:0];
            ALUop_array[WP_ind] <= ALUop_ID0_IB;
            imme_array[WP_ind] <= Imme_ID0_IB;
            regwrite_array[WP_ind] <= RegWrite_ID0_IB;
            memread_array[WP_ind] <= MemRead_ID0_IB;
            memwrite_array[WP_ind] <= MemWrite_ID0_IB;
            shared_globalbar_array[WP_ind] <= Shared_Globalbar_ID0_IB;
            BEQ_array[WP_ind] <= BEQ_ID0_IB_SIMT;
            BLT_array[WP_ind] <= BLT_ID0_IB_SIMT;
            exit_array[WP_ind] <= Exit_ID0_IB;
        end
        if (Valid_ID1_IB & !DropInstr_SIMT_IB) begin
            PAM_array[WP_ind] <= AM_SIMT_IB;
            instr_array[WP_ind] <= Inst_ID1_IB;
            src1_valid_array[WP_ind] <= Src1_Valid_ID1_IB;
            src1_array[WP_ind] <= Src1_ID1_IB[4:0];
            src2_valid_array[WP_ind] <= Src2_Valid_ID1_IB;
            src2_array[WP_ind] <= Src2_ID1_IB[4:0];
            dst_valid_array[WP_ind] <= Dst_Valid_ID1_IB;
            dst_array[WP_ind] <= Dst_ID1_IB[4:0];
            ALUop_array[WP_ind] <= ALUop_ID1_IB;
            imme_array[WP_ind] <= Imme_ID1_IB;
            regwrite_array[WP_ind] <= RegWrite_ID1_IB;
            memread_array[WP_ind] <= MemRead_ID1_IB;
            memwrite_array[WP_ind] <= MemWrite_ID1_IB;
            shared_globalbar_array[WP_ind] <= Shared_Globalbar_ID1_IB;
            BEQ_array[WP_ind] <= BEQ_ID1_IB_SIMT;
            BLT_array[WP_ind] <= BLT_ID1_IB_SIMT;
            exit_array[WP_ind] <= Exit_ID1_IB;
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
