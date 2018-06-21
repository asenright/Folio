///
// adder.v
// A combinatorial adder. Does not need a carry-in bit but has a carry-out.
//
// Written by Andrew Enright, Fall 2017, for CPE142 at CSU Sacramento.
//
// module adder(in1, in2, carry, out);
// parameter size = 16;
// input signed [size : 1] in1, in2;
// output reg signed [size : 1] out;
// output reg carry;

// always @ (*)
// begin
	// {carry, out} = $signed(in1) + $signed(in2);
// end

// endmodule
module adder(in1, in2, carry, out);
 parameter size = 16;
 input  [size : 1] in1, in2;
 output reg  [size : 1] out;
 output reg carry;

 always @ (*)
 begin
	 {carry, out} = in1 + in2;
end

endmodule
