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
        include hardware.asm    
        include output.asm      
        include forth.asm       
        include forth_loop.asm  
        include error.asm       
        include bank1.asm
    EQU BANK1_END,*
    DEPHASE

    ;Bank 2
    ORG BANK2_ADDRESS
    PHASE BANKED_EEPROM
        include math.asm        
        include cordic.asm      
        include bank2.asm
    EQU BANK2_END,*
    DEPHASE

    ;Bank 3
    ORG BANK3_ADDRESS
    PHASE BANKED_EEPROM
        include words.asm 
        include aux_stack.asm
    EQU BANK3_END,*
    DEPHASE

    ;Bank 4
    ORG BANK4_ADDRESS
    PHASE BANKED_EEPROM
        include bank4.asm
    EQU BANK4_END,*
    DEPHASE

;Fixed ROM
;=========
	ORG FIXED_EEPROM
    include banking.asm
	include system.asm
    include word_stubs.asm
    include bank_fixed.asm

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

        ;Jump to ForthLoop function and never return
        ;(Needs to be CALL for optimizer)
        CALL ForthLoop

	END

;Insertion point for string literals
;(should come after all instances of CALL)
;=========================================
	STRING_LITERALS

;Current time (for confirming EEPROM data)
;=========================================
    FCC TIME

	code_end:

