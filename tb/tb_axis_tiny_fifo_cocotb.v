//******************************************************************************
/// @file    tb_axis_tiny_fifo_cocotb.v
/// @author  JAY CONVERTINO
/// @date    2024.12.03
/// @brief   cocotb axis tiny fifo test bench top.
///
/// @LICENSE MIT
///  Copyright 2024 Jay Convertino
///
///  Permission is hereby granted, free of charge, to any person obtaining a copy
///  of this software and associated documentation files (the "Software"), to 
///  deal in the Software without restriction, including without limitation the
///  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
///  sell copies of the Software, and to permit persons to whom the Software is 
///  furnished to do so, subject to the following conditions:
///
///  The above copyright notice and this permission notice shall be included in 
///  all copies or substantial portions of the Software.
///
///  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
///  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
///  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
///  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
///  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
///  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
///  IN THE SOFTWARE.
//******************************************************************************

`timescale 1 ns/10 ps

module tb_axis_tiny_fifo_cocotb #(
    parameter FIFO_DEPTH = 4,
    parameter BUS_WIDTH  = 8
  )
  (
    input                       aclk,
    input                       arstn,
    output [(BUS_WIDTH*8)-1:0]  m_axis_tdata,
    output                      m_axis_tvalid,
    output                      m_axis_tlast,
    input                       m_axis_tready,
    input  [(BUS_WIDTH*8)-1:0]  s_axis_tdata,
    input                       s_axis_tvalid,
    input                       s_axis_tlast,
    output                      s_axis_tready
  );
  // fst dump command
  initial begin
    $dumpfile ("tb_axis_tiny_fifo_cocotb.fst");
    $dumpvars (0, tb_axis_tiny_fifo_cocotb);
    #1;
  end
  
  axis_tiny_fifo #(
    .FIFO_DEPTH(FIFO_DEPTH),
    .BUS_WIDTH(BUS_WIDTH)
  ) dut (
    // input
    .aclk(aclk),
    .arstn(arstn),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tlast(s_axis_tlast),
    // output
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tdata(m_axis_tdata)
  );
  
endmodule

