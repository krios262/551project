module SMUL16(output reg [255:0] product,output reg Ovf, input [15:0] scalar,input [255:0] vecin);

  MULT(product[255:240],Ovf,scalar[15:0], vecin[255:240]);
  MULT(product[239:224],Ovf,scalar[15:0], vecin[239:224]);
  MULT(product[223:208],Ovf,scalar[15:0], vecin[223:208]);
  MULT(product[207:192],Ovf,scalar[15:0], vecin[207:192]);
  MULT(product[191:176],Ovf,scalar[15:0], vecin[191:176]);
  MULT(product[175:160],Ovf,scalar[15:0], vecin[175:160]);
  MULT(product[159:144],Ovf,scalar[15:0], vecin[159:144]);
  MULT(product[143:128],Ovf,scalar[15:0], vecin[143:128]);
  MULT(product[127:112],Ovf,scalar[15:0], vecin[127:112]);
  MULT(product[111:96],Ovf,scalar[15:0], vecin[111:96]);
  MULT(product[95:80],Ovf,scalar[15:0], vecin[95:80]);
  MULT(product[79:64],Ovf,scalar[15:0], vecin[79:64]);
  MULT(product[63:48],Ovf,scalar[15:0], vecin[63:48]);
  MULT(product[47:32],Ovf,scalar[15:0], vecin[47:32]);
  MULT(product[31:16],Ovf,scalar[15:0], vecin[31:16]);
  MULT(product[15:0],Ovf,scalar[15:0], vecin[15:0]);

endmodule

module t_MULT16();
  
  wire [255:0] pro;
  
  reg [255:0] vec1;
  reg [15:0] s1;
  
  SMUL16 S1(pro,s1,vec1);
  
  initial begin
    s1 = 16'hA;
    vec1 = 256'h00010203;
    #10 vec1 = 256'h00020304;
    #20 vec1 = 256'h0406080a;
end
endmodule

