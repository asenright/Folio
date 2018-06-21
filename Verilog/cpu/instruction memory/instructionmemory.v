module instructionmemory(input[15:0] programcounter, output reg[15:0] outRegister);

always@(*)
begin 
		 case (programcounter) 
			 00 : outRegister = 16'hf120; //Signed Addition		 
			 02 : outRegister= 16'hf121; //Signed Subtraction		
			 04 : outRegister= 16'h93ff; //Bitwise Or			
			 06 : outRegister= 16'h834c; //Bitwise And			
			 08 : outRegister= 16'hf564; //Signed Multiplication	
			 10 : outRegister= 16'hf155; //Signed Division		
			 12 : outRegister= 16'hfff1; //Signed Subtraction		
			 14 : outRegister= 16'hf487; //Move			
			 16 : outRegister= 16'hf468; //Swap			
			 18 : outRegister= 16'h9402; //Bitwise Or			
			 20 : outRegister= 16'ha690; //Load Byte Unsigned		
			 22 : outRegister= 16'hb690; //Store Byte			
			 24 : outRegister= 16'hc690; //Load Word			
			 26 : outRegister= 16'h6704; //Branch On Equal	    	
			 28 : outRegister= 16'hfb10; //Signed Addition		
			 30 : outRegister= 16'h5705; //Branch Less Than		
			 32 : outRegister= 16'hfb20; //Signed Addition		
			 34 : outRegister= 16'h4702; //Branch Greater Than		
			 36 : outRegister= 16'hf110; //Signed Addition		
			 38 : outRegister= 16'hf110; //Signed Addition		
			 40 : outRegister= 16'hc890; //Load Word			
			 42 : outRegister= 16'hf880; //Signed Addition		
			 44 : outRegister= 16'hd890; //Store Word			
			 46 : outRegister= 16'hca90; //Load Word			
			 48 : outRegister= 16'hfcc0; //Signed Addition 		
			 50 : outRegister= 16'hfdd1; //Signed Subtraction		
			 52 : outRegister= 16'hfcd0; //Signed Addition 		
			 54 : outRegister= 16'hefff; //EFFF
			 default : outRegister = 16'h0000;
		 endcase;
      

end

endmodule
