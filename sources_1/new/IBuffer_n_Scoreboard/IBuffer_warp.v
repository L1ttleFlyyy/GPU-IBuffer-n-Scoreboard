`timescale 1ns / 100ps
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
    input Valid_IF_ID0_IB,
    input Valid_IF_ID1_IB,
    output Req_IB_IF,

    // signals from ID stage (dual decoding unit)
    input Valid_ID0_IB_SIMT,
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

    input Valid_ID1_IB_SIMT,
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

    // signals from SIMT 
    input DropInstr_SIMT_IB,
    input [NUM_THREADS-1: 0]ActiveMask_SIMT_IB,

    // signals to/from IU
    output Req_IB_IU,
    input Grt_IU_IB,
    output Exit_Req_IB_IU,
    input Exit_Grt_IU_IB,

    // signal to/from OC
    input Full_OC_IB,
    output [NUM_THREADS-1:0] ActiveMask_IB_OC,
    output [31:0] Instr_IB_OC,
    output [4:0] Src1_IB_OC,
    output [4:0] Src2_IB_OC,
    output [4:0] Dst_IB_OC,
    output Src1_Valid_IB_OC,
    output Src2_Valid_IB_OC,
    output [15:0] Imme_IB_OC,
    output Imme_Valid_IB_OC,
    output [3:0] ALUop_IB_OC,
    output RegWrite_IB_OC,
    output MemWrite_IB_OC,
    output MemRead_IB_OC,
    output Shared_Globalbar_IB_OC,
    output BEQ_IB_OC,
    output BLT_IB_OC,
    output [1:0] ScbID_IB_OC,

    // signal from RAU
    input AllocStall_RAU_IB,

    // signal from/to Scb
    // signals for depositing/issuing
    input Full_Scb_IB,
    input Empty_Scb_IB,
    input Dependent_Scb_IB,
    input [1:0] ScbID_Scb_IB, // ScbID passed to IBuffer (for future clearing)
    output [4:0] Src1_IB_Scb, // RegID is 5-bit (R8: thrID, R16: WarpID)
    output [4:0] Src2_IB_Scb,
    output [4:0] Dst_IB_Scb,
    output Src1_Valid_IB_Scb,
    output Src2_Valid_IB_Scb,
    output Dst_Valid_IB_Scb,
    output RP_Grt_IB_Scb, // only create Scb entry for RP_Grt (avoid duplicate entry for Replay Instructions)
    // signal for clearing
    output [1:0] Replay_Complete_ScbID_IB_Scb, // mark the Scb entry as Complete
    output Replay_Complete_IB_Scb,

    // signal from MEM for Replay Instructions
    input PosFB_Valid_MEM_IB,
    input [NUM_THREADS-1:0] PosFB_MEM_IB,
    input ZeroFB_Valid_MEM_IB // indicating the cache miss has been served
    );

    reg [31:0] Instr_array[0:3]; // binary code
    reg [3:0] Valid_array, Replay_array;
    reg [NUM_THREADS-1:0] PAM_array[0:3]; // private active AM for each Instruction
    reg [4:0] Src1_array[0:3], Src2_array[0:3], Dst_array[0:3];
    reg [3:0] Src1_Valid_array, Src2_Valid_array;
    reg [3:0] ALUop_array[0:3];
    reg [15:0] Imme_array[0:3];
    reg [3:0] Imme_Valid_array;
    reg [3:0] RegWrite_array, MemWrite_array, MemRead_array, Shared_Globalbar_array;
    reg [3:0] BEQ_array, BLT_array, Exit_array;
    reg [1:0] ScbID_array[0:3];

    reg RP_Req, IRP_Req;
    assign Req_IB_IU = RP_Req | IRP_Req;
    wire IRP_Grt = IRP_Req & Grt_IU_IB;
    wire RP_Grt = RP_Req & Grt_IU_IB;

    reg [2:0] RP, WP, IRP; // 4-deep FIFO, 3-bit pointer
    wire [2:0] RP_next, WP_next, IRP_next;
    wire WP_EN, RP_EN, IRP_EN;
    wire [1:0] RP_ind = RP[1:0];
    wire [1:0] WP_ind = WP[1:0];
    wire [1:0] IRP_ind = IRP[1:0];
    wire [2:0] depth = WP-IRP;
    wire Full = depth == 3'b100;

    // for the Instruction currently being Replayed
    wire [NUM_THREADS-1:0] PAM_IRP_next;
    // clear the Inst[IRP_ind] in the same clock as PosFB is received

    reg [3:0] Valid_array_next;
    // pointer management
    assign WP_EN = !DropInstr_SIMT_IB & (Valid_ID0_IB_SIMT | Valid_ID1_IB_SIMT);
    assign WP_next = WP_EN? (WP+1'b1):WP;
    assign RP_EN = RP_Grt | Exit_Grt_IU_IB;
    assign RP_next = RP_EN? (RP+1'b1):RP;
    assign IRP_EN = !Valid_array_next[IRP_ind];
    assign IRP_next = IRP_EN? RP_next:IRP;
    // note there is a simpler implementation:
    // assign IRP_EN = !Valid_array[IRP_ind];
    // assign IRP_next = IRP_EN? RP:IRP;
    // although the current implementation might save clocks, 
    // it results in a very long comb path
    // we can even do FWFT from ID to OC totally bypassing IB

    always@(*) begin
        Valid_array_next = Valid_array;
        if (WP_EN) Valid_array_next[WP_ind] = 1'b1;
        if (PosFB_Valid_MEM_IB && (PAM_IRP_next == 0)) Valid_array_next[IRP_ind] = 1'b0;
        if (RP_Grt & !Replay_array[RP_ind]) Valid_array_next[RP_ind] = 1'b0; // non-Replayable Instruction
        if (Exit_Grt_IU_IB) Valid_array_next[RP_ind] = 1'b0;
    end

    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            WP <= 0;
            RP <= 0;
            IRP <= 0;
            Valid_array <= 0;
        end else begin
            WP <= WP_next;
            RP <= RP_next;
            IRP <= IRP_next;
            Valid_array <= Valid_array_next;
        end
    end

    // Q: should I supress Req_IB_IF when I see an "EXIT"?
    // A: No. It has already been taken care of in IF stage (Flush if !PC_Valid)
    // Note: here we has to be conservative, even though the Valid_IF might be a Call/Jump,
    // we still need to reserve an IBuffer slot for it
    assign Req_IB_IF = (depth + Valid_IF_ID0_IB + Valid_IF_ID1_IB + WP_EN) < 3'b100;

    //similarly, Replay_array_set, Replay_array_cleared
    reg [3:0] Replay_array_next;
    always@(*) begin
        Replay_array_next = Replay_array;
        if (ZeroFB_Valid_MEM_IB || (PosFB_Valid_MEM_IB && (PAM_IRP_next != 0))) Replay_array_next[IRP_ind] = 1'b1;
        if (IRP_Grt) Replay_array_next[IRP_ind] = 1'b0;
        if (RP_Grt) Replay_array_next[RP_ind] = 1'b0;
        if (Valid_ID1_IB_SIMT) Replay_array_next[WP_ind] = MemWrite_ID1_IB | MemRead_ID1_IB;
        if (Valid_ID0_IB_SIMT) Replay_array_next[WP_ind] = MemWrite_ID0_IB | MemRead_ID0_IB;  
    end

    assign PAM_IRP_next = PosFB_Valid_MEM_IB? (PAM_array[IRP_ind] & (~PosFB_MEM_IB)): PAM_array[IRP_ind];

    always@(posedge clk) begin
        Replay_array <= Replay_array_next;
        PAM_array[IRP_ind] <= PAM_IRP_next;
        if (RP_Grt) begin
            ScbID_array[RP_ind] <= ScbID_Scb_IB;
        end
        if (Valid_ID0_IB_SIMT & !DropInstr_SIMT_IB) begin
            PAM_array[WP_ind] <= ActiveMask_SIMT_IB;
            Instr_array[WP_ind] <= Instr_ID0_IB;
            Src1_Valid_array[WP_ind] <= Src1_Valid_ID0_IB;
            Src1_array[WP_ind] <= Src1_ID0_IB;
            Src2_Valid_array[WP_ind] <= Src2_Valid_ID0_IB;
            Src2_array[WP_ind] <= Src2_ID0_IB;
            Dst_array[WP_ind] <= Dst_ID0_IB;
            ALUop_array[WP_ind] <= ALUop_ID0_IB;
            Imme_array[WP_ind] <= Imme_ID0_IB;
            Imme_Valid_array[WP_ind] <= Imme_Valid_ID0_IB;
            RegWrite_array[WP_ind] <= RegWrite_ID0_IB;
            MemRead_array[WP_ind] <= MemRead_ID0_IB;
            MemWrite_array[WP_ind] <= MemWrite_ID0_IB;
            Shared_Globalbar_array[WP_ind] <= Shared_Globalbar_ID0_IB;
            BEQ_array[WP_ind] <= BEQ_ID0_IB_SIMT;
            BLT_array[WP_ind] <= BLT_ID0_IB_SIMT;
            Exit_array[WP_ind] <= Exit_ID0_IB;
        end
        if (Valid_ID1_IB_SIMT & !DropInstr_SIMT_IB) begin
            PAM_array[WP_ind] <= ActiveMask_SIMT_IB;
            Instr_array[WP_ind] <= Instr_ID1_IB;
            Src1_Valid_array[WP_ind] <= Src1_Valid_ID1_IB;
            Src1_array[WP_ind] <= Src1_ID1_IB;
            Src2_Valid_array[WP_ind] <= Src2_Valid_ID1_IB;
            Src2_array[WP_ind] <= Src2_ID1_IB;
            Dst_array[WP_ind] <= Dst_ID1_IB;
            ALUop_array[WP_ind] <= ALUop_ID1_IB;
            Imme_array[WP_ind] <= Imme_ID1_IB;
            Imme_Valid_array[WP_ind] <= Imme_Valid_ID1_IB;
            RegWrite_array[WP_ind] <= RegWrite_ID1_IB;
            MemRead_array[WP_ind] <= MemRead_ID1_IB;
            MemWrite_array[WP_ind] <= MemWrite_ID1_IB;
            Shared_Globalbar_array[WP_ind] <= Shared_Globalbar_ID1_IB;
            BEQ_array[WP_ind] <= BEQ_ID1_IB_SIMT;
            BLT_array[WP_ind] <= BLT_ID1_IB_SIMT;
            Exit_array[WP_ind] <= Exit_ID1_IB;
        end
    end

    // Request generation logic
    always@(*) begin
        RP_Req = 1'b0;
        IRP_Req = 1'b0;
        if (RP == IRP | !Valid_array[IRP_ind]) begin
            RP_Req = Valid_array[RP_ind] & !Exit_array[RP_ind] & !Full_Scb_IB & !Dependent_Scb_IB & !Full_OC_IB;
        end else begin // RP != IRP && IRPValid
            // give priority to the Replay Instruction
            if (Replay_array[IRP_ind]) begin
                IRP_Req = !Full_OC_IB;
            end else if (Valid_array[RP_ind] & !Replay_array[RP_ind]) begin // RP is Valid && RP is not another Replayable inst
                RP_Req = !Exit_array[RP_ind] & !Full_Scb_IB & !Dependent_Scb_IB & !Full_OC_IB;
            end
        end
    end

    // output to OC
    assign Instr_IB_OC = IRP_Req? Instr_array[IRP_ind]:Instr_array[RP_ind];
    assign ActiveMask_IB_OC = IRP_Req? PAM_array[IRP_ind]:PAM_array[RP_ind];
    assign Src1_IB_OC = IRP_Req? Src1_array[IRP_ind]:Src1_array[RP_ind];
    assign Src2_IB_OC = IRP_Req? Src2_array[IRP_ind]:Src2_array[RP_ind];
    assign Dst_IB_OC = IRP_Req? Dst_array[IRP_ind]:Dst_array[RP_ind];
    assign Src1_Valid_IB_OC = IRP_Req? Src1_Valid_array[IRP_ind]:Src1_Valid_array[RP_ind];
    assign Src2_Valid_IB_OC = IRP_Req? Src2_Valid_array[IRP_ind]:Src2_Valid_array[RP_ind];
    assign Imme_IB_OC = IRP_Req? Imme_array[IRP_ind]:Imme_array[RP_ind];
    assign Imme_Valid_IB_OC = IRP_Req? Imme_Valid_array[IRP_ind]:Imme_Valid_array[RP_ind];
    assign ALUop_IB_OC = IRP_Req? ALUop_array[IRP_ind]:ALUop_array[RP_ind];
    assign RegWrite_IB_OC = IRP_Req? RegWrite_array[IRP_ind]:RegWrite_array[RP_ind];
    assign MemWrite_IB_OC = IRP_Req? MemWrite_array[IRP_ind]:MemWrite_array[RP_ind];
    assign MemRead_IB_OC = IRP_Req? MemRead_array[IRP_ind]:MemRead_array[RP_ind];
    assign Shared_Globalbar_IB_OC = IRP_Req? Shared_Globalbar_array[IRP_ind]:Shared_Globalbar_array[RP_ind];
    assign BEQ_IB_OC = IRP_Req? BEQ_array[IRP_ind]:BEQ_array[RP_ind];
    assign BLT_IB_OC = IRP_Req? BLT_array[IRP_ind]:BLT_array[RP_ind];
    assign ScbID_IB_OC = IRP_Req? ScbID_array[IRP_ind]:ScbID_Scb_IB;

    // output to Scb
    assign Src1_IB_Scb = Src1_array[RP_ind];
    assign Src2_IB_Scb = Src2_array[RP_ind];
    assign Dst_IB_Scb = Dst_array[RP_ind];
    assign Src1_Valid_IB_Scb = Src1_Valid_array[RP_ind];
    assign Src2_Valid_IB_Scb = Src2_Valid_array[RP_ind];
    assign Dst_Valid_IB_Scb = RegWrite_array[RP_ind];
    assign RP_Grt_IB_Scb = RP_Grt;

    // signal for clearing
    assign Replay_Complete_ScbID_IB_Scb = ScbID_array[IRP_ind]; // mark the Scb entry as Complete
    assign Replay_Complete_IB_Scb = PAM_IRP_next == 0;
    
    // signal to RAU/IU
    assign Exit_Req_IB_IU = Valid_array[RP_ind]? Exit_array[RP_ind] & Empty_Scb_IB & !AllocStall_RAU_IB : 0;

endmodule
