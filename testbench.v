module _9_mytestbenchmodule();
reg CLK;
initial CLK  <= 0;
always #50  CLK <= ~CLK;
		
reg RST;
initial 
begin
	RST <= 0;
	RST <= #50 1;
	RST <= #500 0;
end	  

integer fi;
integer count; 
reg [31:0]i_dat;
reg istb, o_ack;
integer  i1, i2, i3, i4,i5,i6,i7,i8;

initial
begin 
	 istb = 0;
	o_ack <= 0;
	fi = $fopen("input.txt","r");

	#1000; @(posedge CLK); 
				
	$fscanf(fi, "%d %s %d %s %d %s %d %s", i1,i2,i3,i4,i5,i6,i7,i8);
		istb <= 1;
		i_dat <= i1;	@(posedge CLK); while (!i_bsy)  begin @(posedge CLK);end
		i_dat <= i2;	@(posedge CLK); while (!i_bsy)  begin @(posedge CLK);end
		i_dat <= i3;	@(posedge CLK); while (!i_bsy)  begin @(posedge CLK);end
		i_dat <= i4;	@(posedge CLK); while (!i_bsy)  begin @(posedge CLK);end
		i_dat <= i5;	@(posedge CLK); while (!i_bsy)  begin @(posedge CLK);end
		i_dat <= i6;	@(posedge CLK); while (!i_bsy)  begin @(posedge CLK);end
		i_dat <= i7;	@(posedge CLK); while (!i_bsy)  begin @(posedge CLK);end
		i_dat <= i8;	@(posedge CLK); while (!i_bsy)  begin @(posedge CLK);end
 	
	 istb<=0; @(posedge CLK);  
	 o_ack <= 1;
end	  
	  

M1_ONP onp 
(
.CLK(CLK),      
.RST(RST),  

.I_DAT(i_dat),
.I_STB(istb), 
.I_ACK(),
.I_BSY(i_bsy),

.O_DAT(),
.O_STB(),
.O_ACK(o_ack)

);              

endmodule

