//Eight 16x16-bit vector registers
module vReg(output reg [255:0] DataOut_p, output reg [15:0] DataOut_s, 
    input [2:0] Addr, input Clk1, input Clk2, input [255:0] DataIn_p, 
    input [15:0] DataIn_s, input RD_p, input WR_p, input RD_s, input WR_s);

  reg [15:0] vector[7:0][15:0];

  reg [2:0] address;
  reg readp, writep, reads, writes;
  reg [3:0] select; //tracks current element during sequential operations
  integer i; //counter in for loop

  always@(posedge Clk1) begin
    readp <= RD_p;
    writep <= WR_p;
    reads <= RD_s;
    writes <= WR_s;

    if ((~reads && RD_s) || (~writes && WR_s))
      select <= 0;
    else if (reads || writes)
      select <= select + 1;
    else
      select <= select;
  end

  always@(posedge Clk2) begin
    address <= Addr;
  end
  
  always@(readp, address) begin
    if (readp) begin
      DataOut_p = {vector[address][15], vector[address][14], 
                   vector[address][13], vector[address][12], vector[address][11], 
                   vector[address][10], vector[address][9], vector[address][8], 
                   vector[address][7], vector[address][6], vector[address][5], 
                   vector[address][4], vector[address][3], vector[address][2], 
                   vector[address][1], vector[address][0]}; 
    end
    else
      DataOut_p = DataOut_p;
  end
  
  always@(writep, address) begin
    if (writep) begin
      for (i = 0; i < 16; i = i + 1) begin
        vector[address][i] = DataIn_p[(16*i+15):(16*i)];
      end
    end
    else begin
      for (i = 0; i < 16; i = i + 1) begin
        vector[address][i] = vector[address][i]; 
      end
    end
  end
  
  always@(select) begin
    if (reads)
      DataOut_s = vector[address][select];
    else
      DataOut_s = DataOut_s;  
    if (writes)
      vector[address][select] = DataIn_s;
    else
      vector[address][select] = vector[address][select];
  end

endmodule

module t_vReg();
  wire [15:0] out;
  reg [15:0] in;
  wire [255:0] outp;
  reg [255:0] inp;
  reg [2:0] addr;
  reg wr, rd, wrp, rdp, clk1, clk2;
  integer i;

  vReg UUT(.DataOut_s(out), .DataIn_s(in), .Addr(addr), .WR_s(wr), .RD_s(rd),
            .Clk1(clk1), .Clk2(clk2), .DataOut_p(outp), .DataIn_p(inp),
            .WR_p(wrp), .RD_p(rdp));

  initial begin
    clk1 = 1'b1;
    clk2 = 1'b0;
    forever begin
      #5;
      clk1 = ~clk1;
      clk2 = ~clk2;
    end
  end //initial

  initial $monitor("In: %h Serial Out: %h", in, out);

  initial begin
    wr = 1'b0; wrp = 1'b0; rdp = 1'b0; rd = 1'b0;
    addr = 3'b000;
    in = 16'ha000;
    inp = 256'h0;
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
    wrp = 1'b1;
    inp = 256'h123456789abcdef;
    #10;
    wrp = 1'b0;
    rdp = 1'b1;
    #10;
    $display("Parallel out: %h", outp);
    rdp = 1'b0;
    #25;
    addr = 3'b001;
    #5;
    rdp = 1'b1;
    #10;
    $display("Parallel out (should be all x): %h", outp);
    rdp = 1'b0;
    #20;
    $finish;
  end //initial

endmodule
