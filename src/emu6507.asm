;I/O and setup for emulator
;==========================
    ;Screen	
	equ BG_COLOR,	        $2A
	equ FG_COLOR,	        $0
	equ SCREEN_ADDRESS,		$4000
	equ SCREEN_WIDTH,		256
	equ SCREEN_HEIGHT,		128
	equ CHAR_WIDTH,			12
	equ CHAR_HEIGHT, 		16
    equ WORDS_Y,            7

	special_chars:
	FCB CHAR_QUOTE
    FCB ":;[],"
    FCB "'<=>^"
    FCB "$E"    ;E = EE
    FCB "A/"    ;A = alpha
    FCB "S!*"   ;S = store arrow
    FCB "@?_-"
    FCB ". +"
	equ SPECIAL_CHARS_LEN, *-special_chars

	FUNC setup
		SEI
		CLD
		
		;Fill RAM with $FF for debugging
		PLA
		STA 2
		PLA
		STA 3
		LDA #0
		STA 0
		STA 1
		LDY #4
		.loop_begin:
		LDA #$FF
		.loop:
			STA (0),Y
			INY
			BNE .loop
		INC 1
		LDA 1
		CMP #9
		BNE .loop_begin
		
		;Only use bottom 48 bytes of stack
		;May need a lot more for R stack
		TODO: expand this - will need a lot of stack space
		LDX #R_STACK_SIZE-1
		TXS
		LDA 3
		PHA
		LDA 2
		PHA
		
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

        ;Alpha not used in emulator version but check functionality
        LDA #0
        STA keys_alpha
		
		;Point to RAM so tests can run
		;Emulator only!
		MOV #BANK_GEN_RAM2,RAM_BANK2		
		MOV #BANK_GEN_RAM3,RAM_BANK3		
	    
        LDA #$42    ;Debug null handling
        STA null

	END

	FUNC GfxSetup
		
		;Emulator only!
		MOV #BANK_GFX_RAM1,RAM_BANK2		
		MOV #BANK_GFX_RAM2,RAM_BANK3		
	END

	FUNC ReadKey
		LDA KB_INPUT
       
        ;Enter key
        ;=========
        ;KEY_ENTER defined as 13 in src/const.asm which works in Windows
        ;when loading key input from file, but newline in Linux is just 10, 
        ;so doesn't work when loading key input in Linux.
        ;Confirmed editing existing key input file from Linux with notepad 
        ;in Windows doesn't insert 13, so ok to edit existing files but
        ;not to create file on Windows.
        ;Check for 13 and 10 below, though note could cause problems if
        ;keys.txt created in Windows as would be read as two new lines.
        CMP #KEY_ENTER
        BEQ .key_enter
        CMP #KEY_ENTER_ALT
        BNE .not_enter
            .key_enter:
            RTS
        .not_enter:

        ;Backspace
        CMP #KEY_BACKSPACE
        BNE .not_backspace
            RTS
        .not_backspace:

        ;Alpha
        ;(Not useful on emu but test here for hardware)
        CMP #KEY_ALPHA
        BNE .not_alpha
            RTS
        .not_alpha:

        ;Special character
        LDY #0
        .special_loop:
            CMP special_chars,Y
            BNE .special_next
                
                ;;Recode m for minus as c since c assigned to minus sign
                ;CMP #'m'
                ;BNE .key_done
                ;	LDA #CHAR_MINUS
                ;	STA arg
                
                ;Recode uppercase S for STO as d which is store arrow. s is letter s
                CMP #'S'
                BNE .key_E
                    LDA #CHAR_STO
                    RTS

                ;Recode uppercase E for exponent. e is letter e
                .key_E:
                CMP #'E'
                BNE .key_A
                    LDA #CHAR_EXP
                    RTS

                ;Recode uppercase A for alpha
                .key_A:
                CMP #'A'
                BNE .special_done
                    LDA #KEY_ALPHA
                    RTS
                
                .special_done:
                RTS

            .special_next:
            INY
            CPY #SPECIAL_CHARS_LEN
            BNE .special_loop
        
        ;Number
        CMP #'0'
        BCC .not_num
        CMP #'9'+1
        BCS .not_num
            RTS
        .not_num:
        
        ;Uppercase
        CMP #'A'
        BCC .not_upper
        CMP #'Z'+1
        BCS .not_upper
            RTS
        .not_upper:
        
        ;Lowercase
        CMP #'a'
        BCC .not_lower
        CMP #'z'+1
        BCS .not_lower
            ;Convert to uppercase
            SEC
            SBC #$20
            RTS
        .not_lower:
        
        ;No matches found - return 0
        LDA #0

	END

	FUNC LCD_clrscr
		VARS
			BYTE counter
		END
	
        LDA #0
        STA font_inverted
		MOV.W #SCREEN_ADDRESS, screen_ptr
		;Rows on screen
		MOV #128, counter
		LDA #BG_COLOR
		LDY #0
		.loop:
			STA (screen_ptr),Y
			INY
			BNE .loop
			INC screen_ptr+1
			DEC counter
			BNE .loop
		MOV.W #SCREEN_ADDRESS, screen_ptr
	END

	FUNC LCD_char
		ARGS
			BYTE c_out
		VARS
			WORD pixel_ptr
			BYTE pixel_index
			BYTE pixel
			BYTE lc1, lc2
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
        LDA #font_table # 256
        ADC pixel_ptr
        STA pixel_ptr
        LDA #font_table / 256
        ADC pixel_ptr+1
        STA pixel_ptr+1

		;LDA #0
		;STA pixel_index
		LDA #5
		STA lc1
		STA pixel_index
		.loop:
			LDA #8
			STA lc2
			;LDY pixel_index
			;INC pixel_index
			DEC pixel_index
			LDY pixel_index
			LDA (pixel_ptr),Y
			EOR font_inverted
			STA pixel
			LDY #0
			.loop.inner:
				ASL pixel
				LDA #FG_COLOR
				BCS .color
					LDA #BG_COLOR
				.color:
				STA (screen_ptr),Y
				INY
				STA (screen_ptr),Y
				INC screen_ptr+1
				STA (screen_ptr),Y				
				DEY
				STA (screen_ptr),Y
				INC screen_ptr+1
				DEC lc2
				BNE .loop.inner
			INC screen_ptr
			INC screen_ptr
			
			LDA screen_ptr+1
			SEC
			SBC #16
			STA screen_ptr+1
			
			DEC lc1
			BNE .loop	
		
		;Blank line after character
		;Looks fine on actual LCD since room around edge
		LDA #16
		STA lc1
		LDA #BG_COLOR
		LDY font_inverted
		BEQ .no_inv
			LDA #FG_COLOR
		.no_inv:
		LDY #0
		.blank_loop:
			STA (screen_ptr),Y
			INY
			STA (screen_ptr),Y
			DEY
			INC screen_ptr+1
			
			DEC lc1
			BNE .blank_loop
		
		INC screen_ptr
		INC screen_ptr
		LDA screen_ptr+1
		SEC 
		SBC #16
		STA screen_ptr+1

	END
    
	FUNC LCD_print
		ARGS
			STRING source
		VARS
			BYTE index, arg
		END
		
		LDA #0
		STA index
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
	
    ;Col in A
    FUNC LCD_Col
        STA screen_ptr
    END

    ;Row in A
    FUNC LCD_Row
        ;Multiply by CHAR_HEIGHT - 16 for emu
        ASL
        ASL
        ASL
        ASL
        CLC
        ADC #hi(SCREEN_ADDRESS)
        STA screen_ptr+1
    END
    
    FUNC LCD_Byte
        ARGS
            BYTE data
        VARS
            BYTE counter
        END

        MOV #8,counter
        LDY #0
        .loop:
            LDA #FG_COLOR
            LSR data
            BCS .draw_fg
                LDA #BG_COLOR
            .draw_fg:
            STA (screen_ptr),Y
            INY
            STA (screen_ptr),Y
            INC screen_ptr+1
            STA (screen_ptr),Y
            DEY
            STA (screen_ptr),Y
            INC screen_ptr+1
            DEC counter
            BNE .loop
        LDA screen_ptr+1
        SEC
        SBC #CHAR_HEIGHT
        STA screen_ptr+1
        INC screen_ptr
        INC screen_ptr
    END

    FUNC GetTimer
        LDA TIMER_S
    END

