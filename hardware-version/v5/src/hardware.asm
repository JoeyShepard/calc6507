;Hardware specific functions
;===========================

;Data
;====
keypad_table:
    FCB "ABCDE"
    FCB ":;[],"
    FCB "'<=>^"
    FCB KEY_ENTER,"$\"ed"   ;e=exponent, a=left arrow
    FCB 0,"789/"
    FCB "d456*"             ;d=store arrow
    FCB "@123-"
    FCB KEY_ON,"0. +"

keypad_alpha_table:
    FCB "ABCDE"
    FCB "FGHIJ"
    FCB "KLMNO"
    FCB KEY_ENTER,"PQRa"    ;a=left arrow
    FCB 0,"STU/"
    FCB "!VWX*"
    FCB "?YZ_-"
    FCB KEY_ON,"0. +"

;Functions
;=========
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

    ;CS in A
    ;Data in Y
    FUNC LCD_Data
        ORA #LCD_DI|LCD_RST
        ORA sys_bank
        STA PORT_B
        LatchLoad

        STY PORT_B
        LCD_Pulse
    END

    ;CS in A
    ;Data in Y
    FUNC LCD_Instruction
        ORA #LCD_RST ;DI=I=0
        ORA sys_bank
        STA PORT_B
        LatchLoad

        STY PORT_B
        LCD_Pulse
    END

    ;Row in A
    FUNC LCD_Row
        ORA #LCD_ROW
        TAY
        LDA #LCD_BOTH
        JMP LCD_Instruction
    END

    ;Col in A
    FUNC LCD_Col
        STA screen_ptr
        CMP #SCREEN_WIDTH/2
        BCS .right_side
            ;Left LCD
            ORA #LCD_COL
            TAY
            LDA #LCD_LEFT
            CALL LCD_Instruction
            LDY #LCD_COL|0
            LDA #LCD_RIGHT
            CALL LCD_Instruction
            LDA #LCD_LEFT
            BNE .done
        .right_side:
            ;Right LCD
            SEC
            SBC #SCREEN_WIDTH/2
            ORA #LCD_COL
            TAY
            LDA #LCD_RIGHT
            CALL LCD_Instruction
            LDA #LCD_RIGHT
        .done:
        STA screen_ptr+1
    END

    FUNC LCD_Setup

        ;Reset LCD
        LDA #0 ;Bank=0, DI=I=0, both CS, RST=0
        ORA sys_bank
        STA PORT_B
        LatchLoad
        delay   ;Necessary?
        LDA #LCD_RST ;Bank=0, DI=I=0, both CS, RST=1
        ORA sys_bank
        STA PORT_B
        LatchLoad
        delay   ;Necessary?

        ;LCD on
        LDA #LCD_BOTH
        LDY #LCD_ON
        CALL LCD_Instruction

        ;Set coordinates
        LDA #0
        CALL LCD_Row
        LDA #0
        CALL LCD_Col
        LDA #LCD_BOTH
        LDY #LCD_Z|0
        CALL LCD_Instruction
    END

    FUNC LCD_clrscr
        VARS
            BYTE row_count,col_count
        END

        MOV #0, row_count
        .loop_outer:
            MOV #64, col_count
            LDA row_count
            CALL LCD_Row
            .loop_inner:
                LDA #LCD_BOTH
                LDY #0
                CALL LCD_Data
                DEC col_count
                BNE .loop_inner
            INC row_count
            LDA row_count
            CMP #CHAR_SCREEN_HEIGHT
            BNE .loop_outer
        LDA #0
        CALL LCD_Row
        LDA #0
        CALL LCD_Col
    END

    FUNC LCD_char
        ARGS
            BYTE c_out
        VARS
            WORD pixel_ptr
            BYTE char_counter
        END

		LDA c_out
		CMP #' '
		BCS .skip_gt
			RTS
		.skip_gt:
		
		CMP #'e'+1	
		BCC .skip_lt
			RTS
		.skip_lt:
		
		SEC
		SBC #32
		STA pixel_ptr
		LDA #0
		STA pixel_ptr+1
	
		LDA pixel_ptr
		ASL pixel_ptr
		;ROL pixel_ptr+1	;Highest char <128
		ASL pixel_ptr
		ROL pixel_ptr+1
		;CLC ;16-bit can't overflow
		ADC pixel_ptr
		STA pixel_ptr
		BCC .no_C
			INC pixel_ptr+1
		.no_C:

        CLC
        LDA #lo(font_table)
        ADC pixel_ptr
        STA pixel_ptr
        LDA #hi(font_table)
        ADC pixel_ptr+1
        STA pixel_ptr+1

        MOV #0, char_counter
        .loop_inner:
            LDY char_counter
            INC char_counter
            CPY #6
            BEQ .done
            CPY #5
            BNE .char_data
                LDA #0
                BEQ .write_data
            .char_data:
                LDA (pixel_ptr),Y 
            .write_data:
            TAY
            LDA screen_ptr+1
            CALL LCD_Data
            INC screen_ptr
            LDA screen_ptr
            CMP #SCREEN_WIDTH/2
            BNE .loop_inner
            ;Next byte will be on second half of LCD
            LSR screen_ptr+1 ;LCD_LEFT > LCD_RIGHT, ie $20 > $10
            BNE .loop_inner
        .done:
    END

    FUNC LCD_print
        ARGS
            STRING source
        VARS
            BYTE index, arg
        END

        MOV #0, index
        .loop:
			LDY index
			LDA (source),Y
			BEQ .done
			STA arg
			CALL LCD_char, arg
			INC index
			JMP .loop
		.done:
    END

    FUNC ReadKey
        VARS
            BYTE mask
            BYTE row_count,col_count
            BYTE key,cycles
        END
       
        MOV #0, key
        .loop_outer:
            MOV #7, row_count
            MOV #$7F, mask
            .loop:
                LDA mask
                STA PORT_B

                ;Worked fine then became unreliable. Added NOPS. No effect.
                ;Added delay loop instead. RIOT needs time to sink pull-up?
                LDY #KEY_SETTLE_CYCLES
                .delay_loop:
                    DEY
                    BNE .delay_loop

                LDA PORT_A
                AND #KEY_MASK
                CMP #KEY_MASK
                BEQ .continue
                    ;Key found
                    LDY #4
                    STY col_count
                    .key_loop:
                        LSR
                        BCS .no_match
                            ;Found column
                            LDA row_count
                            ASL
                            ASL
                            CLC
                            ADC row_count
                            ADC col_count
                            ADC #1
                            ;Debounce
                            STA key
                            MOV #0, cycles
                            JMP .loop_outer
                        .no_match:
                        DEC col_count
                        JMP .key_loop
                .continue:
                DEC row_count
                SEC
                ROR mask
                LDA mask
                CMP #$FF
                BNE .loop
            ;No key held down
            LDA key
            BNE .debounce
                ;No key found, return
                LDA #0
                RTS
            .debounce:
            INC cycles
            LDA cycles
            CMP #KEY_DEBOUNCE_CYCLES
            BNE .loop_outer

        ;Key debounced
        LDY key
        DEY
        CPY #KEY_ALPHA
        BNE .not_alpha
            ;Alpha pressed - invert state but return no key code
            LDA keys_alpha
            EOR #$FF
            STA keys_alpha
            LDA #0
            RTS
        .not_alpha:
        ;Return alpha or non-alpha key
        LDA keys_alpha
        BNE .alpha_key
            ;Non-alpha key
            LDA keypad_table,Y
            RTS
        .alpha_key:
            ;Alpha key
            LDA keypad_alpha_table,Y
            RTS
    END

    FUNC Delay1s
        VARS
            BYTE counter
        END

        LDY #0
        STY counter
        .delay_loop:
            NOP             ;2 cycles
            NOP             ;2 cycles
            NOP             ;2 cycles
            NOP             ;2 cycles
            NOP             ;2 cycles
            DEY             ;2 cycles
            BNE .delay_loop ;3 cycles
            DEC counter
            BNE .delay_loop
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

