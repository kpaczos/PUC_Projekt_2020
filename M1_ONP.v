module M1_ONP
(
input  wire        CLK,         
input  wire        RST, 

input  wire [31:0] I_DAT,
input  wire I_STB,		
output wire I_ACK,
output wire I_BSY,

output reg  O_STB,
output reg  [31:0] O_DAT,
input  wire O_ACK
);


assign I_ACK = !I_STB ;
assign I_BSY = (((I_DAT == "+"|| I_DAT == "-") && (pop_dat == "*")) || i_bsy2) ? 0:1;	//przypisanie jeœli operator + lub - a na stosie jest ju¿ *   


reg  all;
reg        push_stb;
reg [31:0] push_dat;	
wire [31:0] pop_dat;
reg pop_ack;
reg    [7:0] counter;
wire NoO;
reg ow;	 
reg [31:0] x; 
reg [31:0] O_DAT_ALU;
//------------------------------------------------------------------------------- 
assign NoO= (O_DAT_ALU == "+"|| O_DAT_ALU == "-" || O_DAT_ALU == "*") ? 0:1;   //przypisanie czy jest to liczba czy operator
always @(posedge CLK or posedge RST)
begin all <= (counter <= 8'b1)? 1:0;	end
always @(posedge CLK or posedge RST) 
if (RST) O_STB <= 0; else if (all) O_STB <= 0; else if (I_ACK) O_STB <= 1; 
	
always @(posedge CLK or posedge RST)
if(RST)	//start
	begin	  
	push_stb <= 0;
	push_dat <= 0; 
	pop_ack <=  0;	 
	counter <= 8'h2; 
	ow<=0;
  	end
else if(I_DAT == "=")  //jeœli doszed³‚ program do równa siê push_dat zostaje na 0 
 	begin
	 pop_ack <=  1;	  
	 push_stb <= 0;
	push_dat <= 0; 
	while (i_bsy2)  begin @(posedge CLK);end 
	O_DAT_ALU <= pop_dat; 
	ow<=0; 
	end	
	  
else if((I_DAT == "+"|| I_DAT == "-")&&(pop_dat == "*"))   // jeœli jest + lub - a na stosie jest * 
	begin  
	ow<=0;
	pop_ack <=  1; 	
	while (i_bsy2)  begin @(posedge CLK);end 
	O_DAT_ALU <= pop_dat;
	ow<=1;	 
	pop_ack <=  0; 	
	push_stb <= 1;
	push_dat <= I_DAT;  
	end	
	
else if( (I_DAT == "+"|| I_DAT == "-")&&(pop_dat == "+" ||  pop_dat == "-")) 	//jesli wejœciowe jest + lub - a na stosie jest ju¿ + lub -
	begin 	  
		pop_ack <=  1; 
		ow<=0;
		while (i_bsy2)  begin @(posedge CLK);end 
		O_DAT_ALU <= pop_dat; 
		ow<=1;
		push_stb <= 1;
		push_dat <= I_DAT;  
		pop_ack <=  0; 
		counter <= counter +8'b1; 
		ow<=0;
	 end
	   else if( ((I_DAT == "+"|| I_DAT == "-")&&(pop_dat == "+" ||  pop_dat == "-")) || ((I_DAT == "+"|| I_DAT == "-")))
	begin	  
		pop_ack <=  0; 
		ow<=1;
		push_stb <= 1;
		push_dat <= I_DAT;  
				
		ow<=0;
			
	end

else if(I_DAT == "*")  		 //jeœlli na wejœcie jest * 
	begin
		pop_ack <= 0; 
		if(pop_dat == "*" ||  pop_dat == "/") ow<=1;
		else ow<=0;
		push_stb <= 1;
		push_dat <= I_DAT; 
		counter <= counter +8'b1; 
	
end	 
 //------------------------------------------------------------------------------------------------
else  
	begin
	 while (i_bsy2)  begin @(posedge CLK);end //jeœli zajêty czyli np liczba potrzebna do obliczenia * 
	O_DAT_ALU <= I_DAT;
	end	
always@( posedge CLK)
if(pop_ack  && !(counter == 8'b0))
	begin 
	while (i_bsy2)  begin @(posedge CLK);end 
	 O_DAT_ALU <= pop_dat;
	 counter <= counter - 8'b1;
	end
	M2_ALU alu
(
.CLK(CLK),      
.RST(RST),  

.I_DAT(O_DAT_ALU),
.I_STB(O_STB), 
.I_NUM_OR_OP(NoO),
.I_ACK(),
.I_BSY2(i_bsy2),
.O_DAT(O_DAT),
.O_STB(),
.O_ACK(all)

); 
stack s1 
(
.CLK(CLK),      
.RST(RST),      
.PUSH_STB(push_stb), 
.PUSH_DAT(push_dat), 
.POP_STB(),  
.POP_DAT(pop_dat),
.PUSH_ACK(push_ack),
.POP_ACK(pop_ack),
.OW(ow)
); 	


endmodule