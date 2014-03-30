//Updates PC
module PCunit(output reg [15:0] PC, input [11:0] offset, input Clk2, input updatePC,
    input jump, input reset);

  reg [15:0] ex_offset;

  always@(posedge Clk2) begin

    if (reset)
      PC <= 16'h0000;
    else
      if (updatePC)

        if (jump)
          PC <= PC + ex_offset;
        else
          PC <= PC + 1;

      else
        PC <= PC;
  end

  always@(offset) begin
    ex_offset = { {4{offset[11]}}, offset};
  end

endmodule
