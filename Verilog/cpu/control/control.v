///
// control.v
// A datapath controller for a 16-bit datapath.
// Written by Andrew Enright, Fall 2017, for CPE142 at CSU Sacramento.
//
module control(instruction, w2_addr_src, w2_en, write_back, mem_to_reg, alu_src, alu_op, memory_read, memory_write, byte_select, err, lock, alu_op2_src);
input [15:0] instruction;
output reg w2_addr_src, w2_en, write_back, mem_to_reg, alu_src, alu_op, memory_read, memory_write, byte_select, err, lock, alu_op2_src;

always @ (*)
	begin
	//Lock (freeze buffers)
	if (instruction[15:12] == 0000) lock = 1'b1;
	else begin
		casez (instruction[15:12])
		//ALU operation		
		4'b1111: begin
			alu_op2_src = 1'b0;
			write_back = 1'b1;
			mem_to_reg = 1'b0;
			alu_src = 1'b0;
			alu_op = 1'b1;
			memory_read = 1'b0;
			memory_write = 1'b0;
			byte_select = 1'b0;
			err = 1'b0;
			casez (instruction[3:0])
				//add (0000)
				//subtract (0001)
				4'b0000 : begin
					w2_addr_src = 1'b0;
					w2_en = 1'b0;
				end
				4'b0001 : begin
					w2_addr_src = 1'b0;
					w2_en = 1'b0;
				end
				//multiply (0100)
				//divide (0101)
				4'b010? : begin
					w2_addr_src = 1'b1;
					w2_en = 1'b1;
				end
				//move (0111)
				4'b0111 : begin
					w2_addr_src = 1'b0;
					w2_en = 1'b0;
					end
				//swap (1000)
				4'b1000 : begin
					w2_addr_src = 1'b1;
					w2_en = 1'b1;
					end
				default: begin
					w2_addr_src = 1'b0;
					w2_en = 1'b0;
				end
				endcase
		end 	
		//AND Immediate
		//OR Immediate
		4'b100? : begin
			alu_op2_src = 1'b0;
			w2_addr_src = 1'b0;
			w2_en = 1'b0;
			write_back = 1'b1;
			mem_to_reg = 1'b0;
			alu_src = 1'b1;
			alu_op = 1'b1;
			memory_read = 1'b0;
			memory_write = 1'b0;
			byte_select = 1'b0;
			err = 1'b0;
		end
		//Load byte
		4'b1010: begin
			alu_op2_src = 1'b0;
			w2_addr_src = 1'b0;
			w2_en = 1'b0;
			write_back = 1'b0;
			mem_to_reg = 1'b1;
			alu_src = 1'b1;
			alu_op = 1'b1;
			memory_read = 1'b1;
			memory_write = 1'b0;
			byte_select = 1'b1;
			err = 1'b0;
		end
		//Store byte
		4'b1011: begin
			alu_op2_src = 1'b0;
			err = 1'b0;
			w2_addr_src = 1'b0;
			w2_en = 1'b0;
			write_back = 1'b1;
			mem_to_reg = 1'b0;
			alu_src = 1'b1;
			alu_op = 1'b1;
			memory_read = 1'b0;
			memory_write = 1'b1;
			byte_select = 1'b1;
		end
		//Load
		4'b1100 : begin
			alu_op2_src = 1'b0;
			err = 1'b0;
			w2_addr_src = 1'b0;
			w2_en = 1'b0;
			write_back = 1'b1;
			mem_to_reg = 1'b1;
			alu_src = 1'b1;
			alu_op = 1'b1;
			memory_read = 1'b1;
			memory_write = 1'b0;
			byte_select = 1'b0;
		end
		//Store
		4'b1101 : begin
			alu_op2_src = 1'b0;
			err = 1'b0;
			w2_addr_src = 1'b0;
			w2_en = 1'b0;
			write_back = 1'b1;
			mem_to_reg = 1'b0;
			alu_src = 1'b1;
			alu_op = 1'b1;
			memory_read = 1'b0;
			memory_write = 1'b1;
			byte_select = 1'b0;
		end

		//Branch on less
		//Branch on greater
		4'b010? : begin
			alu_op2_src = 1'b1;
			err = 1'b0;
			w2_addr_src = 1'b0;
			w2_en = 1'b0;
			write_back = 1'b0;
			mem_to_reg = 1'b0;
			alu_src = 1'b0;
			alu_op = 1'b1;
			memory_read = 1'b0;
			memory_write = 1'b0;
			byte_select = 1'b0;
		end
		//Branch on Equal
		4'b0110 : begin
			alu_op2_src = 1'b1;
			err = 1'b0;
			w2_addr_src = 1'b0;
			w2_en = 1'b0;
			write_back = 1'b0;
			mem_to_reg = 1'b0;
			alu_src = 1'b0;
			alu_op = 1'b1;
			memory_read = 1'b0;
			memory_write = 1'b0;
			byte_select = 1'b0;
		end
		//Jump (jump signal handled via jump control)
		//Jump actually has its own adder and shift for calculating address
		4'b0001 : begin
			alu_op2_src = 1'b0;
			err = 1'b0;
			w2_addr_src = 1'b0;
			w2_en = 1'b0;
			write_back = 1'b0;
			mem_to_reg = 1'b0;
			alu_src = 1'b0;
			alu_op = 1'b0;
			memory_read = 1'b0;
			memory_write = 1'b0;
			byte_select = 1'b0;
		end

		//Halt
		4'b0000 : begin
			alu_op2_src = 1'b0;
			err = 1'b0;
			w2_addr_src = 1'b0;
			w2_en = 1'b0;
			write_back = 1'b0;
			mem_to_reg = 1'b0;
			alu_src = 1'b0;
			alu_op = 1'b0;
			memory_read = 1'b0;
			memory_write = 1'b0;
			byte_select = 1'b0;
		end
		
		//Unrecognized
		default : begin
			alu_op2_src = 1'b0;
			err = 1'b1;
			w2_addr_src = 1'b0;
			w2_en = 1'b0;
			write_back = 1'b0;
			mem_to_reg = 1'b0;
			alu_src = 1'b0;
			alu_op = 1'b0;
			memory_read = 1'b0;
			memory_write = 1'b0;
			byte_select = 1'b0;
		end
		endcase 			
	end	
	end
	
endmodule
