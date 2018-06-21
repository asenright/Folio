`include "jumpControl.v"

module buffer_fixture();
wire result;
reg[3:0] opcode;
reg neg, zero;
jumpControl uut (.opcode(opcode), .neg(neg), .zero(zero), .result(result));

initial begin
$vcdpluson;
$monitor("#",$time, "\nopcode = %h | neg = %h | zero = %h | result = %h",opcode,neg,zero,result );
end

initial
begin
	opcode = 4'b0000;
	neg = 1'b0;
	zero = 1'b0;
end

initial 
begin
	#10 $display("Unconditional Jump");
	    opcode = 4'b0001;
	#10 opcode = 4'b0000;
	#10 $display("Branch on less");
	    opcode = 4'b0101;
	    neg = 1'b1;
	#10 neg = 1'b0;
	#10 $display("Branch on equal");
	    opcode = 4'b0110;
	    zero = 1'b1;
	#10 zero = 1'b0;
	#10 $display("Branch on greater than");
	    opcode = 4'b0100;
	    neg = 1'b1;
	
end
initial
begin
	#110 $finish;
end

endmodule
