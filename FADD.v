module FADD (sum,a,b)
parameter BITS = 16;

// Initilizing variables
input [BITS-1:0] a,b;
output [BITS-1:0] sum;
reg a_sign,b_sign;
reg [4:0] a_exp,b_exp;
reg [10:0] a_man, b_man;
// Separting the signed bit , mantisa and exponent
a_sign = a[BITS-1]; // Signed Bit
b_sign = b[BITS-1];

a_exp[4:0] = a[14:10]; // Exponents
b_exp[4:0] = b[14:10];

a_man[12:0] = {1'b1, a[9:0],2'b0}; // Mantisa with the hidden bit 1 and 1 gaurd bit + 1 Round Bit
b_man[12:0] = {1'b1, b[9:0],2'b0};

// Subtract the exponents
a_exp_gt_b_exp = (a_exp > b_exp) ? 1 :0;
a_exp_lt_b_exp = (a_exp < b_exp) ? 1 :0;


// Subtract the exponents
if(a_exp_gt_b_exp) begin
e_diff = a_exp - b_exp; // Difference between the exponents
b_man_gr [12:0] = b_man[12:0] >> (e_diff+2); // Shift the lower exponent with diff+2 times
// Sticky Bit Logic 
for(i=0;i<e_diff;i=i+1) begin
a_man[i+2] 


// To check if the sticky bit is set or not
if(e_diff >2) begin // If Number of shifts is greater than 2 , the Stick bit is the OR of the other MSB bits
b_man_grs [13:0] = {b_man_gr [12:0],//Sticky Bit is 1/0};
end
else begin
b_man_grs [13:0] = {b_man_gr[12:0], 1'b0};
end

end
sum_exp = a_exp;
sum_man = a_man + b_man;
end


if (a_exp_lt_b_exp) begin
e_diff = b_exp - a_exp;
a_man >> e_diff;
sum_exp = a_exp;
sum_man = a_man + b_man;
end

if(a_exp == b_exp) begin
sum_exp = a_exp;
sum_man = a_man + b_man;
end

endmodule 




