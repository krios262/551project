/*output reg [14:0] operSum,output reg [11:0] opersum1,output reg [10:0] opersum2,output reg [14:0] operA,output reg [14:0] operB,*/
module VADD(output reg [15:0] Sum,output reg Overflow,input [15:0] A, input [15:0] B);
  
  reg [14:0] operA,operB;
  wire [14:0] operA1,operB1,operA2,operB2;
  reg [14:0] operSum;
  reg [11:0] opersum1;
  reg [10:0] opersum2;
  reg [4:0] DiffE;
  reg [5:0] i;
  reg [5:0] j;
  reg [1:0] oper;
  reg flag;
  reg flaginf;
  
  //append sticky and guard bit along with normalised one
  assign operA1 = {1'b0,1'b1,A[9:0],3'b000};
  assign operB1 = {1'b0,1'b1,B[9:0],3'b000}; 
  assign operA2 = {2'b0,A[9:0],3'b000};
  assign operB2 = {2'b0,B[9:0],3'b000};
  
  //perform floating point addition
  always @(*)begin
  //Check for overflow numbers
  if((A[14:10] == 5'h1F) || (B[14:10] == 5'h1F))begin
    if (A[14:10] == 5'h1F) 
      begin
        Sum = {A[15],A[14:10],10'h0};
        Overflow = 1'b1;
      end
    else begin
      Sum = {B[15],B[14:10],10'h0};
      Overflow = 1'b1;
    end
  end//End overflow check

  //Perform addition
  else begin 
    //Choose proper normalized or denormalized expansion
    if((A[14:10] == 5'h0) && (B[14:10] == 5'h0)) begin 
      operA = operA2;
      operB = operB2;
    end
    else if (A[14:10] == 5'h0)begin
      operA = operA2;
      operB = operB1;
    end
    else if(B[14:10] == 5'h0) begin
      operA = operA1;
      operB = operB2;
    end
    else begin
      operA = operA1;
      operB = operB1;
    end //End norm denorm append
   
    //if exponent of A > B    
    if (A[14:10] > B[14:10]) begin
      DiffE=A[14:10]-B[14:10];//calculate the difference in exponent
      
      //Shift operB
      for(i=0;i<32;i=i+1) begin
        if(DiffE >0) begin
          //Check sticky bit
          if(operB[0] == 1'b1) begin
              operB = {1'b0,(operB[14:2]),1'b1}; // adjust the mantissa
              DiffE = DiffE-1'b1;
          end
          else begin
            operB = operB >> 1;
            DiffE = DiffE -1'b1 ;
          end
        end //End DiffE > 0
        //Shift is complete
        else begin
          operB = operB;
          DiffE = DiffE;
        end
      end //End operB shift
      //assign final sum exponent with A since it was larger
      Sum[15:10]= A[15:10];
    end

  //if exponent of B > A
  else if (B[14:10] > A[14:10]) begin
      DiffE=B[14:10]-A[14:10];//calculate the difference in exponent
      //Shift operA
      for(i=0;i<32;i=i+1) begin
        if(DiffE >0) begin
          //Check sticky bit
          if(operA[0] == 1'b1) begin
            operA = {1'b0,(operA[14:2]),1'b1}; // adjust the mantissa
            DiffE = DiffE-1'b1;
          end
          else begin
            operA = operA >> 1'b1;
            DiffE = DiffE -1'b1;
          end
        end
        else begin
          operA = operA;
          DiffE = DiffE;
        end
      end//End for loop shift operA 

      //assign the B exponent to the sum since it was larger
      Sum[15:10]= B[15:10];       
    end //End exponent B > A

  // if exponents are equal 
  else begin
    DiffE = 4'b0;
    operA = operA; 
    operB = operB; // no changes to A and B
    Sum[14:10] = A[14:10];// assign exponent value to output
    if(operA > operB) begin
      Sum[15] = A[15];// assign sign to output based on magnitude of A and B
    end
    else begin
      Sum[15] = B[15];// assign sign to output
    end      
  end//End exponents are equal

  // based on sign of the elements perform the mathematical operation
  // if sign is same perform addition
  if(A[15] == B[15]) begin
    operSum = operA + operB;
    oper = 2'b01;
  end
  // if val A > B
  else if (operA > operB) begin
    operSum = operA - operB;
    oper = 2'b10;
  end
  // if val of B > A
  else if (operB > operA) begin
    operSum = operB - operA;
    oper = 2'b11;
  end
  // if A == B and sign is opposite the answer is 0
  else begin
    operSum = 15'h0;
    oper = 2'b00;
  end //End mathematical operation

  // normalising for sum
  //Got a carry out of 1 and exponent needs to be shifted
  if(operSum[14] == 1'b1) begin
    //If exponent is not 30, shift mantissa and add 1 to exponent
    if(Sum[14:10] != 5'h1E) begin
      operSum = operSum >> 1'b1;
      Sum[14:10] = Sum[14:10] + 1'b1;
      flaginf = 1'b0; 
      Overflow = 1'b0;
    end
    //Exponent is at max of 30, we can't represent 31, so its infinty
    else begin
      operSum = operSum;
      Sum[14:10] = 5'h1F;
      flaginf = 1'b1;
      Overflow = 1'b1;
    end
  end //End carry out of 1
  
  //MSB of sum is 0    
  else begin
    flag =1'b0;
    flaginf = 1'b0;
    Overflow = 1'b0;
    //shift mantiss til a 1 is hit
    for(j=0;j<14;j=j+1) begin
      //MSB is 0
      if(~operSum[13]) begin
        //Check if flag that we are done is not set
        if(~flag) begin
          //Check if exponent is as low as it can go, don't shift
          if((Sum[14:10] == 5'h0)) begin
            operSum = operSum;
            Sum[14:10] = 5'h0;
          end
          //Exponent can go lower, shift mantissa and exponent
          else begin             
            operSum = operSum << 1'b1;
            Sum[14:10] = Sum[14:10] - 1'b1;
          end 
        end
        //Flag has been set that we are done
        else begin
          operSum = operSum;
          Sum[14:10] = Sum[14:10]; 
        end              
      end //End MSB is 0

      //MSB is 1
      else begin
        //Set done flag to stop shifting
        operSum = operSum;
        flag = 1'b1;
        //Exponent is 0, change it back to 1
        if (Sum[14:10] == 5'h0) begin
          Sum[14:10] = 5'h1;
        end
        //Exponent is not zero
        else begin
          Sum[14:10] = Sum[14:10];
        end
      end //End MSB is 1
    end //End for loop
  end //End MSB of sum is 0

  // rounding function based on IEEE standards after normalising
  //Need to round
  if (operSum[2]) begin
    //Round up
    if (operSum[1:0])
      opersum1 = operSum[14:3] + 1'b1;
    //Round to even
    else begin
      //LSB is 1, therefore round to 0 by adding 1
      if (operSum[3])
        opersum1 = operSum[14:3] + 1'b1;
      //LSB is 0, therefore don't need to round
      else
        opersum1 = operSum[14:3];
    end
  end
  //Don't need to round
  else begin
    opersum1 = operSum[14:3];
  end //End rounding

  //normalising function after rounding
  //Got a carry out
  if (opersum1[11] == 1'b1) begin
    //Exponent has room to grow
    if(~flaginf) begin
      opersum2 = opersum1[11:1];
      Sum[14:10] = Sum[14:10] + 1'b1; 
    end 
    //Already at infinity
    else begin
      opersum2 = opersum1[10:0];
      Sum[14:10] = Sum[14:10];
    end
  end
  //Didn't get a carry out
  else begin
    opersum2 = opersum1[10:0];
    Sum[14:10] = Sum[14:10];
  end //End post round normalize
 
  // assign mantissa to the sum
  //Hit infinity
  if (flaginf != 1'b1) begin
    Sum[9:0] = opersum2[9:0];
  end
  //Didn't hit infinity 
  else begin
    Sum[9:0] = 10'h0;
  end
 end//End Addition step  
 end//End always

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
  initial $monitor("A:%h B:%h Sum:%h Ovf:%b", In1, In2, Sum, Ov);
  initial begin
    In1 = 16'b0011101100110011;
    In2 = 16'b0010100111001001;
    
   #10  In1 = 16'b0000111101110011;
        In2 = 16'b1000111100110010; 
    
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
   $finish;
   end
endmodule

