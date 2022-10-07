//module controlstage1 (inst,BrEq,BrLT,PCSel);
//	input wire [31:0]inst;
//	input wire BrEq,BrLT;
//	output reg PCSel;
//	wire [9:0]contr;
//	assign contr={inst[31:25],inst[14:12]};
//	initial begin
//	PCSel=1'b0;
//	end
//	always@*
//		begin
//		case(inst[6:0])
//		7'b0110011:	PCSel=1'b0;
//		7'b0010011:	PCSel=1'b0;
//		7'b0000011:	PCSel=1'b0;
//		7'b0100011:	PCSel=1'b0;
//		7'b1100011:	case(inst[14:12])
//					3'b000: 
//						if (BrEq==1'b1)
//							begin  PCSel=1'b1;end
//						else if (BrEq==1'b0)
//							begin  PCSel=1'b0;end
//						
//					3'b001: 
//						if (BrEq==1'b0)
//							begin  PCSel=1'b1;end
//						else if (BrEq==1'b1)
//							begin  PCSel=1'b0;end
//						
//					3'b100:
//						if (BrLT==1'b1)
//							begin  PCSel=1'b1;end
//						else if (BrLT==1'b0)
//							begin  PCSel=1'b0;end
//						
//					3'b101: 
//						if (BrLT==1'b0)
//							begin  PCSel=1'b1;end
//						else if (BrLT==1'b1)
//							begin  PCSel=1'b0;end
//						
//					3'b110: 
//						if (BrLT==1'b1)
//							begin  PCSel=1'b1;end
//						else if (BrLT==1'b0)
//							begin  PCSel=1'b0;end
//						
//					3'b111:
//						if (BrLT==1'b0)
//							begin  PCSel=1'b1;end
//						else if (BrLT==1'b1)
//							begin  PCSel=1'b0;end
//						
//					default:;
//					endcase
//		7'b0110111: begin PCSel=1'b0; end
//		7'b0010111: begin PCSel=1'b0; end
//		7'b1101111: begin PCSel=1'b1;end
//		7'b1100111: begin PCSel=1'b1; end
//		default:;
//
//		endcase	
//		end
//	endmodule
//
//module controlstage3 (inst,BrEq,BrLT,BrUn,alusel,ImmSel,BSel,ASel);
//	input wire [31:0]inst;
//	input wire BrEq,BrLT;
//	output reg BrUn;
//	output reg ASel;
//	output reg [3:0]alusel;
//	output reg [2:0]ImmSel;
//	output reg BSel;
//	wire [9:0]contr;
//	assign contr={inst[31:25],inst[14:12]};
//	initial begin
//	alusel=4'b0000; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0;
//	end
//	always@*
//		begin
//		case(inst[6:0])
//		7'b0110011:	case(contr)
//					10'h000: begin alusel=4'b0000; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
//					10'h100: begin alusel=4'b0001; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
//					10'h001: begin alusel=4'b0010; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
//					10'h002: begin alusel=4'b0011; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
//					10'h003: begin alusel=4'b0100; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
//					10'h004: begin alusel=4'b0101; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
//					10'h005: begin alusel=4'b0110; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
//					10'h105: begin alusel=4'b0111; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
//					10'h006: begin alusel=4'b1000; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
//					10'h007: begin alusel=4'b1001; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
//					default:; 
//				endcase
//		7'b0010011:	case(inst[14:12])
//					3'b000: begin alusel=4'b0000; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//					3'b010: begin alusel=4'b0011; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//					3'b011: begin alusel=4'b0100; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//					3'b100: begin alusel=4'b0101; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//					3'b110: begin alusel=4'b1000; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//					3'b111: begin alusel=4'b1001; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//					3'b001: begin alusel=4'b0010; ImmSel=3'd2; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//					3'b101:case(inst[30])
//						1'b0: begin alusel=4'b0110; ImmSel=3'd2; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//						1'b1: begin alusel=4'b0111; ImmSel=3'd2; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//						endcase
//				endcase
//		7'b0000011:	begin alusel=4'b0000; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//		7'b0100011:	begin alusel=4'b0000; ImmSel=3'd3; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//		7'b1100011:	case(inst[14:12])
//					3'b000: begin BrUn=1'b0; 
//						if (BrEq==1'b1)
//							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
//						else if (BrEq==1'b0)
//							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
//						end
//					3'b001:begin BrUn=1'b0; 
//						if (BrEq==1'b0)
//							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
//						else if (BrEq==1'b1)
//							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
//						end
//					3'b100:begin BrUn=1'b0; 
//						if (BrLT==1'b1)
//							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
//						else if (BrLT==1'b0)
//							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
//						end
//					3'b101:begin BrUn=1'b0; 
//						if (BrLT==1'b0)
//							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
//						else if (BrLT==1'b1)
//							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
//						end
//					3'b110:begin BrUn=1'b1; 
//						if (BrLT==1'b1)
//							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
//						else if (BrLT==1'b0)
//							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
//						end
//					3'b111:begin BrUn=1'b1; 
//						if (BrLT==1'b0)
//							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
//						else if (BrLT==1'b1)
//							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
//						end
//					default:;
//					endcase
//		7'b0110111: begin alusel=4'b1010; ImmSel=3'd5;BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//		7'b0010111: begin alusel=4'b0000; ImmSel=3'd5;BSel=1'b1;ASel=1'b1;BrUn=1'b0; end
//		7'b1101111: begin alusel=4'b0000; ImmSel=3'd6;BSel=1'b1;ASel=1'b1;BrUn=1'b0; end
//		7'b1100111: begin alusel=4'b0000; ImmSel=3'd1;BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
//		default:;
//
//		endcase	
//		end
//	endmodule
//
//module controlstage4 (inst,MemRW,whb);
//	input wire [31:0]inst;
//	output reg [2:0] whb;
//	output reg MemRW;
//	wire [9:0]contr;
//	assign contr={inst[31:25],inst[14:12]};
//	initial begin
//	MemRW=1'b0;whb=3'd0;
//	end
//	always@*
//		begin
//		case(inst[6:0])
//		7'b0110011:	case(contr)
//					10'h000: begin MemRW=1'b0;whb=3'd0; end
//					10'h100: begin MemRW=1'b0;whb=3'd0; end
//					10'h001: begin MemRW=1'b0;whb=3'd0; end
//					10'h002: begin MemRW=1'b0;whb=3'd0; end
//					10'h003: begin MemRW=1'b0;whb=3'd0; end
//					10'h004: begin MemRW=1'b0;whb=3'd0; end
//					10'h005: begin MemRW=1'b0;whb=3'd0; end
//					10'h105: begin MemRW=1'b0;whb=3'd0; end
//					10'h006: begin MemRW=1'b0;whb=3'd0; end
//					10'h007: begin MemRW=1'b0;whb=3'd0; end
//					default:;
//				endcase
//		7'b0010011:	case(inst[14:12])
//					3'b000: begin MemRW=1'b0;whb=3'd0; end
//					3'b010: begin MemRW=1'b0;whb=3'd0; end
//					3'b011: begin MemRW=1'b0;whb=3'd0; end
//					3'b100: begin MemRW=1'b0;whb=3'd0; end
//					3'b110: begin MemRW=1'b0;whb=3'd0; end
//					3'b111: begin MemRW=1'b0;whb=3'd0; end
//					3'b001: begin MemRW=1'b0;whb=3'd0; end
//					3'b101:case(inst[30])
//						1'b0: begin MemRW=1'b0;whb=3'd0; end
//						1'b1: begin MemRW=1'b0;whb=3'd0; end
//						endcase
//				endcase
//		7'b0000011:	case(inst[14:12])
//					3'b000: begin MemRW=1'b0;whb=3'b000; end
//					3'b001: begin MemRW=1'b0;whb=3'b001; end
//					3'b010: begin MemRW=1'b0;whb=3'b010; end
//					3'b100: begin MemRW=1'b0;whb=3'b011; end
//					3'b101: begin MemRW=1'b0;whb=3'b100; end
//				endcase
//		7'b0100011:	case(inst[14:12])
//					3'b000: begin  MemRW=1'b1;whb=3'd0; end
//					3'b001: begin  MemRW=1'b1;whb=3'd1; end
//					3'b010: begin  MemRW=1'b1;whb=3'd2; end
//					default:;
//				endcase
//		7'b1100011: MemRW=1'b0;
//		7'b0110111: begin MemRW=1'b0;whb=3'd0; end
//		7'b0010111: begin MemRW=1'b0;whb=3'd0; end
//		7'b1101111: begin MemRW=1'b0;whb=3'd0; end
//		7'b1100111: begin MemRW=1'b0;whb=3'd0; end
//		default:;
//
//		endcase
//		end
//	endmodule
//
//module controlstage5 (inst,WBsel,RegWEn);
//	input wire [31:0]inst;
//	output reg [1:0]WBsel;
//	output reg RegWEn;
//	wire [9:0]contr;
//	assign contr={inst[31:25],inst[14:12]};
//	initial begin
//	WBsel=2'b01;RegWEn=1'b0;
//	end
//	always@*
//		begin
//		case(inst[6:0])
//		7'b0110011:	case(contr)
//					10'h000: begin WBsel=2'b01;RegWEn=1'b1; end
//					10'h100: begin WBsel=2'b01;RegWEn=1'b1; end
//					10'h001: begin WBsel=2'b01;RegWEn=1'b1; end
//					10'h002: begin WBsel=2'b01;RegWEn=1'b1; end
//					10'h003: begin WBsel=2'b01;RegWEn=1'b1; end
//					10'h004: begin WBsel=2'b01;RegWEn=1'b1; end
//					10'h005: begin WBsel=2'b01;RegWEn=1'b1; end
//					10'h105: begin WBsel=2'b01;RegWEn=1'b1; end
//					10'h006: begin WBsel=2'b01;RegWEn=1'b1; end
//					10'h007: begin WBsel=2'b01;RegWEn=1'b1; end
//					default:;
//				endcase
//		7'b0010011:	case(inst[14:12])
//					3'b000: begin   WBsel=2'b01;RegWEn=1'b1; end
//					3'b010: begin   WBsel=2'b01;RegWEn=1'b1; end
//					3'b011: begin   WBsel=2'b01;RegWEn=1'b1; end
//					3'b100: begin   WBsel=2'b01;RegWEn=1'b1; end
//					3'b110: begin   WBsel=2'b01;RegWEn=1'b1; end
//					3'b111: begin   WBsel=2'b01;RegWEn=1'b1; end
//					3'b001: begin   WBsel=2'b01;RegWEn=1'b1; end
//					3'b101:case(inst[30])
//						1'b0: begin   WBsel=2'b01;RegWEn=1'b1; end
//						1'b1: begin   WBsel=2'b01;RegWEn=1'b1; end
//						endcase
//				endcase
//		7'b0000011:	case(inst[14:12])
//					3'b000: begin   WBsel=2'b00;RegWEn=1'b1; end
//					3'b001: begin   WBsel=2'b00;RegWEn=1'b1; end
//					3'b010: begin   WBsel=2'b00;RegWEn=1'b1; end
//					3'b100: begin   WBsel=2'b00;RegWEn=1'b1; end
//					3'b101: begin   WBsel=2'b00;RegWEn=1'b1; end
//				endcase
//		7'b0100011:	case(inst[14:12])
//					3'b000: begin   WBsel=2'b00;RegWEn=1'b0; end
//					3'b001: begin   WBsel=2'b00;RegWEn=1'b0; end
//					3'b010: begin   WBsel=2'b00;RegWEn=1'b0; end
//					default:;
//				endcase
//		7'b1100011: begin  WBsel=2'b00;RegWEn=1'b0; end
//		7'b0110111: begin  WBsel=2'b01;RegWEn=1'b1; end
//		7'b0010111: begin  WBsel=2'b01;RegWEn=1'b1; end
//		7'b1101111: begin  WBsel=2'b10;RegWEn=1'b1; end
//		7'b1100111: begin  WBsel=2'b10;RegWEn=1'b1; end
//		default:;
//
//		endcase
//		end
//	endmodule
/* verilator lint_off DECLFILENAME */
module controlstage1 (inst,BrEq,BrLT,PCSel);
/* verilator lint_on DECLFILENAME */
/* verilator lint_off UNUSED */
	input wire [31:0]inst;
	input wire BrEq,BrLT;
	output reg PCSel;

	always_comb
		begin
		case(inst[6:0])
		7'b0110011:	PCSel=1'b0;
		7'b0010011:	PCSel=1'b0;
		7'b0000011:	PCSel=1'b0;
		7'b0100011:	PCSel=1'b0;
		7'b1100011:	case(inst[14:12])
					3'b000: 
						if (BrEq==1'b1)
							begin  PCSel=1'b1;end
						else 
							begin  PCSel=1'b0;end
						
					3'b001: 
						if (BrEq==1'b0)
							begin  PCSel=1'b1;end
						else 
							begin  PCSel=1'b0;end
						
					3'b100:
						if (BrLT==1'b1)
							begin  PCSel=1'b1;end
						else 
							begin  PCSel=1'b0;end
						
					3'b101: 
						if (BrLT==1'b0)
							begin  PCSel=1'b1;end
						else 
							begin  PCSel=1'b0;end
						
					3'b110: 
						if (BrLT==1'b1)
							begin  PCSel=1'b1;end
						else 
							begin  PCSel=1'b0;end
						
					3'b111:
						if (BrLT==1'b0)
							begin  PCSel=1'b1;end
						else 
							begin  PCSel=1'b0;end
						
					default:PCSel=1'b0;
					endcase
		7'b0110111: begin PCSel=1'b0; end
		7'b0010111: begin PCSel=1'b0; end
		7'b1101111: begin PCSel=1'b1;end
		7'b1100111: begin PCSel=1'b1; end
		default: PCSel=1'b0;

		endcase	
		end
	endmodule

module controlstage3 (inst,BrEq,BrLT,BrUn,alusel,ImmSel,BSel,ASel);
	input wire [31:0]inst;
	input wire BrEq,BrLT;
	output reg BrUn;
	output reg ASel;
	output reg [3:0]alusel;
	output reg [2:0]ImmSel;
	output reg BSel;
	wire [9:0]contr;
	assign contr={inst[31:25],inst[14:12]};
	
	always_comb begin
		case(inst[6:0])
		7'b0110011:	case(contr)
					10'h000: begin alusel=4'b0000; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
					10'h100: begin alusel=4'b0001; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
					10'h001: begin alusel=4'b0010; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
					10'h002: begin alusel=4'b0011; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
					10'h003: begin alusel=4'b0100; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
					10'h004: begin alusel=4'b0101; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
					10'h005: begin alusel=4'b0110; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
					10'h105: begin alusel=4'b0111; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
					10'h006: begin alusel=4'b1000; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
					10'h007: begin alusel=4'b1001; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end
					default: begin alusel=4'b0000; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end 
				endcase
		7'b0010011:	case(inst[14:12])
					3'b000: begin alusel=4'b0000; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
					3'b010: begin alusel=4'b0011; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
					3'b011: begin alusel=4'b0100; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
					3'b100: begin alusel=4'b0101; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
					3'b110: begin alusel=4'b1000; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
					3'b111: begin alusel=4'b1001; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
					3'b001: begin alusel=4'b0010; ImmSel=3'd2; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
					3'b101:case(inst[30])
						1'b0: begin alusel=4'b0110; ImmSel=3'd2; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
						default: begin alusel=4'b0111; ImmSel=3'd2; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
						endcase
					default: begin alusel=4'b0000; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
				endcase
		7'b0000011:	begin alusel=4'b0000; ImmSel=3'd1; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
		7'b0100011:	begin alusel=4'b0000; ImmSel=3'd3; BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
		7'b1100011:	case(inst[14:12])
					3'b000: begin BrUn=1'b0; 
						if (BrEq==1'b1)
							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;BrUn=1'b0;end
						else 
							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;BrUn=1'b0;end
						end
					3'b001:begin BrUn=1'b0; 
						if (BrEq==1'b0)
							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;BrUn=1'b0;end
						else 
							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;BrUn=1'b0;end
						end
					3'b100:begin BrUn=1'b0; 
						if (BrLT==1'b1)
							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;BrUn=1'b0;end
						else 
							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;BrUn=1'b0;end
						end
					3'b101:begin BrUn=1'b0; 
						if (BrLT==1'b0)
							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;BrUn=1'b0;end
						else 
							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;BrUn=1'b0;end
						end
					3'b110:begin BrUn=1'b1; 
						if (BrLT==1'b1)
							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
						else
							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
						end
					3'b111:begin BrUn=1'b1; 
						if (BrLT==1'b0)
							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
						else 
							begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;end
						end
					default:begin alusel=4'b0000; ImmSel=3'd4; BSel=1'b1;ASel=1'b1;BrUn=1'b0;end
					endcase
		7'b0110111: begin alusel=4'b1010; ImmSel=3'd5;BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
		7'b0010111: begin alusel=4'b0000; ImmSel=3'd5;BSel=1'b1;ASel=1'b1;BrUn=1'b0; end
		7'b1101111: begin alusel=4'b0000; ImmSel=3'd6;BSel=1'b1;ASel=1'b1;BrUn=1'b0; end
		7'b1100111: begin alusel=4'b0000; ImmSel=3'd1;BSel=1'b1;ASel=1'b0;BrUn=1'b0; end
		default: begin alusel=4'b0000; ImmSel=3'd0;BSel=1'b0;ASel=1'b0;BrUn=1'b0; end

		endcase	
		end
	endmodule

module controlstage4 (inst,MemRW,whb);
	input wire [31:0]inst;
	output reg [2:0] whb;
	output reg MemRW;
	wire [9:0]contr;
	assign contr={inst[31:25],inst[14:12]};
	
	always_comb begin
		case(inst[6:0])
		7'b0110011:	case(contr)
					10'h000: begin MemRW=1'b0;whb=3'd0; end
					10'h100: begin MemRW=1'b0;whb=3'd0; end
					10'h001: begin MemRW=1'b0;whb=3'd0; end
					10'h002: begin MemRW=1'b0;whb=3'd0; end
					10'h003: begin MemRW=1'b0;whb=3'd0; end
					10'h004: begin MemRW=1'b0;whb=3'd0; end
					10'h005: begin MemRW=1'b0;whb=3'd0; end
					10'h105: begin MemRW=1'b0;whb=3'd0; end
					10'h006: begin MemRW=1'b0;whb=3'd0; end
					10'h007: begin MemRW=1'b0;whb=3'd0; end
					default: begin MemRW=1'b0;whb=3'd0; end
				endcase
		7'b0010011:	case(inst[14:12])
					3'b000: begin MemRW=1'b0;whb=3'd0; end
					3'b010: begin MemRW=1'b0;whb=3'd0; end
					3'b011: begin MemRW=1'b0;whb=3'd0; end
					3'b100: begin MemRW=1'b0;whb=3'd0; end
					3'b110: begin MemRW=1'b0;whb=3'd0; end
					3'b111: begin MemRW=1'b0;whb=3'd0; end
					3'b001: begin MemRW=1'b0;whb=3'd0; end
					3'b101:case(inst[30])
						1'b0: begin MemRW=1'b0;whb=3'd0; end
						default: begin MemRW=1'b0;whb=3'd0; end
						endcase
					default: begin MemRW=1'b0;whb=3'd0; end
				endcase
		7'b0000011:	case(inst[14:12])
					3'b000: begin MemRW=1'b0;whb=3'b000; end
					3'b001: begin MemRW=1'b0;whb=3'b001; end
					3'b010: begin MemRW=1'b0;whb=3'b010; end
					3'b100: begin MemRW=1'b0;whb=3'b011; end
					3'b101: begin MemRW=1'b0;whb=3'b100; end
					default: begin MemRW=1'b0;whb=3'b000; end
				endcase
		7'b0100011:	case(inst[14:12])
					3'b000: begin  MemRW=1'b1;whb=3'd0; end
					3'b001: begin  MemRW=1'b1;whb=3'd1; end
					3'b010: begin  MemRW=1'b1;whb=3'd2; end
					default: begin  MemRW=1'b1;whb=3'd0; end
				endcase
		7'b1100011: begin MemRW=1'b0; whb=3'd0; end
		7'b0110111: begin MemRW=1'b0;whb=3'd0; end
		7'b0010111: begin MemRW=1'b0;whb=3'd0; end
		7'b1101111: begin MemRW=1'b0;whb=3'd0; end
		7'b1100111: begin MemRW=1'b0;whb=3'd0; end
		default: begin MemRW=1'b0;whb=3'd0; end

		endcase
		end
	endmodule

module controlstage5 (inst,WBsel,RegWEn);
	input wire [31:0]inst;
	output reg [1:0]WBsel;
	output reg RegWEn;
	wire [9:0]contr;
	assign contr={inst[31:25],inst[14:12]};
	always_comb begin
		case(inst[6:0])
		7'b0110011:	case(contr)
					10'h000: begin WBsel=2'b01;RegWEn=1'b1; end
					10'h100: begin WBsel=2'b01;RegWEn=1'b1; end
					10'h001: begin WBsel=2'b01;RegWEn=1'b1; end
					10'h002: begin WBsel=2'b01;RegWEn=1'b1; end
					10'h003: begin WBsel=2'b01;RegWEn=1'b1; end
					10'h004: begin WBsel=2'b01;RegWEn=1'b1; end
					10'h005: begin WBsel=2'b01;RegWEn=1'b1; end
					10'h105: begin WBsel=2'b01;RegWEn=1'b1; end
					10'h006: begin WBsel=2'b01;RegWEn=1'b1; end
					10'h007: begin WBsel=2'b01;RegWEn=1'b1; end
					default: begin WBsel=2'b01;RegWEn=1'b1; end
				endcase
		7'b0010011:	case(inst[14:12])
					3'b000: begin   WBsel=2'b01;RegWEn=1'b1; end
					3'b010: begin   WBsel=2'b01;RegWEn=1'b1; end
					3'b011: begin   WBsel=2'b01;RegWEn=1'b1; end
					3'b100: begin   WBsel=2'b01;RegWEn=1'b1; end
					3'b110: begin   WBsel=2'b01;RegWEn=1'b1; end
					3'b111: begin   WBsel=2'b01;RegWEn=1'b1; end
					3'b001: begin   WBsel=2'b01;RegWEn=1'b1; end
					3'b101:case(inst[30])
						1'b0: begin   WBsel=2'b01;RegWEn=1'b1; end
						default: begin   WBsel=2'b01;RegWEn=1'b1; end
						endcase
					default:begin   WBsel=2'b01;RegWEn=1'b1; end
				endcase
		7'b0000011:	case(inst[14:12])
					3'b000: begin   WBsel=2'b00;RegWEn=1'b1; end
					3'b001: begin   WBsel=2'b00;RegWEn=1'b1; end
					3'b010: begin   WBsel=2'b00;RegWEn=1'b1; end
					3'b100: begin   WBsel=2'b00;RegWEn=1'b1; end
					3'b101: begin   WBsel=2'b00;RegWEn=1'b1; end
					default: begin WBsel=2'b00;RegWEn=1'b1; end
				endcase
		7'b0100011:	case(inst[14:12])
					3'b000: begin   WBsel=2'b00;RegWEn=1'b0; end
					3'b001: begin   WBsel=2'b00;RegWEn=1'b0; end
					3'b010: begin   WBsel=2'b00;RegWEn=1'b0; end
					default:begin   WBsel=2'b00;RegWEn=1'b0; end
				endcase
		7'b1100011: begin  WBsel=2'b00;RegWEn=1'b0; end
		7'b0110111: begin  WBsel=2'b01;RegWEn=1'b1; end
		7'b0010111: begin  WBsel=2'b01;RegWEn=1'b1; end
		7'b1101111: begin  WBsel=2'b10;RegWEn=1'b1; end
		7'b1100111: begin  WBsel=2'b10;RegWEn=1'b1; end
		default: begin WBsel=2'b01;RegWEn=1'b1; end

		endcase
		end
	endmodule
/* verilator lint_on UNUSED */
