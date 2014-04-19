module SMULT16(output [255:0] product,output V,
  input [15:0] scalar, input [255:0] vecin, input start, output done);

  wire [15:0] Ov;

  assign V = Ov[0] | Ov[1] | Ov[2] | Ov[3] | Ov[4] | Ov[5] | Ov[6] |
            Ov[7] | Ov[8] | Ov[9] | Ov[10] | Ov[11] | Ov[12] | Ov[13] | Ov[14]|Ov[15];

  assign done = start; //this module finishes operation in one cycle

  VMULT mult[15:0](.product(product), .Overflow(Ov[15:0]),
    .A(scalar), .B(vecin));

endmodule

module t_SMULT();

  wire [255:0] pro;
  wire ovf;
  reg [255:0] vec1;
  reg [15:0] s1;
  reg start;
  wire done;

  SMULT16 S1(pro,ovf,s1,vec1,start,done);

  initial $monitor("Product:%h Overflow:%b", pro, ovf);
  initial begin
    start = 1'b1;
    s1 = 16'h3c00;
    vec1 = 256'h3c003c003c003c003c003c003c003c003c003c003c003c003c003c003c003c00;
    #10; //Answer = 3c00 repeating
    s1 = 16'hbc00; 
    //vec1 is same
    #10; //Answer = bc00 repeating
    s1 = 16'h7ccc;
    vec1 = 256'h7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde7cde;
    #10; // Answer = 7c00 repeating
    s1 = 16'h3c80;
    vec1 = 256'h0201020102010201020102010201020102010201020102010201020102010201;
    #10; // Answer = 0241 repeating
    $finish;
  end
endmodule

