`include "mux_4to1.v"

module mux_2to4_fixture();
parameter width = 16;
wire[15:0] out1;
reg[15:0] in1, in2, in3, in4;
reg[1:0] sel;
mux_4to1 #(16) uut (in1, in2, in3, in4, sel, out1);

initial begin
$vcdpluson;
$monitor($time, "\nin1 %h | in2 %h | in3 %h | in4 %h \nsel %b | out %h\n", in1, in2, in3, in4, sel, out1);
end

initial
begin
	in1 = 16'h1111;
	in2 = 16'h2222;
	in3 = 16'h3333;
	in4 = 16'h4444;
	sel = 2'b00;
end

initial 
begin
	#10 sel = 2'b00;
	#10 sel = 2'b01;
	#10 sel = 2'b10;
	#10 sel = 2'b11;	
	#10 $finish;
end

endmodule
