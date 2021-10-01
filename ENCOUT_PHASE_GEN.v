module ENCOUT_PHASE_GEN (/*AUTOARG*/
  // Outputs
  o_pouta0, o_pouta1, o_poutb0, o_poutb1, o_poutz0, o_poutz1,
  // Inputs
  i_pclk, i_presetn, i_pol, i_ence, i_posmax, i_pdcnt, i_edgcnt,
  i_poscnt_int, i_set_poscnt, i_elc_intr
  ) ;
  // system I/F
  input i_pclk                   ;
  input i_presetn                ;
  // from ENCOUT_REG_BLK
  input wire        i_pol        ;
  input wire        i_ence       ;
  input wire [15:0] i_posmax     ;
  input wire [15:0] i_pdcnt      ;
  input wire [15:0] i_edgcnt     ;
  input wire [15:0] i_poscnt_int ;
  input wire        i_set_poscnt ;
  // from/to ENCOUT_TOP
  input  wire       i_elc_intr   ;
  output wire       o_pouta0     ;
  output wire       o_pouta1     ;
  output wire       o_poutb0     ;
  output wire       o_poutb1     ;
  output wire       o_poutz0     ;
  output wire       o_poutz1     ;

  // Parameter
  localparam pIDLE = 2'b00; // After reset
  localparam pINT  = 2'b01; // Initial setting (update the value of POSMAX or POSCNT)
  localparam pENCE = 2'b10; // Encout is operating (ENCE=1) and wait for ELC interrupt
//  localparam pELCI = 2'b011; // Receving ELC interrupt and update new register setting
  localparam pGEN  = 2'b11; // Generating phase signal

  // Internal wire, reg declaration
  reg [1:0]  r_state;
  reg [1:0]  r_state_next;

  reg [15:0] r_edgcnt;
  reg [15:0] r_poscnt;
  reg [15:0] r_pdcnt;           // Phase diff counter

  reg [15:0] r_pdcnt_cap;       // Capture register setting for current carrier period
  reg [15:0] r_edgcnt_cap;

  reg [ 1:0] r_phase;

  // State
  always @ (i_pclk) begin
    if (~i_presetn) begin
      r_state <= pIDLE;
    end
    else begin
      r_state <= r_state_next;
    end
  end

  // Next state logic
  always @ (*) begin
    case(r_state)
      pIDLE: begin
        if (i_set_poscnt)
          r_state_next = pINT;
        else if (i_ence)
          r_state_next = pENCE;
        else
          r_state_next = pIDLE;
      end
      pINT: begin
        if (i_ence)
          r_state_next = pENCE;
        else
          r_state_next = pINT;
      end
      pENCE: begin
        if (i_ence == 1'b0)
          r_state_next = pINT;
        else if (i_elc_intr == 1'b1 & i_edgcnt != 16'hFFFF)
          r_state_next = pGEN;
        else
          r_state_next = pENCE;
      end
      pGEN: begin
        if (r_edgcnt == r_edgcnt_cap & r_pdcnt == 0)
          r_state_next = pENCE;
        else
          r_state_next = pGEN;
      end
      default: r_state = pIDLE;
    endcase // case (r_state)
  end

  always @ (posedge i_pclk) begin
    if (~i_presetn) begin
      r_edgcnt     <= 16'b0;
      r_pdcnt      <= 16'b0;
      r_poscnt     <= 16'b0;
      r_pdcnt_cap  <= 16'b0;
      r_edgcnt_cap <= 16'b0;
    end
    else begin
      case (r_state)
        pIDLE: begin
          r_edgcnt     <= 16'b0;
          r_pdcnt      <= 16'b0;
          r_poscnt     <= 16'b0;
          r_pdcnt_cap  <= 16'b0;
          r_edgcnt_cap <= 16'b0;
        end
        pINT: begin
          // load initial value of internal counter when recieving write to POSCNT
          // (1) r_postcnt is load from register
          // (2) r_edgecnt
          r_edgcnt     <= r_edgcnt;
          r_pdcnt      <= r_pdcnt;
          r_poscnt     <= i_poscnt_int;
          r_pdcnt_cap  <= r_pdcnt_cap;
          r_edgcnt_cap <= r_edgcnt_cap;
        end
        pENCE: begin
          // capture OUTCNT register settting when i_elc_intr is asserted
          r_poscnt <= r_poscnt;
          r_edgcnt <= r_edgcnt;
          r_pdcnt  <= 0;
          if (i_elc_intr & i_edgcnt != 16'hFFFF) begin
            r_pdcnt_cap  <= i_pdcnt;
            r_edgcnt_cap <= i_edgcnt;
            if (i_edgcnt[15]) begin
              r_poscnt <= r_poscnt - 1 ;
              r_edgcnt <= 16'hFFFF;
            end
            else begin
              r_poscnt <= r_poscnt + 1 ;
              r_edgcnt <= 1;
            end
          end
          else begin
            r_edgcnt_cap <= r_edgcnt_cap;
            r_pdcnt_cap  <= r_pdcnt_cap;
          end
        end
        pGEN: begin
          r_pdcnt_cap <= r_pdcnt_cap;
          r_edgcnt_cap <= r_edgcnt_cap;
          // update edgcnt
          // Clockwise:
          //            + r_edgcnt increase by 1 when r_pdcnt = r_pdcnt_cap
          //            + r_poscnt increase by 1
          if (r_edgcnt_cap[15] == 1'b0) begin
            if (r_edgcnt < r_edgcnt_cap) begin
              r_pdcnt  <= (r_pdcnt  == r_pdcnt_cap) ? 16'h0 : r_pdcnt  + 16'b1;
              r_edgcnt <= (r_pdcnt  == r_pdcnt_cap) ? r_edgcnt + 1 : r_edgcnt;

              if (r_pdcnt == r_pdcnt_cap)
                  r_poscnt <= (r_poscnt == i_posmax) ? 0 : r_poscnt + 1;
            end
          end
          else begin
          // Counter - Clockwise:
          //            + r_edgcnt decrease by 1 when r_pdcnt = r_pdcnt_cap
          //            + r_poscnt decrease by 1
            if (r_edgcnt > r_edgcnt_cap) begin
              r_pdcnt  <= (r_pdcnt  == r_pdcnt_cap) ? 16'h0    : r_pdcnt  + 16'b1;
              r_edgcnt <= (r_pdcnt  == r_pdcnt_cap) ? r_edgcnt - 1: r_edgcnt;
              if (r_pdcnt == r_pdcnt_cap)
                  r_poscnt <= (r_poscnt == 0) ? i_posmax : r_poscnt - 1;
            end
          end
        end
        default: begin
          r_edgcnt <= r_edgcnt;
          r_pdcnt  <= r_pdcnt;
          r_poscnt <= r_poscnt;

        end
      endcase // case (r_state)
    end
  end // always @ (posedge i_pclk)


  always @ (*) begin
    case(r_poscnt[1:0])
      2'b00: r_phase[1:0] = 2'b10;
      2'b01: r_phase[1:0] = 2'b00;
      2'b10: r_phase[1:0] = 2'b01;
      default: r_phase[1:0] = 2'b11;
    endcase // case (r_poscnt[1:0])
  end

  assign o_pouta0 = r_phase[1];
  assign o_pouta1 = r_phase[1];
  assign o_poutb0 = r_phase[0] ^ i_pol;
  assign o_poutb1 = r_phase[0] ^ i_pol;

  // TODO
  assign o_poutz0 = 1'b1;
  assign o_poutz1 = 1'b1;

endmodule // ENCOUT_PHASE_GEN
