//-----------------------------------------------------------------------------
// Title         : sha256_main_calvar.v
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_main_calvar.v
// Author        : Vu Tien Luan <tienluan1607@gmail.com>
// Created       : 02.08.2018
// Last modified : 02.08.2018
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by Vu Tien Luan This model is the confidential and
// proprietary property of Vu Tien Luan and the possession or use of this
// file requires a written license from Vu Tien Luan.
//------------------------------------------------------------------------------
// Modification history :
// 02.08.2018 : created
//-----------------------------------------------------------------------------

module sha256_main_calvar
  (
   input         clk,
   input         reset_n,
   input         var_init,
   input         var_en,
   input [255:0] H_i1,
   input  [31:0] Kt,
   input  [31:0] Wt,
   output [31:0] a,
   output [31:0] b,
   output [31:0] c,
   output [31:0] d,
   output [31:0] e,
   output [31:0] f,
   output [31:0] g,
   output [31:0] h
   ) ;

  wire [31:0] var_a;
  wire [31:0] var_b;
  wire [31:0] var_c;
  wire [31:0] var_d;
  wire [31:0] var_e;
  wire [31:0] var_f;
  wire [31:0] var_g;
  wire [31:0] var_h;

  wire [31:0] var_a_pre;
  wire [31:0] var_b_pre;
  wire [31:0] var_c_pre;
  wire [31:0] var_d_pre;
  wire [31:0] var_e_pre;
  wire [31:0] var_f_pre;
  wire [31:0] var_g_pre;
  wire [31:0] var_h_pre;

  wire [31:0] T1;
  wire [31:0] T2;

  wire [31:0] E1_var_e;
  wire [31:0] Ch_var_efg;
  wire [31:0] E0_var_a;
  wire [31:0] Maj_var_abc;
  wire        var_ena;

  E0 E0_a ( .x(var_a), .y(E0_var_a) );
  E1 E1_e ( .x(var_e), .y(E1_var_e) );

  Ch Ch_efg   ( .x1(var_e), .x2(var_f), .x3(var_g), .y(Ch_var_efg ) );
  Maj Maj_abc ( .x1(var_a), .x2(var_b), .x3(var_c), .y(Maj_var_abc) );

  assign T1 = var_h + E1_var_e + Ch_var_efg + Kt + Wt;
  assign T2 = E0_var_a + Maj_var_abc;

//   assign var_a_pre = var_init ? H_i1[31 : 0 ] : T1 + T2;
//   assign var_b_pre = var_init ? H_i1[63 : 32] : a;
//   assign var_c_pre = var_init ? H_i1[95 : 64] : b;
//   assign var_d_pre = var_init ? H_i1[127: 96] : c;
//   assign var_e_pre = var_init ? H_i1[159:128] : d + T1;
//   assign var_f_pre = var_init ? H_i1[191:160] : e;
//   assign var_g_pre = var_init ? H_i1[223:192] : f;
//   assign var_h_pre = var_init ? H_i1[256:224] : g;
//   assign var_ena   = var_init | var_en;

   assign var_a_pre = var_init ? 32'h6a09e667 : T1 + T2;
   assign var_b_pre = var_init ? 32'hbb67ae85 : a;
   assign var_c_pre = var_init ? 32'h3c6ef372 : b;
   assign var_d_pre = var_init ? 32'ha54ff53a : c;
   assign var_e_pre = var_init ? 32'h510e527f : d + T1;
   assign var_f_pre = var_init ? 32'h9b05688c : e;
   assign var_g_pre = var_init ? 32'h1f83d9ab : f;
   assign var_h_pre = var_init ? 32'h5be0cd19 : g;
   assign var_ena   = var_en | var_init;

  sha256_regx #(.P_WIDTH(32), .P_INIT(32'h6a09e667)) regx_var_a (.clk(clk), .reset_n(reset_n), .en(var_ena), .D(var_a_pre), .Q(var_a));
  sha256_regx #(.P_WIDTH(32), .P_INIT(32'hbb67ae85)) regx_var_b (.clk(clk), .reset_n(reset_n), .en(var_ena), .D(var_b_pre), .Q(var_b));
  sha256_regx #(.P_WIDTH(32), .P_INIT(32'h3c6ef372)) regx_var_c (.clk(clk), .reset_n(reset_n), .en(var_ena), .D(var_c_pre), .Q(var_c));
  sha256_regx #(.P_WIDTH(32), .P_INIT(32'ha54ff53a)) regx_var_d (.clk(clk), .reset_n(reset_n), .en(var_ena), .D(var_d_pre), .Q(var_d));
  sha256_regx #(.P_WIDTH(32), .P_INIT(32'h510e527f)) regx_var_e (.clk(clk), .reset_n(reset_n), .en(var_ena), .D(var_e_pre), .Q(var_e));
  sha256_regx #(.P_WIDTH(32), .P_INIT(32'h9b05688c)) regx_var_f (.clk(clk), .reset_n(reset_n), .en(var_ena), .D(var_f_pre), .Q(var_f));
  sha256_regx #(.P_WIDTH(32), .P_INIT(32'h1f83d9ab)) regx_var_g (.clk(clk), .reset_n(reset_n), .en(var_ena), .D(var_g_pre), .Q(var_g));
  sha256_regx #(.P_WIDTH(32), .P_INIT(32'h5be0cd19)) regx_var_h (.clk(clk), .reset_n(reset_n), .en(var_ena), .D(var_h_pre), .Q(var_h));

  assign a = var_a;
  assign b = var_b;
  assign c = var_c;
  assign d = var_d;
  assign e = var_e;
  assign f = var_f;
  assign g = var_g;
  assign h = var_h;

endmodule // sha256_main_calvar

// Local Variables:
// verilog-library-directories:(".")
// verilog-library-files:("./sha256_lib.v")
// End:
