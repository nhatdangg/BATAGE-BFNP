`include "BATAGE.sv"
`include "BFNP.sv"
`include "Chooser_table.sv"
`include "Target_cache.sv"
/* verilator lint_off WIDTH */
/* verilator lint_off UNUSED */
module Hybrid_BPU #(
	parameter width_chooser = 3,
	parameter history_length = 1347
)
(
	output wire rst_pipeline_2, //overide of BATAGE
	output reg rst_pipeline_2_temp,
	output wire [3:1] weight_sr_o,
	output wire [4:1] num_table_final_o,
	output reg prediction_IF, 
	output wire hit_BTB, eq_ov_0,
	output wire [2:1] confidence_BATAGE,
	output reg rst_pipeline,
	output wire hit,
	output wire check,
	output reg [32:1] PC_predict_pre_IF,

	input wire Branch_direction,
	input wire [32:1] PC_predict_pre_IF2,
	input wire stall, hit_BTB2, 
	input wire [32:1] PC_actual,
	input wire [32:1] PC_alu,
	input wire [32:1] inst,
	input wire [32:1] PC_in, PC_in2,
	input wire [2:1] confidence_BATAGE2,
	input wire [3:1] weight_sr_o2,
	input wire [4:1] num_table_final_o2,
	input wire eq_ov_02,
	input wire clk, rst
);
	wire [32:1] PC_predict_pre_IF_BFNP, PC_predict_pre_IF_BATAGE,PC_predict_pre_IF_update;
	wire rst_pipeline_BFNP, rst_pipeline_BATAGE;	
	wire hit_BFNP, hit_BATAGE; 
	wire check_BFNP, check_BATAGE;
	wire prediction_BFNP, prediction_BATAGE;
	wire prediction_BFNP_update, prediction_BATAGE_update;
	wire PC_check, PC_check2, PC_check3;

	wire [9:1] total_weights_o;
	wire [2:1] confidence_BATAGE_update;
	wire uncont_predict;
	wire [32:1] PC_predict_o, PC_update/*, PC_predict_j*/;
	reg [32:1] PC_predict_o2, PC_predict_BATAGE2;
	reg prediction_BATAGE2, prediction_IF2, prediction_BFNP_temp;
	wire [history_length:1] Global_hist;
	wire [32:1] address_BATAGE_predict;
	reg condition = 0;
	reg [3:1] rst_pipeline_2_reg = 0;
	
	always @(negedge clk) begin
		PC_predict_o2 <= PC_predict_o;
		prediction_BATAGE2 <= prediction_BATAGE;
		PC_predict_BATAGE2 <= address_BATAGE_predict;
		prediction_IF2 <= prediction_IF;
		prediction_BFNP_temp <= prediction_BFNP;
	end
	/*Target_predictor Target_predictor (
		.PC_predict_o(PC_predict_j),

		.Global_hist(Global_hist),
		.Branch_address_update_iterative(PC_predict_j),
		.Branch_address_update(PC_actual),
		.PC_update(PC_actual),
		.clk(clk),
		.PC_check(PC_check2),
		.stall(stall),
		.en_1(uncont_predict),
		.en_2((PC_actual==PC_predict_pre_IF_update) && PC_check2),
		.en_2_miss((PC_actual!=PC_predict_pre_IF_update) && PC_check2),
		.PC_in(PC_in)
	);*/
	BF_neural_predictor BFNP (
		.PC_predict_pre_IF(PC_predict_pre_IF_BFNP),
		//.rst_pipeline(rst_pipeline_BFNP),	
		.hit(hit_BFNP), 
		.check(check_BFNP),
		.total_weights_o(total_weights_o), //absolute

		.hit_BTB(hit_BTB2),
		.prediction(prediction_BFNP),
		.PC_predict_o(PC_predict_o2),
		.PC_predict_BATAGE(PC_predict_BATAGE2),
		.prediction_BATAGE2(prediction_BATAGE2),			
		

		.stall(stall),
		.Branch_direction(Branch_direction),
		.PC_actual(PC_actual),
		.PC_alu(PC_alu),
		.inst(inst),
		.PC_in(PC_in2),
		.clk(clk), 
		.rst(rst),
		.PC_predict_hybrid(PC_predict_pre_IF2),
		.prediction_hybrid(prediction_IF2),
		.rst_pipeline_2(rst_pipeline_2)
	) ;
	BATAGE BATAGE (
		.Global_hist(Global_hist),
		.uncont_predict(uncont_predict),
		//.rst_pipeline(rst_pipeline_BATAGE),
		.hit(hit_BATAGE),
		.check(check_BATAGE),
		.PC_predict_pre_IF(PC_predict_pre_IF_BATAGE),
		.confidence_BATAGE(confidence_BATAGE),
		.confidence_BATAGE_update(confidence_BATAGE_update),
		.eq_ov_0(eq_ov_0),
		.num_table_final_o(num_table_final_o),
		.weight_sr_o(weight_sr_o),

		.Branch_direction(Branch_direction),
		.stall(stall),
		.PC_actual(PC_actual),
		.PC_alu(PC_alu),
		.inst(inst),
		.PC_in(PC_in),
		.clk(clk), 
		.rst(rst),

		.hit_BTB2(hit_BTB2),
		.rst_pipeline_2(rst_pipeline_2),
		.rst_pipeline_2_update(rst_pipeline_2_reg[1]),
		.hit_BTB(hit_BTB),
		.prediction_final(prediction_BATAGE),
		.PC_predict_o(PC_predict_o),
		.PC_update(PC_update),
		.rst_pipeline_hybrid(rst_pipeline),
		.PC_predict_hybrid(PC_predict_pre_IF2),
		.prediction_hybrid(prediction_IF2)
	);
	/*wire [width_chooser:1] choose_bit;
	wire [width_chooser:1] counter_update;
	reg [3*history_length:1] Global_hist_reg = 0;
	always @(negedge clk) begin
		Global_hist_reg <= {Global_hist, Global_hist_reg[3*history_length:history_length+1]};
	end
	Chooser_table #(
		.width_counter(width_chooser)
	) Chooser_table (
		.choose_bit(choose_bit),
		.index(PC_in[16:3]^Global_hist[history_length:history_length-13]
		^Global_hist[history_length-14:history_length-27]), 
		.index_update(PC_update[16:3]^^Global_hist_reg[history_length:history_length-13]
		^Global_hist_reg[history_length-14:history_length-27]),
		.counter_update(counter_update),
		.clk(clk), 
		.rst(rst),
		.en(rst_pipeline & condition)//rst_pipeline
	);
	wire [width_chooser:1] chooser_counter_update;
	wire prediction_update;
	Sr_chooser_prediction_counter #(
		.width_counter(width_chooser) 
	) Sr_chooser_prediction_counter (
		.chooser_counter_update(chooser_counter_update),
		.prediction_update(prediction_update),
		.PC_predict_pre_IF_update(PC_predict_pre_IF_update),
		.PC_predict_pre_IF(PC_predict_pre_IF),
		.chooser_counter(choose_bit),
        	.prediction(prediction), 
		.clk(clk), 
		.rst(rst), 
		.stall(stall)
	);
	
	Chooser_counter_update #(
		.width_counter(width_chooser)
	)Chooser_counter_update (
		.chooser_new(counter_update),
		.chooser_counter_update(chooser_counter_update),
		.Branch_direction(Branch_direction),
		.BATAGE_prediction(prediction_BATAGE_update), 
		.BFNP_prediction(prediction_BFNP_update)
	);*/
	
	assign rst_pipeline_BFNP = (prediction_BFNP_update != Branch_direction)  && PC_check;
	assign rst_pipeline_BATAGE = (prediction_BATAGE_update != Branch_direction)  && PC_check;
	
	
	wire prediction_update, prediction;
	wire [width_chooser:1] chooser_counter_update;
	
	assign prediction = prediction_IF;
	Sr_chooser_prediction_counter #(
		.width_counter(width_chooser) 
	) Sr_chooser_prediction_counter (
		.chooser_counter_update(chooser_counter_update),
		.prediction_update(prediction_update),
		.prediction_BATAGE_update(prediction_BATAGE_update),
		.prediction_BFNP_update(prediction_BFNP_update),
		.PC_predict_pre_IF_update(PC_predict_pre_IF_update),
		.PC_predict_pre_IF(PC_predict_pre_IF),
		.chooser_counter(0),
        	.prediction(prediction), 
        	.prediction_BATAGE(prediction_BATAGE),
        	.prediction_BFNP(prediction_BFNP),
		.clk(clk), 
		.rst(rst), 
		.stall(stall)
	);
	
	assign rst_pipeline_2 = ( ( (num_table_final_o2 == 0) /*&& ((weight_sr_o2 != 0) )*/|| eq_ov_02) &&
	((confidence_BATAGE2 == 2)/*||(confidence_BATAGE2 == 1) && (num_table_final_o2 == 0)*/
	) && ( prediction_BFNP != prediction_IF2 ) && hit_BTB2 && (total_weights_o>3)) ? 1 : 0;
	
	always @(negedge clk) begin
		if (rst_pipeline)
			rst_pipeline_2_temp <= 0;
		else
			rst_pipeline_2_temp <= rst_pipeline_2;
	end
	always @(negedge clk) begin
		rst_pipeline_2_reg <= {rst_pipeline_2_temp, rst_pipeline_2_reg[3:2]};
	end
	assign address_BATAGE_predict = (hit_BTB && prediction_BATAGE) ? PC_predict_o : PC_in + 4;
	
	always_comb begin // Prediction at pre IF
		if (rst_pipeline_2_temp) begin
			if ( (prediction_BFNP_temp == prediction_BATAGE) && hit_BTB) begin
				PC_predict_pre_IF = (prediction_BATAGE) ? PC_predict_o : PC_in + 4;
				prediction_IF = prediction_BATAGE;
			end else if (hit_BTB && prediction_BATAGE || !hit_BTB) begin
				PC_predict_pre_IF = PC_in + 4;
				prediction_IF = ~prediction_BATAGE;
			end else begin 
				PC_predict_pre_IF = PC_predict_o;
				prediction_IF = ~prediction_BATAGE;
			end
		end else begin
			if (hit_BTB && prediction_BATAGE) begin
				PC_predict_pre_IF = PC_predict_o;
				prediction_IF = prediction_BATAGE;
			end else begin
				PC_predict_pre_IF = PC_in + 4;
				prediction_IF = prediction_BATAGE;
			end
		end
	end
	
	
	
	/*
	wire bp_pick; //1 BATAGE, 0 BFNP
	Mux_prediction_hybrid #(
		.width_counter(width_chooser)
	) Mux_prediction_hybrid (
		.bp_pick(bp_pick),
		.uncont_predict(0),//uncont_predict
		.PC_predict_j(0/*PC_predict_j*//*),
	/*	.prediction(prediction),
		.PC_predict_pre_IF(PC_predict_pre_IF),
		.BATAGE_prediction(prediction_BATAGE), 
		.BFNP_prediction(prediction_BFNP), 
		.chooser({1'b0,confidence_BATAGE}), 
		.hit_BTB(hit_BTB),
		.PC_predict_o(PC_predict_o), 
		.PC_in (PC_in),
		.total_weights(total_weights_o),
		.condition(condition),
		.eq_ov_0(eq_ov_0),
		.num_table_final_o(num_table_final_o),
		.weight_sr_o(weight_sr_o)
	);*/
	
	
	assign PC_check = (inst[7:1] == 7'b1100011)||(inst[7:1] == 7'b1101111)||(inst[7:1] == 7'b1100111);
	assign PC_check2 = (inst[7:1] == 7'b1100111);
	assign PC_check3 = (inst[7:1] == 7'b1100011);
	
	reg [31:0] counter = 0;
	always @(posedge clk) begin
		counter <= counter + 1;
	end
	
	
	always @(posedge clk) begin
		if (counter == 20000)
			condition <= 1;
	end
	always_comb begin
	//	if ( ( rst_pipeline_BFNP && (confidence_BATAGE_update != 0)
	//	|| rst_pipeline_BATAGE && (confidence_BATAGE_update == 0)) && !condition)
	//		rst_pipeline = 1;
	/*	if ( !condition && rst_pipeline_BATAGE )
			rst_pipeline = 1;
		else*/ if ((prediction_update == Branch_direction) && (PC_actual==PC_predict_pre_IF_update) && PC_check)
			rst_pipeline = 0;
		else if (PC_check == 0)
			rst_pipeline = 0;
		else
			rst_pipeline = 1;
	end
//	always_comb begin
//		if ((prediction_update == Branch_direction) && (PC_actual==PC_predict_pre_IF_update) && PC_check) begin
//			rst_pipeline = 0;
//		end
//		else if (PC_check == 0) begin
//			rst_pipeline = 0;
//		end
//		else begin
//			rst_pipeline = 1;
//		end	
//	end
	assign check = rst_pipeline;
	assign hit = hit_BTB;
endmodule
/* verilator lint_on UNUSED */
/* verilator lint_on WIDTH */
