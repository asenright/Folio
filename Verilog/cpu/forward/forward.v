///
// forward.v
// A forwarding unit for handling data hazards. This just sets the control
// signal on a mux for the ALU, it doesn't handle the actual forwarded data.
// 
// Syntax varies from commands type A,B,C, and D
// A and B are handled the same here
//
// C ignores operand 2
//
// D isn't handled at all
//
// Syntax:
// instruction [15:12] : opcode
// instruction [11:8] : operand 1
// instruction [7:4] : operand 2
// instruction [3:0] : other (alu op or immediate)
//
// Written by Andrew Enright, Fall 2017, for CPE142 at CSU Sacramento.
//
module forward(inst_ex, inst_m, inst_wb, haz1, haz2);
input [15:0] inst_ex, inst_m, inst_wb;
output reg [1:0] haz1, haz2;

always @ (*)
	begin
	//Type A: ALU op (1111)
	//Type B: load and store byte (101x)
	//	  load and store (110x)
	//
	if (inst_ex[15:12] == 4'b1111 ||
		inst_ex[15:13] == 3'b101 ||
		inst_ex[15:13] == 3'b110)
		begin
			//haz2 handles hazards for operand 2

			case(inst_ex[7:4])
				inst_m[11:8] : haz2 = 2'b01;
				inst_wb[11:8] : haz2 = 2'b10; 
				default: haz2 = 2'b00;
			endcase
		end
	else haz2 = 2'b00;
	
		//Type c: 	AND imm, OR imm (100x)
		//		ble, bge (010x)
		//		be (0110)
	if (inst_ex[15:13] == 3'b100 || 
		inst_ex[15:13] == 3'b010 ||
		inst_ex[15:12] == 4'b0110 ||
		inst_ex[15:12] == 4'b1111 || //this "if" covers all 
		inst_ex[15:13] == 3'b101 || //use cases for haz1
		inst_ex[15:13] == 3'b110)
		begin
			//haz1 handles hazards for operand 1
			case(inst_ex[11:8])
				inst_m[11:8] : haz1 = 2'b01;
				inst_wb[11:8] : haz1 = 2'b10; 
				default: haz1 = 2'b00;
			endcase
		end
	//Type d/unrecognized
		else haz1 = 2'b00;	
	end	
		
endmodule
