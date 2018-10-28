//-----------------------------------------------------------------------------
// Title         : sha256_main_ctrl.v
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_main_ctrl.v
// Author        : Vu Tien Luan <tienluan1607@gmail.com>
// Created       : 01.08.2018
// Last modified : 01.08.2018
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by Vu Tien Luan This model is the confidential and
// proprietary property of Vu Tien Luan and the possession or use of this
// file requires a written license from Vu Tien Luan.
//------------------------------------------------------------------------------
// Modification history :
// 01.08.2018 : created
//-----------------------------------------------------------------------------

module sha256_main_ctrl
  (
   input          clk       ,
   input          reset_n   ,
   input          w_vld     ,
   input [5:0]    w_cnt     ,
   input [255:0]  hash_val  ,
   output         var_en    ,
   output         hash_en   ,
   output         var_init  ,
   output         s_valid   ,
   output         hash_done ,
   output [255:0] s_data
   ) ;

  wire sig_hash_en_pre;
  wire sig_hash_en;

  assign sig_hash_en_pre = &w_cnt;
  sha256_reg #(.P_WIDTH(1)) reg_hash_en (.clk(clk), .reset_n(reset_n), .D(sig_hash_en_pre), .Q(sig_hash_en) );
  sha256_reg #(.P_WIDTH(1)) reg_s_valid (.clk(clk), .reset_n(reset_n), .D(sig_hash_en    ), .Q(s_valid    ) );

  assign var_en   = w_vld;
//  assign var_init = (~|w_cnt) & w_vld;
  assign var_init = sig_hash_en;
  assign hash_en  = sig_hash_en;
  assign s_data   = {256{s_valid}} & hash_val;
  assign hash_done= sig_hash_en;

endmodule // sha256_main_ctrl
