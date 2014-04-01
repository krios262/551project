//controls DRAM addressing
module addrUnit(output reg [15:0] addr, input Clk1, input [15:0] offset,
    input [15:0] addrBase, input [15:0] PC, input setPC, input updateAddr);

  always@(posedge Clk1) begin

    if (setPC)
      addr <= PC;
    else if (updateAddr)
      addr <= addrBase + offset;
    else
      addr <= addr;

  end
endmodule
