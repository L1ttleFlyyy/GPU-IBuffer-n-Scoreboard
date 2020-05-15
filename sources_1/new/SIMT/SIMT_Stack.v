module SIMT(
// Global Signals
input clk,
input rst,

//interface with Task Manager
input Update_TM_SIMT,
input [2:0] WarpID_TM_SIMT,
input [7:0] AM_TM_SIMT,

//interface with Fetch
output [7:0] UpdatePC_Qual1_SIMT_PC,
output [7:0] UpdatePC_Qual2_SIMT_PC,
  //--Moved to Decode stage--> output [7:0] UpdatePC_Qual3,
output [7:0] Stall_SIMT_PC,    //Stall signal from SIMT
output [32*8-1:0] TargetAddr_SIMT_PC_Flattened, // ={warp7, warp6, ...., warp0}

//interface with Instruction Decode
input BEQ_ID0_IB_SIMT,
input BEQ_ID1_IB_SIMT,
input BLT_ID0_IB_SIMT,
input BLT_ID1_IB_SIMT,
// input CondBr_ID1_SIMT,
// input CondBr_ID2_SIMT,
input DotS_ID1_SIMT,
input DotS_ID0_SIMT,
input Call_ID1_SIMT,
input Call_ID0_SIMT,
input Ret_ID1_SIMT,
input Ret_ID0_SIMT,
input Jmp_ID1_SIMT,
input Jmp_ID0_SIMT,
input [7:0] Valid_ID0_IB_SIMT,
input [7:0] Valid_ID1_IB_SIMT,
input [9:0] PCplus4_ID1_SIMT,
input [9:0] PCplus4_ID0_SIMT,

//interface with IBuffer
output [7:0] DropInstr_SIMT_IB,
output [8*8-1:0] ActiveMask_SIMT_IB_Flattened,

//interface with EX
input Br_ALU_SIMT,
input [7:0] BrOutcome_ALU_SIMT,
input [2:0] WarpID_ALU_SIMT

);

localparam warp0=3'b000;
localparam warp1=3'b001;
localparam warp2=3'b010;
localparam warp3=3'b011;
localparam warp4=3'b100;
localparam warp5=3'b101;
localparam warp6=3'b110;
localparam warp7=3'b111;


wire [9:0] TA_Warp_SIMT_IF [7:0];  // Target Address from SIMT per warp
wire [7:0] AM_Warp_SIMT_IB [7:0];
wire [21:0] z22;
assign z22 = 0;
assign TargetAddr_SIMT_PC_Flattened = {z22,TA_Warp_SIMT_IF[7],
                z22,TA_Warp_SIMT_IF[6],z22,TA_Warp_SIMT_IF[5],
                z22,TA_Warp_SIMT_IF[4],z22,TA_Warp_SIMT_IF[3],
                z22,TA_Warp_SIMT_IF[2],z22,TA_Warp_SIMT_IF[1],
                z22,TA_Warp_SIMT_IF[0]};

assign ActiveMask_SIMT_IB_Flattened = {AM_Warp_SIMT_IB[7],
                                        AM_Warp_SIMT_IB[6],
                                        AM_Warp_SIMT_IB[5],
                                        AM_Warp_SIMT_IB[4],
                                        AM_Warp_SIMT_IB[3],
                                        AM_Warp_SIMT_IB[2],
                                        AM_Warp_SIMT_IB[1],
                                        AM_Warp_SIMT_IB[0]};

reg [7:0] CondBr_Warp;
reg [7:0] DotS_Warp;
reg [7:0] Call_Warp;
reg [7:0] Ret_Warp;
reg [7:0] Jump_Warp;
reg [9:0] PCplus4_ID_SIMT [7:0];
reg [7:0] warp_Br_ALU_SIMT;
reg [7:0] warp_Update_TM_SIMT;
integer i;

always @(*)
begin
    for(i=0;i<8;i=i+1) begin
        //CondBr_Warp signal shows if a conditional branch is present, it belongs to which warp
        CondBr_Warp[i] = ((Valid_ID0_IB_SIMT[i] & (BEQ_ID0_IB_SIMT | BLT_ID0_IB_SIMT)) |
                              (Valid_ID1_IB_SIMT[i] & (BEQ_ID1_IB_SIMT | BLT_ID1_IB_SIMT)));

        DotS_Warp[i] = ((Valid_ID0_IB_SIMT[i] & DotS_ID0_SIMT) |
                              (Valid_ID1_IB_SIMT[i] & DotS_ID1_SIMT));

        Call_Warp[i] = ((Valid_ID0_IB_SIMT[i] & Call_ID0_SIMT) |
                              (Valid_ID1_IB_SIMT[i] & Call_ID1_SIMT));

        Ret_Warp[i] = ((Valid_ID0_IB_SIMT[i] & Ret_ID0_SIMT) |
                              (Valid_ID1_IB_SIMT[i] & Ret_ID1_SIMT));

        Jump_Warp[i] = ((Valid_ID0_IB_SIMT[i] & Jmp_ID0_SIMT) |
                              (Valid_ID1_IB_SIMT[i] & Jmp_ID1_SIMT));
        if(Valid_ID0_IB_SIMT[i]==1) begin
            PCplus4_ID_SIMT[i] = PCplus4_ID0_SIMT;
        end
        else begin
            PCplus4_ID_SIMT[i] = PCplus4_ID1_SIMT;
        end
        warp_Br_ALU_SIMT[i]=0;
        warp_Update_TM_SIMT[i]=0;
    end

    case (WarpID_ALU_SIMT)
        warp0:  warp_Br_ALU_SIMT[0] = Br_ALU_SIMT;
        warp1:  warp_Br_ALU_SIMT[1] = Br_ALU_SIMT;
        warp2:  warp_Br_ALU_SIMT[2] = Br_ALU_SIMT;
        warp3:  warp_Br_ALU_SIMT[3] = Br_ALU_SIMT;
        warp4:  warp_Br_ALU_SIMT[4] = Br_ALU_SIMT;
        warp5:  warp_Br_ALU_SIMT[5] = Br_ALU_SIMT;
        warp6:  warp_Br_ALU_SIMT[6] = Br_ALU_SIMT;
        warp7:  warp_Br_ALU_SIMT[7] = Br_ALU_SIMT;
        default:  warp_Br_ALU_SIMT = 0;
    endcase

    case (WarpID_TM_SIMT)
        warp0:  warp_Update_TM_SIMT[0] = Update_TM_SIMT;
        warp1:  warp_Update_TM_SIMT[1] = Update_TM_SIMT;
        warp2:  warp_Update_TM_SIMT[2] = Update_TM_SIMT;
        warp3:  warp_Update_TM_SIMT[3] = Update_TM_SIMT;
        warp4:  warp_Update_TM_SIMT[4] = Update_TM_SIMT;
        warp5:  warp_Update_TM_SIMT[5] = Update_TM_SIMT;
        warp6:  warp_Update_TM_SIMT[6] = Update_TM_SIMT;
        warp7:  warp_Update_TM_SIMT[7] = Update_TM_SIMT;
        default: warp_Update_TM_SIMT = 0;
    endcase
end





 // ==============================================================

SIMT_warp warp_0(
// Global Signals
.clk(clk),
.rst(rst),
//internal signals for simulation and error detection
.token(),
.push(),
.pop(),
.pc_pushed(),
.am_pushed(),
.sp(),
.spp1(),
.push_SIMT_raw_sim(),
.updatePC_raw_sim(),
//interface with Task Manager
.Update_TM_SIMT(warp_Update_TM_SIMT[0]),
.AM_TM_SIMT(AM_TM_SIMT),
// //interface with Fetch
.UpdatePC_Qual1_SIMT_PC(UpdatePC_Qual1_SIMT_PC[0]),
.UpdatePC_Qual2_SIMT_PC(UpdatePC_Qual2_SIMT_PC[0]),
.Stall_SIMT_PC(Stall_SIMT_PC[0]),
.TA_Warp_SIMT_IF(TA_Warp_SIMT_IF[0]),
//interface with Instruction Decode
.DotS_ID_SIMT(DotS_Warp[0]),
.CondBr_ID_SIMT(CondBr_Warp[0]),
.Call_ID_SIMT(Call_Warp[0]),
.Ret_ID_SIMT(Ret_Warp[0]),
.Jmp_ID_SIMT(Jump_Warp[0]),
.PCplus4_ID_SIMT(PCplus4_ID_SIMT[0]),
//interface with IBuffer
.DropInstr_SIMT_IB(DropInstr_SIMT_IB[0]),
.AM_Warp_SIMT_IB(AM_Warp_SIMT_IB[0]),
//interface with EX
.CondBr_Ex_SIMT(warp_Br_ALU_SIMT[0]),
.CondOutcome_Ex_SIMT(BrOutcome_ALU_SIMT)
);

 // ==============================================================

SIMT_warp warp_1(
// Global Signals
.clk(clk),
.rst(rst),
//internal signals for simulation and error detection
.token(),
.push(),
.pop(),
.pc_pushed(),
.am_pushed(),
.sp(),
.spp1(),
.push_SIMT_raw_sim(),
.updatePC_raw_sim(),
//interface with Task Manager
.Update_TM_SIMT(warp_Update_TM_SIMT[1]),
.AM_TM_SIMT(AM_TM_SIMT),
// //interface with Fetch
.UpdatePC_Qual1_SIMT_PC(UpdatePC_Qual1_SIMT_PC[1]),
.UpdatePC_Qual2_SIMT_PC(UpdatePC_Qual2_SIMT_PC[1]),
.Stall_SIMT_PC(Stall_SIMT_PC[1]),
.TA_Warp_SIMT_IF(TA_Warp_SIMT_IF[1]),
//interface with Instruction Decode
.DotS_ID_SIMT(DotS_Warp[1]),
.CondBr_ID_SIMT(CondBr_Warp[1]),
.Call_ID_SIMT(Call_Warp[1]),
.Ret_ID_SIMT(Ret_Warp[1]),
.Jmp_ID_SIMT(Jump_Warp[1]),
.PCplus4_ID_SIMT(PCplus4_ID_SIMT[1]),
//interface with IBuffer
.DropInstr_SIMT_IB(DropInstr_SIMT_IB[1]),
.AM_Warp_SIMT_IB(AM_Warp_SIMT_IB[1]),
//interface with EX
.CondBr_Ex_SIMT(warp_Br_ALU_SIMT[1]),
.CondOutcome_Ex_SIMT(BrOutcome_ALU_SIMT)
);

 // ==============================================================

SIMT_warp warp_2(
// Global Signals
.clk(clk),
.rst(rst),
//internal signals for simulation and error detection
.token(),
.push(),
.pop(),
.pc_pushed(),
.am_pushed(),
.sp(),
.spp1(),
.push_SIMT_raw_sim(),
.updatePC_raw_sim(),
//interface with Task Manager
.Update_TM_SIMT(warp_Update_TM_SIMT[2]),
.AM_TM_SIMT(AM_TM_SIMT),
// //interface with Fetch
.UpdatePC_Qual1_SIMT_PC(UpdatePC_Qual1_SIMT_PC[2]),
.UpdatePC_Qual2_SIMT_PC(UpdatePC_Qual2_SIMT_PC[2]),
.Stall_SIMT_PC(Stall_SIMT_PC[2]),
.TA_Warp_SIMT_IF(TA_Warp_SIMT_IF[2]),
//interface with Instruction Decode
.DotS_ID_SIMT(DotS_Warp[2]),
.CondBr_ID_SIMT(CondBr_Warp[2]),
.Call_ID_SIMT(Call_Warp[2]),
.Ret_ID_SIMT(Ret_Warp[2]),
.Jmp_ID_SIMT(Jump_Warp[2]),
.PCplus4_ID_SIMT(PCplus4_ID_SIMT[2]),
//interface with IBuffer
.DropInstr_SIMT_IB(DropInstr_SIMT_IB[2]),
.AM_Warp_SIMT_IB(AM_Warp_SIMT_IB[2]),
//interface with EX
.CondBr_Ex_SIMT(warp_Br_ALU_SIMT[2]),
.CondOutcome_Ex_SIMT(BrOutcome_ALU_SIMT)
);

 // ==============================================================

SIMT_warp warp_3(
// Global Signals
.clk(clk),
.rst(rst),
//internal signals for simulation and error detection
.token(),
.push(),
.pop(),
.pc_pushed(),
.am_pushed(),
.sp(),
.spp1(),
.push_SIMT_raw_sim(),
.updatePC_raw_sim(),
// interface with Task Manager
.Update_TM_SIMT(warp_Update_TM_SIMT[3]),
.AM_TM_SIMT(AM_TM_SIMT),
// //interface with Fetch
.UpdatePC_Qual1_SIMT_PC(UpdatePC_Qual1_SIMT_PC[3]),
.UpdatePC_Qual2_SIMT_PC(UpdatePC_Qual2_SIMT_PC[3]),
.Stall_SIMT_PC(Stall_SIMT_PC[3]),
.TA_Warp_SIMT_IF(TA_Warp_SIMT_IF[3]),
//interface with Instruction Decode
.DotS_ID_SIMT(DotS_Warp[3]),
.CondBr_ID_SIMT(CondBr_Warp[3]),
.Call_ID_SIMT(Call_Warp[3]),
.Ret_ID_SIMT(Ret_Warp[3]),
.Jmp_ID_SIMT(Jump_Warp[3]),
.PCplus4_ID_SIMT(PCplus4_ID_SIMT[3]),
//interface with IBuffer
.DropInstr_SIMT_IB(DropInstr_SIMT_IB[3]),
.AM_Warp_SIMT_IB(AM_Warp_SIMT_IB[3]),
//interface with EX
.CondBr_Ex_SIMT(warp_Br_ALU_SIMT[3]),
.CondOutcome_Ex_SIMT(BrOutcome_ALU_SIMT)
);

 // ==============================================================

SIMT_warp warp_4(
// Global Signals
.clk(clk),
.rst(rst),
//internal signals for simulation and error detection
.token(),
.push(),
.pop(),
.pc_pushed(),
.am_pushed(),
.sp(),
.spp1(),
.push_SIMT_raw_sim(),
.updatePC_raw_sim(),
// interface with Task Manager
.Update_TM_SIMT(warp_Update_TM_SIMT[4]),
.AM_TM_SIMT(AM_TM_SIMT),
// //interface with Fetch
.UpdatePC_Qual1_SIMT_PC(UpdatePC_Qual1_SIMT_PC[4]),
.UpdatePC_Qual2_SIMT_PC(UpdatePC_Qual2_SIMT_PC[4]),
.Stall_SIMT_PC(Stall_SIMT_PC[4]),
.TA_Warp_SIMT_IF(TA_Warp_SIMT_IF[4]),
//interface with Instruction Decode
.DotS_ID_SIMT(DotS_Warp[4]),
.CondBr_ID_SIMT(CondBr_Warp[4]),
.Call_ID_SIMT(Call_Warp[4]),
.Ret_ID_SIMT(Ret_Warp[4]),
.Jmp_ID_SIMT(Jump_Warp[4]),
.PCplus4_ID_SIMT(PCplus4_ID_SIMT[4]),
//interface with IBuffer
.DropInstr_SIMT_IB(DropInstr_SIMT_IB[4]),
.AM_Warp_SIMT_IB(AM_Warp_SIMT_IB[4]),
//interface with EX
.CondBr_Ex_SIMT(warp_Br_ALU_SIMT[4]),
.CondOutcome_Ex_SIMT(BrOutcome_ALU_SIMT)
);

 // ==============================================================

SIMT_warp warp_5(
// Global Signals
.clk(clk),
.rst(rst),
//internal signals for simulation and error detection
.token(),
.push(),
.pop(),
.pc_pushed(),
.am_pushed(),
.sp(),
.spp1(),
.push_SIMT_raw_sim(),
.updatePC_raw_sim(),
//interface with Task Manager
.Update_TM_SIMT(warp_Update_TM_SIMT[5]),
.AM_TM_SIMT(AM_TM_SIMT),
// //interface with Fetch
.UpdatePC_Qual1_SIMT_PC(UpdatePC_Qual1_SIMT_PC[5]),
.UpdatePC_Qual2_SIMT_PC(UpdatePC_Qual2_SIMT_PC[5]),
.Stall_SIMT_PC(Stall_SIMT_PC[5]),
.TA_Warp_SIMT_IF(TA_Warp_SIMT_IF[5]),
//interface with Instruction Decode
.DotS_ID_SIMT(DotS_Warp[5]),
.CondBr_ID_SIMT(CondBr_Warp[5]),
.Call_ID_SIMT(Call_Warp[5]),
.Ret_ID_SIMT(Ret_Warp[5]),
.Jmp_ID_SIMT(Jump_Warp[5]),
.PCplus4_ID_SIMT(PCplus4_ID_SIMT[5]),
//interface with IBuffer
.DropInstr_SIMT_IB(DropInstr_SIMT_IB[5]),
.AM_Warp_SIMT_IB(AM_Warp_SIMT_IB[5]),
//interface with EX
.CondBr_Ex_SIMT(warp_Br_ALU_SIMT[5]),
.CondOutcome_Ex_SIMT(BrOutcome_ALU_SIMT)
);

 // ==============================================================

SIMT_warp warp_6(
// Global Signals
.clk(clk),
.rst(rst),
//internal signals for simulation and error detection
.token(),
.push(),
.pop(),
.pc_pushed(),
.am_pushed(),
.sp(),
.spp1(),
.push_SIMT_raw_sim(),
.updatePC_raw_sim(),
//interface with Task Manager
.Update_TM_SIMT(warp_Update_TM_SIMT[6]),
.AM_TM_SIMT(AM_TM_SIMT),
// //interface with Fetch
.UpdatePC_Qual1_SIMT_PC(UpdatePC_Qual1_SIMT_PC[6]),
.UpdatePC_Qual2_SIMT_PC(UpdatePC_Qual2_SIMT_PC[6]),
.Stall_SIMT_PC(Stall_SIMT_PC[6]),
.TA_Warp_SIMT_IF(TA_Warp_SIMT_IF[6]),
//interface with Instruction Decode
.DotS_ID_SIMT(DotS_Warp[6]),
.CondBr_ID_SIMT(CondBr_Warp[6]),
.Call_ID_SIMT(Call_Warp[6]),
.Ret_ID_SIMT(Ret_Warp[6]),
.Jmp_ID_SIMT(Jump_Warp[6]),
.PCplus4_ID_SIMT(PCplus4_ID_SIMT[6]),
//interface with IBuffer
.DropInstr_SIMT_IB(DropInstr_SIMT_IB[6]),
.AM_Warp_SIMT_IB(AM_Warp_SIMT_IB[6]),
//interface with EX
.CondBr_Ex_SIMT(warp_Br_ALU_SIMT[6]),
.CondOutcome_Ex_SIMT(BrOutcome_ALU_SIMT)
);

 // ==============================================================

SIMT_warp warp_7(
// Global Signals
.clk(clk),
.rst(rst),
//internal signals for simulation and error detection
.token(),
.push(),
.pop(),
.pc_pushed(),
.am_pushed(),
.sp(),
.spp1(),
.push_SIMT_raw_sim(),
.updatePC_raw_sim(),
//interface with Task Manager
.Update_TM_SIMT(warp_Update_TM_SIMT[7]),
.AM_TM_SIMT(AM_TM_SIMT),
// //interface with Fetch
.UpdatePC_Qual1_SIMT_PC(UpdatePC_Qual1_SIMT_PC[7]),
.UpdatePC_Qual2_SIMT_PC(UpdatePC_Qual2_SIMT_PC[7]),
.Stall_SIMT_PC(Stall_SIMT_PC[7]),
.TA_Warp_SIMT_IF(TA_Warp_SIMT_IF[7]),
//interface with Instruction Decode
.DotS_ID_SIMT(DotS_Warp[7]),
.CondBr_ID_SIMT(CondBr_Warp[7]),
.Call_ID_SIMT(Call_Warp[7]),
.Ret_ID_SIMT(Ret_Warp[7]),
.Jmp_ID_SIMT(Jump_Warp[7]),
.PCplus4_ID_SIMT(PCplus4_ID_SIMT[7]),
//interface with IBuffer
.DropInstr_SIMT_IB(DropInstr_SIMT_IB[7]),
.AM_Warp_SIMT_IB(AM_Warp_SIMT_IB[7]),
//interface with EX
.CondBr_Ex_SIMT(warp_Br_ALU_SIMT[7]),
.CondOutcome_Ex_SIMT(BrOutcome_ALU_SIMT)
);


endmodule