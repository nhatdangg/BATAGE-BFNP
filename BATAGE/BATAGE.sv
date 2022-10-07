`include "Arith_BATAGE.sv"
module BATAGE #(
	parameter BTB_storage = 16383,
	parameter Index_width_BTB = 14,
        parameter Tag_width_BTB = 16,
	parameter T0_storage = 16383,
        parameter index_width_T0 = 14,
	parameter T1_storage = 2047, //18 bit index, 11 bit address, 7 bit tag, 2K storage
	parameter T1_address_width = 18,
	parameter Tag_width_1 = 7,
	parameter index_width_1 = 11,
	parameter path_length_1 = 6,
	parameter history_length_1 = 6,
	parameter T2_storage = 2047,     //20 bit index, 11 bit address, 9 bit tag, 2K storage
        parameter T2_address_width = 20,
        parameter Tag_width_2 = 9,
	parameter index_width_2 = 11,
        parameter path_length_2 = 10,
        parameter history_length_2 = 10,
	parameter T3_storage = 2047,     //20 bit index, 11 bit address, 9 bit tag, 2K storage
        parameter T3_address_width = 20,
        parameter Tag_width_3 = 9,
	parameter index_width_3 = 11,
        parameter path_length_3 = 18,
        parameter history_length_3 = 18,
	parameter T4_storage = 4095,     //21 bit index, 12 bit address, 9 bit tag, 4K storage
        parameter T4_address_width = 21,
        parameter Tag_width_4 = 9,
	parameter index_width_4 = 12,
        parameter path_length_4 = 25,
        parameter history_length_4 = 25,
	parameter T5_storage = 2047,     //21 bit index, 11 bit address, 10 bit tag, 2K storage
        parameter T5_address_width = 21,
        parameter Tag_width_5 = 10,
	parameter index_width_5 = 11,
        parameter path_length_5 = 27,
        parameter history_length_5 = 35,
	parameter T6_storage = 2047,     //22 bit index, 11 bit address, 11 bit tag, 2K storage
        parameter T6_address_width = 22,
        parameter Tag_width_6 = 11,
	parameter index_width_6 = 11,
        parameter path_length_6 = 29,
        parameter history_length_6 = 55,
	parameter T7_storage = 2047,     //22 bit index, 11 bit address, 11 bit tag, 2K storage
        parameter T7_address_width = 22,
        parameter Tag_width_7 = 11,
	parameter index_width_7 = 11,
        parameter path_length_7 = 30,
        parameter history_length_7 = 69,
	parameter T8_storage = 2047,     //23 bit index, 11 bit address, 12 bit tag, 2K storage
        parameter T8_address_width = 23,
        parameter Tag_width_8 = 12,
	parameter index_width_8 = 11,
        parameter path_length_8 = 32,
        parameter history_length_8 = 105,
	parameter T9_storage = 2047,     //23 bit index, 11 bit address, 12 bit tag, 2K storage
        parameter T9_address_width = 23,
        parameter Tag_width_9 = 12,
	parameter index_width_9 = 11,
        parameter path_length_9 = 34,
        parameter history_length_9 = 155,
	parameter T10_storage = 1023,     //22 bit index, 10 bit address, 12 bit tag, 1K storage
        parameter T10_address_width = 22,
        parameter Tag_width_10 = 12,
	parameter index_width_10 = 10,
        parameter path_length_10 = 36,
        parameter history_length_10 = 230,
	parameter T11_storage = 1023,     //23 bit index, 10 bit address, 13 bit tag, 1K storage
        parameter T11_address_width = 23,
        parameter Tag_width_11 = 13,
	parameter index_width_11 = 10,
        parameter path_length_11 = 39,
        parameter history_length_11 = 354,
	parameter T12_storage = 1023,     //24 bit index, 10 bit address, 14 bit tag, 1K storage
        parameter T12_address_width = 24,
        parameter Tag_width_12 = 14,
	parameter index_width_12 = 10,
        parameter path_length_12 = 41,
        parameter history_length_12 = 479,
	parameter T13_storage = 511,     //24 bit index, 9 bit address, 15 bit tag, 512 storage
        parameter T13_address_width = 24,
        parameter Tag_width_13 = 15,
	parameter index_width_13 = 9,
        parameter path_length_13 = 43,
        parameter history_length_13 = 642,
	parameter T14_storage = 255,     //23 bit index, 8 bit address, 15 bit tag, 2K storage
        parameter T14_address_width = 23,
        parameter Tag_width_14 = 15,
	parameter index_width_14 = 8,
        parameter path_length_14 = 45,
        parameter history_length_14 = 1012,
	parameter T15_storage = 255,     //23 bit index, 8 bit address, 15 bit tag, 255 bit storage
        parameter T15_address_width = 23,
        parameter Tag_width_15 = 15,
	parameter index_width_15 = 8,
        parameter path_length_15 = 48,
        parameter history_length_15 = 1347,
	parameter width_confidence = 2,
	parameter width_num_table = 4,
	parameter width_Taken = 3,
	parameter num_table = 16,
	parameter num_table_tagged = 15,
	parameter path_length = 49*32,//27
	parameter history_length = 1347
)
(
	output wire rst_pipeline,
	output wire hit,
	output wire check,
	output wire [32:1] PC_predict_pre_IF,

	input wire Branch_direction,
	input wire stall,
	input wire [32:1] PC_actual,
	input wire [32:1] PC_alu,
	input wire [32:1] inst,
	input wire [32:1] PC_in,
	input wire clk, rst
);
//	reg Branch_direction;
//	reg stall;
//	reg [32:1] PC_actual;
//	reg [32:1] PC_alu;
//	reg [32:1] inst;
//	reg [32:1] PC_in;
//	reg clk,rst;
	wire en_1_BTB, en_1_tagless;
	wire [num_table_tagged:1] en_1_tagged;
	wire [num_table_tagged:1] allocation;

	// BTB
	wire [32:1] PC_predict_o;
        wire hit_BTB;
       	wire [32:1] PC_update;
	wire [32-Tag_width_BTB:1] index_BTB_update;

	assign hit = hit_BTB;
	assign check = rst_pipeline;		
	assign index_BTB_update = PC_update[32-Tag_width_BTB:1];
	assign en_1_BTB = rst_pipeline;
	Branch_target_buffer #( BTB_storage, Tag_width_BTB) Branch_targer_buffer (
		.clk(clk),
		.rst(rst),
		.en_1(en_1_BTB),
		.PC_in(PC_in),
		.PC_update(PC_update),
		.index_BTB_update(index_BTB_update),
		.PC_predict_update(PC_alu),
		.hit(hit_BTB),
		.PC_predict_o(PC_predict_o)
	);	
	
	//Base_predictor
	wire [3:1] weight;
        wire [3:1] weight_update;
        wire [index_width_T0:1] index;
        wire [index_width_T0:1] index_update;

	assign index = PC_in[14:1];
	Base_predictor #( T0_storage, index_width_T0) Base_predictor (
	       .weight(weight),
	       .weight_update(weight_update),
	       .index(index),
	       .index_update(index_update),
	       .en_1(en_1_tagless),
	       .rst(rst), 
	       .clk(clk)
	);

	//Tagged predictor 15 table
	//Table 1
	wire [3:1] Taken_update_1, NTaken_update_1;
	wire [T1_address_width:1] index_1, index_update_1;
	wire [Tag_width_1:1] Tag_1;
	wire [3:1] Taken_1, NTaken_1;
	Tagged_predictor #( T1_storage, T1_address_width, Tag_width_1 ) Tagged_predictor_1 (
		.clk(clk),
		.rst(rst),
		.en_1(en_1_tagged[1]),
		.allocation(allocation[1]),
		.Taken_update(Taken_update_1),
		.NTaken_update(NTaken_update_1),
		.index(index_1),
		.index_update(index_update_1),
		.Tag(Tag_1),
		.Taken(Taken_1),
		.NTaken(NTaken_1)
	);
	//Table 2
	wire [3:1] Taken_update_2, NTaken_update_2;
	wire [T2_address_width:1] index_2, index_update_2;
	wire [Tag_width_2:1] Tag_2;
	wire [3:1] Taken_2, NTaken_2;
	Tagged_predictor #( T2_storage, T2_address_width, Tag_width_2 ) Tagged_predictor_2 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[2]),
                .allocation(allocation[2]),
		.Taken_update(Taken_update_2),
                .NTaken_update(NTaken_update_2),
                .index(index_2),
                .index_update(index_update_2),
                .Tag(Tag_2),
                .Taken(Taken_2),
                .NTaken(NTaken_2)
        );
	//Table 3
        wire [3:1] Taken_update_3, NTaken_update_3;
        wire [T3_address_width:1] index_3, index_update_3;
        wire [Tag_width_3:1] Tag_3;
        wire [3:1] Taken_3, NTaken_3;
        Tagged_predictor #( T3_storage, T3_address_width, Tag_width_3 ) Tagged_predictor_3 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[3]),
                .allocation(allocation[3]),
		.Taken_update(Taken_update_3),
                .NTaken_update(NTaken_update_3),
                .index(index_3),
                .index_update(index_update_3),
                .Tag(Tag_3),
                .Taken(Taken_3),
                .NTaken(NTaken_3)
        );
	//Table 4
        wire [3:1] Taken_update_4, NTaken_update_4;
        wire [T4_address_width:1] index_4, index_update_4;
        wire [Tag_width_4:1] Tag_4;
        wire [3:1] Taken_4, NTaken_4;
        Tagged_predictor #( T4_storage, T4_address_width, Tag_width_4 ) Tagged_predictor_4 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[4]),
                .allocation(allocation[4]),
		.Taken_update(Taken_update_4),
                .NTaken_update(NTaken_update_4),
                .index(index_4),
                .index_update(index_update_4),
                .Tag(Tag_4),
                .Taken(Taken_4),
                .NTaken(NTaken_4)
        );
	//Table 5
        wire [3:1] Taken_update_5, NTaken_update_5;
        wire [T5_address_width:1] index_5, index_update_5;
        wire [Tag_width_5:1] Tag_5;
        wire [3:1] Taken_5, NTaken_5;
        Tagged_predictor #( T5_storage, T5_address_width, Tag_width_5 ) Tagged_predictor_5 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[5]),
                .allocation(allocation[5]),
		.Taken_update(Taken_update_5),
                .NTaken_update(NTaken_update_5),
                .index(index_5),
                .index_update(index_update_5),
                .Tag(Tag_5),
                .Taken(Taken_5),
                .NTaken(NTaken_5)
        );
	//Table 6
        wire [3:1] Taken_update_6, NTaken_update_6;
        wire [T6_address_width:1] index_6, index_update_6;
        wire [Tag_width_6:1] Tag_6;
        wire [3:1] Taken_6, NTaken_6;
        Tagged_predictor #( T6_storage, T6_address_width, Tag_width_6 ) Tagged_predictor_6 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[6]),
                .allocation(allocation[6]),
		.Taken_update(Taken_update_6),
                .NTaken_update(NTaken_update_6),
                .index(index_6),
                .index_update(index_update_6),
                .Tag(Tag_6),
                .Taken(Taken_6),
                .NTaken(NTaken_6)
        );
	//Table 7
        wire [3:1] Taken_update_7, NTaken_update_7;
        wire [T7_address_width:1] index_7, index_update_7;
        wire [Tag_width_7:1] Tag_7;
        wire [3:1] Taken_7, NTaken_7;
        Tagged_predictor #( T7_storage, T7_address_width, Tag_width_7 ) Tagged_predictor_7 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[7]),
                .allocation(allocation[7]),
		.Taken_update(Taken_update_7),
                .NTaken_update(NTaken_update_7),
                .index(index_7),
                .index_update(index_update_7),
                .Tag(Tag_7),
                .Taken(Taken_7),
                .NTaken(NTaken_7)
        );
	//Table 8
        wire [3:1] Taken_update_8, NTaken_update_8;
        wire [T8_address_width:1] index_8, index_update_8;
        wire [Tag_width_8:1] Tag_8;
        wire [3:1] Taken_8, NTaken_8;
        Tagged_predictor #( T8_storage, T8_address_width, Tag_width_8 ) Tagged_predictor_8 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[8]),
                .allocation(allocation[8]),
		.Taken_update(Taken_update_8),
                .NTaken_update(NTaken_update_8),
                .index(index_8),
                .index_update(index_update_8),
                .Tag(Tag_8),
                .Taken(Taken_8),
                .NTaken(NTaken_8)
        );
	//Table 9
        wire [3:1] Taken_update_9, NTaken_update_9;
        wire [T9_address_width:1] index_9, index_update_9;
        wire [Tag_width_9:1] Tag_9;
        wire [3:1] Taken_9, NTaken_9;
        Tagged_predictor #( T9_storage, T9_address_width, Tag_width_9 ) Tagged_predictor_9 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[9]),
                .allocation(allocation[9]),
		.Taken_update(Taken_update_9),
                .NTaken_update(NTaken_update_9),
                .index(index_9),
                .index_update(index_update_9),
                .Tag(Tag_9),
                .Taken(Taken_9),
                .NTaken(NTaken_9)
        );
	//Table 10
        wire [3:1] Taken_update_10, NTaken_update_10;
        wire [T10_address_width:1] index_10, index_update_10;
        wire [Tag_width_10:1] Tag_10;
        wire [3:1] Taken_10, NTaken_10;
        Tagged_predictor #( T10_storage, T10_address_width, Tag_width_10 ) Tagged_predictor_10 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[10]),
                .allocation(allocation[10]),
		.Taken_update(Taken_update_10),
                .NTaken_update(NTaken_update_10),
                .index(index_10),
                .index_update(index_update_10),
                .Tag(Tag_10),
                .Taken(Taken_10),
                .NTaken(NTaken_10)
        );
	//Table 11
        wire [3:1] Taken_update_11, NTaken_update_11;
        wire [T11_address_width:1] index_11, index_update_11;
        wire [Tag_width_11:1] Tag_11;
        wire [3:1] Taken_11, NTaken_11;
        Tagged_predictor #( T11_storage, T11_address_width, Tag_width_11 ) Tagged_predictor_11 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[11]),
                .allocation(allocation[11]),
		.Taken_update(Taken_update_11),
                .NTaken_update(NTaken_update_11),
                .index(index_11),
                .index_update(index_update_11),
                .Tag(Tag_11),
                .Taken(Taken_11),
                .NTaken(NTaken_11)
        );
	//Table 12
        wire [3:1] Taken_update_12, NTaken_update_12;
        wire [T12_address_width:1] index_12, index_update_12;
        wire [Tag_width_12:1] Tag_12;
        wire [3:1] Taken_12, NTaken_12;
        Tagged_predictor #( T12_storage, T12_address_width, Tag_width_12 ) Tagged_predictor_12 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[12]),
                .allocation(allocation[12]),
		.Taken_update(Taken_update_12),
                .NTaken_update(NTaken_update_12),
                .index(index_12),
                .index_update(index_update_12),
                .Tag(Tag_12),
                .Taken(Taken_12),
                .NTaken(NTaken_12)
        );
	//Table 13
        wire [3:1] Taken_update_13, NTaken_update_13;
        wire [T13_address_width:1] index_13, index_update_13;
        wire [Tag_width_13:1] Tag_13;
        wire [3:1] Taken_13, NTaken_13;
        Tagged_predictor #( T13_storage, T13_address_width, Tag_width_13 ) Tagged_predictor_13 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[13]),
                .allocation(allocation[13]),
		.Taken_update(Taken_update_13),
                .NTaken_update(NTaken_update_13),
                .index(index_13),
                .index_update(index_update_13),
                .Tag(Tag_13),
                .Taken(Taken_13),
                .NTaken(NTaken_13)
        );
	//Table 14
        wire [3:1] Taken_update_14, NTaken_update_14;
        wire [T14_address_width:1] index_14, index_update_14;
        wire [Tag_width_14:1] Tag_14;
        wire [3:1] Taken_14, NTaken_14;
        Tagged_predictor #( T14_storage, T14_address_width, Tag_width_14 ) Tagged_predictor_14 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[14]),
                .allocation(allocation[14]),
		.Taken_update(Taken_update_14),
                .NTaken_update(NTaken_update_14),
                .index(index_14),
                .index_update(index_update_14),
                .Tag(Tag_14),
                .Taken(Taken_14),
                .NTaken(NTaken_14)
        );
	//Table 15
        wire [3:1] Taken_update_15, NTaken_update_15;
        wire [T15_address_width:1] index_15, index_update_15;
        wire [Tag_width_15:1] Tag_15;
        wire [3:1] Taken_15, NTaken_15;
        Tagged_predictor #( T15_storage, T15_address_width, Tag_width_15 ) Tagged_predictor_15 (
                .clk(clk),
                .rst(rst),
                .en_1(en_1_tagged[15]),
                .allocation(allocation[15]),
		.Taken_update(Taken_update_15),
                .NTaken_update(NTaken_update_15),
                .index(index_15),
                .index_update(index_update_15),
                .Tag(Tag_15),
                .Taken(Taken_15),
                .NTaken(NTaken_15)
        );
	
	//Prediction_computation
	wire [2:1] confidence;
	wire prediction;
	Prediction_computation_tagless Prediction_computation_tagless (
		.prediction(prediction),
		.confidence(confidence),
		.weight(weight)
	);

	wire prediction_1;
	wire [2:1] confidence_1;
	wire hit_1;
	Prediction_computation_tagged #( Tag_width_1, T1_address_width ) Prediction_computation_tagged_1 (
      		.prediction(prediction_1),
        	.confidence(confidence_1),
        	.hit(hit_1),
        	.Taken(Taken_1), 
		.NTaken(NTaken_1),
        	.Tag(Tag_1),
        	.index(index_1)
	);

	wire prediction_2;
        wire [2:1] confidence_2;
        wire hit_2;
        Prediction_computation_tagged #( Tag_width_2, T2_address_width ) Prediction_computation_tagged_2 (
                .prediction(prediction_2),
                .confidence(confidence_2),
                .hit(hit_2),
                .Taken(Taken_2), 
                .NTaken(NTaken_2),
                .Tag(Tag_2),
                .index(index_2)
        );

	wire prediction_3;
        wire [2:1] confidence_3;
        wire hit_3;
        Prediction_computation_tagged #( Tag_width_3, T3_address_width ) Prediction_computation_tagged_3 (
                .prediction(prediction_3),
                .confidence(confidence_3),
                .hit(hit_3),
                .Taken(Taken_3),
                .NTaken(NTaken_3),
                .Tag(Tag_3),
                .index(index_3)
        );

	wire prediction_4;
        wire [2:1] confidence_4;
        wire hit_4;
        Prediction_computation_tagged #( Tag_width_4, T4_address_width ) Prediction_computation_tagged_4 (
                .prediction(prediction_4),
                .confidence(confidence_4),
                .hit(hit_4),
                .Taken(Taken_4),
                .NTaken(NTaken_4),
                .Tag(Tag_4),
                .index(index_4)
        );

	wire prediction_5;
        wire [2:1] confidence_5;
        wire hit_5;
        Prediction_computation_tagged #( Tag_width_5, T5_address_width ) Prediction_computation_tagged_5 (
                .prediction(prediction_5),
                .confidence(confidence_5),
                .hit(hit_5),
                .Taken(Taken_5),
                .NTaken(NTaken_5),
                .Tag(Tag_5),
                .index(index_5)
        );

	wire prediction_6;
        wire [2:1] confidence_6;
        wire hit_6;
        Prediction_computation_tagged #( Tag_width_6, T6_address_width ) Prediction_computation_tagged_6 (
                .prediction(prediction_6),
                .confidence(confidence_6),
                .hit(hit_6),
                .Taken(Taken_6),
                .NTaken(NTaken_6),
                .Tag(Tag_6),
                .index(index_6)
        );

	wire prediction_7;
        wire [2:1] confidence_7;
        wire hit_7;
        Prediction_computation_tagged #( Tag_width_7, T7_address_width ) Prediction_computation_tagged_7 (
                .prediction(prediction_7),
                .confidence(confidence_7),
                .hit(hit_7),
                .Taken(Taken_7),
                .NTaken(NTaken_7),
                .Tag(Tag_7),
                .index(index_7)
        );

	wire prediction_8;
        wire [2:1] confidence_8;
        wire hit_8;
        Prediction_computation_tagged #( Tag_width_8, T8_address_width ) Prediction_computation_tagged_8 (
                .prediction(prediction_8),
                .confidence(confidence_8),
                .hit(hit_8),
                .Taken(Taken_8),
                .NTaken(NTaken_8),
                .Tag(Tag_8),
                .index(index_8)
        );

	wire prediction_9;
        wire [2:1] confidence_9;
        wire hit_9;
        Prediction_computation_tagged #( Tag_width_9, T9_address_width ) Prediction_computation_tagged_9 (
                .prediction(prediction_9),
                .confidence(confidence_9),
                .hit(hit_9),
                .Taken(Taken_9),
                .NTaken(NTaken_9),
                .Tag(Tag_9),
                .index(index_9)
        );

	wire prediction_10;
        wire [2:1] confidence_10;
        wire hit_10;
        Prediction_computation_tagged #( Tag_width_10, T10_address_width ) Prediction_computation_tagged_10 (
                .prediction(prediction_10),
                .confidence(confidence_10),
                .hit(hit_10),
                .Taken(Taken_10),
                .NTaken(NTaken_10),
                .Tag(Tag_10),
                .index(index_10)
        );

	wire prediction_11;
        wire [2:1] confidence_11;
        wire hit_11;
        Prediction_computation_tagged #( Tag_width_11, T11_address_width ) Prediction_computation_tagged_11 (
                .prediction(prediction_11),
                .confidence(confidence_11),
                .hit(hit_11),
                .Taken(Taken_11),
                .NTaken(NTaken_11),
                .Tag(Tag_11),
                .index(index_11)
        );

	wire prediction_12;
        wire [2:1] confidence_12;
        wire hit_12;
        Prediction_computation_tagged #( Tag_width_12, T12_address_width ) Prediction_computation_tagged_12 (
                .prediction(prediction_12),
                .confidence(confidence_12),
                .hit(hit_12),
                .Taken(Taken_12),
                .NTaken(NTaken_12),
                .Tag(Tag_12),
                .index(index_12)
        );

	wire prediction_13;
        wire [2:1] confidence_13;
        wire hit_13;
        Prediction_computation_tagged #( Tag_width_13, T13_address_width ) Prediction_computation_tagged_13 (
                .prediction(prediction_13),
                .confidence(confidence_13),
                .hit(hit_13),
                .Taken(Taken_13),
                .NTaken(NTaken_13),
                .Tag(Tag_13),
                .index(index_13)
        );

	wire prediction_14;
        wire [2:1] confidence_14;
        wire hit_14;
        Prediction_computation_tagged #( Tag_width_14, T14_address_width ) Prediction_computation_tagged_14 (
                .prediction(prediction_14),
                .confidence(confidence_14),
                .hit(hit_14),
                .Taken(Taken_14),
                .NTaken(NTaken_14),
                .Tag(Tag_14),
                .index(index_14)
        );

	wire prediction_15;
        wire [2:1] confidence_15;
        wire hit_15;
        Prediction_computation_tagged #( Tag_width_15, T15_address_width ) Prediction_computation_tagged_15 (
                .prediction(prediction_15),
                .confidence(confidence_15),
                .hit(hit_15),
                .Taken(Taken_15),
                .NTaken(NTaken_15),
                .Tag(Tag_15),
                .index(index_15)
        );
	
	wire [num_table:1] prediction_array; //Num_predictor = 16
	wire [num_table:1] hit_array;
	wire [width_confidence*num_table:1] confidence_array;
	wire [width_Taken*num_table_tagged:1] Taken_array, NTaken_array;

	assign Taken_array = {Taken_15, Taken_14, Taken_13, Taken_12, Taken_11, Taken_10, Taken_9, Taken_8, 
		Taken_7, Taken_6, Taken_5, Taken_4, Taken_3, Taken_2, Taken_1};
	
	assign NTaken_array = {NTaken_15, NTaken_14, NTaken_13, NTaken_12, NTaken_11, NTaken_10, NTaken_9, NTaken_8,
                NTaken_7, NTaken_6, NTaken_5, NTaken_4, NTaken_3, NTaken_2, NTaken_1};

	assign hit_array = {hit_15, hit_14, hit_13, hit_12, hit_11, hit_10, hit_9, hit_8, hit_7, 
		hit_6, hit_5, hit_4, hit_3, hit_2, hit_1, 1'b1};
	
	assign prediction_array = {prediction_15, prediction_14, prediction_13, prediction_12, prediction_11, 
		prediction_10, prediction_9, prediction_8, prediction_7, prediction_6, prediction_5, 
		prediction_4, prediction_3, prediction_2, prediction_1, prediction};
	
	assign confidence_array = {confidence_15, confidence_14, confidence_13, confidence_12, confidence_11,
                confidence_10, confidence_9, confidence_8, confidence_7, confidence_6, confidence_5,
                confidence_4, confidence_3, confidence_2, confidence_1, confidence};
	
	wire prediction_final;
        wire [width_confidence:1] confidence_final;
       	wire [width_num_table:1] num_table_final;
	Comparision_prediction Comparision_prediction (
		.prediction_final(prediction_final),
		.confidence_final(confidence_final),
		.num_table_final(num_table_final),
		.confidence(confidence_array),
		.prediction(prediction_array)
	);
	
	Mux_prediction Mux_prediction (
		.PC_predict_pre_IF(PC_predict_pre_IF),
		.PC_in(PC_in),
		.PC_predict_o(PC_predict_o),
		.hit_BTB(hit_BTB),
		.prediction_final(prediction_final)
	);
	
	//State Register
	Sr_index_BTB #(
		.index_width(32),
		.stage(3)
	) Sr_index_BTB (
		.index_update(PC_update),
		.index_predict(PC_in),
		.clk(clk),
		.rst(rst),
		.stall(stall)
	);
	
	Sr_index_table #(
		.index_width(index_width_T0),
		.stage(3)
	) Sr_index_table_tagless (
		.index_update(index_update),
		.index_predict(index),
		.clk(clk),
		.rst(rst),
		.stall(stall)
	);

	Sr_index_table #(
                .index_width(T1_address_width),
                .stage(3)
        ) Sr_index_table_tagged_1 (
                .index_update(index_update_1),
                .index_predict(index_1),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T2_address_width),
                .stage(3)
        ) Sr_index_table_tagged_2 (
                .index_update(index_update_2),
                .index_predict(index_2),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T3_address_width),
                .stage(3)
        ) Sr_index_table_tagged_3 (
                .index_update(index_update_3),
                .index_predict(index_3),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T4_address_width),
                .stage(3)
        ) Sr_index_table_tagged_4 (
                .index_update(index_update_4),
                .index_predict(index_4),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T5_address_width),
                .stage(3)
        ) Sr_index_table_tagged_5 (
                .index_update(index_update_5),
                .index_predict(index_5),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T6_address_width),
                .stage(3)
        ) Sr_index_table_tagged_6 (
                .index_update(index_update_6),
                .index_predict(index_6),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T7_address_width),
                .stage(3)
        ) Sr_index_table_tagged_7 (
                .index_update(index_update_7),
                .index_predict(index_7),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T8_address_width),
                .stage(3)
        ) Sr_index_table_tagged_8 (
                .index_update(index_update_8),
                .index_predict(index_8),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T9_address_width),
                .stage(3)
        ) Sr_index_table_tagged_9 (
                .index_update(index_update_9),
                .index_predict(index_9),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T10_address_width),
                .stage(3)
        ) Sr_index_table_tagged_10 (
                .index_update(index_update_10),
                .index_predict(index_10),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T11_address_width),
                .stage(3)
        ) Sr_index_table_tagged_11 (
                .index_update(index_update_11),
                .index_predict(index_11),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T12_address_width),
                .stage(3)
        ) Sr_index_table_tagged_12 (
                .index_update(index_update_12),
                .index_predict(index_12),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T13_address_width),
                .stage(3)
        ) Sr_index_table_tagged_13 (
                .index_update(index_update_13),
                .index_predict(index_13),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T14_address_width),
                .stage(3)
        ) Sr_index_table_tagged_14 (
                .index_update(index_update_14),
                .index_predict(index_14),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Sr_index_table #(
                .index_width(T15_address_width),
                .stage(3)
        ) Sr_index_table_tagged_15 (
                .index_update(index_update_15),
                .index_predict(index_15),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	wire [num_table:1] prediction_array_update;
	Sr_table_prediction Sr_prediction_table (
		.prediction_table_update(prediction_array_update),
		.prediction_table(prediction_array),
		.clk(clk),
		.rst(rst),
		.stall(stall)
	);

	wire [32:1] PC_predict_update;
	Sr_address_prediction Sr_address_prediction (
		.address_update(PC_predict_update),
		.address_predict(PC_predict_pre_IF),
		.clk(clk),
		.rst(rst),
		.stall(stall)
	);

	wire [16:1] hit_update;
	Sr_hitting Sr_hitting (
		.hit_update(hit_update),
		.hit_predict(hit_array),
		.clk(clk),
		.rst(rst),
		.stall(stall)
	);

	wire [width_confidence*num_table:1] confidence_array_update;
	Sr_confidence Sr_confidence (
		.confidence_update(confidence_array_update),
		.confidence_predict(confidence_array),
		.clk(clk),
		.rst(rst),
		.stall(stall)
	);

	wire [width_Taken*num_table_tagged:1] Taken_array_update, NTaken_array_update;
	wire [3:1] weight_update_sr;
	Sr_Taken_NTaken Sr_Taken_NTaken ( //include weight BTB
		.Taken_update(Taken_array_update),
		.NTaken_update(NTaken_array_update),
		.weight_update(weight_update_sr),
		.weight_predict(weight),
		.Taken_predict(Taken_array),
		.NTaken_predict(NTaken_array),
		.clk(clk),
		.rst(rst),
		.stall(stall)
	);

	wire prediction_final_update;
        wire [width_confidence:1] confidence_final_update;
        wire [width_num_table:1] num_table_final_update;
	Sr_prediction_num_table Sr_prediction_num_table (
		.prediction_update(prediction_final_update),
		.num_table_update(num_table_final_update),
		.confidence_predict_update(confidence_final_update),
		.num_table(num_table_final),
		.confidence(confidence_final),
		.prediction(prediction_final),
		.clk(clk),
		.rst(rst),
		.stall(stall)
	);


	wire allocation_signal, en_2;
	wire [num_table:1] control;
	wire [num_table_tagged:1] en_1_tagged_temp;

	Update_control_signal Update_control_signal (
		.en_2(en_2),
		.allocation_signal(allocation_signal),
		.rst_pipeline(rst_pipeline),
		.en_update({en_1_tagged_temp, en_1_tagless}),
		.control(control),
		.prediction_update(prediction_final_update),
		.first_hitting_table_update(num_table_final_update),
		.confidence_predict_update(confidence_final_update),
		.Taken_update(Taken_array_update),
		.NTaken_update(NTaken_array_update),
		.confidence_update(confidence_array_update),
		.hit_update(hit_update),
		.prediction_table_update(prediction_array_update),
		.address_predict(PC_predict_update),
		.PC_actual(PC_actual),
		.inst(inst),
		.Branch_direction(Branch_direction)
	);

	wire [num_table_tagged:1] decay;
	Allocation_component Allocation_component (
		.en_allocation(allocation),
		.decay(decay),
		.first_hitting_table_update(num_table_final_update),
		.allocation_signal(allocation_signal),
		.Taken_update(Taken_array_update),
		.NTaken_update(NTaken_array_update),
		.clk(clk),
		.rst(rst)
	);


	Table_update_tagless Table_update_tagless (
		.weight_new(weight_update),
		.en(en_1_tagless),
		.control(control[1]),
		.weight_update(weight_update_sr),
		.Branch_direction(Branch_direction)
	);
	
	wire [width_Taken*num_table_tagged:1] Taken_update, NTaken_update;

	Table_update_tagged Table_update_tagged (
		.Taken_new(Taken_update),
		.NTaken_new(NTaken_update),
		.en(en_1_tagged),
		.Branch_direction(Branch_direction),
		.en_allocation(allocation),
		.decay(decay),
		.en_update(en_1_tagged_temp),
		.control(control[16:2]),
		.Taken_update(Taken_array_update),
		.NTaken_update(NTaken_array_update)
	);

	assign  {Taken_update_15, Taken_update_14, Taken_update_13, Taken_update_12, Taken_update_11, Taken_update_10, Taken_update_9, Taken_update_8,
                Taken_update_7, Taken_update_6, Taken_update_5, Taken_update_4, Taken_update_3, Taken_update_2, Taken_update_1} = Taken_update;

        assign  {NTaken_update_15, NTaken_update_14, NTaken_update_13, NTaken_update_12, NTaken_update_11, NTaken_update_10, NTaken_update_9, NTaken_update_8,
                NTaken_update_7, NTaken_update_6, NTaken_update_5, NTaken_update_4, NTaken_update_3, NTaken_update_2, NTaken_update_1} = NTaken_update;

	wire [history_length:1] Global_hist_iterative, Global_hist_true;
	Global_hist_reg Global_hist_reg (
		.Global_hist_iterative(Global_hist_iterative),
		.Global_hist_true_1(Global_hist_true),
		.Global_hist_update_iterative(hit_BTB & prediction_final),
		.Global_hist_update(Branch_direction),
		.en_1(hit_BTB),
		.en_2_miss(rst_pipeline),
		.en_2(en_2),
		.clk(clk),
		.rst(rst),
		.stall(stall)
	);
	
	wire [path_length:1] Branch_address_bits_iterative;
	wire [path_length:1] Branch_address_bits_true_1;
	Branch_address_reg #( .path_length(path_length) ) Branch_address_reg (
		.Branch_address_bits_iterative(Branch_address_bits_iterative),
		.Branch_address_bits_true_1(Branch_address_bits_true_1),
		.Branch_address_update_iterative(PC_predict_pre_IF),
		.Branch_address_update(PC_actual),
		.clk(clk),
		.en_1(hit_BTB),
		.en_2(en_2),
		.en_2_miss(rst_pipeline),
		.rst(rst),
		.stall(stall)
	);

	Index_component #(
		.history_length(history_length_1),
		.tag_width(Tag_width_1),
		.index_width(index_width_1),
		.T_address_width(T1_address_width),
		.path_length(path_length_1)
	) Index_component_1 (
		.index(index_1),
		.Path_hist_iterative(Branch_address_bits_iterative),
		.Path_hist_true(Branch_address_bits_true_1),
		.Global_hist_iterative(Global_hist_iterative),
		.Global_hist_true(Global_hist_true),
		.PC_in(PC_in),
		.en_1(hit_BTB),
		.en_2(en_2),
		.en_2_miss(rst_pipeline),
		.clk(clk),
		.rst(rst),
		.stall(stall)
	);
	
	Index_component #(
                .history_length(history_length_2),
                .tag_width(Tag_width_2),
                .index_width(index_width_2),
                .T_address_width(T2_address_width),
                .path_length(path_length_2)
        ) Index_component_2 (
                .index(index_2),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Index_component #(
                .history_length(history_length_3),
                .tag_width(Tag_width_3),
                .index_width(index_width_3),
                .T_address_width(T3_address_width),
                .path_length(path_length_3)
        ) Index_component_3 (
                .index(index_3),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Index_component #(
                .history_length(history_length_4),
                .tag_width(Tag_width_4),
                .index_width(index_width_4),
                .T_address_width(T4_address_width),
                .path_length(path_length_4)
        ) Index_component_4 (
                .index(index_4),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Index_component #(
                .history_length(history_length_5),
                .tag_width(Tag_width_5),
                .index_width(index_width_5),
                .T_address_width(T5_address_width),
                .path_length(path_length_5)
        ) Index_component_5 (
                .index(index_5),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Index_component #(
                .history_length(history_length_6),
                .tag_width(Tag_width_6),
                .index_width(index_width_6),
                .T_address_width(T6_address_width),
                .path_length(path_length_6)
        ) Index_component_6 (
                .index(index_6),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Index_component #(
                .history_length(history_length_7),
                .tag_width(Tag_width_7),
                .index_width(index_width_7),
                .T_address_width(T7_address_width),
                .path_length(path_length_7)
        ) Index_component_7 (
                .index(index_7),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Index_component #(
                .history_length(history_length_8),
                .tag_width(Tag_width_8),
                .index_width(index_width_8),
                .T_address_width(T8_address_width),
                .path_length(path_length_8)
        ) Index_component_8 (
                .index(index_8),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Index_component #(
                .history_length(history_length_9),
                .tag_width(Tag_width_9),
                .index_width(index_width_9),
                .T_address_width(T9_address_width),
                .path_length(path_length_9)
        ) Index_component_9 (
                .index(index_9),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Index_component #(
                .history_length(history_length_10),
                .tag_width(Tag_width_10),
                .index_width(index_width_10),
                .T_address_width(T10_address_width),
                .path_length(path_length_10)
        ) Index_component_10 (
                .index(index_10),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Index_component #(
                .history_length(history_length_11),
                .tag_width(Tag_width_11),
                .index_width(index_width_11),
                .T_address_width(T11_address_width),
                .path_length(path_length_11)
        ) Index_component_11 (
                .index(index_11),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Index_component #(
                .history_length(history_length_12),
                .tag_width(Tag_width_12),
                .index_width(index_width_12),
                .T_address_width(T12_address_width),
                .path_length(path_length_12)
        ) Index_component_12 (
                .index(index_12),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Index_component #(
                .history_length(history_length_13),
                .tag_width(Tag_width_13),
                .index_width(index_width_13),
                .T_address_width(T13_address_width),
                .path_length(path_length_13)
        ) Index_component_13 (
                .index(index_13),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );
	
	Index_component #(
                .history_length(history_length_14),
                .tag_width(Tag_width_14),
                .index_width(index_width_14),
                .T_address_width(T14_address_width),
                .path_length(path_length_14)
        ) Index_component_14 (
                .index(index_14),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	Index_component #(
                .history_length(history_length_15),
                .tag_width(Tag_width_15),
                .index_width(index_width_15),
                .T_address_width(T15_address_width),
                .path_length(path_length_15)
        ) Index_component_15 (
                .index(index_15),
                .Path_hist_iterative(Branch_address_bits_iterative),
                .Path_hist_true(Branch_address_bits_true_1),
                .Global_hist_iterative(Global_hist_iterative),
                .Global_hist_true(Global_hist_true),
                .PC_in(PC_in),
                .en_1(hit_BTB),
                .en_2(en_2),
                .en_2_miss(rst_pipeline),
                .clk(clk),
                .rst(rst),
                .stall(stall)
        );

	
//	always begin
//		clk=0;
//		forever #20 clk=~clk;
//	end
//
//	initial begin
//		rst = 1;
//		#60 rst = 0;
//	end
//	
//
//	initial begin
//		stall <= 0;
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
//		PC_actual <=12;
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
