//-----------------------------------------------------------------------------
// Title         : sha256_top
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_to.v
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
// 09.08.2018 : created
//-----------------------------------------------------------------------------
module sha256_top
  (
   input          clk       ,
   input          reset_n   ,

   input          m_valid   ,
   input [31:0]   m_data    ,
   input          m_last    ,
//   input [1:0]    m_last_sz ,

   output         m_ready   ,
   output         s_valid   ,
   output [255:0] s_data
   ) ;

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire                  hash_done;              // From sha256_main of sha256_main.v
  wire [5:0]            w_cnt;                  // From sha256_pad of sha256_pad.v
  wire [31:0]           w_data;                 // From sha256_pad of sha256_pad.v
  wire                  w_vld;                  // From sha256_pad of sha256_pad.v
  // End of automatics

  sha256_pad sha256_pad
    (/*AUTOINST*/
     // Outputs
     .m_ready                           (m_ready),
     .w_vld                             (w_vld),
     .w_cnt                             (w_cnt[5:0]),
     .w_data                            (w_data[31:0]),
     // Inputs
     .clk                               (clk),
     .reset_n                           (reset_n),
     .m_valid                           (m_valid),
     .m_data                            (m_data[31:0]),
     .m_last                            (m_last),
//     .m_last_sz                         (m_last_sz[1:0]),
     .hash_done                         (hash_done));
  sha256_main sha256_main
    (/*AUTOINST*/
     // Outputs
     .hash_done                         (hash_done),
     .s_valid                           (s_valid),
     .s_data                            (s_data[255:0]),
     // Inputs
     .clk                               (clk),
     .reset_n                           (reset_n),
     .w_vld                             (w_vld),
     .w_cnt                             (w_cnt[5:0]),
     .w_data                            (w_data[31:0]));

endmodule // sha256_top

// Local Variables:
// verilog-library-directories:(".")
// End:
