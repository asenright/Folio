`include "lockBuffer.v"

module buffer_fixture();
wire[15:0] out1;
reg[15:0] in1;
reg clk, dis, flush;
lockBuffer #(16) uut (in1, clk, dis, flush, out1);

initial begin
$vcdpluson;
$monitor($time, " in1 = %h|out1 = %h|clk = %h|flush = %h|dis = %h", out1, in1, clk, flush, dis);
end

initial
begin
	in1 = 16'b0;
	clk = 1'b0;
	dis = 1'b0;
	flush = 1'b0;
end

always
begin
	#5 clk = ~clk;
end


initial 
begin
	#10 in1 = 16'hAFAF;
	#10 in1 = 16'hFAFA;
	#10 dis = 1'b1;	
		in1 = 16'h FFFF;
	#10 in1 = 16'h5555;
	#10 flush = 1'b1;
	#10 dis = 1'b0;
	
end
initial
begin
	#100 $finish;
end

endmodule
