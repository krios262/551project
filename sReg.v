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
    if (read)
      DataOut = scalar[address];
    else
      DataOut = DataOut;
  end

  always@(write, wr_low, wr_high, address) begin
    if (write)
      scalar[address] = DataIn;
    else if (wr_low)
      scalar[address][7:0] = DataIn[7:0];
    else if (wr_high)
      scalar[address][15:8] = DataIn[15:8];
    else
      scalar[address] = scalar[address];
  end
endmodule

module t_sReg();
  wire [15:0] out;
  reg [15:0] in;
  reg [2:0] addr;
  reg wr, rd, wrl, wrh, clk1, clk2;

  sReg UUT(.DataOut(out), .DataIn(in), .Addr(addr), .WR(wr), .RD(rd), .WR_l(wrl),
            .WR_h(wrh), .Clk1(clk1), .Clk2(clk2));

  initial begin
    clk1 = 1'b1;
    clk2 = 1'b0;
    forever begin
      #5;
      clk1 = ~clk1;
      clk2 = ~clk2;
    end
  end //initial

  initial begin
    wr = 1'b0; wrl = 1'b0; wrh = 1'b0; rd = 1'b0;
    addr = 3'b000;
    in = 16'habcd;
    #2.5;
    #5;
    wr = 1'b1;
    #5;
    addr = 3'b001;
    #10;
    addr = 3'b010;
    #10; 
    addr = 3'b011;
    #5;
    wr = 1'b0; wrl = 1'b1;
    #5;
    addr = 3'b100;
    #10;
    addr = 3'b101;
    #5;
    wrl = 1'b0; wrh = 1'b1;
    #5;
    addr = 3'b110;
    #10;
    addr = 3'b111;
    #10;
    addr = 3'b000;
    #5;
    wrh = 1'b0; rd = 1'b1;
    #5;
    $display("Scalar %d : %h", addr, out);
    for (addr = 3'b001; addr > 3'b000; addr = addr + 1) begin
      #10;
      $display("Scalar %d : %h", addr, out);
    end
    $finish;
  end //initial
    
endmodule
