/*
 * Copyright (c) 2024 Tommy Thorn
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`define N 30

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

   reg [`N-1:0]	      a;
   reg [`N-1:0]	      aa;

   always @(posedge clk)
     if (rst_n == 0)
       a <= 0;
     else begin
	aa <= a * a;
	a <= a + 1;
     end
	
   assign uio_oe  = ~0;
   assign {uo_out,uio_out} = aa[`N-1:`N-16];

   // List all unused inputs to prevent warnings
   wire _unused = &{ena, clk, rst_n, 1'b0, ui_in };
endmodule
