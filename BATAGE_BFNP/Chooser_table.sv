`include "processor_specific_macros.h"
/* verilator lint_off UNUSED */
/* verilator lint_off DECLFILENAME */
/*module Chooser_table #(
	parameter width_counter = 2,
	parameter Table_length = 16383
)
(
	output reg [width_counter:1] choose_bit,

	input wire [32:1] index, index_update,
	input wire [width_counter:1] counter_update,
	input wire clk, rst, en
);
	reg [width_counter:1] Chooser_counter [Table_length:0];
	
	wire [14:1] index_1;
	wire [14:1] index_update_1;

	assign index_1 = index [14:1];
	assign index_update_1 = index_update [14:1];

	initial begin
		for (int i=0; i<=Table_length; i=i+1) begin
			Chooser_counter[i] = 3;
		end
	end
	always @(posedge clk) begin
		if (en)
			Chooser_counter [index_update_1] <= counter_update;
		choose_bit <= Chooser_counter [index_1];
	end

	
endmodule*/

module Sr_chooser_prediction_counter #(
	parameter stage = 3,
	parameter stage_2 = 2,
	parameter width_prediction = 1,
	parameter width_counter = 2
)
(
	output wire [width_counter:1] chooser_counter_update,
	output wire prediction_update, prediction_BATAGE_update, prediction_BFNP_update,
	output wire [32:1] PC_predict_pre_IF_update,
	input wire [width_counter:1] chooser_counter,
	input wire [32:1] PC_predict_pre_IF,
        input wire prediction, clk, rst, stall, prediction_BATAGE, prediction_BFNP	
);
	reg [stage*width_prediction:1] prediction_BATAGE_reg;
	reg [stage*width_prediction:1] prediction_reg, prediction_BFNP_reg;
	reg [stage*width_counter:1] counter_reg;
	reg [stage*32:1] PC_predict_reg;

	assign prediction_update = prediction_reg[1];
	assign prediction_BATAGE_update = prediction_BATAGE_reg[1];
	assign prediction_BFNP_update = prediction_BFNP_reg[1];
	assign chooser_counter_update = counter_reg[width_counter:1];
	assign PC_predict_pre_IF_update = PC_predict_reg [32:1];
	always_ff @(negedge clk) begin
                if (rst == 1) begin
                	prediction_BFNP_reg <= 0;
                	prediction_BATAGE_reg <= 0;
                        prediction_reg <= 0;
                        counter_reg <= 0;
			PC_predict_reg <= 0;
                end
                else begin
                        if (stall == 1) begin
                        	prediction_BFNP_reg <= prediction_BFNP_reg;
                		prediction_BATAGE_reg <= prediction_BATAGE_reg;
                                prediction_reg <= prediction_reg;
                                counter_reg <= counter_reg;
				PC_predict_reg <= PC_predict_reg;
                        end
                        else begin
                        	prediction_BFNP_reg <= {prediction_BFNP, prediction_BFNP_reg [(stage-2)*width_prediction+1+:2*width_prediction]};
                        	prediction_BATAGE_reg <= {prediction_BATAGE, prediction_BATAGE_reg [(stage-2)*width_prediction+1+:2*width_prediction]};
                                prediction_reg <= {prediction, prediction_reg [(stage-2)*width_prediction+1+:2*width_prediction]};
                                counter_reg <= {chooser_counter, counter_reg [(stage-2)*width_counter+1+:2*width_counter]};
				PC_predict_reg <=  {PC_predict_pre_IF, PC_predict_reg [(stage-2)*32+1+:2*32]};
                      
			end
                end
        end
endmodule

/*module Chooser_counter_update #(
	parameter width_counter = 2
)
(
	output reg [width_counter:1] chooser_new,

	input wire [width_counter:1] chooser_counter_update,
	input wire Branch_direction,
	input wire BATAGE_prediction, BFNP_prediction
);
	always_comb begin 
		if (BFNP_prediction != BATAGE_prediction) begin
			if (Branch_direction == BFNP_prediction) begin
				case (chooser_counter_update) 
					3'd3: chooser_new =  3'd3;
					default: chooser_new = $signed(chooser_counter_update) + 1;
				endcase
			end
			else if (Branch_direction == BATAGE_prediction) begin
				case (chooser_counter_update)
        	                        3'd4: chooser_new = 3'd4; //2
        	                        default: chooser_new = $signed(chooser_counter_update) - 1; //2
                	        endcase
			end
			else begin
				chooser_new = chooser_counter_update;
			end
		end else begin
			chooser_new = chooser_counter_update;
//			case (chooser_counter_update) 
//					3'd3: chooser_new =  3'd3;
//					default: chooser_new = $signed(chooser_counter_update) + 1;
//			endcase
			
		end
	end
endmodule*/

module Mux_prediction_hybrid #(
	parameter width_counter = 2
)(
	output reg bp_pick,
	output reg prediction,
	output reg [32:1] PC_predict_pre_IF,
	input wire [width_counter:1] chooser,
	input wire BATAGE_prediction, BFNP_prediction, hit_BTB, uncont_predict,
	input wire [32:1] PC_predict_o, PC_in, PC_predict_j,
	input wire [9:1] total_weights,
	input wire condition, eq_ov_0,
	input wire [4:1] num_table_final_o,
	input wire [3:1] weight_sr_o
);
	wire [9:1] total_weights_abs = (total_weights & {9{~total_weights[9]}}) | (~total_weights & {9{total_weights[9]}}) ; 
	always_comb begin 
		if ( (chooser != 2) ) begin  
			prediction = BATAGE_prediction;
			bp_pick = 1;
		end else if  ( ( (total_weights_abs >= `L1) && (total_weights_abs <= `L2)) &&
		( (num_table_final_o == 0) && (/*(weight_sr_o == -2) || */(weight_sr_o != 0) )|| eq_ov_0 /* && (weight_sr_o != 0)*/ )) begin
			prediction = BFNP_prediction;
			bp_pick = 0;
		end else begin
			prediction = BATAGE_prediction;
			bp_pick = 1;
		end
	end
	
	always_comb begin
		if (uncont_predict)
			PC_predict_pre_IF = PC_predict_j;
		else if (hit_BTB & prediction)
			PC_predict_pre_IF = PC_predict_o;
		else 
			PC_predict_pre_IF = PC_in+4;
	end
endmodule
/* verilator lint_on UNUSED */
/* verilator lint_on DECLFILENAME */
