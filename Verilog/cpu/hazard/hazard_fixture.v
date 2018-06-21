`include "hazard.v"

module hazard_fixture();
wire if_id_lock, id_ex_lock, ex_m_lock, m_wb_lock;
wire if_id_flush, id_ex_flush, ex_m_flush, m_wb_flush;
reg id_lock, ex_lock, m_lock, wb_lock;
reg force_flush, jump_taken, reset;
reg [15:0] in1, in2;

hazard uut(.ex_instruction(in1), .m_instruction(in2), .pc_write(pc_write), .force_flush(force_flush), .jump_taken(jump_taken), .reset(reset),
		
		.if_id_lock(if_id_lock), .id_ex_lock(id_ex_lock), .ex_m_lock(ex_m_lock), .m_wb_lock(m_wb_lock), 
		.if_id_flush(if_id_flush), .id_ex_flush(id_ex_flush), .ex_m_flush(ex_m_flush), .m_wb_flush(m_wb_flush));


initial begin
$vcdpluson;
$monitor("\n#", $time, " : in1 = %h | in2 = %h | pc_write : %b | force_flush = %b | jump_taken = %b\
\n if_id_lock : %b |  id_ex_lock : %b |  ex_m_lock : %b |  m_wb_lock : %b\
\n if_id_flush : %b |  id_ex_flush : %b |  ex_m_flush : %b |  m_wb_flush : %b", 
	in1, in2, pc_write, force_flush, jump_taken,
	if_id_lock, id_ex_lock, ex_m_lock, m_wb_lock,
	if_id_flush, id_ex_flush, ex_m_flush, m_wb_flush);
end

initial
begin
	in1 = 16'h0000;
	in2 = 16'h0000;
	jump_taken = 1'b0;
	force_flush = 1'b0;
	reset = 1'b1;
end

initial 
begin
	#10 $display("\n\nex_instruct : add 0, 5 | m_instruction : add 0, 5. Should not raise hazard");
		in1 = 16'hF050; //add 0, 5
		in2 = 16'hF050; //add 0, 5
		
	#10 $display("\n\nex_instruct : add 0, 5 | m_instruction : add 0, 5 | Force Flush : Should raise hazard with PC write enabled");
		force_flush = 1'b1;
	#10 force_flush = 1'b0;

	#10 $display("\n\nex_instruct : add 0, 5 | m_instruction : read 0,0 Should raise hazard with PC write disabled");
		in1 = 16'hF050; //add 0, 5 
		in2 = 16'hC000; // load 0, 0
		
	#10 $display("\n\nex_instruct : add 0, 5 | m_instruction : add 0, 5. Should not raise hazard");
		in1 = 16'hF050; //add 0, 5
		in2 = 16'hF050; //add 0, 5
		
	#10 $display("\n\nJump taken: Should raise hazard with PC write enabled");
		jump_taken = 1'b1;
	#10 jump_taken = 1'b0;
	#10 $display("\n\nReset: Flush all");
		reset = 1'b0;;
	
end
initial
begin
	#110 $finish;
end

endmodule
