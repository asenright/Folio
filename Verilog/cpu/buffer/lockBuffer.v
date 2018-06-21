///
// lockBuffer.v
// A scalable, lockable buffer: output will not change while input 'dis' is
// high.
// Wire 'dis' to 0 to cause this module to act like a normal buffer.
//
// Written by Andrew Enright for CPE142, CSU Sacramento, Fall 2017.
//

module lockBuffer(data_in, clk, dis, flush, data_out);
parameter size = 16;
input [size:1] data_in;
input clk, dis, flush;
output reg [size:1] data_out;

always @ (posedge clk)
begin
	if (flush) data_out <= {{size}{1'b0}};
	else if (~dis) data_out <= data_in;
	
	
end
endmodule
