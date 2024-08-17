/*
 * Copyright (c) 2024 Tommy Thorn
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`define N 23

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

   reg [`N-1:0]       a;
   reg [`N-1:0]       aa;

`ifdef SIMPLE_MULT
   always @(posedge clk)
     if (rst_n == 0)
       a <= 0;
     else begin
        aa <= a * a;
        a <= a + 1;
     end
`else
   /* Iterative multiplier using carry-save */
   reg s0;
   reg [`N-1:0] sp, sn, c, a1;
   wire [`N-1:0] add = c & 1 ? a1 : 0;
   always @(posedge clk)
     if (rst_n == 0) begin
        a <= 0;
        s0 <= 1;
     end else if (s0) begin
        sp <= 0;
        sn <= ~0;
        c <= a;
        a1 <= a;
        a <= a + 1;
        s0 <= 0;
        $display("");
        $display("Start %1d * %1d", a, a);
     end else /* !s0 */ begin
        if (c == 0 && sp == 0) begin
           aa <= ~sn;
           s0 <= 1;
           $display("  iterate %d, %d, %d, %d, %d", sp, ~sn, c, a1, add);
           $display("Result %d", ~sn);
        end else begin
           $display("  iterate %d, %d, %d, %d, %d", sp, ~sn, c, a1, add);
           sp <= (sp & ~sn | add & (sp | ~sn)) << 1;
           sn <= sp ^ sn ^ add;
           c <= c >> 1;
           a1 <= a1 << 1;
        end
     end
`endif
        
   assign uio_oe  = ~0;
   assign {uo_out,uio_out} = aa[`N-1:`N-16];

   // List all unused inputs to prevent warnings
   wire _unused = &{ena, clk, rst_n, 1'b0, ui_in, uio_in };

endmodule

`ifdef SIM
module tb;
   reg clk, rst_n;

   tt_um_tommythorn_experiments insn(.clk(clk), .rst_n(rst_n));
   always #5 clk = !clk;
   initial begin
      clk = 1;
      rst_n = 0;

      $display("Starting Sim");

      #20
        rst_n = 1;
      #10000 $finish;
   end
endmodule
`endif
