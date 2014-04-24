module CVP14(output [15:0] Addr, output reg RD, output reg WR, output reg V,
    output reg [15:0] DataOut, input Reset, input Clk1, input Clk2, input [15:0] DataIn);

  //Generate parameters
  parameter Pipe_Vdot = 1'b0;
  parameter serial_operation = 1'b1;
  parameter pipe_fp = 1'b1;
  parameter Pipe_SMUL_parallel = 1'b0;

  //Parameters for opcodes
  parameter vadd = 4'b0000, vdot = 4'b0001, smul = 4'b0010, sst = 4'b0011, vld = 4'b0100,
            vst = 4'b0101,  sll = 4'b0110,  slh = 4'b0111,  j = 4'b1000,   nop = 4'b1111;

  //Parameters for states
  parameter newPC = 3'b000, fetchInst = 3'b001, startEx = 3'b010, executing = 3'b011,
            done = 3'b100, overflow = 3'b101, start = 3'b111;

  //register file nets
  reg  [255:0] vInP;
  wire [255:0] vOutP, vOutP2;
  reg  [15:0]  sIn, vInS;
  wire [15:0]  vOutS, vOutS2, sOut;
  reg  [2:0]   sAddr, vAddr, vAddr2;
  reg sRD, sWR, sWR_l, sWR_h, vWR_p, vWR_s, vRD_p, vRD_s;
  reg updatePC, jump, setPC, updateAddr, offsetInc; //addressing module flags

  //addressing nets
  wire [15:0] PC; //program counter
  reg [15:0] instruction;
  wire [3:0] inc_offset;
  reg V_flag;

  reg [2:0] state, nextState;

  //vadd nets
  wire [255:0] AdderOut;
  wire [15:0] AdderOutS;
  wire OvF, addDone, addWrite;
  reg addStart;

  //vdot nets
  wire [15:0] dotOut;
  wire dotV, dotDone;
  reg dotStart;

  //smul nets
  wire [255:0] smulOut;
  wire [15:0] smulOutS;
  wire smulV, smulDone, smulWrite;
  reg smulStart;

  //Scalar and Vector registers
  sReg scalar(.DataOut(sOut), .Addr(sAddr), .Clk1(Clk1), .Clk2(Clk2), .DataIn(sIn),
              .RD(sRD), .WR(sWR), .WR_l(sWR_l), .WR_h(sWR_h));
  generate
    if (serial_operation)
      vRegs vector(.DataOut_s(vOutS), .Addr(vAddr), .Clk1(Clk1), .Clk2(Clk2),
                  .DataIn_s(vInS), .WR_s(vWR_s),
                  .RD_s(vRD_s), .DataOut2_s(vOutS2), .Addr2(vAddr2));
    else
      vReg vector(.DataOut_p(vOutP), .DataOut_s(vOutS), .Addr(vAddr), .Clk1(Clk1), .Clk2(Clk2),
                  .DataIn_p(vInP), .DataIn_s(vInS), .WR_p(vWR_p), .RD_p(vRD_p), .WR_s(vWR_s),
                  .RD_s(vRD_s), .DataOut2_p(vOutP2), .DataOut2_s(vOutS2), .Addr2(vAddr2));
  endgenerate

  //Addressing
  PCunit pcu(.PC(PC), .offset(instruction[11:0]), .Clk2(Clk2), .updatePC(updatePC),
              .jump(jump), .reset(Reset), .overflow(V_flag));
  addrUnit addru(.addr(Addr), .PC(PC), .Clk1(Clk1), .imm_offset(instruction[5:0]),
              .addrBase(sOut), .setPC(setPC), .updateAddr(updateAddr), .inc_offset(inc_offset));
  offsetu osu(.Reset(Reset), .Clk2(Clk2), .offsetInc(offsetInc), .offset(inc_offset));

  //Operation modules
  //VADD generate
  generate
    if (serial_operation)
      VADD16ser adderu(.SumV(AdderOutS), .V(OvF), .A(vOutS), .B(vOutS2), .start(addStart), .write(addWrite),
                         .done(addDone), .Clk1(Clk1), .Clk2(Clk2));
    else
      VADD16 adderu(.SumV(AdderOut), .V(OvF), .A(vOutP), .B(vOutP2), .start(addStart), .done(addDone));
  endgenerate
  //SMULT generates
  generate
    if (serial_operation)
      SMULT16ser smultu(.product(smulOutS), .V(smulV), .scalar(sOut), .vecin(vOutS), .Clk1(Clk1), .Clk2(Clk2),
                    .start(smulStart), .write(smulWrite), .done(smulDone));
    else if(Pipe_SMUL_parallel)
      SMULT16p smultu(.product(smulOut), .V(smulV), .scalar(sOut), .vecin(vOutP), .Clk1(Clk1), .Clk2(Clk2),
                    .start(smulStart), .done(smulDone));
    else
      SMULT16 smultu(.product(smulOut), .V(smulV), .scalar(sOut), .vecin(vOutP), .start(smulStart), .done(smulDone));
  endgenerate
  //VDOT generates
  generate
    if (serial_operation)
      VDOT16s vdotmulu(.out(dotOut), .V(dotV), .A(vOutS), .B(vOutS2), .start(dotStart), .Clk1(Clk1), .Clk2(Clk2),
                        .done(dotDone));
    else if (Pipe_Vdot)
      VDOT16p vdotmulu(.out(dotOut), .V(dotV), .A(vOutP), .B(vOutP2), .start(dotStart), .Clk1(Clk1), .Clk2(Clk2),
                        .done(dotDone));
    else
      VDOT16 vdotmulu(.out(dotOut), .V(dotV), .A(vOutP), .B(vOutP2), .start(dotStart), .done(dotDone));
  endgenerate

  always@(posedge Clk1) begin
    //Addresses and state are set on Clk1

    if (Reset) begin
      state <= start;
      updatePC <= 1'b0;
      jump <= 1'b0;
      offsetInc <= 1'b0;
      V <= 1'b0;
      dotStart <= 1'b0;
      smulStart <= 1'b0;
      addStart <= 1'b0;
    end else begin
      state <= nextState;

    case (nextState)

      newPC: begin
        updatePC <= 1'b0;
        jump <= 1'b0;
        offsetInc <= 1'b0;
      end

      fetchInst: begin
        //No action on Clk1
      end

      startEx: begin

        case (instruction[15:12])
          vadd: begin
            vAddr <= instruction[8:6];
            vAddr2 <= instruction[5:3];
          end
          vdot: begin
            sAddr <= instruction[11:9];
            vAddr <= instruction[8:6];
            vAddr2 <= instruction[5:3];
          end
          smul: begin
            sAddr <= instruction[5:3];
            vAddr <= instruction[8:6];
          end
          sst: begin
            sAddr <= instruction[8:6]; //get system mem dest address
          end
          vld: begin
            sAddr <= instruction[8:6]; //get system mem dest address
            vAddr <= instruction[11:9]; //vector store dest
          end
          vst: begin
            sAddr <= instruction[8:6]; //get system mem dest address
            vAddr <= instruction[11:9]; //vector store dest
          end
          sll: begin
            sAddr <= instruction[11:9];
          end
          slh: begin
            sAddr <= instruction[11:9];
          end
          j: begin
            updatePC <= 1'b1;
            jump <= 1'b1;
          end
          nop: begin
            updatePC <= 1'b1;
          end
        endcase

      end

      executing: begin
        case (instruction[15:12])
          vadd: begin
            vAddr <= instruction[11:9];
            addStart <= 1'b1;
          end
          vdot:
            dotStart <= 1'b1;
          smul: begin
            vAddr <= instruction[11:9];
            smulStart <= 1'b1;
          end
          sst:
            sAddr <= instruction[11:9]; //scalar value to be stored
          vld: begin
            if (updateAddr) begin
              offsetInc <= 1'b1;
            end else
              offsetInc <= 1'b0;
          end
          vst: begin
            if (updateAddr) begin
              offsetInc <= 1'b1;
            end else
              offsetInc <= 1'b0;
          end

        endcase
      end

      done: begin
        updatePC <= 1'b1;
        dotStart <= 1'b0;
        smulStart <= 1'b0;
        addStart <= 1'b0;
        case (instruction[15:12])
          vadd:
            V <= V_flag;
          vdot:
            V <= V_flag;
          smul:
            V <= V_flag;
          default:
            V <= V;
        endcase
      end

      overflow: begin
        sAddr <= 3'b111;
      end

    endcase
    end //else

  end //always

  always@(posedge Clk2) begin
    //RD/WR flags, instruction, PC, data inputs are set on Clk2
    //Data outputs are read on Clk2

    vInS <= DataIn;

    if (Reset) begin
      RD <= 1'b0;
      WR <= 1'b0;
      sWR_l <= 1'b0;
      sWR <= 1'b0;
      sWR_h <= 1'b0;
      sRD <= 1'b0;
      vRD_s <= 1'b0;
      vRD_p <= 1'b0;
      vWR_s <= 1'b0;
      vWR_p <= 1'b0;
      setPC <= 1'b1;
      updateAddr <= 1'b0;
      V_flag <= 1'b0;
    end else begin

    case (state)

      newPC: begin
        RD <= 1'b1;
        WR <= 1'b0;
        sWR <= 1'b0;
        V_flag <= 1'b0;
        setPC <= 1'b0;
      end

      fetchInst: begin
        RD <= 1'b0;
        vWR_s <= 1'b0;
        instruction <= DataIn;
      end

      startEx: begin

        case (instruction[15:12])
          vadd: begin
            if (serial_operation)
              vRD_s <= 1'b1;
            else
              vRD_p <= 1'b1;
          end
          vdot: begin
            if (serial_operation)
              vRD_s <= 1'b1;
            else
              vRD_p <= 1'b1;
          end
          smul: begin
            sRD <= 1'b1;
            if (serial_operation)
              vRD_s <= 1'b1;
            else
              vRD_p <= 1'b1;
          end
          sst: begin
            sRD <= 1'b1;
          end
          vld: begin
            sRD <= 1'b1;
          end
          vst: begin
            sRD <= 1'b1;
          end
          sll: begin
            sIn   <= {sIn[15:8],instruction[7:0]};
            sWR_l <= 1'b1;
          end
          slh: begin
            sIn   <= {instruction[7:0],sIn[7:0]};
            sWR_h <= 1'b1;
          end
          j: begin
            setPC <= 1'b1;
          end
          nop: begin
            setPC <= 1'b1;
          end
        endcase

      end

      executing: begin
        case (instruction[15:12])

          vadd: begin
            if (serial_operation) begin
              if (addWrite) begin
                vInS <= AdderOutS;
                vWR_s <= 1'b1;
                V_flag <= OvF;
              end else
                vWR_s <= vWR_s;
            end else begin
              vRD_p <= 1'b0;
              if (addDone) begin
                vInP <= AdderOut;
                vWR_p <= 1'b1;
                V_flag <= OvF;
              end else
                vWR_p <= vWR_p;
            end
          end

          vdot: begin
            if (serial_operation)
              vRD_s <= 1'b1;
            else
              vRD_p <= 1'b0;

            if (dotDone) begin
              sIn <= dotOut;
              sWR <= 1'b1;
              V_flag <= dotV;
            end else
              sWR <= sWR;
          end

          smul: begin
            sRD <= 1'b0;
            if (serial_operation) begin
              vRD_s <= 1'b0;
              if (smulWrite) begin
                vInS <= smulOutS;
                vWR_s <= 1'b1;
                V_flag <= smulV;
              end else
                vWR_s <= vWR_s;
            end else begin
              vRD_p <= 1'b0;
              if (smulDone) begin
                vInP <= smulOut;
                vWR_p <= 1'b1;
                V_flag <= smulV;
              end else
                vWR_p <= vWR_p;
            end
          end

          sst: begin
            //updateAddr on first cycle, do other operations on second
            if (updateAddr) begin
              DataOut <= sOut;
              WR <= 1'b1;
              sRD <= 1'b0;
              updateAddr <= 1'b0;
            end else
              updateAddr <= 1'b1;
          end
          vld: begin
            sRD <= 1'b0;

            if (updateAddr) begin
              RD <= 1'b1;
            end else
              updateAddr <= 1'b1;
            if (RD) begin
              vWR_s <= 1'b1;
            end else
              vWR_s <= 1'b0;
          end
          vst: begin
            sRD <= 1'b0;
            vRD_s <= 1'b1;

            if (updateAddr) begin
              WR <= 1'b1;
              DataOut <= vOutS;
            end else
              updateAddr <= 1'b1;
          end

        endcase
      end

      done: begin
        //do not set RD to 0; it must stay 1 for VLD
        sWR_l <= 1'b0;
        sWR_h <= 1'b0;
        sWR <= 1'b0;
        setPC <= 1'b1;
        vRD_s <= 1'b0;
        updateAddr <= 1'b0;
        vWR_p <= 1'b0;

        case (instruction[15:12]) //for vld, RD persists
          vld: begin
            WR <= 1'b0;
            RD <= RD;
          end
          vst: begin
            WR <= WR;
            RD <= 1'b0;
            DataOut <= vOutS;
          end
          vadd: begin
            vWR_s <= 1'b0;
            WR <= 1'b0;
            RD <= 1'b0;
          end
          smul: begin
            vWR_s <= 1'b0;
            WR <= 1'b0;
            RD <= 1'b0;
          end
          default: begin
            WR <= 1'b0;
            RD <= 1'b0;
          end
        endcase
      end

      overflow: begin
        sWR <= 1'b1;
        sIn <= instruction;
      end
    endcase

    end //reset else

  end //clk2 sequential

  always @(state, instruction, updateAddr, inc_offset, dotDone, addDone, smulDone, V_flag) begin

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
          vadd:
            nextState = executing;
          vdot:
            nextState = executing;
          smul:
            nextState = executing;
          sst:
            nextState = executing;
          vld:
            nextState = executing;
          vst:
            nextState = executing;
          sll:
            nextState = done;
          slh:
            nextState = done;
          j:
            nextState = newPC; //jump does not require the done state
          nop:
            nextState = newPC; //no op does not require the done state
          default:
            nextState = done;
        endcase

      end

      executing: begin

        case (instruction[15:12])
          vadd: begin
            if(addDone)
              nextState = done;
            else
              nextState = executing;
            end
          vdot: begin
            if (dotDone)
              nextState = done;
            else
              nextState = executing;
          end
          smul: begin
            if (smulDone)
              nextState = done;
            else
              nextState = executing;
          end
          sst: begin
            if (updateAddr)
              nextState = executing;
            else
              nextState = done;
          end
          vld: begin
            if (inc_offset[3] & inc_offset [2] & inc_offset[1] & inc_offset[0])
              nextState = done;
            else
              nextState = executing;
          end
          vst: begin
            if (inc_offset[3] & inc_offset [2] & inc_offset[1] & inc_offset[0])
              nextState = done;
            else
              nextState = executing;
          end
          //j:
          //nop:
          default:
            nextState = done;
        endcase

      end

      done: begin
        if (V_flag)
          nextState = overflow;
        else
          nextState = newPC;
      end

      overflow: begin
        nextState = newPC;
      end

      default: begin
        nextState = 3'bx;
      end
    endcase

  end //combinational block

endmodule
