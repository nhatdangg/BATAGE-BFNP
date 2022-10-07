/* verilator lint_off DECLFILENAME */
module Regpipelinestage0 (clk,newpc,pc,rst,stall,
	PC_predict_pre_IF, PC_predict_pre_IF2, hit_BTB, hit_BTB2, 
	prediction_IF, prediction_IF2, confidence_BATAGE,
	confidence_BATAGE2, weight_sr_o,
	weight_sr_o2, num_table_final_o, num_table_final_o2,
	eq_ov_0, eq_ov_02);
/* verilator lint_on DECLFILENAME */
/* verilator lint_off UNUSED */
	input wire [31:0]newpc;
	input wire clk,rst,stall;
	input wire [31:0] PC_predict_pre_IF;
	input wire hit_BTB, prediction_IF;
	input wire [2:1] confidence_BATAGE;
	input wire [3:1] weight_sr_o;
	input wire [4:1] num_table_final_o;
	input wire eq_ov_0;
	
	output reg [31:0]pc, PC_predict_pre_IF2;
	output reg hit_BTB2, prediction_IF2;
	output reg [2:1] confidence_BATAGE2;
	output reg [3:1] weight_sr_o2;
	output reg [4:1] num_table_final_o2;
	output reg eq_ov_02;
	
	always_ff @(negedge clk) begin
		if (rst==1) begin 
			pc <= 0;
			PC_predict_pre_IF2 <= 0;
			prediction_IF2 <= 0;
			hit_BTB2 <= 0;
			confidence_BATAGE2 <= 0;
			weight_sr_o2 <= 0;
			num_table_final_o2 <= 0;
			eq_ov_02 <= 0;
		end
		else begin
			if (stall) begin
				pc <= pc;
				PC_predict_pre_IF2 <= PC_predict_pre_IF2;
				prediction_IF2 <= prediction_IF2;
				hit_BTB2 <= hit_BTB2;
				confidence_BATAGE2 <= confidence_BATAGE2;
				weight_sr_o2 <= weight_sr_o2;
				num_table_final_o2 <= num_table_final_o2;
				eq_ov_02 <= eq_ov_02;
			end
			else begin
				pc <= newpc;
				PC_predict_pre_IF2 <= PC_predict_pre_IF;
				prediction_IF2 <= prediction_IF;
				hit_BTB2 <= hit_BTB;
				confidence_BATAGE2 <= confidence_BATAGE;
				weight_sr_o2 <= weight_sr_o;
				num_table_final_o2 <= num_table_final_o;
				eq_ov_02 <= eq_ov_0;
			end
		end
	end
endmodule

module Regpipelinestage1 (clk,rst,newinst,newpc,inst,pc,stall);
	input wire [31:0]newinst,newpc;
	input wire clk,rst,stall;
	output reg [31:0]inst,pc;
	always_ff @(negedge clk) begin
		if (rst==1) begin
			inst<=32'h00000033;
			pc<=0;
		end
		else begin
			if (stall) begin 
				inst <= 32'h00000033;
				pc <= pc;
			end
			else begin
				inst<=newinst;
				pc<=newpc;
			end
		end
	end
	endmodule

module Regpipelinestage2 (clk,rst,newrs1,newrs2,newpc,newinst,inst,pc,rs1,rs2,stall);
	input wire [31:0]newinst,newpc,newrs1,newrs2;
	input wire clk,rst,stall;
	output reg [31:0]inst,pc,rs1,rs2;

	always_ff @(negedge clk) begin
		if (rst==1) begin
			inst<=32'h00000033;
			pc<=0;
			rs1<=0;
			rs2<=0;
		end
		else begin
			inst<=newinst;
			pc<=newpc;
			rs1<=newrs1;
			rs2<=newrs2;
			
		end
	end
endmodule

module Regpipelinestage3 (clk,rst,newalu,newrs2,newpc,newinst,inst,pc,alu,rs2);
	input wire [31:0]newinst,newpc,newalu,newrs2;
	input wire clk,rst;
	output reg [31:0]inst,pc,alu,rs2;
	always_ff @(negedge clk) begin
		if (rst==1) begin
			inst<=32'h00000033;
			pc<=newpc;
			alu<=0;	
			rs2<=0;
		end
		else begin
			inst<=newinst;
			pc<=newpc;
			alu<=newalu;
			rs2<=newrs2;
		end
	end
endmodule

module Regpipelinestage4 (clk,newDataR,newinst,newalu,newpc,alu,inst,DataR,pc);
	input wire [31:0]newinst,newDataR,newalu,newpc;
	input wire clk;
	output reg [31:0]inst,DataR,alu,pc;
	always_ff @(negedge clk) begin
		inst<=newinst;
		DataR<=newDataR;
		alu<=newalu;
		pc<=newpc;
	end
endmodule
/* verilator lint_on UNUSED */
