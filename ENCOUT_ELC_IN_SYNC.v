module ENCOUT_ELC_IN_SYNC (/*AUTOARG*/
  // Outputs
  o_elc_in_sync,
  // Inputs
  i_elc_in, i_clk, i_resetn, i_ten
  ) ;
  input  wire i_elc_in        ;
  input  wire i_clk           ;
  input  wire i_resetn        ;
  input  wire i_ten           ;
  output wire o_elc_in_sync   ;

  reg       r_elc_in_act       ;
  wire      w_elc_in_act_clk   ;
  wire      w_elc_in_act_resetn;

  reg [2:0] r_sync_ff         ;
  reg       r_elc_in_detect   ;

  assign w_elc_in_act_clk    = i_ten ? i_clk    : i_elc_in;
  assign w_elc_in_act_resetn = i_ten ? i_resetn : i_resetn & ~r_sync_ff[2];

  always @ (posedge w_elc_in_act_clk or negedge w_elc_in_act_resetn) // this register must be asynchronous
    if (~w_elc_in_act_resetn)
      r_elc_in_act <= 1'b0;
    else
      r_elc_in_act <= 1'b1;

  always @ (posedge i_clk)
    if (~i_resetn)
      {r_elc_in_detect, r_sync_ff[2:0]} <= 4'b0000;
    else
      {r_elc_in_detect, r_sync_ff[2:0]} <= {r_sync_ff[2:0], r_elc_in_act};

  assign o_elc_in_sync = ~r_elc_in_detect & r_sync_ff[2];

endmodule // ENCOUT_ELC_IN_SYNC

module tb (/*AUTOARG*/) ;

  logic i_elc_in        ;
  logic i_clk           ;
  logic i_resetn        ;
  logic i_ten           ;
  logic o_elc_in_sync   ;

  ENCOUT_ELCIN_EDGE_DETECT ENCOUT_ELCIN_EDGE_DETECT (/*AUTOINST*/
                                                     // Outputs
                                                     .o_elc_in_sync     (o_elc_in_sync),
                                                     // Inputs
                                                     .i_elc_in          (i_elc_in),
                                                     .i_clk             (i_clk),
                                                     .i_resetn          (i_resetn),
                                                     .i_ten             (i_ten));

  initial begin
    i_resetn = 1'b0;
    repeat (3) @(posedge i_clk);
    i_resetn = 1'b1;
  end

  logic clk_200;

  initial begin
    clk_200 = 1'b0;
    i_clk = 1'b0;

    fork
      forever #2.5ns clk_200 <= ~clk_200;
      begin
        #5ns;
        forever #50ns i_clk <= ~i_clk;
      end
    join_none
  end


  initial begin
    $dumpfile("ENCOUT_ELCIN_EDGE_DETECT.vcd");
    $dumpvars;
    i_ten = 0;
    i_elc_in = 0;

    repeat (100) @(posedge clk_200);
    i_elc_in = 1'b1;
    @(posedge clk_200);
    i_elc_in = 1'b0;

    repeat (1000) @(posedge clk_200);
    $finish();
  end

endmodule // tb
