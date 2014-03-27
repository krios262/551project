module CVP14(output reg [15:0] Addr, output reg RD, output reg WR, output reg V,
    output reg [15:0] DataOut, input Reset, input Clk1, input Clk2, input [15:0] DataIn);

  //Parameters for opcodes
  parameter vadd = 4'b0000, vdot = 4'b0001, smul = 4'b0010, sst = 4'b0011, vld = 4'b0100,
            vst = 4'b0101,  sll = 4'b0110,  slh = 4'b0111,  j = 4'b1000,   nop = 4'b1111;

  reg [255:0] vOutP, vOutP2, vInP;
  reg [15:0] sOut, sIn, vOutS, vOutS2, vInS;
  reg [2:0] sAddr, vAddr, vAddr2;
  reg sRD, sWR, sWR_l, sWR_h, vWR_p, vWR_s, vRD_p, vRD_s;
          
  reg [15:0] PC; //program counter
  reg [15:0] instruction;
  reg newPC, getNewInst, readInst;

  //Scalar and Vector registers
  sReg scalar(.DataOut(sOut), .Addr(sAddr), .Clk1(Clk1), .Clk2(Clk2), .DataIn(sIn), 
              .RD(sRD), .WR(sWR), .WR_l(sWR_l), .WR_h(sWR_h));
  vReg vector(.DataOut_p(vOutP), .DataOut_s(vOutS), .Addr(vAddr), .Clk1(Clk1), .Clk2(Clk2),
              .DataIn_p(vInP), .DataIn_s(vInS), .WR_p(vWR_p), .RD_p(vRD_p), .WR_s(vWR_s),
              .RD_s(vRD_s), .DataOut2_p(vOutP2), .DataOut2_s(vOutS2), .Addr2(vAddr2)); 

  //Operation modules

  always@(posedge Clk1) begin
    if (newPC) begin
      Addr <= PC; //Memory reads Addr on clk2, so doing this here avoids violating setup/hold
      newPC <= 1'b0;
      readInst <= 1'b1;
    end
    else begin
      Addr <= Addr;
      newPC <= newPC;
      readInst <= readInst;
    end
  end

  always@(posedge Clk2) begin
    if (Reset)
      PC <= 16'h0000;
    else
      PC <= PC; //TODO is reset code in the right location?

    if (readInst) begin
      RD <= 1'b1;
      readInst <= 1'b0;
      getNewInst <= 1'b1;
    end
    else begin
      RD <= RD;
      readInst <= readInst;
      getNewInst <= getNewInst;
    end

    if (getNewInst) begin
      instruction <= DataIn;
      RD <= 1'b0;
      getNewInst <= 1'b0;
    end
    else begin
      instruction <= instruction;
      RD <= RD;
      getNewInst <= getNewInst;
    end
  end

  //Decode the data to branch to the proper operation
  always @(instruction) begin
    
    getNewInst = 1'b0;

    case (instruction[15:12])
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

    PC = PC + 1; //these 2 should probably go in their own always block
    newPC  = 1'b1; //that activates on module "done" flags
    
  end//End Opcode decode

  //Overflow condition
  always @(V) begin
  
  end//End overflow
endmodule
