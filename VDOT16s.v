//Implements vector dot product
//Serial version of VDOT16
module VDOT16s(output reg [15:0] out, output V, input [15:0] A, input [15:0] B, input start,
               input Clk1, input Clk2, output reg done);

  reg [4:0] state;

  reg [15:0] mult;
  wire [15:0] multOut;
  wire [15:0] sumOut;
  wire [1:0] Ov;

  assign V = Ov[0] | Ov[1];

  VMULT multu(.product(multOut), .Overflow(Ov[0]), .A(A), .B(B));
  VADD addu(.Sum(sumOut), .Overflow(Ov[1]), .A(multOut), .B(out));

  always@(posedge Clk1) begin
    if (state == 5'b10000)
      done <= 1'b1;
    else
      done <= 1'b0;
  end

  always@(posedge Clk2) begin
    mult <= multOut;

    if (start) begin
      out <= sumOut;

      if (state == 5'b10000) begin
        state <= state;
      end else begin
        state <= state + 1;
      end
    end else begin
      state <= 5'b00000;
      out <= 16'b0;
    end
  end //always

endmodule

module t_VDOT16s();
  reg [15:0] A, B;
  reg start, Clk1, Clk2;
  wire [15:0] out;
  wire done, V;

  VDOT16s UUT(.out(out), .V(V), .A(A), .B(B), .start(start), .Clk1(Clk1), .Clk2(Clk2), .done(done));

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
    A = 16'h3c00;
    B = 16'h3c00;
    start = 1'b1;
    #170;
    start = 1'b0;
    #20;
    $finish;
  end

endmodule
