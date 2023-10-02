;Initial setup
;=============
    PAGE 0      ;Unlimited lines per page
    BANKING ON  ;Turn on BCALL support for banked calls

;Included files - no ROM space
;=============================
	include macros.asm
    include riot.asm
    include const.asm           ;Shared between both versions
    include const_hardware.asm  ;Hardware version only

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
	
;Banked ROM
;==========
    ;Bank 1    
    ORG BANK1_ADDRESS
    PHASE BANKED_EEPROM

        ;So far, worked with hardware in fixed and font in banked but not like below
        include hardware.asm
        font_table:
        include font_5x8_flipped.asm
        include font_custom_flipped.asm

    EQU BANK1_END,*
    DEPHASE

    ;Bank 2
    ORG BANK2_ADDRESS
    PHASE BANKED_EEPROM


    EQU BANK2_END,*
    DEPHASE

    ;Bank 3
    ORG BANK3_ADDRESS
    PHASE BANKED_EEPROM


    EQU BANK3_END,*
    DEPHASE

    ;Bank 4
    ORG BANK4_ADDRESS
    PHASE BANKED_EEPROM


    EQU BANK4_END,*
    DEPHASE

;Fixed ROM
;=========
	ORG FIXED_EEPROM
    banking_begin:
    include banking.asm
    banking_end:

    size_check_begin:
    size_check_end:

    FUNC setup
        SEI        
        CLD
        ;Stack
        LDX #$FF
        TXS
        ;RIOT pins
        LDA #0 ;LCD_E low, RW=W=0, latch cp low
        STA PORT_A
        LDA #(LCD_E|LCD_RW|LATCH_CP)
        STA PORT_A_DIR
        LDA #$FF
        STA PORT_B_DIR
        ;Banking
        CALL SetBank, #BANK1
        ;Alpha keys
        LDA #0
        STA keys_alpha
        
        ;Fixed return address since stack pointer set above
        JMP main.setup_return
    END

    ;Better to make this macro but can't access sys_bank from macro
    FUNC SetBank
        ARGS
            BYTE bank
        END
        
        LDA bank
        STA sys_bank
        ORA #LCD_RST
        STA PORT_B
        LatchLoad
    END

	FUNC main BEGIN
        VARS
            BYTE arg
        END
        
        CALL setup
        .setup_return:
        CALL LCD_Setup
        CALL LCD_clrscr

        LDA #0
        STA arg
        JMP .draw

        .loop:
            CALL ReadKey
            BEQ .loop
            STA arg
            .draw:
            CALL LCD_clrscr
            CALL LCD_print,"TESTING"

            LDA #0
            CALL LCD_Col
            LDA #1
            CALL LCD_Row
            CALL LCD_char, arg
            LDA keys_alpha
            BEQ .not_alpha
                LDA #120
                CALL LCD_Col
                LDA #'A'
                STA arg
                CALL LCD_char, arg
            .not_alpha:

            JMP .loop

        .done:
            STY PORT_B
            INY
            JMP .done

	END

;Insertion point for string literals
;(should come after all instances of CALL)
;=========================================
	STRING_LITERALS

;Current time (for confirming EEPROM data)
;=========================================
    FCC TIME

	code_end:
	
