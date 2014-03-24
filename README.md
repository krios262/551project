551project
==========

ECE551 Semester Project - Vector Coprocessor

The CVP14 is a vector coprocessor which shares memory with and receives instructions
from a processor.

It consists of a number of verilog modules:

CVP14: the top-level module

sReg: Stores 8 16-bit scalars. Arguments:
    * Addr: address
    * DataOut: outputs one scalar
    * DataIn: inputs one scalar
    * RD: reads (scalar at Addr outputs to DataOut)
    * WR: writes (stores DataIn to Addr)
    * WR_l: writes lower half (stores DataIn[7:0] to lower half of scalar at Addr)
    * WR_h: writes upper half (stores DataIn[15:8] to upper half of scalar at Addr)

    sReg uses the same two-phase clock system as the system memory defined in
        the project spec.
    

vReg: Stores 8 16x16-bit vectors. Can read and write in parallel (an entire vector at once,
      as a 256-bit value) or serially (each 16 bit element, from element 0 to 15, over 16
      clock cycles). Arguments:
    * Addr: address
    * DataOut_p: Parallel data out
    * DataOut_s: Serial data out 
    * DataIn_p: Parallel data in
    * DataIn_s: Serial data in
    * RD_p: Parallel read
    * WR_p: Parallel write
    * RD_s: Serial read (elements 0 to 15 appear at DataOut_s over 16 clocks)
    * WR_S: Serial write (elements 0 to 15 expected at DataIn_s over 16 clocks)

    vReg uses the same two-phase clock system as the system memory defined in
        the project spec.
