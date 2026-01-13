// Miyamii-4000 Processor Top Module
// 4-bit processor with 12-bit address space
// Intel 4004-inspired architecture

module miyamii_4000 (
    // Clock and reset
    input  wire        clk,            // Main clock
    input  wire        rst_n,          // Active-low reset
    input  wire        phi1,           // Clock phase 1
    input  wire        phi2,           // Clock phase 2
    
    // Program memory interface (ROM)
    output wire [11:0] rom_addr,       // ROM address
    input  wire [7:0]  rom_data,       // ROM data input
    output wire        rom_ce,         // ROM chip enable
    
    // Data memory interface (RAM)
    output wire [11:0] ram_addr,       // RAM address (from register pair)
    input  wire [3:0]  ram_data_in,    // RAM data input
    output wire [3:0]  ram_data_out,   // RAM data output
    output wire        ram_we,         // RAM write enable
    output wire        ram_ce,         // RAM chip enable
    
    // I/O ports
    input  wire [3:0]  rom_port_in,    // ROM port input
    output wire [3:0]  rom_port_out,   // ROM port output
    output wire        rom_port_we,    // ROM port write enable
    
    input  wire [3:0]  ram_port_in,    // RAM port input
    output wire [3:0]  ram_port_out,   // RAM port output
    output wire        ram_port_we,    // RAM port write enable
    
    // Test signal for conditional jumps
    input  wire        test_pin,       // Test input signal
    
    // Status outputs
    output wire        carry_flag,     // Carry flag output
    output wire [2:0]  cpu_state,      // Current CPU state
    output wire        stack_overflow, // Stack overflow indicator
    output wire        stack_underflow // Stack underflow indicator
);

    // Internal registers
    reg [3:0]  accumulator;
    reg        carry;
    reg [7:0]  instruction_reg;
    reg [7:0]  second_byte;
    reg [11:0] ram_address_reg;
    
    // Control signals from decoder
    wire        is_two_byte;
    wire [4:0]  alu_op;
    wire [3:0]  reg_addr;
    wire [2:0]  reg_pair;
    wire [3:0]  immediate;
    wire [3:0]  condition;
    wire        acc_we;
    wire        reg_we_dec;
    wire        carry_we;
    wire        carry_clr;
    wire        carry_set;
    wire        carry_cmp;
    wire        pc_load_dec;
    wire        pc_inc_dec;
    wire        stack_push;
    wire        stack_pop;
    wire        ram_we_dec;
    wire        ram_re;
    wire        rom_port_we_dec;
    wire        rom_port_re;
    wire [1:0]  ram_status_sel;
    wire        use_status;
    wire        is_nop;
    
    // Control FSM signals
    wire [2:0]  state;
    wire        state_a1, state_a2, state_a3;
    wire        state_m1, state_m2;
    wire        state_x1, state_x2, state_x3;
    wire        fetch_enable;
    wire        decode_enable;
    wire        execute_enable;
    wire        is_first_byte;
    
    // PC signals
    wire [11:0] pc_current;
    reg  [11:0] pc_next;
    reg         pc_load;
    reg         pc_inc;
    
    // ALU signals
    wire [3:0]  alu_result;
    wire        alu_carry_out;
    reg  [3:0]  alu_a, alu_b;
    
    // Register file signals
    reg  [3:0]  rf_wdata;
    wire [3:0]  rf_rdata;
    wire [7:0]  rf_pair_rdata;
    reg         rf_we;
    
    // Jump condition evaluation
    reg         jump_condition_met;
    
    // Instruction register management
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instruction_reg <= 8'b0;
            second_byte <= 8'b0;
        end else begin
            if (state_a2 && fetch_enable) begin
                instruction_reg <= rom_data;
            end
            if (state_m1 && fetch_enable && is_two_byte) begin
                second_byte <= rom_data;
            end
        end
    end
    
    // Accumulator
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accumulator <= 4'b0;
        end else if (execute_enable && acc_we) begin
            if (instruction_reg[7:4] == 4'b1011) begin  // XCH
                accumulator <= rf_rdata;
            end else if (instruction_reg[7:4] == 4'b1100) begin  // BBL
                accumulator <= immediate;
            end else if (instruction_reg[7:4] == 4'b1101) begin  // LDM
                accumulator <= immediate;
            end else if (ram_re) begin
                accumulator <= ram_data_in;
            end else if (rom_port_re) begin
                accumulator <= rom_port_in;
            end else begin
                accumulator <= alu_result;
            end
        end
    end
    
    // Carry flag
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            carry <= 1'b0;
        end else begin
            if (carry_clr) begin
                carry <= 1'b0;
            end else if (carry_set) begin
                carry <= 1'b1;
            end else if (carry_cmp) begin
                carry <= ~carry;
            end else if (execute_enable && carry_we) begin
                carry <= alu_carry_out;
            end
        end
    end
    
    // RAM address register (set by SRC instruction)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ram_address_reg <= 12'b0;
        end else if (state_x2 && instruction_reg[7:4] == 4'b0010 && instruction_reg[0] == 1'b1) begin
            // SRC instruction - Send Register Control
            ram_address_reg <= {4'b0, rf_pair_rdata};
        end
    end
    
    // ALU operand selection
    always @(*) begin
        alu_a = accumulator;
        alu_b = rf_rdata;
        
        if (instruction_reg[7:4] == 4'b0110) begin  // INC
            alu_a = rf_rdata;
            alu_b = 4'b0;
        end else if (ram_re && (instruction_reg[3:0] == 4'b1000 || instruction_reg[3:0] == 4'b1011)) begin
            // SBM or ADM - use RAM data
            alu_b = ram_data_in;
        end
    end
    
    // Register file write data
    always @(*) begin
        rf_wdata = alu_result;
        if (instruction_reg[7:4] == 4'b1011) begin  // XCH
            rf_wdata = accumulator;
        end
    end
    
    // Register file write enable
    always @(*) begin
        rf_we = execute_enable && reg_we_dec && (state_x1 || state_x2);
    end
    
    // Jump condition evaluation
    always @(*) begin
        jump_condition_met = 1'b0;
        
        if (instruction_reg[7:4] == 4'b0001) begin  // JCN
            // Evaluate condition directly without intermediate variables
            // Bit 1: accumulator = 0
            // Bit 2: carry = 1
            // Bit 3: test pin = 0
            // Bit 0: invert
            
            if (condition[0]) begin
                // Inverted condition
                jump_condition_met = ~((condition[1] & (accumulator == 4'b0)) |
                                       (condition[2] & carry) |
                                       (condition[3] & ~test_pin));
            end else begin
                // Normal condition
                jump_condition_met = (condition[1] & (accumulator == 4'b0)) |
                                     (condition[2] & carry) |
                                     (condition[3] & ~test_pin);
            end
        end
    end
    
    // PC control
    always @(*) begin
        pc_next = pc_current;
        pc_load = 1'b0;
        pc_inc = 1'b0;
        
        if (state_x3) begin
            if (instruction_reg[7:4] == 4'b0001) begin  // JCN
                if (jump_condition_met) begin
                    pc_next = {pc_current[11:8], second_byte};
                    pc_load = 1'b1;
                end else begin
                    pc_inc = 1'b1;
                end
            end else if (instruction_reg[7:4] == 4'b0011 && instruction_reg[0] == 1'b1) begin  // JIN
                pc_next = {4'b0, rf_pair_rdata};
                pc_load = 1'b1;
            end else if (instruction_reg[7:4] == 4'b0100) begin  // JUN
                pc_next = {instruction_reg[3:0], second_byte};
                pc_load = 1'b1;
            end else if (instruction_reg[7:4] == 4'b0101) begin  // JMS
                pc_next = {instruction_reg[3:0], second_byte};
                pc_load = 1'b1;
            end else if (instruction_reg[7:4] == 4'b0111) begin  // ISZ
                if (alu_result == 4'b0) begin
                    pc_next = {pc_current[11:8], second_byte};
                    pc_load = 1'b1;
                end else begin
                    pc_inc = 1'b1;
                end
            end else if (instruction_reg[7:4] == 4'b1100) begin  // BBL
                // PC is popped from stack
            end else begin
                pc_inc = 1'b1;
            end
        end else if (state_a2 || (state_m1 && is_two_byte)) begin
            // Increment during fetch
            pc_inc = 1'b1;
        end
    end
    
    // Output assignments
    assign rom_addr = pc_current;
    assign rom_ce = 1'b1;
    
    assign ram_addr = ram_address_reg;
    assign ram_data_out = accumulator;
    assign ram_we = execute_enable && ram_we_dec && (state_x1 || state_x2);
    assign ram_ce = ram_we || ram_re;
    
    assign rom_port_out = accumulator;
    assign rom_port_we = execute_enable && rom_port_we_dec && state_x2;
    assign ram_port_out = accumulator;
    assign ram_port_we = execute_enable && ram_we_dec && instruction_reg[3:0] == 4'b0001 && state_x2;
    
    assign carry_flag = carry;
    assign cpu_state = state;
    
    // Module instantiations
    
    alu alu_inst (
        .a(alu_a),
        .b(alu_b),
        .carry_in(carry),
        .op(alu_op),
        .result(alu_result),
        .carry_out(alu_carry_out)
    );
    
    register_file rf_inst (
        .clk(clk),
        .rst_n(rst_n),
        .reg_addr(reg_addr),
        .reg_wdata(rf_wdata),
        .reg_we(rf_we),
        .reg_rdata(rf_rdata),
        .pair_addr(reg_pair),
        .pair_wdata(second_byte),
        .pair_we(execute_enable && instruction_reg[7:4] == 4'b0010 && instruction_reg[0] == 1'b0 && state_x2),
        .pair_rdata(rf_pair_rdata)
    );
    
    pc_stack pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .pc_in(pc_next),
        .pc_load(pc_load),
        .pc_inc(pc_inc),
        .pc_out(pc_current),
        .stack_push(execute_enable && stack_push && state_x1),
        .stack_pop(execute_enable && stack_pop && state_x1),
        .stack_overflow(stack_overflow),
        .stack_underflow(stack_underflow)
    );
    
    instruction_decoder decoder_inst (
        .instruction(instruction_reg),
        .is_first_byte(is_first_byte),
        .is_two_byte(is_two_byte),
        .alu_op(alu_op),
        .reg_addr(reg_addr),
        .reg_pair(reg_pair),
        .immediate(immediate),
        .condition(condition),
        .acc_we(acc_we),
        .reg_we(reg_we_dec),
        .carry_we(carry_we),
        .carry_clr(carry_clr),
        .carry_set(carry_set),
        .carry_cmp(carry_cmp),
        .pc_load(pc_load_dec),
        .pc_inc(pc_inc_dec),
        .stack_push(stack_push),
        .stack_pop(stack_pop),
        .ram_we(ram_we_dec),
        .ram_re(ram_re),
        .rom_port_we(rom_port_we_dec),
        .rom_port_re(rom_port_re),
        .ram_status_sel(ram_status_sel),
        .use_status(use_status),
        .is_nop(is_nop)
    );
    
    control_fsm fsm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .phi1(phi1),
        .phi2(phi2),
        .state(state),
        .state_a1(state_a1),
        .state_a2(state_a2),
        .state_a3(state_a3),
        .state_m1(state_m1),
        .state_m2(state_m2),
        .state_x1(state_x1),
        .state_x2(state_x2),
        .state_x3(state_x3),
        .is_two_byte(is_two_byte),
        .fetch_enable(fetch_enable),
        .decode_enable(decode_enable),
        .execute_enable(execute_enable),
        .is_first_byte(is_first_byte)
    );

endmodule
