/* verilator lint_off DECLFILENAME */
module Branch_status_table #(parameter BST_length = 16383) //16383 this module include BTB
(
/* verilator lint_on DECLFILENAME */
/* verilator lint_off UNUSED */
	output wire [2:1] status,
	output wire [32:1] PC_predict_o,
	
	input wire [2:1] status_update,
	input wire [32:1] PC_in, PC_update,
	input wire [32:1] PC_predict_update,
	input wire clk,en_1,RST
);
	wire [14:1] PC_index, PC_index_update;


	//Internal memory
	reg [2:1] status_bits [BST_length:0];
	reg [32:1] PC_predict [BST_length:0];
	reg [16:1] PC [BST_length:0];


	//Combinational
	
	assign PC_index = PC_in [16:3];
	assign PC_index_update = PC_update [16:3];


	//
	initial begin
		for ( int i=0; i <= BST_length; i=i+1) begin
				status_bits[i] = 0;
				PC_predict[i] = 0;
				PC[i]=0;
		end
	end
	//Prediction and Update
	reg [2:1] status_temp;
	reg [32:1] PC_predict_o_temp;
	reg [16:1] PC_temp; 
	always_ff @(posedge clk) begin
			if (en_1==1) begin
				status_bits[PC_index_update] <= status_update;
				PC [PC_index_update] <= PC_update[32:17] ;
				PC_predict[PC_index_update] <= PC_predict_update;
			end
			status_temp <= status_bits [PC_index];
			PC_predict_o_temp <= PC_predict [PC_index];
			PC_temp <= PC[PC_index];
	end
	assign  status =  ( PC_temp == PC_in[32:17] ) ? status_temp : 0;
	assign  PC_predict_o = ( PC_temp == PC_in[32:17] ) ? PC_predict_o_temp : 0;
			
endmodule

module Sr_BST_status_address 
(
	output reg [6:1] status_update,		// Status_ from BST
	output reg [96:1] address_update, //PC_predict_o from BST

	input wire [2:1] status,
	input wire [32:1] address, 
	input wire clk, rst, stall
);
	wire [6:1] status_update_temp;
	wire [96:1] address_update_temp;

	assign status_update_temp=status_update;
	assign address_update_temp=address_update;

	always_ff @(negedge clk) begin
		if (rst == 1) begin
			status_update <= 0;
			address_update <= 0;
		end
		else begin
			if (stall == 1) begin
				status_update <= status_update ;
				address_update <= address_update ;
			end
			else begin
				status_update <= {status, status_update_temp[6:3]};
				address_update <= {address, address_update_temp[96:33]};
			end
		end
	end

endmodule

//For simulation
module Mux_prediction_address 
( 
	output reg [32:1] PC_predict,

	input wire [32:1] PC_nottaken, PC_taken,
	input wire prediction
);
	always_comb begin
		if (prediction ==1) 
			PC_predict = PC_taken;
		else
			PC_predict = PC_nottaken+4;
	end
endmodule
module Sr_PC_in
(
	output reg [96:1] PC_in_update,
	
	input wire [32:1] PC_in, 
	input wire clk, rst, stall
);
	wire [96:1] PC_in_temp;

	assign PC_in_temp = PC_in_update;
	
	always_ff @(negedge clk) begin
		if (rst == 1)
			PC_in_update <= 0;
		else begin
			if (stall == 1)
				PC_in_update <= PC_in_update;
			else
				PC_in_update <= {PC_in , PC_in_temp[96:33]};
		end
	end
endmodule

module Sr_PC_predict
(
	output reg [96:1] PC_in_predict,
	
	input wire [32:1] PC_in,
	input wire clk, rst, stall
);
	wire [96:1] PC_in_temp;

	assign PC_in_temp = PC_in_predict;
	
	always_ff @(negedge clk) begin
		if (rst == 1)
			PC_in_predict <= 0;
		else begin
			if (stall == 1)
				PC_in_predict <= PC_in_predict;
			else
				PC_in_predict <= {PC_in , PC_in_temp[96:33]};
		end
	end
endmodule

module Bias_weight_table #(parameter Bias_length = 1023)
(
	output reg [2:1] weight,

	input wire [10:1] index, index_update,
	input wire [2:1] weight_update,
	input wire en_1, RST,
	input wire clk
);
	//Internal memory
	reg [2:1] bias_table [Bias_length:0];

	//Initialize
	initial begin	
		for (int i = 0; i <= Bias_length; i=i+1) begin
					bias_table [i] = 0;
		end
	end
	//Prediction and Update
	always_ff @(posedge clk) begin
		if (en_1 == 1)
			bias_table [index_update] <= weight_update;
		weight <= bias_table [index];

	end

endmodule


module Sr_Bias_weight
(
	output reg [6:1] weight_update,

	input wire [2:1] weight,
	input wire clk, rst, stall
);
	wire [6:1] weight_update_temp;

	assign weight_update_temp = weight_update;
	always_ff @(negedge clk) begin
		if (rst ==1)
			weight_update <= 0;
		else begin
			if (stall == 1) 
				weight_update <= weight_update;
			else
				weight_update <= {weight , weight_update_temp[6:3]};
		end

	end
endmodule


module index_perceptron
(
	output wire [160:1] index,

	input wire [10:1] PC,
	input wire [160:1] Branch_address_iterative,
	input wire [160:1] Folded_hist_iterative
);
	reg [160:1] Folded_hist_iterative_temp;
	logic [15:0] operand [1:10];

	//assign Folded_hist_iterative_temp [16] = Folded_hist_iterative [160:151];
	genvar i, j;
	generate 
		for (i=0; i<= 15; i++) begin : block_2
			assign operand[1][i] = Folded_hist_iterative [10*i+1];
			assign operand[2][i] = Folded_hist_iterative [10*i+2];
			assign operand[3][i] = Folded_hist_iterative [10*i+3];
			assign operand[4][i] = Folded_hist_iterative [10*i+4];
			assign operand[5][i] = Folded_hist_iterative [10*i+5];
			assign operand[6][i] = Folded_hist_iterative [10*i+6];
			assign operand[7][i] = Folded_hist_iterative [10*i+7];
			assign operand[8][i] = Folded_hist_iterative [10*i+8];
			assign operand[9][i] = Folded_hist_iterative [10*i+9];
			assign operand[10][i] = Folded_hist_iterative [10*i+10];
		end
	endgenerate
	generate
		for ( i=0; i<=15; i=i+1) begin : generate_block_identifier
			assign	Folded_hist_iterative_temp [10*i+10:10*i+1] = {^operand[10][15:i],^operand[9][15:i],^operand[8][15:i],
				^operand[7][15:i],^operand[6][15:i],^operand[5][15:i],^operand[4][15:i],^operand[3][15:i],
				^operand[2][15:i],^operand[1][15:i]};
		end
	endgenerate

	generate
		for ( i=1; i<=16; i=i+1) begin : generate_block_identifier_2
			assign	index [10*i-9+:10] = PC ^ Folded_hist_iterative_temp [10*i-9+:10] ^ Branch_address_iterative [10*i-9+:10];
		end
	endgenerate


endmodule

typedef logic [10:1] Branch [48:1];
typedef logic [6:1] Pos [48:1];

module index_perceptron_BF #(parameter addr_width = 10, parameter num_table = 48)
(
	output reg [num_table*addr_width:1] index,

	input wire [addr_width:1] PC,
	input wire [addr_width:1] Branch_address_iterative [num_table:1],
	input wire [48:1] Folded_hist_iterative,
	input [6:1] Pos_iterative [num_table:1]
);

	wire [addr_width:1] Folded_hist [48:1];
	wire [48:1] zero;

	assign zero = 48'd0;
	
	// verilator lint_off WIDTH
	assign Folded_hist[num_table] = {9'd0, Folded_hist_iterative [num_table]};
	genvar t;
	generate
		for ( t = num_table-1; t >= num_table-9; t=t-1) begin : generate_block_identifier
			assign Folded_hist[t] = Folded_hist_iterative [num_table:t];
		end
	endgenerate

	assign Folded_hist[num_table-10] = Folded_hist_iterative [num_table:num_table-9] ^ Folded_hist_iterative [38];
	genvar i;
	generate
		for ( i=num_table-11; i>=num_table-19; i=i-1) begin : generate_block_identifier_2
			assign Folded_hist[i] =Folded_hist_iterative [num_table:num_table-9] ^ Folded_hist_iterative [num_table-10:i];
      end
   endgenerate
	
 	assign Folded_hist[num_table-20] =Folded_hist_iterative [num_table:num_table-9] ^ Folded_hist_iterative [num_table-10:num_table-19] 
	^ Folded_hist_iterative[num_table-20];
	
	genvar z;
	generate
      for ( z=num_table-21; z>=num_table-29; z=z-1) begin : generate_block_identifier_3
			assign Folded_hist[z] =Folded_hist_iterative [num_table:num_table-9] ^ Folded_hist_iterative [num_table-10:num_table-19] 
			^ Folded_hist_iterative[num_table-20:z];
      end
	endgenerate
	assign Folded_hist[num_table-30] = Folded_hist_iterative [num_table:num_table-9] ^ Folded_hist_iterative [num_table-10:num_table-19] 
	^ Folded_hist_iterative[num_table-20:num_table-29] ^ Folded_hist_iterative[num_table-30];
	
	generate
      for ( z=num_table-31; z>=num_table-39; z=z-1) begin : generate_block_identifier_4
			assign Folded_hist[z] =Folded_hist_iterative [num_table:num_table-9] ^ Folded_hist_iterative [num_table-10:num_table-19] 
			^ Folded_hist_iterative[num_table-20:num_table-29]^ Folded_hist_iterative[num_table-30:z];
      end
	endgenerate
	assign Folded_hist[num_table-40] = Folded_hist_iterative [num_table:num_table-9] ^ Folded_hist_iterative [num_table-10:num_table-19] 
	^ Folded_hist_iterative[num_table-20:num_table-29] ^ Folded_hist_iterative[num_table-30:num_table-39] ^ Folded_hist_iterative[num_table-40] ;
	
	generate
      for ( z=num_table-41; z>=num_table-47; z=z-1) begin : generate_block_identifier_5
			assign Folded_hist[z] =Folded_hist_iterative [num_table:num_table-9] ^ Folded_hist_iterative [num_table-10:num_table-19] 
			^ Folded_hist_iterative[num_table-20:num_table-29]^ Folded_hist_iterative[num_table-30:num_table-39] ^ Folded_hist_iterative[num_table-40:z];
      end
	endgenerate
	always_comb begin
		for (int m=1; m<=num_table; m=m+1) begin 
			index [addr_width*m-addr_width+1+:addr_width] = PC ^ Branch_address_iterative [m] ^ Pos_iterative[m] ^ Folded_hist[m];

		end
	end
	// verilator lint_on WIDTH
endmodule

module Perceptron_table #(parameter Perceptron_table_length = 1023)
(
	output reg [48:1] perceptron_weights,

	input wire [160:1] index, index_update,
	input wire [48:1] perceptron_weights_update,
	input clk, en_1, RST
);
	reg [48:1] perceptron_table [Perceptron_table_length:0];
	//Initialize
	initial begin
		for (int i=0; i<=Perceptron_table_length; i=i+1) begin
				perceptron_table[i]=0;
		end
	end
	//Prediction and update
	always_ff @(posedge clk) begin
		if (en_1==1) begin
				for (int i=1; i<=16; i=i+1) begin
					perceptron_table [index_update[10*(i-1)+1+:10]] [3*(i-1)+1+:3] <= perceptron_weights_update [3*(i-1)+1+:3];
				end
			end
		for (int i=1; i<=16; i=i+1) begin
			perceptron_weights [3*(i-1)+1+:3] <= perceptron_table [index[10*(i-1)+1+:10]] [3*(i-1)+1+:3];
		end
	end
	
endmodule

module Sr_perceptron_address
(
	output reg [480:1] perceptron_address_update,

	input wire [160:1] perceptron_address,
	input wire clk, rst, stall
);
	wire [480:1] perceptron_address_update_temp;

	assign perceptron_address_update_temp = perceptron_address_update;

	always_ff @(negedge clk) begin
		if (rst == 1)
			perceptron_address_update <= 0;
		else begin
			if (stall == 1) 
				perceptron_address_update <= perceptron_address_update;
			else
				perceptron_address_update <= {perceptron_address, perceptron_address_update_temp [480:161]};
		end
	end
endmodule

module Sr_perceptron_weight
(
	output reg [144:1] perceptron_weights_update,

	input wire [48:1] perceptron_weights,
	input wire clk, rst, stall
);
	wire [144:1] perceptron_weight_update_temp;

	assign perceptron_weight_update_temp=perceptron_weights_update;

	always_ff @(negedge clk) begin
		if (rst == 1)
			perceptron_weights_update <= 0;
		else begin
			if (stall == 1)
				perceptron_weights_update <= perceptron_weights_update;
			else
				perceptron_weights_update <= {perceptron_weights, perceptron_weight_update_temp [144:49]};
		end
	end
endmodule

module Perceptron_table_BF #(parameter Perceptron_table_length = 1023)//65535
(
	output reg [144:1] perceptron_weights,

	input wire [480:1] index, index_update, //768
	input wire [144:1] perceptron_weights_update,
	input wire clk, en_1, RST
);
	reg [144:1] perceptron_table_BF [Perceptron_table_length:0];

	//Initialize 
	initial begin
		for (int i=0; i<=Perceptron_table_length; i=i+1) begin
			perceptron_table_BF[i]=0;
     	end
	end
	//Prediction
	always_ff @(posedge clk) begin
		if (en_1==1) begin
			for (int i=1; i<=48; i=i+1) begin
				perceptron_table_BF [index_update[10*(i-1)+1+:10]] [3*(i-1)+1+:3] <= perceptron_weights_update [3*(i-1)+1+:3];
         end
		end
      for (int i=1; i<=48; i=i+1) begin
			perceptron_weights [3*(i-1)+1 +: 3] <= perceptron_table_BF [index[10*(i-1)+1+:10]] [3*(i-1)+1+:3];
      end
    end

	//Update
endmodule

module Sr_perceptron_address_BF #(parameter length = 480)
(
        output reg [length*3:1] perceptron_address_update,

        input wire [length:1] perceptron_address,
        input wire clk, rst, stall
);
        wire [length*3:1] perceptron_address_update_temp;

        assign perceptron_address_update_temp = perceptron_address_update;

        always_ff @(negedge clk) begin
		if (rst == 1)
			perceptron_address_update <= 0;
		else begin
			if (stall == 1)
				perceptron_address_update <= perceptron_address_update;
			else
                		perceptron_address_update <= {perceptron_address, perceptron_address_update_temp [length+1+:2*length]};
		end
        end
endmodule

module Sr_perceptron_weight_BF
(
        output reg [432:1] perceptron_weight_update,

        input wire [144:1] perceptron_weight,
        input wire clk, rst, stall
);
        wire [432:1] perceptron_weight_update_temp;

        assign perceptron_weight_update_temp=perceptron_weight_update;

        always_ff @(negedge clk) begin
		if (rst == 1)
			perceptron_weight_update <= 0;
		else begin
			if (stall == 1)
				perceptron_weight_update <= perceptron_weight_update;
			else
               			perceptron_weight_update <= {perceptron_weight, perceptron_weight_update [432:145]};
		end
        end
endmodule

module Branch_address_reg 
(
	output reg [160:1] Branch_address_iterative,

	input wire [10:1] Branch_address_update_iterative,   // input of PC reg in CPU design at prediction
	input wire [10:1] Branch_address_update,		// input of PC reg in CPU design
	input wire clk, en_1, en_2, rst, en_2_miss, stall
);
						  // reg one always update after a prediction 
	reg [160:1] Branch_address_true;	// reg two update only from result at EX

	always_ff @(negedge clk) begin
		if (rst == 1)
			Branch_address_iterative <= 0;
		else begin
			if ((en_1 ==1) && (en_2_miss == 0) && (stall==0))
				Branch_address_iterative <= {Branch_address_update_iterative,Branch_address_iterative[160:11]};
			else if (en_2_miss == 1)
				Branch_address_iterative <= Branch_address_true;
			else 
				Branch_address_iterative <= Branch_address_iterative ;
		end
	end
	always_ff @(negedge clk) begin
		if (rst ==1)
			Branch_address_true <= 0;
		else begin
			if (en_2 ==1)
				Branch_address_true <= {Branch_address_update, Branch_address_true[160:11]};
			else
				Branch_address_true <= Branch_address_true;
		end
	end
	
endmodule

module Folded_hist_reg
(
        output reg [160:1] Folded_hist_iterative,
	output wire [160:1] Folded_hist_true_1,

        input wire  Folded_hist_update_iterative,   // input of PC reg in CPU design at pred
        input wire  Folded_hist_update,                // input of PC reg in CPU design
        input wire clk, en_1, en_2, rst, en_2_miss, stall
);
                                                  // reg one always update after a prediction
        reg [160:1] Folded_hist_true;        // reg two update only from result at EX
	assign Folded_hist_true_1 = Folded_hist_true;
        always_ff @(negedge clk) begin
		if (rst == 1) 
			Folded_hist_iterative <= 0;
		else begin
                	if ((en_1 ==1) && (en_2_miss == 0) && (stall==0))
                        	Folded_hist_iterative <= {Folded_hist_update_iterative,Folded_hist_iterative[160:2]};
                	else if (en_2_miss == 1)
                        	Folded_hist_iterative <= Folded_hist_true;
        		else 
			 	Folded_hist_iterative <=  Folded_hist_iterative ;
		end
	end
        always_ff @(negedge clk) begin
		if (rst == 1)
			Folded_hist_true <= 0;
		else begin
                	if (en_2 ==1)
                        	Folded_hist_true <= {Folded_hist_update, Folded_hist_true[160:2]};
                	else
                        	Folded_hist_true <= Folded_hist_true;
		end
	end
endmodule

module Branch_address_folded_hist_reg_pos_BF #( parameter addr_width = 10 )
( 
	//Branch_address
	output wire [addr_width:1] Stack_branch_iterative [48:1] ,

	input wire [addr_width:1] Branch_address_update_iterative,
	input wire [addr_width:1] Branch_address_update,
	//Common signal
	input wire clk, rst,
	input wire  en_1, en_2, en_2_miss, stall,
	//Folded Hist
	output wire [48:1] Folded_hist_iterative,
	
	input wire  Folded_hist_update_iterative,
	input wire Folded_hist_update,

	//Position
	output wire [6:1] Pos_iterative [48:1],

	input wire [6:1] Pos_update_iterative,
	input wire [6:1] Pos_update	

);	
	//Internal signal for Branch address reg
	wire [addr_width:1] Stack_branch_true [48:1];	
	wire [48:1] signal_clk, signal_clk_2;	//output of PC comparator
	
//	reg en_2_miss;
//	reg rst,clk,en_1,en_2;
//	reg [16:1] Branch_address_update_iterative;
//	reg [16:1] Branch_address_update;
//	reg Folded_hist_update_iterative;
//	reg Folded_hist_update;
//	reg [6:1] Pos_update_iterative;
//	reg [6:1] Pos_update;
	
	//Common signal
	wire clk_iterative, clk_true; //two clock for two different kind of register

	assign clk_iterative = ((en_1 ==1) | (en_2_miss == 1) & (stall==0)) & clk;
	assign clk_true = (en_2==1) & clk;

	PC_comparator PC_comparator_1 ( .Branch_address_iterative(Stack_branch_iterative), .Branch_address_update(Branch_address_update_iterative), .signal(signal_clk) );
	PC_comparator PC_comparator_2 ( .Branch_address_iterative(Stack_branch_true), .Branch_address_update(Branch_address_update), .signal(signal_clk_2) );

	//Branch address
	genvar i;
	Recency_stack_branch Recency_stack_branch_1 ( .D_stack(Branch_address_update_iterative), .signal_2(Stack_branch_true[48]), .signal(signal_clk[48]), .clk(clk_iterative), .en(en_2_miss), .Stack_out(Stack_branch_iterative[48]), .rst(rst) );
	generate
		for (i=47; i>=1; i=i-1) begin : generate_block_identifier
			Recency_stack_branch Recency_stack_branch_2 ( .D_stack(Stack_branch_iterative[i+1]), .signal_2(Stack_branch_true[i]), .signal(signal_clk[i]), .clk(clk_iterative), .en(en_2_miss), .Stack_out(Stack_branch_iterative[i]), .rst(rst) );
		end
	endgenerate
	
	Recency_stack_branch Recency_stack_branch_3 ( .D_stack(Branch_address_update), .signal_2(Stack_branch_true[48]), .signal(signal_clk_2[48]), .clk(clk_true), .en(1'b0), .Stack_out(Stack_branch_true[48]), .rst(rst) );
	generate
		for (i=47; i>=1; i=i-1) begin : generate_block_identifier_1
			Recency_stack_branch Recency_stack_branch_4 ( .D_stack(Stack_branch_true[i+1]), .signal_2(Stack_branch_true[i]), .signal(signal_clk_2[i]), .clk(clk_true), .en(1'b0), .Stack_out(Stack_branch_true[i]), .rst(rst) );
		end
	endgenerate




//		for (i=1; i<=16; i=i+1) begin
//			Recency_stack entity_0 ( .D_stack (Branch_address_update_iterative[i]), .signal(signal_clk), .clk(clk_iterative), .Stack(Branch_address_iterative [48:1][i]), .en(en_2), .signal_2(Branch_address_true[48:1][i]));   		
//		end
//	endgenerate
//	generate
//                for (i=1; i<=16; i=i+1) begin
//                        Recency_stack entity_1 ( .D_stack (Branch_address_update[i]), .signal(signal_clk_2), .clk(clk_true), .Stack(Branch_address_true [48:1][i]), .en(0), .signal_2(Branch_address_true[48:1][i]) );
//               end
//        endgenerate

	//Folded_hist
	wire [48:1] Folded_hist_true;
	Recency_stack_hist Recency_stack_hist ( .D_stack(Folded_hist_update_iterative), .signal_2(Folded_hist_true[48]), .signal(signal_clk[48]), .clk(clk_iterative), .en(en_2_miss), .Stack_out(Folded_hist_iterative[48]), .rst(rst));
	generate 
		for (i=47; i>=1; i=i-1) begin : generate_block_identifier_2
			Recency_stack_hist Recency_stack_hist_iterative ( .D_stack(Folded_hist_iterative[i+1]), .signal_2(Folded_hist_true[i]), .signal(signal_clk[i]), .clk(clk_iterative), .en(en_2_miss), .Stack_out(Folded_hist_iterative[i]), .rst(rst));
		end	
	endgenerate

	Recency_stack_hist Recency_stack_hist_2 ( .D_stack(Folded_hist_update), .signal_2(Folded_hist_true[48]), .signal(signal_clk_2[48]), .clk(clk_true), .en(1'b0), .Stack_out(Folded_hist_true[48]), .rst(rst));
	generate 
		for (i=47; i>=1; i=i-1) begin : generate_block_identifier_3
			Recency_stack_hist Recency_stack_hist_true ( .D_stack(Folded_hist_true[i+1]), .signal_2(Folded_hist_true[i]), .signal(signal_clk_2[i]), .clk(clk_true), .en(1'b0), .Stack_out(Folded_hist_true[i]), .rst(rst));
		end	
	endgenerate
	//Position
	wire [6:1] Stack_true [48:1];

	Recency_stack_pos entity_4 ( .D_stack(6'd0), .signal_2(Stack_true[48]), .signal(signal_clk[48]), .clk(clk_iterative), .en(en_2_miss), .Stack_out(Pos_iterative [48]), .rst(rst));
	generate 
		for (i=47; i>=1; i=i-1) begin : generate_block_identifier_4
			Recency_stack_pos entity_5 ( .D_stack(Pos_iterative[i+1]), .signal_2(Stack_true[i]), .signal(signal_clk[i]), .clk(clk_iterative), .en(en_2_miss), .Stack_out(Pos_iterative [i]), .rst(rst));
		end
	endgenerate

	Recency_stack_pos entity_6 ( .D_stack(6'd0), .signal_2(Stack_true[48]), .signal(signal_clk_2[48]), .clk(clk_true), .en(1'b0), .Stack_out(Stack_true [48]), .rst(rst));
	generate 
		for (i=47; i>=1; i=i-1) begin : generate_block_identifier_5
			Recency_stack_pos entity_7 ( .D_stack(Stack_true[i+1]), .signal_2(Stack_true[i]), .signal(signal_clk_2[i]), .clk(clk_true), .en(1'b0), .Stack_out(Stack_true [i]), .rst(rst));
		end
	endgenerate
	
	//Simulate test
//	always begin
//		clk=0;
//		forever #20 clk=~clk;
//	end
//
//	initial begin
//		en_2_miss <= 0;
//		en_1<=1;
//		en_2<=1;
//		rst <= 1;
//		#40
//		en_1 <= 0;
//		en_2 <= 0;
//		#20
//		
//		Branch_address_update <= 16'h00ff;
//		Branch_address_update_iterative <= 16'hffff;
//		Folded_hist_update <= 1; 
//		Folded_hist_update_iterative <= 0;
//		Pos_update_iterative <= 15;
//		Pos_update <= 2;
//		rst <= 0;
//		en_1<= 1;
//		en_2<= 0;
//		#40
//		Branch_address_update <= 16'h00ff;
//		Branch_address_update_iterative <= 16'h0fff;
//		Folded_hist_update <= 1; 
//		Folded_hist_update_iterative <= 1;
//		Pos_update_iterative <= 15;
//		Pos_update <= 2;
//		en_1 <= 1;
//		en_2 <= 0;
//		#40
//		Branch_address_update <= 16'h01ff;
//		Branch_address_update_iterative <= 16'hffff;
//		Folded_hist_update <= 0; 
//		Folded_hist_update_iterative <= 1;
//		Pos_update_iterative <= 7;
//		Pos_update <= 2;
//		en_1 <= 1;
//		en_2 <= 0;
//		#40
//		Branch_address_update <= 16'h01ff;
//		Branch_address_update_iterative <= 16'h0fff;
//		Folded_hist_update <= 0; 
//		Folded_hist_update_iterative <= 1;
//		Pos_update_iterative <= 3;
//		Pos_update <= 2;
//		en_2 <= 1;
//		en_1 <= 0;
//		en_2_miss <= 1;
//		#40
//		Branch_address_update <= 16'h00ff;
//		Branch_address_update_iterative <= 16'hffff;
//		Folded_hist_update <= 1; 
//		Folded_hist_update_iterative <= 0;
//		Pos_update_iterative <= 15;
//		Pos_update <= 2;
//		en_1 <= 1;
//		en_2 <= 1;
//		en_2_miss <= 1;
//		#40
//		Branch_address_update <= 16'h0000;
//		Branch_address_update_iterative <= 16'h000f;
//		Folded_hist_update <= 0; 
//		Folded_hist_update_iterative <= 0;
//		Pos_update_iterative <= 1;
//		Pos_update <= 1;
//		en_1 <= 0;
//		en_2 <= 0;
//		en_2_miss <= 0;
//	end

endmodule
module Recency_stack_hist
( 
	output reg Stack_out,

	input wire D_stack,
	input wire  signal_2,
	input wire signal,
	input wire clk, en, rst
);
	reg  Stack_reg;
	
	
	//Simulate


	
	
	always_ff @(negedge clk) begin
		if (rst == 1)
			Stack_reg <= 0;
		else begin
			if ((signal == 0) && (en == 0)) 
				Stack_reg <= D_stack;
			else if (en == 1)
				Stack_reg <= signal_2;
			else
				Stack_reg <= Stack_reg;
		end
	end
	
	always_comb begin
		if (rst == 1) 
			Stack_out = 0;
		else begin
			Stack_out = Stack_reg;
		end
	end
	
endmodule
module Recency_stack_branch #( parameter addr_width = 10 )
( 
	output reg [addr_width:1] Stack_out,

	input wire [addr_width:1] D_stack,
	input wire [addr_width:1] signal_2,
	input wire signal,
	input wire clk, en, rst
);
	reg [addr_width:1] Stack_reg;
	
	//Simulate
	
	
	always_ff @(negedge clk) begin
		if (rst == 1)
			Stack_reg <= 0;
		else begin
			if ((signal == 0) && (en == 0))
				Stack_reg <= D_stack;
			else if (en == 1)
				Stack_reg <= signal_2;
			else
				Stack_reg <= Stack_reg;
		end
	end
	
	always_comb begin
		if (rst == 1) 
			Stack_out = 0;
		else begin
			Stack_out = Stack_reg;
		end
	end
	
endmodule
module Recency_stack_pos
(
	output reg [6:1] Stack_out,

	input wire [6:1] D_stack,
	input wire [6:1] signal_2, //From true reg if necessary
	input wire signal,	   // Enable update if it 's branch
	input wire clk, en, rst	   // en is for misprediction
);
	reg [6:1] Stack_reg, Stack_add, signal_2_temp;
	wire [6:1]  Stack;	

	//Simulate

	assign Stack = Stack_reg;
	always_ff @(negedge clk) begin
		if (rst == 1) 
			Stack_reg <= 0;
		else begin
			if ((signal == 0) && (en == 0))
				Stack_reg <= D_stack;
			else if (en == 1)
				Stack_reg <= signal_2_temp;
			else
				Stack_reg <= Stack_reg;
		end
	end
	always_comb begin
		if (signal_2 == 0)
			signal_2_temp = signal_2;
		else
			signal_2_temp = signal_2-6'd1;
	end
	always_comb begin
		if (Stack == 63)
			Stack_add = Stack;
		else
			Stack_add = Stack+6'd1;
	end

	always_comb begin
		if (rst == 1) 
			Stack_out = 0;
		else if (en == 0)
			Stack_out = Stack_add;
		else
			Stack_out = signal_2;
	end
	

endmodule

module Recency_stack
(
	output wire [48:1] Stack ,

	input D_stack,
	input wire [48:1] signal_2, // From the true reg
	input wire [48:1] signal, // From PC comparator
	input wire clk, en, rst
);
	wire [48:1] signal_clk;
	
	//assign rst = 0;
	assign signal_clk = ~signal & {48{clk}};

	D_flip_flop D_flip_flop_48 ( .out(Stack[48]), .D(D_stack), .clk(signal_clk[48]), .rst(rst), .sel(en), .signal(signal[48]));
	genvar i;
	generate
		for (i=47 ; i>=1; i=i-1) begin : generate_block_identifier
			D_flip_flop entity_0  ( .out(Stack[i]), .D(Stack[i+1]), .clk(signal_clk[i]), .rst(rst), .sel(en), .signal(signal[i]));
		end	
	endgenerate

endmodule
	

module PC_comparator #( parameter addr_width = 10 )
(
	output reg [48:1] signal,

	input wire [addr_width:1] Branch_address_iterative [48:1],
	input wire [addr_width:1] Branch_address_update
);

	always_comb begin
		signal[48] = 0;
		signal[47] = ( Branch_address_update == Branch_address_iterative [48] );	
		for (int i=46; i>=1; i=i-1) begin
			if (Branch_address_update == Branch_address_iterative [i+1])
				signal [i] = 1;
			else
				signal [i] = signal [i+1];
		end
	end
	
endmodule
	

module D_flip_flop
(
	output reg out,

	input wire signal,
	input wire sel,
	input wire D,
	input wire clk,
	input wire rst
);
	reg Q;
	//Simulate 

	always_ff @(negedge clk) begin
		if (rst == 1)
			Q <= 0;
		else 
			Q <= D;
	end
	always_comb begin
		if (rst == 1)
			out = 0;
		else begin
			if (sel == 1)
				out = signal;
			else
				out = Q;
		end
	end
	

endmodule

module BST_update #(parameter theta = 2)
(
	output reg [2:1] status_update,
	//output wire [32:1] PC_predict_update, output of alu
	output wire en_2, en_3,		//en_2 for BST, en_3 for the other
	output wire en_2_reg, en_2_reg_BF,
	output reg rst,	

	input wire Branch_direction,
	input wire Branch_prediction,
	input wire [32:1] inst, 			//inst at EX stage
	input wire [32:1] PC_predict, PC_actual, 	//PC comparision
	input wire [32:1] PC_alu,		 // PC comparision in case of both taken (some branch can jump to multiple address) to update PC jump in memory
	input wire [2:1] old_status,
	input wire [9:1] total_weights_update,
	input wire clk
);
	wire [9:1] total_weights_update_abs;
	wire PC_check;
	reg en_2_temp, en_3_temp;

	assign PC_check = (inst[7:1] == 7'b1100011)||(inst[7:1] == 7'b1101111)||(inst[7:1] == 7'b1100111);
	assign total_weights_update_abs = (total_weights_update & {9{~total_weights_update[9]}}) | (~total_weights_update & {9{total_weights_update[9]}}) ; 

	always_comb begin
		if (old_status == 0) begin
			en_2_temp = 1;
			en_3_temp = 0;
		        status_update[1] = Branch_direction;	
			status_update[2] = ~Branch_direction;
		end
		else if ( (old_status!=3) && (Branch_prediction == Branch_direction) && (PC_predict == PC_actual)) begin
			en_2_temp = 0;
			en_3_temp = 0;
			status_update = old_status;
		end
		else if ( ((Branch_direction != Branch_prediction)||(PC_predict != PC_actual)) && ( (old_status==1) || (old_status==2) ) ) begin
			en_2_temp = 1;
			en_3_temp = 1;
			status_update = 2'd3 & {2{PC_check}};
		end
		else if ( (PC_predict != PC_actual)&&(old_status!=0) ) begin
			en_2_temp = 1;
			en_3_temp = 1;
			status_update = 2'd3 & {2{PC_check}};
		end
		else if ( (old_status == 3) && ( (Branch_direction != Branch_prediction) || (total_weights_update_abs <= theta) ) ) begin
			en_2_temp = 0;
			en_3_temp = 1;
			status_update = 2'd3 & {2{PC_check}};
		end
		else begin
			en_2_temp = 0;
			en_3_temp = 0;
			status_update = 2'd3 & {2{PC_check}};
		end
		       		
	end
	assign en_2_reg_BF = ~en_2_temp & ~en_3_temp & PC_check & (status_update==3);
	assign en_2_reg = ~en_2_temp & ~en_3_temp & PC_check;
	assign en_2 = en_2_temp & PC_check;
	assign en_3 = en_3_temp & PC_check;
	
	assign 	rst = en_2 | en_3;
	

	
endmodule

module Bias_update 
(
	output reg [2:1] bias_update,

	input wire [2:1] bias,
	input wire branch_direction
);
	reg [2:1] bias_inc_update;
	reg [2:1] bias_dec_update;

	Bias_inc Bias_inc ( .bias(bias) , .bias_inc(bias_inc_update) );
	Bias_dec Bias_dec ( .bias(bias) , .bias_dec(bias_dec_update) );
	always_comb begin
		if (branch_direction == 1)
			bias_update = bias_inc_update;
	       	else 
			bias_update = bias_dec_update;
	end
endmodule

module Bias_inc
(
	output reg [2:1] bias_inc,

	input wire [2:1] bias
);
	always_comb begin
		if (bias == 2'b01) 
			bias_inc = 2'b01;
		else if (bias == 2'b00)
			bias_inc = 2'b01;
		else if (bias == 2'b11)
			bias_inc = 2'b00;
		else
			bias_inc = 2'b11;
	end

endmodule

module Bias_dec
(
        output reg [2:1] bias_dec,

        input wire [2:1] bias
);
        always_comb begin
                if (bias == 2'b01)
                        bias_dec = 2'b00;
                else if (bias == 2'b00)
                        bias_dec = 2'b11;
                else if (bias == 2'b11)
                        bias_dec = 2'b10;
                else
                        bias_dec = 2'b10;
	end
	`ifdef FORMAL
                logic [3:1] temp = bias-1;
                always_comb begin
                        if (bias==2)
                                assert (bias_dec==2);
                        else
                                assert (bias_dec==temp[2:1]);
                end
        `endif


endmodule

module Perceptron_update
(
	output reg [48:1] weight_update,
	
	input wire [48:1] weight,
	input wire [16:1] GHR,
	input wire branch_direction
);
	reg [48:1] weight_inc_update;
	reg [48:1] weight_dec_update;

	genvar j;
	generate
		for (j=1; j<=16; j=j+1) begin : generate_block_identifier
			Weight_inc Weight_inc (.weight(weight [3*j : 3*j-2]), .weight_inc(weight_inc_update [3*j: 3*j-2]));
		        Weight_dec Weight_dec (.weight(weight [3*j : 3*j-2]), .weight_dec(weight_dec_update [3*j: 3*j-2]));
		end
	endgenerate

	always_comb begin
		for (int i=1; i<=16; i=i+1) begin
			if (branch_direction == GHR[i])
				weight_update [i*3-2+:3] = weight_inc_update [i*3-2+:3];
			else
				weight_update [i*3-2+:3] = weight_dec_update [i*3-2+:3];
		end
	end
endmodule

module Perceptron_update_BF
(
        output reg [144:1] weight_update,

        input wire [144:1] weight,
	input wire [48:1] RS,
        input wire branch_direction
);
        reg [144:1] weight_inc_update;
        reg [144:1] weight_dec_update;

        genvar j;
        generate
                for (j=1; j<=48; j=j+1) begin : generate_block_identifier
                        Weight_inc Weight_inc (.weight(weight [3*j : 3*j-2]), .weight_inc(weight_inc_update [3*j: 3*j-2]));
                        Weight_dec Weight_dec (.weight(weight [3*j : 3*j-2]), .weight_dec(weight_dec_update [3*j: 3*j-2]));
                end
        endgenerate

        always_comb begin
                for (int i=1; i<=48; i=i+1) begin
                        if (branch_direction == RS[i])
                                weight_update [i*3-2+:3] = weight_inc_update [i*3-2+:3];
                        else
                                weight_update [i*3-2+:3] = weight_dec_update [i*3-2+:3];
        	end
	end
endmodule


module Weight_inc
(
	output reg [3:1] weight_inc,

	input wire [3:1] weight
);
	always_comb begin
		case (weight)
			3'b000: weight_inc = 3'b001;
			3'b001: weight_inc = 3'b010;
			3'b010: weight_inc = 3'b011;
			3'b011: weight_inc = 3'b011;
			3'b100: weight_inc = 3'b101;
                        3'b101: weight_inc = 3'b110;
                        3'b110: weight_inc = 3'b111;
                        3'b111: weight_inc = 3'b000;
		endcase
	end
endmodule

module Weight_dec
(
        output reg [3:1] weight_dec,

        input wire [3:1] weight
);
        always_comb begin
                case (weight)
                        3'b000: weight_dec = 3'b111;
                        3'b001: weight_dec = 3'b000;
                        3'b010: weight_dec = 3'b001;
                        3'b011: weight_dec = 3'b010;
                        3'b100: weight_dec = 3'b100;
                        3'b101: weight_dec = 3'b100;
                        3'b110: weight_dec = 3'b101;
                        3'b111: weight_dec = 3'b110;
		endcase
        end
endmodule



module Perceptron_add 
(
	output wire [9:1] total_weights,

	input wire [48:1] weight_perceptron_conv,
	input wire [144:1] weight_perceptron_rs,
	input wire [2:1] bias,
	input wire prediction_hb, hit_hb
);
	//reg [48:1] weight_perceptron_conv;
	//reg [144:1] weight_perceptron_rs;
	//reg [2:1] bias;
	wire [72:1] weight_perceptron_conv_2;
	wire [36:1] weight_perceptron_conv_3;
	wire [18:1] weight_perceptron_conv_4;
	wire [9:1] weight_perceptron_conv_5;

	wire [9:1] weight_perceptron_total_conv;
	
	wire [216:1] weight_perceptron_rs_2;
	wire [108:1] weight_perceptron_rs_3;
	wire [54:1] weight_perceptron_rs_4;
	wire [27:1] weight_perceptron_rs_5;
	
	wire [9:1] total_weights_temp;


	//Calculate total output Wm
	genvar i;
	generate
		for (i=1;i<=8;i=i+1) begin : generate_block_identifier
			Full_adder_9_bit entity_0 ( .a({ {6{weight_perceptron_conv[6*i]}} ,weight_perceptron_conv[6*i:6*i-2]}), 
				 		    .b({ {6{weight_perceptron_conv[6*i-3]}} ,weight_perceptron_conv[6*i-3:6*i-5]}), .c(weight_perceptron_conv_2[i*9:i*9-8]));
		end
	endgenerate

	generate
                for (i=1;i<=4;i=i+1) begin : generate_block_identifier_1
                        Full_adder_9_bit entity_1 ( .a(weight_perceptron_conv_2[18*i:18*i-8]), 
						    .b(weight_perceptron_conv_2[18*i-9:18*i-17]), .c(weight_perceptron_conv_3[9*i:9*i-8]) );
                end
        endgenerate

	generate
                for (i=1;i<=2;i=i+1) begin : generate_block_identifier_2
                        Full_adder_9_bit entity_2 ( .a(weight_perceptron_conv_3[18*i:18*i-8]),
                                                    .b(weight_perceptron_conv_3[18*i-9:18*i-17]), .c(weight_perceptron_conv_4[9*i:9*i-8]) );
	        end
        endgenerate

	//Calculate total output Wm and bias
	Full_adder_9_bit entity_3 ( .a(weight_perceptron_conv_4[9:1]), .b(weight_perceptron_conv_4[18:10]), .c(weight_perceptron_conv_5));
	Full_adder_9_bit entity_4 ( .a(weight_perceptron_conv_5), .b({ {8{bias[2]}} ,bias[1]}), .c(weight_perceptron_total_conv));

	//Calculate total output Wrs
	generate
                for (i=1;i<=24;i=i+1) begin : generate_block_identifier_3
                        Full_adder_9_bit entity_5 ( .a({ {6{weight_perceptron_rs[6*i]}}, weight_perceptron_rs[6*i:6*i-2]}), 
                                                    .b({ {6{weight_perceptron_rs[6*i-3]}}, weight_perceptron_rs[6*i-3:6*i-5]}), .c(weight_perceptron_rs_2[i*9:i*9-8]));
                end
        endgenerate

	generate
                for (i=1;i<=12;i=i+1) begin : generate_block_identifier_4
                        Full_adder_9_bit entity_6 ( .a(weight_perceptron_rs_2[18*i:18*i-8]), 
                                                    .b(weight_perceptron_rs_2[18*i-9:18*i-17]), .c(weight_perceptron_rs_3[9*i:9*i-8]) );
                end 
        endgenerate

	generate
                for (i=1;i<=6;i=i+1) begin : generate_block_identifier_5
                        Full_adder_9_bit entity_7 ( .a(weight_perceptron_rs_3[18*i:18*i-8]),
                                                    .b(weight_perceptron_rs_3[18*i-9:18*i-17]), .c(weight_perceptron_rs_4[9*i:9*i-8]) );
                end
        endgenerate

	generate
                for (i=1;i<=3;i=i+1) begin : generate_block_identifier_6
                        Full_adder_9_bit entity_8 ( .a(weight_perceptron_rs_4[18*i:18*i-8]),
                                                    .b(weight_perceptron_rs_4[18*i-9:18*i-17]), .c(weight_perceptron_rs_5[9*i:9*i-8]) );
                end
        endgenerate

	wire [9:1] weight_perceptron_rs_6, weight_perceptron_rs_7;
	Full_adder_9_bit entity_9 ( .a(weight_perceptron_rs_5[9:1]), .b(weight_perceptron_rs_5[18:10]), .c(weight_perceptron_rs_6) );
	Full_adder_9_bit entity_10 ( .a(weight_perceptron_rs_5[27:19]), .b(weight_perceptron_rs_6), .c(weight_perceptron_rs_7) );

	//Final Output
	Full_adder_9_bit entity_11 ( .a(weight_perceptron_total_conv), .b(weight_perceptron_rs_7), .c(total_weights_temp) );
	assign total_weights = total_weights_temp;
/*	assign total_weights = (!hit_hb) ? total_weights_temp :
			       (prediction_hb) ? total_weights_temp + 40 : total_weights_temp - 40;
*/
endmodule : Perceptron_add


module Mul_perceptron_GHR

(
	output reg [48:1] weights,

	input wire [16:1] GHR_reg,
	input wire [48:1] perceptron_weights
);
	reg [48:1] perceptron_weights_temp;
	always_comb begin
                for (int i=1; i<=16; i=i+1) begin
			case (perceptron_weights [(i-1)*3+1+:3])
				3'b000: perceptron_weights_temp [(i-1)*3+1+:3] = 3'b000;
				3'b001: perceptron_weights_temp [(i-1)*3+1+:3] = 3'b111;
				3'b010: perceptron_weights_temp [(i-1)*3+1+:3] = 3'b110;
				3'b011: perceptron_weights_temp [(i-1)*3+1+:3] = 3'b101;
				3'b100: perceptron_weights_temp [(i-1)*3+1+:3] = 3'b011;
				3'b101: perceptron_weights_temp [(i-1)*3+1+:3] = 3'b011;
				3'b110: perceptron_weights_temp [(i-1)*3+1+:3] = 3'b010;
				3'b111: perceptron_weights_temp [(i-1)*3+1+:3] = 3'b001;
			endcase
                end
        end

	
	always_comb begin
		for (int i=1; i<=16; i=i+1) begin
			if (GHR_reg [i]==1)
				weights [(i-1)*3+1+:3] = perceptron_weights [(i-1)*3+1+:3];
			else 
				weights [(i-1)*3+1+:3] =  perceptron_weights_temp [(i-1)*3+1+:3];
		end
	end

endmodule

module Mul_perceptron_RS_H
(
	output reg [144:1] weights,

	input wire [48:1] RS_H,
	input wire [144:1] RS_weights
);
	reg [144:1] RS_weights_temp;
	
	always_comb begin
		for (int i=1; i<=48; i=i+1) begin
			case (RS_weights [(i-1)*3+1+:3])
				3'b000: RS_weights_temp [(i-1)*3+1+:3] = 3'b000;
				3'b001: RS_weights_temp [(i-1)*3+1+:3] = 3'b111;
				3'b010: RS_weights_temp [(i-1)*3+1+:3] = 3'b110;
				3'b011: RS_weights_temp [(i-1)*3+1+:3] = 3'b101;
				3'b100: RS_weights_temp [(i-1)*3+1+:3] = 3'b011;
				3'b101: RS_weights_temp [(i-1)*3+1+:3] = 3'b011;
				3'b110: RS_weights_temp [(i-1)*3+1+:3] = 3'b010;
				3'b111: RS_weights_temp [(i-1)*3+1+:3] = 3'b001;
			endcase
		end
	end

	always_comb begin
		for (int i=1; i<=48; i=i+1) begin
			if (RS_H[i] == 1)
				weights [(i-1)*3+1+:3] = RS_weights [(i-1)*3+1+:3];
                        else
                                weights [(i-1)*3+1+:3] = RS_weights_temp [(i-1)*3+1+:3];
		end
	end
	
endmodule

module Full_adder_3_bit
(
        output wire [3:1] c,

        input wire [3:1] a,
        input wire [3:1] b
);
        assign c=a+b;
endmodule

module Full_adder_9_bit 
(	
	output wire [9:1] c,

	input wire [9:1] a,
	input wire [9:1] b
);
	assign c=a+b;
endmodule

module Mux_prediction
(
	output reg prediction,

	input wire total_weights_sign_bit,
	input wire [1:0] bst_status
);
	//BST Status decide outcome of prediction 00 = not found, 01 == taken,
	//10 == not taken, 11 == non-bias
	always_comb begin
		if (bst_status == 0) begin
			prediction = 0;
		end
		else if (bst_status == 3) begin
			prediction = ~total_weights_sign_bit;
		end
		else 
			prediction = bst_status [0];
	end
endmodule

module Sr_total_weights 
(
	output reg [27:1] total_weights_update,

	input wire [9:1] total_weights,
	input clk, rst, stall
);
	wire [27:1] total_weights_temp;

	assign total_weights_temp = total_weights_update;

	always_ff @(negedge clk) begin 
		if (rst == 1)
			total_weights_update <= 0;
		else begin
			if (stall == 1) 
				total_weights_update <= total_weights_update;
			else
				total_weights_update <= {total_weights, total_weights_temp[27:10]};;
		end
	end

endmodule

module Sr_prediction 
(
	output reg [3:1] prediction_update,

	input wire prediction,
	input wire clk, rst, stall
);
	wire [3:1] prediction_temp;

	assign prediction_temp = prediction_update;

	always_ff @(negedge clk) begin
		if (rst == 1)
			prediction_update <= 0;
		else begin
			if (stall == 1)
				prediction_update <= prediction_update;
			else
				prediction_update <= {prediction , prediction_temp[3:2]};
		end
	end

endmodule

module Sr_GHR_reg 
(
	output reg [48:1] GHR_reg_update,

	input wire [16:1] GHR_reg,
	input clk, rst, stall
);
	wire [48:1] GHR_reg_temp;

	assign GHR_reg_temp = GHR_reg_update;

	always_ff @(negedge clk) begin 
		if (rst == 1)
			GHR_reg_update <= 0;
		else begin
			if (stall == 1)
				GHR_reg_update <= GHR_reg_update;
			else
				GHR_reg_update <= {GHR_reg, GHR_reg_temp[48:17]};
		end
	end

endmodule

module Sr_RS_H
(
	output reg [144:1] RS_H_update,

	input wire [48:1] RS_H,
	input clk, rst, stall
);
	wire [144:1] RS_H_temp;

	assign RS_H_temp = RS_H_update;

	always_ff @(negedge clk) begin 
		if (rst == 1)
			RS_H_update <= 0;
		else begin
			if (stall == 1)
				RS_H_update <= RS_H_update;
			else
				RS_H_update <= {RS_H, RS_H_temp[144:49]};
		end
	end
	
endmodule
/* verilator lint_on UNUSED */
