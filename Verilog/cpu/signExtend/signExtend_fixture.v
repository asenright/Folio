`include "signExtend.v"

module signExtend_fixture();

wire[15:0] out1;
reg[7:0] in1;
signExtend #(16) uut (in1, out1);

initial begin
$vcdpluson;
$monitor($time, " \n in1 = %b\nout1 = %b\n\n", in1, out1);
end

initial
begin
	in1 = 8'h00;
end

initial 
begin
	#10 in1 = 8'hF0;
	#10 in1 = 8'h0F;	
end
initial
begin
	#30 $finish;
end

endmodule
