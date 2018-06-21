module ALU(input aluOp, input[3:0] opcode, input signed[15:0] op1, op2, output reg[15:0] out, R15, output reg error, neg, zero);
always@(*) 
begin
if (aluOp) 
	begin
	error = 1'b0; // optional for throwing error
	neg = ((op1 - op2) > 0);
	zero = ((op1 - op2) == 0);
    if (opcode == 4'b0000)			//signed addition
	  begin
		 out = op1 + op2;
		 R15 = 16'h0000;
	  end
    else if (opcode == 4'b0001)		//signed subtraction
	  begin
		 out = op1 - op2;
		 R15 = 16'h0000;
	  end
    else if (opcode == 4'b0100) 		//signed multiplication
	  begin
		 {R15, out} = op1 * op2;
	  end
    else if (opcode == 4'b0101) 		//signed division
	  begin
		 out = op1 / op2;
		 R15  = op1 % op2;
	  end
	end
else 
begin
        out = 16'h0000;
        R15  = 16'h0000;
end
end
endmodule
