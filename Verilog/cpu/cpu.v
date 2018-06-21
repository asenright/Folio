///
// cpu.v
//
// A pipelined 16-bit processor.
//
// Written by Andrew Enright, Fall 2017, for CPE142 at CSU Sacramento.
// Project by Andrew Enright and Ethan Kinyon.

`include "register/register_file.v"
`include "register/register.v"
`include "control/control.v"
`include "jumpControl/jumpControl.v"
`include "buffer/lockBuffer.v"
`include "mux/mux_2to1.v"
`include "mux/mux_4to1.v"
`include "forward/forward.v"
`include "adder/adder.v"
`include "Alu/alu.v"
`include "leftShift1/leftShift1.v"
`include "signExtend/signExtend.v"
`include "hazard/hazard.v"
`include "instruction memory/instructionmemory.v"
`include "data memory/datamemory.v"
`include "Counter/programcounter.v"

module cpu(clk, reset);
input clk, reset;


///////////////////////////////////////////////////////////////////////////////////////
//*******Wires and Regs for Hazard Handling********************************************
///////////////////////////////////////////////////////////////////////////////////////
reg[15:0] errors;

wire IF_ID_FLUSH, ID_EX_FLUSH, EX_M_FLUSH, M_WB_FLUSH; 
wire IF_ID_LOCK, ID_EX_LOCK, EX_M_LOCK, M_WB_LOCK;

reg[15:0] ERROR_SERVICE_ROUTINE_ADDRESS;

///////////////////////////////////////////////////////////////////////////////////////
//*******Other Wires*************************************************************
///////////////////////////////////////////////////////////////////////////////////////

//Wires originating in the Instruction Fetch region
wire[15:0] IF_PC_SRC_MUX_ADDR_OUT, IF_PC_ADDER_OUT, IF_ADDR, //if_pc_adder_out  
										//if_addr is the address of the instruction to be read
					 IF_INSTRUCTION; // pc address and inst buffer inputs
wire IF_ADDRESS_OVERFLOW,IF_PC_WRT;
reg USE_ERROR_ADDRESS;

//Wires originating in the instruction Decode region
wire[15:0] IF_ID_BUFFER_PC_ADDRESS_OUTPUT, ID_INSTRUCTION, //pc address and inst buffer inputs
		ID_SIGN_EXTEND,					    // sign extend output
		ID_READ_DATA_1, ID_READ_DATA_2, ID_READ_DATA_15;            // outputs to register file, inputs to buffer
wire ID_W2_ADDR_SRC, ID_W2_EN, ID_WRITEBACK, ID_MEMTOREG, ID_ALU_SRC, ID_ALU_OP, ID_MEM_READ, ID_MEM_WRITE, ID_BYTE_SELECT, ID_LOCK, CONTROL_ERROR, ID_ALU_OP2_SRC;

//Wires originating in the Execute region
wire[15:0] ID_EX_BUFFER_PC_ADDRESS_OUTPUT, ID_EX_BUFFER_INSTRUCTION_OUTPUT, 			// pc address and instruction buffer outputs
		ID_EX_BUFFER_DATA_1_OUTPUT, ID_EX_BUFFER_DATA_2_OUTPUT, ID_EX_BUFFER_DATA_15_OUTPUT, //data buffer outputs
		EX_ADDRESS_ADDER_OUTPUT, EX_RESULT, EX_REMAINDER,			// alu and address adder results
		EX_M_BUFFER_D1_INPUT, EX_M_BUFFER_D2_INPUT, EX_M_BUFFER_D15_INPUT, 		//inputs to buffer to mem
		EX_SIGN_EXTEND,     // comes out of the buffer which comes from sign extend in decode stage
		EX_MUX_RESULT_ALU_SRC,
		EX_INSTRUCTION,
		EX_ADDRESS, //this is the FINAL address coming out of the adder
		EX_ALU_INPUT_1, EX_ALU_INPUT_2, // result of hazard-detection multiplexer							
		EX_ADDER_IN_2, 
		EX_ALU_OP2_SRC_OUTPUT; //Connects the two OP2 multiplexers
wire EX_ALU_OP2_SRC, EX_ZERO, EX_NEGATIVE, EX_ALU_ERROR,			// alu and address adder results
	//commands buffered through ex
	EX_W2_ADDR_SRC, EX_W2_EN, EX_WRITEBACK, EX_MEMTOREG, EX_ALU_SRC, EX_ALU_OP, EX_MEM_READ, EX_MEM_WRITE, EX_BYTE_SELECT, EX_LOCK;
wire[1:0] DAT_1_HAZ, DAT_2_HAZ;

//Wires originating in the Memory region
//	commands buffered through M
wire M_PC_SRC, //this is the output to the Jump Control, which becomes PC_SRC
	M_ZERO, M_NEGATIVE, //carried from ALU result
	M_W2_ADDR_SRC, M_W2_EN, M_WRITEBACK, M_MEMTOREG, M_ALU_SRC, M_ALU_OP, M_MEM_READ, M_MEM_WRITE, M_BYTE_SELECT, M_LOCK;
wire[15:0] M_DATA_MEMORY_READ_OUTPUT, M_INSTRUCTION, M_ADDRESS,
		M_RESULT, M_REMAINDER, //m_address is the output of the ex-m address buffer
		M_REGISTER_DATA_1;
		
//Wires originating in the Writeback region
wire WB_W2_ADDR_SRC, WB_W2_EN, WB_WRITEBACK, WB_MEMTOREG, WB_BYTE_SELECT;
wire[3:0] //WB_WRITE_ADDR_1,  //used WB_INSTRUCTION[11:8]
		WB_WRITE_ADDR_2; 
wire[15:0] //WB_DATA_1,  //not used: instead WB_MUX_MEM_TO_REG_RESULT
		WB_DATA_2;
wire[15:0] WB_RESULT, WB_REMAINDER, WB_MUX_MEM_TO_REG_RESULT, WB_MUX_WA2_RESULT, WB_INSTRUCTION, WB_DATA_FROM_MEMORY;

///////////////////////////////////////////////////////////////////////////////////////
//*******Component Listing*************************************************************
///////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////
//Components in Instruction Fetch Region
///////////////////////////////////////////////////////////////////////////////////////
wire [15:0] IF_NEXT_ADDR;
mux_2to1 #(16) IF_MUX_PC_SRC (IF_PC_ADDER_OUT, M_ADDRESS, M_PC_SRC, IF_PC_SRC_MUX_ADDR_OUT);
mux_2to1 #(16) IF_MUX_ERR (IF_PC_SRC_MUX_ADDR_OUT, ERROR_SERVICE_ROUTINE_ADDRESS, USE_ERROR_ADDRESS, IF_NEXT_ADDR);
//register(data_in, clk, reset, w_enable, data_out);

//register #(16) PC (.data_in(IF_NEXT_ADDR), .clk(clk), .rst(reset), .w_enable(IF_PC_WRT), .data_out(IF_ADDR));
programcounter PC(.clk(clk), .rst(reset), .pWrite(IF_PC_WRT), .halt(1'b0), .temp_in(IF_NEXT_ADDR),  .out(IF_ADDR));
adder IF_ADDRESS_ADDER(16'h0002, IF_ADDR, IF_ADDRESS_OVERFLOW, IF_PC_ADDER_OUT);
//instructionMemoryDUMMY im(IF_ADDR, IF_INSTRUCTION);

instructionmemory im(.programcounter(IF_ADDR), .outRegister(IF_INSTRUCTION));

//IF/ID Buffers: data in, clock, disable, flush, data out
lockBuffer #(16) IF_ID_BUFFER_ADDRESS (IF_PC_ADDER_OUT, clk, IF_ID_LOCK, IF_ID_FLUSH, IF_ID_BUFFER_PC_ADDRESS_OUTPUT);
lockBuffer #(16) IF_ID_BUFFER_INSTRUCTION (IF_INSTRUCTION, clk, IF_ID_LOCK, IF_ID_FLUSH, ID_INSTRUCTION);

///////////////////////////////////////////////////////////////////////////////////////
//Components in Instruction Decode Region
///////////////////////////////////////////////////////////////////////////////////////

control control(.instruction(ID_INSTRUCTION), .w2_addr_src(ID_W2_ADDR_SRC), .w2_en(ID_W2_EN), 
		.write_back(ID_WRITEBACK), .mem_to_reg(ID_MEMTOREG), .alu_src(ID_ALU_SRC), .alu_op(ID_ALU_OP),
		.memory_read(ID_MEM_READ), .memory_write(ID_MEM_WRITE), .byte_select(ID_BYTE_SELECT), .err(CONTROL_ERROR), .lock(ID_LOCK), .alu_op2_src(ID_ALU_OP2_SRC));
register_file rf (.write_data_1(WB_MUX_MEM_TO_REG_RESULT), .write_data_2(WB_REMAINDER), .write_addr_1(WB_INSTRUCTION[11:8]), .write_addr_2(WB_WRITE_ADDR_2), 
			.read_addr_1(ID_INSTRUCTION[11:8]), .read_addr_2(ID_INSTRUCTION[7:4]), .clk(clk), .rst(reset),
			.write_enable_1(WB_WRITEBACK), .write_enable_2(WB_W2_EN), .first_byte_only(WB_BYTE_SELECT),
			.read_data_1(ID_READ_DATA_1), .read_data_2(ID_READ_DATA_2), .read_data_15(ID_READ_DATA_15));
signExtend se (ID_INSTRUCTION[7:0], ID_SIGN_EXTEND);


//ID/EX buffers
lockBuffer #(10) ID_EX_BUFFER_CONTROLS(
					{ID_ALU_OP2_SRC, ID_W2_ADDR_SRC, ID_W2_EN, ID_WRITEBACK, ID_MEMTOREG, ID_ALU_SRC, ID_ALU_OP,
						ID_MEM_READ, ID_MEM_WRITE, ID_BYTE_SELECT}, clk, ID_EX_LOCK, ID_EX_FLUSH,
					{EX_ALU_OP2_SRC, EX_W2_ADDR_SRC, EX_W2_EN, EX_WRITEBACK, EX_MEMTOREG, EX_ALU_SRC, EX_ALU_OP,
						EX_MEM_READ, EX_MEM_WRITE, EX_BYTE_SELECT});
lockBuffer #(16) ID_EX_BUFFER_INSTRUCTION(ID_INSTRUCTION, clk, ID_EX_LOCK, ID_EX_FLUSH, EX_INSTRUCTION);

lockBuffer #(16) ID_EX_BUFFER_DAT_1(ID_READ_DATA_1, clk, ID_EX_LOCK, ID_EX_FLUSH, ID_EX_BUFFER_DATA_1_OUTPUT);
lockBuffer #(16) ID_EX_BUFFER_DAT_2(ID_READ_DATA_2, clk, ID_EX_LOCK, ID_EX_FLUSH, ID_EX_BUFFER_DATA_2_OUTPUT);
lockBuffer #(16) ID_EX_BUFFER_DAT_15(ID_READ_DATA_15, clk, ID_EX_LOCK, ID_EX_FLUSH, ID_EX_BUFFER_DATA_15_OUTPUT);
lockBuffer #(16) ID_EX_BUFFER_SE(ID_SIGN_EXTEND, clk, ID_EX_LOCK, ID_EX_FLUSH, EX_SIGN_EXTEND);
lockBuffer #(16) ID_EX_BUFFER_ADDRESS(IF_ID_BUFFER_PC_ADDRESS_OUTPUT, clk, ID_EX_LOCK, ID_EX_FLUSH, ID_EX_BUFFER_PC_ADDRESS_OUTPUT);

///////////////////////////////////////////////////////////////////////////////////////
//Components in Execute region
///////////////////////////////////////////////////////////////////////////////////////
mux_2to1 #(16) EX_MUX_ALU_SRC(ID_EX_BUFFER_DATA_1_OUTPUT, EX_SIGN_EXTEND, EX_ALU_SRC, EX_MUX_RESULT_ALU_SRC);
mux_2to1 #(16) EX_MUX_ALU_SRC2(ID_EX_BUFFER_DATA_2_OUTPUT, ID_EX_BUFFER_DATA_15_OUTPUT, EX_ALU_OP2_SRC, EX_ALU_OP2_SRC_OUTPUT);

mux_4to1 #(16) EX_MUX_HAZ_1(EX_MUX_RESULT_ALU_SRC, M_RESULT, WB_RESULT, 16'h0000, DAT_1_HAZ, EX_ALU_INPUT_1);
mux_4to1 #(16) EX_MUX_HAZ_2(EX_ALU_OP2_SRC_OUTPUT, M_RESULT, WB_RESULT, 16'h0000, DAT_2_HAZ, EX_ALU_INPUT_2);

ALU alu(.aluOp(EX_ALU_OP), .opcode(EX_INSTRUCTION), .op1(EX_ALU_INPUT_1), .op2(EX_ALU_INPUT_2), 
		.out(EX_RESULT), .R15(EX_REMAINDER), .error(EX_ALU_ERROR), .zero(EX_ZERO), .neg(EX_NEGATIVE)); 
forward forward(.inst_ex(EX_INSTRUCTION), .inst_m(M_INSTRUCTION), .inst_wb(WB_INSTRUCTION), .haz1(DAT_1_HAZ), .haz2(DAT_2_HAZ));

leftShift1 ls1(.data_in(EX_SIGN_EXTEND), .data_out(EX_ADDER_IN_2));
adder #(16) address_adder(ID_EX_BUFFER_PC_ADDRESS_OUTPUT, EX_ADDER_IN_2, EX_ADDR_ADD_ERROR, EX_ADDRESS); // EX_ADDR_ADD_ERROR isn't used for anything (to support signed jumps), but is here just in case.

hazard hazard(.ex_instruction(EX_INSTRUCTION), .m_instruction(M_INSTRUCTION), .pc_write(IF_PC_WRT), .force_flush(USE_ERROR_ADDRESS), .jump_taken(M_PC_SRC), .reset(reset),
		.if_id_lock(IF_ID_LOCK), .id_ex_lock(ID_EX_LOCK), .ex_m_lock(EX_M_LOCK), .m_wb_lock(M_WB_LOCK), 
		.if_id_flush(IF_ID_FLUSH), .id_ex_flush(ID_EX_FLUSH), .ex_m_flush(EX_M_FLUSH), .m_wb_flush(M_WB_FLUSH));


//EX/M buffers
lockBuffer #(9) EX_M_BUFFER_CONTROLS({EX_W2_ADDR_SRC, EX_W2_EN, EX_WRITEBACK, EX_MEMTOREG, 
						EX_MEM_READ, EX_MEM_WRITE, EX_BYTE_SELECT,
						EX_ZERO, EX_NEGATIVE}, clk, EX_M_LOCK, EX_M_FLUSH, 
						{M_W2_ADDR_SRC, M_W2_EN, M_WRITEBACK, M_MEMTOREG,
						M_MEM_READ, M_MEM_WRITE, M_BYTE_SELECT,
						M_ZERO, M_NEGATIVE});
lockBuffer #(16) EX_M_BUFFER_INSTRUCTION(EX_INSTRUCTION, clk, EX_M_LOCK, EX_M_FLUSH, M_INSTRUCTION);
lockBuffer #(16) EX_M_BUFFER_RESULT(EX_RESULT, clk, EX_M_LOCK, EX_M_FLUSH, M_RESULT);
lockBuffer #(16) EX_M_BUFFER_REMAINDER(EX_REMAINDER, clk, EX_M_LOCK, EX_M_FLUSH, M_REMAINDER);
lockBuffer #(16) EX_M_BUFFER_DAT_1(ID_EX_BUFFER_DATA_1_OUTPUT, clk, EX_M_LOCK, EX_M_FLUSH, M_REGISTER_DATA_1);
lockBuffer #(16) EX_M_BUFFER_ADDR(EX_ADDRESS, clk, EX_M_LOCK, EX_M_FLUSH, M_ADDRESS);
///////////////////////////////////////////////////////////////////////////////////////
//Components in Memory region
///////////////////////////////////////////////////////////////////////////////////////


jumpControl jc (M_INSTRUCTION[15:12], M_ZERO, M_NEGATIVE, M_PC_SRC);
//data_memoryDUMMY dm (.read(M_MEM_READ), .write(M_MEM_WRITE), //Control signals- read and write enable
			//.addr(M_RESULT), .write_data(M_REGISTER_DATA_1), .data_out(M_DATA_MEMORY_READ_OUTPUT), .byte_select(M_BYTE_SELECT));
			
//(input clk, rst, rEnable, wEnable, input[15:0] address, wData, output reg[15:0] rData);
datamemory dm (.clk(clk), .rst(reset), .rEnable(M_MEM_READ), .wEnable(M_MEM_WRITE), .address(M_RESULT), .wData(M_REGISTER_DATA_1), .rData(M_DATA_MEMORY_READ_OUTPUT));
//M/WB Buffers
lockBuffer #(5) M_WB_BUFFER_CONTROLS({M_MEMTOREG, M_W2_ADDR_SRC, M_WRITEBACK, M_W2_EN, M_BYTE_SELECT}, 
											clk, M_WB_LOCK, M_WB_FLUSH, 
									{WB_MEMTOREG, WB_W2_ADDR_SRC, WB_WRITEBACK, WB_W2_EN, WB_BYTE_SELECT});
lockBuffer #(16) M_WB_BUFFER_INSTRUCTION(M_INSTRUCTION, clk, M_WB_LOCK, M_WB_FLUSH, WB_INSTRUCTION);
lockBuffer #(16) M_WB_BUFFER_DATA_FROM_MEMORY(M_DATA_MEMORY_READ_OUTPUT, clk, M_WB_LOCK, M_WB_FLUSH, WB_DATA_FROM_MEMORY);

lockBuffer #(16) M_WB_BUFFER_RESULT(M_RESULT, clk, M_WB_LOCK, M_WB_FLUSH, WB_RESULT);
lockBuffer #(16) M_WB_BUFFER_REMAINDER(M_REMAINDER, clk, M_WB_LOCK, M_WB_FLUSH, WB_REMAINDER);
//Components in Writeback
//Quick note: writeback address 1 is always the fireset operand in the instruction.
//				writeback address 2 is either the second operand, or it's hardcoded to 15 (if dividing or multiplying)
//				writeback data 1 is either from memory (if loading from data mem) or the result of the ALU.
//				writeback data 2 is always from the ALU Remainder.
mux_2to1 #(16) WB_MUX_MEM_TO_REG(WB_RESULT, WB_DATA_FROM_MEMORY, WB_MEMTOREG, WB_MUX_MEM_TO_REG_RESULT); //WB_MUX_MEM_TO_REG_RESULT is the data from data memory
mux_2to1 #(4) WB_MUX_W2_ADDR_SRC(WB_INSTRUCTION[7:4], 4'hF, WB_W2_ADDR_SRC, WB_WRITE_ADDR_2);

always @ (posedge clk or negedge reset)
begin
	if (~reset) 
		begin
		//IF_ID_LOCK, ID_EX_LOCK, EX_M_FLUSH handled by hazard unit
			ERROR_SERVICE_ROUTINE_ADDRESS <= 16'h0000;
			errors <= 16'h0000;
		end 
	else 
	begin
		//Accumulate errors in error register
		errors <= {{13'b0}, IF_ADDRESS_OVERFLOW, CONTROL_ERROR, EX_ALU_ERROR};
		//IF_PC_WRT <= 1'b1;
	 if (IF_ADDRESS_OVERFLOW || CONTROL_ERROR || EX_ALU_ERROR)
			 begin
				 //Error handling : use Error Interrupt Service Routine
				 //IF_ID_LOCK, ID_EX_LOCK, EX_M_FLUSH handled by hazard unit
				 ERROR_SERVICE_ROUTINE_ADDRESS <= 16'h0000;
				 USE_ERROR_ADDRESS <= 1'b1;
			 end
		 else 
			begin
				ERROR_SERVICE_ROUTINE_ADDRESS <= 16'h0000;
				USE_ERROR_ADDRESS <= 1'b0;
			end
	end
end
endmodule

module instructionMemoryDUMMY(input[15:0] addr, output reg[15:0] instr);
always@(*)
case (addr)
	16'h0000 : instr = 16'hF010; //add 0,1
	16'h0002 : instr = 16'hF540; //add 5, 4
	16'h0004 : instr = 16'hF054; // mult 0, 5
	16'h0006 : instr = 16'h10FE; //jump 0(-1)
	16'h0008 : instr = 16'hF010;
	16'h000A : instr = 16'hF540;
endcase

endmodule



module data_memoryDUMMY  (read, write, addr, write_data, data_out, byte_select);
	input [15:0] addr, write_data;
	input read, write, byte_select;
	output reg [15:0] data_out;
initial data_out = 16'h0000;
	
always@(*)
	begin
	if (read) data_out = 16'hFAFA;
	else data_out = 16'h0000;
	end
endmodule


