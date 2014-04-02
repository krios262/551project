//Calculates address offsets
module offsetu(output reg [3:0] offset, input Reset, input Clk2,
    input offsetInc);

  always@(posedge Clk2) begin
    if (Reset)
      offset <= 4'b0;
    else
      if (offsetInc)
        offset <= offset + 1;
      else
        offset <= offset;
  end

endmodule
