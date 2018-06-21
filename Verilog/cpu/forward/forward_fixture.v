`include "forward.v"

module control_fixture();

reg[15:0] inst_ex, inst_m, inst_wb;
wire[1:0] haz1, haz2;

forward uut(.inst_ex(inst_ex), .inst_m(inst_m), .inst_wb(inst_wb), .haz1(haz1), .haz2(haz2));

initial begin
$vcdpluson;
$monitor("#",$time, ": inst_ex: %h | inst_m: %h | inst_wb: %h\nhaz1:%h | haz2:%h", inst_ex, inst_m, inst_wb, haz1, haz2);
end

initial
begin
	inst_ex = 16'h0000;
	inst_wb = 16'h0000;
	inst_m = 16'h0000;
end

initial 
begin
	$display("ex: nop | m: nop | wb: nop\nShouldn't forward anything");
	
	#10 $display("\n\nex: add $0, $1 | m: add $1, $0 | wb: add $7, $A\nShould orward memory to op2, which is dat1haz = 00 and dat2haz = 01");
	inst_ex = 16'hF010;
	inst_m = 16'hF100;
	inst_wb = 16'hF7A0;

	#10 $display("\n\nex: add $5, $7 | add $5, $9 | add $7, $A\nShould get op 1 from memory (dat1haz = 01)\nand op 2 from writeback (dat2haz = 10)");
	inst_ex = 16'hF570;
	inst_m = 16'hF590;
	inst_wb = 16'hF7A0;

	#10 $display("\n\nex: nop\nnop\nadd $0, $4\Shouldn't forward anything");
	inst_ex = 16'h0000;
	inst_m = 16'hF000;
	inst_wb = 16'hF040;


	
	
end
initial
begin
	#250 $finish;
end

endmodule
