///
// mux_2to1.v
// A scalable-width multiplexer with two inputs and one output, and a 1-bit
// select line.
// By Andrew Enright
// Written for CPE142, CSU Sacramento, Fall 2017.

module mux_2to1(in1, in2, sel, out);
parameter size = 16;
input [size:1] in1, in2;
input sel;
output reg [size:1] out;

always @ (*)
	case (sel)
		0 : out = in1;
		1 : out = in2;
	endcase
endmodule
