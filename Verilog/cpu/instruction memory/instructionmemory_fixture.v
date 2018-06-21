`include "instructionmemory.v"

module instructionmemory_fixture;

reg clk, rst;
reg[15:0]  pc;
wire[15:0] outreg;

instructionmemory im1(.clk(clk), .rst(rst), .programcounter(pc), .outRegister(outreg));

initial
   $vcdpluson;

initial
begin
   $display("time\t clk\t rst\t pc\t outRegister\t");
   $monitor("%4d\t %b\t %b\t %h\t %h\t", $time, clk, rst, pc, outreg);
end

initial
begin
   clk     = 1'b0;
   rst     = 1'b0;

   #10
   rst = 1'b1;
   pc = 16'h0002;

   #20
   pc = 16'h0004;
  
   #30
   pc = 16'h0006;
end

initial
begin
   forever #10 clk = ~clk;
end

initial
begin
   #120 $finish;
end

endmodule

