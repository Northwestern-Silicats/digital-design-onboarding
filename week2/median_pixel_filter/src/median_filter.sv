import pixel_pkg::*;

module median_filter #(
  parameter int IMAGE_LEN    = 1080,
  parameter int IMAGE_HEIGHT = 720
) (
  input  logic   clk,
  input  logic   rst,             // synchronous reset high
  input  logic   start_i,         // starting a new frame
  input  logic   pixel_valid_i,   // incoming pixel is valid
  input  pixel_t pixel_i,

  output logic   done_o,          // filtered the whole image
  output logic   pixel_valid_o,   // output pixel is valid
  output pixel_t pixel_o          // output pixel
);

  localparam int COL_COUNT_W = (IMAGE_LEN <= 1) ? 1 : $clog2(IMAGE_LEN);
  localparam int ROW_COUNT_W = (IMAGE_HEIGHT <= 1) ? 1 : $clog2(IMAGE_HEIGHT);
  localparam int LAST_COL    = IMAGE_LEN - 1;
  localparam int LAST_ROW    = IMAGE_HEIGHT - 1;

  logic [COL_COUNT_W-1:0] col_count_d, col_count_q;
  logic [ROW_COUNT_W-1:0] row_count_d, row_count_q;

  pixel_t line_buffer_q [IMAGE_LEN];
  pixel_t current_row_prev_pixel_q;
  pixel_t previous_row_prev_pixel_q;

  pixel_t top_left_pixel;
  pixel_t top_right_pixel;
  pixel_t bottom_left_pixel;
  pixel_t bottom_right_pixel;

  pixel_t pixel_d, pixel_q;
  logic   pixel_valid_d, pixel_valid_q;
  logic   done_d, done_q;
  logic   frame_done_d, frame_done_q;
  logic   input_fire;
  logic   window_valid;
  logic   final_window;

  assign pixel_o       = pixel_q;
  assign pixel_valid_o = pixel_valid_q;
  assign done_o        = done_q;

  assign input_fire         = pixel_valid_i && !frame_done_q;
  assign bottom_right_pixel = pixel_i;
  assign bottom_left_pixel  = current_row_prev_pixel_q;
  assign top_right_pixel    = line_buffer_q[col_count_q];
  assign top_left_pixel     = previous_row_prev_pixel_q;

  assign window_valid = input_fire &&
                        (row_count_q != '0) &&
                        (col_count_q != '0);

  assign final_window = window_valid &&
                        (row_count_q == LAST_ROW) &&
                        (col_count_q == LAST_COL);

  function automatic logic [PIXEL_W-1:0] median_channel(
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

    median_sum    = {1'b0, value_1} + {1'b0, value_2} + {{PIXEL_W{1'b0}}, 1'b1};
    median_channel = median_sum[PIXEL_W:1];
  end
  endfunction

  always_comb begin
    col_count_d   = col_count_q;
    row_count_d   = row_count_q;
    pixel_d       = '0;
    pixel_valid_d = 1'b0;
    done_d        = 1'b0;
    frame_done_d  = frame_done_q;

    if (start_i) begin
      col_count_d  = '0;
      row_count_d  = '0;
      frame_done_d = 1'b0;
    end else if (input_fire) begin
      if (col_count_q == LAST_COL) begin
        col_count_d = '0;

        if (row_count_q == LAST_ROW) begin
          row_count_d  = row_count_q;
          frame_done_d = 1'b1;
        end else begin
          row_count_d = row_count_q + 1'b1;
        end
      end else begin
        col_count_d = col_count_q + 1'b1;
      end
    end

    if (window_valid) begin
      pixel_d.red = median_channel(
        top_left_pixel.red,
        top_right_pixel.red,
        bottom_left_pixel.red,
        bottom_right_pixel.red
      );

      pixel_d.green = median_channel(
        top_left_pixel.green,
        top_right_pixel.green,
        bottom_left_pixel.green,
        bottom_right_pixel.green
      );

      pixel_d.blue = median_channel(
        top_left_pixel.blue,
        top_right_pixel.blue,
        bottom_left_pixel.blue,
        bottom_right_pixel.blue
      );

      pixel_valid_d = 1'b1;
      done_d        = final_window;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      col_count_q               <= '0;
      row_count_q               <= '0;
      current_row_prev_pixel_q  <= '0;
      previous_row_prev_pixel_q <= '0;
      pixel_q                   <= '0;
      pixel_valid_q             <= 1'b0;
      done_q                    <= 1'b0;
      frame_done_q              <= 1'b0;
    end else begin
      col_count_q   <= col_count_d;
      row_count_q   <= row_count_d;
      pixel_q       <= pixel_d;
      pixel_valid_q <= pixel_valid_d;
      done_q        <= done_d;
      frame_done_q  <= frame_done_d;

      if (start_i) begin
        current_row_prev_pixel_q  <= '0;
        previous_row_prev_pixel_q <= '0;
      end else if (input_fire) begin
        line_buffer_q[col_count_q] <= pixel_i;

        current_row_prev_pixel_q  <= pixel_i;
        previous_row_prev_pixel_q <= line_buffer_q[col_count_q];
      end
    end
  end

endmodule
