`include "register_file.v"
module reg_fixture();

	reg clk, rst, first_byte_only, write_enable_1, write_enable_2;
	reg[15:0] write_data_1, write_data_2; 
	reg[3:0] write_addr_1, write_addr_2, read_addr_1, read_addr_2;
	wire[15:0] read_data_1, read_data_2, read_data_15;
//Monitor declarations
	initial
		begin
			$vcdpluson;
		
			$monitor("\n#", $time, "\nrst = %h | first_byte_only = %b\nwe1 = %h | wa1 = %h | wd1 = %h\nwe2 = %h | wa2 = %h\nwd2 = %h\nra1 = %h | rd1 = %h\nra2 = %h | rd2 = %h\nrd15 = %h", 
		rst, first_byte_only, 
		write_enable_1, write_addr_1, write_data_1, 
		
		write_enable_2, write_addr_2, write_data_2, 
		read_addr_1, read_data_1, 
		read_addr_2, read_data_2, 
		read_data_15); 
		end
//Component declaration. 
//Active high reset and write enable.
	register_file uut (
		.write_data_1(write_data_1),
		.write_data_2(write_data_2),
		.write_addr_1(write_addr_1),
		.write_addr_2(write_addr_2), 
		.read_addr_1(read_addr_1), 
		.read_addr_2(read_addr_2), 
		.clk(clk), 
		.rst(rst), 
		.first_byte_only(first_byte_only),
		.write_enable_1(write_enable_1),
		.write_enable_2(write_enable_2),
		.read_data_1(read_data_1),
		.read_data_2(read_data_2),
		.read_data_15(read_data_15));

	integer i;
//Timed output handler
	initial
	begin
		first_byte_only = 1'b0;
		rst <= 1'b1;
		#10 rst <= 1'b0;
		#10 rst <= 1'b1;
		#10
		write_enable_1 = 1'b0;
		write_data_1 = 16'h0000;
		write_addr_1 = 4'h0;
		read_addr_1 = 4'h0;
		
		write_enable_2 = 1'b0;
		write_data_2 = 16'h0000;
		write_addr_2 = 4'hF;
		read_addr_2 = 4'h0;
		
		$write("\n////////////////\nReset issued; cycle througha addresses reading to RD1:\n ");
		for (i = 0; i < 16; i=i+1)
			begin
				#10 
				read_addr_1 = i;
			end
		#200 $write("\n///////////////\nWrite FFFF to register D, read with RD2:\n");
		write_enable_1 = 1'b1;
		write_data_1 = 16'hFFFF;
		write_addr_1 = 4'hD;
		read_addr_1 = 4'h0;
		read_addr_2 = 4'hD;
		#10 $write("\n\nChange write data to AAAA, should change output next cycle"); 
		write_data_1 = 16'hAAAA;
		#10 $write("\n\nWrite AFAF to register F, should come out in RD15");
		write_addr_2 = 4'hF;
		write_enable_2 = 1'b1;
		write_data_2 = 16'hAFAF;	
		
		#10 $write("\n\nWrite first-byte-only to R9,  output of RA1 AND RA2 should be truncated");
		read_addr_1 = 4'h9;
		read_addr_2 = 4'h9;
		write_addr_1 = 4'h9;
		write_enable_1 = 1'b1;
		write_data_1 = 16'hAFAF;	
		first_byte_only = 1'b1;
	end	
//Finish handler
	initial
	begin
		#1000 $finish;
	end
//Clock handler
	initial
	begin
		clk <= 1'b0;
		forever #5 clk <= ~clk;
	end
endmodule
