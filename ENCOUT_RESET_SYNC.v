module ENCOUT_RESET_SYNC (/*AUTOARG*/
  // Outputs
  o_presetn_sync,
  // Inputs
  i_pclk, i_presetn, ten
  ) ;
  input i_pclk;
  input i_presetn;
  input ten;

  output o_presetn_sync;

  reg [1:0] r_sync_ff;
  always @ (posedge i_pclk or negedge i_presetn)
    if (~i_presetn) begin
      r_sync_ff[0] <= 1'b0;
      r_sync_ff[1] <= 1'b0;
    end
    else begin
      r_sync_ff[0] <= 1'b1;
      r_sync_ff[1] <= r_sync_ff[0];
    end

  assign o_presetn_sync  =  ten ? i_presetn : r_sync_ff[1];

endmodule // ENCOUT_RESET_SYNC
