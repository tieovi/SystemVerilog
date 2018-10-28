//-----------------------------------------------------------------------------
// Title         : sha256_main_calhash
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_main_calhash.v
// Author        : Vu Tien Luan  <tienluan1607@gmail.com>
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
// 05.08.2018 : implement functional
//-----------------------------------------------------------------------------

module sha256_main_calhash
  (
   input          clk,
   input          reset_n,
   input [31:0]   a,
   input [31:0]   b,
   input [31:0]   c,
   input [31:0]   d,
   input [31:0]   e,
   input [31:0]   f,
   input [31:0]   g,
   input [31:0]   h,
   input          hash_en,

   output [255:0] hash_val
   ) ;

  localparam HASH_INIT0 = 32'h6a09e667;
  localparam HASH_INIT1 = 32'hbb67ae85;
  localparam HASH_INIT2 = 32'h3c6ef372;
  localparam HASH_INIT3 = 32'ha54ff53a;
  localparam HASH_INIT4 = 32'h510e527f;
  localparam HASH_INIT5 = 32'h9b05688c;
  localparam HASH_INIT6 = 32'h1f83d9ab;
  localparam HASH_INIT7 = 32'h5be0cd19;

  wire   [31:0] hash_val_pre0;
  wire   [31:0] hash_val_pre1;
  wire   [31:0] hash_val_pre2;
  wire   [31:0] hash_val_pre3;
  wire   [31:0] hash_val_pre4;
  wire   [31:0] hash_val_pre5;
  wire   [31:0] hash_val_pre6;
  wire   [31:0] hash_val_pre7;

  wire   [31:0] hash_val0;
  wire   [31:0] hash_val1;
  wire   [31:0] hash_val2;
  wire   [31:0] hash_val3;
  wire   [31:0] hash_val4;
  wire   [31:0] hash_val5;
  wire   [31:0] hash_val6;
  wire   [31:0] hash_val7;

//   assign hash_val_pre0 = hash_val[255:224] + a;
//   assign hash_val_pre1 = hash_val[223:192] + b;
//   assign hash_val_pre2 = hash_val[191:160] + c;
//   assign hash_val_pre3 = hash_val[159:128] + d;
//   assign hash_val_pre4 = hash_val[127: 96] + e;
//   assign hash_val_pre5 = hash_val[ 95: 64] + f;
//   assign hash_val_pre6 = hash_val[ 63: 32] + g;
//   assign hash_val_pre7 = hash_val[ 31:  0] + h;

  assign hash_val_pre0 = HASH_INIT0 + a;
  assign hash_val_pre1 = HASH_INIT1 + b;
  assign hash_val_pre2 = HASH_INIT2 + c;
  assign hash_val_pre3 = HASH_INIT3 + d;
  assign hash_val_pre4 = HASH_INIT4 + e;
  assign hash_val_pre5 = HASH_INIT5 + f;
  assign hash_val_pre6 = HASH_INIT6 + g;
  assign hash_val_pre7 = HASH_INIT7 + h;

  sha256_regx #(.P_WIDTH(32), .P_INIT(HASH_INIT0))
               regx_hash_val0 (.clk(clk), .reset_n(reset_n), .en(hash_en), .D(hash_val_pre0), .Q(hash_val0));
  sha256_regx #(.P_WIDTH(32), .P_INIT(HASH_INIT1))
               regx_hash_val1 (.clk(clk), .reset_n(reset_n), .en(hash_en), .D(hash_val_pre1), .Q(hash_val1));
  sha256_regx #(.P_WIDTH(32), .P_INIT(HASH_INIT2))
               regx_hash_val2 (.clk(clk), .reset_n(reset_n), .en(hash_en), .D(hash_val_pre2), .Q(hash_val2));
  sha256_regx #(.P_WIDTH(32), .P_INIT(HASH_INIT3))
               regx_hash_val3 (.clk(clk), .reset_n(reset_n), .en(hash_en), .D(hash_val_pre3), .Q(hash_val3));
  sha256_regx #(.P_WIDTH(32), .P_INIT(HASH_INIT4))
               regx_hash_val4 (.clk(clk), .reset_n(reset_n), .en(hash_en), .D(hash_val_pre4), .Q(hash_val4));
  sha256_regx #(.P_WIDTH(32), .P_INIT(HASH_INIT5))
               regx_hash_val5 (.clk(clk), .reset_n(reset_n), .en(hash_en), .D(hash_val_pre5), .Q(hash_val5));
  sha256_regx #(.P_WIDTH(32), .P_INIT(HASH_INIT6))
               regx_hash_val6 (.clk(clk), .reset_n(reset_n), .en(hash_en), .D(hash_val_pre6), .Q(hash_val6));
  sha256_regx #(.P_WIDTH(32), .P_INIT(HASH_INIT7))
               regx_hash_val7 (.clk(clk), .reset_n(reset_n), .en(hash_en), .D(hash_val_pre7), .Q(hash_val7));

  assign hash_val = {hash_val0, hash_val1, hash_val2, hash_val3, hash_val4, hash_val5, hash_val6, hash_val7};

endmodule // sha256_main_calhash

// Local Variables:
// verilog-library-directories:(".")
// End:
