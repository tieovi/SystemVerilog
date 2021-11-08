module ENCOUT_PHASE_GEN (/*AUTOARG*/
  // Outputs
  o_period_aset_vld, o_period_aset, o_pouta, o_poutb, o_poutz,
  o_elc_err, o_reg_poscnt,
  // Inputs
  i_pclk, i_presetn, i_reg_ctl, i_reg_str, i_reg_opt, i_reg_posmax,
  i_reg_period, i_reg_outcnt, i_wr_poscnt, i_wdata, i_elcin_sync
  ) ;

  input  wire        i_pclk            ;
  input  wire        i_presetn         ;

  input  wire [ 4:0] i_reg_ctl         ;
  input  wire        i_reg_str         ;
  input  wire        i_reg_opt         ;
  input  wire [15:0] i_reg_posmax      ;
  input  wire [15:0] i_reg_period      ;
  input  wire [15:0] i_reg_outcnt      ;
  input  wire        i_wr_poscnt       ;
  output wire        o_period_aset_vld ;
  output wire [15:0] o_period_aset     ;
  input  wire [15:0] i_wdata           ;
  input  wire        i_elcin_sync      ;
  output reg         o_pouta           ;
  output reg         o_poutb           ;
  output reg         o_poutz           ;
  output wire        o_elc_err         ;
  output wire [15:0] o_reg_poscnt      ;

  //--------------------------------------------------------------------------------
  // Parameter
  //--------------------------------------------------------------------------------
  localparam pIDLE   = 3'b000; // After reset
  localparam pENCE   = 3'b001; // Encout is operating (ENCE=1) and wait for ELC interrupt
  localparam pPERIOD = 3'b010; // Period count in automactic acquisition function
  localparam pELCIN  = 3'b011; // Capture regsiter information and load to register
  localparam pCOUNT  = 3'b100; // Generating phase signal

  //--------------------------------------------------------------------------------
  // Internal wire, reg declaration
  //--------------------------------------------------------------------------------
  // FSM
  reg [2:0]   r_state;
  reg [2:0]   r_state_next;

  // Internal counter
  reg [15:0]  r_poscnt;
  reg [16:0]  r_pdcnt;
  wire [15:0] w_pdcnt_incr;
  reg [ 1:0]  r_elcin_cnt;
  reg [15:0]  r_period_cnt;
  wire        w_pdcnt_exceed;
  wire        w_poscnt_down;

  // EDGCNT capture logic
  reg [15:0]  w_edgcnt_abs;
  reg         w_edgcnt_sign;
  reg [15:0]  r_edgcnt_abs_cap;
  reg         r_edgcnt_sign_cap;

  // Phase A and Phase B logic
  reg         r_pouta;
  reg         r_poutb;
  reg         r_poutz;

  // PERIOD register update
  reg [15:0]  r_period_aset;
  reg         r_period_aset_vld;

  // Internal bits field of each register
  wire        w_ence;
  wire        w_aset;
  wire [15:0] w_edgcnt;
  wire        w_pol;
  wire [ 2:0] w_zw;
  wire        w_zs;

  //--------------------------------------------------------------------------------
  // Decode internal register fields
  //--------------------------------------------------------------------------------
  assign w_ence   = i_reg_str;
  assign w_aset   = i_reg_opt;
  assign w_edgcnt = i_reg_outcnt;
  assign w_pol    = i_reg_ctl[0];
  assign w_zw     = i_reg_ctl[3:1];
  assign w_zs     = i_reg_ctl[4];

  //--------------------------------------------------------------------------------
  // FSM
  //--------------------------------------------------------------------------------

  // Current state
  always @ (posedge i_pclk) begin
    if (~i_presetn) begin
      r_state <= pIDLE;
    end
    else begin
      r_state <= r_state_next;
    end
  end

  // Next state logic
  always @ (*) begin
    if (w_ence == 1'b0) begin
      r_state_next = pIDLE;
    end
    else begin
      case(r_state)
        pIDLE: begin
          if (w_ence)
            r_state_next = pENCE;
          else
            r_state_next = pIDLE;
        end
        pENCE: begin
          if (i_elcin_sync & w_aset)
            r_state_next = pPERIOD;
          else if (i_elcin_sync & ~w_aset & |i_reg_outcnt)
            r_state_next = pELCIN;
          else
            r_state_next = pENCE;
        end
        pPERIOD: begin
          if ( (r_elcin_cnt == 2'b10) & i_elcin_sync)
            r_state_next = pELCIN;
          else
            r_state_next = pPERIOD;
        end
        pELCIN: begin
          r_state_next = pCOUNT;
        end
        pCOUNT: begin
          if (r_period_cnt == i_reg_period & i_elcin_sync == 1'b0)
            r_state_next = pENCE;
          else if (r_period_cnt >= (i_reg_period-1) & i_elcin_sync == 1'b1)
            r_state_next = pELCIN;
          else
            r_state_next = pCOUNT;
        end
        default: r_state_next = pIDLE;
      endcase // case (r_state)
    end // else: !if(w_ence)
  end

  //--------------------------------------------------------------------------------
  // Register capture block
  //--------------------------------------------------------------------------------
  // Period detection
  always @(posedge i_pclk) begin
    if (~i_presetn)
      r_elcin_cnt <= 2'b0;
    else
      if (i_elcin_sync)
        if (r_state == pENCE)
          r_elcin_cnt <= 2'b01;
        else if (r_state == pPERIOD)
          r_elcin_cnt <= r_elcin_cnt + 2'b01;
        else
          r_elcin_cnt <= r_elcin_cnt;
  end

  always @ (posedge i_pclk) begin
    if (~i_presetn) begin
      r_period_aset     <= 16'b0;
      r_period_aset_vld <= 1'b0;
    end
    else if (r_elcin_cnt == 2'b01 & i_elcin_sync == 1'b1) begin
      r_period_aset     <= r_period_cnt;
      r_period_aset_vld <= 1'b1;
    end
    else begin
      r_period_aset     <= r_period_aset;
      r_period_aset_vld <= 1'b0;
    end
  end

  //--------------------------------------------------------------------------------
  // EDGCNT Register capture logic
  assign w_edgcnt_abs  = i_reg_outcnt[15] ? ~i_reg_outcnt + 1 : i_reg_outcnt;
  assign w_edgcnt_sign = i_reg_outcnt[15];

  // Capture for ELC interrupt event
  always @ (posedge i_pclk) begin
    if (~i_presetn) begin
      r_edgcnt_abs_cap  <= 16'h0000;
      r_edgcnt_sign_cap <= 1'b0;
    end
    else if (i_elcin_sync & r_state_next == pELCIN) begin
      r_edgcnt_abs_cap  <= w_edgcnt_abs;
      r_edgcnt_sign_cap <= w_edgcnt_sign;
    end
  end

  assign w_pdcnt_incr  = (r_state_next == pELCIN) ? w_edgcnt_abs  : r_edgcnt_abs_cap ;
  assign w_poscnt_down = (r_state_next == pELCIN) ? w_edgcnt_sign : r_edgcnt_sign_cap;

  //--------------------------------------------------------------------------------
  // Counter logic
  //--------------------------------------------------------------------------------
  // r_period_cnt[15:0]
  always @ (posedge i_pclk)
    if (~i_presetn)
      r_period_cnt <= 16'h0000;
    else if (i_elcin_sync)
      if (r_state != pIDLE)
        r_period_cnt <= 16'h0001;
      else
        r_period_cnt <= 16'h0000;
    else
      if (r_state == pELCIN | r_state == pPERIOD | r_state == pCOUNT)
        r_period_cnt <= r_period_cnt + 16'h0001;
      else
        r_period_cnt <= 16'h0000;



  // r_pdcnt
  assign w_pdcnt_exceed  = r_pdcnt + w_pdcnt_incr > {1'b0, i_reg_period};

  always @ (posedge i_pclk)
    if (~i_presetn)
      r_pdcnt <= 17'h00000;
    else
      if (i_elcin_sync)
        if (r_state == pENCE | r_state == pCOUNT)
          r_pdcnt <= {1'b0, w_pdcnt_incr};
        else
          r_pdcnt <= 17'h00000;
      else
        if (r_state == pCOUNT | r_state == pELCIN)
          if ( w_pdcnt_exceed)
            r_pdcnt <= r_pdcnt + w_pdcnt_incr - i_reg_period;
          else
            r_pdcnt <= r_pdcnt + w_pdcnt_incr;
        else
          r_pdcnt <= 17'h00000;

  // r_poscnt
  always @ (posedge i_pclk) begin
    if (~i_presetn)
      r_poscnt <= 0;
    else begin
      case(r_state)
        pIDLE: begin
          if (i_wr_poscnt)
            r_poscnt <= i_wdata[15:0];
          else
            r_poscnt <= r_poscnt;
        end
        pENCE: begin
          if (i_elcin_sync)
            if (w_poscnt_down)
              r_poscnt <= (r_poscnt == 0) ? i_reg_posmax-1 : r_poscnt - 16'b1;
            else
              r_poscnt <= (r_poscnt == i_reg_posmax-1) ?  0 : r_poscnt + 16'b1;
        end
        pCOUNT : begin
          if ( w_pdcnt_exceed)
            if (w_poscnt_down)
              r_poscnt <= (r_poscnt == 0) ? i_reg_posmax-1  : r_poscnt - 16'b1;
            else
              r_poscnt <= (r_poscnt == i_reg_posmax-1) ?  0 : r_poscnt + 16'b1;
          else
            r_poscnt <= r_poscnt;
        end
        default: begin
          r_poscnt <= r_poscnt;
        end
      endcase // case (r_state)
    end
  end

  //--------------------------------------------------------------------------------
  // Output selection
  //--------------------------------------------------------------------------------
  always @ (*) begin
    case(r_poscnt[1:0])
      2'b00  : {r_pouta, r_poutb} = 2'b10;
      2'b01  : {r_pouta, r_poutb} = 2'b00;
      2'b10  : {r_pouta, r_poutb} = 2'b01;
      default: {r_pouta, r_poutb} = 2'b11;
    endcase // case (r_poscnt[1:0])
  end

  always @(*) begin
    casez ({w_zw, w_zs})
      4'b000_z: r_poutz = 1'b0;
      4'b001_z: r_poutz = (r_poscnt == 0);
      4'b010_0: r_poutz = (r_poscnt == i_reg_posmax-1) | (r_poscnt == 16'h0000);
      4'b010_1: r_poutz = (r_poscnt == 16'h0001      ) | (r_poscnt == 16'h0000);
      4'b011_z: r_poutz = (r_poscnt == 16'h0001      ) | (r_poscnt == 16'h0000)|
                          (r_poscnt == i_reg_posmax-1) ;
      4'b100_0: r_poutz = (r_poscnt == 16'h0001      ) | (r_poscnt == 16'h0000)|
                          (r_poscnt == i_reg_posmax-1) | (r_poscnt == 16'h0002);
      4'b100_1: r_poutz = (r_poscnt == 16'h0001      ) | (r_poscnt == 16'h0000)|
                          (r_poscnt == i_reg_posmax-1) | (r_poscnt == i_reg_posmax-2);
      default : r_poutz = 1'b0;
    endcase // case ()
  end

  always @ (posedge i_pclk) begin
    o_pouta <= r_pouta;
    o_poutb <= r_poutb;
    o_poutz <= r_poutz;
  end

  assign o_reg_poscnt = r_poscnt;

endmodule // ENCOUT_PHASE_GEN
// Local Variables:
// verilog-library-directories:(".")
// End:
