`include "adder.v"

module adder_fixture();
wire signed [15:0] out;
wire carry;
reg signed [15:0] in1, in2;

adder uut (in1, in2, carry, out);

initial begin
$vcdpluson;
$monitor("#", $time, " : in1 = %d | in2 = %d | carry = %b | result = %d", 
	in1, in2, carry, out);
end

initial
begin
	in1 = 16'h0000;
	in2 = 16'h0000;
end

initial 
begin
	#10 in1 = 16'h0002;
		in2 = 16'h0004;
	#10 in1 = 16'h0008;
		in2 = 16'hFFFD;
	#10 in1 = 16'hFFFD;
	
end
initial
begin
	#40 $finish;
end

endmodule
