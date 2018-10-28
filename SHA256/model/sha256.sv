module sha256 (/*AUTOARG*/ ) ;

  function bit [31:0] Ch(bit [31:0] x, logic [31:0] y, logic [31:0] z);
    return (x & y) ^ (~x & z);
  endfunction // Ch

  function bit [31:0] Maj(bit [31:0] x, logic [31:0] y, logic [31:0] z);
    return (x & y) ^ (x & z) ^ (y & z);
  endfunction // Maj

  function bit [31:0] ROTR(int n, bit [31:0] x);
    return (x >> n) | (x <<(32-n));
  endfunction // ROTR

  function bit [31:0] SHR(bit [4:0] n, bit [31:0] x);
    return (x >> n);
  endfunction // SHR

  function bit [31:0] E0(bit [31:0] x);
    return ( ROTR(2, x) ^ ROTR(13, x) ^ ROTR(22, x) );
  endfunction // E0

  function bit [31:0] E1(bit [31:0] x);
    return ( ROTR(6, x) ^ ROTR(11, x) ^ ROTR(25, x) );
  endfunction // E1

  function bit [31:0] O0(bit [31:0] x);
    return ( ROTR(7, x) ^ ROTR(18, x ) ^ SHR(3, x) );
  endfunction // O0

  function bit [31:0] O1(bit [31:0] x);
    return ( ROTR(17, x) ^ ROTR(19, x) ^ SHR(10, x) );
  endfunction // O1

  function bit [255:0] sha256_cal(string msg);
    int l;                    // length in bits
    int k;                    // number of appending zeroes
    int N;                    // number of 512-bits blocks
    //  string msg = "abc";     // original message
    //  string msg = "abcdefghjklm";     // original message
    //  string msg = "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq";
    bit [0:127][7:0] Mp;      // Padded message
    bit [0:31][31:0] Mn;      // Tow 512 bit blocks is expressed as sixteen 32-bit words
    bit [0:63][0:7][31:0] H;  // Hash value
    bit [0:63][31:0] W;       // Message schedule

    // Eights working variable
    bit [31:0] a;
    bit [31:0] b;
    bit [31:0] c;
    bit [31:0] d;
    bit [31:0] e;
    bit [31:0] f;
    bit [31:0] g;
    bit [31:0] h;
    bit [31:0] T1;
    bit [31:0] T2;


    // for debug
    bit [31:0] E1_e;
    bit [31:0] Ch_efg ;
    bit [31:0] E0_a;
    bit [31:0] Maj_abc;

    // SHA-256 constants
    bit [31:0] K[] = {
                      32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
                      32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
                      32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
                      32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
                      32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
                      32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
                      32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
                      32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
                      };

    int idx;
    int i;
    int t;

    //  initial begin
    //--------------------------------------------------------------------------
    // Step1 : padding the message
    //--------------------------------------------------------------------------
    l = msg.len()*8;
    N = (l < 448) ? 1 : 2;

    for(idx = 0; idx < msg.len(); idx++) begin
      Mp[idx] = msg[idx];
    end
    Mp[idx] = 8'h80;

    if (N == 1)
      Mp[56:63] = l;
    else if (N == 2)
      Mp[120:127] = l;

    Mn = Mp;
    $display("Input  message: %h\n", msg);
    $display("Padded message: %h\n", Mp);

    // Intialize hash value
    H[0] =
          {
           32'h6a09e667,
           32'hbb67ae85,
           32'h3c6ef372,
           32'ha54ff53a,
           32'h510e527f,
           32'h9b05688c,
           32'h1f83d9ab,
           32'h5be0cd19
           };

    for(i = 1; i <= N; i++) begin
      // 1. Prepare the message schedule (W)
      for(t = 0; t < 16; t++) begin
        W[t] = Mn[16*(i-1)+t];
      end

      for(t=16; t < 64; t++) begin
        W[t] = O1(W[t-2]) + W[t-7] + O0(W[t-15]) + W[t-16];
      end

      // 2. Initialize working variables
      a = H[i-1][0];
      b = H[i-1][1];
      c = H[i-1][2];
      d = H[i-1][3];
      e = H[i-1][4];
      f = H[i-1][5];
      g = H[i-1][6];
      h = H[i-1][7];

      // 3. For t = 0 to 63
      $display("      a        b        c        d        e        f        g        h        E1        Ch_efg      Kt      Wt");
      for(t = 0; t < 64; t++) begin
        E1_e = E1(e);
        Ch_efg = Ch(e, f, g);
        E0_a = E1(a);
        Maj_abc = Maj(a, b, c);

        T1 = h + E1(e) + Ch(e, f, g) + K[t] + W[t];
        T2 = E0(a) + Maj(a, b, c);
        h = g;
        g = f;
        f = e;
        e = d+T1;
        d = c;
        c = b;
        b = a;
        a = T1+T2;
        $display("t=%2d: %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x", t, a, b, c, d, e, f, g, h, E1_e, Ch_efg, K[t], W[t]);

      end // (t = 0; t < 64; t++)

      H[i][0] = H[i-1][0] + a;
      H[i][1] = H[i-1][1] + b;
      H[i][2] = H[i-1][2] + c;
      H[i][3] = H[i-1][3] + d;
      H[i][4] = H[i-1][4] + e;
      H[i][5] = H[i-1][5] + f;
      H[i][6] = H[i-1][6] + g;
      H[i][7] = H[i-1][7] + h;

      $display("Intermediate hash value %0d: %8x %8x %8x %8x %8x %8x %8x %8x\n", i, H[i][0], H[i][1], H[i][2], H[i][3], H[i][4], H[i][5], H[i][6], H[i][7]);

    end // (i = 1; i < N; i++)

    $display("The final hash value: %8x %8x %8x %8x %8x %8x %8x %8x\n", H[N][0], H[N][1], H[N][2], H[N][3], H[N][4], H[N][5], H[N][6], H[N][7]);
    //  end // initial begin

    return ({H[N][0], H[N][1], H[N][2], H[N][3], H[N][4], H[N][5], H[N][6], H[N][7]});

  endfunction // sha256_cal

  //------------------------------------------------------------
  // Variable declaration
  //------------------------------------------------------------
  string msg = "abcd";
  bit [256:0] s_data;

  initial begin
    s_data = sha256_cal(msg);
    $display("The hash calculation is done!");
  end

endmodule // sha256
