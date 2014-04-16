module SMUL16(output reg [255:0] product,output reg Ovf, input [15:0] scalar,input [255:0] vecin);

SMUL(product[255:240],Ovf,scalar[15:0], vecin[255:240]);
SMUL(product[239:224],Ovf,scalar[15:0], vecin[239:224]);
SMUL(product[223:208],Ovf,scalar[15:0], vecin[223:208]);
SMUL(product[207:192],Ovf,scalar[15:0], vecin[207:192]);
SMUL(product[191:176],Ovf,scalar[15:0], vecin[191:176]);
SMUL(product[175:160],Ovf,scalar[15:0], vecin[175:160]);
SMUL(product[159:144],Ovf,scalar[15:0], vecin[159:144]);
SMUL(product[143:128],Ovf,scalar[15:0], vecin[143:128]);
SMUL(product[127:112],Ovf,scalar[15:0], vecin[127:112]);
SMUL(product[111:96],Ovf,scalar[15:0], vecin[111:96]);
SMUL(product[95:80],Ovf,scalar[15:0], vecin[95:80]);
SMUL(product[79:64],Ovf,scalar[15:0], vecin[79:64]);
SMUL(product[63:48],Ovf,scalar[15:0], vecin[63:48]);
SMUL(product[47:32],Ovf,scalar[15:0], vecin[47:32]);
SMUL(product[31:16],Ovf,scalar[15:0], vecin[31:16]);
SMUL(product[15:0],Ovf,scalar[15:0], vecin[15:0]);

endmodule

module t_SMUL();
  
  wire [255:0] pro;
  
  reg [255:0] vec1;
  reg [15:0] s1;
  
  SMUL16 S1(pro,s1,vec1);
  
  initial begin
    s1 = 16'hA;
    vec1 = 256'h00010203;
    #10 vec1 = 256'h00020304;
    #20 vec1 = 256'h0406080a;
end
endmodule

module SMUL(output reg [15:0] prod,output reg Overflow,input [15:0] A, input [15:0] B);
  
  reg [11:0] operA,operB;
  wire [11:0] operA1,operB1,operA2,operB2;
  reg [23:0] operprod;
  reg [9:0] operprod1;
  reg [11:0] operprod2;
  reg [5:0] i = 6'b000000;
  reg [5:0] j = 4'b0000;
  reg [1:0] oper;
  reg flag;
  reg flaginf;
  reg [6:0] temp_exp;
  
  //append sticky and guard bit along with normalised one
  assign operA1 = {1'b0,1'b1,A[9:0]};
  assign operB1 = {1'b0,1'b1,B[9:0]}; 
  assign operA2 = {2'b0,A[9:0]};
  assign operB2 = {2'b0,B[9:0]};
  
  //perform floating point multiplication
  always @(*)
  //check if any number is infinity if so make the product equal to infinity
  begin
  if((A[14:10] == 5'h1F) || (B[14:10] == 5'h1F))
  begin
     if (A[14:10] == 5'h1F) 
       begin
         prod = {A[15],A[14:10],10'h0};
         Overflow = 1'b1;
       end
     else 
       begin
         prod = {B[15],B[14:10],10'h0};
         Overflow = 1'b1;
       end
  end
  //based on whether the number is normalised or denormalised build the inputs for the multiplication
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
  
  //calculate temp exponent
  temp_exp = A[14:10]+B[14:10]- 4'hf;
  
  //calculate the product of two 11 bit numbers
  operprod = operA*operB;
  
  
  // if temp_exp is greater than 31 it is a denormalised number
  if (temp_exp > 5'h1e)
    begin
       prod[15] = A[15] ^ B[15];
       prod[14:10] = 5'd31;
       prod[9:0] = 10'h0;
    end
    
  // if the last bit is set do the following
  else
    begin
    if(operprod[21] == 1'b1)
    begin
    if (temp_exp > 5'h1d)
      begin
        prod[15] = A[15] ^ B[15];
        prod[14:10] = 5'd31;
        prod[9:0] = 10'h0;
      end
    else
      begin
        prod[15] = A[15] ^ B[15];
        //rounding off logic
          if(operprod[10] == 1'b1 && operprod[11] == 1'b1)
            begin
              operprod2 = operprod[21:11]+1;
            end
          else
            begin
              operprod2 = operprod[21:11];
            end
          // exponent reassign and normalise after rounding
          if(operprod2[11] == 1'b1 && temp_exp < 5'h1d)
            begin
              prod[14:10] = temp_exp+2;
              operprod1[9:0] = operprod2[10:1];
              Overflow = 1'b0;
            end
           else if((operprod2[11] == 1'b1 && temp_exp == 5'h1d)||(operprod2[10] == 1'b1 && temp_exp == 5'h1e))
            begin
              prod[14:10] = 5'd31;
              operprod1[9:0] = 10'h1;
              Overflow = 1'b0;
            end         
           else        
            begin
              prod[14:10] = temp_exp+1;
              operprod1[9:0] = operprod2[9:0];
              Overflow = 1'b0;
            end 
          end
        end
        
     // if 21st bit of product is 1
     else if(operprod[20] == 1'b1)
      begin
        prod[15] = A[15] ^ B[15];
        //rounding off logic
          if(operprod[10] == 1'b1 && operprod[9] == 1'b1)
            begin
              operprod2 = operprod[19:10]+1;
            end
          else
            begin
              operprod2 = operprod[19:10];
            end
          // exponent reassign and normalise after rounding
          if(operprod2[11] == 1'b1 && temp_exp < 5'h1e)
            begin
              prod[14:10] = temp_exp+1;
              Overflow = 1'b0;
              operprod1[9:0] = operprod2[10:1];
            end
           else if(operprod2[11] == 1'b1 && temp_exp == 5'h1e)
            begin
              prod[14:10] = 5'd31;
              Overflow = 1'b1;
              operprod1[9:0] = 10'h0;
            end
          else
            begin
              prod[14:10] = temp_exp;
              operprod1[9:0] = operprod2[9:0];
              Overflow = 1'b0;
            end
          end
          
    // if a denormalised number is a part of input for multiplication
    else
      begin
        flag =1'b0;
        flaginf = 1'b0;
        Overflow = 1'b0;
        for(j=0;j<22;j=j+1)
          begin
            if((operprod[20])== 1'b0)
              begin
                if(flag == 1'b0)
                  begin
                    operprod = operprod << 1'b1;
                    temp_exp = temp_exp - 1'b1; 
                  end
                else
                  begin
                    operprod = operprod;
                    temp_exp = temp_exp;
                  end              
                end
            else
              begin
                operprod = operprod;
                temp_exp = temp_exp;
                flag = 1'b1;
              end
         end
            // calculating the sign
           prod[15] = A[15] ^ B[15];
           //rounding off logic
          if(operprod[10] == 1'b1 && operprod[9] == 1'b1)
            begin
              operprod2 = operprod[19:10]+1;
            end
          else
            begin
              operprod2 = operprod[19:10];
            end
          // exponent reassign and normalise after rounding
          if(operprod2[11] == 1'b1 && temp_exp < 5'h1e)
            begin
              prod[14:10] = temp_exp+1;
              Overflow = 1'b0;
              operprod1[9:0] = operprod2[10:1];
            end
          else
            begin
              prod[14:10] = temp_exp;
              operprod1[9:0] = operprod2[9:0];
              Overflow = 1'b0;
            end
       end
      prod[9:0] = operprod1;
        
      end  
      end
    end
    endmodule
            
            
module t_SMUL();
  
  wire [15:0] prd;
  wire ov;
  //wire [6:0] ex;
  reg [15:0] vect;
  reg [15:0] sa;
  
  SMUL1 S1(prd,ov,sa,vect);
  
  initial begin
    sa = 16'h0140;
    vect = 16'h64C3;
end
endmodule            
      
   
    