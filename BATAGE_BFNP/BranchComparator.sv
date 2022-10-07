module BranchComparator(rs1,rs2,BrUn,BrEq,BrLT);
	input wire [31:0]rs1;
	input wire [31:0]rs2;
	input wire BrUn;
	output reg  BrEq;
	output reg  BrLT;
	always_comb begin
		case(BrUn)
			1'b0: if (rs1==rs2)
				begin	
					BrEq=1'b1;
					BrLT=1'b0;
		        	end
		      	      else if ($signed(rs1)<$signed(rs2))
				begin	
					BrEq=1'b0;
					BrLT=1'b1;
		        	end
		      	      else begin
					BrEq=1'b0;
					BrLT=1'b0;
				end 
			1'b1:if (rs1==rs2)
				begin	
					BrEq=1'b1;
					BrLT=1'b0;
		        	end
		      	     else if (rs1<rs2)
				begin	
					BrEq=1'b0;
					BrLT=1'b1;
		        	end
		      	     else begin
					BrEq=1'b0;
					BrLT=1'b0;
				end 
		endcase 
	end
endmodule
