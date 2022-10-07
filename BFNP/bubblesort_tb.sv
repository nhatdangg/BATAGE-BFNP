`include "processor_specific_macros.h"
`timescale 1ps/1ps
module bubblesort_tb;
	parameter PROGRAM_INST = "/home/nhat/Documents/Reference_core/BRISC-V_Processors/software/applications/binaries/bubblesort.mem";
	parameter PROGRAM_DATA = "/home/nhat/Documents/Reference_core/BRISC-V_Processors/software/applications/binaries/data_bubblesort_new.mem";
	parameter TEST_LENGTH = 200000;
	parameter TEST_NAME = "BUBBLE SORT";
	parameter LOG_FILE = "/home/nhat/Documents/Code/CPU_BFNP/Test_result/bubble_sort_test_results.txt";
	
	reg clk, rst_BF, rst_out, stall_2, hit_2;
	reg [31:0] pc_current, pc_previous;
	
	CPU #(	.PROGRAM_INST(PROGRAM_INST), 
		.PROGRAM_DATA(PROGRAM_DATA)
		) CPU (
		.clk(clk), 
		.rst_BF(rst_BF), 
		.rst_out(rst_out), 
		.pc_current(pc_current),
		.stall_2(stall_2),
		.hit_2(hit_2)
	);

	reg condition;
	integer log_file, x, misprediction, counter_clk, stall_number; 
	real number_inst, IPC, MPKI, hit_prediction_rate, branch_inst;
	
	always begin
		clk=0;
		forever #20 clk=~clk;
	end
	//Count Branch instruction
	initial begin
		branch_inst = 0;
	end
	always @(negedge clk) begin
		if  ( hit_2 == 1 )
			branch_inst = branch_inst + 1;
	end
	
	//IPC
	initial begin
		counter_clk  = 0;
		stall_number = 0;
	end
	
	always @(posedge clk) begin
		if (clk == 1)
			counter_clk = counter_clk + 1;
	end

	always @(posedge clk) begin
		if (stall_2 == 1)
			stall_number = stall_number + 1;
	end

	assign number_inst = counter_clk - stall_number - misprediction * 4;
	assign IPC = number_inst / counter_clk;
	assign MPKI = misprediction / number_inst * 1000;
	assign hit_prediction_rate = (1 - (misprediction / branch_inst)) * 100;
	// Misprediction
	always_ff @(posedge clk) begin
		if (rst_BF == 1)
			misprediction = 0;
		else
			if (rst_out)
				misprediction = misprediction + 1;
			else 
				misprediction = misprediction;
	end
	//Reset signal
	initial begin
		rst_BF = 1 ;
		#60 rst_BF = 0;
	end
	
	// Display
	initial begin	
	 #TEST_LENGTH
		//$display("Number of stall : %d", stall_number);
		$display("Number of instruction : %d", number_inst);
		$display("Number of branch instruction : %d", branch_inst);
		$display("Number of Clock cycles : %d", counter_clk);
		$display("IPC : %f", IPC);
		$display("MPKI : %f", MPKI);
		$display("Hit prediction rate : %f ",hit_prediction_rate);
 		log_file = $fopen(LOG_FILE,"a+");
 		if(!log_file) begin
 			$display("Could not open log file... Exiting!");
			$finish();
  		end

		assign condition = (`DATA_MEMORY[378] == 32'h0000014 )&(`DATA_MEMORY[377] == 32'h0000000a )&(`DATA_MEMORY[376] == 32'h00000008 )
		&(`DATA_MEMORY[375] == 32'h00000005 )&(`DATA_MEMORY[374] == 32'h00000004 )&(`DATA_MEMORY[373] == 32'h0000003 )
		&(`DATA_MEMORY[372] == 32'h00000002 )&(`DATA_MEMORY[371] == 32'h00000002 )&(`DATA_MEMORY[370] == 32'h00000001 )
		&(`DATA_MEMORY[369] == 32'hffffffff );
  		if(condition) begin
    			$display("%s: Test Passed!", TEST_NAME);
    			$fdisplay(log_file, "%s: Test Passed!", TEST_NAME);
			$display(" Number of misprediction in %s : %d instructions ", TEST_NAME, misprediction);
			$fdisplay(log_file," Number of misprediction in %s : %d instructions ", TEST_NAME, misprediction);
			$display("Dumping memory states:");
    			$display("Memory Index, Value");
    			for( x=368; x<379; x=x+1) begin
      				$display("%d: %h", x, `DATA_MEMORY[x]);
      				$fdisplay(log_file, "%d: %h", x, `DATA_MEMORY[x]);
    			end
    			$display("");
    			$fdisplay(log_file, "");
  		end 
		else begin
    			$display("%s: Test Failed!", TEST_NAME);
    			$display("Dumping memory states:");
    			$display("Memory Index, Value");
    			for( x=368; x<379; x=x+1) begin
      				$display("%d: %h", x, `DATA_MEMORY[x]);
      				$fdisplay(log_file, "%d: %h", x, `DATA_MEMORY[x]);
    			end
    			$display("");
    			$fdisplay(log_file, "");
  		end // pass/fail check

  		$fclose(log_file);
  		$stop();

	end
endmodule
