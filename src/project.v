/*
 * Copyright (c) 2024 Tommy Thorn
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`timescale 1ns / 1ns

`include "tokenflow.h"

module tt_um_tommythorn_experiments (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

   parameter          w = 16;
   wire               reset = !rst_n;
   wire               `chan ou_ch;
   wire               dummy;

   tokenflow #(w) tokenflow_inst(reset, ou_ch);

   assign uio_oe = ~0;
   assign {dummy, uio_out, uo_out} = {ou_ch`data, ou_ch`req};
   assign ou_ch`ack = ui_in[0];

   // List all unused inputs to prevent warnings
   wire _unused = &{ena, clk, rst_n, 1'b0, ui_in, uio_in };
endmodule

`ifdef SIM
module tb;
   reg clk, rst_n;
   wire [14:0] data;
   wire        req;
   wire [7:0]  ui_in;

   tt_um_tommythorn_experiments
     insn(.clk(clk), .rst_n(rst_n),
          .ui_in(ui_in), .uio_out(data[14:7]), .uo_out({data[6:0],req}));

   // Tie ACK to REQ for a continous stream of 0, 2, 6, 12, 20, ..., x*(x+1)
   assign ui_in[0] = req;

   always @(posedge req)
     $display("Got %d", data);

   always #5 clk = !clk;
   initial begin
      clk = 1;
      rst_n = 0;

      $display("Starting Sim");

      #20
        rst_n = 1;
      #20000 $finish;
   end
endmodule
`endif
