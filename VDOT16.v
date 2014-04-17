//Implements vector dot product
module VDOT16(output [15:0] out, output V, input [255:0] A, input [255:0] B, input Clk1, input start, output reg done);

  wire [30:0] Ov;
  wire [255:0] multOut;
  wire [127:0] add1Out;
  wire [63:0] add2Out;
  wire [31:0] add3Out;

  assign V = Ov[0] | Ov[1] | Ov[2] | Ov[3] | Ov[4] | Ov[5] | Ov[6] | Ov[7] | Ov[8] |
                  Ov[9] | Ov[10] | Ov[11] | Ov[12] | Ov[13] | Ov[14] | Ov[15] |
                  Ov[16] | Ov[17] | Ov[18] | Ov[19] | Ov[20] | Ov[21] | Ov[22] |
                  Ov[23] | Ov[24] | Ov[25] | Ov[26] | Ov[27] | Ov[28] | Ov[29] | Ov[30];

  VMULT mult[15:0](.product(multOut), .Overflow(Ov[15:0]), .A(A), .B(B));
  VADD add1[7:0](.Sum(add1Out), .Overflow(Ov[23:16]), .A(multOut[127:0]), .B(multOut[255:128]));
  VADD add2[3:0](.Sum(add2Out), .Overflow(Ov[27:24]), .A(add1Out[63:0]), .B(add1Out[127:64]));
  VADD add3[1:0](.Sum(add3Out), .Overflow(Ov[29:28]), .A(add2Out[31:0]), .B(add2Out[63:32]));
  VADD add4(.Sum(out), .Overflow(Ov[30]), .A(add3Out[15:0]), .B(add3Out[31:16]));

  always@(posedge Clk1) begin
    done <= start; //this module finishes operation in one cycle
  end

endmodule
