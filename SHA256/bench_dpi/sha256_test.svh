//-----------------------------------------------------------------------------
// Title         : sha256_test
// Project       : SHA256
//-----------------------------------------------------------------------------
// File          : sha256_test.svh
// Author        : Tien-Luanvu  <luanvt@thinkpad>
// Created       : 20.09.2018
// Last modified : 20.09.2018
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by Vu Tien Luan This model is the confidential and
// proprietary property of Vu Tien Luan and the possession or use of this
// file requires a written license from Vu Tien Luan.
//------------------------------------------------------------------------------
// Modification history :
// 20.09.2018 : created
//-----------------------------------------------------------------------------

import sha256_env_pkg::*;

class sha256_test_c;

  string test_name;

  virtual interface sha256_if sha256_intf;

  sha256_env_c sha256_env;

  function new(string name, virtual interface sha256_if intf);
    this.test_name = name;
    this.sha256_intf = intf;

    sha256_env = new("sha256_env", intf);
  endfunction // new

  task run();
    begin
      no_of_transaction = 100;
      sha256_env.run();
      sha256_env.stop();
    end
  endtask // run

endclass // sha256_test_c
