//Eight 16x16-bit vector registers
module vReg(output reg [255:0] DataOut_p, output reg [255:0] DataOut2_p,
    output reg [15:0] DataOut_s, output reg [15:0] DataOut2_s,
    input [2:0] Addr, input [2:0] Addr2, input Clk1, input Clk2, 
    input [255:0] DataIn_p, input [15:0] DataIn_s, 
    input RD_p, input WR_p, input RD_s, input WR_s);

  reg [15:0] vector[7:0][15:0];
  integer i;  //used in for loop
  wire [3:0] cmd;
  reg [2:0] address, address2;
  parameter readp = 4'b1000, writep = 4'b0100, reads = 4'b0010, writes = 4'b0001;
  reg prev_WR_s, prev_RD_s;
  reg [3:0] select;

  assign cmd = {RD_p, WR_p, RD_s, WR_s}; 

  always@(posedge Clk1) begin

    prev_RD_s <= RD_s;
    prev_WR_s <= WR_s;

    case (cmd)
      readp: begin
      DataOut_p <= {vector[address][15], vector[address][14], 
               vector[address][13], vector[address][12], vector[address][11], 
               vector[address][10], vector[address][9], vector[address][8], 
               vector[address][7], vector[address][6], vector[address][5], 
               vector[address][4], vector[address][3], vector[address][2], 
               vector[address][1], vector[address][0]}; 
      DataOut2_p <= {vector[address2][15], vector[address2][14], 
               vector[address2][13], vector[address2][12], vector[address2][11], 
               vector[address2][10], vector[address2][9], vector[address2][8], 
               vector[address2][7], vector[address2][6], vector[address2][5], 
               vector[address2][4], vector[address2][3], vector[address2][2], 
               vector[address2][1], vector[address2][0]}; 

      for(i = 0; i < 16; i = i + 1) begin
        vector[address][i] <= vector[address][i];
      end

        DataOut_s <= DataOut_s;  
        DataOut2_s <= DataOut2_s;
      end

      writep: begin
        vector[address][0] <= DataIn_p[15:0];
        vector[address][1] <= DataIn_p[31:16];
        vector[address][2] <= DataIn_p[47:32];
        vector[address][3] <= DataIn_p[63:48];
        vector[address][4] <= DataIn_p[79:64];
        vector[address][5] <= DataIn_p[95:80];
        vector[address][6] <= DataIn_p[111:96];
        vector[address][7] <= DataIn_p[127:112];
        vector[address][8] <= DataIn_p[143:128];
        vector[address][9] <= DataIn_p[159:144];
        vector[address][10] <= DataIn_p[175:160];
        vector[address][11] <= DataIn_p[191:176];
        vector[address][12] <= DataIn_p[207:192];
        vector[address][13] <= DataIn_p[223:208];
        vector[address][14] <= DataIn_p[239:224];
        vector[address][15] <= DataIn_p[255:240];

        DataOut_p <= DataOut_p;
        DataOut2_p <= DataOut2_p;

        DataOut_s <= DataOut_s;  
        DataOut2_s <= DataOut2_s;
      end

      reads: begin
        DataOut_s <= vector[address][select];
        DataOut2_s <= vector[address2][select];

      for(i = 0; i < 16; i = i + 1) begin
        vector[address][i] <= vector[address][i];
      end
        DataOut_p <= DataOut_p;
        DataOut2_p <= DataOut2_p;
      end

      writes: begin

        DataOut_p <= DataOut_p;
        DataOut2_p <= DataOut2_p;

        for(i = 0; i < 16; i = i + 1) begin
          if (i == select)
            vector[address][select] <= DataIn_s;
          else
            vector[address][i] <= vector[address][i];
          end
        end

      default: begin
        DataOut_p <= DataOut_p;
        DataOut2_p <= DataOut2_p;

        for(i = 0; i < 16; i = i + 1) begin
          vector[address][i] <= vector[address][i];
        end

          DataOut_s <= DataOut_s;  
          DataOut2_s <= DataOut2_s;
      end
    endcase

    if ((~prev_RD_s && RD_s) || (~prev_WR_s && WR_s))
      select <= 1;
    else if (prev_RD_s || prev_WR_s)
      select <= select + 1;
    else
      select <= 0;
  end

  always@(posedge Clk2) begin
    address <= Addr;
    address2 <= Addr2;
  end

endmodule

module t_vReg();
  wire [15:0] out, out2;
  reg [15:0] in;
  wire [255:0] outp, outp2;
  reg [255:0] inp;
  reg [2:0] addr, addr2;
  reg wr, rd, wrp, rdp, clk1, clk2;
  integer i;

  vReg UUT(.DataOut_s(out), .DataIn_s(in), .Addr(addr), .WR_s(wr), .RD_s(rd),
            .Clk1(clk1), .Clk2(clk2), .DataOut_p(outp), .DataIn_p(inp),
            .WR_p(wrp), .RD_p(rdp), .DataOut2_s(out2), .DataOut2_p(outp2),
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
    wr = 1'b0; wrp = 1'b0; rdp = 1'b0; rd = 1'b0;
    addr = 3'b000; addr2 = 3'b000;
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
    addr2 = 3'b010;
    #10;
    $display("Parallel out: %h", outp);
    $display("Parallel out 2: %h", outp2);
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
