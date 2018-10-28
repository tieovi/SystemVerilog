//-----------------------------------------------------------------------------
// Title         : sha256_tb.v
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_tb.v
// Author        : Vu Tien Luan  <tienluan1607@gmail.com>
// Created       : 14.08.2018
// Last modified : 14.08.2018
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by Vu Tien Luan This model is the confidential and
// proprietary property of Vu Tien Luan and the possession or use of this
// file requires a written license from Vu Tien Luan.
//------------------------------------------------------------------------------
// Modification history :
// 14.08.2018 : created
//-----------------------------------------------------------------------------
module sha256_tb (/*AUTOARG*/) ;

  parameter pCLK = 10;

  /*AUTOREGINPUT*/
  // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
  reg                   clk;                    // To sha256_top of sha256_top.v
  reg [31:0]            m_data;                 // To sha256_top of sha256_top.v
  reg                   m_last;                 // To sha256_top of sha256_top.v
  reg [1:0]             m_last_sz;              // To sha256_top of sha256_top.v
  reg                   m_valid;                // To sha256_top of sha256_top.v
  reg                   reset_n;                // To sha256_top of sha256_top.v
  // End of automatics

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire                  m_ready;                // From sha256_top of sha256_top.v
  wire [255:0]          s_data;                 // From sha256_top of sha256_top.v
  wire                  s_valid;                // From sha256_top of sha256_top.v
  // End of automatics
  sha256_top sha256_top(/*AUTOINST*/
                        // Outputs
                        .m_ready        (m_ready),
                        .s_valid        (s_valid),
                        .s_data         (s_data[255:0]),
                        // Inputs
                        .clk            (clk),
                        .reset_n        (reset_n),
                        .m_valid        (m_valid),
                        .m_data         (m_data[31:0]),
                        .m_last         (m_last),
                        .m_last_sz      (m_last_sz[1:0]));

  // Clock
  initial begin
    clk = 0;
    forever #(pCLK/2) clk = !clk;
  end

  // Reset
  initial begin
    reset_n = 0;
    repeat (3) @(posedge clk);
    reset_n = 1;
  end

  // Timeout
  initial begin
    repeat (100) @(posedge clk);
    $display("[TIMEOUT] SHA256: Simulation timeout!!!");
    $finish();
  end

  initial begin
//    $fsdbDumpvars();
//    $fsdbDumpvars("sha256_tb.sha256_top.sha256_pad.w_count_en");
    $dumpfile("dump_sha256");
    $dumpvars();
  end

  // Input
  initial begin
    m_data = 32'h0;
    m_last = 1'b0;
    m_last_sz = 2'b00;
    m_valid = 1'b0;
    repeat (5) @(posedge clk) #1 ;
    m_valid = 1;
    m_last  = 0;
    m_last_sz = 2'b11;
//    m_data = 32'b01100001_01100010_01100011_00000000;
    m_data = "abcd";
    repeat (1) @(posedge clk) #1;
    m_valid = 1;
    m_last  = 0;
    m_last_sz = 2'b11;
    m_data = "efgh";
    repeat (1) @(posedge clk) #1;
    m_valid = 1;
    m_last  = 1;
    m_last_sz = 2'b11;
    m_data = "jklm";
    repeat (1) @(posedge clk) #1;
    m_valid = 0;
    m_last  = 0;
    m_last_sz = 2'b00;
    m_data = 32'b00000000_00000000_00000000_00000000;
    repeat (100) @(posedge clk);
    $finish();
  end

endmodule // sha256_tb

// Local Variables:
// verilog-library-directories:("../rtl/")
// End:
