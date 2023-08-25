;Unlimited lines per page
;========================
	PAGE 0

;Included files
;==============
	include macros.asm
    include riot.asm

;Constants
;=========
RESET_VECTOR = $FFFC
FIXED_EEPROM = $900

;Main code
;=========
	;Reset vector - repeat in all 8 banks
	ORG RESET_VECTOR-$8000
	FDB main
	ORG RESET_VECTOR-$9000
	FDB main
	ORG RESET_VECTOR-$A000
	FDB main
	ORG RESET_VECTOR-$B000
	FDB main
	ORG RESET_VECTOR-$C000
	FDB main
	ORG RESET_VECTOR-$D000
	FDB main
	ORG RESET_VECTOR-$E000
	FDB main
	ORG RESET_VECTOR-$F000
	FDB main
	
;Functions in ROM
;================
	ORG FIXED_EEPROM
	
;Main function
;=============
	FUNC main BEGIN

        ;All tests with bank output of latch grounded unless latch connected

        ;Test 1
        ;Tried with latch part below uncommented first, didn't work, commented out, did test 1
        ; - EEPROM, no RIOT, no latch - vv110000 1001000 - good
        ; - EEPROM, RIOT, no latch    - vvvvvvvv - bad
        ;   - Vcc = 5.00v
        ; - EEPROM, no RIOT, no latch - vv110000 1001000 - good
         
        ;LDA #(LCD_E|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR
        ;LDX #0
        ;.loop1:
        ;    ;Write val to latch
        ;    ;(In fixed EEPROM so can change bank)
        ;    ;STX PORT_B
        ;    ;LDA #LATCH_CP
        ;    ;STA PORT_A
        ;    ;EOR #LATCH_CP
        ;    ;STA PORT_A

        ;    INX
        ;    JMP .loop1
   
        ;Test 2
        ;Maybe initializing RIOT causes problem?
        ;Simple writing to RIOT port A worked before hooked to latch and connectors, so RIOT has worked before
        ; - EEPROM, no RIOT, no latch - vv00000 1001000 - good
        ; - EEPROM, RIOT, no latch - vv000000 - good
        ;.loop2:
        ;    INX
        ;    JMP .loop2

        ;Test 3
        ;Try code from yesterday that worked
        ; - EEPROM, RIOT, no latch - good
        ;LDA #$FF
        ;STA PORT_A_DIR
        ;STA PORT_B_DIR
        ;LDX #0
        ;LDY #0
        ;.loop:
        ;    STX PORT_A
        ;    INX
        ;    BNE .loop
        ;    INY
        ;    STY PORT_B
        ;    JMP .loop

        ;Test 4
        ;Modiy code from yesterday that worked
        ;Now matches test 1 and works
        ;Was it no pull ups on latch input at beginning?
        ; - EEPROM, RIOT, no latch - good
        ; - EEPROM, RIOT, latch - good
        ; - EEPOROM, RIOT, latch, RAM - good
        ;LDA #(LCD_E|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR
        ;LDX #0
        ;.loop:
        ;    STX PORT_B
        ;    LDA #LATCH_CP
        ;    STA PORT_A
        ;    EOR #LATCH_CP
        ;    STA PORT_A
        ;    INX
        ;    JMP .loop

        ;Test 5 - RAM
        ;Write test values
        ; - EEPROM, RIOT, latch, RAM - failed
        ;   - Addresses count up but seems to crash and addresses go to all 1s
        ;   - 4.98V
        ; - Go back and add to test 4 - same test with RAM installed - good
        ;LDY #0
        ;LDX #0
        ;.loop_write:
        ;    TXA
        ;    STA 0,X
        ;    INX
        ;    BNE .loop_write
        ;;Check test values
        ;LDX #0
        ;.loop_check:
        ;    TXA
        ;    CMP 0,X
        ;    BNE .error
        ;    INX
        ;    BNE .loop_check
        ;;Success - increment latch and output
        ;STY PORT_B
        ;LDA #LATCH_CP
        ;STA PORT_A
        ;EOR #LATCH_CP
        ;STA PORT_A
        ;INY
        ;JMP .loop_write
        ;;Test value did not match
        ;.error:
        ;    LDA #LCD_E
        ;    STA PORT_A
        ;    EOR #LCD_E
        ;    STA PORT_A
        ;    JMP .error

        ;Test 6
        ;Modify test 4 adding RAM tests slowly
        ; - EEPROM, RIOT, latch, RAM
        ;   - fails when loading from RAM in loop (R1+R2)
        ;   - fails when writing once to RAM before loop (R1)
        ;   - fails now with no RAM access below, addresses all 1, ie identical to test 4
        ;     - A0 is 1 before reset. reset chip problem?
        ; - EEPROM, RIOT, latch, no RAM
        ;   - no RAM access - succeeds
        ;   - fails when loading from RAM in loop (R3)
        ;     - goes through all addreses
        ;   - no RAM access - succeeds
        ;LDA #(LCD_E|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR
        
        ;;R1
        ;;LDA #0
        ;;STA 0
        ;;LDA #LCD_E
        ;;STA 1

        ;LDX #0
        ;.loop:
        ;    STX PORT_B
        ;    LDA #LATCH_CP
        ;    STA PORT_A
        ;    EOR #LATCH_CP
        ;    STA PORT_A

        ;    ;R2
        ;    ;LDA 0
        ;    ;STA PORT_A
        ;    ;LDA 1
        ;    ;STA PORT_A
            
        ;    ;R3
        ;    ;LDA 0
        ;    ;LDA $400

        ;    INX
        ;    JMP .loop

        ;Test 7
        ;When streps through all addresses, A5 or A6 stays 0 while all address lines cycle
        ;Failure is when program >=32 bytes? no, see below
        ;Test 4 but larger than 32 bytes
        ; - EEPROM, RIOT, latch, no RAM. no NOPs (30 bytes) - success
        ; - EEPROM, RIOT, latch, no RAM. with 3 NOPs (33 bytes) - success
        ;   - 33rd byte is RTS and never executed
        ; - EEPROM, RIOT, latch, no RAM. with 4 NOPs (34 bytes) - success
        ;   - A5 now toggling as expected
        ; - EEPROM, RIOT, latch, no RAM. with 10 NOPs (40 bytes) - success
        ;LDA #(LCD_E|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR
        ;LDX #0

        ;NOP
        ;NOP
        ;NOP
        ;NOP
        ;NOP
        ;NOP
        ;NOP
        ;NOP
        ;NOP
        ;NOP
        
        ;.loop:
        ;    STX PORT_B
        ;    LDA #LATCH_CP
        ;    STA PORT_A
        ;    EOR #LATCH_CP
        ;    STA PORT_A
        ;    INX
        ;    JMP .loop

        ;Test 8
        ;Read from RAM addresses - minimal example
        ; - EEPROM, RIOT, latch, no RAM. (R1) - success
        ; - EEPROM, RIOT, latch, no RAM. (R2) - success
        ;Connected Phi2 instead of Phi0 to GAL
        ; - EEPROM, RIOT, latch, no RAM. (R3) - failed
        ;   - seems to fail or succeed partly based on prior tests
        ;LDA #(LCD_E|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR
        ;LDX #0

        ;;R1
        ;;LDA 0

        ;.loop:
        ;    STX PORT_B
        ;    LDA #LATCH_CP
        ;    STA PORT_A
        ;    EOR #LATCH_CP
        ;    STA PORT_A
            
        ;    ;R2
        ;    ;LDA 0

        ;    ;R3
        ;    LDA $400

        ;    INX
        ;    JMP .loop

        ;Test 9
        ;Unsocketed all chips, resoldered GAL from Phi0 to Phi2, socketed then started crashing
        ;Back to known working code
        ; - EEPROM, RIOT, latch, no RAM - failed
        ;   - Address pins stuck at 0 or 1
        ;LDA #(LCD_E|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR
        ;LDX #0
        ;.loop:
        ;    STX PORT_B
        ;    LDA #LATCH_CP
        ;    STA PORT_A
        ;    EOR #LATCH_CP
        ;    STA PORT_A
        ;    INX
        ;    JMP .loop

        ;Test 10
        ;Back to simplest example
        ; - EEPROM, no RIOT, no latch, no RAM
        ;   - same behavior - address pins stuck
        .loop:
            JMP .loop

	END

;Insertion point for string literals
;(should come after all instances of CALL)
;=========================================
	STRING_LITERALS

	code_end:
	
