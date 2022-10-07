/* verilator lint_off DECLFILENAME */
/* verilator lint_off UNUSED */
/* verilator lint_off WIDTH */
/* verilator lint_off UNOPTFLAT */
module Target_predictor #(
/* verilator lint_on DECLFILENAME */
	parameter Cache_storage = 1023,
	parameter width = 10,
	parameter path_length = 32*6
) (
	output wire [31:0] PC_predict_o,

	input wire [10:1] Global_hist,
	input wire [32:1] Branch_address_update_iterative,
	input wire [32:1] Branch_address_update,
	input wire [31:0] PC_update, PC_in,
	input wire clk, PC_check, stall, en_1, en_2, en_2_miss
);
	wire [width:0] index_update, index;
	
	Target_cache #(
		.Cache_storage(Cache_storage),
		.width(width)
	) Target_cache (
		.PC_predict_o(PC_predict_o),
		.index(index),
		.index_update(index_update),
		.PC_update(PC_update),
		.en_1(PC_check),
		.clk(clk)
	);

	Sr_index #(
		.stage(3),
		.width_index(width)
	) Sr_index (
		.index_update(index_update),
		.index_predict(index),
		.clk(clk),
		.stall(stall)
	);
	
	wire [path_length:1] Branch_address_bits_iterative;
	wire [path_length:1] Branch_address_bits_true_1;
	
	Branch_address_reg_j #(
		.path_length(path_length)
	) Branch_address_reg_j (
		.Branch_address_bits_iterative(Branch_address_bits_iterative),
		.Branch_address_bits_true_1(Branch_address_bits_true_1),
		.Branch_address_update_iterative(Branch_address_update_iterative),
		.Branch_address_update(Branch_address_update),
		.clk(clk),
		.en_1(en_1),
		.en_2(en_2),
		.en_2_miss(en_2_miss),
		.stall(stall)
	);

	Index_component_j #(
		.path_length(path_length),
		.width_index(width)
	) Index_component_j (
		.Global_hist(Global_hist),
		.index(index),
		.PC_in(PC_in),
		.Branch_address_bits_iterative(Branch_address_bits_iterative)
	);
endmodule

module Target_cache #( //Tagless
	parameter Cache_storage = 255,
	parameter width = 8
) (
	output reg [31:0] PC_predict_o,
	
	input wire [width:1] index, index_update,
	input wire [31:0] PC_update,
	input wire en_1, clk
);
	reg [32:1] PC_predict [Cache_storage:0] ;
	
	initial begin
		for (int i=0; i <= Cache_storage; i=i+1) begin
			PC_predict[i] = 0;
		end
	end
	
	always @(posedge clk) begin
		if (en_1)
			PC_predict[index_update] <= PC_update;
		PC_predict_o <= PC_predict[index];
	end

endmodule

module Sr_index #(
	parameter stage = 3,
	parameter width_index = 8
) (
	output wire [width_index:1] index_update,

	input wire [width_index:1] index_predict,
	input wire clk, stall
);
	reg [stage*width_index:1] index = 0;

        assign index_update = index[width_index:1];

        always_ff @(negedge clk) begin
		if (stall == 1) begin
			index <= index;
		end else begin
                        index <= {index_predict, index[(stage-2)*width_index+1+:2*width_index]};
		end
	end
endmodule

module Index_component_j #(
	parameter path_length = 10*32,
	parameter width_index = 10
) (
	output reg [10:1] index,
 	
	input wire [10:1] Global_hist,
	input wire [path_length:1] Branch_address_bits_iterative,
	input wire [32:1] PC_in
);
	wire [path_length:1] Path_hist_iterative;
	assign Path_hist_iterative [path_length: path_length-31] = 0;

	generate
		for ( genvar i=path_length/32-1; i>=1; i=i-1) begin : generate_block_identifier
			assign	Path_hist_iterative [32*i-31+:32] = Path_hist_iterative [32*(i+1)-31+:32] ^ Branch_address_bits_iterative [32*i-31+:32];
		end
	endgenerate
	assign index = {Path_hist_iterative [8:3], PC_in[6:3]} ;
endmodule

module Branch_address_reg_j #(
	parameter path_length = 10*32
)
(
	output reg [path_length:1] Branch_address_bits_iterative,
	output wire [path_length:1] Branch_address_bits_true_1,

	input wire [32:1] Branch_address_update_iterative,   
	input wire [32:1] Branch_address_update,		// input of PC reg in CPU design
	input wire clk, en_1, en_2, en_2_miss, stall
);
	reg [path_length:1] Branch_address_bits_true = 0;	// reg two update only from result at EX
	

	initial Branch_address_bits_iterative = 0;
	assign Branch_address_bits_true_1 = Branch_address_bits_true;

	always @(negedge clk) begin
		if ((en_1 ==1)  && (en_2_miss == 0)&& (stall == 0))
			Branch_address_bits_iterative <= {Branch_address_update_iterative,Branch_address_bits_iterative[path_length:33]};
		else if (en_2_miss == 1)
			Branch_address_bits_iterative <= Branch_address_bits_true;
		else
			Branch_address_bits_iterative <= Branch_address_bits_iterative ;
		
	end
	always_ff @(negedge clk) begin
		if (en_2 ==1)
			Branch_address_bits_true <= {Branch_address_update, Branch_address_bits_true[path_length:33]};
		else
			Branch_address_bits_true <= Branch_address_bits_true;
		
	end
	

endmodule
/* verilator lint_on UNUSED */
/* verilator lint_on WIDTH */
/* verilator lint_on UNOPTFLAT */
