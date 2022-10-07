module PC (clk,oldPC, newPC, stall, signal);
	input clk, stall, signal;
	input [31:0] oldPC;
	output reg [31:0] newPC;
	always_ff @(negedge clk) begin
		if (signal)
			newPC <= oldPC;
		else begin
			if (stall == 1)
				newPC <= newPC;
			else
				newPC <= oldPC;
		end
	end
endmodule
