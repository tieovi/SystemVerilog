//-----------------------------------------------------------------------------
// Title         : sha256_main_rom
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_main_rom.v
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
//-----------------------------------------------------------------------------
module sha256_main_rom
  (
  input  [5:0]  w_cnt,
  output [31:0] Kt
  ) ;

  reg [31:0] Kt_r;

  always @ (*) begin
    casez(w_cnt)
      6'd0 : Kt_r = 32'h428a2f98;
      6'd1 : Kt_r = 32'h71374491;
      6'd2 : Kt_r = 32'hb5c0fbcf;
      6'd3 : Kt_r = 32'he9b5dba5;
      6'd4 : Kt_r = 32'h3956c25b;
      6'd5 : Kt_r = 32'h59f111f1;
      6'd6 : Kt_r = 32'h923f82a4;
      6'd7 : Kt_r = 32'hab1c5ed5;
      6'd8 : Kt_r = 32'hd807aa98;
      6'd9 : Kt_r = 32'h12835b01;
      6'd10: Kt_r = 32'h243185be;
      6'd11: Kt_r = 32'h550c7dc3;
      6'd12: Kt_r = 32'h72be5d74;
      6'd13: Kt_r = 32'h80deb1fe;
      6'd14: Kt_r = 32'h9bdc06a7;
      6'd15: Kt_r = 32'hc19bf174;
      6'd16: Kt_r = 32'he49b69c1;
      6'd17: Kt_r = 32'hefbe4786;
      6'd18: Kt_r = 32'h0fc19dc6;
      6'd19: Kt_r = 32'h240ca1cc;
      6'd20: Kt_r = 32'h2de92c6f;
      6'd21: Kt_r = 32'h4a7484aa;
      6'd22: Kt_r = 32'h5cb0a9dc;
      6'd23: Kt_r = 32'h76f988da;
      6'd24: Kt_r = 32'h983e5152;
      6'd25: Kt_r = 32'ha831c66d;
      6'd26: Kt_r = 32'hb00327c8;
      6'd27: Kt_r = 32'hbf597fc7;
      6'd28: Kt_r = 32'hc6e00bf3;
      6'd29: Kt_r = 32'hd5a79147;
      6'd30: Kt_r = 32'h06ca6351;
      6'd31: Kt_r = 32'h14292967;
      6'd32: Kt_r = 32'h27b70a85;
      6'd33: Kt_r = 32'h2e1b2138;
      6'd34: Kt_r = 32'h4d2c6dfc;
      6'd35: Kt_r = 32'h53380d13;
      6'd36: Kt_r = 32'h650a7354;
      6'd37: Kt_r = 32'h766a0abb;
      6'd38: Kt_r = 32'h81c2c92e;
      6'd39: Kt_r = 32'h92722c85;
      6'd40: Kt_r = 32'ha2bfe8a1;
      6'd41: Kt_r = 32'ha81a664b;
      6'd42: Kt_r = 32'hc24b8b70;
      6'd43: Kt_r = 32'hc76c51a3;
      6'd44: Kt_r = 32'hd192e819;
      6'd45: Kt_r = 32'hd6990624;
      6'd46: Kt_r = 32'hf40e3585;
      6'd47: Kt_r = 32'h106aa070;
      6'd48: Kt_r = 32'h19a4c116;
      6'd49: Kt_r = 32'h1e376c08;
      6'd50: Kt_r = 32'h2748774c;
      6'd51: Kt_r = 32'h34b0bcb5;
      6'd52: Kt_r = 32'h391c0cb3;
      6'd53: Kt_r = 32'h4ed8aa4a;
      6'd54: Kt_r = 32'h5b9cca4f;
      6'd55: Kt_r = 32'h682e6ff3;
      6'd56: Kt_r = 32'h748f82ee;
      6'd57: Kt_r = 32'h78a5636f;
      6'd58: Kt_r = 32'h84c87814;
      6'd59: Kt_r = 32'h8cc70208;
      6'd60: Kt_r = 32'h90befffa;
      6'd61: Kt_r = 32'ha4506ceb;
      6'd62: Kt_r = 32'hbef9a3f7;
      6'd63: Kt_r = 32'hc67178f2;
      default: Kt_r = 32'hxxxxxxxx;
    endcase // casez (w_cnt)
  end

  assign Kt = Kt_r;

endmodule // sha256_main_rom
