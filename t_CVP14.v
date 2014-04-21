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
    c1 = 1'b0; c2 = 1'b1;
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
    
    $monitor("%t: State: %d, nextState: %d, Inst: %h, PC: %d, Addr: %h, WR: %b, RD: %b, DataOut: %h, dotStart: %b, dotDone: %b, dotWrite: %b, dotOut: %h",
            $time, UUT.state, UUT.nextState, UUT.instruction, UUT.PC, 
            UUT.Addr, UUT.WR, UUT.RD, UUT.DataOut, UUT.dotStart, UUT.dotDone, UUT.dotWrite, UUT.dotOut);
    
    /*
    $monitor("%t: State %b, Inst: %h, Scalar 0: %h, sIn: %h, sAddr: %h, DataIn: %h", $time, UUT.state,
          UUT.instruction, UUT.scalar.scalar[0], UUT.sIn, UUT.sAddr, UUT.DataIn);
    */
  end

  initial begin
    rst = 1'b1;
    #10;
    rst = 1'b0;
    #4500;
    $strobe("V4.0: %h", UUT.vector.vector[4][0]);
    $strobe("V4.1: %h", UUT.vector.vector[4][1]);
    $strobe("V4.2: %h", UUT.vector.vector[4][2]);
    $strobe("V4.3: %h", UUT.vector.vector[4][3]);
    $strobe("V4.4: %h", UUT.vector.vector[4][4]);
    $strobe("V4.5: %h", UUT.vector.vector[4][5]);
    $strobe("V4.6: %h", UUT.vector.vector[4][6]);
    $strobe("V4.7: %h", UUT.vector.vector[4][7]);
    $strobe("V4.8: %h", UUT.vector.vector[4][8]);
    $strobe("V4.9: %h", UUT.vector.vector[4][9]);
    $strobe("V4.10: %h", UUT.vector.vector[4][10]);
    $strobe("V4.11: %h", UUT.vector.vector[4][11]);
    $strobe("V4.12: %h", UUT.vector.vector[4][12]);
    $strobe("V4.13: %h", UUT.vector.vector[4][13]);
    $strobe("V4.14: %h", UUT.vector.vector[4][14]);
    $strobe("V4.15: %h", UUT.vector.vector[4][15]);
    #10;
    $strobe("S0: %h S7: %h", UUT.scalar.scalar[0], UUT.scalar.scalar[7]);
    //write memory contents to text file
    $writememb("dump.txt", mem.Memory);
    #10;
    $finish;
  end
endmodule
