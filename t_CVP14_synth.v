`timescale 1ns / 1ps
module t_CVP14_synth();
  wire[15:0] out, in, addr;
  wire r, w, v;
  reg  rst, c1, c2;

  DRAM mem(.DataOut(in), .Addr(addr), .DataIn(out),
    .clk1(c1), .clk2(c2), .RD(r), .WR(w));
  CVP14_synth UUT(.Addr(addr), .RD(r), .WR(w), .V(v),
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
    rst = 1'b1;
    #10;
    rst = 1'b0;
    #1100;
    $finish;
  end
endmodule
