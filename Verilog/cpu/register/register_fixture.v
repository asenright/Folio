`include "register.v"
module reg_fixture();

reg clk, rst, clear, write;
reg[7:0] data_in;
wire[7:0] data_out;

initial
	$vcdpluson;
	
initial
$monitor("#",$time, ": data_in = %h | data_out = %h | write_enable = %b | clear = %b", data_in, data_out, write, clear);

register #(.N(8)) reg1 (.clk(clk), .rst(clear), .data_out(data_out), .data_in(data_in), .w_enable(write));

initial
begin
	clear = 1'b1;
	#90 clear = 1'b0;
	#10 clear = 1'b1;
end

initial
begin
	write = 1'b1;
	data_in = 8'h55;
	#20  write = 1'b0;
	#100 write = 1'b1;
	data_in = 8'hAA;
end

initial
begin
	#200 $finish;
end

initial
begin
	clk = 1'b0;
	forever #5 clk = ~clk;
end

endmodule
