/* verilator lint_off UNUSED */
/* verilator lint_off DECLFILENAME */
module Tagged_predictor #(
/* verilator lint_on DECLFILENAME */
/* verilator lint_off WIDTH */
	parameter T_storage = 2047,     //18 bit index, 11 bit address, 7 bit tag, 2K storage
	parameter T_address_width = 18,  
	parameter Tag_width = 7
)
(
	output reg [3:1] Taken, NTaken,
	output reg [Tag_width:1] Tag,

	input wire [T_address_width:1] index, index_update,
	input wire [3:1] Taken_update, NTaken_update, 
	input wire clk, rst, en_1, allocation
);
	wire [Tag_width:1] Tag_update;
	wire [T_address_width-Tag_width:1] index_1, index_update_1;

	assign index_1 = index [T_address_width-Tag_width:1];
	assign index_update_1 = index_update [T_address_width-Tag_width:1];
	assign Tag_update = index_update[T_address_width:T_address_width-Tag_width+1];
	
	
	wire cont_1 = ((en_1 == 1) && (allocation==0) || (allocation==1));
	wire cont_2 = (allocation==1);
	//Internal memory
	reg [3:1] Taken_reg [T_storage:0];
	reg [3:1] NTaken_reg [T_storage:0];
	reg [Tag_width:1] Tag_reg [T_storage:0];
	initial begin
		for (int i=0 ; i <= T_storage; i=i+1) begin
			Taken_reg [i] = 0;
			NTaken_reg [i] = 0;
			Tag_reg [i] = 0;
		end	
	end
	//
	always @(posedge clk) begin
		if (cont_1) begin
			Taken_reg [index_update_1] <= Taken_update;
                        NTaken_reg [index_update_1] <= NTaken_update;
		end
		Taken <= Taken_reg [index_1];
		NTaken <= NTaken_reg [index_1];
	end

	always @(posedge clk) begin
		if (cont_2)
			Tag_reg [index_update_1] <= Tag_update;
		Tag <= Tag_reg [index_1];
	end
//	//Update 
//	always_ff @(posedge clk) begin
//		if (rst == 1) begin
//			for (int i=0 ; i <= T_storage; i=i+1) begin
//				Taken_reg [i] <= 0;
//				NTaken_reg [i] <= 0;
//				Tag_reg [i] <= 0;
//			end	
//		end
//		else begin
//			if ((en_1 == 1)&&(allocation==0)) begin
//				Taken_reg [index_update_1] <= Taken_update;
//				NTaken_reg [index_update_1] <= NTaken_update;
//				Tag_reg [index_update_1] <= Tag_reg [index_update_1];
//			end
//			else if (allocation==1) begin
//				Taken_reg [index_update_1] <= Taken_update;
//                                NTaken_reg [index_update_1] <= NTaken_update;
//				Tag_reg [index_update_1] <= Tag_update;
//			end
//			else begin
//				Taken_reg [index_update_1] <= Taken_reg [index_update_1] ;
//				NTaken_reg [index_update_1] <= NTaken_reg [index_update_1] ;
//				Tag_reg [index_update_1] <= Tag_reg [index_update_1];
//			end
//		end
//	end
//
endmodule
module Base_predictor #(
	parameter B_storage = 16383,
	parameter index_width = 14
)

(
	output reg [3:1] weight,

	input wire [3:1] weight_update,
	input wire [index_width:1] index,
	input wire [index_width:1] index_update,
	input wire en_1, rst, 
	input wire clk 
       	
);
	//Storage 
	reg [3:1] weight_bits [B_storage:0];

	initial begin
		for (int i=0; i <= B_storage; i=i+1) begin
			weight_bits[i] = 0;
		end
	end
	//Prediction
	always @(posedge clk) begin
		if (en_1)
			weight_bits[index_update] <= weight_update;
		weight <= weight_bits[index];
	end

//	//Update
//	always_ff @(posedge clk) begin
//		if (rst == 1) begin
//			for (int i=0; i <= B_storage; i=i+1) begin
//				weight_bits[i] <= 0;
//			end
//		end
//		else begin
//			
//			else
//				weight_bits[index_update] <= weight_bits[index_update];
//		end
//	end
	
endmodule

module Branch_target_buffer #(
	parameter BTB_storage = 16383,
	parameter Tag_width = 16
)
(
	output reg [32:1] PC_predict_o,
	output reg hit, uncont_predict,

	input wire [32:1] PC_in, PC_predict_update, PC_update, 
	input wire [32-Tag_width:1] index_BTB_update,
	input wire clk, en_1, rst, en_3
);
	wire [32-Tag_width-2:1] PC_index, PC_index_update;

	assign PC_index = PC_in [32-Tag_width:3];
	assign PC_index_update = index_BTB_update[32-Tag_width:3];

	//Prediction
	reg [Tag_width:1] Tag_predict;
	reg [32:1] PC_predict_1;
	reg valid_predict;

	//Infer BRAM
	//Storage
	reg [Tag_width:1] Tag [BTB_storage:0];
	reg [32:1] PC_predict [BTB_storage:0];
	reg [BTB_storage:0] valid, uncont;
	
	initial begin
		for (int i=0; i <= BTB_storage; i=i+1) begin
			PC_predict[i] = 0;
			Tag[i] = 0;
			valid[i] = 0;
			uncont[i] = 0;
		end
	end
	wire uncont_update = (en_3 == 1) ? 1 : 0;
	always @(posedge clk) begin
		if (1)
			uncont[PC_index_update] <= uncont_update;
		uncont_predict <= uncont[PC_index];
	end
	always @(posedge clk) begin
		if (en_1 == 1) begin
			PC_predict[PC_index_update] <= PC_predict_update;
			Tag [PC_index_update] <= PC_update[32:32-Tag_width+1];	
			valid[PC_index_update] <= 1;	       	
		end
		Tag_predict <= Tag [PC_index];
		PC_predict_1 <= PC_predict [PC_index];
		valid_predict <= valid[PC_index];
	end
	
	assign hit = ((PC_in[32:32-Tag_width+1] == Tag_predict) && valid_predict) ? 1 : 0;
	assign PC_predict_o = ((PC_in[32:32-Tag_width+1] == Tag_predict) && valid_predict) ? PC_predict_1 : PC_in + 4; 
	
	
//	always_ff @(posedge clk) begin
//		if ((PC_in[32:32-Tag_width+1] == Tag [PC_index]) && (valid[PC_index] == 1)) begin
//			hit <= 1;
//			PC_predict_o <= PC_predict [PC_index];
//		end
//		else begin
//			hit <= 0;
//			PC_predict_o <= PC_in+4; // careful
//		end
//	end

	//Update
//	always_ff @(posedge clk) begin
//		if (rst == 1) begin
//			for (int i=0; i <= BTB_storage; i=i+1) begin
//				PC_predict[i] <= 0;
//				Tag[i] <= 0;
//				valid[i] <= 0;
//			end	
//		end
//		else begin
//			if (en_1 == 1) begin
//				PC_predict[PC_index_update] <= PC_predict_update;
//				Tag [PC_index_update] <= PC_update[32:32-Tag_width+1];	
//				valid[PC_index_update] <= 1;	       	
//			end
//			else begin
//				PC_predict[PC_index_update] <= PC_predict[PC_index_update];
//				Tag [PC_index_update] <= Tag [PC_index_update];
//				valid[PC_index_update] <= valid[PC_index_update];
//			end
//		end
//	end
	
endmodule

module Prediction_computation_tagless (
	output wire prediction,
	output reg [2:1] confidence,
	
	input wire [3:1] weight
);
	assign prediction = ~weight[3];
	always_comb begin
		case (weight) 
			3'b000	: confidence = 2;
			3'b001	: confidence = 1;
			3'b010	: confidence = 0;
			3'b011	: confidence = 0;
			3'b100	: confidence = 0;
			3'b101	: confidence = 0;
			3'b110	: confidence = 1;
			default	: confidence = 2;
		endcase	
	end
	
endmodule

module Prediction_computation_tagged #(
	parameter Tag_width = 7,
	parameter index_width = 18
)
(
	output reg prediction,
	output reg [2:1] confidence,
	//output wire [2:1] confidence_cal,
	output reg hit,

	input wire [3:1] Taken, NTaken,
	input wire [Tag_width:1] Tag, 
	input wire [index_width:1] index
);
	reg [2:1] confidence_cal;
	wire [4:1] prediction_hit;
	wire medium_bit, low_bit;
	wire [4:1] Taken_mul, NTaken_mul;

	Full_adder_4_bit Full_adder_4_bit ( .out(Taken_mul), .in_1({1'b0,Taken}), .in_2({1'b0,Taken}), .c_in(1'b1) );
	Full_adder_4_bit Full_adder_4_bit_2 ( .out(NTaken_mul), .in_1({1'b0,NTaken}), .in_2({1'b0,NTaken}), .c_in(1'b1) );
	Full_adder_4_bit Full_adder_4_bit_3 ( .out(prediction_hit), .in_1({1'b0,NTaken}), .in_2(~{1'b0,Taken}), .c_in(1'b1) );
	assign medium_bit = (Taken == NTaken_mul) || (NTaken == Taken_mul);
	assign low_bit = (Taken < NTaken_mul) && (NTaken < Taken_mul);
	always_comb begin 
		confidence_cal = low_bit + low_bit + medium_bit;
	end

	always_comb begin
		if (Tag == index[index_width:index_width-Tag_width+1]) begin
			hit = 1;
			confidence = confidence_cal;
			prediction = prediction_hit[4];
		end
		else begin
			hit = 0;
			confidence = 3;
			prediction = 0;
		end
	end
	
endmodule

module Full_adder_4_bit (
	output wire [4:1] out,

	input wire [4:1] in_1, in_2,
	input wire c_in
);
	assign out = in_1 + in_2 +c_in;
endmodule

module Comparision_prediction #(		//Change this module when change number of table
	parameter num_predictor = 16
)
(
	output reg prediction_final,
	output reg [2:1] confidence_final,
	output wire [4:1] num_table_final,

	input wire [2*num_predictor:1] confidence,
	input wire [num_predictor:1] prediction
);
	wire [4*num_predictor:1] num_table;
	wire [2*num_predictor:1] num_table_1;
	wire [num_predictor:1] confidence_1;
	wire [num_predictor/2:1] prediction_1;

	assign num_table = {4'd15, 4'd14, 4'd13, 4'd12, 4'd11, 4'd10, 4'd9, 4'd8, 
		4'd7, 4'd6, 4'd5, 4'd4, 4'd3, 4'd2, 4'd1, 4'd0};
	genvar i;
	generate 
		for ( i=1; i<=num_predictor/2; i=i+1) begin :block_1
			Comparision Comparision (
				.prediction(prediction_1[i]),
				.confidence(confidence_1[i*2:i*2-1]),
				.num_table(num_table_1[i*4:i*4-3]),
				.confidence_1(confidence[i*4:i*4-1]),
				.confidence_2(confidence[i*4-2:i*4-3]),
				.prediction_1(prediction[i*2]),
				.prediction_2(prediction[i*2-1]),
				.num_table_1(num_table[8*i:8*i-3]),
				.num_table_2(num_table[8*i-4:8*i-7])
			);
		end	
	endgenerate

	wire [num_predictor:1] num_table_2;
        wire [num_predictor/2:1] confidence_2;
        wire [num_predictor/4:1] prediction_2;

	generate
                for ( i=1; i<=num_predictor/4; i=i+1) begin : block_2
                        Comparision Comparision_2 (
                                .prediction(prediction_2[i]),
                                .confidence(confidence_2[i*2:i*2-1]),
                                .num_table(num_table_2[i*4:i*4-3]),
                                .confidence_1(confidence_1[i*4:i*4-1]),
                                .confidence_2(confidence_1[i*4-2:i*4-3]),
                                .prediction_1(prediction_1[i*2]),
                                .prediction_2(prediction_1[i*2-1]),
                                .num_table_1(num_table_1[8*i:8*i-3]),
                                .num_table_2(num_table_1[8*i-4:8*i-7])
                        );
                end
        endgenerate

	wire [num_predictor/2:1] num_table_3;
        wire [num_predictor/4:1] confidence_3;
        wire [num_predictor/8:1] prediction_3;

        generate
                for ( i=1; i<=num_predictor/8; i=i+1) begin : block_3
                        Comparision Comparision_3 (
                                .prediction(prediction_3[i]),
                                .confidence(confidence_3[i*2:i*2-1]),
                                .num_table(num_table_3[i*4:i*4-3]),
                                .confidence_1(confidence_2[i*4:i*4-1]),
                                .confidence_2(confidence_2[i*4-2:i*4-3]),
                                .prediction_1(prediction_2[i*2]),
                                .prediction_2(prediction_2[i*2-1]),
                                .num_table_1(num_table_2[8*i:8*i-3]),
                                .num_table_2(num_table_2[8*i-4:8*i-7])
                        );
                end
        endgenerate
	
	wire prediction_final_temp;
	wire [2:1] confidence_final_temp;
	Comparision Comparision_4 (
		.prediction(prediction_final_temp),
                .confidence(confidence_final_temp),
                .num_table(num_table_final),
                .confidence_1(confidence_3[4:3]),
                .confidence_2(confidence_3[2:1]),
                .prediction_1(prediction_3[2]),
                .prediction_2(prediction_3[1]),
                .num_table_1(num_table_3[8:5]),
                .num_table_2(num_table_3[4:1])
       );
	//Reverse prediction if low confidence, don't reverse confidence because of update_control_signal module, don't change num_table_final
	always_comb begin
		//if (confidence_final_temp == 2) begin
		//	prediction_final = ~prediction_final_temp;
		//end
		//else begin
			prediction_final = prediction_final_temp;
		//end
	end
	assign confidence_final = confidence_final_temp;
       
endmodule

module Comparision (
	output reg prediction,
	output reg [2:1] confidence,
	output reg [4:1] num_table,

	input wire [2:1] confidence_1, confidence_2,
	input wire prediction_1, prediction_2,
	input wire [4:1] num_table_1, num_table_2
);
	always_comb begin
		if (confidence_1 < confidence_2) begin
			prediction = prediction_1;
			confidence = confidence_1;
			num_table = num_table_1;
		end
		else if (confidence_1 > confidence_2) begin
			prediction = prediction_2;
			confidence = confidence_2;
			num_table = num_table_2;
		end
		else begin
			if (num_table_1 > num_table_2) begin
				prediction = prediction_1;
                        	confidence = confidence_1;
                        	num_table = num_table_1;
			end
			else begin
				prediction = prediction_2;
                        	confidence = confidence_2;
                        	num_table = num_table_2;
			end
		end
	end
	
endmodule

module Mux_prediction_BATAGE (
	output reg [32:1] PC_predict_pre_IF,

	input wire [32:1] PC_in, PC_predict_o,
	input wire hit_BTB,
	input wire prediction_final
);
	always_comb begin
		if ((hit_BTB==1)&&(prediction_final == 1)) begin
			PC_predict_pre_IF = PC_predict_o;
		end
		else begin
			PC_predict_pre_IF = PC_in+4;
		end
	end
endmodule
module Sr_prediction_num_table #(
	parameter stage = 3,
	//parameter width_prediction = 1,
	parameter width_num_table = 4,
	parameter width_confidence = 2
)
(
	//output wire prediction_update,
	output wire [width_num_table:1] num_table_update,
	output wire [width_confidence:1] confidence_predict_update,

	input wire [width_num_table:1] num_table,
	input wire [width_confidence:1] confidence,
	//input wire prediction, 
	input wire clk, rst, stall
);
	//reg [stage*width_prediction:1] prediction_reg;	
	reg [stage*width_num_table:1] num_table_reg;
	reg [stage*width_confidence:1] confidence_reg;
	
	assign num_table_update = num_table_reg[width_num_table:1];
	//assign prediction_update = prediction_reg[1];
	assign confidence_predict_update = confidence_reg[width_confidence:1];
	always_ff @(negedge clk) begin
		if (rst == 1) begin
	//		prediction_reg <= 0;
			num_table_reg <= 0;
			confidence_reg <= 0;
		end
		else begin
			if (stall == 1) begin
	//			prediction_reg <= prediction_reg;
				num_table_reg <= num_table_reg;
				confidence_reg <= confidence_reg;
			end
			else begin
	//			prediction_reg <= {prediction, prediction_reg [(stage-2)*width_prediction+1+:2*width_prediction]};
				num_table_reg <= {num_table, num_table_reg [(stage-2)*width_num_table+1+:2*width_num_table]};
				confidence_reg <= {confidence, confidence_reg[(stage-2)*width_confidence+1+:2*width_confidence]};
			end
		end
	end
	
endmodule

module Sr_Taken_NTaken #(
	parameter stage = 3,
	parameter width = 3,
	parameter num_table = 15
)
(
	output wire [num_table*width:1] Taken_update, NTaken_update,
	output wire [width:1] weight_update,

	input wire [width:1] weight_predict,
	input wire [num_table*width:1] Taken_predict, NTaken_predict,
	input wire clk, rst, stall
);
	reg [stage*width*num_table:1] Taken, NTaken;
	reg [stage*width:1] weight;

	assign weight_update = weight [width:1];
	assign Taken_update = Taken [num_table*width:1];
	assign NTaken_update = NTaken [num_table*width:1];

	always_ff @(negedge clk) begin
		if (rst == 1) begin
			Taken <= 0;
			NTaken <= 0;
			weight <= 0;
		end
		else begin
			if (stall == 1) begin
				Taken <=  Taken;
				NTaken <= NTaken;
				weight <= weight;
			end
			else begin
				weight <= {weight_predict, weight [(stage-2)*width+1+:2*width]};
				Taken <= {Taken_predict, Taken [(stage-2)*width*num_table+1+:2*width*num_table]};
				NTaken <= {NTaken_predict, NTaken [(stage-2)*width*num_table+1+:2*width*num_table]};
			end
		end
	end
	
endmodule

module Sr_confidence #(
	parameter stage = 3,
	parameter width = 2,
	parameter num_table = 16
)
(
	output wire [num_table*width:1] confidence_update,

	input wire [num_table*width:1] confidence_predict,
	input wire clk, rst, stall
);
	reg [stage*width*num_table:1] confidence;

	assign confidence_update = confidence[num_table*width:1];

	always_ff @(negedge clk) begin
		if (rst == 1) begin
			confidence <= 0;
		end
		else begin
			if (stall ==  1) begin
				confidence <= confidence;
			end
			else begin
				confidence <= {confidence_predict, confidence[(stage-2)*width*num_table+1+:2*width*num_table]};
			end
		end
	end	
		
endmodule

module Sr_hitting #(
	parameter stage = 3,
	parameter width = 1,
	parameter num_table = 16
)
(
	output wire [num_table*width:1] hit_update,

	input wire [num_table*width:1] hit_predict,
	input wire clk, rst, stall
);
	reg [stage*width*num_table:1] hit;

	assign hit_update = hit[num_table*width:1];

	always_ff @(negedge clk) begin
		if (rst ==  1) begin
			hit <= 0;
		end
		else begin
			if (stall == 1) begin
				hit <= hit;
			end
			else begin
				hit <= {hit_predict, hit[(stage-2)*width*num_table+1+:2*width*num_table]};
			end
		end
	end
	
endmodule

module Sr_address_prediction #(
	parameter stage = 3,
	parameter width_prediction = 1,
	parameter width_address = 32
)
( 
	output wire prediction_update,
	output wire [width_address:1] address_update,

	input wire prediction, 
	input wire [width_address:1] address_predict,
	input wire clk, rst, stall
);
        reg [stage*width_address:1] address;
	reg [stage*width_prediction:1] prediction_reg;
        assign address_update = address[width_address:1];
	assign prediction_update = prediction_reg[1];
        always_ff @(negedge clk) begin
                if (rst ==  1) begin
                        address <= 0;
                        prediction_reg <= 0;
                end
                else begin
			if (stall == 1) begin
				address <= address;
				prediction_reg <= prediction_reg;
			end
			else begin
				prediction_reg <= {prediction, prediction_reg [stage*width_prediction:width_prediction+1]};
                        	address <= {address_predict, address[stage*width_address:width_address+1]};
			end
                end
	end
	
endmodule

module Sr_table_prediction #(
        parameter stage = 3,
        parameter width_prediction = 16
)
(
        output wire [width_prediction:1] prediction_table_update,

        input wire [width_prediction:1] prediction_table,
        input wire clk, rst, stall
);
        reg [stage*width_prediction:1] prediction;

        assign prediction_table_update = prediction[width_prediction:1];

        always_ff @(negedge clk) begin
                if (rst ==  1) begin
                        prediction <= 0;
                end
                else begin
                        if (stall == 1) begin
                                prediction <= prediction;
                        end
                        else begin
                                prediction <= {prediction_table, prediction[(stage-2)*width_prediction+1+:2*width_prediction]};
                        end
                end
        end
	
endmodule

module Sr_index_table #(
	parameter index_width = 18,
	parameter stage =  3
)
(
	output wire [index_width:1] index_update,

	input wire [index_width:1] index_predict,
	input wire clk, rst, stall
);
	reg [stage*index_width:1] index;

	assign index_update = index[index_width:1];

	always_ff @(negedge clk) begin
		if (rst == 1) begin
			index <= 0;
		end
		else begin
			if (stall == 1) begin
				index <= index;
			end
			else begin
				index <= {index_predict, index[(stage-2)*index_width+1+:2*index_width]};
			end
		end
	end
	
endmodule

module Sr_index_BTB #(
        parameter index_width = 18,
        parameter stage =  3
)
(
        output wire [index_width:1] index_update,
	output wire uncont_update,
	
	input wire uncont_predict,
        input wire [index_width:1] index_predict,
        input wire clk, rst, stall
);
        reg [stage*index_width:1] index;
	reg [stage:1] uncont;
	
	assign uncont_update = uncont[1];
        assign index_update = index[index_width:1];

        always_ff @(negedge clk) begin
                if (rst == 1) begin
                        index <= 0;
			uncont <= 0;
                end
                else begin
                        if (stall == 1) begin
                                index <= index;
				uncont <= uncont;
                        end
                        else begin
                                index <= {index_predict, index[(stage-2)*index_width+1+:2*index_width]};
				uncont <= {uncont_predict, uncont[(stage-2)+1+:2]};
                        end
                end
        end
	
endmodule

module Update_control_signal #(
	parameter width_num_table = 4,
	parameter num_table_tagged = 15,
	parameter num_table = 16,
	parameter width_Taken = 3,
	parameter width_confidence = 2,
	parameter width_hit = 1
)
(
	output reg en_2, en_3, //For global hist true reg (correct prediction)
	output reg allocation_signal,
	output reg rst_pipeline,
	output wire [num_table:1] en_update,
	output wire [num_table:1] control,

	//Prediction
	input wire rst_pipeline_2_update,
	input wire prediction_update,		
	input wire [width_num_table:1] first_hitting_table_update,
	input wire [width_confidence:1] confidence_predict_update,
	input wire [width_Taken*num_table_tagged:1] Taken_update, NTaken_update,
	input wire [width_confidence*num_table:1] confidence_update,
	input wire [width_hit*num_table:1] hit_update,
	input wire [num_table:1] prediction_table_update,
	input wire [32:1] address_predict,
	
	input wire [32:1]PC_actual,
	input wire [32:1]inst,
	input wire Branch_direction	
);
	wire PC_check, PC_check2;
	assign PC_check = (inst[7:1] == 7'b1100011)||(inst[7:1] == 7'b1101111)||(inst[7:1] == 7'b1100111);
	assign PC_check2 = (inst[7:1] == 7'b1100111);
	
	wire [width_num_table:1] second_hitting_table;
	wire [width_confidence:1] confidence_second;
        wire  prediction_second;
	Second_hitting_detect Second_hitting_detect (
		.second_hitting_table(second_hitting_table),
		.confidence_second(confidence_second),
		.prediction_second(prediction_second),
		.prediction_table_update(prediction_table_update),
		.confidence_update(confidence_update),
        	.hit_update(hit_update)
	);
	always_comb begin
		if (PC_check2)
			en_3 = 1;
		else 
			en_3 = 0;
	end
	always_comb begin
		/*if (rst_pipeline_2_update) begin
			allocation_signal = 1;
			rst_pipeline = 1;
			en_2 = 0;
		end
		else*/ if ((prediction_update == Branch_direction) && (PC_actual==address_predict) && PC_check) begin
			allocation_signal = 0;
			rst_pipeline = 0;
			en_2 = 1;
		end
		else if (PC_check == 0) begin
			allocation_signal = 0;
                        rst_pipeline = 0;
			en_2 = 0;
		end
		else begin
			allocation_signal = 1;
			rst_pipeline = 1;
			en_2 = 0;
		end	
	end

	wire [4*num_table:1] temp;
	assign temp = {4'd15, 4'd14, 4'd13, 4'd12, 4'd11, 4'd10, 4'd9, 4'd8,
                4'd7, 4'd6, 4'd5, 4'd4, 4'd3, 4'd2, 4'd1, 4'd0};

	wire [16:1] en_update_temp, control_temp;
	genvar i;
	generate
		for (i=1; i<=16; i=i+1) begin : block_4
			Update_signal_table Update_signal_table (
				.en(en_update_temp[i]),
				.control(control_temp[i]),
				.confidence_predict_update(confidence_predict_update),
				.confidence_second(confidence_second),
				.prediction_second(prediction_second),
				.second_hitting_table(second_hitting_table), 
				.first_hitting_table_update(first_hitting_table_update), 
				.num_table(temp[i*4:i*4-3]),
				.Branch_direction(Branch_direction),
				.hit_status(hit_update[i])
			);
		end
	endgenerate

	assign en_update = en_update_temp & {16{PC_check}} & {16{rst_pipeline}};
	assign control = control_temp & {16{PC_check}};
	
endmodule

module Update_signal_table #(
	parameter width_confidence = 2,
	parameter width_num_table = 4
)
(
	output reg en,
	output reg control,

	input wire [width_confidence:1] confidence_predict_update, confidence_second,
	input wire prediction_second,
	input wire [width_num_table:1] second_hitting_table, first_hitting_table_update, num_table,
	input wire Branch_direction, hit_status	
);
	always_comb begin 
		if (hit_status == 1) begin
			if (num_table > first_hitting_table_update) begin
				en = 1;
				control = 1; //Update with branch direction
			end
			else if (num_table == first_hitting_table_update) begin
				if ((Branch_direction != prediction_second) || (confidence_predict_update != 0) || (confidence_second != 0)||(first_hitting_table_update == 0)) begin
					en = 1;
					control = 1;
				end
				else if ((confidence_predict_update == 0) && (confidence_second == 0)&& (Branch_direction == prediction_second)&&(first_hitting_table_update != 0)) begin
					en = 1;
					control = 0; //decay
				end
				else begin
					en = 0;
					control = 1;
				end

			end
			else if ((num_table == second_hitting_table)&&(num_table != 15)) begin
				if ((confidence_predict_update != 0)&&(first_hitting_table_update != 0)) begin
					en = 1;
					control = 1;
				end
				else begin
					en = 0;
					control = 1;
				end
			end
			else begin
				en = 0;
				control = 0;
			end
		end
		else begin
			en = 0;
			control = 0;
		end
	end
	
endmodule

module Second_hitting_detect #(
	parameter width_num_table = 4,
        parameter num_table_tagged = 15,
        parameter num_table = 16,
	parameter width_hit = 1,
	parameter width_confidence = 2,
	parameter width_prediction_table = 16
)
(
	output reg [width_num_table:1] second_hitting_table,
	output reg [width_confidence:1] confidence_second,
	output reg prediction_second,

	input wire [width_prediction_table:1] prediction_table_update,
	input wire [width_confidence*num_table:1] confidence_update,
	input wire [width_hit*num_table:1] hit_update
);

	wire [64:1] table_temp = {4'd15, 4'd14, 4'd13, 4'd12, 4'd11, 4'd10, 4'd9, 4'd8,
                4'd7, 4'd6, 4'd5, 4'd4, 4'd3, 4'd2, 4'd1, 4'd0};
	wire [32:1] table_temp_new;
	wire [8:1] hit_new;
	
	genvar a;
	generate 
		for (a = 1; a<=4; a=a+1) begin :block_5
			Check_4_hitting_table Check_4_hitting_table_1 (
				.hitting_table(table_temp_new[a*8:a*8-3]), 
				.second_hitting_table(table_temp_new[a*8-4:a*8-7]),
				.hit_new(hit_new[a*2:a*2-1]),
				.hit_update(hit_update[a*4:a*4-3]),
				.table_check(table_temp[a*16:a*16-15])
			);
		end
	endgenerate

	wire [16:1] table_temp_new_1;
	wire [4:1] hit_new_1;
	
	Check_4_hitting_table Check_4_hitting_table_5 (
                .hitting_table(table_temp_new_1[8:5]),
                .second_hitting_table(table_temp_new_1[4:1]),
                .hit_new(hit_new_1[2:1]),
                .hit_update(hit_new[4:1]),
                .table_check(table_temp_new[16:1])
        );

	Check_4_hitting_table Check_4_hitting_table_6 (
                .hitting_table(table_temp_new_1[16:13]),
                .second_hitting_table(table_temp_new_1[12:9]),
                .hit_new(hit_new_1[4:3]),
                .hit_update(hit_new[8:5]),
                .table_check(table_temp_new[32:17])
        );

	wire [2:1] hit_new_2;
	wire [4:1] table_temp_new_2;
	Check_4_hitting_table Check_4_hitting_table_7 (
                .hitting_table(table_temp_new_2),
                .second_hitting_table(second_hitting_table),
                .hit_new(hit_new_2),
                .hit_update(hit_new_1),
                .table_check(table_temp_new_1)
        );

	always_comb begin
		case (second_hitting_table)
			4'd0: begin
				prediction_second = prediction_table_update [1];
				confidence_second = confidence_update [2:1];
			end
			4'd1: begin
				prediction_second = prediction_table_update [2];
				confidence_second = confidence_update [4:3];
			end
			4'd2: begin
				prediction_second = prediction_table_update [3];
				confidence_second = confidence_update [6:5];
			end
			4'd3: begin 
				prediction_second = prediction_table_update [4];
				confidence_second = confidence_update [8:7];
			end
			4'd4: begin
				prediction_second = prediction_table_update [5];
				confidence_second = confidence_update [10:9];
			end
			4'd5: begin
				prediction_second = prediction_table_update [6];
				confidence_second = confidence_update [12:11];
			end
			4'd6: begin
				prediction_second = prediction_table_update [7];
				confidence_second = confidence_update [14:13];
			end
			4'd7: begin
				prediction_second = prediction_table_update [8];
				confidence_second = confidence_update [16:15];
			end
			4'd8: begin
				prediction_second = prediction_table_update [9];
				confidence_second = confidence_update [18:17];
			end
			4'd9: begin
				prediction_second = prediction_table_update [10];
				confidence_second = confidence_update [20:19];
			end
			4'd10: begin
				prediction_second = prediction_table_update [11];
				confidence_second = confidence_update [22:21];
			end
			4'd11: begin
				prediction_second = prediction_table_update [12];
				confidence_second = confidence_update [24:23];
			end
			4'd12: begin 
				prediction_second = prediction_table_update [13];
				confidence_second = confidence_update [26:25];
			end
			4'd13: begin
				prediction_second = prediction_table_update [14];
				confidence_second = confidence_update [28:27];
			end
			4'd14:	begin
				prediction_second = prediction_table_update [15];
				confidence_second = confidence_update [30:29];
			end
			default: begin 
				prediction_second = 0;
				confidence_second = 3;
			end
		endcase
	end

endmodule

module Check_4_hitting_table (
	output reg [4:1] hitting_table, second_hitting_table,
	output reg [2:1] hit_new,
	input wire [4:1] hit_update,
	input wire [16:1] table_check
);
	always_comb begin 
		case (hit_update) 
			4'd1: begin
				hit_new = 2'b10;
				hitting_table = table_check [4:1];
				second_hitting_table = 15;
			end
			4'd2: begin
				hit_new = 2'b10;
                                hitting_table = table_check [8:5];
                                second_hitting_table = 15;
			end
			4'd3: begin
				hit_new = 2'b11;
                                hitting_table = table_check [8:5];
                                second_hitting_table = table_check[4:1];
                        end
                        4'd4: begin
				hit_new = 2'b10;
                                hitting_table = table_check [12:9];
                                second_hitting_table = 15;
                        end
			4'd5: begin
				hit_new = 2'b11;
                                hitting_table = table_check [12:9];
                                second_hitting_table = table_check[4:1];
                        end
                        4'd6: begin
				hit_new = 2'b11;
                                hitting_table = table_check [12:9];
                                second_hitting_table = table_check[8:5];
                        end
			4'd7: begin
				hit_new = 2'b11;
                                hitting_table = table_check [12:9];
                                second_hitting_table = table_check[8:5];
                        end
                        4'd8: begin
				hit_new = 2'b10;
                                hitting_table = table_check [16:13];
                                second_hitting_table = 15;
                        end
                        4'd9: begin
				hit_new = 2'b11;
                                hitting_table = table_check [16:13];
                                second_hitting_table = table_check[4:1];
                        end
                        4'd10: begin
				hit_new = 2'b11;
                                hitting_table = table_check [16:13];
                                second_hitting_table = table_check[8:5];
                        end
                        4'd11: begin
				hit_new = 2'b11;
                                hitting_table = table_check [16:13];
                                second_hitting_table = table_check[8:5];
                        end
                        4'd12: begin
				hit_new = 2'b11;
                                hitting_table = table_check [16:13];
                                second_hitting_table = table_check[12:9];
                        end
			4'd13: begin
				hit_new = 2'b11;
                                hitting_table = table_check [16:13];
                                second_hitting_table = table_check[12:9];
                        end
                        4'd14: begin
				hit_new = 2'b11;
                                hitting_table = table_check [16:13];
                                second_hitting_table = table_check[12:9];
                        end
                        4'd15: begin
				hit_new = 2'b11;
                                hitting_table = table_check [16:13];
                                second_hitting_table = table_check[12:9];
                        end
			default begin
				hit_new = 2'b00;
                                hitting_table = 15;
                                second_hitting_table = 15;
			end
		endcase
	end
endmodule
module Allocation_component #(
        parameter width_num_table = 4,
        parameter num_table_tagged = 15,
        parameter num_table = 16,
        parameter width_Taken = 3,
        parameter width_confidence = 2,
        parameter width_hit = 1
)
(
	output reg [num_table_tagged:1] en_allocation,
       	output reg [num_table_tagged:1] decay,

	input wire  [width_num_table:1] first_hitting_table_update,
        input wire allocation_signal,
	input wire [num_table_tagged*width_Taken:1] Taken_update, NTaken_update,
	input wire clk, rst
);
	wire [num_table:1] mhc_signal, high_confidence;
	Check_mhc_confidence Check_mhc_confidence(
       		.mhc_signal(mhc_signal),
		.high_confidence(high_confidence),
        	.Taken_update(Taken_update), 
		.NTaken_update(NTaken_update)
	);
	
	wire condition;
        wire [5:1] r;
	reg [9:1] cat;	
	Check_allocation_probability Check_allocation_probability (
        	.condition(condition),
        	.r(r),
        	.cat(cat)
	);	
	
	wire [9:1] cat_new;
	wire [4:1] mhc;
	Cat_counter_update Cat_counter_update (
        	.cat_new(cat_new),
      		.cat(cat),
        	.mhc(mhc)
	);
	
	Random_r Random_r (
        	.r(r),
        	.reset(rst),
        	.clk(clk)
	);
	
	wire [2:1] s;
	Random_s Random_s (
                .s(s),
                .reset(rst),
                .clk(clk)
        );

	wire signal;
	Random_PDEC Random_PDEC (
        	.signal(signal),
        	.reset(rst),
       		.clk(clk)
	);

	wire [4:1] table_allocation;
	wire [num_table:1] count_mhc, table_allocation_check;
	Mhc_count_table_allocation Mhc_count_table_allocation (
		.mhc(mhc),
        	.table_allocation(table_allocation),
		.count_mhc(count_mhc),
		.table_allocation_check(table_allocation_check),
		.first_hitting_table_update(first_hitting_table_update),
        	.mhc_signal(mhc_signal), 
		.high_confidence(high_confidence),
        	.allocation_signal(allocation_signal),
        	.s(s)
	);

	always_comb begin
		if ( (allocation_signal) & (condition) ) begin
			en_allocation = table_allocation_check[16:2];
			decay = count_mhc[16:2]&{15{signal}};  //use only 1 pdec random
		end
		else begin
			en_allocation = 0;
			decay = 0;
		end
	end

	always_ff @(negedge clk) begin
		if ( (allocation_signal) & (condition) ) begin
			//cat <= cat_new;
			cat <= 0;
		end
		else if (rst == 1) begin
			cat <= 0;
		end
		else begin
			cat <= cat;
		end
	end
	
endmodule

module Mhc_count_table_allocation #(
        parameter width_num_table = 4,
        parameter num_table_tagged = 15,
        parameter num_table = 16,
        parameter width_Taken = 3,
        parameter width_confidence = 2,
        parameter width_hit = 1
)
(
	output wire [4:1] mhc,
	output wire [4:1] table_allocation,
	output wire [num_table:1] count_mhc, table_allocation_check,	

	input wire  [width_num_table:1] first_hitting_table_update,
	input wire [num_table:1] mhc_signal, high_confidence,
	input wire allocation_signal,
	input wire [2:1] s
);
	wire [5:1] first_check_table;
	Full_adder_5_bit Full_adder_5_bit (
       		.out(first_check_table),
		.in_1({1'b0,first_hitting_table_update}), 
		.in_2({3'd0,s}),
        	.cin(1'b0)
	);

	wire [5*num_table:1] temp;
        assign temp = {5'd15, 5'd14, 5'd13, 5'd12, 5'd11, 5'd10, 5'd9, 5'd8,
                5'd7, 5'd6, 5'd5, 5'd4, 5'd3, 5'd2, 5'd1, 5'd0};

	reg [num_table:1] table_above_first_check_one;
	wire [num_table:1] table_check;
	always_comb begin
		for (int i=1; i<=16; i=i+1) begin
			if (temp[i*5-4+:5] >= first_check_table) begin
				table_above_first_check_one [i] = 1;
			end
			else begin
				table_above_first_check_one [i] = 0;
			end
		end	
	end
	
	assign table_check = table_above_first_check_one & {~high_confidence[16:2],1'b0};

	Allocation_table_detect Allocation_table_detect (
		.mhc(mhc),
		.count_mhc(count_mhc),
		.table_allocation_check(table_allocation_check),
		.table_allocation(table_allocation),
		.table_check(table_check),
		.mhc_signal(mhc_signal),
		.first_check_table(first_check_table)
	);
	
endmodule
module Allocation_table_detect #(
	parameter num_table = 16
)
(
	output wire [4:1] mhc,
	output reg [4:1] table_allocation,
	output reg [num_table:1] count_mhc, table_allocation_check,
	
	input wire [num_table:1] table_check, mhc_signal,
	input wire [5:1] first_check_table
);
	wire [64:1] temp_table;
	wire [4:1] temp_signal;
	wire [16:1] temp_table_allocation;
	assign temp_table = {4'd15, 4'd14, 4'd13, 4'd12, 4'd11, 4'd10, 4'd9, 4'd8,
                4'd7, 4'd6, 4'd5, 4'd4, 4'd3, 4'd2, 4'd1, 4'd0};
	genvar a;
	generate
		for (a=1; a<=4; a=a+1) begin : block_6
			Check_4_table_for_allocation Check_4_table_for_allocation (
				.table_allocation_check(temp_table_allocation[a*4-3+:4]),
				.signal(temp_signal[a]),
				.table_check(table_check[a*4-3+:4]),
				.num_table_check(temp_table[a*16-15+:16])
			);
		end
	endgenerate

	wire temp_signal_2;
	Check_4_table_for_allocation Check_4_table_for_allocation_2 (
		.table_allocation_check(table_allocation),
		.signal(temp_signal_2),
		.table_check(temp_signal),
		.num_table_check(temp_table_allocation)
	);
	
	Decoder_4_to_16 Decoder_4_to_16 (
        	.out(table_allocation_check),
       		.in(table_allocation)
	);

	wire [5*num_table:1] temp;
        assign temp = {5'd15, 5'd14, 5'd13, 5'd12, 5'd11, 5'd10, 5'd9, 5'd8,
                5'd7, 5'd6, 5'd5, 5'd4, 5'd3, 5'd2, 5'd1, 5'd0};
	
	always_comb begin
		for (int i=1; i<=16; i=i+1) begin
			if ((temp[i*5-4+:5] >= first_check_table) && (temp[i*5-4+:5] < {1'b0,table_allocation})) begin
				if (mhc_signal[i] == 1) begin
					count_mhc[i] = 1;
				end
				else begin
					count_mhc[i] = 0;
				end
			end
			else begin
				count_mhc[i] = 0;
			end
		end
	end

	Add_16_bit Add_16_bit (
		.out(mhc),
		.in(count_mhc)
	);
	
endmodule

module Decoder_4_to_16(
	output reg [16:1] out,
	input wire [4:1] in
);
	always_comb begin
		case (in)
                        4'd1: begin
                        	out = 16'd2;	
			end
                        4'd2: begin
				out = 16'd4;
                        end
                        4'd3: begin
				out = 16'd8;
                        end
                        4'd4: begin
				out = 16'd16;
                        end
                        4'd5: begin
				out = 16'd32;
                        end
                        4'd6: begin
				out = 16'd64;
                        end
                        4'd7: begin
				out = 16'd128;
                        end
                        4'd8: begin
				out = 16'd256;
                        end
                        4'd9: begin
				out = 16'd512;
                        end
                        4'd10: begin
				out = 16'd1024;
                        end
                        4'd11: begin
				out = 16'd2048;
                        end
                        4'd12: begin
				out = 16'd4096;
			end
                        4'd13: begin
				out = 16'd8192;
                        end
                        4'd14: begin
				out = 16'd16384;
                        end
                        4'd15: begin
				out = 16'd32768;
                        end
                        default begin //0
				out = 0;
                        end
                endcase
	end	
endmodule

module Check_4_table_for_allocation (
	output reg [4:1] table_allocation_check,
	output reg signal,
	input wire [4:1] table_check,
	input wire [16:1] num_table_check
);
	always_comb begin 
		case (table_check)
			4'd1: begin
				table_allocation_check = num_table_check [4:1];
				signal = 1;
			end
			4'd2: begin
				table_allocation_check = num_table_check [8:5];
                                signal = 1;
			end
			4'd3: begin 
				table_allocation_check = num_table_check [4:1];
                                signal = 1;
			end
			4'd4: begin
				table_allocation_check = num_table_check [12:9];
                                signal = 1;
			end
			4'd5: begin
				table_allocation_check = num_table_check [4:1];
                                signal = 1;
			end
			4'd6: begin
				table_allocation_check = num_table_check [8:5];
                                signal = 1;
                        end
                        4'd7: begin
				table_allocation_check = num_table_check [4:1];
                                signal = 1;
                        end
                        4'd8: begin
				table_allocation_check = num_table_check [16:13];
                                signal = 1;
                        end
                        4'd9: begin
				table_allocation_check = num_table_check [4:1];
                                signal = 1;
                        end
                        4'd10: begin
				table_allocation_check = num_table_check [8:5];
                                signal = 1;
                        end
			4'd11: begin
				table_allocation_check = num_table_check [4:1];
                                signal = 1;
                        end
                        4'd12: begin
				table_allocation_check = num_table_check [12:9];
                                signal = 1;
                        end
                        4'd13: begin
				table_allocation_check = num_table_check [4:1];
                                signal = 1;
                        end
                        4'd14: begin
				table_allocation_check = num_table_check [8:5];
                                signal = 1;
                        end
                        4'd15: begin
				table_allocation_check = num_table_check [4:1];
                                signal = 1;
                        end
			default begin //0
				table_allocation_check = 0;
                                signal = 0;
			end
		endcase	
	end
endmodule

module Add_16_bit (
	output wire [4:1] out,
	input wire [16:1] in
);
	wire [20:1] temp_1;
	genvar i;
	generate
		for (i=1; i<=5; i=i+1) begin : block_7
			Full_adder_4_bit Full_adder_4_bit (
				.out(temp_1[i*4-3+:4]),
				.in_1({3'd0,in[i*3-2]}),
				.in_2({3'd0,in[i*3-1]}),
				.c_in(in[i*3])
			);
		end
	endgenerate
	wire [12:1] temp_2;
        wire [4:1] temp_3;
        Full_adder_4_bit Full_adder_4_bit_2 (
                .out(temp_2[4:1]),
                .in_1(temp_1[4:1]),
                .in_2(temp_1[8:5]),
                .c_in(in[16])
        );
        Full_adder_4_bit Full_adder_4_bit_3 (
                .out(temp_2[8:5]),
                .in_1(temp_1[12:9]),
                .in_2(temp_1[16:13]),
                .c_in(1'b0)
        );
        Full_adder_4_bit Full_adder_4_bit_4 (
                .out(temp_3),
                .in_1(temp_2[8:5]),
                .in_2(temp_2[4:1]),
                .c_in(1'b0)
        );
        Full_adder_4_bit Full_adder_4_bit_5 (
                .out(out),
                .in_1(temp_1[20:17]),
                .in_2(temp_3),
                .c_in(1'b0)
        );	
endmodule

module Full_adder_5_bit (
        output reg [5:1] out,

        input wire [5:1] in_1, in_2,
        input wire cin
);
        always_comb begin
                out = in_1 + in_2 + cin;
        end
endmodule


module Check_allocation_probability (
	output wire condition,
	input wire [5:1] r,
	input wire [9:1] cat
);
	assign condition = ( {2'd0,r,7'd0} >= {cat, 5'd0} );
endmodule

module Cat_counter_update (
	output reg [9:1] cat_new,

	input wire [9:1] cat,
	input wire [4:1] mhc
);
	wire [9:1] cat_plus_3, cat_update_mhc;
	reg [9:1] max_0_cat;

	Full_adder_9_bit_BATAGE Full_adder_9_bit (
		.out(cat_plus_3),
		.in_1(cat),
		.in_2(9'd3),
		.cin(1'b0)
	);
	Full_adder_9_bit_BATAGE Full_adder_9_bit_1 (
                .out(cat_update_mhc),
                .in_1(cat_plus_3),
                .in_2(~{3'd0,mhc,2'd0}),
                .cin(1'b1)
        );

	always_comb begin
		if ($signed(cat_update_mhc) >= $signed(9'd0)) 
			max_0_cat = cat_update_mhc;
		else 
			max_0_cat = 9'd0;
	end
	always_comb begin
		if ($signed(max_0_cat) > $signed(9'd127))
			cat_new = 9'd127;
		else
			cat_new = max_0_cat;
	end
	
endmodule

module Full_adder_9_bit_BATAGE (
        output reg [9:1] out,

        input wire [9:1] in_1, in_2,
        input wire cin
);
        always_comb begin
                out = in_1 + in_2 + cin;
        end
endmodule

module Random_r (
   	output reg [5:1] r,
	input wire reset,
	input wire clk
);

	wire feedback;
	
	assign feedback =  r[1] ^ (r[5:2]==0);
    	always_ff @(negedge clk) begin
        	if (reset)
            		r <= 5'd1;
        	else
            		r <= {(feedback^r[3]), r[5], r[4], r[3], r[2]};
    	end
	
endmodule

module Random_s (
	output wire [2:1] s,
        input wire reset,
        input wire clk
);
	reg [3:1] r;
	assign s[2] = r[3];
	assign s[1] = r[2]&r[1]|~r[3];

        always_ff @(negedge clk) begin
                if (reset)
                        r <= 3'd1;
                else
                        r <= {(r[1]^r[2]), r[3], r[2]};
			
        end
	
endmodule

module Random_PDEC (
	output wire signal,

	input wire reset,
	input wire clk
);
	reg [4:1] r;
	wire feedback;

	assign feedback = r[1] ^ r[4:2]==0;
	assign signal = (r <= 4'd3);

	always_ff @(negedge clk) begin
		if (reset)
			r <= 4'd1;
		else
			r <= {(feedback^r[4]), r[4], r[3], r[2]};
	end
	`ifdef FORMAL
		logic [4:1] a = $anyseq;
		always_comb begin
			cover (r == a);
		end
	`endif
endmodule

module Check_mhc_confidence #(
	parameter num_table =16,
	parameter num_table_tagged =15,
	parameter width = 3
)
(
	output reg [num_table:1] mhc_signal, high_confidence,

	input wire [num_table_tagged*width:1] Taken_update, NTaken_update
);
	wire [width*2*num_table_tagged:1] Taken_update_5_time, NTaken_update_5_time, Taken_update_2_time, NTaken_update_2_time;
	
	genvar j;
	generate
		for (j=1; j<=num_table_tagged; j=j+1) begin : block_8
			Full_adder_6_bit Full_adder_6_bit (
				.out(Taken_update_2_time[width*2*j:width*2*j-5]),
				.in_1({3'd0,Taken_update[width*j:width*j-2]}),
				.in_2({3'd0,Taken_update[width*j:width*j-2]}),
				.cin(1'b1)
			);
			Full_adder_6_bit Full_adder_6_bit_1 (
                                .out(NTaken_update_2_time[width*2*j:width*2*j-5]),
                                .in_1({3'd0,NTaken_update[width*j:width*j-2]}),
                                .in_2({3'd0,NTaken_update[width*j:width*j-2]}),
                                .cin(1'b1)
                        );
			Multiply_5_add_4 Multiply_5_add_4 (
				.out(Taken_update_5_time[width*2*j:width*2*j-5]),
				.in_1({3'd0,Taken_update[width*j:width*j-2]})
			);
			Multiply_5_add_4 Multiply_5_add_4_1 (
                                .out(NTaken_update_5_time[width*2*j:width*2*j-5]),
                                .in_1({3'd0,NTaken_update[width*j:width*j-2]})
                        );
		end
	endgenerate

	always_comb begin
		mhc_signal[1] = 0;
		high_confidence[1]=0;
		for (int i=1; i<=num_table_tagged; i=i+1) begin
			mhc_signal[i+1] = ( (Taken_update_2_time[i*6-5+:6] < NTaken_update[i*3-2+:3])  && (NTaken_update[i*3-2+:3]<=Taken_update_5_time[i*6-5+:6]) ) || ( (NTaken_update_2_time[i*6-5+:6] < Taken_update[i*3-2+:3])  && (Taken_update[i*3-2+:3] <= NTaken_update_5_time[i*6-5+:6]) );	
			high_confidence[i+1] = (Taken_update_2_time[i*6-5+:6] < NTaken_update[i*3-2+:3]) || (NTaken_update_2_time[i*6-5+:6] < Taken_update[i*3-2+:3]);
		end
	end

	
endmodule

module Multiply_5_add_4 (
	output wire [6:1] out,
	input wire [6:1] in_1
);
	
	wire [6:1] in_1_2_time, in_1_2_time_1, in_1_4_time;
	Full_adder_6_bit Full_adder_6_bit_1 (
		.out(in_1_2_time),
		.in_1(in_1),
		.in_2(in_1),
		.cin(1'b1)
	);
	Full_adder_6_bit Full_adder_6_bit_2 (
                .out(in_1_2_time_1),
                .in_1(in_1),
                .in_2(in_1),
                .cin(1'b1)
        );
	Full_adder_6_bit Full_adder_6_bit_3 (
                .out(in_1_4_time),
                .in_1(in_1_2_time),
                .in_2(in_1_2_time_1),
                .cin(1'b1)
        );
	Full_adder_6_bit Full_adder_6_bit_4 (
                .out(out),
                .in_1(in_1_4_time),
                .in_2(in_1),
                .cin(1'b1)
        );
	
endmodule

module Full_adder_6_bit (
	output reg [6:1] out,

	input wire [6:1] in_1, in_2,
	input wire cin
);
	always_comb begin
		out = in_1 + in_2 + cin; 
	end
endmodule
module Table_update_tagless #(
	parameter width = 3
)
(
	output reg [width:1] weight_new,
        input wire en, control,
        input wire [width:1] weight_update,
	input wire Branch_direction
);
	wire [width:1] weight;
	Update_with_branch_direction_tagless Update_with_branch_direction_tagless (
		.weight_new(weight),
		.weight_update(weight_update),
		.Branch_direction(Branch_direction)
	);
	always_comb begin 
		if (en & control)
			weight_new = weight;
		else
			weight_new = weight_update;
	end
	
endmodule

module Table_update_tagged #(
	parameter width = 3,
	parameter num_table_tagged = 15
)
(
	output reg [width*num_table_tagged:1] Taken_new, NTaken_new,
	output reg [num_table_tagged:1] en, //Enable update counter NT,T only
	
	input wire Branch_direction,
	input wire [num_table_tagged:1] en_allocation, decay,
	input wire [num_table_tagged:1] en_update, control, 
	input wire [width*num_table_tagged:1] Taken_update, NTaken_update
);
	wire [width*num_table_tagged:1] Taken_update_with_direction, NTaken_update_with_direction, Taken_decay, NTaken_decay;

	genvar i; 
	generate
		for (i = 1; i<=15; i=i+1) begin : block_9
			Update_with_branch_direction_tagged Update_with_branch_direction_tagged (
				.NTaken_new(NTaken_update_with_direction[i*3:i*3-2]),
				.Taken_new(Taken_update_with_direction[i*3:i*3-2]),
				.NTaken_update(NTaken_update[i*3:i*3-2]),
				.Taken_update(Taken_update[i*3:i*3-2]),
				.Branch_direction(Branch_direction)
			);
			Decay Decay (
				.NTaken_new(NTaken_decay[i*3:i*3-2]),
                                .Taken_new(Taken_decay[i*3:i*3-2]),
                                .NTaken_update(NTaken_update[i*3:i*3-2]),
                                .Taken_update(Taken_update[i*3:i*3-2])
			);
		end
	endgenerate

	assign en = en_allocation | en_update ;
	always_comb begin
		for (int j=1; j<=15; j=j+1) begin
			if (en_update[j]) begin
				if (control[j]) begin
					Taken_new [j*3-2+:3] = Taken_update_with_direction[j*3-2+:3];
					NTaken_new [j*3-2+:3] = NTaken_update_with_direction[j*3-2+:3];
				end
				else begin
					Taken_new [j*3-2+:3] = Taken_decay [j*3-2+:3];
					NTaken_new [j*3-2+:3] = NTaken_decay [j*3-2+:3];
				end
			end
			else if (en_allocation[j]) begin
				Taken_new [j*3-2+:3] = {2'd0, Branch_direction};
				NTaken_new [j*3-2+:3] = {2'd0, ~Branch_direction};
			end
			else if (decay[j]) begin
				Taken_new [j*3-2+:3] = Taken_decay [j*3-2+:3];
				NTaken_new [j*3-2+:3] =  NTaken_decay [j*3-2+:3];
			end
			else begin
				Taken_new [j*3-2+:3] = Taken_update [j*3-2+:3];
                                NTaken_new [j*3-2+:3] = NTaken_update [j*3-2+:3];
			end
		end			
	end
	
endmodule

module Update_with_branch_direction_tagless #(
       	parameter width = 3
)
(
	output reg [width:1] weight_new,
	input wire [width:1] weight_update,
	input wire Branch_direction
);
	wire [width:1] weight_inc, weight_dec;
        Counter_inc_tagless Counter_inc_1 (
                .out(weight_inc),
                .in(weight_update)
        );
        Counter_dec_tagless Counter_dec_2 (
                .out(weight_dec),
                .in(weight_update)
        );

	always_comb begin
		if (Branch_direction) begin
			weight_new =  weight_inc;
		end
		else begin
			weight_new = weight_dec;
		end
	end
	
endmodule
module Update_with_branch_direction_tagged #(
	parameter width = 3
)
(
	output reg [width:1] NTaken_new,
        output reg [width:1] Taken_new,

        input wire [width:1] NTaken_update,
        input wire [width:1] Taken_update,
	input wire Branch_direction
);
	wire [width:1] NTaken_dec, Taken_dec;
        Counter_dec Counter_dec_1 (
                .out(NTaken_dec),
                .in(NTaken_update)
        );
        Counter_dec Counter_dec_2 (
                .out(Taken_dec),
                .in(Taken_update)
        );
	
	wire [width:1] NTaken_inc, Taken_inc;
        Counter_inc Counter_inc_1 (
                .out(NTaken_inc),
                .in(NTaken_update)
        );
        Counter_inc Counter_inc_2 (
                .out(Taken_inc),
                .in(Taken_update)
        );

	always_comb begin
		if (Branch_direction) begin
			if (Taken_update < 7) begin
				Taken_new = Taken_inc;
				NTaken_new = NTaken_update;
			end	
			else if (NTaken_update > 0) begin
				Taken_new = Taken_update;
                                NTaken_new = NTaken_dec;
			end
			else begin
				Taken_new = Taken_update;
                                NTaken_new = NTaken_update;
			end	
		end
		else begin
			if (NTaken_update < 7) begin
                                Taken_new = Taken_update;
                                NTaken_new = NTaken_inc;
                        end
                        else if (Taken_update > 0) begin
                                Taken_new = Taken_dec;
                                NTaken_new = NTaken_update;
                        end
                        else begin
                                Taken_new = Taken_update;
                                NTaken_new = NTaken_update;
                        end
		end
	end
	
endmodule
module Decay #(
	parameter width = 3
)
(
	output reg [width:1] NTaken_new,
	output reg [width:1] Taken_new,

	input wire [width:1] NTaken_update,
	input wire [width:1] Taken_update

);
	wire [width:1] NTaken_dec, Taken_dec;
	Counter_dec Counter_dec_1 (
		.out(NTaken_dec),
		.in(NTaken_update)
	);
	Counter_dec Counter_dec_2 (
                .out(Taken_dec),
                .in(Taken_update)
        );
	always_comb begin
		if (NTaken_update > Taken_update) begin
			Taken_new = Taken_update;
			NTaken_new = NTaken_dec;
		end
		else if (NTaken_update < Taken_update) begin
			NTaken_new = NTaken_update;
			Taken_new = Taken_dec;
		end
		else begin
			Taken_new = Taken_update;
			NTaken_new = NTaken_update;
		end
	end
	
endmodule

module Counter_dec #(
	parameter width =3
)
(
	output reg [width:1] out,

	input wire [width:1] in
);
	always_comb begin
		case (in)
			3'd0:   out = 3'd0;
			3'd1:   out = 3'd0;
			3'd2:   out = 3'd1;
			3'd3:   out = 3'd2;
			3'd4:   out = 3'd3;
			3'd5:   out = 3'd4;
			3'd6:   out = 3'd5;
			default:out = 3'd6;
		endcase
	end
	
endmodule

module Counter_inc #(
        parameter width =3
)
(
        output reg [width:1] out,

        input wire [width:1] in
);
        always_comb begin
                case (in)
                        3'd0:   out = 3'd1;
                        3'd1:   out = 3'd2;
                        3'd2:   out = 3'd3;
                        3'd3:   out = 3'd4;
                        3'd4:   out = 3'd5;
                        3'd5:   out = 3'd6;
                        3'd6:   out = 3'd7;
                        default:out = 3'd7;
                endcase
        end
	
endmodule

module Counter_dec_tagless #(
	parameter width =3
)
(
	output reg [width:1] out,

	input wire [width:1] in
);
	always_comb begin
		case (in)
			3'd0:   out = 3'd7;
			3'd1:   out = 3'd0;
			3'd2:   out = 3'd1;
			3'd3:   out = 3'd2;
			3'd4:   out = 3'd4;
			3'd5:   out = 3'd4;
			3'd6:   out = 3'd5;
			default:out = 3'd6;
		endcase
	end
	
endmodule

module Counter_inc_tagless #(
        parameter width =3
)
(
        output reg [width:1] out,

        input wire [width:1] in
);
        always_comb begin
                case (in)
                        3'd0:   out = 3'd1;
                        3'd1:   out = 3'd2;
                        3'd2:   out = 3'd3;
                        3'd3:   out = 3'd3;
                        3'd4:   out = 3'd5;
                        3'd5:   out = 3'd6;
                        3'd6:   out = 3'd7;
                        default:out = 3'd0;
                endcase
        end
	
endmodule

module Global_hist_reg #(
        parameter history_length = 1347
)
(
        output reg [history_length:1] Global_hist_iterative,
        output wire [history_length:1] Global_hist_true_1,

        input wire Global_hist_update_iterative,
        input wire Global_hist_update,
        input wire en_1,                                        // Enable update iterative
        input wire en_2_miss,                                   // Enable update iterative reg with true reg
        input wire en_2,                                        // Enable update true reg
        input wire clk, rst, stall
);
        reg [history_length:1] Global_hist_true;
        assign Global_hist_true_1 = Global_hist_true;
        always_ff @(negedge clk) begin
                if (rst == 1)
                        Global_hist_iterative <= 0;
                else begin
                        if ((en_1 ==1)  && (en_2_miss == 0) && (stall == 0))
                                Global_hist_iterative <= {Global_hist_update_iterative,Global_hist_iterative[history_length:2]};
                        else if (en_2_miss == 1)
                                Global_hist_iterative <= Global_hist_true;
                        else
                                Global_hist_iterative <=  Global_hist_iterative ;
                end
        end
        always_ff @(negedge clk) begin
                if (rst == 1)
                        Global_hist_true <= 0;
                else begin
                        if (en_2 ==1)
                                Global_hist_true <= {Global_hist_update, Global_hist_true[history_length:2]};
                        else
                                Global_hist_true <= Global_hist_true;
                end
        end
	
endmodule

module Branch_address_reg_BATAGE #(
	parameter path_length = 27
)
(
	output reg [path_length:1] Branch_address_bits_iterative,
	output wire [path_length:1] Branch_address_bits_true_1,

	input wire [32:1] Branch_address_update_iterative,   
	input wire [32:1] Branch_address_update,		// input of PC reg in CPU design
	input wire clk, en_1, en_2, rst, en_2_miss, stall
);
	reg [path_length:1] Branch_address_bits_true;	// reg two update only from result at EX
	wire Branch_address_bits_update_iterative;
	wire Branch_address_bits_update;

	assign Branch_address_bits_true_1 = Branch_address_bits_true;
	Compute_path_bit Compute_path_bit (
		.represent_bit(Branch_address_bits_update_iterative),
		.address(Branch_address_update_iterative)
	);
	Compute_path_bit Compute_path_bit_2 (
                .represent_bit(Branch_address_bits_update),
                .address(Branch_address_update)
        );

	always_ff @(negedge clk) begin
		if (rst == 1)
			Branch_address_bits_iterative <= 0;
		else begin
			if ((en_1 ==1)  && (en_2_miss == 0)&& (stall == 0))
				Branch_address_bits_iterative <= {Branch_address_bits_update_iterative,Branch_address_bits_iterative[path_length:2]};
			else if (en_2_miss == 1)
				Branch_address_bits_iterative <= Branch_address_bits_true;
			else
				Branch_address_bits_iterative <= Branch_address_bits_iterative ;
		end
	end
	always_ff @(negedge clk) begin
		if (rst ==1)
			Branch_address_bits_true <= 0;
		else begin
			if (en_2 ==1)
				Branch_address_bits_true <= {Branch_address_bits_update, Branch_address_bits_true[path_length:2]};
			else
				Branch_address_bits_true <= Branch_address_bits_true;
		end
	end
	

endmodule

module Compute_path_bit #(
	parameter width = 32
)
(
	output wire represent_bit,

	input wire [width:1] address
);
	wire [16:1] address_temp;

	assign address_temp = address[16:1] ^ address[32:17];

	wire [8:1] address_temp_2;

	assign address_temp_2 = address_temp[8:1] ^ address_temp[16:9];

	wire [4:1] address_temp_3;

	assign address_temp_3 = address_temp_2[4:1] ^ address_temp_2[8:5];

	wire [2:1] address_temp_4;

	assign address_temp_4 =  address_temp_3[2:1] ^ address_temp_3[4:3];
	assign represent_bit = address_temp_4[2] ^ address_temp_4[1];
	
endmodule

module Index_component #(
	parameter longest_history_length = 1347,
	parameter history_length = 1347,
        parameter tag_width = 15,	//T_address_width = Tag_width + index_width
        parameter index_width = 8,
	parameter T_address_width = 23,
	parameter path_length = 27,
	parameter longest_path_length = 49 * 32
)
(
	output wire [index_width+tag_width:1] index, 
	
	input wire [longest_path_length:1] Path_hist_iterative, Path_hist_true,
	input wire [longest_history_length:1] Global_hist_iterative, Global_hist_true,
       	input wire [32:1] PC_in,	
        input wire clk, rst, stall, en_1, en_2, en_2_miss
);
	//Path history 
	wire [longest_path_length:1] Path_hist_iterative_2;
	assign Path_hist_iterative_2 [path_length*32:1] = Path_hist_iterative [path_length*32:1];
	assign Path_hist_iterative_2 [longest_path_length:path_length*32+1] = 0;
	
	wire [longest_path_length:1] Path_hist_iterative_3;
	assign Path_hist_iterative_3[longest_path_length:longest_path_length-31] = 0;
	
	genvar i;
	generate
		for (i=longest_path_length/32-1; i>=1; i=i-1) begin : generate_block_identifier_2
			assign	Path_hist_iterative_3 [32*i-31+:32] = /*Path_hist_iterative_3 [32*(i+1)-31+:32] ^*/ Path_hist_iterative_2 [32*i-31+:32];
		end
	endgenerate	
	wire [32:1] Path_hist_iterative_4 = Path_hist_iterative_3 [32:1];
	
	//Global history 
	localparam int num = history_length / 32 + 1;
	
	wire [(num+1)*32:1] Global_hist_iterative_2;
	assign Global_hist_iterative_2 [history_length:1] = Global_hist_iterative [history_length:1];
	assign Global_hist_iterative_2 [(num+1)*32:history_length+1] = 0;
	
	wire [(num+1)*32:1] Global_hist_iterative_3;
	assign Global_hist_iterative_3[(num+1)*32:history_length+1] = 0;
	
	generate
		for ( i=num; i>=1; i=i-1) begin : generate_block_identifier
			assign	Global_hist_iterative_3 [32*i-31+:32] = /*Global_hist_iterative_3 [32*(i+1)-31+:32] ^*/ Global_hist_iterative_2 [32*i-31+:32];
		end
	endgenerate
	wire [index_width:1] Global_hist_iterative_4 = Global_hist_iterative_3 [index_width:1] ^ Global_hist_iterative_3 [32:index_width+1];
	wire [tag_width:1] Global_hist_iterative_5 = Global_hist_iterative_3 [tag_width:1] ^ Global_hist_iterative_3 [32:tag_width+1];

	reg [index_width:1] index_temp;
	reg [tag_width:1] Tag;
	wire [index_width:1] Folded_hist_index_iterative, Path_hist_index_iterative;
        wire [tag_width:1] Folded_hist_tag_iterative, Path_hist_tag_iterative;
        wire [tag_width-1:1] Folded_hist_tag_iterative_2, Path_hist_tag_iterative_2;
	Circular_Buffer #(
		longest_history_length,
		history_length,
		tag_width,
		index_width,
		path_length,
		longest_path_length
	) Circular_Buffer (
		.Folded_hist_index_iterative(Folded_hist_index_iterative),
		.Path_hist_index_iterative(Path_hist_index_iterative),
		.Folded_hist_tag_iterative(Folded_hist_tag_iterative),
		.Path_hist_tag_iterative(Path_hist_tag_iterative),
		.Folded_hist_tag_iterative_2(Folded_hist_tag_iterative_2),
		.Path_hist_tag_iterative_2(Path_hist_tag_iterative_2),
		.Path_hist_iterative(Path_hist_iterative),
		.Path_hist_true(Path_hist_true),
		.Global_hist_iterative(Global_hist_iterative),
		.Global_hist_true(Global_hist_true),
		.en_1(en_1),
		.en_2(en_2),
		.en_2_miss(en_2_miss),
		.stall(stall),
		.rst(rst),
		.clk(clk)
	);

	always_comb begin
		
		index_temp = Folded_hist_index_iterative ^ Path_hist_index_iterative ^PC_in [index_width:3] ^ PC_in [index_width+1+:index_width] ^ Path_hist_iterative_4 [index_width+2:3] ^ Global_hist_iterative_4;
		Tag = Folded_hist_tag_iterative ^ Path_hist_tag_iterative ^ {Folded_hist_tag_iterative_2,1'b0} ^ PC_in [tag_width:3] ^ PC_in [tag_width+1+:tag_width] ^ Path_hist_iterative_4 [index_width+3+tag_width:index_width+3] ^ Global_hist_iterative_5;		
	end
	assign index = {Tag, index_temp};
	

endmodule

module Circular_Buffer #(
	parameter longest_history_length = 1347,
	parameter history_length = 1347,
	parameter tag_width = 15,
	parameter index_width = 8,
	parameter path_length = 27,
	parameter longest_path_length = 27
)
(
	output reg [index_width:1] Folded_hist_index_iterative, Path_hist_index_iterative,
	output reg [tag_width:1] Folded_hist_tag_iterative, Path_hist_tag_iterative,
	output reg [tag_width-1:1] Folded_hist_tag_iterative_2, Path_hist_tag_iterative_2,

	input wire [longest_path_length:1] Path_hist_iterative, Path_hist_true,
	input wire [longest_history_length:1] Global_hist_iterative, Global_hist_true,
	
	input wire clk, rst, stall, en_1, en_2, en_2_miss
);
	reg [index_width:1] Folded_hist_index_true, Path_hist_index_true;
	reg [tag_width:1] Folded_hist_tag_true, Path_hist_tag_true;
	reg [tag_width-1:1] Folded_hist_tag_true_2, Path_hist_tag_true_2;

	always_ff @(negedge clk) begin
		if (rst == 1) begin
			Folded_hist_index_iterative <= 0;
			Folded_hist_tag_iterative <= 0;
			Folded_hist_tag_iterative_2 <= 0;
			Path_hist_index_iterative <= 0;
                        Path_hist_tag_iterative <= 0;
                        Path_hist_tag_iterative_2 <= 0;
		end
		else begin
			if ((en_1 ==1)  && (en_2_miss == 0) && (stall == 0)) begin
				Folded_hist_index_iterative <= {Folded_hist_index_iterative[index_width:2], Global_hist_iterative [history_length] ^ Global_hist_iterative[longest_history_length]};
				Folded_hist_tag_iterative <= {Folded_hist_tag_iterative[tag_width:2], Global_hist_iterative [history_length] ^ Global_hist_iterative[longest_history_length]};
				Folded_hist_tag_iterative_2 <= {Folded_hist_tag_iterative_2[tag_width-1:2], Global_hist_iterative [history_length] ^ Global_hist_iterative[longest_history_length]};

				Path_hist_index_iterative <= {Path_hist_index_iterative[index_width:2], Path_hist_iterative [path_length] ^ Path_hist_iterative[longest_path_length]};
                                Path_hist_tag_iterative <= {Path_hist_tag_iterative[tag_width:2], Path_hist_iterative [path_length] ^ Path_hist_iterative[longest_path_length]};
                                Path_hist_tag_iterative_2 <= {Path_hist_tag_iterative_2[tag_width-1:2], Path_hist_iterative [path_length] ^ Path_hist_iterative[longest_path_length]};
			end
			else if (en_2_miss == 1) begin
				Folded_hist_index_iterative <= Folded_hist_index_true;
				Folded_hist_tag_iterative <= Folded_hist_tag_true;
				Folded_hist_tag_iterative_2 <= Folded_hist_tag_true_2;

				Path_hist_index_iterative <= Path_hist_index_true;
                                Path_hist_tag_iterative <= Path_hist_tag_true;
                                Path_hist_tag_iterative_2 <= Path_hist_tag_true_2;
			end
			else begin
				Folded_hist_index_iterative <= Folded_hist_index_iterative;
				Folded_hist_tag_iterative <= Folded_hist_tag_iterative;
				Folded_hist_tag_iterative_2 <= Folded_hist_tag_iterative_2;

				Path_hist_index_iterative <= Path_hist_index_iterative;
                                Path_hist_tag_iterative <= Path_hist_tag_iterative;
                                Path_hist_tag_iterative_2 <= Path_hist_tag_iterative_2;
			end
		end	
	end
	always_ff @(negedge clk) begin
		if (rst == 1) begin
			Folded_hist_index_true <= 0;
			Folded_hist_tag_true <= 0;
			Folded_hist_tag_true_2 <= 0;

			Path_hist_index_true <= 0;
                        Path_hist_tag_true <= 0;
                        Path_hist_tag_true_2 <= 0;
		end
		else begin
			if (en_2 == 1) begin
				Folded_hist_index_true <= {Folded_hist_index_true[index_width:2], Global_hist_true [history_length] ^ Global_hist_true[longest_history_length]};
				Folded_hist_tag_true <= {Folded_hist_tag_true[tag_width:2], Global_hist_true [history_length] ^ Global_hist_true[longest_history_length]};
				Folded_hist_tag_true_2 <= {Folded_hist_tag_true_2[tag_width-1:2], Global_hist_true [history_length] ^ Global_hist_true[longest_history_length]};
			
				Path_hist_index_true <= {Path_hist_index_true[index_width:2], Path_hist_true [path_length] ^ Path_hist_true[longest_path_length]};
                                Path_hist_tag_true <= {Path_hist_tag_true[tag_width:2], Path_hist_true [path_length] ^ Path_hist_true[longest_path_length]};
                                Path_hist_tag_true_2 <= {Path_hist_tag_true_2[tag_width-1:2], Path_hist_true [path_length] ^ Path_hist_true[longest_path_length]};
			end
			else begin 
				Folded_hist_index_true <= Folded_hist_index_true;
				Folded_hist_tag_true <= Folded_hist_tag_true;
				Folded_hist_tag_true_2 <= Folded_hist_tag_true_2;

				Path_hist_index_true <= Path_hist_index_true;
                                Path_hist_tag_true <= Path_hist_tag_true;
                                Path_hist_tag_true_2 <= Path_hist_tag_true_2;
			end
		end

	end
	
endmodule
/* verilator lint_on UNUSED */
/* verilator lint_on WIDTH */
