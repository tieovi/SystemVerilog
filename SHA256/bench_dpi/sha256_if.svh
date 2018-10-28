//-----------------------------------------------------------------------------
// Title         : sha256_if
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_msg.svh
// Author        : Tien-Luanvu  <luanvt@thinkpad>
// Created       : 24.08.2018
// Last modified : 24.08.2018
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by Vu Tien Luan This model is the confidential and
// proprietary property of Vu Tien Luan and the possession or use of this
// file requires a written license from Vu Tien Luan.
//------------------------------------------------------------------------------
// Modification history :
// 24.08.2018 : created
//-----------------------------------------------------------------------------

interface sha256_if
  (
   );

   logic          clk       ;
   logic          reset_n   ;
   logic          m_valid   ;
   logic          m_ready   ;
   logic          m_last    ;
   logic [31:0]   m_data    ;
   logic          s_valid   ;
   logic [255:0]  s_data    ;

  //------------------------------------------------------------
  // Default clocking
  //------------------------------------------------------------
  // TODO: default clocking is not require bit width
  default clocking mon_cb @(posedge clk);
    default input #1ns output #1ns;
    input clk       ;
    input reset_n   ;
    input m_valid   ;
    input m_ready   ;
    input m_last    ;
    input m_data    ;
    input s_valid   ;
    input s_data    ;
  endclocking // mon_cb

  modport monitor_mp (
     clocking mon_cb
  );

  clocking drv_cb @(posedge clk);
    default input #1ns output #1ns;
    input  clk       ;
    input  reset_n   ;
    input  m_ready   ;
    output m_valid   ;
    output m_last    ;
    output m_data    ;
  endclocking // drv_cb

  modport driver_mp (
     clocking drv_cb
   );

endinterface
