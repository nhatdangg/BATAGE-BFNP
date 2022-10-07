//`include "ALU.sv"
//`include "controlstage.sv"
//`include "ImmGeneration.sv"
/* verilator lint_off DECLFILENAME */
module Hard_branch_predict #(
	parameter ENTRY = 4,
	parameter TAG_WIDTH = 32 
) (
	output wire prediction,
	output wire hit,

	input wire [31:0] pc4, pc,
	input wire [31:0] inst4, wb, 
	input wire [31:0] inst3, DataR, alu1,
	input wire [31:0] inst2, alu,
	input wire [31:0] inst1,
	input wire [31:0] inst,
	input wire [31:0] register [31:0],
	input wire clk, rst_pipeline
);
//	wire [1:0] ostatus_all [ENTRY-1:0];
	wire [TAG_WIDTH-1:0] otag_all [ENTRY-1:0];
	wire [2:0] ocounter_all [ENTRY-1:0];
	wire [31:0] oinst_br_all [ENTRY-1:0];
/*	wire [31:0] opc_ch_all [ENTRY-1:0];
	wire [31:0] oinst_ch_all [ENTRY-1:0];
	wire [31:0] opast_operand1_all [ENTRY-1:0];
	wire [31:0] opast_operand1_2all [ENTRY-1:0];
	wire [31:0] opast_operand2_all [ENTRY-1:0];
	wire [31:0] opast_operand2_2all [ENTRY-1:0];

	wire [1:0] ostatus;
*/	wire [TAG_WIDTH-1:0] otag;
	wire [2:0] ocounter;
	wire [31:0] oinst_br; //branch instruction 
/*	wire [31:0] oinst_ch; //last instruction change the operand
	wire [31:0] opast_operand1, opast_operand1_2;
	wire [31:0] opast_operand2, opast_operand2_2;

	wire [1:0] istatus;
*/	wire [$clog2(ENTRY)-1:0] iaddr, iaddr_2;
	wire [TAG_WIDTH-1:0] itag;
	wire [2:0] icounter;
	wire [31:0] iinst_br; //branch instruction
/*	wire [31:0] ipc_ch; //PC of change instruction
	wire [31:0] iinst_ch; //last instruction change the operand
	wire [31:0] ipast_operand1, ipast_operand1_2; // last operand value of change instruction
	wire [31:0] ipast_operand2, ipast_operand2_2; // last operand value of change instruction
*/	wire /*en,*/ en_1, /*en_2, en_3, en_4,*/ en_5; //en_1 (miss predict), en_2, en_3 (branch instruction retired)
	
	Cache_predict #(
		.ENTRY(ENTRY),
		.TAG_WIDTH(TAG_WIDTH)
	) Cache_predict (
//		.ostatus_all(ostatus_all),
		.otag_all(otag_all),
		.ocounter_all(ocounter_all),
		.oinst_br_all(oinst_br_all),
/*		.opc_ch_all(opc_ch_all),
		.oinst_ch_all(oinst_ch_all),
		.opast_operand1_all(opast_operand1_all),
		.opast_operand1_2all(opast_operand1_2all),
		.opast_operand2_all(opast_operand2_all),
		.opast_operand2_2all(opast_operand2_2all),
*/
//		.ostatus(ostatus),
		.otag(otag),
		.ocounter(ocounter),
		.oinst_br(oinst_br), //branch instruction 
/*		.oinst_ch(oinst_ch), //last instruction change the operand
		.opast_operand1(opast_operand1), 
		.opast_operand1_2(opast_operand1_2),
		.opast_operand2(opast_operand2), 
		.opast_operand2_2(opast_operand2_2),

		.istatus(istatus),
*/		.iaddr(iaddr),
		.iaddr_2(iaddr_2),
		.itag(itag),
		.icounter(icounter),
		.iinst_br(iinst_br), //branch instruction
/*		.ipc_ch(ipc_ch), //PC of change instruction
		.iinst_ch(iinst_ch), //last instruction change the operand
		.ipast_operand1(ipast_operand1), 
		.ipast_operand1_2(ipast_operand1_2), // last operand value of change instruction
		.ipast_operand2(ipast_operand2), 
		.ipast_operand2_2(ipast_operand2_2), // last operand value of change instruction
*/		.clk(clk), 
//	        .en(en),	
		.en_1(en_1), 
/*		.en_2(en_2), 
		.en_3(en_3),
	        .en_4(en_4),
*/		.en_5(en_5)	//en_1, en_4 (miss predict), en_2, en_3 (branch instruction retired)
	);

	Prediction_component #(
		.ENTRY(ENTRY),
		.TAG_WIDTH(TAG_WIDTH)
	) Prediction_component (
		.prediction(prediction),
		.hit(hit),
		.iaddr(iaddr),

		.inst(inst),
		.inst1(inst1),
		.inst2(inst2),
		.inst3(inst3),
		.inst4(inst4),
		.wb(wb),
		.alu1(alu1),
		.alu(alu),
		.DataR(DataR),
		.pc(pc),
//		.ostatus(ostatus),
		.otag(otag),
		.ocounter(ocounter),
		.oinst_br(oinst_br),
		.register(register)
/*		.oinst_ch(oinst_ch),
		.opast_operand1(opast_operand1),  
		.opast_operand1_2(opast_operand1_2),	
                .opast_operand2(opast_operand2), 
		.opast_operand2_2(opast_operand2_2)
*/	);

	Update_component #(
		.ENTRY(ENTRY),
		.TAG_WIDTH(TAG_WIDTH)
	) Update_component (
//		.istatus(istatus),
		.iaddr(iaddr_2), //retired or miss prediction
		.itag(itag),
		.icounter(icounter),
		.iinst_br(iinst_br), //branch instruction
/*		.ipc_ch(ipc_ch), //PC of change instruction
		.iinst_ch(iinst_ch), //last instruction change the operand
		.ipast_operand1(ipast_operand1), 
		.ipast_operand1_2(ipast_operand1_2), // last operand value of change instruction
		.ipast_operand2(ipast_operand2), 
		.ipast_operand2_2(ipast_operand2_2), // last operand value of change instruction
	        .en(en),	
*/		.en_1(en_1), 
/*		.en_2(en_2), 
		.en_3(en_3),
	        .en_4(en_4),
*/		.en_5(en_5),	//en_1, en_4 (miss predict), en_2, en_3 (branch instruction retired)

		.register(register),
//		.ostatus_all(ostatus_all),
		.otag_all(otag_all),
		.ocounter_all(ocounter_all),
		.oinst_br_all(oinst_br_all),
/*		.opc_ch_all(opc_ch_all),
		.oinst_ch_all(oinst_ch_all),
		.opast_operand1_all(opast_operand1_all),
		.opast_operand1_2all(opast_operand1_2all),
		.opast_operand2_all(opast_operand2_all),
		.opast_operand2_2all(opast_operand2_2all),
*/		.pc4(pc4), 
		.inst4(inst4), 
		.rst_pipeline(rst_pipeline)
	);

endmodule


module Update_component #(
	parameter ENTRY = 4,
	parameter TAG_WIDTH = 32
) (
//	output reg [1:0] istatus,
	output reg [$clog2(ENTRY)-1:0] iaddr,
	output reg [TAG_WIDTH-1:0] itag,
	output reg [2:0] icounter,
	output reg [31:0] iinst_br, //branch instruction
/*	output reg [31:0] ipc_ch, //PC of change instruction
	output reg [31:0] iinst_ch, //last instruction change the operand
	output reg [31:0] ipast_operand1, ipast_operand1_2, // last operand value of change instruction
	output reg [31:0] ipast_operand2, ipast_operand2_2, // last operand value of change instruction
*/	output reg /*en,*/ en_1,/* en_2, en_3, en_4,*/ en_5,//en_1, en_4 (miss predict), en_2, en_3 (branch instruction retired)

//	input wire [1:0] ostatus_all [ENTRY-1:0],
	input wire [TAG_WIDTH-1:0] otag_all [ENTRY-1:0],
	input wire [2:0] ocounter_all [ENTRY-1:0],
	/* verilator lint_off UNUSED */
	input wire [31:0] oinst_br_all [ENTRY-1:0],
//	input wire [31:0] opc_ch_all [ENTRY-1:0],
//	input wire [31:0] oinst_ch_all [ENTRY-1:0],
/*	input wire [31:0] opast_operand1_all [ENTRY-1:0],
	input wire [31:0] opast_operand1_2all [ENTRY-1:0],
	input wire [31:0] opast_operand2_all [ENTRY-1:0],
	input wire [31:0] opast_operand2_2all [ENTRY-1:0],
*/
	input wire [31:0] register [31:0],
	/* verilator lint_on UNUSED */

	input wire [31:0] pc4,
	input wire [31:0] inst4,
	input wire rst_pipeline // pipeline to retired stage
);
	wire [31:0] pcr = pc4 - 4;
	wire [1:0] iaddr_2 = (pcr[1:0] ^ pcr[3:2] ^ pcr[5:4] ^ pcr[7:6] ^ pcr[9:8] ^ pcr[11:10] ^ pcr[13:12] ^ pcr[15:14]) ;
	assign iaddr = iaddr_2;

/*	always_comb begin
		if ( (inst4[6:0] == 7'b1100011) && (rst_pipeline) && (ocounter_all[iaddr_2] == 0)) begin
			istatus = 0;
			en = 1;
		end else if ( ((oinst_ch_all[iaddr_2][6:0] == 7'b0110011) || (oinst_ch_all[iaddr_2][6:0] == 7'b0010011))
				&& (pcr == otag_all[iaddr_2]) && (ostatus_all[iaddr_2] == 0) ) begin
			istatus = 1;
			en = 1;
		end else if ((pcr == otag_all[iaddr_2]) && (ostatus_all[iaddr_2] == 1)) begin
			istatus = 1;
			en = 1;
		end else begin
			istatus = 0;
			en = 0;
		end
	end
*/
	always_comb begin
		if ((inst4[6:0] == 7'b1100011) &&(rst_pipeline) && (ocounter_all[iaddr_2] == 0)) begin
			itag = pcr;
			iinst_br = inst4;
			en_1 = 1;
		end else begin
			itag = 0;
			iinst_br = 0;
			en_1 = 0;
		end
	end	

/*	reg [31:0] inst_ch_1 [ENTRY-1:0];
	reg [31:0] pc_ch_1 [ENTRY-1:0];
	always_ff @(negedge clk) begin
		for (int i = 0; i <= ENTRY-1; i=i+1) begin
			if ((oinst_br_all[i][6:0] == 7'b1100011) && (oinst_br_all[i][19:15] == inst4[11:7]) && 
			   ((inst4[6:0] == 7'b0110011) || (inst4[6:0] == 7'b0010011)) )	begin
				inst_ch_1[i] <= inst4;
				pc_ch_1[i] <= pcr;
		   	end else begin
				inst_ch_1[i] <= inst_ch_1[i];
				pc_ch_1[i] <= pc_ch_1[i];
			end
		end
	end

	always_comb begin
		if ((inst4[6:0] == 7'b1100011) &&(rst_pipeline) && (ocounter_all[iaddr_2] != 0) && (otag_all[iaddr_2] == pcr)	
			&& (oinst_br_all[iaddr_2][6:0] == 7'b1100011)) begin
			ipc_ch = pc_ch_1[iaddr_2];
			iinst_ch = inst_ch_1[iaddr_2];
			en_2 = 1;
		end else begin
			ipc_ch = 0;
			iinst_ch = 0;
			en_2 = 0;
		end	
	end

	assign     num = (pcr == opc_ch_all[0]) ? 0 :
		         (pcr == opc_ch_all[1]) ? 1 :
			 (pcr == opc_ch_all[2]) ? 2 : 3;
	always_comb begin
		if  ((pcr == opc_ch_all[num]) && oinst_br_all[num][6:0] == 7'b1100011) begin
			ipast_operand1 = register[oinst_ch_all[num][19:15]]; 
			ipast_operand2 = (oinst_ch_all[num][6:0] == 7'b0010011) ? 0 : register[oinst_ch_all[num][24:20]];
			ipast_operand1_2 = opast_operand1_all[num];
			ipast_operand2_2 = opast_operand2_all[num];
			en_3 = 1;
			en_4 = 1;
		end else begin
			ipast_operand1 = 0;
			ipast_operand2 = 0;
			ipast_operand1_2 = 0;
			ipast_operand2_2 = 0;
			en_3 = 0;
			en_4 = 0;
		end
	end
*/
	always_comb begin
		if ( (inst4[6:0] == 7'b1100011) && (rst_pipeline) && (ocounter_all[iaddr_2] == 0)) begin
			icounter = 7;
			en_5 = 1;
		end if ((rst_pipeline) && (otag_all[iaddr_2] != pcr)) begin
			icounter = ocounter_all[iaddr_2] - 1;
			en_5 = 1;
		end else if ((rst_pipeline) && (otag_all[iaddr_2] == pcr)) begin
			icounter = (ocounter_all[iaddr_2] == 7) ? 7 : ocounter_all[iaddr_2] + 1;
			en_5 = 1;
		end else begin
			icounter = 0;
			en_5 = 0;
		end
	end

endmodule

module Prediction_component #(
	parameter ENTRY = 4,
	parameter TAG_WIDTH = 32
) (
	output reg prediction,
	output reg hit,
	output wire [$clog2(ENTRY)-1:0] iaddr,

	/* verilator lint_off UNUSED */
	input wire [31:0] inst, inst1, inst2, inst3, inst4,
	input wire [31:0] wb, alu, alu1,
	input wire [31:0] DataR,
	input wire [31:0] pc,
//	input wire [1:0] ostatus,
	input wire [TAG_WIDTH-1:0] otag,
	input wire [2:0] ocounter,
	input wire [31:0] register [31:0],
	input wire [31:0] oinst_br //branch instruction 
	/* verilator lint_on UNUSED */
/*	input wire [31:0] oinst_ch, //last instruction change the operand
	input wire [31:0] opast_operand1, opast_operand1_2,
	input wire [31:0] opast_operand2, opast_operand2_2*/
);
	wire prediction_1;
	//wire condition; //Can predict operand ?

	assign iaddr = pc[1:0] ^ pc[3:2] ^ pc[5:4] ^ pc[7:6] ^ pc[9:8] ^ pc[11:10] ^ pc[13:12] ^ pc[15:14] ;

/*	wire [31:0] sll_cont1, srl_cont1, sra_cont1;
	wire [31:0] sll_cont2, srl_cont2, sra_cont2;
	genvar i;
	generate 
		for ( i=1; i <= 32; i=i+1) begin
			assign sll_cont1[i-1] = (opast_operand1 ==  (opast_operand1_2 << i));
			assign srl_cont1[i-1] = (opast_operand1 ==  (opast_operand1_2 >> i));
			assign sra_cont1[i-1] = (opast_operand1 ==  ($signed(opast_operand1_2) >>> i));
			assign sll_cont2[i-1] = (opast_operand2 ==  (opast_operand2_2 << i));
			assign srl_cont2[i-1] = (opast_operand2 ==  (opast_operand2_2 >> i));
			assign sra_cont2[i-1] = (opast_operand2 ==  ($signed(opast_operand2_2) >>> i));
		end
	endgenerate

	wire [4:0] sll1, srl1, sra1, sll2, srl2, sra2;
	Encoder_32_to_5 Encoder_32_to_5 (
		.out(sll1),
		.in(sll_cont1)
	);
	Encoder_32_to_5 Encoder_32_to_52 (
		.out(srl1),
		.in(srl_cont1)
	);
	Encoder_32_to_5 Encoder_32_to_53 (
		.out(sra1),
		.in(sra_cont1)
	);
	Encoder_32_to_5 Encoder_32_to_54 (
		.out(sll2),
		.in(sll_cont2)
	);
	Encoder_32_to_5 Encoder_32_to_55 (
		.out(srl2),
		.in(srl_cont2)
	);
	Encoder_32_to_5 Encoder_32_to_56 (
		.out(sra2),
		.in(sra_cont2)
	);
	
	assign condition = ( ((sll1 != 0) || (srl1 != 0) || (sra1 != 0) || (opast_operand1 == opast_operand1_2))
				&& ((sll2 != 0) || (srl2 != 0) || (sra2 != 0) || (opast_operand2 == opast_operand2_2)) 
				&& (oinst_br[24:20] == 0));

	wire [31:0] operand1 = (sll1 != 0) ? opast_operand1 << sll1 :
			       (srl1 != 0) ? opast_operand1 >> srl1 :
			       (sra1 != 0) ? $signed(opast_operand1) >>> sra1 :
			       (opast_operand1 == opast_operand1_2) ? opast_operand1 : 0; 

	wire [31:0] operand2 = (sll2 != 0) ? opast_operand2 << sll2 :
			       (srl2 != 0) ? opast_operand2 >> srl2 :
			       (sra2 != 0) ? $signed(opast_operand2) >>> sra2 :
			       (opast_operand2 == opast_operand2_2) ? opast_operand2 : 0;
*/
	//INST1 pre execution
	wire [3:0] alusel;
	wire [31:0] rs1, rs2, rd, imm;
	/* verilator lint_off UNDRIVEN */
	/* verilator lint_off UNUSED */
	wire BrEq, BrLT, BrUn, BSel, ASel; //unused
	/* verilator lint_on UNDRIVEN */
	/* verilator lint_on UNUSED */
	wire [3:0] alusel;
	wire [2:0] ImmSel;
	controlstage3 controlstage3 (
		.inst(inst1),
		.BrEq(BrEq),
		.BrLT(BrLT),
		.BrUn(BrUn),
		.alusel(alusel),
		.ImmSel(ImmSel),
		.BSel(BSel),
		.ASel(ASel)
	);
	ImmGeneration ImmGeneration (
		.inst(inst1[31:7]),
		.ImmSel(ImmSel),
		.imm(imm)
	);
	assign rs1 = ((inst1[6:0] != 7'b0110011) && (inst1[6:0] != 7'b0010011)) ? 0 : 
		     (((inst2[6:0] == 7'b0110011) || (inst2[6:0] == 7'b0010011)) && (inst2[11:7] == inst1[19:15])) ? alu :
		     (((inst3[6:0] == 7'b0110011) || (inst3[6:0] == 7'b0010011)) && (inst3[11:7] == inst1[19:15])) ? alu1 :
		     ((inst3[6:0] == 7'b0000011) && (inst3[11:7] == inst1[19:15])) ? DataR :
		     (((inst4[6:0] == 7'b0110011) || (inst4[6:0] == 7'b0010011) || (inst4[6:0] == 7'b0000011)) && (inst4[11:7] == inst1[19:15])) ? wb :
		     register[inst1[19:15]];
	assign rs2 = (ImmSel != 0) ? imm : 
		     ((inst1[6:0] != 7'b0110011) && (inst1[6:0] != 7'b0010011)) ? 0 : 
		     (((inst2[6:0] == 7'b0110011) || (inst2[6:0] == 7'b0010011)) && (inst2[11:7] == inst1[24:20])) ? alu :
		     (((inst3[6:0] == 7'b0110011) || (inst3[6:0] == 7'b0010011)) && (inst3[11:7] == inst1[24:20])) ? alu1 :
		     ((inst3[6:0] == 7'b0000011) && (inst3[11:7] == inst1[24:20])) ? DataR :
		     (((inst4[6:0] == 7'b0110011) || (inst4[6:0] == 7'b0010011) || (inst4[6:0] == 7'b0000011)) && (inst4[11:7] == inst1[24:20])) ? wb :
		     register[inst1[24:20]];
	ALU ALU (
		.alusel(alusel),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd)
	);
	//INST pre execution	
	wire [3:0] alusel_1;
	wire [31:0] rs1_1, rs2_1, rd_1, imm_1;
	/* verilator lint_off UNDRIVEN */
	/* verilator lint_off UNUSED */
	wire BrEq_1, BrLT_1, BrUn_1, BSel_1, ASel_1; //unused
	/* verilator lint_on UNDRIVEN */
	/* verilator lint_on UNUSED */
	wire [3:0] alusel_1;
	wire [2:0] ImmSel_1;
	controlstage3 controlstage3_1 (
		.inst(inst),
		.BrEq(BrEq_1),
		.BrLT(BrLT_1),
		.BrUn(BrUn_1),
		.alusel(alusel_1),
		.ImmSel(ImmSel_1),
		.BSel(BSel_1),
		.ASel(ASel_1)
	);
	ImmGeneration ImmGeneration_1 (
		.inst(inst[31:7]),
		.ImmSel(ImmSel_1),
		.imm(imm_1)
	);
	assign rs1_1 = ((inst[6:0] != 7'b0110011) && (inst[6:0] != 7'b0010011)) ? 0 : 
		     (((inst1[6:0] == 7'b0110011) || (inst1[6:0] == 7'b0010011) || (inst1[6:0] == 7'b0000011)) && (inst1[11:7] == inst[19:15])) ? rd :
		     (((inst2[6:0] == 7'b0110011) || (inst2[6:0] == 7'b0010011)) && (inst2[11:7] == inst[19:15])) ? alu :
		     (((inst3[6:0] == 7'b0110011) || (inst3[6:0] == 7'b0010011)) && (inst3[11:7] == inst[19:15])) ? alu1 :
		     ((inst3[6:0] == 7'b0000011) && (inst3[11:7] == inst[19:15])) ? DataR :
		     (((inst4[6:0] == 7'b0110011) || (inst4[6:0] == 7'b0010011) || (inst4[6:0] == 7'b0000011)) && (inst4[11:7] == inst[19:15])) ? wb :
		     register[inst[19:15]];
	assign rs2_1 = (ImmSel_1 != 0) ? imm_1 : 
		     ((inst[6:0] != 7'b0110011) && (inst[6:0] != 7'b0010011)) ? 0 : 
		     (((inst2[6:0] == 7'b0110011) || (inst2[6:0] == 7'b0010011)) && (inst2[11:7] == inst[24:20])) ? alu :
		     (((inst3[6:0] == 7'b0110011) || (inst3[6:0] == 7'b0010011)) && (inst3[11:7] == inst[24:20])) ? alu1 :
		     ((inst3[6:0] == 7'b0000011) && (inst3[11:7] == inst[24:20])) ? DataR :
		     (((inst4[6:0] == 7'b0110011) || (inst4[6:0] == 7'b0010011) || (inst4[6:0] == 7'b0000011)) && (inst4[11:7] == inst[24:20])) ? wb :
		     register[inst[24:20]];
	ALU ALU_1 (
		.alusel(alusel_1),
		.rs1(rs1_1),
		.rs2(rs2_1),
		.rd(rd_1)
	);

	// BR INST pre execution	
	wire [31:0] rs1_2, rs2_2;
	/* verilator lint_off UNDRIVEN */
	/* verilator lint_off UNUSED */
	wire [3:0] alusel_2;
	wire BrEq_2, BrLT_2, BrUn_2, BSel_2, ASel_2; //unused
	wire [2:0] ImmSel_2;
	/* verilator lint_on UNDRIVEN */
	/* verilator lint_on UNUSED */
	wire [3:0] alusel_2;
	controlstage3 controlstage3_2 (
		.inst(oinst_br),
		.BrEq(BrEq_2),
		.BrLT(BrLT_2),
		.BrUn(BrUn_2),
		.alusel(alusel_2),
		.ImmSel(ImmSel_2),
		.BSel(BSel_2),
		.ASel(ASel_2)
	);
	assign rs1_2 = 
		     (((inst[6:0] == 7'b0110011) || (inst[6:0] == 7'b0010011) || (inst[6:0] == 7'b0000011)) && (inst[11:7] == oinst_br[19:15])) ? rd_1 :
		     (((inst1[6:0] == 7'b0110011) || (inst1[6:0] == 7'b0010011) || (inst1[6:0] == 7'b0000011)) && (inst1[11:7] == oinst_br[19:15])) ? rd :
		     (((inst2[6:0] == 7'b0110011) || (inst2[6:0] == 7'b0010011)) && (inst2[11:7] == oinst_br[19:15])) ? alu :
		     (((inst3[6:0] == 7'b0110011) || (inst3[6:0] == 7'b0010011)) && (inst3[11:7] == oinst_br[19:15])) ? alu1 :
		     ((inst3[6:0] == 7'b0000011) && (inst3[11:7] == oinst_br[19:15])) ? DataR :
		     (((inst4[6:0] == 7'b0110011) || (inst4[6:0] == 7'b0010011) || (inst4[6:0] == 7'b0000011)) && (inst4[11:7] == oinst_br[19:15])) ? wb :
		     register[oinst_br[19:15]];
	assign rs2_2 =  
		     (((inst[6:0] == 7'b0110011) || (inst[6:0] == 7'b0010011) || (inst[6:0] == 7'b0000011)) && (inst[11:7] == oinst_br[24:20])) ? rd_1 :
		     (((inst2[6:0] == 7'b0110011) || (inst2[6:0] == 7'b0010011)) && (inst2[11:7] == oinst_br[24:20])) ? alu :
		     (((inst3[6:0] == 7'b0110011) || (inst3[6:0] == 7'b0010011)) && (inst3[11:7] == oinst_br[24:20])) ? alu1 :
		     ((inst3[6:0] == 7'b0000011) && (inst3[11:7] == oinst_br[24:20])) ? DataR :
		     (((inst4[6:0] == 7'b0110011) || (inst4[6:0] == 7'b0010011) || (inst4[6:0] == 7'b0000011)) && (inst4[11:7] == oinst_br[24:20])) ? wb :
		     register[oinst_br[24:20]];

	BranchComparator BranchComparator (.rs1(rs1_2),.rs2(rs2_2),.BrUn(BrUn_2),.BrEq(BrEq_2),.BrLT(BrLT_2));
        wire PCSel;
	controlstage1 controlstage1 (.inst(oinst_br),.BrEq(BrEq_2),.BrLT(BrLT_2),.PCSel(PCSel));
	assign prediction_1 = PCSel;

	always_comb begin
		if (ocounter > 0) begin
			if ((otag == pc) /*&& (condition == 1) && (ostatus == 1)*/) begin
				prediction = prediction_1;
				hit = 1;
			end else begin
				prediction = 0;
				hit = 0;
			end	
		end else begin
			prediction = 0;
			hit = 0;
		end
	end
endmodule

module Encoder_32_to_5 (
	output reg [4:0] out,
	input wire [31:0] in
);
	always_comb begin
		case(in)
			32'd1: out = 1;
			32'd2: out = 2;
			32'd4: out = 3;
			32'd8: out = 4;
			32'd16: out = 5;
			32'd32: out = 6;
			32'd64: out = 7;
			32'd128: out = 8;
			32'd256: out = 9;
			32'd512: out = 10;
			32'd1024: out = 11;
			32'd2048: out = 12;
			32'd4096: out = 13;
			32'd8192: out = 14;
			32'd16384: out = 15;
			32'd32768: out = 16;
			default: out = 0;
		endcase
	end
endmodule

module Cache_predict #(
	parameter ENTRY = 4,
	parameter TAG_WIDTH = 32
) (
//	output wire [1:0] ostatus_all [ENTRY-1:0],
	output wire [TAG_WIDTH-1:0] otag_all [ENTRY-1:0],
	output wire [2:0] ocounter_all [ENTRY-1:0],
	output wire [31:0] oinst_br_all [ENTRY-1:0],
/*	output wire [31:0] opc_ch_all [ENTRY-1:0],
	output wire [31:0] oinst_ch_all [ENTRY-1:0],
	output wire [31:0] opast_operand1_all [ENTRY-1:0],
	output wire [31:0] opast_operand1_2all [ENTRY-1:0],
	output wire [31:0] opast_operand2_all [ENTRY-1:0],
	output wire [31:0] opast_operand2_2all [ENTRY-1:0],
*/
//	output reg [1:0] ostatus,
	output reg [TAG_WIDTH-1:0] otag,
	output reg [2:0] ocounter,
	output reg [31:0] oinst_br, //branch instruction 
/*	output reg [31:0] oinst_ch, //last instruction change the operand
	output reg [31:0] opast_operand1, opast_operand1_2,
	output reg [31:0] opast_operand2, opast_operand2_2,
*/
//	input wire [1:0] istatus,
	input wire [$clog2(ENTRY)-1:0] iaddr, iaddr_2,
	input wire [TAG_WIDTH-1:0] itag,
	input wire [2:0] icounter,
	input wire [31:0] iinst_br, //branch instruction
/*	input wire [31:0] ipc_ch, //PC of change instruction
	input wire [31:0] iinst_ch, //last instruction change the operand
	input wire [31:0] ipast_operand1, ipast_operand1_2, // last operand value of change instruction
	input wire [31:0] ipast_operand2, ipast_operand2_2, // last operand value of change instruction
*/	input wire clk,/* en,*/ en_1,/* en_2, en_3, en_4,*/ en_5 //en_1, en_4 (miss predict), en_2, en_3 (branch instruction retired)
);
//	reg [1:0] status [ENTRY-1:0];
	reg [TAG_WIDTH-1:0] tag [ENTRY-1:0];	// out
	reg [2:0] counter [ENTRY-1:0];		// out
	reg [31:0] inst_br [ENTRY-1:0];		// out
/*	reg [31:0] pc_ch [ENTRY-1:0];		// out
	reg [31:0] inst_ch [ENTRY-1:0];		// out
	reg [31:0] past_operand1 [ENTRY-1:0];
        reg [31:0] past_operand1_2 [ENTRY-1:0];
	reg [31:0] past_operand2 [ENTRY-1:0];
	reg [31:0] past_operand2_2 [ENTRY-1:0];
*/
//	assign ostatus_all = status;
	assign otag_all = tag;
        assign ocounter_all = counter;
	assign oinst_br_all = inst_br;	
/*	assign oinst_ch_all = inst_ch;
	assign opc_ch_all = pc_ch;
	assign opast_operand1_all = past_operand1;
	assign opast_operand1_2all = past_operand1_2;
	assign opast_operand2_all = past_operand2;
	assign opast_operand2_2all = past_operand2_2;
*/
	initial begin
		for ( int i=0; i <= ENTRY; i=i+1) begin
//			status[i] = 0;
			tag[i] = 0;
			counter[i] = 0;
			inst_br[i] = 0;
/*			pc_ch[i] = 0;
			inst_ch[i] = 0;
			past_operand1[i] = 0;
			past_operand1_2[i] = 0;
			past_operand2 [i] = 0;
			past_operand2_2 [i] = 0;
*/		end
	end

/*	always @(posedge clk) begin
		if (en) 
			status [iaddr_2] <= istatus;
		ostatus <= status [iaddr];
	end
*/	
	always @(posedge clk) begin
		if (en_1) begin
			tag [iaddr_2] <= itag;
			inst_br [iaddr_2] <= iinst_br;
		end
		otag <= tag [iaddr];
		oinst_br <= inst_br [iaddr];
	end
	
/*
	always @(posedge clk) begin
		if (en_2) begin
			pc_ch [iaddr_2] <= ipc_ch;
			inst_ch [iaddr_2] <= iinst_ch;
		end
		oinst_ch <= inst_ch [iaddr];
	end

	always @(posedge clk) begin
		if (en_3) begin
			past_operand1 [iaddr_2] <= ipast_operand1;
			past_operand2 [iaddr_2] <= ipast_operand2;
		end
		opast_operand1 <= past_operand1 [iaddr];
		opast_operand2 <= past_operand2 [iaddr];

	end
	always @(posedge clk) begin
		if (en_4) begin
			past_operand1_2 [iaddr_2] <= ipast_operand1_2;
			past_operand2_2 [iaddr_2] <= ipast_operand2_2;
		end
		opast_operand1_2 <= past_operand1_2 [iaddr];
		opast_operand2_2 <= past_operand2_2 [iaddr];
	end
*/
	always @(posedge clk) begin
		if (en_5)
			counter [iaddr_2] <= icounter;
		ocounter <= counter [iaddr];
	end

endmodule
/* verilator lint_off DECLFILENAME */
