module encout_apb_if (
  // Outputs
  o_pready, o_pslverr, o_we, o_re, o_prdata, o_wdata,
  // Inputs
  i_clk, i_presetn, i_paddr, i_psel, i_pwrite, i_penable, i_pwdata,
  i_rdata
  ) ;
  // APB3 I/F
  input  wire        i_clk     ;
  input  wire        i_presetn ;
  input  wire [31:0] i_paddr   ;
  input  wire        i_psel    ;
  input  wire        i_pwrite  ;
  input  wire        i_penable ;
  input  wire [31:0] i_pwdata  ;
  output wire        o_pready  ;
  output wire        o_pslverr ;
  output wire [31:0] o_prdata  ;
  // Internal
  output reg  [ 5:0] o_we      ;
  output reg  [ 5:0] o_re      ;
  input  wire [31:0] i_rdata   ;
  output wire [31:0] o_wdata   ;

  // write enable logic
  always @(*) begin
    if (i_psel & ~i_penable & i_pwrite) begin
      case(i_paddr[31:0])
        32'h91_C100: o_we = 1 << 0; // CTL
        32'h91_C101: o_we = 1 << 1; // STR
        32'h91_C106: o_we = 1 << 2; // POSMAX
        32'h91_C10C: o_we = 1 << 3; // OUTCNT
        32'h91_CD08: o_we = 1 << 4; // OUTCNT
        32'hD1_C700: o_we = 1 << 5; // VER
        default    : o_we = 6'b00_0000;
      endcase // case (i_paddr[31:0])
    end
    else begin
      o_we = 6'b00_0000;
    end
  end

  // read enable logic
  always @(*) begin
    if (i_psel & ~i_penable & ~i_pwrite) begin
      case(i_paddr[31:0])
        32'h91_C100: o_re = 1 << 0; // CTL
        32'h91_C101: o_re = 1 << 1; // STR
        32'h91_C106: o_re = 1 << 2; // POSMAX
        32'h91_C10C: o_re = 1 << 3; // OUTCNT
        32'h91_CD08: o_re = 1 << 4; // OUTCNT
        32'hD1_C700: o_re = 1 << 5; // VER
        default    : o_re = 6'b00_0000;
      endcase // case (i_paddr[31:0])
    end
    else begin
      o_re = 6'b00_0000;
    end
  end

  // Slave error, fix to Low
  assign o_pslverr = 1'b0;

  // Indicate that ready to take next transaction, fix to High
  assign o_pready = 1'b1;

  // Forward APB read/write data from REG_BLK
  assign o_prdata = i_rdata;
  assign o_wdata = i_pwdata;

endmodule // encout_apb_if
