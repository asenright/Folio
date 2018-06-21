`include "datamemory.v"

module datamemory_fixture;

reg clk, rst, rEnable, wEnable; 
reg[15:0]  address, wData; 
wire[15:0] rData;

datamemory dm1(.clk(clk), .rst(rst), .rEnable(rEnable), .wEnable(wEnable), .address(address), .wData(wData), .rData(rData));

initial
   $vcdpluson;

initial
begin
   $display("time\t clk\t rst\t rEnable\t wEnable\t address\t wData\t\t rData\t");
   $monitor("%4d\t %b\t %b\t %b\t\t %b\t\t %h\t\t %h\t\t %h\t\t", $time, clk, rst, rEnable, wEnable, address, wData, rData);
end

initial
begin
   clk = 1'b0;
   rst = 1'b0;

   #10
   rst  = 1'b1;
   rEnable = 1'b1;
   wEnable = 1'b0;
   address  = 16'h0000;

   #10
   rst  = 1'b1;
   rEnable  = 1'b1;
   wEnable = 1'b1;
   wData   = 16'haaaa;
   address  = 16'h0000;
   
   #10
   rst  = 1'b1;
   rEnable  = 1'b1;
   wEnable = 1'b0;
   address  = 16'h0002;
   
   #10
   rEnable  = 1'b1;
   wEnable = 1'b0;
   address  = 16'h0004;
   
   #10
   rEnable  = 1'b1;
   wEnable = 1'b0;
   address  = 16'h0006;
 
   #10
   rEnable  = 1'b1;
   wEnable = 1'b0;
   address  = 16'h0008;
   
   #10
   rEnable  = 1'b1;
   wEnable = 1'b1;
   address  = 16'h0000;
 
   #10
   rEnable = 1'b1;
   wEnable = 1'b1;
   wData = 16'h1111;
   address = 16'h1010;
	
end

initial
begin
   forever #10 clk = ~clk;
end

initial
begin
   #110 $finish;
end

endmodule