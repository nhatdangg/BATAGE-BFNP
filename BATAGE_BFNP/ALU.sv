module ALU(rs1,rs2,alusel,rd);
	input wire [3:0] alusel;
	input wire [31:0] rs1;
	input wire [31:0] rs2;
	output reg [31:0] rd;
	always_comb begin
		case(alusel)	
			4'b0000: rd = rs1 + rs2;
			4'b0001: rd = rs1 - rs2;
			4'b0010: rd = rs1 << rs2;
			4'b0011: rd = ($signed(rs1) < $signed(rs2))?1:0; //signed
			4'b0100: rd = (rs1 < rs2)?1:0; //unsigned
			4'b0101: rd = rs1 ^ rs2;
			4'b0110: rd = rs1 >> rs2; //srl
			4'b0111: rd = $signed(rs1) >>> rs2; //sra arithmetic
			4'b1000: rd = rs1 | rs2;
			4'b1001: rd = rs1 & rs2;
			4'b1010: rd = rs2;
			4'b1011: rd = rs1 + rs2 + 4;
			default: rd = 0;
		endcase
	end
endmodule

