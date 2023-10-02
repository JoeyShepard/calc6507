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
	
;Functions in ROM
;================
    ;Bank 1    
    ORG BANK1_ADDRESS
    PHASE BANKED_EEPROM

        FUNC opt_test1
            LDA #'Z'
        END
        
    EQU BANK1_END,*
    DEPHASE

    ;Bank 2
    ORG BANK2_ADDRESS
    PHASE BANKED_EEPROM

        FUNC opt_test2
            LDA #'Y'
        END

    EQU BANK2_END,*
    DEPHASE

    ;Bank 3
    ORG BANK3_ADDRESS
    PHASE BANKED_EEPROM

        FUNC opt_test3
            LDA #'W'
            BCALL opt_test4
        END

    EQU BANK3_END,*
    DEPHASE

    ;Bank 4
    ORG BANK4_ADDRESS
    PHASE BANKED_EEPROM

        FUNC opt_test4
            CLC
            ADC #1
        END

    EQU BANK4_END,*
    DEPHASE

	ORG FIXED_EEPROM
   
    size_check_begin:
    
    include hardware.asm
    banking_begin:
    include banking.asm
    banking_end:
    font_table:
    include font_5x8_flipped.asm
    include font_custom_flipped.asm
	
    size_check_end:


;Main function
;=============
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

            LDA #0
            CALL LCD_Col
            LDA #2
            CALL LCD_Row

            CALL opt_test1  ;No banking change. Points to bank 1 at start up
            STA arg
            CALL LCD_char, arg

            BCALL opt_test2 ;Should switch banks, call, then return to here
            STA arg
            CALL LCD_char, arg

            BCALL opt_test3 ;Should switch banks twice, call twice, then return to here
            STA arg
            CALL LCD_char, arg


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
	
