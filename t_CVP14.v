//Cvp14 Test Bench
`timescale 1ns/1ns
module t_CVP14();
  wire[15:0] out, in, addr;
  wire r, w, v;
  reg  rst, c1, c2;

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
    /*
    $monitor("%t: State: %b, Inst: %h, PC: %d, Addr: %h, WR: %b, RD: %b, DataOut: %h",
            $time, UUT.state, UUT.instruction, UUT.PC, UUT.Addr, UUT.WR, UUT.RD, UUT.DataOut);
    */
    /*
    $monitor("%t: State %b, Inst: %h, sWR_l:, %b, Scalar 0: %h, sIn: %h, sAddr: %h", $time, UUT.state,
          UUT.instruction, UUT.sWR_l, UUT.scalar.scalar[0], UUT.sIn, UUT.sAddr);
    */
  end

  initial begin
    rst = 1'b1;
    #10;
    rst = 1'b0;
    #1100;
    $strobe("S0: %h S1: %h S7: %h", UUT.scalar.scalar[0], UUT.scalar.scalar[1], UUT.scalar.scalar[7]);
    #10;
    //write memory contents to text file
    $writememb("dump.txt", mem.Memory);
    #10;
    $finish;
  end
endmodule
