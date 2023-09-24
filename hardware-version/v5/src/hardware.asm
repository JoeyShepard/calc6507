;Hardware specific functions
;===========================


;Constants
;=========
;LCD commands
LCD_ON          = $3F
LCD_ROW         = $B8
LCD_COL         = $40
LCD_Z           = $C0

;LCD CS
LCD_BOTH        = 0
LCD_LEFT        = $20
LCD_RIGHT       = $10

;LCD Constants
LCD_WIDTH       = 128   ;Note SCREEN_WIDTH is 256 for emulator
LCD_HEIGHT      = 64

;Macros
;======
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

;Functions
;=========
    ;CS in A
    ;Data in Y
    FUNC LCD_Data
        EOR #LCD_DI|LCD_RST
        STA PORT_B
        LatchLoad

        STY PORT_B
        LCD_Pulse
    END

    ;CS in A
    ;Data in Y
    FUNC LCD_Instruction
        EOR #LCD_RST ;DI=I=0
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
        CMP #LCD_WIDTH/2
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
            SBC #LCD_WIDTH/2
            ORA #LCD_COL
            TAY
            LDA #LCD_RIGHT
            CALL LCD_Instruction
            LDA #LCD_RIGHT
        .done:
        STA screen_ptr+1
    END

    FUNC LCD_Setup
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
            CMP #SCREEN_HEIGHT/2
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

    ;Old - known working. does not rely on optimizer.
    LCD_Test1:
        LDA #0
        STA 0
        .row_loop:
            LDA 0
            ORA #LCD_ROW
            TAY
            LDA #LCD_BOTH
            JSR LCD_Instruction
            LDX #64
            .loop:
                CLC
                TXA
                ADC 0
                TAY
                LDA #LCD_BOTH
                JSR LCD_Data
                DEX
                BNE .loop
            INC 0
            LDA 0
            CMP #8
            BNE .row_loop

        RTS

    LCD_Test2:
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
