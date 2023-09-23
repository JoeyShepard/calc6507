;Constants
;=========
;LCD commands
LCD_ON          = $3F
LCD_ROW         = $B8
LCD_COL         = $40
LCD_Z           = $C0

;LCD constants
LCD_BOTH        = 0
LCD_LEFT        = $20
LCD_RIGHT       = $10

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

    ;Row in A
    FUNC LCD_Col
        ORA #LCD_COL
        TAY
        LDA #LCD_BOTH
        JMP LCD_Instruction
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
        LDY #LCD_Z
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
    END

    ;Old - known working. does not rely on optimizer.
    LCD_Test:
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
