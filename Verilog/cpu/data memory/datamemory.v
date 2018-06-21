module datamemory(input clk, rst, rEnable, wEnable, input[15:0] address, wData, output reg[15:0] rData);

integer j;
reg[7:0] mem [10000:0];

always@(posedge clk or negedge rst)
begin
   if (wEnable == clk)
      begin
		 mem[address+1] <= wData[15:8];
         mem[address]   <= wData[7:0];
      end
   else if (!rst)
      begin
         for(j = 10; j < 10000; j = j + 1)
            begin
               mem[j] <= 8'h00;
            end
         mem[0] <= 8'h2b;
         mem[1] <= 8'hcd;
		 mem[2] <= 8'h00;
	     mem[3] <= 8'h00;
	     mem[4] <= 8'h12;
	     mem[5] <= 8'h34;
	     mem[6] <= 8'hde;
		 mem[7] <= 8'had;
	     mem[8] <= 8'hbe;
	     mem[9] <= 8'hef;
      end

end

always@(*)
begin
   rData  = 16'hxxxx;
   if (rEnable == 1'b1)
      begin
       rData = {mem[address], mem[address+1]};
      end
end
endmodule
