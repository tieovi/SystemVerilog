//-----------------------------------------------------------------------------
// Title         : sha256_msg
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

class sha256_msg_c;

  rand bit [31:0] m_data[$];    // using queue

  constraint m_leng_c {
    m_data.size() <= 13 && m_data.size() > 0;
  }

  function new();
  endfunction // new

  function string print_queue();
    string string_data;
    string temp;
    for (int i = 0; i< m_data.size(); i++) begin
      $swriteh(temp,"%h ",m_data[i]);
      string_data = {string_data, temp};
    end
    return string_data;
  endfunction // print_queue

  function string to_string();
    string msg;
    msg = $psprintf("\n\tm_data=0x%0s\n\tlength=%0h", print_queue(), m_data.size());
    return msg;
  endfunction // to_string

endclass // sha256_msg_c
