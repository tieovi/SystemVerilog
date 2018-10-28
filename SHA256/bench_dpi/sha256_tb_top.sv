//-----------------------------------------------------------------------------
// Title         : sha256_tb_top
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_tb_top.sv
// Author        : Tien-Luanvu  <luanvt@thinkpad>
// Created       : 30.08.2018
// Last modified : 30.08.2018
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by Vu Tien Luan This model is the confidential and
// proprietary property of Vu Tien Luan and the possession or use of this
// file requires a written license from Vu Tien Luan.
//------------------------------------------------------------------------------
// Modification history :
// 30.08.2018 : created
//-----------------------------------------------------------------------------

// `include "sha256_env.svh"
// `include "sha256_test.svh"

module sha256_tb_top;

  parameter pCLK = 10;

  reg                   clk;                    // To sha256_top of sha256_top.v
  reg [1:0]             m_last_sz;              // To sha256_top of sha256_top.v

  sha256_top sha256_top(/*AUTOINST*/
                        // Outputs
                        .m_ready        (sha256_intf.m_ready),
                        .s_valid        (sha256_intf.s_valid),
                        .s_data         (sha256_intf.s_data[255:0]),
                        // Inputs
                        .clk            (sha256_intf.clk),
                        .reset_n        (sha256_intf.reset_n),
                        .m_valid        (sha256_intf.m_valid),
                        .m_data         (sha256_intf.m_data[31:0]),
                        .m_last         (sha256_intf.m_last)
                        );

  sha256_if sha256_intf ();

//  sha256_env_c sha256_env;

  initial begin
    clk = 0;
    forever #(pCLK/2) clk = !clk;
  end

  assign sha256_intf.clk = clk;

  sha256_test_c sha256_test;
  initial begin
    sha256_test = new("sha256_test", sha256_intf);
    sha256_intf.reset_n   <= 0;
    repeat (5) @(posedge clk);
    sha256_intf.reset_n <= 1;
    sha256_intf.m_valid   <= 1'b0;
    sha256_intf.m_last    <= 1'b0;
    sha256_intf.m_data    <= 32'h0;
    repeat (5) @(posedge clk);
    sha256_test.run();
    $finish();
  end

  // dump waveform
  initial begin
    $dumpfile("dump_sha256");
    $dumpvars();
  end

endmodule // sha256_tb_top
