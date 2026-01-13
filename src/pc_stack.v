// Program Counter with 3-level Stack for Miyamii-4000 Processor
// 12-bit PC supporting 4K address space
// 3-level deep stack for subroutine nesting

module pc_stack (
    input  wire        clk,
    input  wire        rst_n,
    
    // PC operations
    input  wire [11:0] pc_in,          // New PC value (for jumps)
    input  wire        pc_load,        // Load PC with pc_in
    input  wire        pc_inc,         // Increment PC
    output reg  [11:0] pc_out,         // Current PC value
    
    // Stack operations (for subroutine calls)
    input  wire        stack_push,     // Push current PC to stack
    input  wire        stack_pop,      // Pop PC from stack
    output reg         stack_overflow, // Stack overflow indicator
    output reg         stack_underflow // Stack underflow indicator
);

    // 3-level stack
    reg [11:0] stack [0:2];
    reg [1:0]  stack_ptr;  // Stack pointer (0-3, where 3 indicates overflow)
    
    integer i;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 12'b0;
            stack_ptr <= 2'b0;
            stack_overflow <= 1'b0;
            stack_underflow <= 1'b0;
            for (i = 0; i < 3; i = i + 1) begin
                stack[i] <= 12'b0;
            end
        end else begin
            // Clear overflow/underflow flags
            stack_overflow <= 1'b0;
            stack_underflow <= 1'b0;
            
            // Handle stack push (subroutine call)
            if (stack_push) begin
                if (stack_ptr < 2'd3) begin
                    stack[stack_ptr] <= pc_out;
                    stack_ptr <= stack_ptr + 2'd1;
                end else begin
                    stack_overflow <= 1'b1;  // Stack full
                end
            end
            
            // Handle stack pop (return from subroutine)
            if (stack_pop) begin
                if (stack_ptr > 2'd0) begin
                    stack_ptr <= stack_ptr - 2'd1;
                    pc_out <= stack[stack_ptr - 2'd1];
                end else begin
                    stack_underflow <= 1'b1;  // Stack empty
                end
            end
            
            // Handle PC load (jump)
            if (pc_load && !stack_pop) begin
                pc_out <= pc_in;
            end
            
            // Handle PC increment (normal fetch)
            if (pc_inc && !pc_load && !stack_pop) begin
                pc_out <= pc_out + 12'd1;
            end
        end
    end

endmodule
