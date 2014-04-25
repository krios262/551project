module VADD16(output [255:0] SumV,output V,input [255:0] A,input [255:0] B,input start,output done);

  wire [15:0] Ov;

  assign V = Ov[0] |Ov[1] | Ov[2] | Ov[3] | Ov[4] | Ov[5] | Ov[6] | Ov[7] | Ov[8] | Ov[9] | Ov[10] | Ov[11] | Ov[12] | Ov[13] | Ov[14] | Ov[15] ; 
  assign done = start;

  VADD adder[15:0](SumV,Ov,A,B);
  /*
  VADD add1(SumV[15:0],Ov[0],A[15:0],B[15:0]);
  VADD add2(SumV[31:16],Ov[1],A[31:16],B[31:16]);
  VADD add3(SumV[47:32],Ov[2],A[47:32],B[47:32]);
  VADD add4(SumV[63:48],Ov[3],A[63:48],B[63:48]);
  VADD add5(SumV[79:64],Ov[4],A[79:64],B[79:64]);
  VADD add6(SumV[95:80],Ov[5],A[95:80],B[95:80]);
  VADD add7(SumV[111:96],Ov[6],A[111:96],B[111:96]);
  VADD add8(SumV[127:112],Ov[7],A[127:112],B[127:112]);
  VADD add9(SumV[143:128],Ov[8],A[143:128],B[143:128]);
  VADD add10(SumV[159:144],Ov[9],A[159:144],B[159:144]);
  VADD add11(SumV[175:160],Ov[10],A[175:160],B[175:160]);
  VADD add12(SumV[191:176],Ov[11],A[191:176],B[191:176]);
  VADD add13(SumV[207:192],Ov[12],A[207:192],B[207:192]);
  VADD add14(SumV[223:208],Ov[13],A[223:208],B[223:208]);
  VADD add15(SumV[239:224],Ov[14],A[239:224],B[239:224]);
  VADD add16(SumV[255:240],Ov[15],A[255:240],B[255:240]);
  */

endmodule


module VADD16_ser(output reg [255:0] SumV,output Overflw,input [255:0] Inval1,input [255:0] Inval2,input start,output reg done,input clk1,input clk2);
  
  parameter S0= 5'b00000;
  parameter S1= 5'b00001;
  parameter S2= 5'b00010;
  parameter S3= 5'b00011;
  parameter S4= 5'b00100;
  parameter S5= 5'b00101;
  parameter S6= 5'b00110;
  parameter S7= 5'b00111;
  parameter S8= 5'b01000;
  parameter S9= 5'b01001;
  parameter S10= 5'b01010;
  parameter S11= 5'b01011;
  parameter S12= 5'b01100;
  parameter S13= 5'b01101;
  parameter S14= 5'b01110;
  parameter S15= 5'b01111;
  parameter S16= 5'b10000;
  parameter S17= 5'b10001;
  
  reg [15:0] Ov;
  wire Overpart;
  wire [15:0] Sumpart;
  reg donev;
  reg ovfl;
  reg [4:0] state,nextstate;
  reg [15:0] sump;
  reg [15:0] In1,In2;
  
  assign Overflw = Ov;
  //assign done = donev;
  
  
  
  VADD add1(Sumpart,Overpart,In1,In2);

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
   In1 = Inval1[15:0];
   In2 = Inval2[15:0];
   SumV = 0;
   Ov = 0;
   nextstate = S1;
   //donev = 1'b0;
 end
 S1: begin
   In1 = Inval1[31:16];
   In2 = Inval2[31:16];
   
   SumV[15:0]  = sump;
   Ov = Ov | ovfl;
   
   nextstate = S2;
   //donev = 1'b0;
 end
  S2: begin
   In1 = Inval1[47:32];
   In2 = Inval2[47:32];
      
   SumV[31:16] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S3;
   //donev = 1'b0;
 end
  S3: begin
   In1 = Inval1[63:48];
   In2 = Inval2[63:48];
      
   SumV[47:32] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S4;
   //donev = 1'b0;
 end
  S4: begin
   In1 = Inval1[79:64];
   In2 = Inval2[79:64];
      
   SumV[63:48] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S5;
   //donev = 1'b0;
 end
  S5: begin
   In1 = Inval1[95:80];
   In2 = Inval2[95:80];
      
   SumV[79:64] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S6;
   //donev = 1'b0;
 end
  S6: begin
   In1 = Inval1[111:96];
   In2 = Inval2[111:96];
      
   SumV[95:80] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S7;
   //donev = 1'b0;
 end
  S7: begin
   In1 = Inval1[127:112];
   In2 = Inval2[127:112];
      
   SumV[111:96] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S8;
   //donev = 1'b0;
 end
  S8: begin
   In1 = Inval1[143:128];
   In2 = Inval2[143:128];
      
   SumV[127:112] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S9;
   //donev = 1'b0;
 end
  S9: begin
   In1 = Inval1[159:144];
   In2 = Inval2[159:144];
      
   SumV[143:128] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S10;
   //donev = 1'b0;
 end
  S10: begin
   In1 = Inval1[175:160];
   In2 = Inval2[175:160];
      
   SumV[159:144] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S11;
   //donev = 1'b0;
 end
  S11: begin
   In1 = Inval1[191:176];
   In2 = Inval2[191:176];
      
   SumV[175:160] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S12;
   //donev = 1'b0;
 end
  S12: begin
   In1 = Inval1[207:192];
   In2 = Inval2[207:192];
      
   SumV[191:176] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S13;
   //donev = 1'b0;
 end
  S13: begin
   In1 = Inval1[223:208];
   In2 = Inval2[223:208];
      
   SumV[207:192]= sump;
   Ov = Ov | ovfl;
   
   nextstate = S14;
   //donev = 1'b0;
 end
  S14: begin
   In1 = Inval1[239:224];
   In2 = Inval2[239:224];
      
   SumV[223:208]= sump;
   Ov = Ov | ovfl;
   
   nextstate = S15;
   //donev = 1'b0;
 end
   S15: begin
   In1 = Inval1[255:240];
   In2 = Inval2[255:240];
      
   SumV[239:224] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S16;
   //donev = 1'b0;
 end
  S16: begin
   In1 = Inval1[255:240];
   In2 = Inval2[255:240];
      
   SumV[255:240] = sump;
   Ov = Ov | ovfl;
   
   nextstate = S0;
   //donev = 1'b1;
 end
 endcase
 end
 
 
 always@(posedge clk1) begin
 if (state == 5'b10000)
      done <= 1'b1;
  else
      done <= 1'b0;
  end
 
endmodule

/*
`timescale 1ns/10ps
module t_VADD16pipe();
  
wire [255:0] SumVa;
wire Overflwa;
wire donea;

reg [255:0] Inval1a,Inval2a;
reg starta;
reg clka; 

VADD16 adderpipe(.SumV(SumVa),.Overflw(Overflwa),.Inval1(Inval1a),.Inval2(Inval2a),.start(starta),.done(donea),.clk(clka));
  
initial
begin
  clka = 1'b0;
  forever #5 clka = ~clka;
end

initial
begin
Inval1a = 256'h533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a;
Inval2a = 256'h533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a_533a;
starta = 1'b1;
#10 starta = 1'b0;
#500 $stop;
end

endmodule
*/
