# Design Guide

This is a design guide for the NU Silicon Digital Design team. None of the conventions or principles listed below are absolute, but they are very strong recommendations.

---

## Naming Conventions

In general names should be very concise, but still descriptive enough so anyone can understand what that thing represents


### 1. Registered values should have a `_d` and `_q` signal

If you need to register the `_q` signal again, use `_2q`, `_3q`, etc

This is imporant is because `always_ff` blocks should be very simple to understand

**Example:**

```systemverilog
always_comb begin
    sum_d = num_a + num_b + num_c;
end

always_ff @(posedge clk) begin
    sum_q  <= sum_d;
    sum_2q <= sum_q;
end
```

---

### 2. All input and output logic types should have `_i` for input and `_o` for output

Applies to all port signals with the exception of `clk` and `reset` signals

**Example:**

```systemverilog
input  logic clk,
input  logic start_i,
output logic done_o
```

---

### 3. All logic should be in `snake_case`

---

### 4. All parameters should be in `SCREAMING_SNAKE_CASE`

---

### 5. All parameters for the width of a logic type should end in `_W`

**Example:**

```systemverilog
localparam int DATA_W = 8;
```

---

### 6. All packages should end in `_pkg` and all interfaces should end in `_if`

**Example:**

```systemverilog
package my_example_pkg;

interface my_example_if();
```

---

## Format Conventions

### 1. Only declare one variable per line except for paired register variables

Paired register variables, such as `_q` and `_d`, may be declared on the same line. Max one pair per line.

**Example:**

```systemverilog
logic signal_one;
logic signal_two;

logic [COUNT_W-1 : 0] counter_d, counter_q;
```

---

### 2. Equal signs in the same part of a block should be lined up within reason

**Example:**

```systemverilog
always_comb begin
    case (state)
        STATE_1: begin
            num_4 = num_2 + num_3;

            if (num_2 == 3) begin
                super_long_num     = num_3 - num_1;
                super_long_neg_num = num_3 - num_1;
            end
        end

        STATE_2: begin
            num_5 = num_1 + num_2;
        end
    endcase
end
```

---

### 3. The types, widths, and names of signal declarations should be lined up when possible

**Example:**

```systemverilog
logic [LONG_NAME_W : 0] really_long_name;
logic [SHORT_W : 0]     short_name;
```

---

### 4. Group and align similar signals/ports, within reason

**Example:**

```systemverilog
input  logic clk,
input  logic signal_1_i,
input  logic signal_2_i,
input  logic signal_3_i,

output logic out_1_o,
output logic out_2_o, 
output logic out_3_o,
```

---

### 4. All variable and parameter declarations should line up when possible

---

### 5. Use the port name declaration format when creating module instances

**Example:**

```systemverilog
my_module #(
    .DATA_W      (DATA_W),
    .COUNTER_LEN (COUNTER_LEN)
) my_module_inst (
    .clk    (clk),
    .rst    (rst),
    .data_i (data_i),
    .data_o (data_o)
);
```

---

## RTL Design Principles

### 1. All sequential logic should change on the positive edge of the clock

---

### 2. All resets should be positive synchronous resets

**Example:**

```systemverilog
always_ff @(posedge clk) begin
    if (rst) begin
        data_valid_q <= '0;
    end else begin
        data_valid_q <= data_valid_d;
        data_q       <= data_d;
    end
end
```

---
### 3. Try to use the `data_pipeline` and `data_shift` modules when possible
--- 
### 4. Try to use the `data_pipeline` and `data_shift` modules when possible

These will be provided, but they make trying to optimize for a clock frequency easier.

---

### 5. Split logic into separate `always_comb` and `always_ff` blocks

Very little should be written in an `always_ff` block besides assigning clocked values.

---

### 6. All parameters outside of port declarations should use `localparam`

---

### 7. Unless it is necessary, define `localparam` values and types inside of packages

---

### 8. Importing packages should always be done below the module declaration name

---

### 9. No magic numbers

Your RTL should not have a bunch of unexplained numbers scattered throughout.

Declare parameters when possible. However, if you are doing something as trivial as adding `1`, you do not need to create a parameter.

**Example: Bad**

```systemverilog
if (count_q == 96) begin
    // What is 96? I don't want to have to figure it out.
    // Do whatever
end
```

**Example: Good**

```systemverilog
localparam int MAX_CYCLES = 96;

if (count_q == MAX_CYCLES) begin
    // Do whatever
end
```

--- 

## Comments

A program with excessive comments isn't great, but a program with no comments sucks.

### 1. Comments are not for you, they are for me
Comments should be concise.

You want a person with little to no background of your project to be able to understand the purpose of your code on their first or second read.

Please try to avoid commenting on things that are trivial, but I'd rather have too many comments than not enough.

---


### 2. Comments within the same block should generally be aligned

**Example:**

```systemverilog
always_ff @(posedge clk) begin
    if (rst) begin
        data_valid_q <= '0;             // This is a reset
    end else begin
        data_valid_q <= data_valid_d;   // This is an aligned comment
        data_q       <= data_d;         // The first comment was trivial
    end
end
```

---

### 3. Place comments to BRIEFLY describe each ports purpose

Usually ignore standard ports like `clk` and `rst`. 

Give information that someone else might not pick up on right away so know each ports purpose.

**Example:**

```systemverilog
input  logic clk,   
input  logic rst,        
input  logic valid_i,       // '1' = data_i is valid
input  logic data_i,        // '0' means black, '1' means white
input  logic last_i,        // When '1' we've seen our entire stream

output logic valid_o,       // Shows if out_cnt_o i valid
output logic out_cnt_o,     // running count of white inputs we've seen so far
output logic out_3_o,       // '1' if out_cnt_o is prime
```






