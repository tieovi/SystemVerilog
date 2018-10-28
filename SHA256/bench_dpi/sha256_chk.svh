//-----------------------------------------------------------------------------
// Title         : sha256_chk
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_chk.svh
// Author        : Tien-Luanvu  <luanvt@thinkpad>
// Created       : 28.08.2018
// Last modified : 28.08.2018
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by Vu Tien Luan This model is the confidential and
// proprietary property of Vu Tien Luan and the possession or use of this
// file requires a written license from Vu Tien Luan.
//------------------------------------------------------------------------------
// Modification history :
// 28.08.2018 : created
//-----------------------------------------------------------------------------

  // insert for dpi-c
  typedef bit [ 7:0] BYTE;             // 8-bit byte
  typedef bit [31:0] WORD;             // 32-bit word, change to "long" for 16-bit machines

  typedef struct {
    BYTE data[64];
    WORD datalen;
    longint bitlen;
    WORD state[8];
  } SHA256_CTX;

  import "DPI-C" function void sha256_init  (inout SHA256_CTX ctx                              );
  import "DPI-C" function void sha256_update(inout SHA256_CTX ctx, input  BYTE data[], int len );
  import "DPI-C" function void sha256_final (inout SHA256_CTX ctx, output BYTE hash[32]        );
  // end insert for dpi-c

typedef sha256_msg_c;
class sha256_chk_c;

  // Use mailbox to get data from driver and monitor
  mailbox mbx_in[2];

  // queue of expected secure hash
  bit [255:0] exp_sdata_q[$];

  // count number of trans
  int trans_num;
  event DONE;

  function new(mailbox mbx[2]);
    for(int i=0; i< 2; i++) begin
      this.mbx_in[i] = mbx[i];
    end
    trans_num = 0;
  endfunction // new

  task run;
    fork
      forever begin
        get_and_proccess_mesg;
        get_and_check_sdata;
      end
    join_none
  endtask // run

  task get_and_proccess_mesg;
    sha256_msg_c mesg;
    mbx_in[0].get(mesg);
    $display("[sha256_chk] time=%0t, Got mesg on input port mesg=%s", $time, mesg.to_string());
    gen_exp_sdata(mesg);
  endtask // get_and_proccess_mesg

  task get_and_check_sdata;
    bit [255:0] dut_sdata;
    bit [255:0] exp_sdata;

    mbx_in[1].get(dut_sdata);
    exp_sdata = exp_sdata_q.pop_front();
    if (dut_sdata !== exp_sdata)
      $display("[sha256_chk] time=%0t, [FAIL] Mismatch hash calculation:\n\tdut=%h\n\texp=%h", $time, dut_sdata, exp_sdata);
    else
      $display("[sha256_chk] time=%0t, [PASS] Correct  hash calculation:\n\tdut=%h\n\texp=%h", $time, dut_sdata, exp_sdata);

    // increase the number of trans_count eacch time check comple
    trans_num++;
    if (trans_num >= no_of_transaction) begin
      ->DONE;
    end

  endtask // get_and_check_sdata

  function gen_exp_sdata(sha256_msg_c mesg);
    bit [255:0] exp_sdata;
    WORD msg_word;
    BYTE msg_byte[$];
    int  msg_size;
    int  byte_len;

    SHA256_CTX ctx;
    BYTE data[];
    BYTE hash[32];

    msg_size = mesg.m_data.size();
    for(int i=0; i < msg_size; i++) begin
      msg_word = mesg.m_data.pop_front();
      msg_byte.push_back(msg_word[31:24]);
      msg_byte.push_back(msg_word[23:16]);
      msg_byte.push_back(msg_word[15: 8]);
      msg_byte.push_back(msg_word[ 7: 0]);
      $display("[sha256_chk] msg_word=%h", msg_word);
    end

    data = new[msg_size*4];
    byte_len = msg_size*4;

    for(int i=0; i < msg_size*4; i++) begin
      data[i] = msg_byte[i];
    end

    sha256_init(ctx);
    sha256_update(ctx, data, byte_len);
    sha256_final(ctx, hash);

    for(int i=0; i< 32; i++) begin
      exp_sdata = exp_sdata | (hash[i] << (248-8*i) );
    end

    $display("[sha256_chk] exp_sdata=%h", exp_sdata);

    exp_sdata_q.push_back(exp_sdata);

  endfunction // gen_exp_sdata

endclass // sha256_chk_c
