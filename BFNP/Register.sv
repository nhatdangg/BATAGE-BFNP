module Register(
	input wire [4:0] AddrD,AddrA,AddrB,
	input wire [31:0] DataD,
	input wire RegWEn,
	input wire clk,
	output wire [31:0] oregister [31:0],
	output reg [31:0] rs1,
	output reg [31:0] rs2
);
	/* verilator lint_off VARHIDDEN */
	reg [31:0]Register[31:0];
	assign oregister = Register;
	/* verilator lint_on VARHIDDEN */
	initial begin
		Register[0]=32'd0;
		Register[1]=32'd0;
		Register[2]=32'd0;
		Register[3]=32'd0;
		Register[4]=32'd0;
		Register[5]=32'd0;
		Register[6]=32'd0;
		Register[7]=32'd0;
		Register[8]=32'd0;
		Register[9]=32'd0;
		Register[10]=32'd0;
		Register[11]=32'd0;
		Register[12]=32'd0;
		Register[13]=32'd0;
		Register[14]=32'd0;
		Register[15]=32'd0;
		Register[16]=32'd0;
		Register[17]=32'd0;
		Register[18]=32'd0;
		Register[19]=32'd0;
		Register[20]=32'd0;
		Register[21]=32'd0;
		Register[22]=32'd0;
		Register[23]=32'd0;
		Register[24]=32'd0;
		Register[25]=32'd0;
		Register[26]=32'd0;
		Register[27]=32'd0;
		Register[28]=32'd0;
		Register[29]=32'd0;
		Register[30]=32'd0;
		Register[31]=32'd0;
	end
	/* verilator lint_off COMBDLY */
	always_comb begin
			case(AddrA)
				5'b00000 : rs1<=Register[0];
				5'b00001 : rs1<=Register[1];
				5'b00010 : rs1<=Register[2];
				5'b00011 : rs1<=Register[3];
				5'b00100 : rs1<=Register[4];
				5'b00101 : rs1<=Register[5];
				5'b00110 : rs1<=Register[6];
				5'b00111 : rs1<=Register[7];
				5'b01000 : rs1<=Register[8];
				5'b01001 : rs1<=Register[9];
				5'b01010 : rs1<=Register[10];
				5'b01011 : rs1<=Register[11];
				5'b01100 : rs1<=Register[12];
				5'b01101 : rs1<=Register[13];
				5'b01110 : rs1<=Register[14];
				5'b01111 : rs1<=Register[15];
				5'b10000 : rs1<=Register[16];
				5'b10001 : rs1<=Register[17];
				5'b10010 : rs1<=Register[18];
				5'b10011 : rs1<=Register[19];
				5'b10100 : rs1<=Register[20];
				5'b10101 : rs1<=Register[21];
				5'b10110 : rs1<=Register[22];
				5'b10111 : rs1<=Register[23];
				5'b11000 : rs1<=Register[24];
				5'b11001 : rs1<=Register[25];
				5'b11010 : rs1<=Register[26];
				5'b11011 : rs1<=Register[27];
				5'b11100 : rs1<=Register[28];
				5'b11101 : rs1<=Register[29];
				5'b11110 : rs1<=Register[30];
				5'b11111 : rs1<=Register[31];
			endcase
			case(AddrB)
				5'b00000 : rs2<=Register[0];
				5'b00001 : rs2<=Register[1];
				5'b00010 : rs2<=Register[2];
				5'b00011 : rs2<=Register[3];
				5'b00100 : rs2<=Register[4];
				5'b00101 : rs2<=Register[5];
				5'b00110 : rs2<=Register[6];
				5'b00111 : rs2<=Register[7];
				5'b01000 : rs2<=Register[8];
				5'b01001 : rs2<=Register[9];
				5'b01010 : rs2<=Register[10];
				5'b01011 : rs2<=Register[11];
				5'b01100 : rs2<=Register[12];
				5'b01101 : rs2<=Register[13];
				5'b01110 : rs2<=Register[14];
				5'b01111 : rs2<=Register[15];
				5'b10000 : rs2<=Register[16];
				5'b10001 : rs2<=Register[17];
				5'b10010 : rs2<=Register[18];
				5'b10011 : rs2<=Register[19];
				5'b10100 : rs2<=Register[20];
				5'b10101 : rs2<=Register[21];
				5'b10110 : rs2<=Register[22];
				5'b10111 : rs2<=Register[23];
				5'b11000 : rs2<=Register[24];
				5'b11001 : rs2<=Register[25];
				5'b11010 : rs2<=Register[26];
				5'b11011 : rs2<=Register[27];
				5'b11100 : rs2<=Register[28];
				5'b11101 : rs2<=Register[29];
				5'b11110 : rs2<=Register[30];
				5'b11111 : rs2<=Register[31];
			endcase
			end

	always@(posedge clk) 
			begin
			case(RegWEn)
				1'b1:	case(AddrD)
					5'b00000 : Register[0]<=32'd0;
					5'b00001 : Register[1]<=DataD;
					5'b00010 : Register[2]<=DataD;
					5'b00011 : Register[3]<=DataD;
					5'b00100 : Register[4]<=DataD;
					5'b00101 : Register[5]<=DataD;
					5'b00110 : Register[6]<=DataD;
					5'b00111 : Register[7]<=DataD;
					5'b01000 : Register[8]<=DataD;
					5'b01001 : Register[9]<=DataD;
					5'b01010 : Register[10]<=DataD;
					5'b01011 : Register[11]<=DataD;
					5'b01100 : Register[12]<=DataD;
					5'b01101 : Register[13]<=DataD;
					5'b01110 : Register[14]<=DataD;
					5'b01111 : Register[15]<=DataD;
					5'b10000 : Register[16]<=DataD;
					5'b10001 : Register[17]<=DataD;
					5'b10010 : Register[18]<=DataD;
					5'b10011 : Register[19]<=DataD;
					5'b10100 : Register[20]<=DataD;
					5'b10101 : Register[21]<=DataD;
					5'b10110 : Register[22]<=DataD;
					5'b10111 : Register[23]<=DataD;
					5'b11000 : Register[24]<=DataD;
					5'b11001 : Register[25]<=DataD;
					5'b11010 : Register[26]<=DataD;
					5'b11011 : Register[27]<=DataD;
					5'b11100 : Register[28]<=DataD;
					5'b11101 : Register[29]<=DataD;
					5'b11110 : Register[30]<=DataD;
					5'b11111 : Register[31]<=DataD;	
				endcase
				1'b0:;
			endcase
		end
		/* verilator lint_on COMBDLY */
endmodule
