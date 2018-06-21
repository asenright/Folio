///
// leftShift1.v
// Shifts the input left 1 bit.
//
// Written by Andrew Enright for CPE142, CSU Sacramento, Fall 2017.
//

module leftShift1(data_in, data_out);
parameter size = 16;
input [size:1] data_in;
output reg [size:1] data_out;

always @ (*)
			data_out = data_in << 1;
endmodule
