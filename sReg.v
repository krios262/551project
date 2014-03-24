//Eight 16-bit scalar registers
module sReg(output reg [15:0] DataOut, input [2:0] Addr, input Clk1, input Clk2,
    input [15:0] DataIn, input RD, input WR, input WR_l, input WR_h);

  reg [15:0] scalar[7:0];
  reg [2:0] address;
  reg read, write, wr_low, wr_high;

  always@(posedge Clk1) begin
    read <= RD;
    write <= WR;
    wr_low <= WR_l;
    wr_high <= WR_h;
  end

  always@(posedge Clk2) begin
    address <= Addr;
  end

  always@(read, address) begin
    if (read == 1'b1)
      DataOut = scalar[address];
    else
      DataOut = DataOut;
  end

  always@(write, wr_low, wr_high, address) begin
    if (write == 1'b1)
      scalar[address] = DataIn;
    else if (wr_low == 1'b1)
      scalar[address][7:0] = DataIn[7:0];
    else if (wr_high == 1'b1)
      scalar[address][15:8] = DataIn[15:8];
    else
      scalar[address] = scalar[address];
  end
endmodule
