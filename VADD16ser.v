module VADD16ser(output reg [15:0] SumV, output reg V, input [15:0] A,
                 input [15:0] B, input start, input Clk1, input Clk2, output reg write, output reg done);

  wire Ov;
  wire [15:0] sum;
  reg [4:0] state;

  VADD adder(sum,Ov,A,B);

  always@(posedge Clk1) begin
    case (state)
      5'b10000: begin
        done <= 1'b1;
        write <= write;
      end
      5'b00001: begin
        done <= done;
        write <= 1'b1;
      end
      5'b00000: begin
        done <= 1'b0;
        write <= 1'b0;
      end
      default: begin
        done <= done;
        write <= write;
      end
    endcase
  end

  always@(posedge Clk2) begin
    SumV <= sum;

    if (start) begin
      V <= Ov | V;

      if (state == 5'b10000) begin
        state <= state;
      end else begin
        state <= state + 1;
      end
    end else begin
      state <= 5'b00000;
      V <= 1'b0;
    end
  end //always

endmodule

module t_VADD16ser();
  reg [15:0] A, B;
  reg start, Clk1, Clk2;
  wire [15:0] out;
  wire done, V, write;

  VADD16ser UUT(.SumV(out), .V(V), .A(A), .B(B), .start(start), .Clk1(Clk1), .Clk2(Clk2), .write(write), .done(done));

  initial begin
    Clk1 = 1'b0;
    Clk2 = 1'b1;
    forever begin
      #5;
      Clk2 = ~Clk2;
      Clk1 = ~Clk1;
    end //forever
  end

  initial $monitor("state: %b A: %h B: %h out: %h V: %b start: %b write: %b done: %b", UUT.state, A, B, out, V, start, write, done);

  initial begin
    start = 1'b0;
    #12.5;
    A = 16'h9939;
    B = 16'h9939;
    start = 1'b1;
    #170;
    start = 1'b0;
    #20;
    $finish;
  end

endmodule
