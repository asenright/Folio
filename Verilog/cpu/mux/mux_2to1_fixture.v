`include "mux_2to1.v"

module mux_2to4_fixture();
parameter width = 16;
wire[15:0] out1;
reg[15:0] in1, in2;
reg sel;
mux_2to1 #(16) uut (in1, in2, sel, out1);

initial begin
$vcdpluson;
$monitor($time, "\nin1 %h | in2 %h\nsel %b | out %h\n", in1, in2, sel, out1);
end

initial
begin
	in1 = 16'h0000;
	in2 = 16'hFFFF;
	sel = 1'b0;
end

initial 
begin
	#10 sel = 1'b1;
	#10 in2 = 16'h5555; 
	#10 sel = 1'b0;	
	#10 $finish;
end

endmodule
