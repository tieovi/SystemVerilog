module ENCOUT_REG_BLK (/*AUTOARG*/
  // Outputs
  o_rdata, o_pol, o_ence, o_posmax, o_pdcnt, o_edgcnt, o_poscnt_int, o_set_poscnt,
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
  output wire [15:0] o_edgcnt     ;
  output wire [15:0] o_poscnt_int ;
  output wire        o_set_poscnt ;
  input  wire [15:0] i_poscnt_cur ;

  // Parameter
  parameter pCTL    = 0;
  parameter pSTR    = 1;
  parameter pPOSMAX = 2;
  parameter pOUTCNT = 3;
  parameter pPOSCNT = 4;
  parameter pVER    = 5;

  // Internal reg and wire declaration
  reg               reg_pol    ;
  reg               reg_ence   ;
  reg [15:0]        reg_posmax ;
  reg [15:0]        reg_pdcnt  ;
  reg [15:0]        reg_poscnt ;
  reg signed [15:0] reg_edgcnt ;
  reg [31:0]        r_rd_data  ;
  reg [31:0]        r_rdata    ;


  // Write logic for CTL register
  always @ (posedge i_pclk) begin
    if (~i_presetn) begin
      reg_pol <= 1'b0;
    end
    else if (i_we[pCTL] & ~reg_ence) begin
      reg_pol <= i_wdata[0];
    end
    else begin
      reg_pol <= reg_pol;
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
      {reg_pdcnt, reg_edgcnt} <= 32'hFFFF_0000;
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

  // Read logic
  always @ (*) begin
    case(i_re[5:0])
      6'b00_0001: r_rd_data = {31'b0, reg_pol}                     ; // reg CTL
      6'b00_0010: r_rd_data = {31'b0, reg_ence}                    ; // reg STR
      6'b00_0100: r_rd_data = {16'b0, reg_posmax}                  ; // reg POSMAX
      6'b00_1000: r_rd_data = {reg_pdcnt, reg_edgcnt}              ; // reg OUTCNT
      6'b01_0000: r_rd_data = reg_ence ? {16'h0, i_poscnt_cur} :
                                               {16'h0, reg_poscnt} ; // reg POSCNT
      6'b10_0000: r_rd_data = {24'h0, 8'h10}                       ;
      default   : r_rd_data = 32'h0;
    endcase // case (i_re[5:0])
  end

  always @ (posedge i_pclk) begin
    if (~i_presetn) begin
      r_rdata <= 32'h0;
    end
    else begin
      if ( (|i_we) | (i_re) ) begin
        r_rdata <= r_rd_data;
      end
      else begin
        r_rdata <= r_rdata;
      end
    end
  end
  assign o_rdata = r_rdata;

  // output to PHASE_GEN
  assign o_pol        = reg_pol       ;
  assign o_ence       = reg_ence      ;
  assign o_posmax     = reg_posmax    ;
  assign o_pdcnt      = reg_pdcnt     ;
  assign o_edgcnt     = reg_edgcnt    ;
  assign o_poscnt_int = reg_poscnt    ;
  assign o_set_poscnt = i_we[pPOSCNT] ;

endmodule // ENCOUT_REG_BLK
