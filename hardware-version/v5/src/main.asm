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

;Variables in zero page
;======================
    ORG $0000
    include zp.asm

;Variables in main RAM
;=====================
    ORG HW_STACK_BEGIN+R_STACK_SIZE
    include globals.asm

;Reset vectors in ROM
;====================
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
    include hardware.asm
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

        CALL ReadKey

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
	
