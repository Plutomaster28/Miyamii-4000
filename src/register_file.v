// Register File for Miyamii-4000 Processor
// 16 registers of 4 bits each
// Can be addressed individually or as 8 pairs for 8-bit operations

module register_file (
    input  wire        clk,
    input  wire        rst_n,
    
    // Single register access (4-bit)
    input  wire [3:0]  reg_addr,       // Register address (0-15)
    input  wire [3:0]  reg_wdata,      // Write data
    input  wire        reg_we,         // Write enable
    output wire [3:0]  reg_rdata,      // Read data
    
    // Register pair access (8-bit)
    input  wire [2:0]  pair_addr,      // Pair address (0-7)
    input  wire [7:0]  pair_wdata,     // Write data for pair
    input  wire        pair_we,        // Write enable for pair
    output wire [7:0]  pair_rdata      // Read data from pair
);

    // 16 x 4-bit register array
    reg [3:0] registers [0:15];
    
    integer i;
    
    // Write operations
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to 0
            for (i = 0; i < 16; i = i + 1) begin
                registers[i] <= 4'b0;
            end
        end else begin
            // Single register write
            if (reg_we) begin
                registers[reg_addr] <= reg_wdata;
            end
            
            // Register pair write (writes to two consecutive registers)
            if (pair_we) begin
                registers[{pair_addr, 1'b0}]     <= pair_wdata[7:4];  // High nibble to even register
                registers[{pair_addr, 1'b1}]     <= pair_wdata[3:0];  // Low nibble to odd register
            end
        end
    end
    
    // Read operations (combinational)
    assign reg_rdata  = registers[reg_addr];
    assign pair_rdata = {registers[{pair_addr, 1'b0}], registers[{pair_addr, 1'b1}]};

endmodule
