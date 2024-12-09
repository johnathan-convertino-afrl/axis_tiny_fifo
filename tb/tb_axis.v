//******************************************************************************
// file:    tb_axis.v
//
// author:  JAY CONVERTINO
//
// date:    2024/12/09
//
// about:   Brief
// Test bench for axis_tiny_fifo using axis stim and clock stim.
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
 * Module: tb_axis
 *
 * Test bench for axis_tiny_fifo. This will run a file through the system
 * and write its output. These can then be compared to check for errors.
 * If the files are identical, no errors. A FST file will be written.
 *
 * Parameters:
 *
 *   IN_FILE_NAME  - File name for input.
 *   OUT_FILE_NAME - File name for output.
 *   RAND_READY    - 0 = no random ready. 1 = randomize ready.
 *   FIFO_DEPTH    - Number of transactions to buffer.
 *
 */
module tb_axis #(
  parameter IN_FILE_NAME = in.bin,
  parameter OUT_FILE_NAME = out.bin,
  parameter RAND_READY = 0,
  parameter FIFO_DEPTH = 8);
  
  localparam BUS_WIDTH  = 2;
  localparam USER_WIDTH = 1;
  localparam DEST_WIDTH = 1;
  
  wire                      tb_dut_valid;
  wire                      tb_dut_ready;
  wire [(BUS_WIDTH*8)-1:0]  tb_dut_data;
  wire [BUS_WIDTH-1:0]      tb_dut_keep;
  wire                      tb_dut_last;
  wire [USER_WIDTH-1:0]     tb_dut_user;
  wire [DEST_WIDTH-1:0]     tb_dut_dest;
  
  wire                      tb_stim_clk;
  wire                      tb_stim_rstn;
  wire                      tb_stim_valid;
  wire [(BUS_WIDTH*8)-1:0]  tb_stim_data;
  wire [BUS_WIDTH-1:0]      tb_stim_keep;
  wire                      tb_stim_last;
  wire [USER_WIDTH-1:0]     tb_stim_user;
  wire [DEST_WIDTH-1:0]     tb_stim_dest;
  
  wire                      tb_eof;
  
  // fst dump command
  initial begin
    $dumpfile ("tb_axis.fst");
    $dumpvars (0, tb_axis);
    #1;
  end
  
  //Group: Instantiated Modules

  /*
   * Module: clk_stim
   *
   * Generate a 50/50 duty cycle set of clocks and reset.
   */
  clk_stimulus #(
    .CLOCKS(1),
    .CLOCK_BASE(1000000),
    .CLOCK_INC(1000),
    .RESETS(1),
    .RESET_BASE(2000),
    .RESET_INC(100)
  ) clk_stim (
    .clkv(tb_stim_clk),
    .rstnv(tb_stim_rstn),
    .rstv()
  );
  
  /*
   * Module: slave_axis_stim
   *
   * Device under test SLAVE stimulus module.
   */
  slave_axis_stimulus #(
    .BUS_WIDTH(BUS_WIDTH),
    .USER_WIDTH(USER_WIDTH),
    .DEST_WIDTH(DEST_WIDTH),
    .FILE(IN_FILE_NAME)
  ) slave_axis_stim (
    .m_axis_aclk(tb_stim_clk),
    .m_axis_arstn(tb_stim_rstn),
    .m_axis_tvalid(tb_stim_valid),
    .m_axis_tready(tb_stim_ready),
    .m_axis_tdata(tb_stim_data),
    .m_axis_tkeep(tb_stim_keep),
    .m_axis_tlast(tb_stim_last),
    .m_axis_tuser(tb_stim_user),
    .m_axis_tdest(tb_stim_dest),
    .eof(tb_eof)
  );
  
  /*
   * Module: dut
   *
   * Device under test, axis_tiny_fifo
   */
  axis_tiny_fifo #(
    .FIFO_DEPTH(FIFO_DEPTH),
    .BUS_WIDTH(BUS_WIDTH)
  ) dut (
    .aclk(tb_stim_clk),
    .arstn(tb_stim_rstn),
    .s_axis_tvalid(tb_stim_valid),
    .s_axis_tready(tb_stim_ready),
    .s_axis_tdata(tb_stim_data),
    .s_axis_tlast(tb_stim_last),
    .m_axis_tvalid(tb_dut_valid),
    .m_axis_tready(tb_dut_ready),
    .m_axis_tlast(tb_dut_last),
    .m_axis_tdata(tb_dut_data)
  );
  
  /*
   * Module: master_axis_stim
   *
   * Devie under test MASTER stimulus module.
   */
  master_axis_stimulus #(
    .BUS_WIDTH(BUS_WIDTH),
    .USER_WIDTH(USER_WIDTH),
    .DEST_WIDTH(DEST_WIDTH),
    .RAND_READY(RAND_READY),
    .FILE(OUT_FILE_NAME)
  ) master_axis_stim (
    .s_axis_aclk(tb_stim_clk),
    .s_axis_arstn(tb_stim_rstn),
    .s_axis_tvalid(tb_dut_valid),
    .s_axis_tready(tb_dut_ready),
    .s_axis_tdata(tb_dut_data),
    .s_axis_tkeep(tb_dut_keep),
    .s_axis_tlast(tb_dut_last),
    .s_axis_tuser(tb_dut_user),
    .s_axis_tdest(tb_dut_dest),
    .eof(1'b0)
  );
  
endmodule

