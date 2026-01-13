; BCD Counter Example for Miyamii-4000
; Counts from 0 to 99 in BCD format
; Uses R0 for ones digit, R1 for tens digit

START:
    CLB             ; Clear accumulator and carry
    XCH 0           ; Clear R0 (ones digit)
    XCH 1           ; Clear R1 (tens digit)

COUNT_LOOP:
    ; Increment ones digit
    LD 0            ; Load ones digit
    IAC             ; Increment
    DAA             ; Decimal adjust
    XCH 0           ; Store back
    
    ; Check if we need to increment tens digit
    JCN NZ, DISPLAY ; If not zero, just display
    
    ; Ones digit wrapped to 0, increment tens
    LD 1            ; Load tens digit
    IAC             ; Increment
    DAA             ; Decimal adjust
    XCH 1           ; Store back
    
    ; Check if we reached 100
    LDM 10          ; Load 10
    XCH 2           ; Store in R2 for comparison
    LD 1            ; Load tens digit
    SUB 2           ; Compare with 10
    JCN Z, START    ; If equal, restart from 0

DISPLAY:
    ; Output the current count
    ; Combine tens and ones into accumulator
    LD 1            ; Load tens digit
    WRR             ; Write to ROM port (tens)
    LD 0            ; Load ones digit
    WRR             ; Write to ROM port (ones)
    
    ; Small delay loop (optional)
    LDM 15          ; Load delay counter
    XCH 3           ; Store in R3

DELAY:
    INC 3           ; Increment R3
    LD 3            ; Load R3
    JCN NZ, DELAY   ; Loop if not zero
    
    ; Continue counting
    JUN COUNT_LOOP

; Subroutine: Display two-digit BCD number
; R0 = ones digit, R1 = tens digit
SHOW_BCD:
    LD 1            ; Load tens
    WRR             ; Output
    LD 0            ; Load ones
    WRR             ; Output
    BBL 0           ; Return
