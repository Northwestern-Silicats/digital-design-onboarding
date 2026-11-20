package pixel_pkg;
  localparam int PIXEL_W    = 8;  // Every color channel is 8 bits wide
  localparam int KERNEL_LEN = 2;  // We are using a 2x2 kernel
  
  /* 
    Packed struct acts like a bundle of bits (Usually what you want for RTL/Synthesis)
    For inputs / outputs
  */
  typedef struct packed {
    logic [PIXEL_W-1:0] red;
    logic [PIXEL_W-1:0] green;
    logic [PIXEL_W-1:0] blue;
  } pixel_t;

  /* 
    Take 4 pixel colors and return a value representing the adverage of the two median values
  */
  function automatic logic [PIXEL_W-1:0] find_median_channel(
    input logic [PIXEL_W-1:0] value_0_i,
    input logic [PIXEL_W-1:0] value_1_i,
    input logic [PIXEL_W-1:0] value_2_i,
    input logic [PIXEL_W-1:0] value_3_i
  );
    
    logic [PIXEL_W-1:0] value_0;
    logic [PIXEL_W-1:0] value_1;
    logic [PIXEL_W-1:0] value_2;
    logic [PIXEL_W-1:0] value_3;
    logic [PIXEL_W-1:0] swap_value;
    logic [PIXEL_W:0]   median_sum;

    begin
      value_0 = value_0_i;
      value_1 = value_1_i;
      value_2 = value_2_i;
      value_3 = value_3_i;

      // TODO: Sort the color values using the swap method 
      // Value_1 and value_2 will end up being the median values

      if (value_0 > value_1) begin
        swap_value = value_0;
        value_0    = value_1;
        value_1    = swap_value;
      end

      if (value_2 > value_3) begin
        swap_value = value_2;
        value_2    = value_3;
        value_3    = swap_value;
      end

      if (value_0 > value_2) begin
        swap_value = value_0;
        value_0    = value_2;
        value_2    = swap_value;
      end

      if (value_1 > value_3) begin
        swap_value = value_1;
        value_1    = value_3;
        value_3    = swap_value;
      end

      if (value_1 > value_2) begin
        swap_value = value_1;
        value_1    = value_2;
        value_2    = swap_value;
      end
        


      // TODO: Find and return the average of value_1 + value_2 
      // Return this value in the variable 'find_median_channel'
      median_sum = value_1 + value_2;
      find_median_channel = (median_sum + 1) / 2;


    end
  endfunction

endpackage