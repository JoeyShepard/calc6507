;Unlimited lines per page
;========================
	PAGE 0

;Included files
;==============
	include macros.asm
    include riot.asm

;Constants
;=========
RESET_VECTOR    = $FFFC
FIXED_EEPROM    = $900

;LCD commands
LCD_ON          = $3F
LCD_ROW         = $B8
LCD_COL         = $40
LCD_Z           = $C0

;LCD constants
LCD_BOTH        = 0

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

        ;Test 209 - same as test 108 in v3
        ;Works as expected!
        ;- error line uncommented though
        ;Uncommented error line
        ;- errored so RAM not working yet
        
        ;;Setup
        ;LDA #(LCD_E|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR
        ;LDY #0
        ;;Write test values
        ;.test:
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
        ;TYA
        ;AND #LCD_CS1|LCD_CS2
        ;STA PORT_B
        ;LDA #LATCH_CP
        ;STA PORT_A
        ;EOR #LATCH_CP
        ;STA PORT_A
        ;INY
        ;JMP .test
        ;;Test value did not match
        ;.error:
        ;    TXA
        ;    STA PORT_B
        ;.error_loop:
        ;    LDA #LCD_E
        ;    STA PORT_A
        ;    EOR #LCD_E
        ;    STA PORT_A
        ;    JMP .error_loop

        ;Test 210
        ;RAM didn't work due to error in GAL!
        ;Back to basic test to make sure everything else still working
        ; - EEPROM, latch, GAL, RAM - crashes
        ;   - A12 and A14 toggle between 1 and nothing. crashing over and over?
        ; - EEPROM, latch, GAL, no RAM
        ;   - also crashing over and over
        ; - try to read then reprogram GAL
        ;   - software shows mostly 1s! 
        ;   - reprogrammed then failed verification but noticed LOCK bit set
        ;   - tried with brand new GAL and able to verify if no lock bit
        ;   - switched back to original GAL and able to verify after programming
        ; - EEPROM, latch, GAL, no RAM
        ;   - worked after reflashing
        ; - EEPROM, latch, GAL, RAM - good

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

        ;***ADDED LCD_RW TO PORT_A INIT!***

        ;Test 211 - same as 209
        ;EEPROM, latch, GAL, RAM - good!!!

        ;Setup
        ;LDA #(LCD_E|LCD_RW|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR
        ;LDY #0
        ;;Write test values
        ;.test:
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
        ;TYA
        ;AND #LCD_CS1|LCD_CS2
        ;STA PORT_B
        ;LDA #LATCH_CP
        ;STA PORT_A
        ;EOR #LATCH_CP
        ;STA PORT_A
        ;INY
        ;JMP .test
        ;;Test value did not match
        ;.error:
        ;    TXA
        ;    STA PORT_B
        ;.error_loop:
        ;    LDA #LCD_E
        ;    STA PORT_A
        ;    EOR #LCD_E
        ;    STA PORT_A
        ;    JMP .error_loop

;DO NOT COMMENT OUT MACROS

;10us delay. At 1mhz, each nop is 2us.
delay MACRO
    nop
    nop
    nop
    nop
    nop
    ENDM

LatchLoad MACRO
    LDA #LATCH_CP 
    STA PORT_A
    LDA #0
    STA PORT_A
    ENDM

LCD_Pulse MACRO
    LDA #LCD_E
    STA PORT_A
    delay
    LDA #0
    STA PORT_A
    delay ;probably not necessary
    ENDM

;CS in A
;Data in Y
LCD_Data MACRO
    EOR #LCD_DI|LCD_RST
    STA PORT_B
    LatchLoad

    STY PORT_B
    LCD_Pulse
    ENDM

;CS in A
;Data in Y
LCD_Instruction MACRO
    EOR #LCD_RST ;DI=I=0
    STA PORT_B
    LatchLoad

    STY PORT_B
    LCD_Pulse
    ENDM

        ;Test 212 - write to LCD
        ;With LCD - nothing on LCD, all address lines toggle
        ;Without LCD - all address lines toggle
        ;Added jump to bottom where PORT B cycles
        ; - all address lines toggle
        ;Is the adapter causing problems?
        ; - without adapter, worked correctly!
        ;Removed jump to bottom, back to normal test
        ; - worked with no LCD hooked up
        ;Normal test with LCD - good!

        ;Setup
        ;LDA #0 ;LCD_E low, RW=W=0, latch cp low
        ;STA PORT_A
        ;LDA #(LCD_E|LCD_RW|LATCH_CP)
        ;STA PORT_A_DIR
        ;LDA #$FF
        ;STA PORT_B_DIR

        ;;JMP .done

        ;;Bank=0, DI=I=0, both CS, RST=0
        ;LDA #0
        ;STA PORT_B
        ;LatchLoad
        ;delay   ;Necessary?
        ;;Bank=0, DI=I=0, both CS, RST=1
        ;LDA #LCD_RST
        ;STA PORT_B
        ;LatchLoad
        ;delay   ;Necessary?
        ;LDA #0 ;Both CS
        ;LDY #LCD_ON
        ;LCD_Instruction
        ;LDA #0 ;Both CS
        ;LDY #LCD_Z
        ;LCD_Instruction

        ;LDY #0
        ;.loop:
        ;    LDA #0  ;Both CS
        ;    LCD_Data
        ;    INY
        ;    BNE .loop
        
        ;.done:
        ;    STY PORT_B
        ;    INY
        ;    JMP .done

        ;Test 213 - based on 212
        ;Set Z only, write Y to screen - good
        ;Set X, Y, Z, reset ROW with mem addres 0
        ; - X, Y, Z good but doesn't step rows. RAM problem?
        ; - no, ANDed instead of ORed in row - see below
        ;Write Y to RAM before writing to LCD - good!
        ;Fix ROW command - OR in instead of AND
        ; - Also add counter to pattern.
        ; - good!

        ;Set up pins
        LDA #0 ;LCD_E low, RW=W=0, latch cp low
        STA PORT_A
        LDA #(LCD_E|LCD_RW|LATCH_CP)
        STA PORT_A_DIR
        LDA #$FF
        STA PORT_B_DIR

        ;Reset LCD
        LDA #0 ;Bank=0, DI=I=0, both CS, RST=0
        STA PORT_B
        LatchLoad
        delay   ;Necessary?
        LDA #LCD_RST ;Bank=0, DI=I=0, both CS, RST=1
        STA PORT_B
        LatchLoad
        delay   ;Necessary?

        ;LCD on
        LDA #LCD_BOTH
        LDY #LCD_ON
        LCD_Instruction

        ;Set coordinates
        LDA #LCD_BOTH
        LDY #LCD_ROW
        LCD_Instruction
        LDA #LCD_BOTH
        LDY #LCD_COL
        LCD_Instruction
        LDA #LCD_BOTH
        LDY #LCD_Z
        LCD_Instruction

        LDA #0
        STA 0
        .row_loop:
            LDA 0
            ORA #LCD_ROW
            TAY
            LDA #LCD_BOTH
            LCD_Instruction
            LDX #64
            .loop:
                CLC
                TXA
                ADC 0
                TAY
                LDA #LCD_BOTH
                LCD_Data
                DEX
                BNE .loop
            INC 0
            LDA 0
            CMP #8
            BNE .row_loop
        
        .done:
            STY PORT_B
            INY
            JMP .done

	END

;Insertion point for string literals
;(should come after all instances of CALL)
;=========================================
	STRING_LITERALS

	code_end:
	
