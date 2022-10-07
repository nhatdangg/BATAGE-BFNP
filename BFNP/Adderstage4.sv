module Adderstage4 (oldPC, newPC);
	input wire [31:0] oldPC;
	output wire [31:0] newPC;
	assign newPC=oldPC+4;
endmodule
