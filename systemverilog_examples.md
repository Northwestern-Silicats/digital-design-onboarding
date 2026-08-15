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

### Two Process FSM
Below is a very simple two process FSM for detecting the input sequence '101'. The combinational process determines the next state and output, while the clocked process updates the current state.

```systemverilog
// Each name represents one state in the sequence detector.
typedef enum logic [1:0] {
    IDLE,       // We have not seen any part of "101"
    SEEN_1,     // We have seen "1"
    SEEN_10     // We have seen "10"
} state_t;

state_t state_q;     // The current state, stored in flip-flops
state_t next_state;  // The state to enter on the next clock edge

// Process 1: combinational next-state and output logic
always_comb begin
    // Defaults prevent unintended latches.
    next_state = state_q;
    detected_o = 1'b0;

    case (state_q)
        IDLE : begin
            if (bit_i == 1'b1)
                next_state = SEEN_1;
        end

        SEEN_1 : begin
            if (bit_i == 1'b0)
                next_state = SEEN_10;
            else
                next_state = SEEN_1;  // This 1 may start a new "101"
        end

        SEEN_10 : begin
            if (bit_i == 1'b1) begin
                detected_o = 1'b1;    // The complete sequence "101" was seen
                next_state = SEEN_1;  // The last 1 may start another sequence
            end else begin
                next_state = IDLE;
            end
        end

        default : next_state = IDLE;  // Recover from an unexpected state
    endcase
end

// Process 2: clocked state register
always_ff @(posedge clk) begin
    if (reset == 1'b1)
        state_q <= IDLE;
    else
        state_q <= next_state;
end
```

### Simple Single Port BRAM
This is an example of a very simple single port BRAM that takes one clock cycle to read data or store data. Because it has one port, it performs only one operation per clock cycle.

```systemverilog
// DEPTH words are stored, and each word is DATA_WIDTH bits wide.
logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];

always_ff @(posedge clk) begin
    if (write_enable_i == 1'b1) begin
        // Store write_data_i at address_i on this clock edge.
        memory[address_i] <= write_data_i;
    end else begin
        // Register the selected word. It appears at read_data_o after this edge.
        read_data_o <= memory[address_i];
    end
end
```

### Simple Dual Port BRAM
This is an example of a simple dual port BRAM where a read and a write can happen during the same clock cycle. Avoid reading and writing the same address at the same time because the returned value can depend on the target device.

```systemverilog
// One port writes to memory while the other port reads from memory.
logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];

always_ff @(posedge clk) begin
    if (write_enable_i == 1'b1) begin
        // The write port stores one word on the clock edge.
        memory[write_address_i] <= write_data_i;
    end

    // The read port works independently and returns data one cycle later.
    read_data_o <= memory[read_address_i];
end
```

### Struct
Structs are useful for grouping related signals under one name. A packed struct stores all of its fields together as one vector of bits.

```systemverilog
typedef struct packed {
    logic       valid;  // Indicates whether data should be used
    logic [7:0] data;   // The 8-bit data value
} transaction_t;

transaction_t transaction;

// Access each field with the struct name followed by a period.
assign transaction.valid = valid_i;
assign transaction.data  = data_i;
assign valid_o            = transaction.valid;
assign data_o             = transaction.data;
```

### Local Parameters
Local parameters give names to constants used inside a module. They are fixed at compile time and, unlike regular parameters, cannot be overridden when the module is instantiated.

```systemverilog
parameter int INPUT_WIDTH = 8;                  // May be overridden by the parent module
localparam int OUTPUT_WIDTH = INPUT_WIDTH * 2;  // Cannot be overridden by the parent module

logic [INPUT_WIDTH-1:0]  input_data;
logic [OUTPUT_WIDTH-1:0] output_data;
```

### Packed & Unpacked Arrays
Packed arrays are treated as one continuous vector of bits. Unpacked arrays contain separate elements and are commonly used to describe memories.

```systemverilog
// A packed array: one 8-bit value with bit positions 7 down to 0.
logic [7:0] packed_byte;

// An unpacked array: four separate elements, where each element is 8 bits wide.
logic [7:0] unpacked_bytes [0:3];

assign first_bit  = packed_byte[0];       // Select one bit from the packed array
assign third_byte = unpacked_bytes[2];    // Select one element from the unpacked array
```

### Packages
Packages help keep code readable by storing definitions that are shared by multiple modules. This way, a shared parameter, type, or function only needs to be updated in one place.

```systemverilog
package example_pkg;
    parameter int DATA_WIDTH = 8;

    typedef logic [DATA_WIDTH-1:0] data_t;
endpackage : example_pkg

module package_example
    import example_pkg::*;  // Make the package names visible in this module
(
    input  data_t data_i,
    output data_t data_o
);

assign data_o = data_i;

endmodule : package_example
```

### Instantiating Modules
Here is an example of connecting two hypothetical add1 modules together using named port instantiation.

```systemverilog
logic [7:0] first_result;
logic [7:0] final_result;

// The signal in parentheses connects to the named module port before it.
add1 first_add1 (
    .data_i (data_i),       // Send the original value into the first module
    .data_o (first_result)  // Save the first module's result
);

add1 second_add1 (
    .data_i (first_result), // Send the first result into the second module
    .data_o (final_result)  // The original value has now been incremented twice
);
```

### For Loops
For loops replicate the logic inside them. This combinational example creates the logic needed to invert every bit of a four-bit input.

```systemverilog
always_comb begin
    for (int i = 0; i < 4; i++) begin
        // Synthesis creates one inverter for each value of i.
        inverted_o[i] = data_i[i] ^ 1'b1;
    end
end
```

### Generate Loops
Generate loops create repeated hardware when the design is elaborated. They are useful when each copy is a separate module instance.

```systemverilog
// Four separate 8-bit values will pass through four separate add1 modules.
logic [7:0] data_i [0:3];
logic [7:0] data_o [0:3];

genvar i;
generate
    for (i = 0; i < 4; i++) begin : generate_adders
        // Create four add1 modules, one for each element of the arrays.
        add1 add1_instance (
            .data_i (data_i[i]),
            .data_o (data_o[i])
        );
    end
endgenerate
```

### Functions
Functions give a name to reusable combinational logic. This function returns the larger of two eight-bit values.

```systemverilog
function automatic logic [7:0] larger_value (
    input logic [7:0] a,
    input logic [7:0] b
);
    if (a > b)
        larger_value = a;
    else
        larger_value = b;
endfunction

// Call the function anywhere a normal expression can be used.
assign largest_o = larger_value(first_i, second_i);
```

### AXI Stream Interface
An AXI stream transfers one data word on a rising clock edge when both `tvalid` and `tready` are high. The source controls `tvalid`, `tdata`, and `tlast`, while the destination controls `tready`. If the source asserts `tvalid` while `tready` is low, it must keep the data and control signals unchanged until the transfer happens.

This simplified interface includes the most common AXI stream signals. Modports describe which signals each side of the connection may drive.

```systemverilog
interface axi_stream_if #(
    parameter int DATA_WIDTH = 32
)(
    input logic clk,
    input logic reset
);

logic                  tvalid; // The source is presenting valid data
logic                  tready; // The destination is ready to accept data
logic [DATA_WIDTH-1:0] tdata;  // The data being transferred
logic                  tlast;  // This word is the last one in a packet

modport master (
    input  clk,
    input  reset,
    input  tready,
    output tvalid,
    output tdata,
    output tlast
);

modport slave (
    input  clk,
    input  reset,
    input  tvalid,
    input  tdata,
    input  tlast,
    output tready
);

endinterface : axi_stream_if

// This module adds one to each word while passing the AXI stream handshake
// and packet boundary signal through without adding a register stage.
module axi_stream_add1 (
    axi_stream_if.slave  input_stream,
    axi_stream_if.master output_stream
);

assign input_stream.tready  = output_stream.tready;
assign output_stream.tvalid = input_stream.tvalid;
assign output_stream.tdata  = input_stream.tdata + 1'b1;
assign output_stream.tlast  = input_stream.tlast;

endmodule : axi_stream_add1

// Create two interface instances and connect them to the module.
axi_stream_if #(.DATA_WIDTH(32)) input_stream  (.clk(clk), .reset(reset));
axi_stream_if #(.DATA_WIDTH(32)) output_stream (.clk(clk), .reset(reset));

axi_stream_add1 add1_instance (
    .input_stream  (input_stream),
    .output_stream (output_stream)
);
```
