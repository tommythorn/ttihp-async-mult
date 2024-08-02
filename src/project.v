/*
 * Copyright (c) 2024 Tommy Thorn
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

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

   // A very simple 2 entry 1b wide sync sram
   // Inputs
   // - clock
   // - we
   // - wa
   // - wd
   // - ra
   // Ouput
   // - rq
   //
   // The style here is deliberately explicit
   reg		      sram0, sram1;
   wire		      we, wa, wd, ra, rq;
   assign {we, wa, wd, ra} = ui_in;
   assign uo_out = ra == 0 ? sram0 : sram1;
   always @(posedge clk)
     if (we)
       if (wa == 0)
	 sram0 <= wd;
       else 
	 sram1 <= wd;

   // All output pins must be assigned. If not used, assign to 0.
   assign uio_out = 0;
   assign uio_oe  = 0;

   // List all unused inputs to prevent warnings
   wire		      _unused = &{ena, clk, rst_n, 1'b0, ui_in[7:4]};
endmodule
