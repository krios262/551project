module CVP14(output [15:0] Addr, output RD, output WR, output V, output U,
    output [15:0] DataOut, input Reset, input Clk1, input Clk2, input [15:0] DataIn);

//Parameters for opcodes
parameter vaad = 4'b0000, vdot = 4'b0001, smul = 4'b0010, sst = 4'b0011, vld = 4'b0100,
          vst = 4'b0101,  sll = 4'b0110,  slh = 4'b0111,  j = 4'b1000,   nop = 4'b1111;
          
//Decode the data to branch to the proper operation
always @(DataIn) begin
  case (DataIn[15:12])
    vaad:
    vdot:
    smul:
    sst:
    vld:
    vst:
    sll:
    slh:
    j:
    nop:
  endcase
end//End Opcode decode

//Overflow/underflow condition
always @(U, V) begin
  
end//End overflow/underflow
endmodule
