`include "alu.v"

module alu_fixture;

reg[3:0]         functCode;
reg signed[15:0] op1, op2;
wire[15:0]       out, R15;
wire err, neg, zero;
reg alu_op;

ALU alu(.functionCode(functCode), 
        .op1(op1), .op2(op2),
        .out(out), .R15(R15), .aluOp(alu_op));

initial
   $vcdpluson;

initial
begin
   $display("time\t funct\t op1\t op2\t out\t R15\t");
   $monitor("%4d\t %b\t %h\t %h\t %h\t %h\t", $time, functCode, op1, op2, out, R15,err,neg,zero);
end

initial
begin
   alu_op = 1'b1;
   functCode = 4'b0000;
   op1       = 16'h0100;
   op2       = 16'h0001;

   #20
   functCode = 4'b0001;
   op1       = 16'h0100;
   op2       = 16'h0010;

   #20
   functCode = 4'b0100;
   op1       = 16'h0100;
   op2       = 16'h0010;

   #20
   functCode = 4'b0101;
   op1       = 16'h0100;
   op2       = 16'h0010;


end

endmodule