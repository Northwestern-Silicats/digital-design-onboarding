# Fun Practice Questions

These practice questions are based on public LogiCode problem topics, but the prompts here are rewritten for NU Silicats onboarding. Do not copy/paste LogiCode's full problem statements into this repo.

LogiCode catalog: https://logi-code.com/problems/

## How To Use This File

Do these before or during the median pixel filter project. The goal is not to finish every problem. The goal is to build the exact RTL skills needed for the project: combinational logic, sequential logic, counters, valid timing, buffering, and simple sorting.

Recommended order:

1. Problems 1-4: combinational warmup
2. Problems 5-8: sequential warmup
3. Problems 9-12: median-filter prep

---

## 1. Majority Vote

Inspired by LogiCode: Majority  
Link: https://logi-code.com/problems/

Write a combinational SystemVerilog module that outputs `1` when at least two of three 1-bit inputs are `1`.

Starter interface:

```systemverilog
module majority3 (
  input  logic a_i,
  input  logic b_i,
  input  logic c_i,
  output logic y_o
);

  // TODO

endmodule
```

Skills: boolean logic, `assign`, combinational thinking.

---

## 2. Comparator Operations

Inspired by LogiCode: Comparator Operations  
Link: https://logi-code.com/problems/

Write a combinational module that compares two unsigned 8-bit numbers.

Outputs:

- `greater_o` is high when `a_i > b_i`
- `equal_o` is high when `a_i == b_i`
- `less_o` is high when `a_i < b_i`

Starter interface:

```systemverilog
module comparator8 (
  input  logic [7:0] a_i,
  input  logic [7:0] b_i,
  output logic       greater_o,
  output logic       equal_o,
  output logic       less_o
);

  // TODO

endmodule
```

Skills: unsigned comparison, mutually exclusive outputs.

---

## 3. Counting Ones

Inspired by LogiCode: Counting Ones  
Link: https://logi-code.com/problems/

Given an 8-bit input, output the number of bits that are `1`.

Starter interface:

```systemverilog
module count_ones8 (
  input  logic [7:0] din_i,
  output logic [3:0] count_o
);

  // TODO

endmodule
```

Check yourself:

- Why does `count_o` need 4 bits?
- What is the maximum possible count?

Skills: vectors, addition width, combinational logic.

---

## 4. One-Hot Detector

Inspired by LogiCode: One Hot Encoding Detector  
Link: https://logi-code.com/problems/

Write a module that outputs `1` only when exactly one bit of an 8-bit input is high.

Starter interface:

```systemverilog
module one_hot8 (
  input  logic [7:0] din_i,
  output logic       one_hot_o
);

  // TODO

endmodule
```

Hint: reuse your `count_ones8` idea mentally. A value is one-hot when the count of ones is exactly 1.

Skills: bit vectors, reduction thinking, reusable combinational logic.

---

## 5. Counter With Start

Inspired by LogiCode: Counter  
Link: https://logi-code.com/problems/

Build a counter that starts counting after a one-cycle `start_i` pulse.

Rules:

- Reset clears the count to 0.
- Before `start_i`, the counter holds at 0.
- After `start_i`, the counter increments by 1 every clock.

Starter interface:

```systemverilog
module start_counter #(
  parameter int COUNT_W = 8
) (
  input  logic               clk,
  input  logic               rst,
  input  logic               start_i,
  output logic [COUNT_W-1:0] count_o
);

  // TODO

endmodule
```

Skills: `always_ff`, stored state, synchronous reset.

---

## 6. Edge Detector

Inspired by LogiCode: Edge Detector  
Link: https://logi-code.com/problems/

Output a one-cycle pulse when `din_i` changes from 0 to 1.

Starter interface:

```systemverilog
module rising_edge_detector (
  input  logic clk,
  input  logic rst,
  input  logic din_i,
  output logic pulse_o
);

  // TODO

endmodule
```

Hint: store the previous value of `din_i` in a register.

Skills: previous-cycle state, pulse generation, nonblocking assignments.

---

## 7. Fibonacci Generator

Inspired by LogiCode: Fibonacci Generator  
Link: https://logi-code.com/problems/

Create a sequential module that outputs the Fibonacci sequence: 1, 1, 2, 3, 5, 8...

Rules:

- Reset should return the generator to the beginning.
- On each valid step, output the next Fibonacci number.

Starter interface:

```systemverilog
module fibonacci_gen #(
  parameter int DATA_W = 16
) (
  input  logic              clk,
  input  logic              rst,
  input  logic              step_i,
  output logic [DATA_W-1:0] fib_o
);

  // TODO

endmodule
```

Skills: two-register state, old value vs new value, sequential updates.

---

## 8. Serial To Parallel Converter

Inspired by LogiCode: Serial to Parallel Converter  
Link: https://logi-code.com/problems/

Accept one serial input bit per valid cycle. After 8 valid bits, output the collected byte and pulse `byte_valid_o` for one cycle.

Starter interface:

```systemverilog
module serial_to_parallel8 (
  input  logic       clk,
  input  logic       rst,
  input  logic       bit_valid_i,
  input  logic       bit_i,
  output logic       byte_valid_o,
  output logic [7:0] byte_o
);

  // TODO

endmodule
```

Skills: shift registers, valid signals, counters.

---

## 9. Valid Pipeline

Inspired by LogiCode topics: Skid Buffer / valid-ready buffering  
Link: https://logi-code.com/problems/

Build a one-cycle pipeline stage for data and valid.

Rules:

- `data_o` is `data_i` delayed by one clock.
- `valid_o` is `valid_i` delayed by one clock.
- Reset clears both outputs.

Starter interface:

```systemverilog
module valid_pipeline #(
  parameter int DATA_W = 8
) (
  input  logic              clk,
  input  logic              rst,
  input  logic              valid_i,
  input  logic [DATA_W-1:0] data_i,
  output logic              valid_o,
  output logic [DATA_W-1:0] data_o
);

  // TODO

endmodule
```

Skills: valid/data alignment, pipeline timing.

---

## 10. Last Four Samples

Inspired by LogiCode: Sliding Window Median Filter  
Link: https://logi-code.com/problems/

Store the last four valid samples from a stream.

Important: this is not the same as the image project's spatial 2x2 window. This only teaches shifting recent values through registers.

Starter interface:

```systemverilog
module last_four_samples #(
  parameter int DATA_W = 8
) (
  input  logic              clk,
  input  logic              rst,
  input  logic              valid_i,
  input  logic [DATA_W-1:0] data_i,
  output logic [DATA_W-1:0] newest_o,
  output logic [DATA_W-1:0] prev1_o,
  output logic [DATA_W-1:0] prev2_o,
  output logic [DATA_W-1:0] prev3_o
);

  // TODO

endmodule
```

Skills: shift registers, valid-gated storage.

---

## 11. Median Of Four Bytes

Inspired by LogiCode: Sliding Window Median Filter / Bubble Sort  
Link: https://logi-code.com/problems/

Write a combinational module that takes four unsigned 8-bit values and outputs the median using this project rule:

1. Sort the four values.
2. Take the two middle values.
3. Average them.
4. If the result ends in `.5`, round up.

Starter interface:

```systemverilog
module median4_byte (
  input  logic [7:0] a_i,
  input  logic [7:0] b_i,
  input  logic [7:0] c_i,
  input  logic [7:0] d_i,
  output logic [7:0] median_o
);

  // TODO

endmodule
```

Example:

```text
20, 21, 120, 120 -> 71
```

Skills: compare/swap, functions, avoiding overflow in addition.

---

## 12. 2x2 Window Valid

Inspired by LogiCode: Sliding Window Median Filter  
Link: https://logi-code.com/problems/

Write the valid logic for the median pixel filter's 2x2 image window.

Inputs:

- `pixel_valid_i`
- `row_count_q`
- `col_count_q`

Output:

- `window_valid_o`

Rule:

```systemverilog
window_valid_o = pixel_valid_i && (row_count_q != '0) && (col_count_q != '0);
```

Then answer in one sentence:

Why does the first row produce no outputs?  
Why does the first column produce no outputs?

Skills: valid timing, image streaming, spatial window reasoning.

---

## 13. RGB Median Warmup

Inspired by LogiCode: Sliding Window Median Filter  
Link: https://logi-code.com/problems/

Given four `pixel_t` values, compute the median red, green, and blue channels separately.

Starter interface:

```systemverilog
import pixel_pkg::*;

module median4_pixel (
  input  pixel_t pixel_0_i,
  input  pixel_t pixel_1_i,
  input  pixel_t pixel_2_i,
  input  pixel_t pixel_3_i,
  output pixel_t median_o
);

  // TODO

endmodule
```

Skills: structs, helper functions, repeated channel logic.

---

## 14. Image Row/Column Counter

Inspired by LogiCode: Counter  
Link: https://logi-code.com/problems/

Build the row and column counter logic needed for a streamed image.

Rules:

- Pixels arrive left to right.
- When the column reaches `IMAGE_LEN - 1`, the next valid pixel wraps column back to 0.
- When the column wraps, increment the row.
- Counters only advance when `pixel_valid_i` is 1.

Starter interface:

```systemverilog
module image_position_counter #(
  parameter int IMAGE_LEN    = 4,
  parameter int IMAGE_HEIGHT = 4
) (
  input  logic clk,
  input  logic rst,
  input  logic pixel_valid_i,
  output logic at_first_row_o,
  output logic at_first_col_o,
  output logic at_last_pixel_o
);

  // TODO

endmodule
```

Skills: nested counting, image stream position, edge cases.

---

## 15. Challenge: Tiny Median Pixel Filter

Inspired by LogiCode: Sliding Window Median Filter  
Link: https://logi-code.com/problems/

Before writing the full project, explain the output windows for this 3x3 image:

```text
P00 P01 P02
P10 P11 P12
P20 P21 P22
```

Fill this out:

```text
O00 uses: __ __ / __ __
O01 uses: __ __ / __ __
O10 uses: __ __ / __ __
O11 uses: __ __ / __ __
```

Then explain why a 3x3 input creates a 2x2 output.

Skills: spatial reasoning, window movement, project mental model.
