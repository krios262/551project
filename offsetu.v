//Calculates address offsets
module offsetu(output reg [15:0] offset, input [5:0] inst, input Clk2,
    input offsetInc);

  reg [15:0] ex_offset;

  always@(posedge Clk2) begin
    if (offsetInc)
      offset <= offset + 1;
    else
      offset <= ex_offset;
  end

  always@(inst) begin
    ex_offset = { {10{inst[5]}}, inst};
  end
endmodule
