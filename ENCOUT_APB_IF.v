module ENCOUT_APB_IF ( /*AUTOARG*/
  // Outputs
  o_pready, o_pslverr, o_prdata, o_we, o_re, o_wdata,
  // Inputs
  i_pclk, i_presetn, i_paddr, i_psel, i_pwrite, i_penable, i_pwdata,
  i_rdata
  ) ;

  localparam ADR_CTL    = 32'hA011_C100;
  localparam ADR_STR    = 32'hA011_C101;
  localparam ADR_OPT    = 32'hA011_C102;
  localparam ADR_POSMAX = 32'hA011_C106;
  localparam ADR_OUTCNT = 32'hA011_C10C;
  localparam ADR_PERIOD = 32'hA011_C10E;
  localparam ADR_POSCNT = 32'hA011_CD08;
  localparam ADR_STATUS = 32'hA011_CD0A;
  localparam ADR_VER    = 32'hA011_2300;


  // APB3 I/F
  input  wire        i_pclk    ;
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
  output reg  [ 8:0] o_we      ;
  output reg  [ 8:0] o_re      ;
  input  wire [31:0] i_rdata   ;
  output wire [31:0] o_wdata   ;

  // write enable logic
  always @(*) begin
    if (i_psel & ~i_penable & i_pwrite) begin
      case(i_paddr[31:0])
        ADR_CTL    : o_we = 1 << 0; // CTL
        ADR_STR    : o_we = 1 << 1; // STR
        ADR_OPT    : o_we = 1 << 2; // OPT
        ADR_POSMAX : o_we = 1 << 3; // POSMAX
        ADR_OUTCNT : o_we = 1 << 4; // OUTCNT
        ADR_PERIOD : o_we = 1 << 5; // PERIOD
        ADR_POSCNT : o_we = 1 << 6; // POSCNT
        ADR_STATUS : o_we = 1 << 7; // STATUS
        ADR_VER    : o_we = 1 << 8; // VER
        default    : o_we = 9'h000; // Default
      endcase // case (i_paddr[31:0])
    end
    else begin
      o_we = 9'h000;
    end
  end

  // read enable logic
  always @(*) begin
    if (i_psel & ~i_penable & ~i_pwrite) begin
      case(i_paddr[31:0])
        ADR_CTL    : o_re = 1 << 0; // CTL
        ADR_STR    : o_re = 1 << 1; // STR
        ADR_OPT    : o_re = 1 << 2; // OPT
        ADR_POSMAX : o_re = 1 << 3; // POSMAX
        ADR_OUTCNT : o_re = 1 << 4; // OUTCNT
        ADR_PERIOD : o_re = 1 << 5; // PERIOD
        ADR_POSCNT : o_re = 1 << 6; // POSCNT
        ADR_STATUS : o_re = 1 << 7; // STATUS
        ADR_VER    : o_re = 1 << 8; // VER
        default    : o_re = 9'h000; // Default
      endcase // case (i_paddr[31:0])
    end
    else begin
      o_re = 9'h000;
    end
  end

  // Slave error, fix to Low
  assign o_pslverr = 1'b0;

  // Indicate that ready to take next transaction, fix to High
  assign o_pready = 1;

  // Forward APB read/write data from REG_BLK
  assign o_prdata = i_rdata;
  assign o_wdata = i_pwdata;

  wire unused = i_pclk;

endmodule // ENCOUT_APB_IF
