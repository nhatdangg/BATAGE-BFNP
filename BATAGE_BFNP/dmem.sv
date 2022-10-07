//module dmem #(parameter PROGRAM_DATA= "") (clk,Addr,MemRW,DataW,whb,DataR);
//	input wire clk;
//	input wire [2:0]whb;
//	input wire [31:0] Addr;
//	input wire MemRW;
//	input wire [31:0]DataW;
//	output reg [31:0] DataR;
//	wire [31:0]num;
//	wire[31:0]numinc;
//	reg [31:0]MEMO[0:4096];
//	integer i;
//	initial begin
//		DataR<=0;
//		for(i=0;i<=4096;i=i+1) begin
//			MEMO[i]=0;
//		end
//		$readmemh(PROGRAM_DATA,MEMO);
//	end
//	assign num=Addr>>2;
//	assign numinc=num+1;
//	always @* begin
//		if (whb==3'b000) 
//			case(Addr[1:0])
//			2'b00:DataR={{24{MEMO[num][7]}},MEMO[num][7:0]};
//			2'b01:DataR={{24{MEMO[num][15]}},MEMO[num][15:8]};
//			2'b10:DataR={{24{MEMO[num][23]}},MEMO[num][23:16]};
//			2'b11:DataR={{24{MEMO[num][31]}},MEMO[num][31:24]};
//			endcase
//		else if (whb==3'b001)
//			case(Addr[1:0])
//		         2'b00:DataR={{16{MEMO[num][15]}},MEMO[num][15:0]};
//			 2'b01:DataR={{16{MEMO[num][23]}},MEMO[num][23:8]};
//			 2'b10:DataR={{16{MEMO[num][31]}},MEMO[num][31:16]};
//			 2'b11:DataR={{16{MEMO[numinc][7]}},MEMO[numinc][7:0],MEMO[num][31:24]};
//			endcase
//		else if (whb==3'b010) DataR=MEMO[num];	
//		else if (whb==3'b011)
//			case(Addr[1:0])
//			 2'b00:DataR={24'b0,MEMO[num][7:0]};
//			 2'b01:DataR={24'b0,MEMO[num][15:8]};
//			 2'b10:DataR={24'b0,MEMO[num][23:16]};
//			 2'b11:DataR={24'b0,MEMO[num][31:24]};
//			endcase
//		else if (whb==3'b100)
//			 case(Addr[1:0])
//			 2'b00:DataR={16'b0,MEMO[num][15:0]};
//			 2'b01:DataR={16'b0,MEMO[num][23:8]};
//			 2'b10:DataR={16'b0,MEMO[num][31:16]};
//			 2'b11:DataR={16'b0,MEMO[numinc][7:0],MEMO[num][31:24]};
//			endcase 
//	end
//	always @(posedge clk) begin
//		if ((MemRW==1'b1)&&(whb==3'd0))
//			case(Addr[1:0])
//			 2'b00:MEMO[num][7:0]=DataW[7:0];
//			 2'b01:MEMO[num][15:8]=DataW[7:0];
//			 2'b10:MEMO[num][23:16]=DataW[7:0];
//			 2'b11:MEMO[num][31:24]=DataW[7:0];
//			endcase
//		else if ((MemRW==1'b1)&&(whb==3'd1))
//			case(Addr[1:0])
//			 2'b00:MEMO[num][15:0]=DataW[15:0];
//			 2'b01:MEMO[num][23:8]=DataW[15:0];
//			 2'b10:MEMO[num][31:16]=DataW[15:0];
//			 2'b11:begin MEMO[num][31:24]=DataW[7:0];MEMO[numinc][7:0]=DataW[15:8]; end				 
//			endcase
//		else if((MemRW==1'b1)&&(whb==3'd2)) 
//			 MEMO[num]=DataW;
//	
//	end
//			
//	
//endmodule

/* verilator lint_off UNUSED */
module dmem #(parameter PROGRAM_DATA= "/home/nhat/Documents/Reference_core/BRISC-V_Processors/software/applications/binaries/data_quicksort_new.mem") (clk,Addr,MemRW,DataW,whb,DataR);
	input wire clk;
	input wire [2:0]whb;
	input wire [31:0] Addr;
	input wire MemRW;
	input wire [31:0]DataW;
	output reg [31:0] DataR;
	wire [31:0]num;
	wire[31:0]numinc;
	reg [31:0]MEMO[20000:0];
	integer i;
	initial begin
		//DataR<=0;
		for(i=0;i<=4095;i=i+1) begin
			MEMO[i]=0;
		end 
		$readmemh(PROGRAM_DATA,MEMO);
	end
	assign num=Addr>>2;
	assign numinc=num+1;
	//
	reg [7:0] fir_byte, sec_byte, thir_byte, four_byte;
	reg [7:0] data_1, data_1_inc, data_2, data_3, data_4;
	reg sig_1, sig_2, sig_3, sig_4, sig_1_inc, sig_1_inc_r;
	wire sig = (sig_1 == 1) ? sig_1 :
				  (sig_1_inc == 1) ? sig_1_inc :
				  1'b0;
	wire [7:0] data = (sig_1 == 1) ? data_1 :
				   (sig_1_inc == 1) ? data_1_inc :
				   0;
	wire [31:0] num_1 = (sig_1 == 1) ? num :					//write
				    (sig_1_inc == 1) ? numinc :
				    0;
	wire [31:0] num_1_r = (sig_1_inc_r == 1) ? numinc : num;
					   
	always @(posedge clk) begin
		if (sig) 
			MEMO[num_1][7:0] <= data;
		fir_byte <= MEMO[num_1_r][7:0];
	end
	
	always @(posedge clk) begin
		if (sig_2) 
			MEMO[num][15:8] <= data_2;
		sec_byte <= MEMO[num][15:8];
	end
	
	always @(posedge clk) begin
		if (sig_3) 
			MEMO[num][23:16] <= data_3;
		thir_byte <= MEMO[num][23:16];
	end
	
	always @(posedge clk) begin
		if (sig_4) 
			MEMO[num][31:24] <= data_4;
		four_byte <= MEMO[num][31:24];
	end
	
	always @* begin
		if (whb==3'b000) 
			case(Addr[1:0])
			2'b00: begin DataR = {{24{fir_byte[7]}},fir_byte}; sig_1_inc_r = 0; end
			2'b01: begin DataR = {{24{sec_byte[7]}},sec_byte}; sig_1_inc_r = 0; end
			2'b10: begin DataR = {{24{thir_byte[7]}},thir_byte}; sig_1_inc_r = 0; end
			default: begin DataR = {{24{four_byte[7]}},four_byte}; sig_1_inc_r = 0; end
			endcase
		else if (whb==3'b001) begin
			case(Addr[1:0])
		    2'b00: begin DataR = {{16{sec_byte[7]}},{sec_byte,fir_byte}}; sig_1_inc_r = 0; end
			 2'b01: begin DataR = {{16{thir_byte[7]}},{thir_byte,sec_byte}}; sig_1_inc_r = 0; end
			 2'b10: begin DataR = {{16{four_byte[7]}},{four_byte,thir_byte}}; sig_1_inc_r = 0; end
			 default: begin DataR = {{16{fir_byte[7]}},fir_byte,four_byte}; sig_1_inc_r = 1; end
			endcase
		end	
		else if (whb==3'b010) begin DataR = {four_byte,thir_byte,sec_byte,fir_byte};	sig_1_inc_r = 0; end
		else if (whb==3'b011) begin
			case(Addr[1:0])
			 2'b00: begin DataR={24'b0,fir_byte}; sig_1_inc_r = 0; end
			 2'b01: begin DataR={24'b0,sec_byte}; sig_1_inc_r = 0; end
			 2'b10: begin DataR={24'b0,thir_byte}; sig_1_inc_r = 0; end
			 default: begin DataR={24'b0,four_byte}; sig_1_inc_r = 0; end
			endcase
		end
		else if (whb==3'b100) begin
			 case(Addr[1:0])
			 2'b00: begin DataR={16'b0,sec_byte,fir_byte}; sig_1_inc_r = 0; end
			 2'b01: begin DataR={16'b0,thir_byte,sec_byte}; sig_1_inc_r = 0; end
			 2'b10: begin DataR={16'b0,four_byte,thir_byte}; sig_1_inc_r = 0; end
			 default: begin DataR={16'b0,fir_byte,four_byte}; sig_1_inc_r = 1; end
			endcase 
		end 
		else begin
			DataR = 0; sig_1_inc_r = 0;
		end
	end
	
	always_comb begin
		if ((MemRW==1'b1)&&(whb==3'd0)) begin
			case(Addr[1:0])
			 2'b00: begin data_1=DataW[7:0]; sig_1= 1; {data_2,data_3,data_4,data_1_inc} = 0; {sig_1_inc, sig_2, sig_3, sig_4} = 0; end
			 2'b01: begin data_2=DataW[7:0]; sig_2= 1; {data_1,data_3,data_4,data_1_inc} = 0; {sig_1_inc, sig_1, sig_3, sig_4} = 0; end
			 2'b10: begin data_3=DataW[7:0]; sig_3= 1; {data_1,data_2,data_4,data_1_inc} = 0; {sig_1_inc, sig_1, sig_2, sig_4} = 0; end
			 default: begin data_4=DataW[7:0]; sig_4= 1; {data_1,data_2,data_3,data_1_inc} = 0; {sig_1_inc, sig_1, sig_2, sig_3} = 0; end
			endcase
		end else if ((MemRW==1'b1)&&(whb==3'd1)) begin
			case(Addr[1:0])
			 2'b00: begin {data_2,data_1}=DataW[15:0]; {sig_1, sig_2}= 2'd3; {data_3,data_4,data_1_inc} = 0; {sig_1_inc, sig_3, sig_4} = 0; end
			 2'b01: begin {data_3,data_2}=DataW[15:0]; {sig_2, sig_3}= 2'd3; {data_1,data_4,data_1_inc} = 0; {sig_1_inc, sig_1, sig_4} = 0; end
			 2'b10: begin {data_4,data_3}=DataW[15:0]; {sig_4, sig_3}= 2'd3; {data_1,data_2,data_1_inc} = 0; {sig_1_inc, sig_1, sig_2} = 0; end
			 default: begin data_4=DataW[7:0];data_1_inc=DataW[15:8]; {sig_1_inc, sig_4}= 2'd3; {data_1,data_2,data_3} = 0; {sig_2, sig_3, sig_1} = 0; end				 
			endcase
		end else if((MemRW==1'b1)&&(whb==3'd2)) begin
			 {data_4,data_3,data_2,data_1}=DataW;
			 data_1_inc = 0;
			 {sig_1, sig_2, sig_3, sig_4} = 4'b1111;
			 sig_1_inc = 1;
		end else
			begin data_1 = 0; data_2 = 0; data_3 = 0; data_4 = 0; data_1_inc = 0; {sig_1_inc, sig_2, sig_3, sig_4, sig_1} = 0;end
	end
			
	
endmodule
/* verilator lint_on UNUSED */
