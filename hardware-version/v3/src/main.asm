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

        ;Probably not necessary but just in case
        SEI
        CLD

        ;IMPORTANT - problems with v2. replaced crystal then reran tests 1-10 from v2 here in v3
        ;Added test 0 for v3 which is same as test 2
        ;Copied tests up here as needed

        ;All tests with bank output of latch grounded unless latch connected

        ;Test 0 - added in v3
        ;Start with simple test
        ; - EEPROM, no RIOT, no latch - vv00000 1001000 - good
        ;   - good at first then seemed all over the place
        ;   - tried again and all over the place
        ;   - does it make a difference if logic probe pin is touching when switched on?
        ;     - worked 5 times with probe not touching when switched on
        ; - EEPROM, no RIOT, latch - vv000000 1001000 - good 
        ; - EEPROM, RIOT, latch - 
        ;.loop2:
        ;    INX
        ;    JMP .loop2

        ;Test 1
        ;v2 - Tried with latch part below uncommented first, didn't work, commented out, did test 1
        ;v3 - Uncommented latch loop (30 bytes)
        ; - EEPROM, RIOT, latch - vvvvv00v v001000 - good
        ;   - Expected -          vvvvv00v v001000
        ;   - Stopped here then tried again another day - still good
        ; - EEPROM, RIOT, latch, RAM - vvvvv00v v001000 - good
         
        ;LDA #(LCD_E|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR
        ;LDX #0
        ;.loop1:
        ;    ;Write val to latch
        ;    ;(In fixed EEPROM so can change bank)
        ;    STX PORT_B
        ;    LDA #LATCH_CP
        ;    STA PORT_A
        ;    EOR #LATCH_CP
        ;    STA PORT_A

        ;    INX
        ;    JMP .loop1
  
        ;***Skipped other tests since working to here***

        ;Test 5 - RAM
        ;Write test values
        ; - EEPROM, RIOT, latch, RAM
        ;   - plugged in EEPROM backwards - ruined? PORT B stuck on and latch not toggling
        ;     - came back later: actually expected if failed. LCD_E toggling?
        ;   - able to read contents in EEPROM reader so not totally dead
        ;   - back to problem with lines stuck high where I thought xtal had died. caused by probing around?
        ;   - whoops, need to initialize RIOT first - added below
        ;     - still no output on LCD_E or PORT_B
        ;   - commented out check for error
        ;     - address lines all 1
        ;     - tried again and lines toggling
        ;       - still nothing on latch or RIOT outputs

        ;LDA #(LCD_E|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR
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
        ;    ;BNE .error
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

        ;Tried test 1 again
        ;No output from RIOT :/
        ; - is RAM drawing too much current?
        ; tried without RAM
        ; - all lines changing now except A6
        ; - 3rd try back to normal. VCC 4.96v
        ;   - still curious if probing causes crash
        ; - 4th try back to all lines changing

        ;***END OF TESTS COPIED FROM V2***
        ;(Restart numbering to keep separate)

        ;Test 106 based on test 1
        ;EEPROM, latch, RIOT, no RAM
        ;Does RIOT need time before initializing? - no
        ; - Boots but no RIOT output
        ;Waited a few hours then it worked correctly
        ; - hmmm, power supply?
        ; - worked second time too
        ;Added RAM back in
        ; - EEPROM, latch, RIOT, RAM - good
        ;LDX #0
        ;.warmup:
        ;    nop
        ;    nop
        ;    nop
        ;    nop
        ;    INX
        ;    BNE .warmup
        ;LDA #(LCD_E|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR
        ;LDX #0
        ;.loop1:
        ;    ;Write val to latch
        ;    ;(In fixed EEPROM so can change bank)
        ;    STX PORT_B
        ;    LDA #LATCH_CP
        ;    STA PORT_A
        ;    EOR #LATCH_CP
        ;    STA PORT_A

        ;    INX
        ;    JMP .loop1

        ;Test 107 - same as test 5
        ;Only probing port output pins in case that's interfering
        ;EEPROM, latch, RIOT, RAM - failed on very first try
        ; - pins not toggling 
        ; - second try: some pins of latch toggled but not all
        ;   - port B not toggling but it's what feeds latch - hmm
        ;LDA #(LCD_E|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR
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
        ;    ;BNE .error
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

        ;Test 108 based on test 5
        ;Try toggling one pin instead of whole latch
        ;(bank pins shouldnt matter but just in case)

        ;***SOLDERED IN TPS61023. WORKS!!!***

        LDA #(LCD_E|LATCH_CP)
        STA PORT_A_DIR
        LDA #$FF
        STA PORT_B_DIR
        LDY #0
        LDX #0
        .loop_write:
            TXA
            STA 0,X
            INX
            BNE .loop_write
        ;Check test values
        LDX #0
        .loop_check:
            TXA
            CMP 0,X
            ;BNE .error
            INX
            BNE .loop_check
        ;Success - increment latch and output
        TYA
        AND #LCD_CS1|LCD_CS2
        STA PORT_B
        LDA #LATCH_CP
        STA PORT_A
        EOR #LATCH_CP
        STA PORT_A
        INY
        JMP .loop_write
        ;Test value did not match
        .error:
            LDA #LCD_E
            STA PORT_A
            EOR #LCD_E
            STA PORT_A
            JMP .error
	END

;Insertion point for string literals
;(should come after all instances of CALL)
;=========================================
	STRING_LITERALS

	code_end:
	
