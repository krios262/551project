//Pipeline VADD
module VADDp(output [15:0] Sum,output Overflow,input [15:0] A, input [15:0] B, 
             input Clk2);

  reg [15:0] pre_sum;
  wire [15:0] pre_sum_pipe;
  reg [14:0] pre_operSum;
  wire [14:0] pre_operSum_pipe;
  reg Ov1;
  wire Ov1_pipe;
  reg Ov2;
  wire Ov2_pipe;

  pre_norm_sum preADD(.Sum(pre_sum_pipe), .operSum(pre_operSum_pipe), 
                      .Overflow(Ov1_pipe), .A(A), .B(B));
  norm_round_sum_final finalADD(.pre_sum(pre_sum), .pre_operSum(pre_operSum), 
                                .Ovf(Ov2_pipe), .final_sum(Sum));

  assign Overflow = Ov2 | Ov1;

  always@(posedge Clk2) begin
    Ov1 <= Ov1_pipe;
    Ov2 <= Ov2_pipe;
    pre_sum <= pre_sum_pipe;
    pre_operSum <= pre_operSum_pipe;
  end

endmodule

module pre_norm_sum(output reg [15:0] Sum, output reg [14:0] operSum, output reg Overflow, 
                    input [15:0] A, input [15:0] B);
  reg [14:0] operA,operB;
  wire [14:0] operA1,operB1,operA2,operB2;
  reg [4:0] DiffE;  
  reg [5:0] i;
  //append sticky and guard bit along with normalised one
  assign operA1 = {1'b0,1'b1,A[9:0],3'b000};
  assign operB1 = {1'b0,1'b1,B[9:0],3'b000}; 
  assign operA2 = {2'b0,A[9:0],3'b000};
  assign operB2 = {2'b0,B[9:0],3'b000};
  
  //perform floating point addition
  always @(A, B)begin
    //Check for overflow numbers
    if((A[14:10] == 5'h1F) || (B[14:10] == 5'h1F))begin
      operSum = 15'h0;
      Overflow = 1'b1;
      if (A[14:10] == 5'h1F) begin
        Sum = {A[15],A[14:10],10'h0};
      end
      else begin
        Sum = {B[15],B[14:10],10'h0};
      end
    end//End overflow check

    //Perform addition
    else begin
    Overflow = 1'b0; 
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
        Sum = {A[15:10], 10'h0};
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
        Sum = {B[15:10], 10'h0};       
      end //End exponent B > A

      // if exponents are equal 
      else begin
        DiffE = 4'b0;
        operA = operA; 
        operB = operB; // no changes to A and B
        if(operA > operB) begin
          Sum = {A[15:10], 10'h0};// assign sign to output based on magnitude of A and B
        end
        else begin
          Sum = {B[15:10],10'h0};// assign sign to output
        end      
      end//End exponents check

      // based on sign of the elements perform the mathematical operation
      // if sign is same perform addition
      if(A[15] == B[15]) begin
        operSum = operA + operB;
      end
      // if val A > B
      else if (operA > operB) begin
        operSum = operA - operB;
      end
      // if val of B > A
      else if (operB > operA) begin
        operSum = operB - operA;
      end
      // if A == B and sign is opposite the answer is 0
      else begin
        operSum = 15'h0;
      end //End mathematical operation
    end //End Else not infinity
  end //End Always
endmodule//End pre_norm_sum

//Normalize a raw sum, round it, normalize again, and give final Sum in half point float
module norm_round_sum_final(input [15:0] pre_sum, input [14:0] pre_operSum, output reg Ovf, 
                            output reg [15:0] final_sum);
  reg [14:0] operSum;
  reg [15:0] Sum;
  reg [11:0] opersum1;
  reg [10:0] opersum2;
  reg [5:0] j;
  reg flag;
  reg flaginf;
  reg Overflow;

  always@(pre_sum, pre_operSum) begin
    operSum = pre_operSum;
    Sum = pre_sum;
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
    //Didnt Hit infinity
    if (flaginf != 1'b1) begin
      Sum[9:0] = opersum2[9:0];
    end
    //hit infinity 
    else begin
      Sum[9:0] = 10'h0;
    end 
    //Assign final values
    final_sum = Sum;
    Ovf = Overflow;
  end//End always pre_sum, pre_operSum
endmodule //end norm_round_sum_final

`timescale 1ns/1ps
module t_vaddptest();
  
  wire [15:0] Sum;
  wire Ov;
  reg [15:0] In1,In2;
  reg Clk1, Clk2;
  
  VADDp adder1(Sum,Ov,In1,In2, Clk2);
  initial $monitor("A:%h B:%h Sum:%h Ovf:%b", In1, In2, Sum, Ov);

  initial begin
    Clk1 = 1'b0;
    Clk2 = 1'b1;
    forever begin
      #5; Clk2 = ~Clk2; Clk1 = ~Clk1;
    end
  end
  initial begin
    In1 = 16'b0011101100110011;
    In2 = 16'b0010100111001001;
    
   #15  In1 = 16'b0000111101110011;
        In2 = 16'b1000111100110010; 
    
   #15  In1 = 16'b0001011001100100;
    In2 = 16'b1000111100110000; 
   
   #15  In1 = 16'b0011100000000000;
    In2 = 16'b1011010000000000; 

   #15  In1 = 16'b0000111100000000;
    In2 = 16'b1001011110000000; 
    
   #15  In1 = 16'b0011111100000000;
    In2 = 16'b1011110100000000; 
    
  #15 In1 = 16'b0011111100000000;
    In2 = 16'b0010101110010001; 
    
  #15  In1 = 16'b0011100000000000;
   In2 = 16'b0000000111100101;
   
  #15  In1 = 16'b0111111100000000;
   In2 = 16'b0000000111100101;

  #15  In1 = 16'b011110100000000;
   In2 = 16'b0011010111100101;
   
     #15  In1 = 16'b0111101000000000;
   In2 = 16'b0111101011110010;
   
  #15  In1 = 16'b0111101000000000;
   In2 = 16'b0111011011110010;
   $finish;
   end
endmodule

