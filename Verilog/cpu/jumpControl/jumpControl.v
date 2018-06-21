///
// jumpControl, a 16-bit jump control unit.
// Outputs a 1 if the processor should jump.
// Written by Andrew Enright, Fall 2017, for CPE142 at CSU Sacramento.
//
module jumpControl(opcode, zero, neg, result);
input [3:0] opcode;
input zero, neg;
output reg result;

always @ (*)
	begin
		case (opcode)
		//jump
		4'b0001: result = 1'b1;
		//beq
		4'b0110: if (zero) result = 1'b1;
			else result = 1'b0;
		//jge
		4'b0100: if (!zero && !neg) result = 1'b1;			
			else result = 1'b0;
		//jle
		4'b0101: if (neg) result = 1'b1;
			else result = 1'b0;
		default: result = 1'b0;
		endcase 			
	end
	

endmodule
