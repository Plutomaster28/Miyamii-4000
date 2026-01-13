// Instruction Decoder for Miyamii-4000 Processor
// Decodes 8-bit instructions and generates control signals

module instruction_decoder (
    input  wire [7:0]  instruction,    // Current instruction byte
    input  wire        is_first_byte,  // Is this the first byte of instruction?
    
    // Decoded instruction information
    output reg         is_two_byte,    // Instruction requires second byte
    output reg  [4:0]  alu_op,         // ALU operation code
    output reg  [3:0]  reg_addr,       // Register address
    output reg  [2:0]  reg_pair,       // Register pair address
    output reg  [3:0]  immediate,      // 4-bit immediate data
    output reg  [3:0]  condition,      // Condition code for JCN
    
    // Control signals
    output reg         acc_we,         // Accumulator write enable
    output reg         reg_we,         // Register write enable
    output reg         carry_we,       // Carry flag write enable
    output reg         carry_clr,      // Clear carry
    output reg         carry_set,      // Set carry
    output reg         carry_cmp,      // Complement carry
    output reg         pc_load,        // Load PC (jump)
    output reg         pc_inc,         // Increment PC
    output reg         stack_push,     // Push to stack (call)
    output reg         stack_pop,      // Pop from stack (return)
    output reg         ram_we,         // RAM write enable
    output reg         ram_re,         // RAM read enable
    output reg         rom_port_we,    // ROM port write
    output reg         rom_port_re,    // ROM port read
    output reg  [1:0]  ram_status_sel, // RAM status character select (0-3)
    output reg         use_status,     // Use status character addressing
    output reg         is_nop          // No operation
);

    // Instruction opcodes (upper 4 bits)
    localparam OP_NOP = 4'b0000;
    localparam OP_JCN = 4'b0001;
    localparam OP_FIM_SRC = 4'b0010;
    localparam OP_FIN_JIN = 4'b0011;
    localparam OP_JUN = 4'b0100;
    localparam OP_JMS = 4'b0101;
    localparam OP_INC = 4'b0110;
    localparam OP_ISZ = 4'b0111;
    localparam OP_ADD = 4'b1000;
    localparam OP_SUB = 4'b1001;
    localparam OP_LD  = 4'b1010;
    localparam OP_XCH = 4'b1011;
    localparam OP_BBL = 4'b1100;
    localparam OP_LDM = 4'b1101;
    localparam OP_IO  = 4'b1110;
    localparam OP_ACC = 4'b1111;
    
    // ALU operation codes (imported from alu.v)
    localparam ALU_ADD  = 5'b00000;
    localparam ALU_SUB  = 5'b00001;
    localparam ALU_INC  = 5'b00010;
    localparam ALU_DEC  = 5'b00011;
    localparam ALU_CMA  = 5'b00111;
    localparam ALU_RAL  = 5'b01000;
    localparam ALU_RAR  = 5'b01001;
    localparam ALU_TCC  = 5'b01010;
    localparam ALU_TCS  = 5'b01011;
    localparam ALU_DAA  = 5'b01100;
    localparam ALU_KBP  = 5'b01101;
    localparam ALU_PASS = 5'b01110;
    localparam ALU_CLR  = 5'b01111;
    
    wire [3:0] opcode = instruction[7:4];
    wire [3:0] operand = instruction[3:0];
    
    always @(*) begin
        // Default values
        is_two_byte = 1'b0;
        alu_op = ALU_PASS;
        reg_addr = 4'b0;
        reg_pair = 3'b0;
        immediate = 4'b0;
        condition = 4'b0;
        
        acc_we = 1'b0;
        reg_we = 1'b0;
        carry_we = 1'b0;
        carry_clr = 1'b0;
        carry_set = 1'b0;
        carry_cmp = 1'b0;
        pc_load = 1'b0;
        pc_inc = 1'b0;
        stack_push = 1'b0;
        stack_pop = 1'b0;
        ram_we = 1'b0;
        ram_re = 1'b0;
        rom_port_we = 1'b0;
        rom_port_re = 1'b0;
        ram_status_sel = 2'b0;
        use_status = 1'b0;
        is_nop = 1'b0;
        
        if (is_first_byte) begin
            case (opcode)
                OP_NOP: begin
                    if (operand == 4'b0000) begin
                        is_nop = 1'b1;
                    end
                end
                
                OP_JCN: begin
                    is_two_byte = 1'b1;
                    condition = operand;
                end
                
                OP_FIM_SRC: begin
                    is_two_byte = 1'b1;
                    reg_pair = operand[3:1];
                    // operand[0] = 0: FIM (fetch immediate)
                    // operand[0] = 1: SRC (send register control)
                end
                
                OP_FIN_JIN: begin
                    reg_pair = operand[3:1];
                    // operand[0] = 0: FIN (fetch indirect)
                    // operand[0] = 1: JIN (jump indirect)
                    if (operand[0]) begin
                        pc_load = 1'b1;
                    end
                end
                
                OP_JUN: begin
                    is_two_byte = 1'b1;
                    pc_load = 1'b1;
                end
                
                OP_JMS: begin
                    is_two_byte = 1'b1;
                    stack_push = 1'b1;
                    pc_load = 1'b1;
                end
                
                OP_INC: begin
                    reg_addr = operand;
                    alu_op = ALU_INC;
                    reg_we = 1'b1;
                    carry_we = 1'b1;
                end
                
                OP_ISZ: begin
                    is_two_byte = 1'b1;
                    reg_addr = operand;
                    alu_op = ALU_INC;
                    reg_we = 1'b1;
                end
                
                OP_ADD: begin
                    reg_addr = operand;
                    alu_op = ALU_ADD;
                    acc_we = 1'b1;
                    carry_we = 1'b1;
                end
                
                OP_SUB: begin
                    reg_addr = operand;
                    alu_op = ALU_SUB;
                    acc_we = 1'b1;
                    carry_we = 1'b1;
                end
                
                OP_LD: begin
                    reg_addr = operand;
                    alu_op = ALU_PASS;
                    acc_we = 1'b1;
                end
                
                OP_XCH: begin
                    reg_addr = operand;
                    acc_we = 1'b1;
                    reg_we = 1'b1;
                end
                
                OP_BBL: begin
                    immediate = operand;
                    stack_pop = 1'b1;
                    acc_we = 1'b1;
                end
                
                OP_LDM: begin
                    immediate = operand;
                    alu_op = ALU_PASS;
                    acc_we = 1'b1;
                end
                
                OP_IO: begin
                    // I/O and RAM instructions
                    case (operand)
                        4'b0000: begin  // WRM - Write RAM main
                            ram_we = 1'b1;
                        end
                        4'b0001: begin  // WMP - Write RAM port
                            ram_we = 1'b1;
                        end
                        4'b0010: begin  // WRR - Write ROM port
                            rom_port_we = 1'b1;
                        end
                        4'b0011: begin  // WPM - Write program RAM (4289 only)
                            ram_we = 1'b1;
                        end
                        4'b0100, 4'b0101, 4'b0110, 4'b0111: begin  // WR0-WR3
                            ram_we = 1'b1;
                            use_status = 1'b1;
                            ram_status_sel = operand[1:0];
                        end
                        4'b1000: begin  // SBM - Subtract RAM
                            ram_re = 1'b1;
                            alu_op = ALU_SUB;
                            acc_we = 1'b1;
                            carry_we = 1'b1;
                        end
                        4'b1001: begin  // RDM - Read RAM main
                            ram_re = 1'b1;
                            acc_we = 1'b1;
                        end
                        4'b1010: begin  // RDR - Read ROM port
                            rom_port_re = 1'b1;
                            acc_we = 1'b1;
                        end
                        4'b1011: begin  // ADM - Add RAM
                            ram_re = 1'b1;
                            alu_op = ALU_ADD;
                            acc_we = 1'b1;
                            carry_we = 1'b1;
                        end
                        4'b1100, 4'b1101, 4'b1110, 4'b1111: begin  // RD0-RD3
                            ram_re = 1'b1;
                            use_status = 1'b1;
                            ram_status_sel = operand[1:0];
                            acc_we = 1'b1;
                        end
                    endcase
                end
                
                OP_ACC: begin
                    // Accumulator instructions
                    case (operand)
                        4'b0000: begin  // CLB - Clear both
                            alu_op = ALU_CLR;
                            acc_we = 1'b1;
                            carry_clr = 1'b1;
                        end
                        4'b0001: begin  // CLC - Clear carry
                            carry_clr = 1'b1;
                        end
                        4'b0010: begin  // IAC - Increment accumulator
                            alu_op = ALU_INC;
                            acc_we = 1'b1;
                            carry_we = 1'b1;
                        end
                        4'b0011: begin  // CMC - Complement carry
                            carry_cmp = 1'b1;
                        end
                        4'b0100: begin  // CMA - Complement accumulator
                            alu_op = ALU_CMA;
                            acc_we = 1'b1;
                        end
                        4'b0101: begin  // RAL - Rotate left
                            alu_op = ALU_RAL;
                            acc_we = 1'b1;
                            carry_we = 1'b1;
                        end
                        4'b0110: begin  // RAR - Rotate right
                            alu_op = ALU_RAR;
                            acc_we = 1'b1;
                            carry_we = 1'b1;
                        end
                        4'b0111: begin  // TCC - Transfer carry to accumulator
                            alu_op = ALU_TCC;
                            acc_we = 1'b1;
                            carry_clr = 1'b1;
                        end
                        4'b1000: begin  // DAC - Decrement accumulator
                            alu_op = ALU_DEC;
                            acc_we = 1'b1;
                            carry_we = 1'b1;
                        end
                        4'b1001: begin  // TCS - Transfer carry subtract
                            alu_op = ALU_TCS;
                            acc_we = 1'b1;
                            carry_clr = 1'b1;
                        end
                        4'b1010: begin  // STC - Set carry
                            carry_set = 1'b1;
                        end
                        4'b1011: begin  // DAA - Decimal adjust
                            alu_op = ALU_DAA;
                            acc_we = 1'b1;
                            carry_we = 1'b1;
                        end
                        4'b1100: begin  // KBP - Keyboard process
                            alu_op = ALU_KBP;
                            acc_we = 1'b1;
                        end
                        4'b1101: begin  // DCL - Designate command line
                            // This instruction affects RAM bank selection
                            // Implementation depends on RAM banking scheme
                        end
                    endcase
                end
            endcase
        end
    end

endmodule
