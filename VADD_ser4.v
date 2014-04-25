
module VADD16_ser4(output reg [255:0] SumV,output Overflw,input [255:0] Inval1,input [255:0] Inval2,input start,output reg done,input clk1,input clk2);
  
  parameter S0= 3'b000;
  parameter S1= 3'b001;
  parameter S2= 3'b010;
  parameter S3= 3'b011;
  parameter S4= 3'b100;
  
  reg [15:0] Ov;
  wire [3:0] Overpart;
  wire [63:0] Sumpart;
  reg [3:0] ovfl;
  reg [2:0] state,nextstate;
  reg [63:0] sump;
  reg [63:0] In1,In2;
  
  assign Overflw = | Ov;
  
  VADD add1(Sumpart[15:0],Overpart[0],In1[15:0],In2[15:0]);
  VADD add2(Sumpart[31:16],Overpart[1],In1[31:16],In2[31:16]);
  VADD add3(Sumpart[47:32],Overpart[2],In1[47:32],In2[47:32]);
  VADD add4(Sumpart[63:48],Overpart[3],In1[63:48],In2[63:48]);

 always@(posedge clk2)
 begin
   if(start == 1'b0)
     begin
     state <= S0;
     sump <= Sumpart;
     ovfl <= Overpart;
     end
   else
     begin
     state <= nextstate;
     sump <= Sumpart;
     ovfl <= Overpart;
     end
 end
 

 always@(state,start)
 begin
 case(state)
 S0: begin
   In1 = Inval1[63:0];
   In2 = Inval2[63:0];
   SumV = 15'h0;
   Ov = 15'h0;
   nextstate = S1;
   //donev = 1'b0;
 end
 S1: begin
   In1 = Inval1[127:64];
   In2 = Inval2[127:64];
   
   SumV[63:0]  = sump;
   Ov[3:0] =  ovfl;
   
   nextstate = S2;
   //donev = 1'b0;
 end
  S2: begin
   In1 = Inval1[191:128];
   In2 = Inval2[191:128];
      
   SumV[127:64] = sump;
   Ov[7:4] =  ovfl;
   
   nextstate = S3;
   //donev = 1'b0;
 end
  S3: begin
   In1 = Inval1[255:192];
   In2 = Inval2[255:192];
      
   SumV[191:128] = sump;
   Ov[11:8] =ovfl;
   
   nextstate = S4;
   //donev = 1'b0;
 end
  S4: begin
   In1 = Inval1[255:192];
   In2 = Inval2[255:192];
      
   SumV[255:192] = sump;
   Ov[15:12] = ovfl;
   
   nextstate = S0;
   //donev = 1'b0;
 end
 endcase
 end
 
 
 always@(posedge clk1) begin
 if (state == 5'b100)
      done <= 1'b1;
  else
      done <= 1'b0;
  end
 
endmodule
/*
`timescale 1ns/10ps
module t_VADD164pipe();
  
wire [255:0] SumVa;
wire Overflwa;
wire donea;

reg [255:0] Inval1a,Inval2a;
reg starta;
reg clka,clkb; 

VADD16_ser4 adderpipe(.SumV(SumVa),.Overflw(Overflwa),.Inval1(Inval1a),.Inval2(Inval2a),.start(starta),.done(donea),.clk1(clka),.clk2(clkb));
  
initial
begin
  clka = 1'b0;
  clkb = 1'b0;
  forever 
  begin
  #5 clka = 1'b1;
  #5 clkb = 1'b1;
  clka = 1'b0;
  #5 clkb = 1'b0;
end
end

initial
begin
Inval1a = 256'h533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a;
Inval2a = 256'h533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a;
starta = 1'b0;
#15 starta = 1'b1;
#1500 $stop;
end

endmodule
*/
