`include "lockBuffer.v"

module buffer_fixture();
wire out1;
reg in1;
reg clk, dis;
lockBuffer #(1) uut (in1, clk, dis, out1);

initial begin
$vcdpluson;
$monitor($time, " in1 = %h|out1 = %h|clk = %h|dis = %h", out1, in1, clk, dis);
end

initial
begin
	in1 = 1'b0;
	clk = 1'b0;
	dis = 1'b0;
end

always
begin
	#5 clk = ~clk;
end


initial 
begin
	$display("Test buffer response");
	#10 in1 = 1'b0;
	#10 in1 = 1'b1;
	#10 in1 = 1'b0;
	#10 in1 = 1'b1;
	$display("Test buffer disable");
	#10 dis = 1'b1;
	#10 in1 = 1'b0;
	#10 in1 = 1'b1;
	$display("Test buffer re-enable");
	#10 dis = 1'b0;
	#10 in1 = 1'b0;
	#10 in1 = 1'b1;
	 
	
end
initial
begin
	#100 $stop;
end

endmodule
