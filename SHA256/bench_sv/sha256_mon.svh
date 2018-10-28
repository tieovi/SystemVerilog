//-----------------------------------------------------------------------------
// Title         : sha256_mon
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_mon.svh
// Author        : Tien-Luanvu  <luanvt@thinkpad>
// Created       : 26.08.2018
// Last modified : 26.08.2018
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by Vu Tien Luan This model is the confidential and
// proprietary property of Vu Tien Luan and the possession or use of this
// file requires a written license from Vu Tien Luan.
//------------------------------------------------------------------------------
// Modification history :
// 26.08.2018 : created
//-----------------------------------------------------------------------------

typedef sha256_msg_c;
class sha256_mon_c;

  // Virtual interface to sample signal
  virtual interface sha256_if sha256_intf;

  // Use mailbox to put mesg
  mailbox mbx_out[2];

  // Constructor
  function new( mailbox mbx[2], virtual interface sha256_if sha256_intf);
     this.mbx_out = mbx;
     this.sha256_intf = sha256_intf;
  endfunction // new

  // Run
  task run;
    fork
      sample_input();
      sample_output();
    join_none
    $display("[sha256_mon] At the end of run task!");
  endtask // run

  int word_count;
  sha256_msg_c mesg;

  // sample_input
  task sample_input;

    word_count = 0;
    forever @(posedge sha256_intf.clk) begin
      if (sha256_intf.mon_cb.m_valid && sha256_intf.mon_cb.m_ready ) begin
        if (word_count == 0) begin
          mesg = new();
          mesg.m_data.push_back(sha256_intf.mon_cb.m_data);
          word_count = word_count + 1;
        end else begin
          mesg.m_data.push_back(sha256_intf.mon_cb.m_data);
          word_count = word_count + 1;
        end
        if (sha256_intf.mon_cb.m_last) begin
          mbx_out[0].put(mesg);
          $display("[sha256_mon] time=%0t, Seen message on the input port=%s", $time, mesg.to_string());
          word_count = 0;
        end
      end
    end
  endtask // sample_input

  // sample_output
  task sample_output;
    bit [255:0] s_data;

    forever @(posedge sha256_intf.clk) begin
      if (sha256_intf.mon_cb.s_valid) begin
        s_data = sha256_intf.mon_cb.s_data;
        $display("[sha256_mon] time=%0t, Seen hash data on the output port\nHash=%0h", $time, s_data);
        mbx_out[1].put(s_data);
      end
    end
  endtask // sample_output

endclass // sha256_mon_c
