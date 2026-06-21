# Session 1 — HDLBits Exercises (SystemVerilog Edition)

These exercises are based on HDLBits problems, but rewritten in SystemVerilog. We use `logic`, `always_comb`, and `always_ff` so the homework matches the coding style used in lecture and in the 2x2 kernel project.

---

## Live Coding (do together, ~30 min)

### 1. `sv_module` — Basic module + submodule instantiation

You're given a submodule:

```systemverilog
module mod_a (
  input  logic in1,
  input  logic in2,
  output logic out
);
```

Instantiate `mod_a` inside `top_module`, wiring `a` and `b` to its inputs and `out` to its output. Connect by name (`.port(signal)` style).

```systemverilog
module top_module (
  input  logic a,
  input  logic b,
  output logic out
);

  // TODO: instantiate mod_a here

endmodule
```

---

### 2. `sv_always_if` — Combinational logic with `always_comb`

Two independent combinational behaviors in one module:
- If `cpu_overheated` is high, assert `shut_off_computer`.
- If `arrived` is low and `gas_tank_empty` is low, assert `keep_driving`.

**Rule: in `always_comb`, always assign safe defaults first, then override.**

```systemverilog
module top_module (
  input  logic cpu_overheated,
  output logic shut_off_computer,
  input  logic arrived,
  input  logic gas_tank_empty,
  output logic keep_driving
);

  always_comb begin
    shut_off_computer = 1'b0;
    keep_driving      = 1'b0;

    // TODO: override defaults when conditions are true
  end

endmodule
```

---

## Homework

### 3. `sv_module_pos` — Instantiate by position

Same `mod_a` shape, but now it has 2 outputs and 4 inputs:

```systemverilog
module mod_a (
  output logic out1,
  output logic out2,
  input  logic in1,
  input  logic in2,
  input  logic in3,
  input  logic in4
);
```

Connect it to `top_module`'s ports **by position** (ports connected left-to-right in declaration order).

```systemverilog
module top_module (
  input  logic a, b, c, d,
  output logic out1, out2
);

  // TODO: instantiate mod_a, connect by position

endmodule
```

---

### 4. `sv_module_name` — Instantiate by name

Same `mod_a` as above. This time connect **by name** (`.in1(a)` style) instead of by position.

```systemverilog
module top_module (
  input  logic a, b, c, d,
  output logic out1, out2
);

  // TODO: instantiate mod_a, connect by name

endmodule
```

---

### 5. `sv_module_shift` — Build a shift register from a sub-module

You're given a single D flip-flop module:

```systemverilog
module my_dff (
  input  logic clk,
  input  logic d,
  output logic q
);
```

Instantiate three of them and chain them together to build a length-3 shift register.

```systemverilog
module top_module (
  input  logic clk,
  input  logic d,
  output logic q
);

  logic q1;
  logic q2;

  // TODO:
  // First DFF:  d  -> q1
  // Second DFF: q1 -> q2
  // Third DFF:  q2 -> q

endmodule
```

---

### 6. `sv_dff` — Single D flip-flop

Build one D flip-flop, triggered on the positive edge of `clk`.

```systemverilog
module top_module (
  input  logic clk,
  input  logic d,
  output logic q
);

  always_ff @(posedge clk) begin
    // TODO: copy d to q
  end

endmodule
```

---

### 7. `sv_dff8` — 8-bit-wide D flip-flop

Same idea as above, but `d` and `q` are 8-bit vectors. One `always_ff` block can register all 8 bits at once.

```systemverilog
module top_module (
  input  logic       clk,
  input  logic [7:0] d,
  output logic [7:0] q
);

  always_ff @(posedge clk) begin
    // TODO
  end

endmodule
```

---

### 8. `sv_always_case` — 6-to-1 mux with `case`

Select one of six 4-bit data inputs based on a 3-bit `sel`. Assign a safe default before the `case` block, and include a `default` branch.

```systemverilog
module top_module (
  input  logic [2:0] sel,
  input  logic [3:0] data0, data1, data2, data3, data4, data5,
  output logic [3:0] out
);

  always_comb begin
    out = 4'b0000;

    case (sel)
      // TODO: 3'd0: out = data0; etc. through 3'd5
      default: out = 4'b0000;
    endcase
  end

endmodule
```

---

### 9. `sv_always_casez` — Priority encoder with `casez`

Given an 8-bit input, output the position of the **first** (lowest index) `1` bit. Use `casez` with `z` as don't-care wildcards. Cases are checked top-to-bottom, so order matters.

Patterns to match:
```
8'bzzzzzzz1 -> pos = 0   (bit 0 is set)
8'bzzzzzz10 -> pos = 1   (bit 1 set, bit 0 clear)
...
8'b10000000 -> pos = 7
```

```systemverilog
module top_module (
  input  logic [7:0] in,
  output logic [2:0] pos
);

  always_comb begin
    pos = 3'd0;

    casez (in)
      // TODO: fill in patterns using z wildcards
      default: pos = 3'd0;
    endcase
  end

endmodule
```

---

### 10. `sv_always_nolatches` — Avoiding accidental latches

Decode the last 16-bit PS/2 scancode into one of four arrow-key outputs. Arrow key scancodes:

```
16'he06b -> left
16'he072 -> down
16'he074 -> right
16'he075 -> up
```

**The trap:** if you don't assign every output on every path through the block, synthesis infers a latch to hold the old value. This problem is specifically designed to make you hit that bug and fix it.

**The fix:** default every output to `0` at the top of the block before your `case`.

```systemverilog
module top_module (
  input  logic [15:0] scancode,
  output logic        left,
  output logic        down,
  output logic        right,
  output logic        up
);

  always_comb begin
    left  = 1'b0;
    down  = 1'b0;
    right = 1'b0;
    up    = 1'b0;

    case (scancode)
      // TODO: decode arrow key scancodes
      default: begin
        left  = 1'b0;
        down  = 1'b0;
        right = 1'b0;
        up    = 1'b0;
      end
    endcase
  end

endmodule
```

---

## Mapping to lecture concepts

| # | Problem | Concept |
|---|---------|---------|
| 1, 3, 4 | module, module_pos, module_name | Module instantiation, port connection (position vs. name) |
| 2, 8, 9, 10 | always_if, always_case, always_casez, nolatches | `always_comb`, case/casez, default assignments |
| 5 | module_shift | Hierarchy + chaining sequential sub-modules |
| 6, 7 | dff, dff8 | Sequential logic, `always_ff`, vectors |
| 10 | always_nolatches | Latch inference — ties directly to the latches lecture section |

**The thread through every combinational problem:** assign safe defaults first, then override. That habit carries directly into FSM output logic and the 2x2 kernel control signals.
