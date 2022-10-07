/* verilator lint_off DECLFILENAME */
module Regpipelinestage0 (clk,newpc,pc,rst,stall);
/* verilator lint_on DECLFILENAME */
/* verilator lint_off UNUSED */
	input wire [31:0]newpc;
	input wire clk,rst,stall;
	output reg [31:0]pc;
	always_ff @(negedge clk) begin
		if (rst==1) 
			pc <= 0;
		else begin
			if (stall)
				pc <= pc;
			else
				pc <= newpc;
		end
	end
endmodule

module Regpipelinestage1 (clk,rst,newinst,newpc,inst,pc,stall);
	input wire [31:0]newinst,newpc;
	input wire clk,rst,stall;
	output reg [31:0]inst,pc;
	always_ff @(negedge clk) begin
		if (rst==1) begin
			inst<=32'h000033;
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
