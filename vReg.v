//Eight 16x16-bit vector registers
module vReg(output reg [255:0] DataOut, input [2:0] Addr, input Clk1, input Clk2,
    input [255:0] DataIn, input RD_p, input WR_p);

  reg [255:0] vector[7:0];
  reg [2:0] address;
  reg readp, writep;

  always@(posedge Clk1) begin
    readp <= RD_p;
    writep <= WR_p;
  end

  always@(posedge Clk2) begin
    address <= Addr;
  end

  always@(read, address) begin
    if (readp)
      DataOut = vector[address];
    else
      DataOut = DataOut;
  end

  always@(write, wr_low, wr_high, address) begin
    if (writep)
      vector[address] = DataIn;
    else
      vector[address] = vector[address];
  end
endmodule
