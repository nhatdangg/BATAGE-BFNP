/* verilator lint_off UNUSED */
module Stall_component (
	output reg stall,
	output reg en,

	input wire [31:0] inst1, inst2
);
	reg [1:0] count_1;
	reg D_1,D_2,D_3,B_1,B_2,D_4,D_5;
	assign D_1 = (inst2[6:0]==7'b0000011) && (inst1[6:0]==7'b0110011); // Load then S type
	assign D_2 = (inst2[6:0]==7'b0000011) && (inst1[6:0]==7'b0100011); // Load then store
	assign D_3 = (inst2[6:0]==7'b0000011) && (inst1[6:0]==7'b0010011); // Load then I type
	assign D_4 = (inst2[6:0]==7'b0000011) && (inst1[6:0]==7'b1100011); // Load then Branch
	assign D_5 = (inst2[6:0]==7'b0000011) && (inst2[6:0]==7'b0000011); // Load then Load
	//assign D_5 = (inst2[6:0]==7'b0110011) && (inst1[6:0]==7'b0000011); // Store then Load type
	assign B_1 = (inst2[11:7]==inst1[19:15]);
	assign B_2 = (inst2[11:7]==inst1[24:20]);
	always_comb begin
		if (((D_1)||(D_2)||(D_4))&&(~D_3)) begin
			if (B_1||B_2) begin
				en = 0;
				stall = 1;
			end
			else begin
				en = 1;
				stall = 0;
			end
		end
		else if (D_3||D_5) begin
			if (B_1) begin
				en = 0;
				stall = 1;
			end
			else begin
				en = 1;
				stall = 0;
			end
		end
		else begin
			en = 1;
			stall = 0;
		end
	end
endmodule
/* verilator lint_on UNUSED */
