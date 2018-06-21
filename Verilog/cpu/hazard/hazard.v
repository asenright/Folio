///
// hazard.v
// Hazard detection, signals a stall if detects a data-read dependency, signals a flush in case of jump.
// Can be forced to flush in response to errors.
//
// Written by Andrew Enright, Fall 2017, for CPE142 at CSU Sacramento.

module hazard (ex_instruction, m_instruction, pc_write, force_flush, jump_taken, reset,
		if_id_lock, id_ex_lock, ex_m_lock, m_wb_lock, 
		if_id_flush, id_ex_flush, ex_m_flush, m_wb_flush
		);
 input  [15 : 0] ex_instruction, m_instruction;
 input force_flush, jump_taken, reset;
 
 output reg pc_write;
 output reg if_id_lock, id_ex_lock, ex_m_lock, m_wb_lock;
 output reg if_id_flush, id_ex_flush, ex_m_flush, m_wb_flush;
 
 always @ (*)
 begin
	//if memory instruction is read, and it's reading into an address used by EX:
		//-lock IF-ID, ID-EX, for a cycle 
		//lock PC for a cycle
		//flush EX-M (to prevent double execution).
	if (~reset)
		begin
			pc_write = 1'b0;
		
			if_id_lock = 1'b1;
			id_ex_lock = 1'b1;
			ex_m_lock = 1'b1;
			m_wb_lock = 1'b1;

			if_id_flush = 1'b1;
			id_ex_flush = 1'b1;
			ex_m_flush = 1'b1;
			m_wb_flush = 1'b1;
		
		end
	else if (force_flush || (
		(m_instruction[15:12] == 4'b1100 || m_instruction[15:12] == 4'b1010) &&
		(m_instruction[11:8] == ex_instruction[11:8] || m_instruction[11:8] == ex_instruction[7:4])))
		begin
			//If a flush was forced we still need to write to PC
			//otherwise if we're just stalling for a read, PC doesn't get written
			if (force_flush) pc_write = 1'b1;
			else pc_write = 1'b0;
			
			if_id_lock = 1'b1;
			id_ex_lock = 1'b1;
			ex_m_lock = 1'b0;
			m_wb_lock = 1'b0;

			if_id_flush = 1'b0;
			id_ex_flush = 1'b0;
			ex_m_flush = 1'b1;
			m_wb_flush = 1'b0;
		end
		//if a jump is taken, if_id, id_ex need to be flushed. ex_m doesn't because there's already no writeback.
	else if (jump_taken)
		begin
			pc_write = 1'b1;
		
			if_id_lock = 1'b0;
			id_ex_lock = 1'b0;
			ex_m_lock = 1'b0;
			m_wb_lock = 1'b0;

			if_id_flush = 1'b1;
			id_ex_flush = 1'b1;
			ex_m_flush = 1'b0;
			m_wb_flush = 1'b0;
		
		end
		
	else begin
		//Normal operation. PC Writes, no locks, no flush.
		pc_write = 1'b1;
			if_id_lock = 1'b0;
			id_ex_lock = 1'b0;
			ex_m_lock = 1'b0;
			m_wb_lock = 1'b0;

			if_id_flush = 1'b0;
			id_ex_flush = 1'b0;
			ex_m_flush = 1'b0;
			m_wb_flush = 1'b0;
	end
end

endmodule
