; Sample program for Miyamii-4000 Processor
; Demonstrates various instructions

; Program: Calculate Fibonacci sequence
; Stores results in registers R0-R7

START:
    ; Initialize Fibonacci sequence
    LDM 0           ; F(0) = 0
    XCH 0           ; Store in R0
    LDM 1           ; F(1) = 1
    XCH 1           ; Store in R1
    
    ; Calculate F(2)
    LD 0            ; Load F(0)
    ADD 1           ; Add F(1)
    XCH 2           ; Store F(2) in R2
    
    ; Calculate F(3)
    LD 1            ; Load F(1)
    ADD 2           ; Add F(2)
    XCH 3           ; Store F(3) in R3
    
    ; Calculate F(4)
    LD 2            ; Load F(2)
    ADD 3           ; Add F(3)
    XCH 4           ; Store F(4) in R4
    
    ; Calculate F(5)
    LD 3            ; Load F(3)
    ADD 4           ; Add F(4)
    XCH 5           ; Store F(5) in R5
    
    ; Calculate F(6)
    LD 4            ; Load F(4)
    ADD 5           ; Add F(5)
    XCH 6           ; Store F(6) in R6
    
    ; Calculate F(7)
    LD 5            ; Load F(5)
    ADD 6           ; Add F(6)
    XCH 7           ; Store F(7) in R7
    
    ; Display results by writing to ROM port
    LD 0            ; Load F(0)
    WRR             ; Write to ROM port
    
    LD 1            ; Load F(1)
    WRR             ; Write to ROM port
    
    LD 2            ; Load F(2)
    WRR             ; Write to ROM port
    
    LD 3            ; Load F(3)
    WRR             ; Write to ROM port
    
    LD 4            ; Load F(4)
    WRR             ; Write to ROM port
    
    LD 5            ; Load F(5)
    WRR             ; Write to ROM port
    
    LD 6            ; Load F(6)
    WRR             ; Write to ROM port
    
    LD 7            ; Load F(7)
    WRR             ; Write to ROM port

DONE:
    JUN DONE        ; Loop forever
