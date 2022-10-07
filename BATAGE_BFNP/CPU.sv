`include "processor_specific_macros.h"
`include "AdderPC.sv"
`include "Adderstage4.sv"
`include "ALU.sv"
`include "BranchComparator.sv"
`include "controlstage.sv"
`include "dataforwarding.sv"
`include "dmem.sv"
`include "IMEM.sv"
`include "ImmGeneration.sv"
`include "mux.sv"
`include "PC.sv"
`include "Register.sv"
`include "regpipeline.sv"
`include "Stall_component.sv"
`include "Hybrid_BPU.sv"
/* verilator lint_off UNUSED */
module CPU 
#(
	parameter PROGRAM_INST = "",
	parameter PROGRAM_DATA = ""
)
(
	output wire [31:0] inst_2, inst_4,
	output wire rst_out, stall_2, hit_2,
	output wire [31:0] pc_current, pc_4, pc_3, pc_2,
	input wire clk, rst_BF
);	
	

//	wire [31:0] pc,pcnew,pcinc,pc0,PC_actual;
//	wire [31:0] inst,wb,rs1,rs2,imm,out,rs1new1,alu,DataR,DataR1,rs1branch,rs2imm;
//	wire [31:0] inst1,inst2,inst3,inst4,pc1,pc2,pc3,pc3new,pc4,rs1new,rs2new,rs2new1,alu1,alu2,PC_predict_pre_IF;
//	wire [2:0]  ImmSel,whb;
//	wire BrUn,BrEq,BrLT,BSel,ASel,MemRW,PCSel,RegWEn,hit,RST,check;
//	wire [1:0]  WBsel,cont1,cont2;
//	wire [3:0]  alusel;
//	wire en;

	//Stage 1
	//Branchbuffer Branchbuffer(.pc(pc),.pc2(pc2),.inst2(inst2),.PCSel(PCSel),.pcnew(alu),.hit(hit),.Addr(Addr),.RST(RST),.clk(clk),.check(check));
	

	wire PCSel, RST, hit, check, stall;
	wire [31:0] PC_actual, alu, inst2, PC_predict_pre_IF
	, PC_predict_pre_IF2, pc, pc1;
	wire hit_BTB, hit_BTB2, prediction_IF, prediction_IF2;
	wire [2:1] confidence_BATAGE, confidence_BATAGE2;
	wire [3:1] weight_sr_o, weight_sr_o2;
	wire [4:1] num_table_final_o, num_table_final_o2;
	wire eq_ov_0, eq_ov_02, rst_pipeline_2, rst_pipeline_2_temp;
	
	Hybrid_BPU Hybrid_BPU (
	.Branch_direction(PCSel), .PC_actual(PC_actual), .PC_alu(alu), 
	.inst(inst2), .PC_in(pc), .PC_in2(pc0), .rst(rst_BF), .clk(clk), 
	.PC_predict_pre_IF(PC_predict_pre_IF), .rst_pipeline(RST), 
	.hit(hit), .check(check), .stall(stall),
	.prediction_IF(prediction_IF), .hit_BTB(hit_BTB), 
	.PC_predict_pre_IF2(PC_predict_pre_IF2),
	.hit_BTB2(hit_BTB2),
	.confidence_BATAGE(confidence_BATAGE),
	.confidence_BATAGE2(confidence_BATAGE2),
	.weight_sr_o(weight_sr_o),
	.weight_sr_o2(weight_sr_o2),
	.num_table_final_o(num_table_final_o),
	.num_table_final_o2(num_table_final_o2), 
	.eq_ov_0(eq_ov_0), .eq_ov_02(eq_ov_02), 
	.rst_pipeline_2(rst_pipeline_2),
	.rst_pipeline_2_temp(rst_pipeline_2_temp)
	);
	
	wire [31:0] pc2;
	mux_pc_actual mux_pc_actual ( .alu(alu), .pc(pc2), .PCsel(PCSel), .PC_actual(PC_actual) );
	
	wire [31:0] pcnew;
	PC PC (.clk(clk), .oldPC(pcnew), .newPC(pc), .stall(stall&!rst_pipeline_2), .signal(check) );	
	
	assign hit_2 = hit;
	assign pc_current = pc;
	assign stall_2 = stall;	

	wire [31:0] inst;
	IMEM #(.PROGRAM_INST(PROGRAM_INST)) IMEM (.PC(pc), .inst(inst), .clk(clk), .rst(RST||rst_pipeline_2), .stall(stall));
	
	wire [31:0] pcinc, pc3, pc0;
	AdderPC AdderPC (.oldPC(pc), .newPC(pcinc));
	muxpc muxpc ( .alu(alu), .pcold(pc2), .pc0(pc0), .rst_pipeline_2(rst_pipeline_2),
	.pcinc(pcinc), .PCSel(PCSel), 
	.pcnew(pcnew), .brb(PC_predict_pre_IF), .hit(hit), .check(check));
	
	wire [31:0] inst1;
	
	Regpipelinestage0 Regpipelinestage0(
	.clk(clk), .newpc(pc), .pc(pc0), 
	.PC_predict_pre_IF(PC_predict_pre_IF), 
	.PC_predict_pre_IF2(PC_predict_pre_IF2),
	.prediction_IF(prediction_IF), .prediction_IF2(prediction_IF2),
	.hit_BTB(hit_BTB), .hit_BTB2(hit_BTB2),
	.confidence_BATAGE(confidence_BATAGE),
	.confidence_BATAGE2(confidence_BATAGE2),
	.weight_sr_o(weight_sr_o),
	.weight_sr_o2(weight_sr_o2),
	.num_table_final_o(num_table_final_o),
	.num_table_final_o2(num_table_final_o2),
	.eq_ov_0(eq_ov_0), .eq_ov_02(eq_ov_02),
	.rst(RST||rst_pipeline_2), .stall(stall)
	);
	
	Regpipelinestage1 Regpipelinestage1 (.clk(clk), .newinst(inst), .newpc(pc0), .inst(inst1), .pc(pc1), .rst(RST||rst_pipeline_2), .stall(stall));
	Stall_component Stall_component (.inst1(inst), .inst2(inst1), .stall(stall));
	wire BrEq, BrLT;
	controlstage1 controlstage1 (.inst(inst2),.BrEq(BrEq),.BrLT(BrLT),.PCSel(PCSel));
	//Stage 2
	
	wire [31:0] inst4, rs1new, rs2new, wb;
	wire  RegWEn;
	Register Register (.clk(clk),.AddrD(inst4[11:7]),.AddrA(inst1[19:15]),.AddrB(inst1[24:20]),.DataD(wb),.rs1(rs1new),.rs2(rs2new),.RegWEn(RegWEn));
	
	wire [31:0]  rs1, rs2;
	Regpipelinestage2 Regpipelinestage2 (.clk(clk),.rst(RST),.newrs1(rs1new),.newrs2(rs2new),.newpc(pc1),.newinst(inst1),.inst(inst2),.pc(pc2),.rs1(rs1),.rs2(rs2),.stall(stall));
	//Stage 3
	
	wire [2:0] ImmSel;
	wire [31:0]  imm;
	ImmGeneration ImmGeneration (.inst(inst2[31:7]),.ImmSel(ImmSel),.imm(imm[31:0]));
	
	wire [31:0] rs1branch, rs2imm;
	wire BrUn;
	BranchComparator BranchComparator (.rs1(rs1branch),.rs2(rs2imm),.BrUn(BrUn),.BrEq(BrEq),.BrLT(BrLT));
	
	wire [1:0] cont1, cont2;
	wire [31:0] alu1;
	wire [31:0] pc3new;
	muxdtfwrs1 muxdtfwrs1 ( .in1(rs1), .in2(alu1), .in3(wb), .in4(pc3new), .sel(cont1),.out(rs1branch) );
	muxdtfwrs2 muxdtfwrs2 ( .in1(rs2), .in2(alu1), .in3(wb), .in4(pc3new), .sel(cont2),.out(rs2imm) );
	
	wire [31:0] inst3;
	dataforwarding dataforwarding (.inst2(inst2),.inst3(inst3),.inst4(inst4),.cont1(cont1),.cont2(cont2));
	
	wire [31:0] out;
	wire BSel;
	muximm muximm (.imm(imm), .rs2(rs2imm), .bsel(BSel), .out(out));

	wire [31:0] rs1new1;
	wire ASel;
	muxbranch muxbranch (.rs1(rs1branch),.pc(pc2),.ASel(ASel),.rs1new(rs1new1));

	wire [3:0] alusel;
	ALU ALU (.rs1(rs1new1),.rs2(out),.alusel(alusel),.rd(alu));

	wire [31:0] rs2new1;
	Regpipelinestage3 Regpipelinestage3(.clk(clk),.rst(RST),.newalu(alu),.newrs2(rs2imm),.newpc(pc2),.newinst(inst2),.inst(inst3),.pc(pc3),.alu(alu1),.rs2(rs2new1));
	controlstage3 controlstage3 (.inst(inst2),.BrEq(BrEq),.BrLT(BrLT),.BrUn(BrUn),.alusel(alusel),.ImmSel(ImmSel),.BSel(BSel),.ASel(ASel));
	//Stage 4
	wire MemRW;
	wire [31:0] DataR;
	wire [2:0] whb;
	dmem #(.PROGRAM_DATA(PROGRAM_DATA)) dmem (.clk(clk),.Addr(alu1),.MemRW(MemRW),.DataW(rs2new1),.DataR(DataR),.whb(whb));
	
	
	Adderstage4 Adderstage4 (.oldPC(pc3), .newPC(pc3new));

	wire [31:0] DataR1, alu2, pc4;
	Regpipelinestage4 Regpipelinestage4(.clk(clk),.newDataR(DataR),.newinst(inst3),.newalu(alu1),.newpc(pc3new),.pc(pc4),.alu(alu2),.inst(inst4),.DataR(DataR1));
	controlstage4 controlstage4 (.inst(inst3),.MemRW(MemRW),.whb(whb));
	
	//Stage 5
	wire [1:0] WBsel;
	muxdmem muxdmem (.ALU(alu2),.mem(DataR1),.pc(pc4),.WBsel(WBsel),.wb(wb));
	controlstage5 controlstage5 (.inst(inst4),.WBsel(WBsel),.RegWEn(RegWEn));

	assign rst_out = RST;
	assign inst_2 = inst2;
	assign inst_4 = inst4;
	assign pc_4 = pc4;
	assign pc_3 = pc3;
	assign pc_2 = pc2;
endmodule
/* verilator lint_on UNUSED */
