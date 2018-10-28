//-----------------------------------------------------------------------------
// Title         : sha256_env
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_env.svh
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

package sha256_env_pkg;

  int no_of_transaction;
  // TODO for verdi reading file
 `include "../bench_sv/sha256_msg.svh"
 `include "../bench_sv/sha256_gen.svh"
 `include "../bench_sv/sha256_mon.svh"
 `include "../bench_sv/sha256_drv.svh"
 `include "../bench_sv/sha256_chk.svh"

class sha256_env_c;

  // a name for the env
  string env_name;

  // gen
  sha256_gen_c sha256_gen;

  // driver
  sha256_drv_c sha256_drv;

  // monitor
  sha256_mon_c sha256_mon;

  // checker
  sha256_chk_c sha256_chk;

  // mailbox from gen to drv
  mailbox mbx_gen_drv;

  // mailbox from mon to checker
  mailbox mbx_mon_chk[2];

  // virtual interface
  virtual interface sha256_if sha256_intf;

  // constructer
 function new(string name, virtual interface sha256_if intf);
    this.env_name = name;
    this.sha256_intf = intf;
    // create mailbox intance used by driver and generator to communicate
    mbx_gen_drv = new();
    sha256_gen = new(mbx_gen_drv);
    sha256_drv = new(mbx_gen_drv, intf);

    mbx_mon_chk[0] = new();
    mbx_mon_chk[1] = new();
    sha256_mon = new(mbx_mon_chk, intf);
    sha256_chk = new(mbx_mon_chk);
  endfunction // new

  // run
  task run();
      sha256_gen.run();
      sha256_drv.run();
      sha256_mon.run();
      sha256_chk.run();
  endtask // run

  // stop
  task stop();
    wait(sha256_chk.DONE.triggered);
  endtask // stop

endclass // sha256_env_c

endpackage // packet_env_pkg
