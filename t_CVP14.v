//Cvp14 Test Bench
`timescale 1ns/1ns
module t_CVP14();
  parameter smul_pipe = 1'b1;
  wire[15:0] out, in, addr;
  wire r, w, v;
  reg  rst, c1, c2;

  integer i;

  DRAM mem(.DataOut(in), .Addr(addr), .DataIn(out),
    .clk1(c1), .clk2(c2), .RD(r), .WR(w));
  CVP14 #(.Pipe_SMUL_parallel(smul_pipe)) UUT(.Addr(addr), .RD(r), .WR(w), .V(v),
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
    
    $monitor("%t: State: %d, nextState: %d, Inst: %h, PC: %d, Addr: %h, WR: %b, RD: %b, AdderOutS: %h, V: %b, addDone: %b, addWrite: %b",
            $time, UUT.state, UUT.nextState, UUT.instruction, UUT.PC, 
            UUT.Addr, UUT.WR, UUT.RD, UUT.AdderOutS, UUT.V, UUT.addDone, UUT.addWrite);
    
    /*
    $monitor("%t: State %b, Inst: %h, Scalar 0: %h, sIn: %h, sAddr: %h, DataIn: %h", $time, UUT.state,
          UUT.instruction, UUT.scalar.scalar[0], UUT.sIn, UUT.sAddr, UUT.DataIn);
    */
  end

  initial begin
    #2.5;
    rst = 1'b1;
    #10;
    rst = 1'b0;
    #60000000;
    $display("Didn't reach addr xFFFF, dump what we have");
    $writememb("dump.txt", mem.Memory);
    #10;
    $finish;
  end

  always@(addr) begin
    //END OF TESTBENCH CONDITION
    $display("Addr = %h", addr);
    if(addr == 16'hffff) begin
    $display("Time:%t MEM DUMP!", $time);
    $writememb("dump.txt", mem.Memory);
    #10;
    $finish;
    end
  end

endmodule
