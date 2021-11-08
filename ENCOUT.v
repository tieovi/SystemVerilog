module ENCOUT (/*AUTOARG*/
  // Outputs
  PREADY, PSLVERR, PRDATA, POUTA, POUTB, POUTZ,
  // Inputs
  PCLK, PRESETN, PADDR, PSEL, PWRITE, PENABLE, PWDATA, ELC_IN, TEN
  ) ;
  // APB3 I/F
  input wire         PCLK    ;
  input wire         PRESETN ;
  input wire [31:0]  PADDR   ;
  input wire         PSEL    ;
  input wire         PWRITE  ;
  input wire         PENABLE ;
  input wire [31:0]  PWDATA  ;
  output wire        PREADY  ;
  output wire        PSLVERR ;
  output wire [31:0] PRDATA  ;

  input wire         ELC_IN  ;
  output wire        POUTA   ;
  output wire        POUTB   ;
  output wire        POUTZ   ;
  input wire         TEN     ;

  wire               w_presetn_sync    ;
  wire               w_elc_in_sync     ;
  wire [15:0]        w_period_aset     ;
  wire               w_period_aset_vld ;
  wire               w_elc_err         ;
  wire [15:0]        w_reg_poscnt      ;
  wire [ 4:0]        w_reg_ctl         ;
  wire               w_reg_str         ;
  wire               w_reg_opt         ;
  wire [15:0]        w_reg_posmax      ;
  wire [15:0]        w_reg_period      ;
  wire [15:0]        w_reg_outcnt      ;
  wire [31:0]        w_wdata           ;
  wire               w_wr_poscnt       ;
  wire [ 8:0]        w_we              ;
  wire [ 8:0]        w_re              ;
  wire [31:0]        w_rdata           ;


  ENCOUT_RESET_SYNC RESET_SYNCE(
                                 // Outputs
  .o_presetn_sync (w_presetn_sync),
                                 // Inputs
  .i_pclk (PCLK),
  .i_presetn (PRESETN),
  .ten (TEN));

  ENCOUT_ELC_IN_SYNC ELC_IN_SYNC (
                                  // Outputs
                                  .o_elc_in_sync        (w_elc_in_sync),
                                  // Inputs
                                  .i_elc_in             (ELC_IN),
                                  .i_clk                (PCLK),
                                  .i_resetn             (w_presetn_sync),
                                  .i_ten                (TEN));

  ENCOUT_PHASE_GEN PHASE_GEN (
                              // Outputs
                              .o_period_aset_vld(w_period_aset_vld),
                              .o_period_aset    (w_period_aset[15:0]),
                              .o_pouta          (POUTA),
                              .o_poutb          (POUTB),
                              .o_poutz          (POUTZ),
                              .o_elc_err        (w_elc_err),
                              .o_reg_poscnt     (w_reg_poscnt[15:0]),
                              // Inputs
                              .i_pclk           (PCLK),
                              .i_presetn        (w_presetn_sync),
                              .i_reg_ctl        (w_reg_ctl[4:0]),
                              .i_reg_str        (w_reg_str),
                              .i_reg_opt        (w_reg_opt),
                              .i_reg_posmax     (w_reg_posmax[15:0]),
                              .i_reg_period     (w_reg_period[15:0]),
                              .i_reg_outcnt     (w_reg_outcnt[15:0]),
                              .i_wr_poscnt      (w_wr_poscnt),
                              .i_wdata          (w_wdata[15:0]),
                              .i_elcin_sync     (w_elc_in_sync));

  ENCOUT_APB_IF APB_IF (
                        // Outputs
                        .o_pready       (PREADY),
                        .o_pslverr      (PSLVERR),
                        .o_prdata       (PRDATA[31:0]),
                        .o_we           (w_we[8:0]),
                        .o_re           (w_re[8:0]),
                        .o_wdata        (w_wdata[31:0]),
                        // Inputs
                        .i_pclk         (PCLK),
                        .i_presetn      (w_presetn_sync),
                        .i_paddr        (PADDR[31:0]),
                        .i_psel         (PSEL),
                        .i_pwrite       (PWRITE),
                        .i_penable      (PENABLE),
                        .i_pwdata       (PWDATA[31:0]),
                        .i_rdata        (w_rdata[31:0]));

  ENCOUT_REG_BLK REG_BLK (
                          // Outputs
                          .o_reg_ctl            (w_reg_ctl[4:0]),
                          .o_reg_str            (w_reg_str),
                          .o_reg_opt            (w_reg_opt),
                          .o_reg_period         (w_reg_period[15:0]),
                          .o_reg_posmax         (w_reg_posmax[15:0]),
                          .o_reg_outcnt         (w_reg_outcnt[15:0]),
                          .o_wr_poscnt          (w_wr_poscnt),
                          .o_rdata              (w_rdata[31:0]),
                          // Inputs
                          .i_pclk               (PCLK),
                          .i_presetn            (w_presetn_sync),
                          .i_elc_err            (w_elc_err),
                          .i_period_aset        (w_period_aset[15:0]),
                          .i_period_aset_vld    (w_period_aset_vld),
                          .i_we                 (w_we[8:0]),
                          .i_re                 (w_re[8:0]),
                          .i_wdata              (w_wdata[31:0]),
                          .i_reg_poscnt         (w_reg_poscnt[15:0]));
endmodule // ENCOUT_TOP

// Local Variables:
// verilog-library-directories:(".")
// End:
