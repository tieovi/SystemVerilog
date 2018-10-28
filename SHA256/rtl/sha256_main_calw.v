//-----------------------------------------------------------------------------
// Title         : sha256_main_calw.v
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_main_claw.v
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

module sha256_main_calw
  (
   input        clk,
   input        reset_n,
   input        w_vld,
   input [31:0] w_data,
   input [5:0]  w_cnt,
   output[31:0] Wt
   ) ;

  // Internal signal decleration
  wire [31:0] W_fifo     [0:15];
  wire [31:0] W_fifo_pre [0:15];
  wire        W_fifo_en        ;
  wire [31:0] Wt_out           ;
  wire [31:0] W_t16            ;
  wire [31:0] W_t15            ;
  wire [31:0] W_t07            ;
  wire [31:0] W_t02            ;

  wire [31:0] O0_W_t15         ;
  wire [31:0] O1_W_t02         ;

  //------------------------------------------------------------
  // Wt fifo logic
  assign W_fifo_en        = w_vld;
  assign W_fifo_pre[0]    = (|w_cnt[5:4]) ? Wt_out : w_data;
  // assign W_fifo_pre[1:15] = W_fifo[0:14];

  genvar idx_0;
  generate
    for(idx_0 = 1; idx_0 <= 15; idx_0 = idx_0 + 1) begin: W_fifo_pre_gen
      assign W_fifo_pre[idx_0] = W_fifo[idx_0-1];
    end
  endgenerate

  genvar idx_1;
  generate
    for(idx_1 = 0; idx_1 < 16; idx_1 = idx_1 + 1) begin: gen_w_fifo
      sha256_regx #(.P_WIDTH(32)) regx_W_fifo( .clk(clk), .reset_n(reset_n), .en(W_fifo_en), .D(W_fifo_pre[idx_1]), .Q(W_fifo[idx_1]));
    end
  endgenerate

  assign W_t16 = W_fifo[15];
  assign W_t15 = W_fifo[14];
  assign W_t07 = W_fifo[06];
  assign W_t02 = W_fifo[01];


  //------------------------------------------------------------
  // W_t_out calculation
  O0 O0_of_Wt15(.x(W_t15), .y(O0_W_t15));
  O1 O1_if_Wt02(.x(W_t02), .y(O1_W_t02));

  assign Wt_out = O1_W_t02 + W_t07 + O0_W_t15 + W_t16;

  //------------------------------------------------------------
  // Wt output selection
  assign Wt = |w_cnt[5:4] ? Wt_out : w_data;

endmodule // sha256_main_calw
