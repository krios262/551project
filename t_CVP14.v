//Cvp14 Test Bench
`timescale 1ns/1ns
module t_CVP14();
  wire[15:0] out, in, addr;
  wire r, w, v;
  reg  rst, c1, c2;

  integer i;

  DRAM mem(.DataOut(in), .Addr(addr), .DataIn(out),
    .clk1(c1), .clk2(c2), .RD(r), .WR(w));
  CVP14 UUT(.Addr(addr), .RD(r), .WR(w), .V(v),
    .DataOut(out), .Reset(rst), .Clk1(c1), .Clk2(c2), .DataIn(in));

  initial begin
    c1 = 1'b1; c2 = 1'b0;
    forever begin
      #5;
      c1 = ~c1;
      c2 = ~c2;
      /*
      #2.5; c1 = ~c1; #2.5;
      #2.5; c2 = ~c2; #2.5;
      */
    end
  end

  initial begin
    
    $monitor("%t: State: %d, nextState: %d, Inst: %h, PC: %d, Addr: %h, WR: %b, RD: %b, DataOut: %h, dotStart: %b dotDone: %b, startadd: %b",
            $time, UUT.state, UUT.nextState, UUT.instruction, UUT.PC, 
            UUT.Addr, UUT.WR, UUT.RD, UUT.DataOut, UUT.dotDone, UUT.dotStart, UUT.startadd);
    
    /*
    $monitor("%t: State %b, Inst: %h, Scalar 0: %h, sIn: %h, sAddr: %h, DataIn: %h", $time, UUT.state,
          UUT.instruction, UUT.scalar.scalar[0], UUT.sIn, UUT.sAddr, UUT.DataIn);
    */
  end

  initial begin
    rst = 1'b1;
    #10;
    rst = 1'b0;
    #5500;
    $strobe("V0.0: %h", UUT.vector.vector[0][0]);
    $strobe("V0.1: %h", UUT.vector.vector[0][1]);
    $strobe("V0.2: %h", UUT.vector.vector[0][2]);
    $strobe("V0.3: %h", UUT.vector.vector[0][3]);
    $strobe("V0.4: %h", UUT.vector.vector[0][4]);
    $strobe("V0.5: %h", UUT.vector.vector[0][5]);
    $strobe("V0.6: %h", UUT.vector.vector[0][6]);
    $strobe("V0.7: %h", UUT.vector.vector[0][7]);
    $strobe("V0.8: %h", UUT.vector.vector[0][8]);
    $strobe("V0.9: %h", UUT.vector.vector[0][9]);
    $strobe("V0.10: %h", UUT.vector.vector[0][10]);
    $strobe("V0.11: %h", UUT.vector.vector[0][11]);
    $strobe("V0.12: %h", UUT.vector.vector[0][12]);
    $strobe("V0.13: %h", UUT.vector.vector[0][13]);
    $strobe("V0.14: %h", UUT.vector.vector[0][14]);
    $strobe("V0.15: %h", UUT.vector.vector[0][15]);
    #10;
    $strobe("S0: %h S7: %h", UUT.scalar.scalar[0], UUT.scalar.scalar[7]);
    //write memory contents to text file
    $writememb("dump.txt", mem.Memory);
    #10;
    $finish;
  end
endmodule
