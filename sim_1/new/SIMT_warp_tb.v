`timescale 1ns/1ns
module SIMT_warp_tb();

reg clk;
reg rst;
reg Update_TM_SIMT;
reg [7:0]AM_TM_SIMT;

reg DotS_ID_SIMT;
reg CondBr_ID_SIMT;
reg Call_ID_SIMT;
reg Ret_ID_SIMT;
reg Jump_ID_SIMT;
reg [9:0] PCplus4_ID_SIMT;
reg CondBr_Ex_SIMT;
reg [7:0] CondOutcome_Ex_SIMT;

wire DropInstr_SIMT_IB;
wire [7:0] AM_Warp_SIMT_IB;
wire UpdatePC_Qual1_SIMT_IF;
wire UpdatePC_Qual2_SIMT_IF;
wire Stall_SIMT_IF;
wire [9:0] TA_Warp_SIMT_IF;
// wire [19:0] stack [15:0][7:0];
// wire [3:0] TOSP[7:0];
// wire [3:0] TOSP_plus1[7:0];

//-----Simulation Signals interface-------
wire [1:0]token;      //Token caluculated/update token value that would be pushed
wire push;            //stack push
wire pop;             //stack pop
wire [9:0]pc_pushed;  //pc pushed to stack
wire [7:0]am_pushed;  //am pushed to stack
wire [3:0]sp;         //TOSP
wire [3:0]spp1;       //TOSP_plus1
wire push_SIMT_raw_sim;
wire updatePC_raw_sim;
//-----Simulation Signals interface ends-------

integer clock_count=0;
integer dots,branch,cal,ret,jump,pcp4,exsig,exout;
integer error=0;

localparam warp0=3'b000;
localparam warp1=3'b001;
localparam warp2=3'b010;
localparam warp3=3'b011;
localparam warp4=3'b100;
localparam warp5=3'b101;
localparam warp6=3'b110;
localparam warp7=3'b111;

localparam t1=8'h01;
localparam t2=8'h03;
localparam t3=8'h07;
localparam t4=8'h0f;
localparam t5=8'h1f;
localparam t6=8'h3f;
localparam t7=8'h7f;
localparam t8=8'hff;

localparam SYNC=2'b00;
localparam DIV=2'b01;
localparam CALL=2'b10;
localparam INVALID=2'b11;

SIMT_warp dut(
	//Global Signals
	.clk(clk),
	.rst(rst),
	//Simulation Signals
	.token(token),
	.push(push),
	.pop(pop),
	.pc_pushed(pc_pushed),
	.am_pushed(am_pushed),
	.sp(sp),
	.spp1(spp1),
	.push_SIMT_raw_sim(push_SIMT_raw_sim),
	.updatePC_raw_sim(updatePC_raw_sim),
	//IB Signals
	.DropInstr_SIMT_IB(DropInstr_SIMT_IB),
	.AM_Warp_SIMT_IB(AM_Warp_SIMT_IB),
	//IF Signals
	.UpdatePC_Qual1_SIMT_IF(UpdatePC_Qual1_SIMT_IF),
	.UpdatePC_Qual2_SIMT_IF(UpdatePC_Qual2_SIMT_IF),
	.Stall_SIMT_IF(Stall_SIMT_IF),
	.TA_Warp_SIMT_IF(TA_Warp_SIMT_IF),
	//ID Signals
	.DotS_ID_SIMT(DotS_ID_SIMT),
	.CondBr_ID_SIMT(CondBr_ID_SIMT),
	.Call_ID_SIMT(Call_ID_SIMT),
	.Ret_ID_SIMT(Ret_ID_SIMT),
	.Jump_ID_SIMT(Jump_ID_SIMT),
	.PCplus4_ID_SIMT(PCplus4_ID_SIMT),
	//EX Signals
	.CondBr_Ex_SIMT(CondBr_Ex_SIMT),
	.CondOutcome_Ex_SIMT(CondOutcome_Ex_SIMT),
	//Task Manager Signals
	.Update_TM_SIMT(Update_TM_SIMT),
	.AM_TM_SIMT(AM_TM_SIMT)
	);

always
begin
	#5;
	clk = ~clk;	
	if(clk) clock_count=clock_count+1;
	else dis;
end	

// task upd;
// input [7:0]mask;
// output update;
// output [7:0]a_m;
// begin
// 	update=1;
// 	a_m=mask;
// 	#10;
// 	update=0;
// end
// endtask

task updt;
input [7:0]mask;
begin
	AM_TM_SIMT=mask;
	Update_TM_SIMT=1;
	#10;
	Update_TM_SIMT=0;
end
endtask

task dis;
begin
	$display("Clock count = %d \t Clock = %d",clock_count,clk);
	$display("AM Warp = %b",AM_Warp_SIMT_IB);
	$display("Drop Instruction = %b",DropInstr_SIMT_IB);
	$display("Update PC Qual1 (due to conditional branch) = %b",UpdatePC_Qual1_SIMT_IF);
	$display("Update PC Qual2 (RET or non-branch.S) = %b",UpdatePC_Qual2_SIMT_IF);
	$display("Stall = %b",Stall_SIMT_IF);
	$display("TA PC to IF = %b",TA_Warp_SIMT_IF);
	//$display("------------------------------------");
	$display("----Token caluculated/update token value that would be pushed = %b",token);
	$display("----stack push = %b",push);
	$display("----stack pop = %b",pop);
	$display("----pc_pushed = %d",pc_pushed);
	$display("----am_pushed = %b",am_pushed);
	$display("----TOSP = %d",sp);
	$display("----TOSP_plus1 = %d",spp1);
	$display("----push_SIMT_raw_sim = %b",push_SIMT_raw_sim);
	$display("----updatePC_raw_sim = %b",updatePC_raw_sim);
	//$display("------------------------------------");
	//$display("\n");
end
endtask


task mod;
// input Update;
// input [7:0]AM;
input DotS;
input CondBr;
input Call;
input Ret;
input Jump;
input [9:0] PCplus4;
input ExBr;
input [7:0] CondOutcome;
begin
// Update_TM_SIMT=Update;
// AM_TM_SIMT=AM;
DotS_ID_SIMT=DotS;
CondBr_ID_SIMT=CondBr;
Call_ID_SIMT=Call;
Ret_ID_SIMT=Ret;
Jump_ID_SIMT=Jump;
PCplus4_ID_SIMT=PCplus4;
CondBr_Ex_SIMT=ExBr;
CondOutcome_Ex_SIMT=CondOutcome;
end
endtask


initial
begin
	clk=1;
	dots=0;
	branch=0;
	cal=0;
	ret=0;
	jump=0;
	pcp4=0;
	exsig=0;
	exout=0;
	mod(dots,branch,cal,ret,jump,pcp4,exsig,exout);
	
	//.S,B,C,R,J,P,E,O
	//mod->	.S 	Br 	Call 	Ret 	Jmp 	PC 	Ex 	Outcome

	Update_TM_SIMT=0;
	AM_TM_SIMT=0;

	// 0		BEQ.S $1, $2, label1
	// 4		Add $5, $4, $1
	// 8		BRA label 2
	// 12	Label 1:	BEQ.S $3, $2, label3
	// 16		Add $5, $4, $3
	// 20		BRA label 4
	// 24	Label 3:	Sub $5, $4, $2
	// 28	Label 4:	NOP.S
	// 32	Label 2:	Mul.S $7, $3, $6

	rst=1;
	#1 rst=0;
	#9 rst=1;
	// dis();
	$display("Instruction : Clear\n\n");
	updt(8'b0011_1111);

	#10;
	// dis();
	// #10;
	// 0		BEQ.S $1, $2, label1
	dots=1;
	branch=1;
	pcp4=4;
	mod(dots,branch,cal,ret,jump,pcp4,exsig,exout);
	#10;
	$display("Instruction : 0		BEQ.S $1, $2, label1\n\n");
	//  4		Add $5, $4, $1 
	// Stall should be high, waiting for response from EX stage for outcome of BEQ.S
	if(Stall_SIMT_IF==0) begin
		$display("Stall_SIMT_IF=0 This is correct");
	end 
		else begin
			$display("Stall is active");
			error=error+1;
		end
	#10;
	// Stall should be high, waiting for response from EX stage for outcome of BEQ.S
	if(Stall_SIMT_IF==0) begin
		$display("Stall is not active");
			error=error+1;
	end 
		else begin
			$display("Stall_SIMT_IF!=0 This is correct");
		end
	#10;
	// Stall should be high, waiting for response from EX stage for outcome of BEQ.S
	if(Stall_SIMT_IF==0) begin
		$display("Stall is not active");
			error=error+1;
	end 
		else begin
			$display("Stall_SIMT_IF!=0 This is correct");
		end
	#10;
	// Stall should be high, waiting for response from EX stage for outcome of BEQ.S
	if(Stall_SIMT_IF==0) begin
		$display("Stall is not active");
			error=error+1;
	end 
		else begin
			$display("Stall_SIMT_IF!=0 This is correct");
		end
	dots=0;
	branch=0;
	pcp4=8;
	exsig=1;
	exout=8'b0010_1101;
	mod(dots,branch,cal,ret,jump,pcp4,exsig,exout);
	#10;
	$display("Instruction : 4		Add $5, $4, $1\n\n");
	if(Stall_SIMT_IF==0) begin 
		$display("Stall_SIMT_IF==0 This is correct");
	end
		else begin
			$display("Stall is still active");
			error=error+1;
		end 
	// Stall should be low
	// #10;
	// 12	Label 1:	BEQ.S $3, $2, label3
	dots=1;
	branch=1;
	pcp4=16;
	exsig=0;
	mod(dots,branch,cal,ret,jump,pcp4,exsig,exout);
	#10;
	$display("Instruction : 12	Label 1:	BEQ.S $3, $2, label3\n\n");
	//  16		Add $5, $4, $3
	// Stall should be high, waiting for response from EX stage for outcome of BEQ.S
	if(Stall_SIMT_IF==0) begin
		$display("Stall_SIMT_IF==0 This is correct");
	end 
		else begin
			$display("Stall is active");
			error=error+1;
		end
	$display("NOP");
	#10;
	dots=0;
	branch=0;
	pcp4=20;
	exsig=1;
	exout=8'b0000_0101;
	mod(dots,branch,cal,ret,jump,pcp4,exsig,exout);
	#10;
	$display("Instruction : 16		Add $5, $4, $3\n\n");
	if(Stall_SIMT_IF==0) begin 
		$display("Stall_SIMT_IF==0 This is correct");
	end
		else begin
			$display("Stall is still active");
			error=error+1;
		end 
	// Stall should be low
	// 24	Label 3:	Sub $5, $4, $2
	exsig=0;
	pcp4=28;
	mod(dots,branch,cal,ret,jump,pcp4,exsig,exout);
	#10;
	$display("Instruction : 24	Label 3:	Sub $5, $4, $2\n\n");
	if(Stall_SIMT_IF==0) begin 
		$display("Stall_SIMT_IF==0 This is correct");
	end
		else begin
			$display("Stall is still active");
			error=error+1;
		end 
	// Stall should be low
	// 28	Label 4:	NOP.S
	dots=1;
	pcp4=32;
	mod(dots,branch,cal,ret,jump,pcp4,exsig,exout);
	#10;
	$display("Instruction : 28	Label 4:	NOP.S\n\n");
	if(UpdatePC_Qual2_SIMT_IF==1) begin 
		$display("UpdatePC_Qual2_SIMT_IF==1 This is correct");
	end
		else begin
			$display("UpdatePC_Qual2_SIMT_IF is still inactive");
			error=error+1;
		end 
	if(TA_Warp_SIMT_IF==16) begin 
		$display("TA_Warp_SIMT_IF==16 This is correct");
	end
		else begin
			$display("TA_Warp_SIMT_IF==%d is incorrect",TA_Warp_SIMT_IF);
			error=error+1;
		end 


	$display("\n************************************************************************");
	$display("Total ERRORS: %d",error);
	$display("************************************************************************\n");
	$finish();
end

endmodule