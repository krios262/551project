//Implements vector dot product
//Pipelined version of VDOT16
module VDOT16p(output [15:0] out, output V, input [255:0] A, input [255:0] B, input start,
               input Clk1, input Clk2, output reg done);

  wire [30:0] Ov;
  wire [255:0] multOut;
  reg [255:0] mult;
  wire [127:0] add1Out;
  reg [127:0] add1;
  wire [63:0] add2Out;
  reg [63:0] add2;
  wire [31:0] add3Out;
  reg [31:0] add3;

  reg [2:0] state;

  assign V = Ov[0] | Ov[1] | Ov[2] | Ov[3] | Ov[4] | Ov[5] | Ov[6] | Ov[7] | Ov[8] |
                  Ov[9] | Ov[10] | Ov[11] | Ov[12] | Ov[13] | Ov[14] | Ov[15] |
                  Ov[16] | Ov[17] | Ov[18] | Ov[19] | Ov[20] | Ov[21] | Ov[22] |
                  Ov[23] | Ov[24] | Ov[25] | Ov[26] | Ov[27] | Ov[28] | Ov[29] | Ov[30];

  VMULT multu[15:0](.product(multOut), .Overflow(Ov[15:0]), .A(A), .B(B));
  VADD add1u[7:0](.Sum(add1Out), .Overflow(Ov[23:16]), .A(mult[127:0]), .B(mult[255:128]));
  VADD add2u[3:0](.Sum(add2Out), .Overflow(Ov[27:24]), .A(add1[63:0]), .B(add1[127:64]));
  VADD add3u[1:0](.Sum(add3Out), .Overflow(Ov[29:28]), .A(add2[31:0]), .B(add2[63:32]));
  VADD add4u(.Sum(out), .Overflow(Ov[30]), .A(add3[15:0]), .B(add3[31:16]));

  always@(posedge Clk1) begin
    if (state == 3'b101)
      done <= 1'b1;
    else
      done <= 1'b0;
  end

  always@(posedge Clk2) begin
    mult <= multOut;
    add1 <= add1Out;
    add2 <= add2Out;
    add3 <= add3Out;

    if (start) begin
      if (state == 3'b101) begin
        state <= state;
      end else begin
        state <= state + 1;
      end
    end else begin
      state <= 3'b000;
    end
  end //always

endmodule

module t_VDOT16p();
  reg [255:0] A, B;
  reg start, Clk1, Clk2;
  wire [15:0] out;
  wire done, V;

  VDOT16p UUT(.out(out), .V(V), .A(A), .B(B), .start(start), .Clk1(Clk1), .Clk2(Clk2), .done(done));

  initial begin
    Clk1 = 1'b0;
    Clk2 = 1'b1;
    forever begin
      #5;
      Clk2 = ~Clk2;
      Clk1 = ~Clk1;
    end //forever
  end

  initial $monitor("state: %b A: %h B: %h out: %h V: %b start: %b done: %b", UUT.state, A, B, out, V, start, done);

  initial begin
    start = 1'b0;
    #12.5;
    A = 256'h3c003c003c003c003c003c003c003c003c003c003c003c003c003c003c003c00;
    B = 256'h3c003c003c003c003c003c003c003c003c003c003c003c003c003c003c003c00;
    start = 1'b1;
    #100;
    $finish;
  end

endmodule
