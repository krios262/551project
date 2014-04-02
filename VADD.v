module VADD16(output [255:0] SumV,output Overflw,input [255:0] Inval1,input [255:0] Inval2,input start,output done);
  
  wire [15:0] Ov;
  
  assign Overflw = Ov[0] |Ov[1] | Ov[2] | Ov[3] | Ov[4] | Ov[5] | Ov[6] | Ov[7] | Ov[8] | Ov[9] | Ov[10] | Ov[11] | Ov[12] | Ov[13] | Ov[14] | Ov[15] ; 
  assign done = start;
  
  VADD add1(SumV[15:0],Ov[0],Inval1[15:0],Inval2[15:0]);
  VADD add2(SumV[31:16],Ov[1],Inval1[31:16],Inval2[31:16]);
  VADD add3(SumV[47:32],Ov[2],Inval1[47:32],Inval2[47:32]);
  VADD add4(SumV[63:48],Ov[3],Inval1[63:48],Inval2[63:48]);
  VADD add5(SumV[79:64],Ov[4],Inval1[79:64],Inval2[79:64]);
  VADD add6(SumV[95:80],Ov[5],Inval1[95:80],Inval2[95:80]);
  VADD add7(SumV[111:96],Ov[6],Inval1[111:96],Inval2[111:96]);
  VADD add8(SumV[127:112],Ov[7],Inval1[127:112],Inval2[127:112]);
  VADD add9(SumV[143:128],Ov[8],Inval1[143:128],Inval2[143:128]);
  VADD add10(SumV[159:144],Ov[9],Inval1[159:144],Inval2[159:144]);
  VADD add11(SumV[175:160],Ov[10],Inval1[175:160],Inval2[175:160]);
  VADD add12(SumV[191:176],Ov[11],Inval1[191:176],Inval2[191:176]);
  VADD add13(SumV[207:192],Ov[12],Inval1[207:192],Inval2[207:192]);
  VADD add14(SumV[223:208],Ov[13],Inval1[223:208],Inval2[223:208]);
  VADD add15(SumV[239:224],Ov[14],Inval1[239:224],Inval2[239:224]);
  VADD add16(SumV[255:240],Ov[15],Inval1[255:240],Inval2[255:240]);
 
  
endmodule
  

/*output reg [14:0] operSum,output reg [11:0] opersum1,output reg [10:0] opersum2,output reg [14:0] operA,output reg [14:0] operB,*/
module VADD(output reg [15:0] Sum,output reg Overflow,input [15:0] A, input [15:0] B);
  
  reg [14:0] operA,operB;
  wire [14:0] operA1,operB1,operA2,operB2;
  reg [14:0] operSum;
  reg [11:0] opersum1;
  reg [10:0] opersum2;
  reg [4:0] DiffE;
  reg [5:0] i = 6'b000000;
  reg [5:0] j = 4'b0000;
  reg [1:0] oper;
  reg flag;
  reg flaginf;
  
  //append sticky and guard bit along with normalised one
  assign operA1 = {1'b0,1'b1,A[9:0],3'b000};
  assign operB1 = {1'b0,1'b1,B[9:0],3'b000}; 
  assign operA2 = {2'b0,A[9:0],3'b000};
  assign operB2 = {2'b0,B[9:0],3'b000};
  
  //perform floating point addition
  always @(*)
  begin
  if((A[14:10] == 5'h1F) || (B[14:10] == 5'h1F))
  begin
     if (A[14:10] == 5'h1F) 
       begin
         Sum = {A[15],A[14:10],10'h0};
         Overflow = 1'b1;
       end
     else 
       begin
         Sum = {B[15],B[14:10],10'h0};
         Overflow = 1'b1;
       end
  end
  else
  begin
  if((A[14:10] == 5'h0) && (B[14:10] == 5'h0))
  begin 
    operA = operA2;
    operB = operB2;
  end
  else if (A[14:10] == 5'h0)
  begin
    operA = operA2;
    operB = operB1;
  end
  else if(B[14:10] == 5'h0)
  begin
    operA = operA1;
    operB = operB2;
  end
  else
  begin
    operA = operA1;
    operB = operB1;
  end
  
   
  //if exponent of A > B    
  if (A[14:10] > B[14:10])
    begin
      DiffE=A[14:10]-B[14:10];//calculate the difference in exponent
      
      for(i=0;i<32;i=i+1)
      begin
        if(DiffE >0)
          begin
            if(operB[0] == 1'b1)
              begin
                operB = {1'b0,(operB[14:2]),1'b1}; // adjust the mantissa
                DiffE = DiffE-1'b1;
              end
            else
              begin
                operB = operB >> 1;
                DiffE = DiffE -1'b1 ;
              end
          end
        else
          begin
          operB = operB;
          end
      end
      
     Sum[14:10]= A[14:10];//assign final sum exponent
     if(A[15] != B[15])
       begin
       Sum[15] = A[15];  //assign sign of sum based on value of A and B         
       end
    end

//if exponent of B > A
  else if (B[14:10] > A[14:10])
    begin
      DiffE=B[14:10]-A[14:10];//calculate the difference in exponent
      
      for(i=0;i<32;i=i+1)
      begin
        if(DiffE >0)
          begin
            if(operA[0] == 1'b1)
              begin
                operA = {1'b0,(operA[14:2]),1'b1}; // adjust the mantissa
                DiffE = DiffE-1'b1;
              end
            else
              begin
                operA = operA >> 1'b1;
                DiffE = DiffE -1'b1;
              end
          end
        else
          begin
          operA = operA;
          end
      end 
      
      Sum[14:10]= B[14:10]; //assign the exponent to the sum
      if(A[15] != B[15])
        begin
        Sum[15] = B[15];  // assign the sign for the Sum         
        end       
    end

else // if exponents are equal
  begin
    operA = operA; //
    operB = operB; // no changes to A and B
    Sum[14:10] = A[14:10];// assign exponent value to output
    if(operA > operB)
      begin
        Sum[15] = A[15];// assign sign to output based on magnitude of A and B
      end
    else
      begin
        Sum[15] = B[15];// assign sign to output
      end      
  end

// based on sign of the elements perform the mathematical operation
// if sign is same perform addition
if(A[15] == B[15])
  begin
    operSum = operA + operB;
    oper = 2'b01;
  end
// if val A > B
else if (operA > operB)
  begin
    operSum = operA - operB;
    oper = 2'b10;
  end
// if val of B > A
else if (operB > operA)
  begin
    operSum = operB - operA;
    oper = 2'b11;
  end
 // if A == B and sign is opposite the answer is 0
 else if (operB == operA)
   operSum = 15'h0;


// normalising for sum
if(operSum[14] == 1'b1)
  begin
    if(Sum[14:10] != 5'h1E)
      begin
        operSum = operSum >> 1'b1;
        Sum[14:10] = Sum[14:10] + 1'b1;
        flaginf = 1'b0; 
        Overflow = 1'b0;
      end
    else
      begin
        operSum = operSum;
        Sum[14:10] = 5'h1F;
        //Sum[9:0] = 10'h0;
        flaginf = 1'b1;
        Overflow = 1'b1;
      end
  end
/* else if(Sum[14:0] == 5'b0)
  begin
    if (operSum[13] == 1'b1)
      begin*/
        
else 
   begin
     flag =1'b0;
     flaginf = 1'b0;
     Overflow = 1'b0;
     for(j=0;j<14;j=j+1)
     begin
        if((operSum[13]-j)== 1'b0)
          begin
            if(flag == 1'b0)
              begin
              operSum = operSum << 1'b1;
              Sum[14:10] = Sum[14:10] - 1'b1; 
              end
            else
              begin
              operSum = operSum;
              Sum[14:10] = Sum[14:10]; 
              end              
          end
        else
          begin
          operSum = operSum;
          Sum[14:10] = Sum[14:10];
          flag = 1'b1;
          end
    end
  end 

// rounding function based on IEEE standards after normalising
if (operSum[2] == 1'b1)
  opersum1 = operSum[14:3] + 1'b1;
else
  opersum1 = operSum[14:3];
  
  //normalising function after rounding
 if (opersum1[11] == 1'b1)
   begin
    if(flaginf != 1)    
     begin
     opersum2 = opersum1[11:1];
     Sum[14:10] = Sum[14:10] + 1'b1; 
     end 
    else
     begin
     opersum2 = opersum1[10:0];
     Sum[14:10] = Sum[14:10];
     end
   end
 else
   begin
    opersum2 = opersum1[10:0];
    Sum[14:10] = Sum[14:10];
   end
 
 // assign mantissa to the sum
 if (flaginf != 1'b1)
   begin
     Sum[9:0] = opersum2[9:0];
   end
 else
   begin
     Sum[9:0] = 10'h0;
   end
      
// if both elements are of same sign assign the sign to sum
 if(A[15] == B[15])
   begin
   Sum[15] = A[15];
   end
 end  
 end

endmodule  

`timescale 1ns/1ps
module t_vaddtest();
  
  wire [15:0] Sum;
  //wire [14:0] V1,I1,I2;
  //wire [11:0] V2;
 // wire [10:0] V3;
  //wire [1:0] op;
  wire Ov;
  reg [15:0] In1,In2;
/*V1,V2,V3,I1,I2,*/
  
  VADD adder1(Sum,Ov,In1,In2);
  
  initial begin
    In1 = 16'b0100100010010000;
    In2 = 16'b0100000101010101;
    
   #10  In1 = 16'b0101001100111010;
    In2 = 16'b0101001100111010; 
    
   #10  In1 = 16'b0001011001100100;
    In2 = 16'b1000111100110000; 

   #10  In1 = 16'b0011100000000000;
    In2 = 16'b1011010000000000; 

   #10  In1 = 16'b0000111100000000;
    In2 = 16'b1001011110000000; 
    
   #10  In1 = 16'b0011111100000000;
    In2 = 16'b1011110100000000; 
    
  #10  In1 = 16'b0011111100000000;
    In2 = 16'b0010101110010001; 
    
  #10  In1 = 16'b0011100000000000;
   In2 = 16'b0000000111100101;
   
  #10  In1 = 16'b0111111100000000;
   In2 = 16'b0000000111100101;

  #10  In1 = 16'b011110100000000;
   In2 = 16'b0011010111100101;
   
     #10  In1 = 16'b0111101000000000;
   In2 = 16'b0111101011110010;
   
  #10  In1 = 16'b0111101000000000;
   In2 = 16'b0111011011110010;
   end
endmodule

