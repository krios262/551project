module VADD16(output [255:0] SumV,output V,input [255:0] A,input [255:0] B,input start,output done);

  wire [15:0] Ov;

  assign V = Ov[0] |Ov[1] | Ov[2] | Ov[3] | Ov[4] | Ov[5] | Ov[6] | Ov[7] | Ov[8] | Ov[9] | Ov[10] | Ov[11] | Ov[12] | Ov[13] | Ov[14] | Ov[15] ; 
  assign done = start;

  VADD adder[15:0](SumV,Ov,A,B);
  /*
  VADD add1(SumV[15:0],Ov[0],A[15:0],B[15:0]);
  VADD add2(SumV[31:16],Ov[1],A[31:16],B[31:16]);
  VADD add3(SumV[47:32],Ov[2],A[47:32],B[47:32]);
  VADD add4(SumV[63:48],Ov[3],A[63:48],B[63:48]);
  VADD add5(SumV[79:64],Ov[4],A[79:64],B[79:64]);
  VADD add6(SumV[95:80],Ov[5],A[95:80],B[95:80]);
  VADD add7(SumV[111:96],Ov[6],A[111:96],B[111:96]);
  VADD add8(SumV[127:112],Ov[7],A[127:112],B[127:112]);
  VADD add9(SumV[143:128],Ov[8],A[143:128],B[143:128]);
  VADD add10(SumV[159:144],Ov[9],A[159:144],B[159:144]);
  VADD add11(SumV[175:160],Ov[10],A[175:160],B[175:160]);
  VADD add12(SumV[191:176],Ov[11],A[191:176],B[191:176]);
  VADD add13(SumV[207:192],Ov[12],A[207:192],B[207:192]);
  VADD add14(SumV[223:208],Ov[13],A[223:208],B[223:208]);
  VADD add15(SumV[239:224],Ov[14],A[239:224],B[239:224]);
  VADD add16(SumV[255:240],Ov[15],A[255:240],B[255:240]);
  */

endmodule
