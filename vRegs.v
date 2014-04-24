//Eight 16x16-bit vector registers
module vRegs(output reg [15:0] DataOut_s, output reg [15:0] DataOut2_s,
    input [2:0] Addr, input [2:0] Addr2, input Clk1, input Clk2,
    input [15:0] DataIn_s, input RD_s, input WR_s);

  reg [15:0] vector[7:0][15:0];
  integer i;  //used in for loop
  wire [1:0] cmd;
  reg [2:0] address, address2;
  reg prev_WR_s, prev_RD_s;
  reg [3:0] selectW;
  reg [3:0] selectR;

  always@(posedge Clk1) begin

    prev_RD_s <= RD_s;
    prev_WR_s <= WR_s;


    if (RD_s) begin
      DataOut_s <= vector[address][selectR];
      DataOut2_s <= vector[address2][selectR];
    end else begin
      DataOut_s <= DataOut_s;
      DataOut2_s <= DataOut2_s;
    end

    if (WR_s) begin
      vector[address][selectW] <= DataIn_s;
    end else begin
      vector[address][i] <= vector[address][i];
    end

    if (~prev_RD_s && RD_s)
      selectR <= 1;
    else if (prev_RD_s)
      selectR <= selectR + 1;
    else
      selectR <= 0;

    if (~prev_WR_s && WR_s)
      selectW <= 1;
    else if (prev_WR_s)
      selectW <= selectW + 1;
    else
      selectW <= 0;
  end

  always@(posedge Clk2) begin
    address <= Addr;
    address2 <= Addr2;
  end

endmodule

module t_vRegs();
  wire [15:0] out, out2;
  reg [15:0] in;
  reg [2:0] addr, addr2;
  reg wr, rd, clk1, clk2;
  integer i;

  vRegs UUT(.DataOut_s(out), .DataIn_s(in), .Addr(addr), .WR_s(wr), .RD_s(rd),
            .Clk1(clk1), .Clk2(clk2),
            .DataOut2_s(out2),
            .Addr2(addr2));

  initial begin
    clk1 = 1'b1;
    clk2 = 1'b0;
    forever begin
      #5;
      clk1 = ~clk1;
      clk2 = ~clk2;
    end
  end //initial

  initial $monitor("In: %h Serial Out: %h Serial Out 2: %h", in, out, out2);

  initial begin
    wr = 1'b0; rd = 1'b0;
    addr = 3'b000; addr2 = 3'b000;
    in = 16'ha000;
    #2.5;
    wr = 1'b1;
    for (i = 0; i < 16; i = i + 1) begin
      #10;
      in = in + 1;
    end

    wr = 1'b0;
    rd = 1'b1;
    /*
    $display("Vector 0-0: %h", UUT.vector[0][0]);
    $display("Vector 0-1: %h", UUT.vector[0][1]);
    $display("Vector 0-2: %h", UUT.vector[0][2]);
    $display("Vector 0-3: %h", UUT.vector[0][3]);
    */
    #160;
    rd = 1'b0;
    #25;
    addr = 3'b010;
    #5;
    #10;
    addr2 = 3'b010;
    #10;
    addr = 3'b001;
    #5;
    #10;
    #20;
    $finish;
  end //initial

endmodule
