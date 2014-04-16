module VMULT(output reg[15:0] product, output reg Overflow,input [15:0] A, input [15:0] B);
  reg [21:0] binary_prod;
  reg [10:0] operA, operB;
  wire [10:0]  operA1, operB1, operA0, operB0;
  reg [11:0]  mantissa;
  reg [5:0]  exponent;
  integer i;
  reg found_first_one;

  //append normalized one
  assign operA1 = {1'b1,A[9:0]};
  assign operB1 = {1'b1,B[9:0]};
  assign operA0 = {1'b0,A[9:0]};
  assign operB0 = {1'b0,B[9:0]};

  always @(A, B) begin
    //Append a 1 or 0 to mantissa based on exponent
    if((A[14:10] == 5'h0) && (B[14:10] == 5'h0)) begin 
      operA = operA0;
      operB = operB0;
      exponent = 5'b00001;
    end
    else if (A[14:10] == 5'h0) begin
      operA = operA0;
      operB = operB1;
      exponent = A[14:10] + B[14:10] - 14;
    end
    else if(B[14:10] == 5'h0) begin
      operA = operA1;
      operB = operB0;
      exponent = A[14:10] + B[14:10] - 14;
    end
    else begin
      operA = operA1;
      operB = operB1;
      exponent = A[14:10] + B[14:10] - 15;
    end //End Append to mantissa

    //Multiple mantissa
    binary_prod = operA*operB;

    //Shift binary product to normalized form, round, correct exponent
    found_first_one = 1'b0;
    //If 2 bits before '.'
    if(binary_prod[21]) begin
      exponent = exponent + 1;
      //Assign pre rounded mantissa
      mantissa = {1'b0,binary_prod[21:11]};
    end//End 2 bits before mantissa check

    //MSB is 0, determine where first 1 occurs, shift exponent accordingly
    else begin
      //Shift out guarenteed 0 MSB and subtract exponent
      binary_prod = binary_prod << 1'b1;
      //Find first 1	  
      for(i = 0; i < 21; i = i + 1) begin
        //First 1 has not been found
        if(~found_first_one) begin
          //Bit 21 is a 1, stop search
          if(binary_prod[21]) begin
            found_first_one = 1'b1;
            mantissa = {1'b0,binary_prod[21:11]};
            binary_prod = binary_prod;
            exponent = exponent;
          end
          //shift and search again
          else begin
            binary_prod = binary_prod << 1'b1;
            found_first_one = 1'b0;
            mantissa = 12'b0;
            exponent = exponent - 1;
          end
        end
        //First one has been found
        else begin
          found_first_one = 1'b1;
          binary_prod = binary_prod;
          mantissa = mantissa;
          exponent = exponent;
        end
      end//End for loop shift
    end //End MSB is 0 check

    //round based on bit 10 and what follows
    if (binary_prod[10]) begin
      //Following bits are > 0, round up
      if(binary_prod[9:0]) begin
        mantissa = mantissa + 1;
        //If MSB of mantissa is 1 then shift exponent and mantissa
        if(mantissa[11]) begin
          exponent = exponent + 1;
          mantissa = {1'b0, mantissa[11:1]};
        end
        else begin
          mantissa = mantissa;
          exponent = exponent;
        end
      end
      //All of the following bits are 0
      else begin
        //Last bit of mantissa is odd, add one to make it even
        if(binary_prod[9]) begin
          mantissa = mantissa + 1;
          //If MSB of mantissa is 1 then shift exponent and mantissa
          if(mantissa[11]) begin
            exponent = exponent + 1;
            mantissa = {1'b0, mantissa[11:1]};
          end
          else begin
            mantissa = mantissa;
            exponent = exponent;
          end
        //Last bit of mantissa is even, do nothing
        end else begin
          mantissa = mantissa;
          exponent = exponent;
        end
      end
    end
    //Round bit is 0, do nothing
    else begin 
      mantissa = mantissa;
      exponent = exponent;
    end
    //Check overflow
    if(exponent > 30) begin
      exponent = 6'b111111;
      mantissa = 12'b0;
      Overflow = 1'b1;
    end
    else begin
      exponent = exponent;
      mantissa = mantissa;
      Overflow = 1'b0;
    end
  //Cooncatinate final answer
  product = {(A[15]^B[15]), exponent[4:0], mantissa[9:0]};
  end//End always@(A, B)

endmodule

module t_VMULT();
  reg [15:0] A, B;
  wire [15:0] prod;
  wire ovf;

  VMULT uut(prod, ovf, A, B);

  initial $monitor("A:%b B:%b Product:%h Overflow:%b", A, B, prod, ovf);
  initial begin
    A = 16'b0011110000000000;
    B = 16'b0011110000000000;
    #10;
    A = 16'b1011110000000000;
    B = 16'b0011110000000000;
    #10;
    A = 16'b1011110000000000;
    B = 16'b1011110000000000;
    #10;
    A = 16'b0100001010101010;
    B = 16'b0011001011011110;
    #10;
    A = 16'b0100001010101010;
    B = 16'b0011001011011110;
    #10;
    A = 16'b1100001010101010;
    B = 16'b0011001011011110;
    #10;
    A = 16'b0111101010101010;
    B = 16'b0111101011011110;
    #10;
    A = 16'b0100000010000000;
    B = 16'b0011110010000000;
    #10;
    A = 16'b0100000010000000;
    B = 16'b0000001000000001; //expect 0482
    #10;
    A = 16'b0011110010000000; //this case does not work properly
    B = 16'b0000001000000001; //expect 0241
    #10;
    A = 16'b0100000010000000; //this case does not work properly
    B = 16'b0000000000010001; //expect 0026
    #10;
    $finish;
  end
endmodule
