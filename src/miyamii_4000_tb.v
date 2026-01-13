// Testbench for Miyamii-4000 Processor
// Basic functionality test

`timescale 1us/1ns

module miyamii_4000_tb;

    // Clock and reset
    reg        clk;
    reg        rst_n;
    reg        phi1;
    reg        phi2;
    
    // ROM interface
    wire [11:0] rom_addr;
    reg  [7:0]  rom_data;
    wire        rom_ce;
    
    // RAM interface
    wire [11:0] ram_addr;
    reg  [3:0]  ram_data_in;
    wire [3:0]  ram_data_out;
    wire        ram_we;
    wire        ram_ce;
    
    // I/O ports
    reg  [3:0]  rom_port_in;
    wire [3:0]  rom_port_out;
    wire        rom_port_we;
    reg  [3:0]  ram_port_in;
    wire [3:0]  ram_port_out;
    wire        ram_port_we;
    
    // Test pin
    reg         test_pin;
    
    // Status
    wire        carry_flag;
    wire [2:0]  cpu_state;
    wire        stack_overflow;
    wire        stack_underflow;
    
    // Simple ROM memory
    reg [7:0] rom_mem [0:4095];
    
    // Simple RAM memory
    reg [3:0] ram_mem [0:1279];
    
    // DUT instantiation
    miyamii_4000 dut (
        .clk(clk),
        .rst_n(rst_n),
        .phi1(phi1),
        .phi2(phi2),
        .rom_addr(rom_addr),
        .rom_data(rom_data),
        .rom_ce(rom_ce),
        .ram_addr(ram_addr),
        .ram_data_in(ram_data_in),
        .ram_data_out(ram_data_out),
        .ram_we(ram_we),
        .ram_ce(ram_ce),
        .rom_port_in(rom_port_in),
        .rom_port_out(rom_port_out),
        .rom_port_we(rom_port_we),
        .ram_port_in(ram_port_in),
        .ram_port_out(ram_port_out),
        .ram_port_we(ram_port_we),
        .test_pin(test_pin),
        .carry_flag(carry_flag),
        .cpu_state(cpu_state),
        .stack_overflow(stack_overflow),
        .stack_underflow(stack_underflow)
    );
    
    // Clock generation - 10.8us period (740 kHz)
    initial begin
        clk = 0;
        forever #5.4 clk = ~clk;  // 10.8us period
    end
    
    // Two-phase clock generation
    always @(posedge clk) phi1 = 1;
    always @(negedge clk) phi1 = 0;
    
    initial begin
        phi2 = 0;
        forever begin
            #2.7 phi2 = 1;
            #2.7 phi2 = 0;
            #5.4;
        end
    end
    
    // ROM read
    always @(*) begin
        rom_data = rom_mem[rom_addr];
    end
    
    // RAM operations
    always @(posedge clk) begin
        if (ram_we) begin
            ram_mem[ram_addr] <= ram_data_out;
        end
        ram_data_in <= ram_mem[ram_addr];
    end
    
    // Test program
    initial begin
        integer i;
        
        // Initialize memories
        for (i = 0; i < 4096; i = i + 1) begin
            rom_mem[i] = 8'h00;  // NOP
        end
        for (i = 0; i < 1280; i = i + 1) begin
            ram_mem[i] = 4'h0;
        end
        
        // Load a simple test program
        // Test 1: Load immediate and increment
        rom_mem[0] = 8'hD5;    // LDM 5 - Load 5 to accumulator
        rom_mem[1] = 8'hF2;    // IAC - Increment accumulator (5+1=6)
        rom_mem[2] = 8'hF2;    // IAC - Increment accumulator (6+1=7)
        rom_mem[3] = 8'h60;    // INC R0 - Increment register 0
        rom_mem[4] = 8'h80;    // ADD R0 - Add register 0 to accumulator
        
        // Test 2: Register operations
        rom_mem[5] = 8'hD3;    // LDM 3
        rom_mem[6] = 8'hB1;    // XCH R1 - Exchange with register 1
        rom_mem[7] = 8'hD7;    // LDM 7
        rom_mem[8] = 8'h81;    // ADD R1 - Add register 1 to accumulator
        
        // Test 3: Jump
        rom_mem[9] = 8'h40;    // JUN 0x00C (jump to address 12)
        rom_mem[10] = 8'h0C;
        rom_mem[11] = 8'hD9;   // LDM 9 (should be skipped)
        rom_mem[12] = 8'hDA;   // LDM A
        
        // Test 4: FIM - Fetch immediate to register pair
        rom_mem[13] = 8'h20;   // FIM R0R1, 0x42
        rom_mem[14] = 8'h42;
        rom_mem[15] = 8'hA0;   // LD R0
        
        // Test 5: Subroutine call
        rom_mem[16] = 8'h50;   // JMS 0x020 (call subroutine)
        rom_mem[17] = 8'h20;
        rom_mem[18] = 8'hDF;   // LDM F (return here)
        
        // Subroutine at 0x020
        rom_mem[32] = 8'hD8;   // LDM 8
        rom_mem[33] = 8'hC0;   // BBL 0 (return with 0 in accumulator)
        
        // Test 6: Conditional jump
        rom_mem[19] = 8'hF0;   // CLB - Clear both
        rom_mem[20] = 8'h12;   // JCN acc=0, 0x025 (should jump)
        rom_mem[21] = 8'h25;
        rom_mem[22] = 8'hDE;   // LDM E (should be skipped)
        
        rom_mem[37] = 8'hD1;   // LDM 1
        rom_mem[38] = 8'h00;   // NOP
        
        // Initialize signals
        rst_n = 0;
        test_pin = 0;
        rom_port_in = 4'h0;
        ram_port_in = 4'h0;
        
        // VCD dump
        $dumpfile("miyamii_4000_tb.vcd");
        $dumpvars(0, miyamii_4000_tb);
        
        // Reset sequence
        #50;
        rst_n = 1;
        
        // Run for enough time to execute several instructions
        #5000;
        
        $display("Test completed!");
        $display("Final carry flag: %b", carry_flag);
        $display("Stack overflow: %b, underflow: %b", stack_overflow, stack_underflow);
        
        $finish;
    end
    
    // Monitor key signals
    always @(posedge clk) begin
        if (cpu_state == 3'b111) begin  // State X3 (end of instruction)
            $display("Time: %0t | PC: %03x | State: %b | Carry: %b", 
                     $time, rom_addr, cpu_state, carry_flag);
        end
    end

endmodule
