module AdderPC (oldPC ,newPC);
	input wire [31:0] oldPC;
	output reg [31:0] newPC;
	always_comb begin
	 	newPC=oldPC+4;
	end
endmodule
