`timescale 1 ns / 1 ps
module DRAM(DataOut, Addr, DataIn, clk1, clk2, RD, WR);
parameter WordSize=16;
parameter AddrWidth=16;
localparam MemSize  = (1 << AddrWidth);
input [AddrWidth-1:0] Addr;
input [WordSize-1:0]  DataIn;
output reg [WordSize-1:0]  DataOut;
input clk1, clk2, RD, WR;

reg [AddrWidth-1:0] mAddr;
reg [WordSize-1:0] Memory [0:MemSize-1];
reg [WordSize-1:0] mData;

always @(posedge clk1) begin
   if (RD == 1'b1) begin
        DataOut <= Memory[mAddr];
//        $strobe($time, " clk1 = %b clk2 = %b MemAddr = %d DataOut = %d\n", clk1, clk2, mAddr, DataOut);
   end
   else begin
        if (WR == 1'b1) begin
           Memory[mAddr] <= DataIn;
//           $strobe($time, " clk1 = %b clk2 = %b MemAddr = %d DataIn = %d\n", clk1, clk2, mAddr, DataIn);
        end
        else begin
             DataOut <= {WordSize{1'bx}};
        end
   end
end
always @(posedge clk2) begin
    mAddr <= Addr;
end

initial begin
  $readmemb("mem.list", Memory);
end
endmodule

module t_DRAM;
parameter WordSize=16;
parameter AddrWidth=16;
reg [AddrWidth-1:0] MemAddr;
reg [WordSize-1:0] MemDataIn;  
wire [WordSize-1:0] MemDataOut;
reg RD, WR;
reg clk1, clk2;

reg [1:0] count;
reg sclk;

 DRAM my_mem(MemDataOut, MemAddr, MemDataIn, clk1, clk2, RD, WR);

 initial begin
   $monitor($time, " clk1 = %b clk2 = %b MemAddr = %d RD = %b WR = %b DataIn = %d DataOut = %d\n", clk1, clk2, MemAddr, 
             RD, WR, MemDataIn, MemDataOut);
 end

 initial begin
   clk1 = 0;
   clk2 = 0;
   count = 2'b11;
   #100 $finish;
 end

 always @(count) begin
    clk1 = (~count[1] & ~count[0]);
    clk2 = (count[1] & ~count[0]);
 end

 always @(posedge sclk) begin
    count <= count + 1;
 end

 initial begin
   sclk = 0;
   forever begin
    #1 sclk = ~sclk;
   end
 end
   
 initial begin
    RD  = 1'b0;
    WR  = 1'b0;
  #1 MemAddr = 16'b0000_0000_0000_1010; 
  #4 RD      = 1'b1;
  #4 MemAddr = 16'bxxxx_xxxx_xxxx_xxxx;
  #4 RD      = 1'b0;
  #4 MemAddr = 16'b0000_0000_0000_0001; 
  #4 RD      = 1'b1;
  #4 MemAddr = 16'bxxxx_xxxx_xxxx_xxxx;
  #4 RD      = 1'b0;
  #4 MemAddr = 16'b0000_0000_0000_0010; 
  #4 WR      = 1'b1; MemDataIn = 16'b0000_0110_1100_1111;
  #4 MemAddr = 16'bxxxx_xxxx_xxxx_xxxx;
  #4 WR      = 1'b0;
  #4 MemAddr = 16'b0000_0000_0000_0010; 
  #4 RD      = 1'b1;
  #4 MemAddr = 16'bxxxx_xxxx_xxxx_xxxx;
  #4 RD      = 1'b0;
 end
endmodule
