 module M2_ALU
(
input  wire        CLK,         
input  wire        RST, 

input  wire [31:0] I_DAT,
input  wire 	   I_STB,
input wire        I_NUM_OR_OP,//  np. jeœli =1 to liczba,  jeœli 0 to operator.
output wire 	   I_ACK,
output wire 	I_BSY2,

output reg  O_STB,
output reg  [31:0] O_DAT,
input  wire O_ACK

); 	  

wire       push_stb;
reg [31:0] push_dat;	
wire [31:0] pop_dat;
reg pop_ack;
reg  [31:0] v1;
reg [31:0] v2; 
reg [2:0]bsy2;	

assign I_ACK = !I_STB ;
assign I_BSY2 = (I_NUM_OR_OP==0 && bsy2>0) ? 1:0; 
assign push_stb= (I_NUM_OR_OP==1 || (I_NUM_OR_OP==0 && (bsy2==2 || bsy2==3) && !O_ACK ) || (I_NUM_OR_OP==0 && (bsy2==2 || bsy2==0) && O_ACK )) ? 1:0;
always @(posedge CLK or posedge RST)
	begin

pop_ack <= ((I_NUM_OR_OP==0 && bsy2==0 )||(I_NUM_OR_OP==0 && bsy2==1 ) || O_ACK) ? 1:0;	//
 end
always @(posedge CLK or posedge RST)
if (RST)begin
O_STB <= 0;
bsy2<=0; 
pop_ack<= I_NUM_OR_OP==0 ? 1:0;	 

end 
else if (O_ACK) O_STB <= 1; 
else if (I_ACK) O_STB <= 0;

always @(posedge CLK or posedge RST)
if(I_NUM_OR_OP==1) begin 
	push_dat<= I_DAT;
	bsy2<=3;
end	  
else if(I_NUM_OR_OP==0 && bsy2==3  && !O_ACK ) begin    //jeœli nie jest liczb¹ i poprzedni znak to liczba
	v1<= pop_dat;	//pobranie pierwszej liczby oraz zapamietanie jej
	 bsy2<=1;
end		 
else if(I_NUM_OR_OP==0 && bsy2==1 && !O_ACK ) begin   //jesli nie jest liczb¹ i poprzedni znak to znów nie liczba
	v2<= pop_dat;  //pobranie drugiej liczby
	bsy2<=2;  
end	
else if((I_NUM_OR_OP==0 && bsy2==2 && !O_ACK) ) begin
	
if(I_DAT=="+")begin	  //jesli + dodawanie wynik na stos
	push_dat<= v1 + v2;	
		end
	else if(I_DAT=="-")begin //jesli - odejmowanie wynik na stos
		push_dat<= v1 - v2; 
	end
	else if(I_DAT=="*")begin   //jesli * mnozenie wynik na stos
		push_dat<= v1 * v2;
	end	
	bsy2<=0;
end	
else if(I_NUM_OR_OP==0 && bsy2==0  && O_ACK) begin 	//jesli nie jest liczb¹ oraz dopiero co wykonane zosta³o dzia³anie matematyczne lub dopiero co wystartowa³ program
	v1<= pop_dat;  //pobranie piewrszej liczby
	 bsy2<=1;
end		 
else if(I_NUM_OR_OP==0 && bsy2==1 && O_ACK ) begin //jeœli nie jest liczb¹ a wyst¹pi³ wczeœniej znak
	v2<= pop_dat;
	bsy2<=2;  
end
else if(I_NUM_OR_OP==0 && bsy2==2 && O_ACK)begin	
	
	if(I_DAT=="+")begin		//jesli + dodawanie wynik na stos
		O_DAT<= v1 + v2;
		end
	else if(I_DAT=="-")begin	//jesli - odejmowanie wynik na stos
		O_DAT<= v1 - v2;   
	end
	else if(I_DAT=="*")begin	  //jesli * mnozenie wynik na stos
		O_DAT<= v1 * v2;
	end	
	bsy2<=3;
	end

	
 
stack_alu s2 
(
.CLK(CLK),      
.RST(RST),      
.PUSH_STB(push_stb), 
.PUSH_DAT(push_dat), 
.POP_STB(),  
.POP_DAT(pop_dat),
.PUSH_ACK(push_ack),
.POP_ACK(pop_ack),
.EMP(empty_stack)
); 			 


endmodule