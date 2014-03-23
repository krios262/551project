//Eight 16-bit scalar registers
module sReg(output reg [15:0] DataOut, input [2:0] Addr, input Clk1, input Clk2,
    input [7:0] DataIn, input RD, input WR_l, input WR_h);

  reg [15:0] scalar[7:0];
  reg [2:0] address;
  reg read, wr_low, wr_high;

  always@(posedge Clk1) begin
    read <= RD;
    wr_low <= WR_l;
    wr_high <= WR_h;
  end

  always@(posedge Clk2) begin
    address <= Addr;
  end

  always@(read, address) begin
    if (read == 1'b1) begin
      case (address)
        3'b000:
          DataOut <= scalar[0];
        3'b001:
          DataOut <= scalar[1];
        3'b010:
          DataOut <= scalar[2];
        3'b011:
          DataOut <= scalar[3];
        3'b100:
          DataOut <= scalar[4];
        3'b101:
          DataOut <= scalar[5];
        3'b110:
          DataOut <= scalar[6];
        3'b111:
          DataOut <= scalar[7];
      endcase
    end
    else
      DataOut <= DataOut;
  end

  always@(wr_low, wr_high, address) begin
    case (address)
      3'b000: begin
        if (wr_low == 1'b1)
          scalar[0][7:0] <= DataIn;
        else if (wr_high == 1'b1)
          scalar[0][15:8] <= DataIn;
        else
          scalar[0] <= scalar[0];
      end
      3'b001: begin
        if (wr_low == 1'b1)
          scalar[1][7:0] <= DataIn;
        else if (wr_high == 1'b1)
          scalar[1][15:8] <= DataIn;
        else
          scalar[1] <= scalar[1];
      end
      3'b010: begin
        if (wr_low == 1'b1)
          scalar[2][7:0] <= DataIn;
        else if (wr_high == 1'b1)
          scalar[2][15:8] <= DataIn;
        else
          scalar[2] <= scalar[2];
      end
      3'b011: begin
        if (wr_low == 1'b1)
          scalar[3][7:0] <= DataIn;
        else if (wr_high == 1'b1)
          scalar[3][15:8] <= DataIn;
        else
          scalar[3] <= scalar[3];
      end
      3'b100: begin
        if (wr_low == 1'b1)
          scalar[4][7:0] <= DataIn;
        else if (wr_high == 1'b1)
          scalar[4][15:8] <= DataIn;
        else
          scalar[4] <= scalar[4];
      end
      3'b101: begin
        if (wr_low == 1'b1)
          scalar[5][7:0] <= DataIn;
        else if (wr_high == 1'b1)
          scalar[5][15:8] <= DataIn;
        else
          scalar[5] <= scalar[5];
      end
      3'b110: begin
        if (wr_low == 1'b1)
          scalar[6][7:0] <= DataIn;
        else if (wr_high == 1'b1)
          scalar[6][15:8] <= DataIn;
        else
          scalar[6] <= scalar[6];
      end
      3'b111: begin
        if (wr_low == 1'b1)
          scalar[7][7:0] <= DataIn;
        else if (wr_high == 1'b1)
          scalar[7][15:8] <= DataIn;
        else
          scalar[7] <= scalar[7];
      end
      endcase
  end
endmodule
