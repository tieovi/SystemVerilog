module ENCOUT_TOP (/*AUTOARG*/
  // Outputs
  PREADY, PSLVERR, PRDATA, O_POUTA0, O_POUTA1, O_POUTB0, O_POUTB1,
  O_POUTZ0, O_POUTZ1,
  // Inputs
  PCLK, PRESETN, PADDR, PSEL, PWRITE, PENABLE, PWDATA, ELCIN
  ) ;
  // APB3 I/F
  input  wire        PCLK    ;
  input  wire        PRESETN ;
  input  wire [31:0] PADDR   ;
  input  wire        PSEL    ;
  input  wire        PWRITE  ;
  input  wire        PENABLE ;
  input  wire [31:0] PWDATA  ;
  output wire        PREADY  ;
  output wire        PSLVERR ;
  output wire [31:0] PRDATA  ;

  input  wire       ELCIN    ;
  output wire       O_POUTA0 ;
  output wire       O_POUTA1 ;
  output wire       O_POUTB0 ;
  output wire       O_POUTB1 ;
  output wire       O_POUTZ0 ;
  output wire       O_POUTZ1 ;

  wire [31:0] w_rdata      ;
  wire        w_pol        ;
  wire        w_ence       ;
  wire [15:0] w_posmax     ;
  wire [15:0] w_pdcnt      ;
  wire [15:0] w_edgcnt     ;
  wire [15:0] w_poscnt_int ;
  wire        w_set_poscnt ;
  wire [5:0]  w_we         ;
  wire [5:0]  w_re         ;
  wire [31:0] w_wdata      ;
  wire [15:0] w_poscnt_cur ;

  ENCOUT_PHASE_GEN ENCOUT_PHASE_GEN (
                                     // Outputs
                                     .o_pouta0          (O_POUTA0           ),
                                     .o_pouta1          (O_POUTA1           ),
                                     .o_poutb0          (O_POUTB0           ),
                                     .o_poutb1          (O_POUTB1           ),
                                     .o_poutz0          (O_POUTZ0           ),
                                     .o_poutz1          (O_POUTZ1           ),
                                     // Inputs
                                     .i_pclk            (PCLK               ),
                                     .i_presetn         (PRESETN            ),
                                     .i_pol             (w_pol              ),
                                     .i_ence            (w_ence             ),
                                     .i_posmax          (w_posmax[15:0]     ),
                                     .i_pdcnt           (w_pdcnt[15:0]      ),
                                     .i_edgcnt          (w_edgcnt[15:0]     ),
                                     .i_poscnt_int      (w_poscnt_int[15:0] ),
                                     .i_set_poscnt      (w_set_poscnt       ),
                                     .i_elc_intr        (ELCIN              ));

  ENCOUT_APB_IF ENCOUT_APB_IF (
                               // Outputs
                               .o_pready        (PREADY        ),
                               .o_pslverr       (PSLVERR       ),
                               .o_prdata        (PRDATA[31:0]  ),
                               .o_we            (w_we[5:0]     ),
                               .o_re            (w_re[5:0]     ),
                               .o_wdata         (w_wdata[31:0] ),
                               // Inputs
                               .i_pclk          (PCLK          ),
                               .i_presetn       (PRESETN       ),
                               .i_paddr         (PADDR[31:0]   ),
                               .i_psel          (PSEL          ),
                               .i_pwrite        (PWRITE        ),
                               .i_penable       (PENABLE       ),
                               .i_pwdata        (PWDATA[31:0]  ),
                               .i_rdata         (w_rdata[31:0] ));

  ENCOUT_REG_BLK ENCOUT_REG_BLK (
                                 // Outputs
                                 .o_rdata               (w_rdata[31:0]      ),
                                 .o_pol                 (w_pol              ),
                                 .o_ence                (w_ence             ),
                                 .o_posmax              (w_posmax[15:0]     ),
                                 .o_pdcnt               (w_pdcnt[15:0]      ),
                                 .o_edgcnt              (w_edgcnt[15:0]     ),
                                 .o_poscnt_int          (w_poscnt_int[15:0] ),
                                 .o_set_poscnt          (w_set_poscnt       ),
                                 // Inputs
                                 .i_pclk                (PCLK               ),
                                 .i_presetn             (PRESETN            ),
                                 .i_we                  (w_we[5:0]          ),
                                 .i_re                  (w_re[5:0]          ),
                                 .i_wdata               (w_wdata[31:0]      ),
                                 .i_poscnt_cur          (w_poscnt_cur[15:0] ));
endmodule // ENCOUT_TOP

// Local Variables:
// verilog-library-directories:(".")
// End:
