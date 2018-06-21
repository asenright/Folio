//Dual-Write Tri-Read Register, by Andrew Enright
//This register has three read outputs (two addressable and one hardcoded to
//register 15).
//It also has two write inputs, both addressable.
//If first_byte_only is selected, only the the bottom half of the byte [7:0]
//will be written to register RA1. This doesn't currently affect the second
//write, just the first.
//
//Written as part of a design for CPE142, CSUS, Fall 2017.
module register_file
 (
	input wire [15:0]	 		write_data_1,
						write_data_2,
	input wire [3:0]			write_addr_1,
						write_addr_2, 
						read_addr_1, 
						read_addr_2, 
	input wire				clk, 
						rst, 
						write_enable_1,
						write_enable_2,
						first_byte_only,
	output reg [15:0]	 		read_data_1, 
						read_data_2,
						read_data_15);
	
//An n-1 bit, 2^^address lines size array of registers.
reg [15:0] registers [15:0];

integer i;

always @ (posedge clk, negedge rst)
begin
	if (~rst) 
		begin
		read_data_1 = 16'h0;
		read_data_2 = 16'h0;
		read_data_15 = 16'h0;
		for (i = 0; i < 16; i = i+1) 
			begin
				registers[i] = 16'h0;
			end	
		registers[0] = 16'h0F00;
		registers[1] = 16'h0050;
		registers[2] = 16'hFF0F;
		registers[3] = 16'hF0FF;
		registers[4] = 16'h0040;
		registers[5] = 16'h6666;
		registers[6] = 16'h00FF;
		registers[7] = 16'hFF88;
		registers[11] = 16'hCCCC;
		registers[12] = 16'h0002; 	
		end
	else if (write_enable_1) 
		begin
			if (~first_byte_only)
				registers[write_addr_1] = write_data_1;
			else
				registers[write_addr_1] = {8'h00, write_data_1[7:0]};

			if ((write_enable_2 == 1) && (write_addr_2 != write_addr_1))
				begin
					registers[write_addr_2] = write_data_2;
				end
		end
		
		if (~first_byte_only) read_data_1 = registers[read_addr_1];
		else read_data_1 = {8'h00, registers[read_addr_1][7:0]};
		read_data_1 = registers[read_addr_1];
		read_data_2 = registers[read_addr_2];
		read_data_15 = registers[15];	
end
endmodule
