module stack_alu
(                            
input  wire        CLK,      
input  wire        RST,                      
input  wire        PUSH_STB, 
input  wire [31:0] PUSH_DAT,                            
output  wire        POP_STB,  
output wire [31:0] POP_DAT,	
output  wire        PUSH_ACK,
input  wire       POP_ACK,

output reg EMP

);                           
//-------------------------------------------------------------------------------
reg    [4:0] push_ptr;
//-------------------------------------------------------------------------------
reg    [3:0] pop_ptr;
//-------------------------------------------------------------------------------
	assign  PUSH_ACK = PUSH_STB&& (full ? 0:1);	 
  assign  POP_STB = (!PUSH_STB)&&(empty ? 0:1);
  assign full = (push_ptr==5'b1_0000);
  assign empty = (push_ptr==5'b0_0000);
 
 always@(posedge CLK or posedge RST)
	 EMP<=empty;  
 always@(posedge CLK or posedge RST)
 if(RST)	
  begin	 
	pop_ptr  <= 4'hF;
	push_ptr <= 5'h0; 
  end
 else if(PUSH_ACK)	 //dodanie do stosu	(pomoc dla maszyny)
  begin
   push_ptr <= push_ptr + 4'd1;
   pop_ptr  <= pop_ptr  + 4'd1; 
  end	  
 else if(POP_ACK&&POP_STB)	 //zabranie ze stosu (pomoc dla maszyny)
  begin
   push_ptr <= push_ptr - 4'd2;
   pop_ptr  <= pop_ptr  - 4'd2;
  end 
  
  
//-------------------------------------------------------------------------------
reg [31:0] RAM [0:15];	
//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------
always@( posedge CLK)
	if(PUSH_STB) RAM [ push_ptr ] <= PUSH_DAT;	//dos³owne dodanie do stosu
//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------
assign 	POP_DAT = RAM[pop_ptr] ;  //dos³owne zabranie ze stosu

endmodule

