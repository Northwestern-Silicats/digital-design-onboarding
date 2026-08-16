package pixel_pkg;
  // Every color channel is 8 bits wide
  localparam int PIXEL_W = 8;
  /* 
    Packed struct acts like a bundle of bits (Usually what you want for RTL/Synthesis)
    For inputs / outputs
  */
  typedef struct packed {
    logic [PIXEL_W-1:0] red;
    logic [PIXEL_W-1:0] green;
    logic [PIXEL_W-1:0] blue;
  } pixel_t;

endpackage
    
