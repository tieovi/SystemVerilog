module ENCOUT_REG_BLK (/*AUTOARG*/
  // Outputs
  o_rdata, o_pol, o_ence, o_posmax, o_pdcnt, o_edgecnt, o_poscnt_int,
  // Inputs
  i_pclk, i_presetn, i_we, i_re, i_wdata, i_poscnt_cur
  ) ;
  input  wire        i_pclk       ;
  input  wire        i_presetn    ;
  input  wire [5:0]  i_we         ;
  input  wire [5:0]  i_re         ;
  input  wire [31:0] i_wdata      ;
  output wire [31:0] o_rdata      ;
  output wire        o_pol        ;
  output wire        o_ence       ;
  output wire [15:0] o_posmax     ;
  output wire [15:0] o_pdcnt      ;
  output wire [15:0] o_edgecnt    ;
  output wire [15:0] o_poscnt_int ;
  input  wire [15:0] i_poscnt_cur ;

  // Parameter
  parameter pCTL    = 0;
  parameter pSTR    = 1;
  parameter pPOSMAX = 2;
  parameter pOUTCNT = 3;
  parameter pPOSCNT = 4;
  parameter pVER    = 5;

  // Internal reg and wire declaration
  reg               reg_pol ;
  reg               reg_ence ;
  reg [15:0]        reg_posmax ;
  reg [15:0]        reg_pdcnt ;
  reg [15:0]        reg_poscnt;
  reg signed [15:0] reg_edgcnt ;

  // Write logic for CTL register
  always @ (posedge i_pclk) begin
    if (~i_presetn) begin
      reg_pol <= 1'b0;
    end
    else if (i_we[pCTL] & ~reg_ence) begin
      reg_pol <= i_wdata[0];
    end
    else begin
      reg_pol <= reg_pol
    end
  end

  // Write logic for STR register
  always @ (posedge i_pclk) begin
    if (~i_presetn) begin
      reg_ence <= 1'b0;
    end
    else if (i_we[pSTR]) begin
      reg_ence <= i_wdata[0];
    end
    else begin
      reg_ence <= reg_ence;
    end
  end

  // Write logic for POSMAX
  always @ (posedge i_pclk) begin
    if (~i_presetn) begin
      reg_posmax <= 16'h0;
    end
    else if (i_we[pPOSMAX] & i_wdata[0] & i_wdata[1]) begin
      reg_posmax <= i_wdata[15:0];
    end
    else begin
      reg_posmax <= reg_posmax;
    end
  end

  // Write logic for OUTCNT
  always @ (posedge i_pclk) begin
    if (~i_presetn) begin
      {reg_pdcnt, reg_edgcnt} <= 32'h0;
    end
    else if (i_we[pOUTCNT] & (i_wdata[31:1] != 0) ) begin
      {reg_pdcnt, reg_edgcnt} <= i_wdata[31:0];
    end
    else begin
      {reg_pdcnt, reg_edgcnt} <= {reg_pdcnt, reg_edgcnt};
    end
  end

  // Write logic for initial value of POSCNT
  always @ (posedge i_pclk) begin
    if (~i_presetn) begin
      reg_poscnt <= 16'h0;
    end
    else if (i_we[pPOSCNT]) begin
      reg_poscnt <= i_wdata[15:0];
    end
    else begin
      reg_poscnt <= reg_poscnt;
    end
  end

  // No write logic for VER register since it is read-only



endmodule // ENCOUT_REG_BLK
