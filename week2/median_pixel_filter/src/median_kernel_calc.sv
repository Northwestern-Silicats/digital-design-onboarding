import pixel_pkg::*;

module median_kernel_calc (
    input  pixel_t kernel_00_i,
    input  pixel_t kernel_01_i,
    input  pixel_t kernel_10_i,
    input  pixel_t kernel_11_i,
    output pixel_t pixel_o
);

  // TODO: Write a combinational block that calls the find_median_channel function on each color
  // Pass in all kernel values => [0][0], [0][1], [1][0], [1][1]
  // Re-combine the three function calls into one output pixel (pixel_o)
  always_comb begin
    pixel_o.red = pixel_pkg::find_median_channel(kernel_00_i.red, kernel_01_i.red, kernel_10_i.red, kernel_11_i.red);
    pixel_o.green = pixel_pkg::find_median_channel(kernel_00_i.green, kernel_01_i.green, kernel_10_i.green, kernel_11_i.green);
    pixel_o.blue = pixel_pkg::find_median_channel(kernel_00_i.blue, kernel_01_i.blue, kernel_10_i.blue, kernel_11_i.blue);
end

endmodule
