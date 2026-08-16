package pixel_pkg;

  localparam int PIXEL_W = 8;

  typedef struct packed {
    logic [PIXEL_W-1:0] red;
    logic [PIXEL_W-1:0] green;
    logic [PIXEL_W-1:0] blue;
  } pixel_t;

endpackage
