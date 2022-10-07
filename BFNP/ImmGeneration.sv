module ImmGeneration(inst,ImmSel,imm);
	input wire [24:0] inst;
	input wire [2:0] ImmSel;
	output reg [31:0] imm;
	
	always_comb begin
		case (ImmSel)
			3'b000: imm = 32'd0;
			3'b001: imm = {{20{inst[24]}},inst[24:13]};
			3'b010: imm = {{27{1'b0}},inst[17:13]};
			3'b011: imm = {{20{inst[24]}},inst[24:18],inst[4:0]};
			3'b100: imm = {{20{inst[24]}},inst[0],inst[23:18],inst[4:1],1'b0};
			3'b101: imm = {inst[24:5],12'd0};
			3'b110: imm = {{12{inst[24]}},inst[12:5],inst[13],inst[23:14],1'b0};
			default: imm = 0;
		endcase
	end
endmodule
