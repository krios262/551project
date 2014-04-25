module SMULT16(output [255:0] product,output V,
  input [15:0] scalar, input [255:0] vecin, input start, output done);

  wire [15:0] Ov;

  assign V = Ov[0] | Ov[1] | Ov[2] | Ov[3] | Ov[4] | Ov[5] | Ov[6] |
            Ov[7] | Ov[8] | Ov[9] | Ov[10] | Ov[11] | Ov[12] | Ov[13] | Ov[14]|Ov[15];

  assign done = start; //this module finishes operation in one cycle

  VMULT mult[15:0](.product(product), .Overflow(Ov[15:0]),
    .A(scalar), .B(vecin));

endmodule


module SMULT16_ser(output reg [255:0] product,output V,
  input [15:0] scalar, input [255:0] vecin, input start, output reg done,input clk1,input clk2);

    
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
  wire [15:0] Prodpart;
  reg donev;
  reg ovfl;
  reg [4:0] state,nextstate;
  reg [15:0] prod;
  reg [15:0] In1,In2;
  
  assign V = Ov;
  //assign done = donev;
  
  
  
  SMUL MUL1(Prodpart,Overpart,In1,In2);

 always@(posedge clk2)
 begin
   if(start == 1'b0)
     begin
     state <= S0;
     prod <= 15'h0;
     ovfl <= Overpart;
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
   In1 = vecin[15:0];
   In2 = scalar;
   product = 0;
   Ov = 0;
   nextstate = S1;
 end
 S1: begin
   In1 = vecin[31:16];
   In2 = scalar;
   
   product[15:0]  = prod;
   Ov = Ov | ovfl;
   
   nextstate = S2;

 end
  S2: begin
   In1 = vecin[47:32];
   In2 = scalar;
      
   product[31:16] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S3;

 end
  S3: begin
   In1 = vecin[63:48];
   In2 = scalar;
      
   product[47:32] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S4;
   donev = 1'b0;
 end
  S4: begin
   In1 = vecin[79:64];
   In2 = scalar;
      
   product[63:48] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S5;
 
 end
  S5: begin
   In1 = vecin[95:80];
   In2 = scalar;
      
   product[79:64] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S6;

 end
  S6: begin
   In1 = vecin[111:96];
   In2 = scalar;
      
   product[95:80] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S7;

 end
  S7: begin
   In1 = vecin[127:112];
   In2 = scalar;
      
   product[111:96] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S8;
  
 end
  S8: begin
   In1 = vecin[143:128];
   In2 = scalar;
      
   product[127:112] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S9;

 end
  S9: begin
   In1 = vecin[159:144];
   In2 = scalar;
      
   product[143:128] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S10;
  
 end
  S10: begin
   In1 = vecin[175:160];
   In2 = scalar;
      
   product[159:144] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S11;
  
 end
  S11: begin
   In1 = vecin[191:176];
   In2 = scalar;
      
   product[175:160] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S12;

 end
  S12: begin
   In1 = vecin[207:192];
   In2 = scalar;
      
   product[191:176] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S13;
 
 end
  S13: begin
   In1 = vecin[223:208];
   In2 = scalar;
      
   product[207:192]= prod;
   Ov = Ov | ovfl;
   
   nextstate = S14;
 
 end
  S14: begin
   In1 = vecin[239:224];
   In2 = scalar;
      
   product[223:208]= prod;
   Ov = Ov | ovfl;
   
   nextstate = S15;

 end
   S15: begin
   In1 = vecin[255:240];
   In2 = scalar;
      
   product[239:224] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S16;
  
 end
  S16: begin
   In1 = vecin[255:240];
   In2 = scalar;
      
   product[255:240] = prod;
   Ov = Ov | ovfl;
   
   nextstate = S17;
  
 end
 endcase 
 end
 
always@(posedge clk1) 
begin
 if (state == 5'b10000)
      done <= 1'b1;
  else
      done <= 1'b0;
  end
 
endmodule





module t_SMULT12();

  wire [255:0] pro;
  wire ovf;
  reg [255:0] vec1;
  reg [15:0] s1;
  reg start;
  wire done;

  SMULT16 S1(pro,ovf,s1,vec1,start,done);

  initial $monitor("Product:%h Overflow:%b", pro, ovf);
  initial begin
    start = 1'b1;
    s1 = 16'h3c00;
    vec1 = 256'h3c003c003c003c003c003c003c003c003c003c003c003c003c003c003c003c00;
    #10; //Answer = 3c00 repeating
    s1 = 16'hbc00; 
    //vec1 is same
    #10; //Answer = bc00 repeating
    s1 = 16'h7ccc;
    vec1 = 256'h7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde;
    #10; // Answer = 7c00 repeating
    s1 = 16'h3c80;
    vec1 = 256'h0201020102010201020102010201020102010201020102010201020102010201;
    #10; // Answer = 0241 repeating
    $finish;
  end
endmodule


module t_SMULT();

  wire [255:0] pro;
  wire ovf;
  reg [255:0] vec1;
  reg [15:0] s1;
  reg start;
  wire done;

  SMULT16 S1(pro,ovf,s1,vec1,start,done);

  initial $monitor("Product:%h Overflow:%b", pro, ovf);
  initial begin
    start = 1'b1;
    s1 = 16'h3c00;
    vec1 = 256'h3c003c003c003c003c003c003c003c003c003c003c003c003c003c003c003c00;
    #10; //Answer = 3c00 repeating
    s1 = 16'hbc00; 
    //vec1 is same
    #10; //Answer = bc00 repeating
    s1 = 16'h7ccc;
    vec1 = 256'h7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde;
    #10; // Answer = 7c00 repeating
    s1 = 16'h3c80;
    vec1 = 256'h0201020102010201020102010201020102010201020102010201020102010201;
    #10; // Answer = 0241 repeating
    $finish;
  end
endmodule

