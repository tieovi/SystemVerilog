//-----------------------------------------------------------------------------
// Title         : sha256_msg
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_msg.svh
// Author        : Tien-Luanvu  <luanvt@thinkpad>
// Created       : 24.08.2018
// Last modified : 24.08.2018
//-----------------------------------------------------------------------------
// Description : Message generator module
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by Vu Tien Luan This model is the confidential and
// proprietary property of Vu Tien Luan and the possession or use of this
// file requires a written license from Vu Tien Luan.
//------------------------------------------------------------------------------
// Modification history :
// 24.08.2018 : created
//-----------------------------------------------------------------------------

typedef sha256_msg_c;
class sha256_gen_c;

  // Use a mailbox and put these generated mesg into that
  // This mailbox will be later used by the driver
  mailbox mbx_out;

  function new(mailbox mbx);
    mbx_out = mbx;
  endfunction // new

  // Method
  task run;
    fork
      sha256_msg_c mesg;
      for (int i=0; i<no_of_transaction; i++) begin
        mesg = new();
        assert(mesg.randomize());
        mbx_out.put(mesg);
        $display("[sha256_gen] Generate message as following:%s", mesg.to_string());
      end
    join_none
  endtask // run

endclass // sha256_gen_c
