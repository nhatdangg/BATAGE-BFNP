`timescale 1ps/1ps
`include "Arith_Neural_BPU.sv"
/* verilator lint_off DECLFILENAME */
module BF_neural_predictor (
/* verilator lint_on DECLFILENAME */
	output wire [32:1] PC_predict_pre_IF,
	output wire rst_pipeline,	
	output wire hit, 
	output wire check,

	input wire stall,
	input wire Branch_direction,	
	input wire [32:1] PC_actual,
	input wire [32:1] PC_alu,
	input wire [32:1] inst,
	input wire [32:1] PC_in,
	input wire prediction_hb, hit_hb,
	input wire clk, rst
) ;

	//For testing
	/* verilator lint_off UNUSED */
	wire [96:1] PC_in_update;//careful
//	reg [32:1] PC_in_1;
	wire [32:1] PC_in_wire;
	assign PC_in_wire = PC_in;
        Sr_PC_in Sr_PC_in ( .PC_in_update(PC_in_update), .PC_in (PC_in_wire), .clk(clk), .rst(rst), .stall(stall));

	//Branch_status_table signal	en_1
	wire [2:1] status;
	wire  [32:1] PC_predict_o;

	wire [2:1] status_update;
	wire [32:1] PC_predict_update;
	
	/* verilator lint_off UNOPTFLAT */
       	wire en_1, en_2;
	/* verilator lint_on UNOPTFLAT */

	Branch_status_table Branch_status_table ( .status(status), .PC_predict_o(PC_predict_o), .status_update(status_update), .PC_in(PC_in), .PC_update(PC_in_update[32:1]), .PC_predict_update(PC_predict_update), .clk(clk), .en_1(en_1), .RST(rst));

	wire [6:1] status_update_reg;
	wire [96:1] address_update;

	Sr_BST_status_address Sr_BST_status_address ( .status_update(status_update_reg), .address_update(address_update), .status(status), .address(PC_predict_o), .clk(clk), .rst(rst), .stall(stall));

	//Bias_weight_table en_1 | en_2
	wire [2:1] weight;
	wire [6:1] weight_update;  //output of reg
	wire [2:1] weight_update_2; //output of update component

	Bias_weight_table Bias_weight_table ( .weight(weight), .index(PC_in[10:1]), .index_update(PC_in_update[10:1]), .weight_update(weight_update_2), .en_1(en_1|en_2), .clk(clk), .RST(rst));

	Sr_Bias_weight Sr_Bias_weight ( .weight_update(weight_update), .weight(weight), .clk(clk), .rst(rst), .stall(stall));

	//Perceptron_table en_1 | en_2
	wire [48:1] perceptron_weights;
	wire [144:1] perceptron_weights_update; //output of reg
	wire [48:1] perceptron_weights_update_2;
	wire [480:1] perceptron_address_update;
        wire [160:1] perceptron_address;

	
	Perceptron_table Perceptron_table ( .perceptron_weights(perceptron_weights), .index(perceptron_address), .index_update(perceptron_address_update[160:1]), .perceptron_weights_update (perceptron_weights_update_2), .clk(clk), .en_1(en_1|en_2), .RST(rst));

	Sr_perceptron_address Sr_perceptron_address (.perceptron_address_update(perceptron_address_update), .perceptron_address(perceptron_address), .clk(clk), .rst(rst), .stall(stall));

	Sr_perceptron_weight Sr_perceptron_weight ( .perceptron_weights_update(perceptron_weights_update), .perceptron_weights(perceptron_weights) ,.clk(clk), .rst(rst), .stall(stall));

	//Perceptron_table_BF en_2
	
	wire [144:1] perceptron_weights_BF;
	wire [480:1] perceptron_address_BF;
   wire [480*3:1] perceptron_address_update_BF;
	wire [432:1] perceptron_weights_update_BF; //output of reg
	wire [144:1] perceptron_weights_update_BF_2; //output of update component

	Perceptron_table_BF Perceptron_table_BF ( .perceptron_weights(perceptron_weights_BF) , .index(perceptron_address_BF), .index_update(perceptron_address_update_BF[480:1]), .perceptron_weights_update(perceptron_weights_update_BF_2), .clk(clk), .en_1(en_2), .RST(rst));

	Sr_perceptron_address_BF Sr_perceptron_address_BF ( .perceptron_address_update(perceptron_address_update_BF), .perceptron_address(perceptron_address_BF), .clk(clk), .rst(rst), .stall(stall));

	Sr_perceptron_weight_BF Sr_perceptron_weight_BF ( .perceptron_weight_update(perceptron_weights_update_BF), .perceptron_weight(perceptron_weights_BF), .clk(clk), .rst(rst), .stall(stall));

	//Arith for prediction
	wire [48:1] weights_GHR;
	wire [16:1] GHR_reg;
	Mul_perceptron_GHR Mul_perceptron_GHR( .weights(weights_GHR), .GHR_reg(GHR_reg), .perceptron_weights(perceptron_weights));

	wire [144:1] weights_RS;
	wire [48:1] RS_H;
	Mul_perceptron_RS_H Mul_perceptron_RS_H( .weights(weights_RS), .RS_H(RS_H), .RS_weights(perceptron_weights_BF));

	wire [9:1] total_weights;
	Perceptron_add Perceptron_add ( .total_weights(total_weights), .weight_perceptron_conv(weights_GHR), 
		.weight_perceptron_rs(weights_RS), .bias(weight), .prediction_hb(prediction_hb), .hit_hb(hit_hb) );
	
	wire prediction;
	Mux_prediction Mux_prediction ( .prediction(prediction), .total_weights_sign_bit(total_weights[9]), .bst_status(status));

	wire [3:1] prediction_update;
	Sr_prediction Sr_prediction ( .prediction_update(prediction_update), .prediction(prediction), .clk(clk), .rst(rst), .stall(stall) );
	
	wire [27:1] total_weights_update;
	Sr_total_weights Sr_total_weights ( .total_weights_update(total_weights_update), .total_weights(total_weights), .clk(clk), .rst(rst), .stall(stall));

	wire [48:1] GHR_reg_update;
	Sr_GHR_reg Sr_GHR_reg ( .GHR_reg_update(GHR_reg_update), .GHR_reg(GHR_reg), .clk(clk), .rst(rst), .stall(stall));

	wire [144:1]RS_H_update; 
	Sr_RS_H Sr_RS_H ( .RS_H_update(RS_H_update), .RS_H(RS_H), .clk(clk), .rst(rst), .stall(stall));
	//Update component
//	wire rst_pipeline;
	wire en_2_reg, en_2_reg_BF;
//	reg Branch_direction;
//	reg [32:1] inst;
//	reg [32:1] PC_actual;
//	reg [32:1] PC_alu;
	wire [32:1] PC_predict;
	//PC_predict need mux
	assign PC_predict_update=PC_alu;
	
	BST_update BST_update ( .status_update(status_update), .en_2_reg(en_2_reg), .en_2_reg_BF(en_2_reg_BF), .en_2(en_1), .en_3(en_2), .rst(rst_pipeline), .Branch_direction(Branch_direction), .Branch_prediction(prediction_update[1]), .inst(inst), .PC_predict(PC_predict), .PC_actual(PC_actual), .PC_alu(PC_alu), .old_status(status_update_reg[2:1]), .total_weights_update(total_weights_update[9:1]), .clk(clk));

	Bias_update Bias_update ( .bias_update(weight_update_2), .bias(weight_update[2:1]), .branch_direction(Branch_direction));
	
	Perceptron_update Perceptron_update ( .weight_update(perceptron_weights_update_2), .weight(perceptron_weights_update[48:1]) , .branch_direction(Branch_direction), .GHR(GHR_reg_update[16:1]));

	Perceptron_update_BF Perceptron_update_BF( .weight_update(perceptron_weights_update_BF_2), .weight(perceptron_weights_update_BF[144:1]), .branch_direction(Branch_direction), .RS(RS_H_update[48:1]));

	//For simulation
	wire [32:1] PC_predict_IF;	
	wire [96:1] PC_in_predict;
	Mux_prediction_address Mux_prediction_address ( .PC_predict(PC_predict_IF), .PC_nottaken(PC_in), .PC_taken(PC_predict_o), .prediction(prediction));
	Sr_PC_predict Sr_PC_predict ( .PC_in_predict(PC_in_predict), .PC_in(PC_predict_IF), .clk(clk), .rst(rst), .stall(stall));

	//Register index
	wire [160:1] Branch_address_iterative;
	wire en_2_miss;
	assign en_2_miss = en_2 | en_1;

	Branch_address_reg Branch_address_reg ( .Branch_address_iterative(Branch_address_iterative), .Branch_address_update_iterative(PC_predict_IF[10:1]), .Branch_address_update(PC_actual[10:1]), .clk(clk), .en_1(status[1]|status[2]), .en_2(en_2_reg), .en_2_miss(en_2_miss), .rst(rst), .stall(stall));

	wire [160:1] Folded_hist_iterative,Folded_hist_true_1;
	Folded_hist_reg Folded_hist_reg ( .Folded_hist_iterative(Folded_hist_iterative), .Folded_hist_update_iterative(prediction), .Folded_hist_update(Branch_direction), .clk(clk), .en_1(status[1]|status[2]), .en_2(en_2_reg), .en_2_miss(en_2_miss), .rst(rst), .Folded_hist_true_1(Folded_hist_true_1), .stall(stall));

	//Register_index_BF
	wire [10:1] Stack_branch_iterative [48:1];
	wire [48:1] Folded_hist_iterative_BF;
	wire [6:1] Pos_iterative[48:1];
	Branch_address_folded_hist_reg_pos_BF Branch_address_folded_hist_reg_pos_BF( .Stack_branch_iterative(Stack_branch_iterative), .Branch_address_update_iterative(PC_predict_IF[10:1]), .Branch_address_update(PC_actual[10:1]), .clk(clk), .en_1(status[1]&status[2]), .en_2(en_2_reg_BF), .Folded_hist_iterative(Folded_hist_iterative_BF), .Folded_hist_update_iterative(prediction), .Folded_hist_update(Branch_direction), .Pos_iterative(Pos_iterative), .Pos_update_iterative(6'd0), .Pos_update(6'd0), .en_2_miss(en_2), .rst(rst), .stall(stall));
	
	//Index_perceptron
	
	index_perceptron index_perceptron ( .index(perceptron_address), .PC(PC_in[10:1]), .Branch_address_iterative(Branch_address_iterative), .Folded_hist_iterative(Folded_hist_iterative));
	index_perceptron_BF index_perceptron_BF ( .index(perceptron_address_BF), .PC(PC_in[10:1]), .Branch_address_iterative(Stack_branch_iterative), .Folded_hist_iterative(Folded_hist_iterative_BF), .Pos_iterative(Pos_iterative) );

	assign PC_predict = PC_in_predict [32:1];
	assign GHR_reg = Folded_hist_iterative [160:145];
	assign RS_H = Folded_hist_iterative_BF;
	
	//Ouput signal to muxpc
	assign hit = status[2]|status[1];
	assign PC_predict_pre_IF = PC_predict_IF;
	assign check = en_1 | en_2;
	/* verilator lint_on UNUSED */

//	always begin
//		clk=0;
//		forever #20 clk=~clk;
//	end
//
//	initial begin
//		rst = 1;
//		#60 rst = 0;
//	end
//	//PC_in,Branch_direction,inst,PC_alu,PC_actual
//
//	initial begin
//		PC_actual <=2;
//		PC_alu <= 0;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 0;
//		#40
//		PC_actual <=2;
//		PC_alu <=0;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 4;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 8;
//		#40
//		PC_actual <=2;
//		PC_alu<=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 12;
//		#40 
//		PC_actual <=2;
//		PC_alu<=3;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 16;
//		#40
//		PC_actual <=16;
//		PC_alu<= 16;
//		Branch_direction <=1'b1;
//		inst <=32'h00000063;
//		PC_in <= 20;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 8;
//		#40
//		PC_actual <= 2;
//		PC_alu <= 2;
//		Branch_direction <=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 16;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 20;
//		#40
//		PC_actual <=16;
//		PC_alu <=16;
//		Branch_direction<=1'b1;
//		inst<=32'h00000063;
//		PC_in <= 24;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 28;
//		#40
//		PC_actual <=8;
//		PC_alu <=8;
//		Branch_direction<=1'b1;
//		inst<=32'h00000063;
//		PC_in <= 32;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 20;
//		#40
//		PC_actual <=6;
//		PC_alu <=6;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 8;
//		#40
//		PC_actual <=6;
//		PC_alu <=6;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 16;
//		#40
//		PC_actual <=8;
//		PC_alu <=8;
//		Branch_direction<=1'b1;
//		inst<=32'h00000063;
//		PC_in <= 20;
//		#40
//		PC_actual <=8;
//		PC_alu <=20;
//		Branch_direction<=1'b0;
//		inst<=32'h00000063;
//		PC_in <= 8;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 8;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 12;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 16;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000063;
//		PC_in <= 20;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 8;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 16;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000063;
//		PC_in <= 20;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 20;
//		#40
//		PC_actual <=2;
//		PC_alu <=2;
//		Branch_direction<=1'b0;
//		inst<=32'h00000033;
//		PC_in <= 24;
//	end	
endmodule

