module stack
(                            
input  wire        CLK,      
input  wire        RST,                      
input  wire        PUSH_STB, 
input  wire [31:0] PUSH_DAT,                            
output  wire        POP_STB,  
output wire [31:0] POP_DAT,	
output  wire        PUSH_ACK,
input  wire       POP_ACK,
input wire		  OW
);                           
//-------------------------------------------------------------------------------
reg    [4:0] push_ptr;
//-------------------------------------------------------------------------------
reg    [3:0] pop_ptr;
//-------------------------------------------------------------------------------
	  
  wire full;
  wire empty;
  
  assign full = (push_ptr==5'b1_0000);
  assign empty = (push_ptr==5'b0_0000);
  assign  PUSH_ACK =PUSH_STB && (full ? 0:1);	 
  assign  POP_STB = (!PUSH_STB)&&(empty ? 0:1);	 
 							 
 		  
 always@(posedge CLK or posedge RST)
 if(RST)	
  begin	 
	pop_ptr  <= 4'hF;
	push_ptr <= 4'h0; 
  end 
   else if(POP_ACK)
  begin
   push_ptr <= push_ptr - 4'd1;
   pop_ptr  <= pop_ptr  - 4'd2;	 
  end 
  always@(posedge CLK or posedge RST) 	
  if(PUSH_ACK)
  begin	
	 
   push_ptr <= push_ptr + 4'd1;
   pop_ptr  <= pop_ptr  + 4'd1; 
  
  end
  
  
//-------------------------------------------------------------------------------
reg [31:0] RAM [0:15];	
//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------
always@( posedge CLK)
	if(PUSH_STB && !OW) RAM [ push_ptr ] <= PUSH_DAT;
else if(PUSH_STB && OW)begin RAM [ push_ptr ] <= 0; RAM [ push_ptr - 4'd2 ] <= PUSH_DAT;end	
//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------  


assign 	POP_DAT = (RAM[pop_ptr] == "+" || RAM[pop_ptr] == "-" || RAM[pop_ptr] == "*") ? RAM[pop_ptr]:  RAM[pop_ptr - 4'd2] ;

endmodule

