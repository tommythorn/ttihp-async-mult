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
        // JUST TO BE CLEAR, yes I know this could simply have been
        // `aa <= aa + a * 2 - 1` but that's not the point.
        aa <= a * a;
        a <= a + 1;
     end
`else
   /* Iterative multiplier using carry-save */
   reg s0;
   wire [`N-1:0] carry_out, sum_out;
   reg [`N-1:0] c, a1, carry, sum;
   reg		c_is_zero, carry_is_zero;

   genvar        i;
   generate
      for (i = 0; i < `N; i = i + 1)
        sky130_fd_sc_hd__fa_1 fa(.COUT(carry_out[i]), .SUM(sum_out[i]), .A(a1[i] & c[0]), .B(sum[i]), .CIN(carry[i]));
   endgenerate

   always @(posedge clk)
     if (!rst_n) begin
        a <= 0;
	sum <= 0;
        s0 <= 1;
     end else if (s0) begin
        carry <= 0;
        sum <= 0;
        c <= sum ^ 3;
        a1 <= sum ^ 3;
        s0 <= 0;
	c_is_zero <= 0;
	carry_is_zero <= 0;
        $display("");
        $display("Start %1d^2", sum^3);
     end else /* !s0 */ begin
        $display("  iterate %d, %d, %d, %d", carry, sum, c, a1);
        carry <= carry_out << 1;
        sum <= sum_out;
        c <= c >> 1;
        a1 <= a1 << 1;

        if (c_is_zero && carry_is_zero) begin
           aa <= sum;
           s0 <= 1;
           $display("Result %d", sum);
        end

	// Pipeline
	c_is_zero <= c == 0;
	carry_is_zero <= carry_is_zero == 0;
     end
`endif

   assign uio_oe  = ~0;
   assign {uo_out,uio_out} = aa[`N-1:`N-16];

   // List all unused inputs to prevent warnings
   wire _unused = &{ena, clk, rst_n, 1'b0, ui_in, uio_in };

endmodule

`ifdef SIM
module sky130_fd_sc_hd__fa_1(COUT, SUM, A, B, CIN);
   output COUT;
   output SUM ;
   input  A   ;
   input  B   ;
   input  CIN ;

   assign COUT = B & CIN | (CIN | B) & A;
   assign SUM  = ((A | CIN | B) & !(B & CIN | (CIN | B) & A)) | CIN & A & B;
endmodule

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
