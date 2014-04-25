

module SMULT16_ser4(output reg [255:0] product,output V,
  input [15:0] scalar, input [255:0] vecin, input start, output reg done,input clk1,input clk2);

    
  parameter S0= 3'b000;
  parameter S1= 3'b001;
  parameter S2= 3'b010;
  parameter S3= 3'b011;
  parameter S4= 3'b100;

  
  reg [15:0] Ov;
  wire [3:0] Overpart;
  wire [63:0] Prodpart;
  reg donev;
  reg [3:0] ovfl;
  reg [2:0] state,nextstate;
  reg [63:0] prod;
  reg [63:0] In1,In2;
  
  assign V = Ov;
  //assign done = donev;
  
  
  
  SMUL MUL1(Prodpart[15:0],Overpart[0],In1[15:0],In2[15:0]);
  SMUL MUL2(Prodpart[31:16],Overpart[1],In1[31:16],In2[31:16]);
  SMUL MUL3(Prodpart[47:32],Overpart[2],In1[47:32],In2[47:32]);
  SMUL MUL4(Prodpart[63:48],Overpart[3],In1[63:48],In2[63:48]);

 always@(posedge clk2)
 begin
   if(start == 1'b0)
     begin
     state <= S0;
     prod <= 64'h0;
     ovfl <= 4'h0;
     end
   else
     begin
     state <= nextstate;
     prod <= Prodpart;
     ovfl <= Overpart;
     end
 end
 

 always@(state)
 begin
 case(state)
 S0: begin
   In1 = vecin[63:0];
   In2 = {scalar,scalar,scalar,scalar};
   product = 0;
   Ov = 0;
   nextstate = S1;
 end
 S1: begin
   In1 = vecin[127:64];
   In2 = {scalar,scalar,scalar,scalar};
   
   product[63:0]  = prod;
   Ov[3:0] =  ovfl;
   
   nextstate = S2;

 end
  S2: begin
   In1 = vecin[191:128];
   In2 = {scalar,scalar,scalar,scalar};
      
   product[127:64] = prod;
   Ov[7:4] =  ovfl;
   
   nextstate = S3;

 end
  S3: begin
   In1 = vecin[255:192];
   In2 = {scalar,scalar,scalar,scalar};
         
   product[191:128] = prod;
   Ov[11:8] =  ovfl;
   
   nextstate = S4;
   donev = 1'b0;
 end
  S4: begin
   In1 = vecin[255:192];
   In2 = scalar;
      
   product[255:192] = prod;
   Ov[15:11] =  ovfl;
   
   nextstate = S0;
 
 end
 
 endcase 
 end
 
always@(posedge clk1) 
begin
 if (state == 3'b100)
      done <= 1'b1;
  else
      done <= 1'b0;
  end
 
endmodule



/*

module t_SMULTser4();

  wire [255:0] pro;
  wire ovf;
  reg [255:0] vec1;
  reg [15:0] s1;
  reg start;
  reg clka,clkb;
  wire done;

  SMULT16_ser4 S1(pro,ovf,s1,vec1,start,done,clka,clkb);


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

  initial begin
    start = 1'b0;
    s1 = 16'h3c00;
    vec1 = 256'h3c003c003c003c003c003c003c003c003c003c003c003c003c003c003c003c00;
    #15 start = 1'b1;
    #700 start = 1'b0;
    $stop;
  end
endmodule
*/
