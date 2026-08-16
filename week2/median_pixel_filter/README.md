# Median Pixel Filter

## Project Goal

The median pixel filter applies a `2x2` kernel to an image with dimensions `IMAGE_LEN` by `IMAGE_HEIGHT`.

Since a `2x2` kernel covers an even number of pixels, there is no single middle value. For each output pixel, the module sorts the 4 pixel values in the window and averages the two middle values. This is done separately for the red, green, and blue channels. The resulting median channel values are then combined back into one output pixel.

Build the module as a streaming design. Pixels are given starting from the top-left corner of the image, moving left to right. When the stream reaches the right edge of a row, the next incoming pixel is the leftmost pixel of the row below.

<img width="912" height="432" alt="2x2 median filter example" src="https://github.com/user-attachments/assets/b410afd0-ccfd-409a-aec4-1458d916d605" />

## Input Pixel Stream

Pixels arrive in row-major order:

```text
P00, P01, P02, ...
P10, P11, P12, ...
P20, P21, P22, ...
```

An incoming pixel should only be used when `pixel_valid_i` is high.

## 2x2 Window

For the current input pixel, the `2x2` window is:

```text
previous row, previous column    previous row, same column
same row, previous column        current pixel
```

For example, in a `3x3` image:

```text
P00  P01  P02
P10  P11  P12
P20  P21  P22
```

The first output window is:

```text
P00  P01
P10  P11
```

For example, a `3x3` input image produces a `2x2` output image.

## Module Interface

Your module should have the following header:

```systemverilog
module median_filter #(
  parameter int IMAGE_LEN    = 1080,
  parameter int IMAGE_HEIGHT = 720
) (
  input  logic   clk,
  input  logic   rst,             // synchronous reset, active high
  input  logic   start_i,         // starts a new frame
  input  logic   pixel_valid_i,   // incoming pixel is valid
  input  pixel_t pixel_i,

  output logic   done_o,          // full image has been filtered
  output logic   pixel_valid_o,   // output pixel is valid
  output pixel_t pixel_o          // filtered output pixel
);
```

## Expected Behavior

The module should not output a filtered pixel until a full `2x2` window is available.

For a `3x3` image, the first output becomes available when pixel `P11` arrives:

```text
P00  P01
P10  P11
```

`pixel_valid_o` should be high only when `pixel_o` contains a valid filtered output pixel.

`done_o` should assert after the final output pixel of the frame has been produced.

## Deliverables

Complete the following files:

```text
src/pixel_pkg.sv
src/median_filter.sv
tb/median_filter_tb.sv
tb/test_vectors/input_pixels.csv
tb/test_vectors/expected_pixels.csv
```

## Style Requirements

Follow the NU Silicon SystemVerilog style guide.

Important rules:

- Inputs should end in `_i`, and outputs should end in `_o`.
- Registered signals should use `_d` and `_q`.
- Use `snake_case` for signals.
- Use `SCREAMING_SNAKE_CASE` for parameters.
- Use `always_comb` for combinational logic.
- Use `always_ff @(posedge clk)` for sequential logic.
- Resets should be synchronous and active high.
- Avoid magic numbers.
