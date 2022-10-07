//module IMEM #(parameter PROGRAM_INST ="")(inst,clk,PC,rst,stall);
//	localparam	INST_WIDTH_LENGTH = 32;
//	localparam	PC_WIDTH_LENGTH = 32;
//	localparam	MEM_WIDTH_LENGTH = 32;
//	localparam	MEM_DEPTH = 1<<18;
//	output	reg	[INST_WIDTH_LENGTH-1:0]inst;
////	output  reg     en;
//	input		[PC_WIDTH_LENGTH-1:0]PC;
//	input           clk, rst, stall ;
////	input		[31:0]PCnew;
//	reg		[MEM_WIDTH_LENGTH-1:0]IMEM[MEM_DEPTH-1:0];
//
////	output reg		[1:0]a,t;
////	wire		[17:0] pWord,pWordnew,pWordnewnext;
//	wire		[17:0] pWord;
//	wire		[1:0] pByte;
////	output reg		[31:0] inst0next,instnext;
//
//
//	assign		pWord = PC[19:2];
//	assign		pByte = PC[1:0];
////	assign 		pWordnew = PCnew[19:2];
////	assign 		pWordnewnext=pWordnew+1;
//			
//	//reg [INST_WIDTH_LENGTH-1:0] temp, inst_temp;
//	initial begin
//		$readmemh(PROGRAM_INST,IMEM);
//	end
////	initial begin
////		en=1;
////		a=0;
////		t=1;
////	end
//
//	always_ff @(negedge clk) begin
//		if (pByte == 2'b00) begin
//			if (rst==1) 
//				inst <= 32'h00000033;	
//			else begin
//				if (stall==1) begin
//					inst <= inst;
//				end	
//				else begin
//					inst <= IMEM[pWord];
//				end
//			end
//		end
//		else
//			inst <= 32'h00000033;
//	end
////		en=1;
////		inst = 'hz;
////		
////		if (pByte == 2'b00)
////			begin
////			inst0next=IMEM[pWordnewnext];
////			instnext=IMEM[pWordnew];
////			inst = IMEM[pWord];
////			
////			if (a==0)
////				begin
////					if (((inst[6:0]==7'b0000011)&&(inst0next[6:0]==7'b0110011))||((inst[6:0]==7'b0000011) && (inst0next[6:0]==7'b0100011)))
////						begin
////							if ((inst[11:7]==inst0next[19:15])||(inst[11:7]==inst0next[24:20]))
////								begin 
////									en=0;
////									if (t==0) begin
////											inst=32'h00000033;
////											a=2;
////											en=1;
////										end
////									else t=0;
////								end
////						end
////					if ((inst[6:0]==7'b0000011)&&(inst0next[6:0]==7'b0010011))
////						begin
////							if (inst[11:7]==inst0next[19:15])
////								begin
////									en=0;
////									if (t==0) begin
////										inst=32'h00000033;
////										a=2;
////										en=1;
////										end
////									else t=0;
////								end 			
////						end
////					if (((instnext[6:0]==7'b0000011)&&(inst0next[6:0]==7'b0110011))||((instnext[6:0]==7'b0000011) && (inst0next[6:0]==7'b0100011)))
////						begin
////							if ((instnext[11:7]==inst0next[19:15])||(instnext[11:7]==inst0next[24:20]))
////								begin 
////									en=0;
////								end
////						end
////					if ((instnext[6:0]==7'b0000011)&&(inst0next[6:0]==7'b0010011))
////						begin
////							if (instnext[11:7]==inst0next[19:15])
////								begin
////									en=0;
////								end 			
////						end
////				//Branch stall
////					/*if ((instnext[6:0]==7'b1100011)||(instnext[6:0]==7'b1101111)||(instnext[6:0]==7'b1100111))
////						en=0;
////					if ((inst[6:0]==7'b1100011)||(inst[6:0]==7'b1101111)||(inst[6:0]==7'b1100111))
////						begin
////							en=0;
////							if (t==0) begin
////								inst=32'h00000033;
////								a=3;
////								end
////							else t=0;  
////						end 	*/
////
////				end
////			else if (a==3)  begin a=2; inst=32'h00000033; en=1; t=1; end
////			else if (a==2) begin 
////						a=1; inst=32'h00000033; en=1; t=1;
////		/*			 if ((instnext[6:0]==7'b1100011)||(instnext[6:0]==7'b1101111)||(instnext[6:0]==7'b1100111))
////						begin a=0; en=0; end*/
////		/*			 if ((instnext[6:0]==7'b0000011) && (inst0next[6:0]==7'b0100011))
////						begin
////							if ((instnext[11:7]==inst0next[19:15])||(instnext[11:7]==inst0next[24:20]))
////								begin a=0; en=0; end
////						end*/
////					end
////			else   begin   a=0;
////					/* if ((instnext[6:0]==7'b1100011)||(instnext[6:0]==7'b1101111)||(instnext[6:0]==7'b1100111))
////						 en=0;*/
////					
////				 end
////				
////			end
//endmodule

/* verilator lint_off UNUSED */
module IMEM #(parameter PROGRAM_INST ="/home/nhat/Documents/Reference_core/BRISC-V_Processors/software/applications/binaries/quicksort.mem")(inst,clk,PC,rst,stall);
	localparam	INST_WIDTH_LENGTH = 32;
	localparam	PC_WIDTH_LENGTH = 32;
	localparam	MEM_WIDTH_LENGTH = 32;
	localparam	MEM_DEPTH = 1<<14;
	output	reg	[INST_WIDTH_LENGTH-1:0]inst;
	reg [INST_WIDTH_LENGTH-1:0]inst_temp, inst_pre;
//	output  reg     en;
	input		[PC_WIDTH_LENGTH-1:0]PC;
	input           clk, rst, stall ;
//	input		[31:0]PCnew;
	/* verilator lint_off VARHIDDEN */
	reg		[MEM_WIDTH_LENGTH-1:0]IMEM[MEM_DEPTH-1:0];
	/* verilator lint_on VARHIDDEN */
	wire		[13:0] pWord;
	wire		[1:0] pByte;



	assign		pWord = PC[15:2];
	assign		pByte = PC[1:0];

	initial begin
		$readmemh(PROGRAM_INST,IMEM);
	end

	always_ff @(posedge clk)  begin
		inst_temp <= IMEM[pWord];
	end
	always_ff @(posedge clk)  begin
		inst_pre <= inst;
	end
	always_ff @(negedge clk) begin
		if (pByte == 2'b00) begin
			if (rst==1) 
				inst <= 32'h00000033;	
			else begin
				if (stall==1) begin
					inst <= inst_pre;
				end	
				else begin
					inst <= inst_temp;
				end
			end
		end
		else
			inst <= 32'h00000033;
	end

endmodule
/* verilator lint_on UNUSED */
