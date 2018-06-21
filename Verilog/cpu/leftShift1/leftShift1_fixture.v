`include "leftShift1.v"

module ls1_fixture();

wire[15:0] out1;
reg[15:0] in1;
leftShift1 #(16) uut (in1, out1);

initial begin
$vcdpluson;
$monitor($time, " \n in1 = %b\nout1 = %b\n\n", in1, out1);
end

initial
begin
	in1 = 16'h0000;
end


initial 
begin
	#10 in1 = 16'hF0F0;
	#10 in1 = 16'h0F0F;	
end
initial
begin
	#30 $finish;
end

endmodule
