//******************************************************************************
// file:    tb_coctb.v
//
// author:  JAY CONVERTINO
//
// date:    2024/12/09
//
// about:   Brief
// Test bench wrapper for cocotb
//
// license: License MIT
// Copyright 2024 Jay Convertino
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
//******************************************************************************

`timescale 1ns/100ps

/*
 * Module: tb_cocotb
 *
 * Test bench for axis_tiny_fifo. This will run a file through the system
 * and write its output. These can then be compared to check for errors.
 * If the files are identical, no errors. A FST file will be written.
 *
 * Parameters:
 *
 *   FIFO_DEPTH    - Number of transactions to buffer.
 *   BUS_WIDTH     - Number of bytes for tdata width.
 *
 * Ports:
 *
 *   aclk           - Clock for AXIS
 *   arstn          - Negative reset for AXIS
 *   m_axis_tdata   - Output data
 *   m_axis_tvalid  - When active high the output data is valid
 *   m_axis_tlast   - Indicates last word in stream.
 *   m_axis_tready  - When set active high the output device is ready for data.
 *   s_axis_tdata   - Input data
 *   s_axis_tvalid  - When set active high the input data is valid
 *   s_axis_tlast   - Is this the last word in the stream (active high).
 *   s_axis_tready  - When active high the device is ready for input data.
 */
module tb_cocotb #(
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
    $dumpfile ("tb_cocotb.fst");
    $dumpvars (0, tb_cocotb);
    #1;
  end
  
  //Group: Instantiated Modules

  /*
   * Module: dut
   *
   * Device under test, axis_tiny_fifo
   */
  axis_tiny_fifo #(
    .FIFO_DEPTH(FIFO_DEPTH),
    .BUS_WIDTH(BUS_WIDTH)
  ) dut (
    .aclk(aclk),
    .arstn(arstn),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tlast(s_axis_tlast),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tdata(m_axis_tdata)
  );
  
endmodule

