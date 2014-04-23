`timescale 1ns/1ps
//Pipeline parallel SMULT16
module SMULT16p(output [255:0] product,output V,input Clk1, input Clk2,
  input [15:0] scalar, input [255:0] vecin, input start, output reg done);
  reg [1:0] state;
  wire [15:0] Ov;

  assign V = Ov[0] | Ov[1] | Ov[2] | Ov[3] | Ov[4] | Ov[5] | Ov[6] |
            Ov[7] | Ov[8] | Ov[9] | Ov[10] | Ov[11] | Ov[12] | Ov[13] | Ov[14]|Ov[15];

  VMULTp mult[15:0](.product(product), .Overflow(Ov[15:0]), .Clk2(Clk2),
    .A(scalar), .B(vecin));
 
  always@(posedge Clk1) begin
    if (state == 2'b10)
      done <= 1'b1;
    else
      done <= 1'b0;
  end

  always@(posedge Clk2) begin
    if (start) begin
      if (state == 2'b10) begin
        state <= state;
      end else begin
        state <= state + 1;
      end
    end 
    else begin
      state <= 2'b00;
    end
  end//state machine always

endmodule

module t_SMULT16p();

  wire [255:0] pro;
  wire ovf;
  reg [255:0] vec1;
  reg [15:0] s1;
  reg start, Clk1, Clk2;
  wire done;

  SMULT16p S1(pro,ovf,Clk1, Clk2, s1,vec1,start,done);
  initial begin
    Clk1 = 1'b0;
    Clk2 = 1'b1;
    forever begin
      #5;
      Clk2 = ~Clk2;
      Clk1 = ~Clk1;
    end//forever
  end//clock


  initial $monitor("Product:%h Overflow:%b start:%b done:%b", pro, ovf, start, done);
  initial begin
    start = 1'b0; #12.5;
    s1 = 16'h3c00;
    vec1 = 256'h3c003c003c003c003c003c003c003c003c003c003c003c003c003c003c003c00;
    start = 1'b1; #100; //Answer = 3c00 repeating
    
    start = 1'b0; #12.5;
    s1 = 16'hbc00; 
    //vec1 is same
    start = 1'b1; #100; //Answer = bc00 repeating
    
    start = 1'b0; #12.5;
    s1 = 16'h7ccc;
    vec1 = 256'h7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde;
    start = 1'b1;#100; // Answer = 7c00 repeating
    
    start = 1'b0; #12.5;
    s1 = 16'h3c80;
    vec1 = 256'h0201020102010201020102010201020102010201020102010201020102010201;
    start = 1'b1; #100; // Answer = 0241 repeating
    $finish;
  end
endmodule


module t_SMULT16p_synth();

  wire [255:0] pro;
  wire ovf;
  reg [255:0] vec1;
  reg [15:0] s1;
  reg start, Clk1, Clk2;
  wire done;

  SMULT16p_synth S1(pro,ovf,Clk1, Clk2, s1,vec1,start,done);
  initial begin
    Clk1 = 1'b0;
    Clk2 = 1'b1;
    forever begin
      #5;
      Clk2 = ~Clk2;
      Clk1 = ~Clk1;
    end//forever
  end//clock


  initial $monitor("Product:%h Overflow:%b start:%b done:%b", pro, ovf, start, done);
  initial begin
    start = 1'b0; #12.5;
    s1 = 16'h3c00;
    vec1 = 256'h3c003c003c003c003c003c003c003c003c003c003c003c003c003c003c003c00;
    start = 1'b1; #100; //Answer = 3c00 repeating
    
    start = 1'b0; #12.5;
    s1 = 16'hbc00; 
    //vec1 is same
    start = 1'b1; #100; //Answer = bc00 repeating
    
    start = 1'b0; #12.5;
    s1 = 16'h7ccc;
    vec1 = 256'h7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde;
    start = 1'b1;#100; // Answer = 7c00 repeating
    
    start = 1'b0; #12.5;
    s1 = 16'h3c80;
    vec1 = 256'h0201020102010201020102010201020102010201020102010201020102010201;
    start = 1'b1; #100; // Answer = 0241 repeating
    $finish;
  end
endmodule

