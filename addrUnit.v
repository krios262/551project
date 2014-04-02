//controls DRAM addressing
module addrUnit(output reg [15:0] addr, input Clk1, input [5:0] imm_offset,
    input [15:0] addrBase, input [15:0] PC, input setPC, input updateAddr,
    input [3:0] inc_offset);

  reg [15:0] ex_offset;
  reg [15:0] ex_inc_offset;

  always@(posedge Clk1) begin

    if (setPC)
      addr <= PC;
    else if (updateAddr)
      addr <= addrBase + ex_offset + ex_inc_offset;
    else
      addr <= addr;

  end

  always@(imm_offset, inc_offset) begin
    ex_offset = { {10{imm_offset[5]}}, imm_offset};
    ex_inc_offset = { {12{imm_offset[3]}}, inc_offset};
  end

endmodule
