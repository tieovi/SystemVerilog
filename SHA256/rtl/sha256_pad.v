//-----------------------------------------------------------------------------
// Title         : sha256_pad
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_pad.v
// Author        : Tien-Luanvu  <luanvt@thinkpad>
// Created       : 31.07.2018
// Last modified : 31.07.2018
//-----------------------------------------------------------------------------
// Description :
//  Message padding block for SHA256 core
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by Vu Tien Luan This model is the confidential and
// proprietary property of Vu Tien Luan and the possession or use of this
// file requires a written license from Vu Tien Luan.
//------------------------------------------------------------------------------
// Modification history :
// 31.07.2018 : created
//-----------------------------------------------------------------------------

module sha256_pad
  (
   // System I/F
   input clk                ,
   input reset_n            ,
   // Msg I/F
   input         m_valid    ,
   input [31:0]  m_data     ,
   input         m_last     ,
   output        m_ready    ,
   // To sha256_main
   input         hash_done  ,
   output        w_vld      ,
   output [5:0]  w_cnt      ,
   output [31:0] w_data
   ) ;

  wire       seen_m_last        ;
  wire       seen_m_last_pre    ;
  wire       seen_m_last_en     ;
  wire       m_last_d1          ;

  wire       w_count_en         ;
  wire [5:0] w_count            ;
  wire [5:0] w_count_pre        ;
  wire [3:0] m_len              ;

  reg [31:0] w_dat              ;


  // fixme update m_ready_valid reg
  wire m_ready_pre              ;
  wire m_ready_en               ;

  assign m_ready_pre = (w_cnt < 6'd13) & (~seen_m_last);
  assign m_ready_en  = 1'b1;

  sha256_regx #(.P_WIDTH(1), .P_INIT(1'b1)) regx_m_ready (.clk(clk), .reset_n(reset_n), .en(m_ready_en), .D(m_ready_pre), .Q(m_ready));

  // msg len counter
  assign w_count_en = (m_valid & m_ready) | seen_m_last;
  assign w_count_pre = w_count + 6'h01;

  sha256_regx #(.P_WIDTH(6)) regx_w_count (.clk(clk), .reset_n(reset_n), .en(w_count_en), .D(w_count_pre), .Q(w_count));

  // msg len capture
  sha256_regx #(.P_WIDTH(4)) regx_m_len   (.clk(clk), .reset_n(reset_n), .en(m_last), .D(w_count[3:0]), .Q(m_len) );

  // is last signal is seen
  assign seen_m_last_pre = ~(&w_count);
  assign seen_m_last_en  = m_last | &w_count;
  sha256_regx #(.P_WIDTH(1)) reg_seen_m_last (.clk(clk), .reset_n(reset_n), .en(seen_m_last_en), .D(seen_m_last_pre), .Q(seen_m_last) );

  // delay m_last 1 cycle
  sha256_reg #(.P_WIDTH(1)) reg_m_last_d1 (.clk(clk), .reset_n(reset_n), .D(m_last), .Q(m_last_d1));

  // output data selection
  always @ (*) begin
//    casez({(w_count==15), seen_m_last, (m_last_d1 & &m_last_sz_reg)})
    casez({(w_count==15), seen_m_last, m_last_d1})
      3'b1??  : w_dat = (m_len+1)*32  ;
      3'b010  : w_dat = 32'h0000_0000 ;
      3'b011  : w_dat = 32'h8000_0000 ;
      3'b000  : w_dat = m_data        ;
      default : w_dat = 32'h0000_0000 ;
    endcase
  end

  assign w_vld  = w_count_en;
  assign w_cnt  = w_count;
  assign w_data = w_dat;

endmodule // sha256_pad

// Local Variables:
// verilog-library-directories:(".")
// End:
