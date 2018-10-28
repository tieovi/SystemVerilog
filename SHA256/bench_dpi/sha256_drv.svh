//-----------------------------------------------------------------------------
// Title         : sha256_drv
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_drv.sv
// Author        : Tien-Luanvu  <luanvt@thinkpad>
// Created       : 25.08.2018
// Last modified : 25.08.2018
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by Vu Tien Luan This model is the confidential and
// proprietary property of Vu Tien Luan and the possession or use of this
// file requires a written license from Vu Tien Luan.
//------------------------------------------------------------------------------
// Modification history :
// 25.08.2018 : created
//-----------------------------------------------------------------------------

typedef sha256_msg_c;
class sha256_drv_c;

  // Use a virtual interface that point to same interface
  virtual interface sha256_if sha256_intf;

  // Use mailbox to receive msg from generator
  mailbox mbx_input;

  function new(mailbox mbx, virtual interface sha256_if intf);
    mbx_input = mbx;
    this.sha256_intf = intf;
  endfunction // new

  task run;
    sha256_msg_c mesg;
    fork
      forever begin
        mbx_input.get(mesg);
        $display("[sha256_drv] time=%0t, Got message as following from generator:%s", $time, mesg.to_string());
        repeat (3) @(posedge sha256_intf.clk);
        drv_mesg(mesg);
      end
    join_none
  endtask // run

  task drv_mesg(sha256_msg_c mesg);
    int word_count;
    int mesg_size ;
    bit [31:0] msg_temp;

    mesg_size = mesg.m_data.size();
    word_count = 0;

    forever @(posedge sha256_intf.clk) begin
      if (sha256_intf.drv_cb.m_ready) begin
        if (word_count == (mesg_size-1)) begin
          sha256_intf.drv_cb.m_valid <= 1'b1;
          sha256_intf.drv_cb.m_last  <= 1'b1;
          sha256_intf.drv_cb.m_data  <= mesg.m_data.pop_front();
          word_count                  = word_count + 1;
        end else if (word_count == mesg_size) begin
          sha256_intf.drv_cb.m_valid <=  1'b0;
          sha256_intf.drv_cb.m_last  <=  1'b0;
          sha256_intf.drv_cb.m_data  <= 32'h0;
          word_count = 0;
          break;
        end else begin
          sha256_intf.drv_cb.m_valid <= 1'b1;
          sha256_intf.drv_cb.m_last  <= 1'b0;
          sha256_intf.drv_cb.m_data  <= mesg.m_data.pop_front();
          word_count                  = word_count + 1;
        end
      end
    end

  endtask // drv_mesg

endclass // sha256_drv_c
