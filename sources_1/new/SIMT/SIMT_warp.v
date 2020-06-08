module SIMT_warp(
// Global Signals
input clk,
input rst,

//internal signals for simulation and error detection
output [1:0]token,      //Token caluculated/update token value that would be pushed
output push,            //stack push
output pop,             //stack pop
output reg [9:0]pc_pushed,  //pc pushed to stack
output [7:0]am_pushed,  //am pushed to stack
output [3:0]sp,         //TOSP
output [3:0]spp1,       //TOSP_plus1
output push_SIMT_raw_sim,
output updatePC_raw_sim,
//interface with Task Manager
input Update_TM_SIMT,
input [7:0] AM_TM_SIMT,

// //interface with Fetch
output UpdatePC_Qual1_SIMT_PC,
output UpdatePC_Qual2_SIMT_PC,
  //--Moved to Decode stage--> output [7:0] UpdatePC_Qual3,
output Stall_SIMT_PC,    //Stall signal from SIMT
output reg [9:0] TA_Warp_SIMT_IF,   // Target Address from SIMT per warp

//interface with Instruction Decode
input DotS_ID_SIMT,
input CondBr_ID_SIMT,
input Call_ID_SIMT,
input Ret_ID_SIMT,
input Jmp_ID_SIMT,
input [9:0] PCplus4_ID_SIMT,

//interface with IBuffer
output DropInstr_SIMT_IB,
output [7:0] AM_Warp_SIMT_IB,

//interface with EX
input CondBr_Ex_SIMT,
input [7:0] CondOutcome_Ex_SIMT

);

localparam SYNC=2'b00;
localparam DIV=2'b01;
localparam CALL=2'b10;
localparam INVALID=2'b11;

localparam warp0=3'b000;
localparam warp1=3'b001;
localparam warp2=3'b010;
localparam warp3=3'b011;
localparam warp4=3'b100;
localparam warp5=3'b101;
localparam warp6=3'b110;
localparam warp7=3'b111;

//Simiulation signals start
// assign sim_stack = stack;
// assign sim_TOSP = TOSP;
// assign sim_TOSP_plus1 = TOSP_plus1;
//Simulation signals ends


reg [19:0] stack [15:0];

reg [3:0] TOSP;
reg [3:0] TOSP_plus1;
reg [7:0] ActiveMask;


// wire CondBr_status_rx_warp [7:0];       // each bit represent status received for a specific warp
wire CondBr_status_Not_rx;   // each bit represent status not received for a specific warp
reg Waiting_Status_CondBr;        // each reg bit used for stall signal generation
wire waiting_wire;


wire Stall_SIMT;
reg TOS_SYNC_Token;        // Top of the stack token is SYNC
integer i,j;

wire updatePC_raw;
wire pop_stack_raw;
wire pop_stack_qual;
wire push_SIMT_raw;
wire updateAM_Qual1;
wire [1:0] updateToken_val;
wire push_SIMT_stack_qual;
// wire updateAM_Qual [7:0];

// assign CondBr_status_Not_rx_warp = ~(CondBr_status_rx_warp);
// assign Stall_SIMT = CondBr_status_Not_rx_warp & Waiting_Status_CondBr;

//-----Simulation Signals interface-------
assign token = updateToken_val;
assign push = push_SIMT_stack_qual;
assign pop = pop_stack_qual;
//---Moved to comb always block-- assign pc_pushed = (updateToken_val==DIV)?stack[TOSP][17:8]:PCplus4_ID_SIMT;
assign am_pushed = (updateToken_val==DIV)?(ActiveMask^CondOutcome_Ex_SIMT):ActiveMask;
assign sp = TOSP;
assign spp1 = TOSP_plus1;
assign updatePC_raw_sim = updatePC_raw;
assign push_SIMT_raw_sim = push_SIMT_raw;
//-----Simulation Signals interface ends-------


assign Stall_SIMT_PC = Stall_SIMT;
assign AM_Warp_SIMT_IB = pop_stack_qual ? stack[TOSP][7:0] : ActiveMask;
//////-------------------------/////

assign DropInstr_SIMT_IB = (Stall_SIMT | 
                              Call_ID_SIMT | Jmp_ID_SIMT | Ret_ID_SIMT |
                              (~TOS_SYNC_Token & (DotS_ID_SIMT & ~(CondBr_ID_SIMT))));
//////-----------Stall Signal Generation--------------/////
assign CondBr_status_Not_rx = ~CondBr_Ex_SIMT;
assign Stall_SIMT = Waiting_Status_CondBr & CondBr_status_Not_rx;

//////-----------PC Qual 1--------------/////
assign updatePC_raw = | CondOutcome_Ex_SIMT;
assign UpdatePC_Qual1_SIMT_PC = updatePC_raw & Waiting_Status_CondBr & CondBr_Ex_SIMT;
//////-----------PC Qual 2--------------/////
//assign pop_stack_raw = Ret_ID_SIMT | (DotS_ID_SIMT & ~(Call_ID_SIMT | CondBr_ID_SIMT));
//assign pop_stack_qual = pop_stack_raw & ~Stall_SIMT;
assign UpdatePC_Qual2_SIMT_PC = pop_stack_qual & ~TOS_SYNC_Token;
//////-----------SIMT Stack Pushing--------------/////
assign push_SIMT_raw = ~(& CondOutcome_Ex_SIMT);
//assign updateAM_Qual1 = updatePC_raw & push_SIMT_raw & CondBr_Ex_SIMT & Stall_SIMT;
assign updateAM_Qual1 = updatePC_raw & push_SIMT_raw & CondBr_Ex_SIMT & Waiting_Status_CondBr; // updated on 2nd feb stall replaced by waiting.
assign updateToken_val[0] = updateAM_Qual1;
//assign updateToken_val[1] = Call_ID_SIMT & ~Stall_SIMT;
assign updateToken_val[1] = Call_ID_SIMT & ~Waiting_Status_CondBr;
//assign push_SIMT_stack_qual = updateToken_val[0] | updateToken_val[1] | (CondBr_ID_SIMT & DotS_ID_SIMT & ~Stall_SIMT);
assign push_SIMT_stack_qual = updateToken_val[0] | updateToken_val[1] | (CondBr_ID_SIMT & DotS_ID_SIMT & ~Waiting_Status_CondBr);
//////-----------SIMT Stack Poping--------------/////
assign pop_stack_raw = Ret_ID_SIMT | (DotS_ID_SIMT & ~(Call_ID_SIMT | CondBr_ID_SIMT));
assign pop_stack_qual = pop_stack_raw & ~Waiting_Status_CondBr;
//assign pop_stack_qual = pop_stack_raw & ~Stall_SIMT;
//////-----------Active Mask Updating--------------/////
assign updateAM_Qual = updateAM_Qual1 | pop_stack_qual;

assign waiting_wire = (Waiting_Status_CondBr)? CondBr_status_Not_rx : CondBr_ID_SIMT;
always @(posedge clk or negedge rst) begin
    if(rst==0) begin
          Waiting_Status_CondBr<=0;
          TOSP<=4'hf;
          TOSP_plus1<=0;
          ActiveMask<=0;
          for(j=0;j<16;j=j+1)
              stack[j]<=0;
    end
    else begin
        // if(Waiting_Status_CondBr) begin
        //     Waiting_Status_CondBr<=CondBr_status_Not_rx;
        // end
        // else begin
        //     Waiting_Status_CondBr<=condBr_wire;
        // end

        Waiting_Status_CondBr <= waiting_wire;
        //////-----------Updating the ActiveMask Reegister--------------/////
        if(Update_TM_SIMT) begin
            ActiveMask <= AM_TM_SIMT;
        end
        else if(updateAM_Qual) begin
            if(pop_stack_qual) begin
                ActiveMask<=stack[TOSP][7:0];
            end
            else begin
                ActiveMask<=CondOutcome_Ex_SIMT;
            end
        end

        //////-----------Updating the stack pointers--------------/////
        // if(pop_stack_qual) begin
        //     TOSP<=TOSP-1;
        //     TOSP_plus1<=TOSP_plus1-1;
        // end
        // else if(push_SIMT_stack_qual) begin
        //     TOSP<=TOSP+1;
        //     TOSP_plus1<=TOSP_plus1+1;
        // end
        case ({pop_stack_qual,push_SIMT_stack_qual})
            2'b10: begin
                        TOSP<=TOSP-1;
                        TOSP_plus1<=TOSP_plus1-1;
                    end
            2'b01: begin
                        TOSP<=TOSP+1;
                        TOSP_plus1<=TOSP_plus1+1;
                    end
            default: begin
                        TOSP<=TOSP;
                        TOSP_plus1<=TOSP_plus1;
                    end
        endcase
        //////-----------Updating SIMT Stack--------------/////
        if(push_SIMT_stack_qual) begin
            stack[TOSP_plus1][19:18]<=updateToken_val;
            stack[TOSP_plus1][17:8]<=PCplus4_ID_SIMT;
            stack[TOSP_plus1][7:0]<=ActiveMask;
            //if(updateToken_val==DIV) begin
            if(Waiting_Status_CondBr==1) begin
                stack[TOSP_plus1][17:8]<=stack[TOSP][17:8];     // Since the warp is stalled when conditional branch is encountered, the following instructions should be flushed, to  free hardware to fetch instructioins from other warps  available. Executing  of a conditiional branch would take significant number of clocks, as theere's no special treatment added for a  specific instruciton in the blocks/stages following SIMT, where Conditional Brnach instruction's execution could be speed up. Hence, PC+4 value is taken from the value stored in SYNC token when pushed. In this Architecture, only Conditional-Branch.S is supported.
                stack[TOSP_plus1][7:0]<=ActiveMask^CondOutcome_Ex_SIMT;
            end
        end
    end
end

always @(*) begin
    if (rst==0) begin
        TOS_SYNC_Token = 0;
        TA_Warp_SIMT_IF = 0;
        pc_pushed = 0;
    end
    else begin
        TOS_SYNC_Token = ~(stack[TOSP][19] | stack[TOSP][18]);//~(stack[19][to_unsigned(TOSP)] | stack[18][to_unsigned(TOSP)]);
        TA_Warp_SIMT_IF = stack[TOSP][17:8];
        //if(updateToken_val==DIV) begin
        if(Waiting_Status_CondBr==1) begin
            pc_pushed = stack[TOSP][17:8];
        end
        else begin
            pc_pushed = PCplus4_ID_SIMT;
        end
    end
end
endmodule