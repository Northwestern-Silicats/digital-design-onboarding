# System Verilog Examples


### Assign statement
This is an example of an assign statement. Assign statments are combinational logic, but are used OUTSIDE of an always_comb block. It should mainly be used for short assign statments.

```systemverilog
logic a_and_b;
assign a_and_b = a & b;
```

### Basic clocked block with a synchronous reset

You will use these blocks all the time. You should not put any real logic inside these types of blocks, they are just used to change registered values.

```systemverilog
always_ff@(posedge clk) begin
    if(reset == 1'b1) begin
        clocked_q <= '0;        // reset signals here (only be reset to 0)
    end else begin
        clocked_q <= clocked_d; // clock signals here
    end
end

```