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
    include zp.asm              ;Shared between both versions

;Variables in main RAM
;=====================
    ORG HW_STACK_BEGIN+R_STACK_SIZE
    include globals.asm         ;Shared between both versions

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
        include hardware.asm                ;|
        font_table:                         ;|-932 bytes combined
        include font_5x8_flipped.asm        ;|
        include font_custom_flipped.asm     ;|
        include output.asm                  ;657 bytes
        include forth.asm                   ;1793 bytes
        include forth_loop.asm              ;317 bytes
    EQU BANK1_END,*
    DEPHASE

    ;Bank 2
    ORG BANK2_ADDRESS
    PHASE BANKED_EEPROM
        include math.asm                    ;1416 bytes
        include cordic.asm                  ;1067 bytes
        include error.asm                   ;346 bytes
    EQU BANK2_END,*
    DEPHASE

    ;Bank 3
    ORG BANK3_ADDRESS
    PHASE BANKED_EEPROM
        include aux_stack.asm       ;54 bytes
        include word_stubs.asm      ;289 bytes
    EQU BANK3_END,*
    DEPHASE

    ;Bank 4
    ORG BANK4_ADDRESS
    PHASE BANKED_EEPROM


    EQU BANK4_END,*
    DEPHASE

;Fixed ROM
;=========

    ;Space past used memory. Put code here while
    ;arranging in banks
    ORG $C000

    ;Sizes are when when started moving to banking - may increase
    include words.asm           ;4389 bytes
        ;words 1230

    ;size_check_begin:
    ;size_check_end:

	ORG FIXED_EEPROM
    banking_begin:
    include banking.asm
    banking_end:
	include system.asm          ;13 bytes

    FUNC setup
        SEI        
        CLD

        ;Stack
        LDX #R_STACK_SIZE-1
        TXS

		;Stack grows down
		LDX #0
		STX stack_count
		
		LDA #0
		STA font_inverted
		
		LDA #dict_begin # 256
		STA dict_ptr
		STA dict_save
		LDA #dict_begin / 256
		STA dict_ptr+1
		STA dict_save+1
		
		LDA #0
		STA dict_begin
		STA dict_begin+1
		STA dict_begin+2
		
		LDA #MODE_IMMEDIATE
		STA mode
        
        ;Alpha keys
        LDA #0
        STA keys_alpha

        ;RIOT pins
        LDA #0 ;LCD_E low, RW=W=0, latch cp low
        STA PORT_A
        LDA #(LCD_E|LCD_RW|LATCH_CP)
        STA PORT_A_DIR
        LDA #$FF
        STA PORT_B_DIR

        ;Banking
        CALL SetBank, #BANK1
        
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
            LDA #2
            CALL LCD_Row
            CALL LCD_Byte, #$A9

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

            ;Jump to ForthLoop function and never return
            ;(Needs to be CALL for optimizer)
            ;CALL ForthLoop

	END

;Insertion point for string literals
;(should come after all instances of CALL)
;=========================================
	STRING_LITERALS

;Current time (for confirming EEPROM data)
;=========================================
    FCC TIME

	code_end:

