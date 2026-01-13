// 4-bit ALU for Miyamii-4000 Processor
// Supports arithmetic, logic, and rotate operations

module alu (
    input  wire [3:0] a,           // Operand A (accumulator)
    input  wire [3:0] b,           // Operand B (register or memory)
    input  wire       carry_in,    // Carry input
    input  wire [4:0] op,          // ALU operation
    output reg  [3:0] result,      // Result output
    output reg        carry_out    // Carry output
);

    // ALU Operation Codes
    localparam ALU_ADD  = 5'b00000;  // Add
    localparam ALU_SUB  = 5'b00001;  // Subtract
    localparam ALU_INC  = 5'b00010;  // Increment
    localparam ALU_DEC  = 5'b00011;  // Decrement
    localparam ALU_AND  = 5'b00100;  // Logical AND
    localparam ALU_OR   = 5'b00101;  // Logical OR
    localparam ALU_XOR  = 5'b00110;  // Logical XOR
    localparam ALU_CMA  = 5'b00111;  // Complement A
    localparam ALU_RAL  = 5'b01000;  // Rotate left through carry
    localparam ALU_RAR  = 5'b01001;  // Rotate right through carry
    localparam ALU_TCC  = 5'b01010;  // Transfer carry to accumulator
    localparam ALU_TCS  = 5'b01011;  // Transfer carry subtract (9 + carry)
    localparam ALU_DAA  = 5'b01100;  // Decimal adjust accumulator
    localparam ALU_KBP  = 5'b01101;  // Keyboard process
    localparam ALU_PASS = 5'b01110;  // Pass through A
    localparam ALU_CLR  = 5'b01111;  // Clear
    
    reg [4:0] temp_result;
    
    always @(*) begin
        temp_result = 5'b0;
        carry_out = 1'b0;
        result = 4'b0;
        
        case (op)
            ALU_ADD: begin
                temp_result = {1'b0, a} + {1'b0, b} + {4'b0, carry_in};
                result = temp_result[3:0];
                carry_out = temp_result[4];
            end
            
            ALU_SUB: begin
                temp_result = {1'b0, a} + {1'b0, ~b} + 5'b00001;  // A + ~B + 1
                result = temp_result[3:0];
                carry_out = temp_result[4];
            end
            
            ALU_INC: begin
                temp_result = {1'b0, a} + 5'b00001;
                result = temp_result[3:0];
                carry_out = temp_result[4];
            end
            
            ALU_DEC: begin
                temp_result = {1'b0, a} + 5'b01111;  // A + (-1)
                result = temp_result[3:0];
                carry_out = temp_result[4];
            end
            
            ALU_AND: begin
                result = a & b;
                carry_out = carry_in;
            end
            
            ALU_OR: begin
                result = a | b;
                carry_out = carry_in;
            end
            
            ALU_XOR: begin
                result = a ^ b;
                carry_out = carry_in;
            end
            
            ALU_CMA: begin
                result = ~a;
                carry_out = carry_in;
            end
            
            ALU_RAL: begin
                // Rotate left through carry: {carry, acc} << 1
                result = {a[2:0], carry_in};
                carry_out = a[3];
            end
            
            ALU_RAR: begin
                // Rotate right through carry: {carry, acc} >> 1
                result = {carry_in, a[3:1]};
                carry_out = a[0];
            end
            
            ALU_TCC: begin
                // Transfer carry to accumulator
                result = {3'b0, carry_in};
                carry_out = 1'b0;
            end
            
            ALU_TCS: begin
                // Transfer carry subtract: 9 + carry
                result = 4'd9 + {3'b0, carry_in};
                carry_out = 1'b0;
            end
            
            ALU_DAA: begin
                // Decimal Adjust Accumulator for BCD
                if (a > 4'd9 || carry_in) begin
                    temp_result = {1'b0, a} + 5'd6;
                    result = temp_result[3:0];
                    carry_out = temp_result[4] | carry_in;
                end else begin
                    result = a;
                    carry_out = carry_in;
                end
            end
            
            ALU_KBP: begin
                // Keyboard Process - convert bit position to number
                case (a)
                    4'b0001: result = 4'd1;
                    4'b0010: result = 4'd2;
                    4'b0011: result = 4'd3;
                    4'b0100: result = 4'd4;
                    4'b0101: result = 4'd5;
                    4'b0110: result = 4'd6;
                    4'b0111: result = 4'd7;
                    4'b1000: result = 4'd8;
                    4'b1001: result = 4'd9;
                    4'b1010: result = 4'd10;
                    4'b1011: result = 4'd11;
                    4'b1100: result = 4'd12;
                    4'b1101: result = 4'd13;
                    4'b1110: result = 4'd14;
                    4'b1111: result = 4'd15;
                    default: result = 4'd0;
                endcase
                carry_out = carry_in;
            end
            
            ALU_PASS: begin
                result = a;
                carry_out = carry_in;
            end
            
            ALU_CLR: begin
                result = 4'b0;
                carry_out = carry_in;
            end
            
            default: begin
                result = 4'b0;
                carry_out = 1'b0;
            end
        endcase
    end

endmodule
