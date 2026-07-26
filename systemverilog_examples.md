# SystemVerilog Examples

### Assign statement
This is an example of an assign statement. Assign statements describe combinational logic, but are used OUTSIDE of an always_comb block. They should mainly be used for short assignments.

```systemverilog
logic a_and_b;
assign a_and_b = a & b;
```

### Module Example

This is an example of how to create a very basic module.

```systemverilog
module example_module
    import package_name_pkg::*;
#(
    parameter PARAM_ONE = 1,
    parameter PARAM_TWO = 2
)(
    // Port Format: input/output TYPE WIDTH NAME
    input logic                   clk,
    input logic [PARAM_TWO-1:0]   input_i,

    output logic                  valid_o,
    output logic [PARAM_ONE-1:0]  data_o
);

// Declare signals and do logic here
endmodule : example_module
```

### Outline of a Combinational Block

```systemverilog
always_comb begin  // The trigger list is automatically inferred
    z = a + b;
    f = a - b;
    q = ~a;
end
```

### Clocked Block with a Synchronous Reset

These blocks are used to update registered values. Keep combinational next-state logic in a separate always_comb block.

```systemverilog

always_ff @(posedge clk) begin
    if (reset == 1'b1) begin
        clocked_q <= '0;        // Reset registered signals here
    end else begin
        clocked_q <= clocked_d; // Update registered signals here
    end
end

```

### Clocked Block with an Asynchronous Reset
The only real change is adding the reset signal to the always block's trigger list. You should probably avoid async resets unless you have a good reason to use them. They have the potential to cause metastability issues depending on when the reset happens relative to the clock edge.

```systemverilog
always_ff @(posedge clk, posedge reset) begin
    if (reset == 1'b1) begin
        clocked_q <= '0;        // Reset registered signals here
    end else begin
        clocked_q <= clocked_d; // Update registered signals here
    end
end
```

### Case Statement
For combinational logic, cases are usually placed in an always_comb block. When the logic is synthesized, case statements are typically implemented as selection or decoder logic. The default item runs when the expression doesn't match any of the other case items and helps define behavior for unexpected values. A single statement (case2) doesn't require a begin/end.

```systemverilog
always_comb begin
    case (CONDITION)
        case1 : begin
            // case logic
        end

        case2 : d = sub_condition ? 2'b01 : 2'b10;

        case3 : begin
            // case logic
        end

        default  : begin
            // default logic
        end
    endcase
end
```

### If Statements

```systemverilog
always_comb begin
    if(condition) begin
        // logic
    end else if(condtion_2) begin
        // logic
    end else begin
        // logic
    end
end
```

### Inline Conditionals
Use these when you have a very simple condition that you want to check. Their benefit is that they are one line of code, which is easier to read. They can be used in always_comb blocks or assign statements.

```systemverilog
// (CONDITION) ? true_assignment : false_assignment

// If (a & b) is 1, assign 3 to out; otherwise, assign 2.
assign out = (a & b) ? 2'd3 : 2'd2;

```
