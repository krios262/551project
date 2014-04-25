module SMULT16serp(output reg [15:0] product, output reg V, input Clk1, input Clk2,
  input [15:0] scalar, input [15:0] vecin, input start, output reg write,  output reg done);

  wire Ov;
  wire [15:0] element;
  reg [4:0] state;

  VMULTp mult(.product(element), .Overflow(Ov), .A(scalar), .B(vecin), .Clk2(Clk2));

  always@(posedge Clk1) begin
    case (state)
      5'b11111: begin
        done <= 1'b1;
        write <= write;
      end
      5'b00010: begin
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
    product <= element;

    if (start) begin
      if (state == 5'b00000) begin 
        V <= V;
        state <= state +1;
      end else if (state == 5'b11111) begin
        state <= state;
        V <= Ov| V;
      end else begin
        state <= state + 1;
        V <= Ov| V;
      end
    end else begin
      state <= 5'b00000;
      V <= 1'b0;
    end
  end //always

endmodule

module t_SMULT16serp();

  reg [15:0] vec, scalar;
  reg start, Clk1, Clk2;
  wire [15:0] out;
  wire done, V, write;

  SMULT16serp UUT(.product(out), .V(V), .scalar(scalar), .vecin(vec), .start(start), .Clk1(Clk1), .Clk2(Clk2), .write(write), .done(done));

  initial begin
    Clk1 = 1'b0;
    Clk2 = 1'b1;
    forever begin
      #5;
      Clk2 = ~Clk2;
      Clk1 = ~Clk1;
    end //forever
  end

  initial $monitor("state: %b Sca: %h Vec: %h out: %h V: %b start: %b write: %b done: %b", UUT.state, scalar, vec, out, V, start, write, done);

  initial begin
    start = 1'b0;
    #12.5;
    scalar = 16'h3c00;
    vec = 16'h3c00;
    //Answer = 3c00
    start = 1'b1;
    #350;
    start = 1'b0;
    #20;
    scalar = 16'hbc00;
    start = 1'b1;
    #350;
    start = 1'b0;
    #20;
    //Answer = bc00 repeating
    $finish;
  end
endmodule

