`timescale 1ns/1ps

import pixel_pkg::*;

module median_filter_tb;

  localparam int IMAGE_LEN      = 4;
  localparam int IMAGE_HEIGHT   = 4;
  localparam int INPUT_COUNT    = IMAGE_LEN * IMAGE_HEIGHT;
  localparam int EXPECTED_COUNT = (IMAGE_LEN - 1) * (IMAGE_HEIGHT - 1);
  localparam int MAX_WAIT_CYCLES = 8;

  logic   clk;
  logic   rst;
  logic   start_i;
  logic   pixel_valid_i;
  pixel_t pixel_i;

  logic   done_o;
  logic   pixel_valid_o;
  pixel_t pixel_o;

  string input_path;
  string expected_path;
  string output_path;
  string header;

  int input_fd;
  int expected_fd;
  int output_fd;
  int scan_count;
  int red_value;
  int green_value;
  int blue_value;
  int expected_red;
  int expected_green;
  int expected_blue;
  int output_count;
  int mismatch_count;
  int done_count;

  median_filter #(
    .IMAGE_LEN    (IMAGE_LEN),
    .IMAGE_HEIGHT (IMAGE_HEIGHT)
  ) dut (
    .clk           (clk),
    .rst           (rst),
    .start_i       (start_i),
    .pixel_valid_i (pixel_valid_i),
    .pixel_i       (pixel_i),
    .done_o        (done_o),
    .pixel_valid_o (pixel_valid_o),
    .pixel_o       (pixel_o)
  );

  always begin
    #5 clk = ~clk;
  end

  task automatic check_output;
  begin
    if (pixel_valid_o === 1'b1) begin
      scan_count = $fscanf(expected_fd, "%d,%d,%d\n", expected_red, expected_green, expected_blue);

      if (scan_count != 3) begin
        $display("FAIL: RTL produced more output pixels than expected.");
        mismatch_count++;
      end else begin
        $fdisplay(output_fd, "%0d,%0d,%0d", pixel_o.red, pixel_o.green, pixel_o.blue);

        if ((pixel_o.red   !== expected_red[7:0])   ||
            (pixel_o.green !== expected_green[7:0]) ||
            (pixel_o.blue  !== expected_blue[7:0])) begin
          $display(
            "FAIL: output %0d expected %0d,%0d,%0d got %0d,%0d,%0d",
            output_count,
            expected_red,
            expected_green,
            expected_blue,
            pixel_o.red,
            pixel_o.green,
            pixel_o.blue
          );
          mismatch_count++;
        end
      end

      output_count++;
    end

    if (done_o === 1'b1) begin
      done_count++;
    end
  end
  endtask

  task automatic drive_idle_cycle;
  begin
    pixel_valid_i = 1'b0;
    pixel_i       = '0;
    @(posedge clk);
    #1;
    check_output();
  end
  endtask

  task automatic drive_pixel(input int red_i, input int green_i, input int blue_i);
  begin
    pixel_valid_i = 1'b1;
    pixel_i.red   = red_i[7:0];
    pixel_i.green = green_i[7:0];
    pixel_i.blue  = blue_i[7:0];
    @(posedge clk);
    #1;
    check_output();
  end
  endtask

  initial begin
    clk             = 1'b0;
    rst             = 1'b1;
    start_i         = 1'b0;
    pixel_valid_i   = 1'b0;
    pixel_i         = '0;
    output_count    = 0;
    mismatch_count  = 0;
    done_count      = 0;

    input_path    = "tb/test_vectors/input_pixels.csv";
    expected_path = "tb/test_vectors/expected_pixels.csv";
    output_path   = "tb/output_pixels.csv";

    scan_count = $value$plusargs("INPUT=%s", input_path);
    scan_count = $value$plusargs("EXPECTED=%s", expected_path);
    scan_count = $value$plusargs("OUTPUT=%s", output_path);

    input_fd = $fopen(input_path, "r");
    if (input_fd == 0) begin
      $display("FAIL: could not open input file: %s", input_path);
      $finish;
    end

    expected_fd = $fopen(expected_path, "r");
    if (expected_fd == 0) begin
      $display("FAIL: could not open expected file: %s", expected_path);
      $finish;
    end

    output_fd = $fopen(output_path, "w");
    if (output_fd == 0) begin
      $display("FAIL: could not open output file: %s", output_path);
      $finish;
    end

    scan_count = $fgets(header, input_fd);
    scan_count = $fgets(header, expected_fd);
    $fdisplay(output_fd, "red,green,blue");

    repeat (2) begin
      drive_idle_cycle();
    end

    rst = 1'b0;

    start_i = 1'b1;
    drive_idle_cycle();
    start_i = 1'b0;

    for (int pixel_idx = 0; pixel_idx < INPUT_COUNT; pixel_idx++) begin
      scan_count = $fscanf(input_fd, "%d,%d,%d\n", red_value, green_value, blue_value);

      if (scan_count != 3) begin
        $display("FAIL: input CSV ended early at pixel %0d.", pixel_idx);
        mismatch_count++;
      end else begin
        drive_pixel(red_value, green_value, blue_value);
      end
    end

    repeat (MAX_WAIT_CYCLES) begin
      drive_idle_cycle();
    end

    if (output_count != EXPECTED_COUNT) begin
      $display("FAIL: expected %0d outputs, got %0d.", EXPECTED_COUNT, output_count);
      mismatch_count++;
    end

    if (done_count != 1) begin
      $display("FAIL: expected done_o to pulse once, got %0d pulses.", done_count);
      mismatch_count++;
    end

    if (mismatch_count == 0) begin
      $display("PASS: median filter output matched expected CSV.");
    end else begin
      $display("FAIL: saw %0d mismatch(es).", mismatch_count);
    end

    $fclose(input_fd);
    $fclose(expected_fd);
    $fclose(output_fd);
    $finish;
  end

endmodule
