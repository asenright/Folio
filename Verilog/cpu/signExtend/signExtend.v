///
// signExtend.v
// Zero-pads an 8-bit input to a 16-bit output.
//
// Written by Andrew Enright for CPE142, CSU Sacramento, Fall 2017.
//

module signExtend(data_in, data_out);
input [8:1] data_in;
output reg [16:1] data_out;

always @ (*)
			data_out = {{8{data_in[8]}}, data_in};
endmodule
