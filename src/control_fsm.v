// Control FSM for Miyamii-4000 Processor
// 8-state finite state machine for instruction cycle timing
// States: A1, A2, A3, M1, M2, X1, X2, X3

module control_fsm (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        phi1,           // Clock phase 1
    input  wire        phi2,           // Clock phase 2
    
    // State outputs
    output reg  [2:0]  state,          // Current state
    output wire        state_a1,       // State indicators
    output wire        state_a2,
    output wire        state_a3,
    output wire        state_m1,
    output wire        state_m2,
    output wire        state_x1,
    output wire        state_x2,
    output wire        state_x3,
    
    // Control signals
    input  wire        is_two_byte,    // Current instruction is two bytes
    output reg         fetch_enable,   // Enable instruction fetch
    output reg         decode_enable,  // Enable instruction decode
    output reg         execute_enable, // Enable execution
    output reg         is_first_byte   // Fetching first byte
);

    // State encoding
    localparam STATE_A1 = 3'b000;  // Fetch first byte, send to IR
    localparam STATE_A2 = 3'b001;  // Continue fetch
    localparam STATE_A3 = 3'b010;  // Decode instruction
    localparam STATE_M1 = 3'b011;  // Execute or fetch second byte
    localparam STATE_M2 = 3'b100;  // Continue execution
    localparam STATE_X1 = 3'b101;  // Complete execution
    localparam STATE_X2 = 3'b110;  // Write back results
    localparam STATE_X3 = 3'b111;  // Finish cycle
    
    reg [2:0] next_state;
    reg       need_second_byte;
    
    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_A1;
            need_second_byte <= 1'b0;
        end else begin
            state <= next_state;
            if (state == STATE_A3) begin
                need_second_byte <= is_two_byte;
            end
        end
    end
    
    // Next state logic
    always @(*) begin
        case (state)
            STATE_A1: next_state = STATE_A2;
            STATE_A2: next_state = STATE_A3;
            STATE_A3: next_state = STATE_M1;
            STATE_M1: next_state = STATE_M2;
            STATE_M2: next_state = STATE_X1;
            STATE_X1: next_state = STATE_X2;
            STATE_X2: next_state = STATE_X3;
            STATE_X3: next_state = STATE_A1;
            default:  next_state = STATE_A1;
        endcase
    end
    
    // Output logic
    always @(*) begin
        fetch_enable = 1'b0;
        decode_enable = 1'b0;
        execute_enable = 1'b0;
        is_first_byte = 1'b1;
        
        case (state)
            STATE_A1: begin
                fetch_enable = 1'b1;
                is_first_byte = 1'b1;
            end
            
            STATE_A2: begin
                fetch_enable = 1'b1;
                is_first_byte = 1'b1;
            end
            
            STATE_A3: begin
                decode_enable = 1'b1;
                is_first_byte = 1'b1;
            end
            
            STATE_M1: begin
                if (need_second_byte) begin
                    fetch_enable = 1'b1;
                    is_first_byte = 1'b0;
                end else begin
                    execute_enable = 1'b1;
                end
            end
            
            STATE_M2: begin
                execute_enable = 1'b1;
                is_first_byte = !need_second_byte;
            end
            
            STATE_X1: begin
                execute_enable = 1'b1;
            end
            
            STATE_X2: begin
                execute_enable = 1'b1;
            end
            
            STATE_X3: begin
                execute_enable = 1'b1;
            end
        endcase
    end
    
    // State indicator outputs
    assign state_a1 = (state == STATE_A1);
    assign state_a2 = (state == STATE_A2);
    assign state_a3 = (state == STATE_A3);
    assign state_m1 = (state == STATE_M1);
    assign state_m2 = (state == STATE_M2);
    assign state_x1 = (state == STATE_X1);
    assign state_x2 = (state == STATE_X2);
    assign state_x3 = (state == STATE_X3);

endmodule
