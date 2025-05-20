//******************************************************************************
// file:    axis_tiny_fifo.v
//
// author:  JAY CONVERTINO
//
// date:    2021/06/04
//
// about:   Brief
// AXIS TINY FIFO
//
// license: License MIT
// Copyright 2021 Jay Convertino
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
 * Module: axis_tiny_fifo
 *
 * AXIS fifo that uses a shift register to buffer data. This
 * Adds latency to the design in the amount of the FIFO_DEPTH. Though
 * if the destination isn't ready it will build up data to that
 * FIFO_DEPTH and overwrite any non-valid data inserted.
 *
 * Parameters:
 *
 *   FIFO_DEPTH    - Number of transactions to buffer.
 *   BUS_WIDTH     - Width of the input/output bus in bytes.
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
module axis_tiny_fifo #(
    parameter FIFO_DEPTH = 4,
    parameter BUS_WIDTH  = 8
  )
  (
    input                   aclk,
    input                   arstn,
    output [(BUS_WIDTH*8)-1:0]  m_axis_tdata,
    output                      m_axis_tvalid,
    output                      m_axis_tlast,
    input                       m_axis_tready,
    input  [(BUS_WIDTH*8)-1:0]  s_axis_tdata,
    input                       s_axis_tvalid,
    input                       s_axis_tlast,
    output                      s_axis_tready
  );
  
  `include "util_helper_math.vh"
  
  //index
  reg [clogb2(FIFO_DEPTH):0] index;
  reg [clogb2(FIFO_DEPTH):0] index_shift;
  reg [clogb2(FIFO_DEPTH):0] index_check;
  
  //buffer
  reg [(BUS_WIDTH*8)-1:0] reg_data_buffer[FIFO_DEPTH];
  reg [FIFO_DEPTH-1:0]    reg_valid_buffer  = 0;
  reg [FIFO_DEPTH-1:0]    reg_last_buffer   = 0;
  
  // var: s_axis_tready
  // If any valid is 0, we are ready for data
  assign s_axis_tready = (~&reg_valid_buffer || m_axis_tready) & arstn;
  
  // var: m_axis_tdata
  // assign output data as soon as its ready
  assign m_axis_tdata   = reg_data_buffer[0];

  // var: m_axis_tvalid
  // assign output data as soon as its ready
  assign m_axis_tvalid  = reg_valid_buffer[0];

  // var: m_axis_tlast
  // assign output data as soon as its ready
  assign m_axis_tlast   = reg_last_buffer[0];
  
  //process data out of fifo
  always @(posedge aclk) begin
    if(arstn == 1'b0) begin
      reg_valid_buffer <= 0;
      
      for(index = 0; index < FIFO_DEPTH; index = index + 1) begin
        reg_data_buffer[index] <= 0;
      end
    end else begin
      //insert data axis data into the buffer if we are ready, or the destination is ready. Otherwise feed in original data.
      reg_data_buffer[FIFO_DEPTH-1]  <= (~&reg_valid_buffer || m_axis_tready ? (s_axis_tvalid ? s_axis_tdata : 0) : reg_data_buffer[FIFO_DEPTH-1]);
      reg_valid_buffer[FIFO_DEPTH-1] <= (~&reg_valid_buffer || m_axis_tready ? s_axis_tvalid : reg_valid_buffer[FIFO_DEPTH-1]);
      reg_last_buffer[FIFO_DEPTH-1]  <= (~&reg_valid_buffer || m_axis_tready ? s_axis_tlast  : reg_last_buffer[FIFO_DEPTH-1]);
      
      //NAND all valids lower then current register. This results in all data being shifted below and including that index.
      //if any have 0 for valid (no data) shift. Also shift if ready, since destination is ready to take data anyways.
      for(index_shift = 1; index_shift < FIFO_DEPTH; index_shift = index_shift + 1) begin
        for(index_check = 0; index_check < index_shift; index_check = index_check + 1) begin
          if((m_axis_tready == 1'b1) || (reg_valid_buffer[index_check] == 1'b0)) begin
            reg_data_buffer[index_shift-1]  <= reg_data_buffer[index_shift];
            reg_valid_buffer[index_shift-1] <= reg_valid_buffer[index_shift];
            reg_last_buffer[index_shift-1]  <= reg_last_buffer[index_shift];
          end
        end
      end
    end
  end
endmodule
