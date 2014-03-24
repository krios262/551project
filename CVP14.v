module CVP14(output [15:0] Addr, output RD, output WR, output V, output U,
    output [15:0] DataOut, input Reset, input Clk1, input Clk2, input [15:0] DataIn);

  //Parameters for opcodes
  parameter vadd = 4'b0000, vdot = 4'b0001, smul = 4'b0010, sst = 4'b0011, vld = 4'b0100,
            vst = 4'b0101,  sll = 4'b0110,  slh = 4'b0111,  j = 4'b1000,   nop = 4'b1111;

  reg [255:0] vOutP, vInP;
  reg [15:0] sOut, sIn, vOutS, vInS;
  reg [2:0] sAddr, vAddr;
  reg sRD, sWR, sWR_l, sWR_h, vWR_p, vWR_s, vRD_p, vRD_s;
          
  //Scalar and Vector registers
  sReg scalar(.DataOut(sOut), .Addr(sAddr), .Clk1(Clk1), .Clk2(Clk2), .DataIn(sIn), 
              .RD(sRD), .WR(sWR), .WR_l(sWR_l), .WR_h(sWR_h));
  vReg vector(.DataOut_p(vOutP), .DataOut_s(vOutS), .Addr(vAddr), .Clk1(Clk1), .Clk2(Clk2),
              .DataIn_p(vInP), .DataIn_s(vInS), .WR_p(vWR_p), .RD_p(vRD_p), .WR_s(vWR_s),
              .RD_s(vRD_s)); 

  //Decode the data to branch to the proper operation
  always @(DataIn) begin
    /*
    case (DataIn[15:12])
      vadd:
      vdot:
      smul:
      sst:
      vld:
      vst:
      sll:
      slh:
      j:
      nop:
    endcase
    */
  end//End Opcode decode

  //Overflow/underflow condition
  always @(U, V) begin
  
  end//End overflow/underflow
endmodule
