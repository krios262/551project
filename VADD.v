module VADD(sum,g_flag_op,done,a,b, start)
// Input are [256:0] A and B , start 
// Outputs is [256:0] Sum, done, g_flag_op 


output [255:0] sum;
input [255:0] a, b;
input start;
output done;
output g_flag_op;

reg [15:0] g_flag;

// Floation Point Addition function calls
always @ (start) begin
done =1'b0;
FADD f0 (sum[15:0],g_flag[0],a[15:0],b[15:0]);
FADD f1 (sum[31:16],g_flag[1],a[31:16],b[31:16]);
FADD f2 (sum[47:32],g_flag[2],a[47:32],b[47:32]);
FADD f3 (sum[63:48],g_flag[3],a[63:48],b[63:48]);
FADD f4 (sum[79:64],g_flag[4],a[79:64],b[79:64]);
FADD f5 (sum[95:80],g_flag[5],a[95:80],b[95:80]);
FADD f6 (sum[111:96],g_flag[6],a[111:96],b[111:96]);
FADD f7 (sum[127:112],g_flag[7],a[127:112],b[127:112]);
FADD f8 (sum[143:128],g_flag[8],a[143:128],b[143:128]);
FADD f9 (sum[159:144],g_flag[9],a[159:144],b[159:144]);
FADD f10 (sum[175:160],g_flag[10],a[175:160],b[175:160]);
FADD f11 (sum[191:176],g_flag[11],a[191:176],b[191:176]);
FADD f12 (sum[207:192],g_flag[12],a[207:192],b[207:192]);
FADD f13 (sum[223:208],g_flag[13],a[223:208],b[223:208]);
FADD f14 (sum[239:224],g_flag[14],a[239:224],b[239:224]);
FADD f15 (sum[255:240],g_flag[15],a[255:240],b[255:240]);

g_flag_op = g_flag[15] | g_flag[14] | g_flag[13] | g_flag[12] | g_flag[11] | g_flag[10] | g_flag[9] | g_flag[9] | g_flag[8] | g_flag[7] | g_flag[6] | g_flag[5] | g_flag[4] | g_flag[3] | g_flag[2] | g_flag[1] | g_flag[0];

done =1'b1;

end
endmodule
