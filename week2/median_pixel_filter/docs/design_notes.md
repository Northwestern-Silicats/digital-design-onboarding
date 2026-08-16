# Median Filter Design Notes

## Architecture

The design is a streaming 2x2 median filter. It accepts pixels in row-major order and keeps enough state to build the current 2x2 window when each valid input pixel arrives.

The current input pixel is the bottom-right pixel of the window. The bottom-left pixel is the previous valid pixel from the same row. The top-right pixel comes from the line buffer at the current column. The top-left pixel is the previous value read from the line buffer.

```text
top_left      top_right
bottom_left   current pixel
```

## State

- `col_count_q` tracks the current input column.
- `row_count_q` tracks the current input row.
- `line_buffer_q[col]` stores the most recent pixel from the previous row for that column.
- `current_row_prev_pixel_q` stores the pixel immediately to the left of the current pixel.
- `previous_row_prev_pixel_q` stores the previous row pixel from the previous column.

## Valid Timing

`pixel_valid_o` is asserted only when a full 2x2 window exists. That means the input pixel is valid, the row is not 0, and the column is not 0.

`done_o` pulses with the final valid output pixel, which occurs when the current input pixel is at `LAST_ROW` and `LAST_COL`.

## Median Calculation

Each color channel is sorted independently. The output channel is the rounded-up average of the two middle sorted values.

For example, `20, 21, 120, 120` produces `(21 + 120 + 1) >> 1 = 71`.
