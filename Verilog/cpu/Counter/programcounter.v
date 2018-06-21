module programcounter(input clk, rst, pWrite, halt, input[15:0] temp_in, output reg[15:0] out);
always@(posedge clk or negedge rst)
begin
   if (pWrite == 1'b1) out <= temp_in;
   else if (~rst) out  <= 16'h0000;
end
endmodule