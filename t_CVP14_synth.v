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

  //initial $monitor ("State: %b PC: %h Addr: %h SetPC: %b DataIn: %h, V: %b, Reset: %b",
  //  UUT.state, UUT.PC, UUT.Addr, UUT.setPC, UUT.DataIn, UUT.V, UUT.Reset);

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
	if(addr == 16'hfff3) begin
		$display("Time:%t MEM DUMP!", $time);
		$writememb("dump.txt", mem.Memory);
		#10;
		$finish;
	end
end
endmodule
