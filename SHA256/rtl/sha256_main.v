//-----------------------------------------------------------------------------
// Title         : sha256_main
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_main.v
// Author        : Tien-Luanvu  <luanvt@thinkpad>
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
module sha256_main
  (
   input          clk       ,
   input          reset_n   ,
   input          w_vld     ,
   input [5:0]    w_cnt     ,
   input [31:0]   w_data    ,
   output         hash_done ,
   output         s_valid   ,
   output [255:0] s_data
   ) ;

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [31:0]           Kt;                     // From sha256_main_rom of sha256_main_rom.v
  wire [31:0]           Wt;                     // From sha256_main_calw of sha256_main_calw.v
  wire [31:0]           a;                      // From sha256_main_calvar of sha256_main_calvar.v
  wire [31:0]           b;                      // From sha256_main_calvar of sha256_main_calvar.v
  wire [31:0]           c;                      // From sha256_main_calvar of sha256_main_calvar.v
  wire [31:0]           d;                      // From sha256_main_calvar of sha256_main_calvar.v
  wire [31:0]           e;                      // From sha256_main_calvar of sha256_main_calvar.v
  wire [31:0]           f;                      // From sha256_main_calvar of sha256_main_calvar.v
  wire [31:0]           g;                      // From sha256_main_calvar of sha256_main_calvar.v
  wire [31:0]           h;                      // From sha256_main_calvar of sha256_main_calvar.v
  wire                  hash_en;                // From sha256_main_ctrl of sha256_main_ctrl.v
  wire [255:0]          hash_val;               // From sha256_main_calhash of sha256_main_calhash.v
  wire                  var_en;                 // From sha256_main_ctrl of sha256_main_ctrl.v
  wire                  var_init;               // From sha256_main_ctrl of sha256_main_ctrl.v
  // End of automatics

  sha256_main_ctrl   sha256_main_ctrl
    (/*AUTOINST*/
     // Outputs
     .var_en                            (var_en),
     .hash_en                           (hash_en),
     .var_init                          (var_init),
     .s_valid                           (s_valid),
     .hash_done                         (hash_done),
     .s_data                            (s_data[255:0]),
     // Inputs
     .clk                               (clk),
     .reset_n                           (reset_n),
     .w_vld                             (w_vld),
     .w_cnt                             (w_cnt[5:0]),
     .hash_val                          (hash_val[255:0]));

  sha256_main_calvar   sha256_main_calvar
    (/*AUTOINST*/
     // Outputs
     .a                                 (a[31:0]),
     .b                                 (b[31:0]),
     .c                                 (c[31:0]),
     .d                                 (d[31:0]),
     .e                                 (e[31:0]),
     .f                                 (f[31:0]),
     .g                                 (g[31:0]),
     .h                                 (h[31:0]),
     // Inputs
     .clk                               (clk),
     .reset_n                           (reset_n),
     .var_init                          (var_init),
     .var_en                            (var_en),
     .H_i1                              (hash_val[255:0]),
     .Kt                                (Kt[31:0]),
     .Wt                                (Wt[31:0]));
  sha256_main_calw sha256_main_calw
    (/*AUTOINST*/
     // Outputs
     .Wt                                (Wt[31:0]),
     // Inputs
     .clk                               (clk),
     .reset_n                           (reset_n),
     .w_vld                             (w_vld),
     .w_data                            (w_data[31:0]),
     .w_cnt                             (w_cnt[5:0]));
  sha256_main_rom sha256_main_rom
    (/*AUTOINST*/
     // Outputs
     .Kt                                (Kt[31:0]),
     // Inputs
     .w_cnt                             (w_cnt[5:0]));

  sha256_main_calhash sha256_main_calhash
    (/*AUTOINST*/
     // Outputs
     .hash_val                          (hash_val[255:0]),
     // Inputs
     .clk                               (clk),
     .reset_n                           (reset_n),
     .a                                 (a[31:0]),
     .b                                 (b[31:0]),
     .c                                 (c[31:0]),
     .d                                 (d[31:0]),
     .e                                 (e[31:0]),
     .f                                 (f[31:0]),
     .g                                 (g[31:0]),
     .h                                 (h[31:0]),
     .hash_en                           (hash_en));

endmodule // sha256_main


// Local Variables:
// verilog-library-directories:(".")
// End:
