//controls DRAM addressing
module addrUnit(output reg [15:0] addr, input Clk1, input [5:0] offset,
    input [15:0] addrBase, input [15:0] PC, input setPC, input updateAddr);

  reg [15:0] ex_offset;

  always@(posedge Clk1) begin

    if (setPC)
      addr <= PC;
    else if (updateAddr)
      addr <= addrBase + ex_offset;
    else
      addr <= addr;

  end

  always@(offset) begin
    ex_offset = { {10{offset[5]}}, offset};
  end

endmodule
