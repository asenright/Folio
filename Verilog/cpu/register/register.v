module register(data_in, clk, rst, w_enable, data_out);

parameter size = 16;
input [size-1:0] data_in;
input clk, rst, w_enable;
output reg [size-1:0] data_out;


initial data_out <= 0;

always @(posedge clk, negedge rst)
if (!rst)
	data_out <= 0;
else if (w_enable)
	data_out <= data_in;
	
endmodule
							
