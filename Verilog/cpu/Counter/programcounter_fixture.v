`include "programcounter.v"

module programcounter_fixture;

reg        clk, rst, pWrite;
reg[15:0]  temp_in; 
wire[15:0] out;

programcounter pc1(.clk(clk), .rst(rst), .pWrite(pWrite), .temp_in(temp_in), .out(out));

initial
   $vcdpluson;

initial
begin
   $display("time\t clk\t rst\t pWrite\t temp_in\t out\t");
   $monitor("%4d\t %b\t %b\t %b\t %h\t\t %h\t", $time, clk, rst, pWrite, temp_in, out);
end

initial
begin
   clk     = 1'b0;
   rst     = 1'b0;
   pWrite   = 1'b0;

   #5
   rst     = 1'b1;
   pWrite   = 1'b1;
   temp_in   = 16'h0000;

   #15
   pWrite   = 1'b1;
   temp_in  = 16'h0001;
  
   #15
   pWrite   = 1'b0;
   temp_in  = 16'h0002;

   #15
   pWrite   = 1'b1;
   temp_in  = 16'h0003;
end

initial
begin
   forever #10 clk = ~clk;
end

initial
begin
   #100 $finish;
end

endmodule

