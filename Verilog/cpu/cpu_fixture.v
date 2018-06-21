//cpu_fixture.v
//A fixture for the associated cpu file. 
//	This fixture monitors status of modules within CPU, and runs the clk and reset signals.
//
//Written by Andrew Enright.
//Project by Andrew Enright and Ethan Kinyon.
`include "cpu.v"

module cpu_fixture();
reg rst, clk;
cpu proc(clk, rst);

initial begin
$vcdpluson;
$monitor("#", $time, " : rst %b | err register : %b |\
\n\n///////Instructions////////\
\nIF Address: %h\nIF  : %h | ID : %h | EX : %h | M : %h | WB : %h\
\n////////Register File//////////\n0 : %h | 1  : %h | 2  : %h | 3 : %h\n4 : %h | 5  : %h | 6  : %h | 7 : %h\n8 : %h | 9  : %h | A  : %h | B : %h\nC : %h | D  : %h | E  : %h | F : %h\n\
\n////////ALU//////////\n opcode: %h | in1: %h | in2 : %h | result : %h | remainder : %h | zero : %b | neg : %b\
\n/////////Writeback////////////\nWB1: En : %b | Wd : %h | Wa : %h\nWB2: En : %b | Wd : %h | Wa : %h\
\n/////////////Buffers//////////////////////////////////////////\
\n\n/////IF/ID/////\
\nAddress: 		In : %h | Out : %h | Lock : %b | Flush : %b\
\nInstruction: 		In : %h | Out : %h | Lock : %b | Flush : %b\
\n\n/////ID/EX////////\
\nControls: 		In : %b | Out : %b | Lock : %b | Flush : %b\
\nInstruction: 		In : %h | Out : %h | Lock : %b | Flush : %b\
\nDat1: 			In : %h | Out : %h | Lock : %b | Flush : %b \
\nDat2: 			In : %h | Out : %h | Lock : %b | Flush : %b \
\nDat15: 			In : %h | Out : %h | Lock : %b | Flush : %b\
\nSE: 			In : %h | Out : %h | Lock : %b | Flush : %b \
\nAddress: 		In : %h | Out : %h | Lock : %b | Flush : %b \
\n\n/////EX/M///////\
\nControls: 		In : %b | Out : %b | Lock : %b | Flush : %b\
\nInstruction: 		In : %h | Out : %h | Lock : %b | Flush : %b\
\nResult: 		In : %h | Out : %h | Lock : %b | Flush : %b \
\nRemainder: 		In : %h | Out : %h | Lock : %b | Flush : %b \
\nDat1: 			In : %h | Out : %h | Lock : %b | Flush : %b\
\nAddress: 		In : %h | Out : %h | Lock : %b | Flush : %b\
\n\n/////M/WB///////\
\nControls: 		In : %b | Out : %b | Lock : %b | Flush : %b\
\nInstruction: 		In : %h | Out : %h | Lock : %b | Flush : %b\
\nResult: 		In : %h | Out : %h | Lock : %b | Flush : %b \
\nRemainder: 		In : %h | Out : %h | Lock : %b | Flush : %b\
\nDat1: 			In : %h | Out : %h | Lock : %b | Flush : %b \
\n\
\n////////////Multiplexers///////////\
\n////////////IF//////////////\
\nPC SRC: 		In1 : %h | In2 : %h | Sel : %b | Out: %h\
\nERR:  			In1 : %h | In2 : %h | Sel : %b | Out: %h\
\n////////////EX///////////////\
\nALU SRC: 		In1 : %h | In2 : %h | Sel : %b | Out: %h\
\nALU SRC2: 		In1 : %h | In2 : %h | Sel : %b | Out: %h\
\nHAZ1 			In1 : %h | In2 : %h | In3: %h | Sel : %b | Out: %h\
\nHAZ2: 			In1 : %h | In2 : %h | In3: %h | Sel : %b | Out: %h\
\n////////////WB///////////////\
\nMem to Reg:  		In1 : %h | In2 : %h | Sel : %b | Out: %h\
\nW2 Addr Src: 		In1 : %h | In2 : %h | Sel : %b | Out: %h\
\n\n\n\n\n", 
		proc.rf.rst, proc.errors [3:0], proc.IF_ADDR,
		proc.IF_INSTRUCTION, proc.ID_INSTRUCTION, proc.EX_INSTRUCTION, proc.M_INSTRUCTION, proc.WB_INSTRUCTION,
		proc.rf.registers[0], proc.rf.registers[1], proc.rf.registers[2], proc.rf.registers[3], 
		proc.rf.registers[4], proc.rf.registers[5], proc.rf.registers[6], proc.rf.registers[7], 
		proc.rf.registers[8], proc.rf.registers[9], proc.rf.registers[10], proc.rf.registers[11], 
		proc.rf.registers[12], proc.rf.registers[13], proc.rf.registers[14], proc.rf.registers[15],
		proc.alu.opcode, proc.alu.op1, proc.alu.op2, proc.alu.out, proc.alu.R15, proc.alu.zero, proc.alu.neg,
		proc.rf.write_enable_1,  proc.rf.write_addr_1, proc.rf.write_data_1,
		proc.rf.write_enable_2,  proc.rf.write_addr_2, proc.rf.write_data_2,
		proc.IF_ID_BUFFER_ADDRESS.data_in, proc.IF_ID_BUFFER_ADDRESS.data_out, proc.IF_ID_BUFFER_ADDRESS.dis, proc.IF_ID_BUFFER_ADDRESS.flush,
		proc.IF_ID_BUFFER_INSTRUCTION.data_in, proc.IF_ID_BUFFER_INSTRUCTION.data_out, proc.IF_ID_BUFFER_INSTRUCTION.dis, proc.IF_ID_BUFFER_INSTRUCTION.flush,
		
		proc.ID_EX_BUFFER_CONTROLS.data_in, proc.ID_EX_BUFFER_CONTROLS.data_out, proc.ID_EX_BUFFER_CONTROLS.dis, proc.ID_EX_BUFFER_CONTROLS.flush,
		proc.ID_EX_BUFFER_INSTRUCTION.data_in, proc.ID_EX_BUFFER_INSTRUCTION.data_out, proc.ID_EX_BUFFER_INSTRUCTION.dis, proc.ID_EX_BUFFER_INSTRUCTION.flush,
		proc.ID_EX_BUFFER_DAT_1.data_in, proc.ID_EX_BUFFER_DAT_1.data_out, proc.ID_EX_BUFFER_DAT_1.dis, proc.ID_EX_BUFFER_DAT_1.flush,
		proc.ID_EX_BUFFER_DAT_2.data_in, proc.ID_EX_BUFFER_DAT_2.data_out, proc.ID_EX_BUFFER_DAT_2.dis, proc.ID_EX_BUFFER_DAT_2.flush,
		proc.ID_EX_BUFFER_DAT_15.data_in, proc.ID_EX_BUFFER_DAT_15.data_out, proc.ID_EX_BUFFER_DAT_15.dis, proc.ID_EX_BUFFER_DAT_15.flush,
		proc.ID_EX_BUFFER_SE.data_in, proc.ID_EX_BUFFER_SE.data_out, proc.ID_EX_BUFFER_SE.dis, proc.ID_EX_BUFFER_SE.flush,
		proc.ID_EX_BUFFER_ADDRESS.data_in, proc.ID_EX_BUFFER_ADDRESS.data_out, proc.ID_EX_BUFFER_ADDRESS.dis, proc.ID_EX_BUFFER_ADDRESS.flush,
		
		proc.EX_M_BUFFER_CONTROLS.data_in, proc.EX_M_BUFFER_CONTROLS.data_out, proc.EX_M_BUFFER_CONTROLS.dis, proc.EX_M_BUFFER_CONTROLS.flush,
		proc.EX_M_BUFFER_INSTRUCTION.data_in, proc.EX_M_BUFFER_INSTRUCTION.data_out, proc.EX_M_BUFFER_INSTRUCTION.dis, proc.EX_M_BUFFER_INSTRUCTION.flush,
		proc.EX_M_BUFFER_RESULT.data_in, proc.EX_M_BUFFER_RESULT.data_out, proc.EX_M_BUFFER_RESULT.dis, proc.EX_M_BUFFER_RESULT.flush,
		proc.EX_M_BUFFER_REMAINDER.data_in, proc.EX_M_BUFFER_REMAINDER.data_out, proc.EX_M_BUFFER_REMAINDER.dis, proc.EX_M_BUFFER_REMAINDER.flush,
		proc.EX_M_BUFFER_DAT_1.data_in, proc.EX_M_BUFFER_DAT_1.data_out, proc.EX_M_BUFFER_DAT_1.dis, proc.EX_M_BUFFER_DAT_1.flush,
		proc.EX_M_BUFFER_ADDR.data_in, proc.EX_M_BUFFER_ADDR.data_out, proc.EX_M_BUFFER_ADDR.dis, proc.EX_M_BUFFER_ADDR.flush,
		
		proc.M_WB_BUFFER_CONTROLS.data_in, proc.M_WB_BUFFER_CONTROLS.data_out, proc.M_WB_BUFFER_CONTROLS.dis, proc.M_WB_BUFFER_CONTROLS.flush,
		proc.M_WB_BUFFER_INSTRUCTION.data_in, proc.M_WB_BUFFER_INSTRUCTION.data_out, proc.M_WB_BUFFER_INSTRUCTION.dis, proc.M_WB_BUFFER_INSTRUCTION.flush,
		proc.M_WB_BUFFER_DATA_FROM_MEMORY.data_in, proc.M_WB_BUFFER_DATA_FROM_MEMORY.data_out, proc.M_WB_BUFFER_DATA_FROM_MEMORY.dis, proc.M_WB_BUFFER_DATA_FROM_MEMORY.flush,
		proc.M_WB_BUFFER_RESULT.data_in, proc.M_WB_BUFFER_RESULT.data_out, proc.M_WB_BUFFER_RESULT.dis, proc.M_WB_BUFFER_RESULT.flush,
		proc.M_WB_BUFFER_REMAINDER.data_in, proc.M_WB_BUFFER_REMAINDER.data_out, proc.M_WB_BUFFER_REMAINDER.dis, proc.M_WB_BUFFER_REMAINDER.flush,
		
		proc.IF_MUX_PC_SRC.in1, proc.IF_MUX_PC_SRC.in2, proc.IF_MUX_PC_SRC.sel, proc.IF_MUX_PC_SRC.out,   
		proc.IF_MUX_ERR.in1, proc.IF_MUX_ERR.in2, proc.IF_MUX_ERR.sel, proc.IF_MUX_ERR.out,
		
		proc.EX_MUX_ALU_SRC.in1, proc.EX_MUX_ALU_SRC.in2, proc.EX_MUX_ALU_SRC.sel, proc.EX_MUX_ALU_SRC.out,
		proc.EX_MUX_ALU_SRC2.in1, proc.EX_MUX_ALU_SRC2.in2, proc.EX_MUX_ALU_SRC2.sel, proc.EX_MUX_ALU_SRC2.out,
		proc.EX_MUX_HAZ_1.in1, proc.EX_MUX_HAZ_1.in2, proc.EX_MUX_HAZ_1.in3,proc.EX_MUX_HAZ_1.sel, proc.EX_MUX_HAZ_1.out,
		proc.EX_MUX_HAZ_2.in1, proc.EX_MUX_HAZ_2.in2, proc.EX_MUX_HAZ_2.in3,proc.EX_MUX_HAZ_2.sel, proc.EX_MUX_HAZ_2.out,

		proc.WB_MUX_MEM_TO_REG.in1, proc.WB_MUX_MEM_TO_REG.in2, proc.WB_MUX_MEM_TO_REG.sel, proc.WB_MUX_MEM_TO_REG.out,
		proc.WB_MUX_W2_ADDR_SRC.in1, proc.WB_MUX_W2_ADDR_SRC.in2, proc.WB_MUX_W2_ADDR_SRC.sel, proc.WB_MUX_W2_ADDR_SRC.out
		);

end

initial
begin
	clk <= 1'b0;
	rst <= 1'b1;
end

initial 
begin
	#10 rst <= 1'b0;
	#10 rst <= 1'b1;	
end

always 
begin
	#5 clk = ~clk;
end

initial
begin
	#1000 if  (proc.errors[0]) $write("ALU ERROR\n\n");
	if (proc.errors [1]) $write("CONTROL ERROR (UNRECOGNIZED COMMAND?)\n\n");
	if (proc.errors [2]) $write("INSTRUCTION ADDRESS OVERFLOW\n\n");
 
	
	$finish;
end

endmodule
