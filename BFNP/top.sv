`include "processor_specific_macros.h"
`timescale 1ps/1ps
module top (clk, rst_BF);
	input reg clk, rst_BF;
	/* verilator lint_off UNUSED */
	reg [32:1] inst_2, inst_4;
	reg rst_out, stall_2, hit_2, sig, hit_hb_o;
	reg [31:0] pc_current, pc_4, pc_3, pc_2;
        reg [31:0] profile_branch [3:0];	
        reg [32*64-1:0] db_profile_branch;	
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
		.hit_2(hit_2),
                .hit_hb_o(hit_hb_o)
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

	
	integer log_file, verify_file , ana_file, stall_number,misprediction_cont, number_inst; 
	real  IPC, MPKI, hit_prediction_rate, branch_inst, misprediction, counter_clk, false_dd_branch, dd_branch, cond_inst;
	wire init = (counter_clk == 0);
	
	//Count Branch instruction
	initial begin
                profile_branch[0] = 0;
                profile_branch[1] = 0;
                profile_branch[2] = 0;
                profile_branch[3] = 0;
		db_profile_branch = 0;
                number_inst = 1;
                cond_inst = 0;
		branch_inst = 0;
                dd_branch = 0;
                false_dd_branch = 0;
	end
        reg sum;
        reg [31:0] iinst_br_2;
        always @(negedge clk) begin
                if (sum == 0) begin
                    db_profile_branch <= {db_profile_branch[32*63-1:0], iinst_br_2};
                end
        end
        always @(posedge clk) begin
            sum <= 0;
            for (j=0; j<=3; j++) begin
                for (i=0; i<=63; i++) begin
                    if (CPU.Hard_branch_predict.Cache_predict.iinst_br == db_profile_branch[i*32+:32]) 
                        sum <= 1;
                end
            end
            iinst_br_2 <= CPU.Hard_branch_predict.Cache_predict.iinst_br;   
        end

        reg [31:0] oinst_br_o = CPU.Hard_branch_predict.Cache_predict.oinst_br;
        wire condition_2 = ((oinst_br_o == 32'h00068463) && (CPU.inst == 32'h0015f693)) 
        || (oinst_br_o == 32'hfe0596e3) || (oinst_br_o == 32'hfc0698e3); //aha-mont64
        wire condition = ((CPU.inst == 32'h00068463) && (CPU.inst1 == 32'h0015f693)) 
        || (CPU.inst == 32'hfe0596e3) || (CPU.inst == 32'hfc0698e3); //aha-mont64

        reg hit_hb_o_2, rst_out_1, rst_out_2;
	always @(negedge clk) begin
		if  ( ((inst_2[7:1] == 7'b1100011)||(inst_2[7:1] == 7'b1101111)||(inst_2[7:1] == 7'b1100111)) ) begin
			branch_inst <= branch_inst + 1;
                end
                if (inst_2[7:1] == 7'b1100011) begin 
                     cond_inst <= cond_inst + 1;
                end
                if (condition)
                    dd_branch <= dd_branch + 1;
                if (/*hit_hb_o & condition_2 ||*/ condition & rst_out_2)
                        false_dd_branch <= false_dd_branch + 1;
	end
	always @(negedge clk) begin
            hit_hb_o_2 <= hit_hb_o;
            rst_out_1 <= rst_out;
            rst_out_2 <= rst_out_1;
        end	
	//IPC
	initial begin
		counter_clk  = 0;
		stall_number = 0;
	end
	
	always @(posedge clk) begin
		if (clk == 1)
			counter_clk <= counter_clk + 1;
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
			$display("Number of conditional branch instruction after initialize phase : %f", cond_inst);
			$fdisplay(log_file, "Number of conditional branch instruction after initialize phase : %f", cond_inst);
			$display("Number of data-dependent branch instruction after initialize phase : %f", dd_branch);
			$fdisplay(log_file, "Number of data-dependent branch instruction after initialize phase : %f", dd_branch);
			$display("Number of false predicted data-dependent branch instruction after initialize phase : %f", false_dd_branch);
			$fdisplay(log_file, "Number of false predicted data-dependent branch instruction after initialize phase : %f", false_dd_branch);
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
			$display("Number of conditional branch instruction after initialize phase : %f", cond_inst);
			$fdisplay(log_file, "Number of conditional branch instruction after initialize phase : %f", cond_inst);
			$display("Number of data-dependent branch instruction after initialize phase : %f", dd_branch);
			$fdisplay(log_file, "Number of data-dependent branch instruction after initialize phase : %f", dd_branch);
			$display("Number of false predicted data-dependent branch instruction after initialize phase : %f", false_dd_branch);
			$fdisplay(log_file, "Number of false predicted data-dependent branch instruction after initialize phase : %f", false_dd_branch);
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
        //                for (int m=0; m <= 63; m++) begin
        //                    $display("Data dependent inst %d : %h ", m, db_profile_branch[m*32+:32] );
        //                    $fdisplay(log_file,"Data dependent inst %d : %h ", m, db_profile_branch[m*32+:32]);
        //                end
			$display("");
			$fdisplay(log_file, "");
			$fclose(log_file);
			$fclose(verify_file);
			$finish();
			
		end
	end
endmodule
/* verilator lint_on UNUSED */

