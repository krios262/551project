module CVP14(output reg [15:0] Addr, output reg RD, output reg WR, output reg V,
    output reg [15:0] DataOut, input Reset, input Clk1, input Clk2, input [15:0] DataIn);

  //Parameters for opcodes
  parameter vadd = 4'b0000, vdot = 4'b0001, smul = 4'b0010, sst = 4'b0011, vld = 4'b0100,
            vst = 4'b0101,  sll = 4'b0110,  slh = 4'b0111,  j = 4'b1000,   nop = 4'b1111;

  //Parameters for states
  parameter newPC = 3'b000, fetchInst = 3'b001, startEx = 3'b010, executing = 3'b011,
            done = 3'b100, start = 3'b111;

  reg  [255:0] vInP;
  wire [255:0] vOutP, vOutP2;
  reg  [15:0]  sIn, vInS;
  wire [15:0]  vOutS, vOutS2, sOut;
  reg  [2:0]   sAddr, vAddr, vAddr2;
  reg sRD, sWR, sWR_l, sWR_h, vWR_p, vWR_s, vRD_p, vRD_s;

  reg [15:0] PC; //program counter
  reg [15:0] instruction;

  reg [2:0] state, nextState;

  //Scalar and Vector registers
  sReg scalar(.DataOut(sOut), .Addr(sAddr), .Clk1(Clk1), .Clk2(Clk2), .DataIn(sIn),
              .RD(sRD), .WR(sWR), .WR_l(sWR_l), .WR_h(sWR_h));
  vReg vector(.DataOut_p(vOutP), .DataOut_s(vOutS), .Addr(vAddr), .Clk1(Clk1), .Clk2(Clk2),
              .DataIn_p(vInP), .DataIn_s(vInS), .WR_p(vWR_p), .RD_p(vRD_p), .WR_s(vWR_s),
              .RD_s(vRD_s), .DataOut2_p(vOutP2), .DataOut2_s(vOutS2), .Addr2(vAddr2));

  //Operation modules

  always@(posedge Clk1) begin
    //Addresses and state are set on Clk1
    if (Reset)
      state <= start;
    else
      state <= nextState;

    case (nextState)

      start: begin
        //No action on Clk1
      end

      newPC: begin
        Addr <= PC;
      end

      fetchInst: begin
        //No action on Clk1
      end

      startEx: begin

        case (instruction[15:12])
          /*vadd:
          vdot:
          smul:
          sst:
          vld:
          vst:*/
          sll:
          begin
            sAddr <= instruction[11:9];
          end
          slh:
          begin
            sAddr <= instruction[11:9];
          end
          //j:
          //nop:
        endcase

      end

      executing: begin
        //No action for current ops (SLL and SLH)
      end

      done: begin
        //No action on Clk1
      end

    endcase

  end //always

  always@(posedge Clk2) begin
    //RD/WR flags, instruction, PC, data inputs are set on Clk2
    //Data outputs are read on Clk2

    case (state)

      start: begin
        PC <= 16'h0000;
        RD <= 1'b0;
        WR <= 1'b0;
        sWR_l <= 1'b0;
        sWR <= 1'b0;
        sWR_h <= 1'b0;
        sRD <= 1'b0;
      end

      newPC: begin
        RD <= 1'b1;
      end

      fetchInst: begin
        RD <= 1'b0;
        instruction <= DataIn;
      end

      startEx: begin

        case (instruction[15:12])
          /*vadd:
          vdot:
          smul:
          sst:
          vld:
          vst:*/
          sll:
          begin
            sIn   <= {sIn[15:8],instruction[7:0]};
            sWR_l <= 1'b1;
          end
          slh:
          begin
            sIn   <= {instruction[7:0],sIn[7:0]};
            sWR_h <= 1'b1;
          end
          //j:
          //nop:
        endcase

      end

      executing: begin

      end

      done: begin
        sWR_l <= 1'b0;
        sWR_h <= 1'b0;
        PC <= PC + 1;
      end
    endcase

  end

  always @(state, instruction) begin

    case (state)

      start: begin
        nextState = newPC;
      end

      newPC: begin
        nextState = fetchInst;
      end

      fetchInst: begin
        nextState = startEx;
      end

      startEx: begin

        case (instruction[15:12])
          /*vadd:
          vdot:
          smul:
          sst:
          vld:
          vst:*/
          sll:
          begin
            nextState = done;
          end
          slh:
          begin
            nextState = done;
          end
          //j:
          //nop:
          default:
            nextState = done;
        endcase

      end

      executing: begin
        nextState = done; //modify when adding more inst
      end

      done: begin
        nextState = newPC;
      end

      default: begin
        nextState = 3'bx;
      end
    endcase

  end //combinational block

  //Overflow condition
  always @(V) begin

  end//End overflow
endmodule
