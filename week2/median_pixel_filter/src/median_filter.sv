import pixel_pkg::*;

module median_filter #(
  parameter int IMAGE_LEN    = 1080,
  parameter int IMAGE_HEIGHT = 720
) (
  input logic clk,
  input logic rst, //synchronous reset high
  input logic start_i, //starting a new frame
  input logic pixel_valid_i, //current input pixel is valid
  input       pixel_t pixel_i, //input pixel data

  output logic done_o, //the whole image is filtered
  output logic pixel_valid_o, //current output pixel is valid
  output       pixel_t pixel_o //output pixel data
);

  //NOTE: Remember, _q means the signal is clocked, _d means the signal is combinational

  // Local parameters
  localparam int X_COUNTER_W = $clog2(IMAGE_LEN);
  localparam int Y_COUNTER_W = $clog2(IMAGE_HEIGHT);
  localparam int SHIFT_REG_W = IMAGE_LEN + KERNEL_LEN - 1;


  // FSM States
  localparam logic [1:0] IDLE      = 2'd0;
  localparam logic [1:0] CALCULATE = 2'd1;
  logic [1:0] state_q;
  logic [1:0] state_d;


  // Row/Col Counters
  logic [X_COUNTER_W-1:0] x_counter_d;
  logic [X_COUNTER_W-1:0] x_counter_q;
  logic [Y_COUNTER_W-1:0] y_counter_d;
  logic [Y_COUNTER_W-1:0] y_counter_q;


  // Storage Buffer to hold pixels
  pixel_t                 pixel_shift_reg_d[SHIFT_REG_W];
  pixel_t                 pixel_shift_reg_q[SHIFT_REG_W];
  pixel_t                 kernel           [KERNEL_LEN] [KERNEL_LEN];
  pixel_t                 pixel_d;
  logic                   pixel_valid_d;

  // Control Signals
  logic x_inbounds;
  logic y_inbounds;
  logic kernel_valid;

  logic done_d;

  // Inbounds check: the counters track the position of the incoming pixel,
  // which is the bottom-right corner of the current 2x2 window. The window
  // is fully inside the image once that corner is past the first column
  // (x counter is not 0) and past the first row (y counter is not 0), so
  // the window's top-left corner is never on the last row or last column.
  always_comb begin
    x_inbounds = (x_counter_q != 0);
    y_inbounds = (y_counter_q != 0);
  end

  // Shift process: every valid input pixel shifts the buffer by one spot.
  // The new pixel enters at index 0 and every stored pixel moves up an
  // index, so index 0 holds the newest pixel and the highest index holds
  // the oldest one. When the input pixel is not valid, the buffer holds.
  always_comb begin
    for (int i = 0; i < SHIFT_REG_W; i++) begin
      pixel_shift_reg_d[i] = pixel_shift_reg_q[i];
    end

    if (pixel_valid_i) begin
      pixel_shift_reg_d[0] = pixel_i;
      for (int i = 1; i < SHIFT_REG_W; i++) begin
        pixel_shift_reg_d[i] = pixel_shift_reg_q[i - 1];
      end
    end
  end

  // Compute next State
  // This is the 1st process in the two process FSM
  always_comb begin
    // Default values to avoid latches
    state_d       = state_q;
    x_counter_d   = x_counter_q;
    y_counter_d   = y_counter_q;
    kernel_valid  = 1'b0;
    pixel_valid_d = 1'b0;
    done_d        = 1'b0;

    case (state_q)
      IDLE: begin
        // Counters wait at the first pixel position until a frame starts
        x_counter_d = '0;
        y_counter_d = '0;

        if (start_i) begin
          state_d = CALCULATE;
        end
      end

      CALCULATE: begin
        if (pixel_valid_i) begin
          // The kernel is computed from the buffer and the incoming pixel
          // every cycle; it only counts as an output when it is inbounds
          kernel_valid  = x_inbounds && y_inbounds;
          pixel_valid_d = kernel_valid;

          // Advance to the next pixel position in row-major order
          x_counter_d = x_counter_q + 1;

          if (x_counter_q == (IMAGE_LEN - 1)) begin
            x_counter_d = '0;
            y_counter_d = y_counter_q + 1;

            // The last pixel of the frame finishes the image
            if (y_counter_q == (IMAGE_HEIGHT - 1)) begin
              y_counter_d = '0;
              state_d     = IDLE;
              done_d      = 1'b1;
            end
          end
        end
      end

      default: begin
        state_d = IDLE;
      end
    endcase
  end

  // This masks the kernel to make things easier to read
  always_comb begin
    kernel[0][0] = pixel_shift_reg_q[SHIFT_REG_W-1];
    kernel[0][1] = pixel_shift_reg_q[SHIFT_REG_W-2];
    kernel[1][0] = pixel_shift_reg_q[0];
    kernel[1][1] = pixel_i;
  end

  // Instance of the 'median_kernel_calc' module
  // The entire kernel is passed in as the input; the result is always
  // computed into pixel_d and is registered onto pixel_o in the clocked
  // block, where pixel_valid_o marks the cycles it is a real output
  median_kernel_calc kernel_calc_inst (
    .kernel_00_i (kernel[0][0]),
    .kernel_01_i (kernel[0][1]),
    .kernel_10_i (kernel[1][0]),
    .kernel_11_i (kernel[1][1]),
    .pixel_o     (pixel_d)
  );

  // Synchronous clocked block to update our registers
  // Synchronous, active high reset
  always_ff @(posedge clk) begin
    if (rst) begin
      state_q           <= IDLE;
      x_counter_q       <= '0;
      y_counter_q       <= '0;
      pixel_o           <= '0;
      pixel_valid_o     <= 1'b0;
      done_o            <= 1'b0;
      for (int i = 0; i < SHIFT_REG_W; i++) begin
        pixel_shift_reg_q[i] <= '0;
      end
    end else begin
      state_q           <= state_d;
      x_counter_q       <= x_counter_d;
      y_counter_q       <= y_counter_d;
      pixel_o           <= pixel_d;
      pixel_valid_o     <= pixel_valid_d;
      done_o            <= done_d;
      for (int i = 0; i < SHIFT_REG_W; i++) begin
        pixel_shift_reg_q[i] <= pixel_shift_reg_d[i];
      end
    end
  end

endmodule
