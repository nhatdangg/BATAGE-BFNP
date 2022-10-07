/* verilator lint_off DECLFILENAME */
module muxbranch(rs1,pc,ASel,rs1new);
/* verilator lint_on DECLFILENAME */
/* verilator lint_off UNUSED */
	input wire [31:0]rs1;
	input wire [31:0]pc;
	input wire ASel;
	output reg [31:0]rs1new;
	always @* begin
		rs1new=(rs1&{32{~ASel}})|(pc&{32{ASel}});
	end
endmodule

module muxdmem(ALU,mem,pc,WBsel,wb);
	input wire [31:0]ALU;
	input wire [31:0]mem;
	input wire [31:0] pc;
	input wire [1:0]WBsel;
	output reg [31:0]wb;
	initial begin
	wb=32'd0;
	end
	always @* begin
		case (WBsel)
			2'b00: wb=mem;
			2'b01: wb=ALU;
			2'b10: wb=pc;
			default: wb=0;
		endcase
	end
endmodule

module muxdtfwrs1( in1, in2, in3, in4, sel, out );
	input wire [31:0] in1,in2,in3,in4;
	input wire [1:0] sel;
	output reg [31:0] out;
	always @* begin
		if (sel==2'b00)
			out=in1;
		else if (sel==2'b01)
			out=in2;
		else if (sel==2'b10)
			out=in3;
		else
			out=in4;
	end
endmodule

module muxdtfwrs2( in1, in2, in3, in4, sel, out );
	input wire [31:0] in1,in2,in3,in4;
	input wire [1:0] sel;
	output reg [31:0] out;
	always @* begin
		if (sel==2'b00)
			out=in1;
		else if (sel==2'b01)
			out=in2;
		else if (sel==2'b10)
			out=in3;
		else
			out=in4;
	end
endmodule

module muximm(imm, rs2, bsel, out);
	input wire [31:0]imm;
	input wire [31:0]rs2;
	input wire bsel;
	output reg [31:0]out;
	always @* begin
	out=({32{bsel}}&imm)|({32{~bsel}}&rs2);
	end
endmodule

module muxpc(alu, pcold, pc0, rst_pipeline_2, pcinc, brb, PCSel, hit, check, pcnew);
	input wire [31:0] alu;
	input wire [31:0] pcold, brb, pcinc, pc0;
	input wire PCSel, hit,check, rst_pipeline_2;
	output reg [31:0]pcnew;
	initial begin
		pcnew=32'd0;
	end
	always @* begin
		if (check==1) 
			pcnew=pcold;
		else begin
			if (rst_pipeline_2)
				pcnew=pc0;	
			else if (hit==1)
				pcnew=brb;
			else begin	
				pcnew=pcinc;
//				if (PCSel==1)
//					pcnew=alu;
//				else 
//					pcnew=pcinc;
			end
		end

	end
endmodule

module mux_pc_actual ( alu, pc, PCsel, PC_actual );
	input wire [31:0] pc, alu;
	input wire PCsel;
	output wire [31:0] PC_actual;

	assign PC_actual = (pc+4) & {32{~PCsel}} | alu & {32{PCsel}};
endmodule 
/* verilator lint_on UNUSED */
