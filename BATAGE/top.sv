`include "processor_specific_macros.h"
`timescale 1ps/1ps
module top (clk, rst_BF);
	input reg clk, rst_BF;
	/* verilator lint_off UNUSED */
	reg [32:1] inst_2, inst_4;
	reg rst_out, stall_2, hit_2, sig;
	reg [31:0] pc_current, pc_4, pc_3, pc_2;
	
	CPU #(	.PROGRAM_INST(`PROGRAM), 
		.PROGRAM_DATA(`PROGRAM)
		) CPU (
		.inst_2(inst_2),
		.inst_4(inst_4),
		.pc_3(pc_3),
		.pc_4(pc_4),
		.pc_2(pc_2),
		.clk(clk), 
		.rst_BF(rst_BF), 
		.rst_out(rst_out), 
		.pc_current(pc_current),
		.stall_2(stall_2),
		.hit_2(hit_2)
	);
	//Check number of miss occur twice consecutively
	reg [5:1] miss_2;
	reg [5*32:1] inst_miss;
	integer miss_2_c = 0;
	always @(posedge clk) begin
		miss_2 <= {rst_out, miss_2[5:2]};
		inst_miss <= {inst_2, inst_miss[32*5:33]};
		if ( (miss_2 == 5'b10001) && (inst_miss[32*5:32*4+1]==inst_miss[32:1]) ) begin
			miss_2_c <= miss_2_c + 1;
			//$display("%08x %08x %08x %08x\n", number_inst, pc_4-4, inst_4, pc_current);
		end
	end

	integer miss_pre_conf_0 = 0;
	integer miss_pre_conf_1 = 0;
	integer miss_pre_conf_2 = 0;
	integer log_file, verify_file , ana_file, stall_number,misprediction_cont, number_inst; 
	real  IPC, MPKI, hit_prediction_rate, branch_inst, misprediction, counter_clk;
	wire init = (counter_clk == 0);
	always @(posedge clk) begin
		if ( (CPU.BATAGE.confidence_final_update == 0) & (rst_out) )
			miss_pre_conf_0 <= miss_pre_conf_0 + 1;
		if ( (CPU.BATAGE.confidence_final_update == 1) & (rst_out) )
			miss_pre_conf_1 <= miss_pre_conf_1 + 1;
		if ( (CPU.BATAGE.confidence_final_update == 2) & (rst_out) )
			miss_pre_conf_2 <= miss_pre_conf_2 + 1;
	end
	//Count Branch instruction
	initial begin
		number_inst = 1;
		branch_inst = 0;
	end
	always @(negedge clk) begin
		if  ( ((inst_2[7:1] == 7'b1100011)||(inst_2[7:1] == 7'b1101111)||(inst_2[7:1] == 7'b1100111)))
			branch_inst <= branch_inst + 1;
	end
	
	//IPC
	initial begin
		counter_clk  = 0;
		stall_number = 0;
	end
	
	always @(posedge clk) begin
		if (clk == 1)
			counter_clk <= counter_clk + 1;
	end

	always @(posedge clk) begin
		if (init)
			stall_number <= 0;
		else if (stall_2 == 1) 
			stall_number <= stall_number + 1;
	end

	
	assign IPC = (number_inst * 1000 / counter_clk) / 1000;
	assign MPKI = misprediction * 1000 / number_inst ;
	assign hit_prediction_rate = (1000 - (misprediction * 1000 / branch_inst)) / 10 ;
	// Misprediction
	always_ff @(posedge clk) begin
		if ((rst_BF == 1) || init)
			misprediction <= 0;
		else
			if (rst_out) begin
				misprediction <= misprediction + 1;
`ifdef ANALYSIS
			        $display("%08x %08x %08x\n", number_inst+2, pc_2, inst_2);
			        $fwrite(ana_file, "%08x %08x %08x\n", number_inst+2, pc_2, inst_2);
`endif
			end else 
				misprediction <= misprediction;
	end
	//
	always @(posedge clk) begin
		if (/*(pc_4 != pc_3) &&*/ (inst_4 != 32'h00000033 || (pc_4 == 32'h00000008)) && (counter_clk >= 5) ) begin
`ifdef DEBUG
			$fwrite(verify_file, "%08x %08x %08x\n", number_inst, pc_4-4, inst_4);
			for (i = 0; i < 4; i = i + 1) begin
                   		for (j = 0; j < 8; j = j + 1) begin
                        		$fwrite(verify_file, "%08x", ((i*8+j == {27'd0,CPU.Register.AddrD}) && (i*8+j != 0) && CPU.Register.RegWEn ) ? 
                               CPU.Register.DataD : `REGISTER_FILE[i * 8 + j]);
        		                $fwrite(verify_file, "%s", (j != 7 ? " " : "\n"));
                    		end
                	end
`endif		
			number_inst <= number_inst + 1;
			sig <= 1;
		end else begin
			number_inst <= number_inst;
			sig <= 0;
		end
	end
	integer i,j;
	always_ff @(negedge clk) begin
		if (sig && (number_inst < `TEST_LENGTH2)) begin
			
		end
	end
	
	initial begin
`ifdef DEBUG
		verify_file = $fopen(`VERIFY_FILE,"w");
`endif
//`ifdef ANALYSIS
		ana_file = $fopen(`ANALYSIS_FILE,"w");
//`endif
		log_file = $fopen(`LOG_FILE,"w");
		
	end
	// Display
	reg c = 0;
	reg c2 = 0;
	always @(negedge clk) begin	
		if (number_inst == `TEST_LENGTH1 && !c) begin
		//$display("Number of stall : %d", stall_number);
			c <= 1;
			if(log_file != 0) begin
				$display("Could not open log file... Exiting!");
				$finish();
			end
			$display("%s: Test Passed!", `TEST_NAME);
                        $fdisplay(log_file, "%s: Test Passed!", `TEST_NAME);
			
			$display("Number of instruction after initialize phase : %d", number_inst);
			$fdisplay(log_file, "Number of instruction after initialize phase : %d", number_inst);
			$display("Number of branch instruction after initialize phase : %f", branch_inst);
			$fdisplay(log_file, "Number of branch instruction after initialize phase : %f", branch_inst);
			$display("Number of miss prediction branch instruction after initialize phase : %f", misprediction);
                        $fdisplay(log_file, "Number of miss prediction branch instruction after initialize phase : %f", misprediction);
			$display("Number of Clock cycles : %f", counter_clk);
			$fdisplay(log_file, "Number of Clock cycles : %f", counter_clk);
			$display("IPC : %f", (number_inst / counter_clk) );
			$fdisplay(log_file, "IPC : %f", (number_inst  / counter_clk) );
			$display("MPKI : %f", misprediction * 1000 / number_inst);
			$fdisplay(log_file, "MPKI : %f", misprediction * 1000 / number_inst);
			$display("Hit prediction rate : %f ",hit_prediction_rate);
			$fdisplay(log_file, "Hit prediction rate : %f ",(1000 - (misprediction * 1000 / branch_inst)) / 10);

			$display("Number of miss twice in a row : %d ", miss_2_c);
			$fdisplay(log_file,"Number of miss twice in a row : %d ", miss_2_c);
			$display("Miss prediction BATAGE confidence 0 : %d", miss_pre_conf_0);
			$display("Miss prediction BATAGE confidence 1 : %d", miss_pre_conf_1);
			$display("Miss prediction BATAGE confidence 2 : %d", miss_pre_conf_2);
			$fdisplay(log_file,"Miss prediction BATAGE confidence 0 : %d", miss_pre_conf_0);
			$fdisplay(log_file,"Miss prediction BATAGE confidence 1 : %d", miss_pre_conf_1);
			$fdisplay(log_file,"Miss prediction BATAGE confidence 2 : %d", miss_pre_conf_2);
			$display("");
			$fdisplay(log_file, "");

			
		end
		if (number_inst == `TEST_LENGTH2 && !c2) begin
		//$display("Number of stall : %d", stall_number);
			c2 <= 1;
			$display("%s: Test Passed!", `TEST_NAME);
                        $fdisplay(log_file, "%s: Test Passed!", `TEST_NAME);
			
			$display("Number of instruction after initialize phase : %d", number_inst);
			$fdisplay(log_file, "Number of instruction after initialize phase : %d", number_inst);
			$display("Number of branch instruction after initialize phase : %f", branch_inst);
			$fdisplay(log_file, "Number of branch instruction after initialize phase : %f", branch_inst);
			$display("Number of miss prediction branch instruction after initialize phase : %f", misprediction);
                        $fdisplay(log_file, "Number of miss prediction branch instruction after initialize phase : %f", misprediction);
			$display("Number of Clock cycles : %f", counter_clk);
			$fdisplay(log_file, "Number of Clock cycles : %f", counter_clk);
			$display("IPC : %f", (number_inst / counter_clk) );
			$fdisplay(log_file, "IPC : %f", (number_inst  / counter_clk) );
			$display("MPKI : %f", misprediction * 1000 / number_inst);
			$fdisplay(log_file, "MPKI : %f", misprediction * 1000 / number_inst);
			$display("Hit prediction rate : %f ",hit_prediction_rate);
			$fdisplay(log_file, "Hit prediction rate : %f ",(1000 - (misprediction * 1000 / branch_inst)) / 10);

			$display("Number of miss twice in a row : %d ", miss_2_c);
			$fdisplay(log_file,"Number of miss twice in a row : %d ", miss_2_c);
			$display("Miss prediction BATAGE confidence 0 : %d", miss_pre_conf_0);
			$display("Miss prediction BATAGE confidence 1 : %d", miss_pre_conf_1);
			$display("Miss prediction BATAGE confidence 2 : %d", miss_pre_conf_2);
			$fdisplay(log_file,"Miss prediction BATAGE confidence 0 : %d", miss_pre_conf_0);
			$fdisplay(log_file,"Miss prediction BATAGE confidence 1 : %d", miss_pre_conf_1);
			$fdisplay(log_file,"Miss prediction BATAGE confidence 2 : %d", miss_pre_conf_2);
			$display("");
			$fdisplay(log_file, "");
			$fclose(log_file);
			$fclose(verify_file);
			$finish();
			
		end
	end
endmodule
/* verilator lint_on UNUSED */

