module ENCOUT_REG_BLK (/*AUTOARG*/
  // Outputs
  o_reg_ctl, o_reg_str, o_reg_opt, o_reg_period, o_reg_posmax,
  o_reg_outcnt, o_wr_poscnt, o_rdata,
  // Inputs
  i_pclk, i_presetn, i_elc_err, i_period_aset, i_period_aset_vld,
  i_we, i_re, i_wdata, i_reg_poscnt
  ) ;
  input wire         i_pclk           ;
  input wire         i_presetn        ;

  input wire         i_elc_err        ;
  input wire [15:0]  i_period_aset    ;
  input wire         i_period_aset_vld;
  input wire [ 8:0]  i_we             ;
  input wire [ 8:0]  i_re             ;
  input wire [31:0]  i_wdata          ;
  input wire [15:0]  i_reg_poscnt     ;
  output wire [4:0]  o_reg_ctl        ;
  output wire        o_reg_str        ;
  output wire        o_reg_opt        ;
  output wire [15:0] o_reg_period     ;
  output wire [15:0] o_reg_posmax     ;
  output wire [15:0] o_reg_outcnt     ;
  output wire        o_wr_poscnt      ;
  output wire [31:0] o_rdata          ;

  // Parameter
  localparam REG_CTL    = 0;
  localparam REG_STR    = 1;
  localparam REG_OPT    = 2;
  localparam REG_POSMAX = 3;
  localparam REG_OUTCNT = 4;
  localparam REG_PERIOD = 5;
  localparam REG_POSCNT = 6;
  localparam REG_STATUS = 7;
  localparam REG_VER    = 8;

  // Internal reg and wire declaration
  reg  [4:0]        r_reg_ctl        ;
  reg               r_reg_str        ;
  reg               r_reg_opt        ;
  reg [15:0]        r_reg_posmax     ;
  reg [15:0]        r_reg_period     ;
  reg [15:0]        r_reg_outcnt     ;
  reg [15:0]        r_reg_poscnt     ;
  reg [31:0]        r_rd_data        ;
  reg [31:0]        r_rdata          ;
  reg               r_reg_elc_err    ;
  reg               r_reg_outcnt_err ;

  //------------------------------------------------------------
  // Write logic for CTL register
  always @ (posedge i_pclk)
    if (~i_presetn)
      r_reg_ctl <= 5'b00000;
    else if (i_we[REG_CTL] & ~r_reg_str)
      r_reg_ctl <= i_wdata[4:0];
    else
      r_reg_ctl <= r_reg_ctl;

  //------------------------------------------------------------
  // Write logic for STR register
  always @ (posedge i_pclk)
    if (~i_presetn)
      r_reg_str <= 1'b0;
    else if (i_we[REG_STR])
      r_reg_str <= i_wdata[0];
    else
      r_reg_str <= r_reg_str;

  //------------------------------------------------------------
  // Write logic for OPT register
  always @ (posedge i_pclk)
    if (~i_presetn)
      r_reg_opt <= 1'b0;
    else if (i_we[REG_OPT] & ~r_reg_str)
      r_reg_opt <= i_wdata[0];
    else
      r_reg_opt <= r_reg_opt;

  //------------------------------------------------------------
  // Write logic for PERIOD register
  //  APB3 write command
  //  Or internally by automatic aquisition
  always @ (posedge i_pclk)
    if (~i_presetn)
      r_reg_period <= 16'h0000;
    else if (i_we[REG_PERIOD] & ~r_reg_str & ~r_reg_opt)
      r_reg_period <= i_wdata[15:0];
    else if (r_reg_opt & i_period_aset_vld)
      r_reg_period <= i_period_aset;
    else
      r_reg_period <= r_reg_period;

  //------------------------------------------------------------
  // Write logic for POSMAX
  always @ (posedge i_pclk)
    if (~i_presetn)
      r_reg_posmax <= 16'h0000;
    else if (i_we[REG_POSMAX] & ~r_reg_str)
      r_reg_posmax <= i_wdata[15:0];
    else
      r_reg_posmax <= r_reg_posmax;

  //------------------------------------------------------------
  // Write logic for OUTCNT
  always @ (posedge i_pclk)
    if (~i_presetn)
      r_reg_outcnt <= 16'h0000;
    else if (i_we[REG_OUTCNT])
      r_reg_outcnt <= i_wdata[15:0];
    else
      r_reg_outcnt <= r_reg_outcnt;

  //------------------------------------------------------------
  // Write logic for ERR

  // ELC_ERR bit
  always @ (posedge i_pclk)
    if (~i_presetn)
      r_reg_elc_err <= 1'b0;
    else
      case({i_elc_err, i_re[REG_STATUS]})
        2'b00  : r_reg_elc_err <= r_reg_elc_err;
        2'b01  : r_reg_elc_err <= 1'b0;
        2'b10  : r_reg_elc_err <= 1'b1;
        default: r_reg_elc_err <= 1'b1;
      endcase // case ({i_elc_err, i_re[REG_STATUS]})

  // OUTCNT_ERR Bit
  // TODO: Update REG_BLK visio diagram
  always @ (posedge i_pclk)
    if (~i_presetn)
      r_reg_outcnt_err <= 1'b0;
    else if (i_we[REG_OUTCNT])
      r_reg_outcnt_err <= (i_wdata[15:0] > r_reg_period[15:0]);
    else if (i_we[REG_PERIOD] & ~r_reg_str)
      r_reg_outcnt_err <= (i_wdata[15:0] < r_reg_outcnt[15:0]);
    else
      r_reg_outcnt_err <= r_reg_outcnt_err;

  //------------------------------------------------------------
  // Read logic
  always @ (*)
    case(i_re[8:0])
      9'h001: r_rd_data = {27'h0, r_reg_ctl[4:0]}                 ; // CTL
      9'h002: r_rd_data = {31'h0, r_reg_str}                      ; // STR
      9'h004: r_rd_data = {31'h0, r_reg_opt}                      ; // OPT
      9'h008: r_rd_data = {16'h0, r_reg_posmax}                   ; // POSMAX
      9'h010: r_rd_data = {16'h0, r_reg_outcnt}                   ; // OUTCNT
      9'h020: r_rd_data = {16'h0, r_reg_period}                   ; // PERIOD
      9'h040: r_rd_data = {16'h0, i_reg_poscnt}                   ; // POSCNT
      9'h080: r_rd_data = {30'h0, r_reg_outcnt_err, r_reg_elc_err}; // POSCNT
      9'h100: r_rd_data = 32'h00020001                            ; // VERSION
      default   : r_rd_data = 32'h0;
    endcase // case (i_re[5:0])

  always @ (posedge i_pclk)
    if (~i_presetn)
      r_rdata <= 32'h0;
    else
      if (|i_re)
        r_rdata <= r_rd_data;
      else
        r_rdata <= r_rdata;


  // output to PHASE_GEN
  assign o_rdata = r_rdata                            ;
  assign o_reg_ctl    = r_reg_ctl                     ;
  assign o_reg_str    = r_reg_str                     ;
  assign o_reg_opt    = r_reg_opt                     ;
  assign o_reg_period = r_reg_period                  ;
  assign o_reg_posmax = r_reg_posmax                  ;
  assign o_wr_poscnt  = ~r_reg_str & i_we[REG_POSCNT] ;
  assign o_reg_outcnt = r_reg_outcnt                  ;

endmodule // ENCOUT_REG_BLK
