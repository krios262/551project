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
	  #2.5 c1 = ~c1; #2.5; 
	  #2.5 c2 = ~c2; #2.5;
	end
  end
initial begin
  $monitor("Current Instruc: %h, PC: %d, Addr: %h, , readInst: %b,getNewInst: %b", 
UUT.instruction, UUT.PC, UUT.Addr,UUT.readInst, UUT.getNewInst);
end
initial begin
  rst = 1'b1;
  #10;
  rst = 1'b0;
  #10;
  $strobe("Mem[0]: %h", mem.Memory[0]);
  #1000;
  $strobe("S0: %h S1: %h S7: %h", UUT.scalar.scalar[0], UUT.scalar.scalar[1], UUT.scalar.scalar[7]);
end  
endmodule
