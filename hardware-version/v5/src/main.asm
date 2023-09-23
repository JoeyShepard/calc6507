;Unlimited lines per page
;========================
	PAGE 0

;Included files - no ROM space
;=============================
	include macros.asm
    include riot.asm
    include const.asm

;Constants
;=========
RESET_VECTOR    = $FFFC
FIXED_EEPROM    = $900

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
    include lcd.asm
    font_table:
    include font_5x8_flipped.asm
    include font_custom_flipped.asm
	
;Main function
;=============
	FUNC main BEGIN

        ;Probably not necessary but just in case
        SEI
        CLD
        LDX #$FF
        TXS

        CALL LCD_Setup
        CALL LCD_clrscr

        LDA #0
        STA 0
        LDA #5
        STA 1

        .loop:
            LDY 0
            LDA font_table+(65-32)*5,Y
            TAY
            LDA #LCD_LEFT
            CALL LCD_Data

            DEC 1
            BNE .no_space
                LDY #0
                LDA #LCD_LEFT
                CALL LCD_Data
                LDA #5
                STA 1
            .no_space:

            INC 0
            LDA 0
            CMP #30
            BNE .loop
        
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
	
