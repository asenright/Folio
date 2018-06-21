///
// mux_4to1.v
// A scalable-width multiplexer with four inputs and one output, and a 2-bit
// select line.
// By Andrew Enright
// Written for CPE142, CSU Sacramento, Fall 2017.

module mux_4to1(in1, in2, in3, in4, sel, out);
parameter size = 16;
input [size:1] in1, in2, in3, in4;
input [1:0] sel;
output reg [size:1] out;

always @ (*)
	case (sel)
		2'b00 : out = in1;
		2'b01 : out = in2;
		2'b10 : out = in3;
		2'b11 : out = in4;
	endcase
endmodule
