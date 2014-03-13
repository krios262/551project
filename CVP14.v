module CVP14(output [15:0] Addr, output RD, output WR, output V, output U,
    output [15:0] DataOut, input Reset, input Clk1, input Clk2, input [15:0] DataIn);

//Parameters for opcodes
parameter VAAD = 4'b0000, VDOT = 4'b0001, SMUL = 4'b0010, SST = 4'b0011, VLD = 4'b0100,
          VST = 4'b0101,  SLL = 4'b0110,  SLH = 4'b0111,  J = 4'b1000,   NOP = 4'b1111;

endmodule
