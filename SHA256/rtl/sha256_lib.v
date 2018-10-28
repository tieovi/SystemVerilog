//-----------------------------------------------------------------------------
// Title         : sha256_lib
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_lib.v
// Author        : Tien-Luanvu  <luanvt@thinkpad>
// Created       : 31.07.2018
// Last modified : 31.07.2018
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by Vu Tien Luan This model is the confidential and
// proprietary property of Vu Tien Luan and the possession or use of this
// file requires a written license from Vu Tien Luan.
//------------------------------------------------------------------------------
// Modification history :
// 31.07.2018 : created
//-----------------------------------------------------------------------------

module sha256_reg
  #(
    parameter P_WIDTH = 32,
    parameter P_INIT  = {P_WIDTH{1'b0}}
    )
  (
   input                clk     ,
   input                reset_n ,
   input  [P_WIDTH-1:0] D       ,
   output [P_WIDTH-1:0] Q
   ) ;

  reg [P_WIDTH-1:0] Q_tmp;
  always @(posedge clk or negedge reset_n) begin
    if (~reset_n)
      Q_tmp <= #1 P_INIT;
    else
      Q_tmp <= #1 D;
  end
  assign Q = Q_tmp;

endmodule // sha256_reg

module sha256_regx
  #(
    parameter P_WIDTH = 32,
    parameter P_INIT  = {P_WIDTH{1'b0}}
    )
  (
   input                clk,
   input                reset_n,
   input                en,
   input [P_WIDTH-1:0]  D,
   output [P_WIDTH-1:0] Q
   ) ;

  reg [P_WIDTH-1:0] Q_tmp;
  always @(posedge clk or negedge reset_n) begin
    if (~reset_n)
      Q_tmp <= #1 P_INIT;
    else
      Q_tmp <= #1 en ? D : Q_tmp;
  end
  assign Q = Q_tmp;

endmodule // sha256_reg

module ROTR
  (
   output [31:0] y,
   input  [31:0] x,
   input  [ 5:0] n
   );

  assign y = (x >> n) | (x << (32-n));

endmodule // ROTR

module SHR
  (
   output [31:0] y,
   input  [31:0] x,
   input  [ 5:0] n
   );

  assign y = (x >> n);

endmodule // SHR


module O0
  (
   output [31:0] y,
   input  [31:0] x
   );

  wire   [31:0] rotr7_y     ;
  wire   [31:0] rotr18_y    ;
  wire   [31:0] shr3_y      ;

  ROTR rotr7 (.x(x), .n(6'd07), .y(rotr7_y ));
  ROTR rotr18(.x(x), .n(6'd18), .y(rotr18_y));
  SHR  shr3  (.x(x), .n(6'd03), .y(shr3_y  ));

  assign y = rotr7_y ^ rotr18_y ^ shr3_y;

  // return ( ROTR(7, x) ^ ROTR(18, x ) ^ SHR(3, x) );
endmodule // O0


module O1
  (
   output [31:0] y,
   input  [31:0] x
   );

  wire   [31:0] rotr17_y    ;
  wire   [31:0] rotr19_y    ;
  wire   [31:0] shr10_y     ;

  ROTR rotr17 (.x(x), .n(6'd17 ), .y(rotr17_y ));
  ROTR rotr19 (.x(x), .n(6'd19 ), .y(rotr19_y ));
  SHR  shr10  (.x(x), .n(6'd10 ), .y(shr10_y  ));

  assign y = rotr17_y ^ rotr19_y ^ shr10_y;

endmodule // O0

module E0
  (
   output [31:0] y,
   input  [31:0] x
   );

  wire [31:0] y_rotr02;
  wire [31:0] y_rotr13;
  wire [31:0] y_rotr22;

  ROTR rotr02 (.x(x), .n(6'd02), .y(y_rotr02));
  ROTR rotr13 (.x(x), .n(6'd13), .y(y_rotr13));
  ROTR rotr22 (.x(x), .n(6'd22), .y(y_rotr22));

  assign y = y_rotr02 ^ y_rotr13 ^ y_rotr22;

endmodule // E0

module E1
  (
   output [31:0] y,
   input  [31:0] x
   );

  wire [31:0] y_rotr06;
  wire [31:0] y_rotr11;
  wire [31:0] y_rotr25;

  ROTR rotr06 (.x(x), .n(6'd06), .y(y_rotr06));
  ROTR rotr11 (.x(x), .n(6'd11), .y(y_rotr11));
  ROTR rotr25 (.x(x), .n(6'd25), .y(y_rotr25));

  assign y = y_rotr06 ^ y_rotr11 ^ y_rotr25;

endmodule // E1

module Ch
  (
   output [31:0] y,
   input  [31:0] x1,
   input  [31:0] x2,
   input  [31:0] x3
   );

  assign y = (x1 & x2) ^ (~x1 & x3);

endmodule // Ch

module Maj
  (
   output [31:0] y,
   input  [31:0] x1,
   input  [31:0] x2,
   input  [31:0] x3
   );

  assign y = (x1 & x2) ^ (x1 & x3) ^ (x2 & x3);

endmodule // Ch
