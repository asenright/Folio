`include "control.v"

module control_fixture();
wire w2_addr_src, w2_en, wb, mem_to_reg, alu_src,  alu_op, mr, mw, bs, err, alu_op2_src;
reg [15:0] instruction;
// for reference: Module declaration
//module control(instruction, w2_addr_src, w2_en, write_back, mem_to_reg, alu_src, alu_op, memory_read, memory_write, byte_select, err);
//input [15:0] instruction;
//output reg w2_addr_src, w2_en, write_back, mem_to_reg, alu_src, alu_op, memory_read, memory_write, byte_select, err;
control uut (
		.instruction(instruction), 
		.w2_addr_src(w2_addr_src), 
		.w2_en(w2_en), 
		.write_back(write_back), 
		.mem_to_reg(mem_to_reg),
		.alu_src(alu_src), 
		.alu_op(alu_op),
		.memory_read(memory_read),
		.memory_write(memory_write),
		.byte_select(byte_select),
		.err(err),
		.alu_op2_src(alu_op2_src));

initial begin
$vcdpluson;
$monitor("#", $time, ": opcode = %h\nw2_addr_src = %h | w2_en = %h | wb = %h\nmtr = %h | alu_src = %h | alu_op=%h\nmr = %h | mw = %h | bs = %h | err=%h | alu_op2_src = %h", 
	instruction, w2_addr_src, w2_en, write_back, mem_to_reg, alu_src, alu_op, memory_read, memory_write, byte_select, err, alu_op2_src);
end

initial
begin
	instruction = 16'h0000;
end

initial 
begin
	#10 $display("\nSigned Add");
	instruction = 16'hF000;
	
	#10$display("\nSigned Subtract");
	instruction = 16'hF001;
	
	#10 $display("\nSigned Multiply");
	instruction = 16'hF004;
	
	#10 $display("\nSigned Divide");
	instruction = 16'hF005;

	#10 $display("\nMove");
	instruction = 16'hF007;

	#10 $display("\nSwap");
	instruction = 16'hF008;	
	
	#10 $display("\nAND immediate");
	instruction = 16'h8000;

	#10 $display("\nOR immediate");
	instruction = 16'h9000;
	
	#10 $display("\nLoad Byte Unsigned");
	instruction = 16'hA000;
	
	#10 $display("\nStore Byte");
	instruction = 16'hB000;
	
	#10 $display("\nLoad Word");
	instruction = 16'hC000;
	
	#10 $display("\nStore Word");
	instruction = 16'hD000;
	
	#10 $display("\nBranch if Less");
	instruction = 16'h5000;
	
	#10 $display("\nBranch if Greater");
	instruction = 16'h4000;
	
	#10 $display("\nBranch if Equal");
	instruction = 16'h6000;
	
	#10 $display("\nJump");
	instruction = 16'h1000;
	
	#10 $display("\nHalt");
	instruction = 16'h0000;
	
end
initial
begin
	#240 $finish;
end

endmodule
