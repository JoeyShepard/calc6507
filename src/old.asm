;Copies of functions that worked with NASM/optimizer combo before being replaced with VM functions
;Generally, better to rely on source control but need to keep copy handy for testing

;NOT TO BE INCLUDED IN MAIN PROJECT

	;emu6507.asm
	;===========
	FUNC setup
		SEI
		CLD
		
		;Only use bottom 48 bytes of stack
		;May need a lot more for R stack
		PLA
		STA 0
		PLA
		STA 1
		TODO: expand this - will need a lot of stack space
		LDX #R_STACK_SIZE-1
		TXS
		LDA 1
		PHA
		LDA 0
		PHA
		
		;Stack grows down
		LDX #0
		STX stack_count
		
		LDA #0
		STA font_inverted
		
		MOV.W #font_table,font_ptr
		
		LDA #dict_begin % 256
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
		
		;Point to RAM so tests can run
		;Emulator only!
		MOV #BANK_GEN_RAM2,RAM_BANK2		
		MOV #BANK_GEN_RAM3,RAM_BANK3		
	END

	
	FUNC GfxSetup
		
		;Emulator only!
		MOV #BANK_GFX_RAM1,RAM_BANK2		
		MOV #BANK_GFX_RAM2,RAM_BANK3		
	END
	
	FUNC ReadKey
		LDA KB_INPUT
	END
	
	FUNC LCD_clrscr
		VARS
			BYTE counter
		END
		
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
		IF_LT
			RTS
		END_IF
		
		CMP #'e'+1	
		IF_GE
			RTS
		END_IF
		
		SEC
		SBC #32
		STA pixel_ptr
		LDA #0
		STA pixel_ptr+1
	
		LDA pixel_ptr
		ASL pixel_ptr
		;ROL pixel_ptr+1	;highest char <128
		ASL pixel_ptr
		ROL pixel_ptr+1
		;CLC ;16-bit can't overflow
		ADC pixel_ptr
		STA pixel_ptr
		BCC .no_C
			INC pixel_ptr+1
		.no_C:
		
		TODO: remove after debugging
		;CLC
		;LDA #font_table % 256
		;ADC pixel_ptr
		;STA pixel_ptr
		;LDA #font_table / 256
		;ADC pixel_ptr+1
		;STA pixel_ptr+1
		
		CLC
		LDA font_ptr
		ADC pixel_ptr
		STA pixel_ptr
		LDA font_ptr+1
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
		
		;blank line after character
		;looks fine on actual LCD since room around edge
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
	
	VM_func_begin:
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
	VM_func_end:

	;output.asm
	;==========
	FUNC DigitHigh
		ARGS
			BYTE digit
		END
		
		LDA digit
		LSR
		LSR
		LSR
		LSR
		CLC
		ADC #'0'
		STA digit
		CALL LCD_char, digit
	END
	
	FUNC DigitLow
		ARGS
			BYTE digit
		END
		
		LDA digit
		AND #$F
		CLC
		ADC #'0'
		STA digit
		CALL LCD_char, digit
	END
	
	FUNC DrawFloat
		ARGS
			WORD source
		VARS
			BYTE index, arg, sign
			WORD buff
		END
		
		INC.W source
		CALL MemCopy,source,#R0,#8
		
		LDA #' '
		STA sign
		LDY #EXP_HI-1
		LDA (source),Y
		AND #SIGN_BIT
		BEQ .positive
			;LDA #CHAR_MINUS
			LDA #'-'
			STA sign
		.positive:
		
		CALL LCD_char, sign
				
		LDY #5
		LDA R0,Y
		STA arg
		CALL DigitHigh, arg
		
		CALL LCD_char, #'.'
		CALL DigitLow, arg
		LDA #4
		STA index
		.loop:
			LDY index
			LDA R0,Y
			STA arg
			CALL DigitHigh, arg
			CALL DigitLow, arg
			DEC index
			
			TODO: instead, adjust R0 above
			LDA index
			CMP #$FF
			
			BNE .loop
		LDA #'+'
		STA sign
		LDY #EXP_HI-1
		LDA (source),Y
		AND #E_SIGN_BIT
		BEQ .positive_e
			;LDA #CHAR_MINUS
			LDA #'-'
			STA sign
		.positive_e:
		CALL LCD_char,sign
		LDY #7
		LDA R0,Y
		STA arg
		CALL DigitLow, arg
		LDY #6
		LDA R0,Y
		STA arg
		CALL DigitHigh, arg
		CALL DigitLow, arg
			
	END
	
	FUNC HexHigh
		ARGS
			BYTE digit
		VARS
			BYTE arg
		END
		
		LDA digit
		LSR
		LSR
		LSR
		LSR
		CMP #$A
		BCC .print_digit
			CLC
			ADC #'A'-10
			STA arg
			JMP .done
		.print_digit:
			CLC
			ADC #'0'
			STA arg
		.done:
		CALL LCD_char, arg
	END
	
	FUNC HexLow
		ARGS
			BYTE digit
		VARS
			BYTE arg
		END
		
		LDA digit
		AND #$F
		CMP #$A
		BCC .print_digit
			CLC
			ADC #'A'-10
			STA arg
			JMP .done
		.print_digit:
			CLC
			ADC #'0'
			STA arg
		.done:
		CALL LCD_char, arg
	END
	
	FUNC DrawHex
		ARGS
			WORD source
		VARS
			BYTE arg
		END
		
		CALL LCD_char, #'$'
		
		LDY #2
		LDA (source),Y
		STA arg
		CALL HexHigh, arg
		CALL HexLow, arg
		LDY #1
		LDA (source),Y
		STA arg
		CALL HexHigh, arg
		CALL HexLow, arg
	END
	
	FUNC DrawString
		ARGS
			WORD source
		VARS
			BYTE arg
			BYTE index
		END

		CALL LCD_char, #CHAR_QUOTE
		
		LDA #1
		STA index
		.loop:
			LDY index
			LDA (source),Y
			BEQ .done
			STA arg
			CALL LCD_char, arg
			INC index
			LDA index
			CMP #9
			BNE .loop
		.done:
		CALL LCD_char, #CHAR_QUOTE
	END
		
	FUNC DrawStack
		VARS
			BYTE character
			BYTE counter
			WORD address
		END
		
		JSR StackAddItem
		JSR CODE_FREE+EXEC_HEADER
		
		TXA
		STA address
		LDA #0
		STA address+1
		
		TODO: stack usage in status? battery? takes up more room though
		
		TODO: shrink
		CALL LCD_clrscr
		LDA #CHAR_WIDTH*8
		STA screen_ptr
		CALL LCD_char, #'['
		CALL DrawHex, address
		CALL LCD_print, " FREE]"
		
		JSR CODE_DROP+EXEC_HEADER
		
		MOV #'5',character
		MOV #5,counter
		
		TXA
		CLC
		ADC #(4*OBJ_SIZE)
		STA address
		LDA #0
		STA address+1
		
		.loop:
			LDA #0
			STA screen_ptr
			LDA screen_ptr+1
			CLC
			ADC #CHAR_HEIGHT
			STA screen_ptr+1
			CALL LCD_char, character
			CALL LCD_char, #':'
			
			DEC counter
			LDA counter
			CMP stack_count
			BCS .no_item
				LDY #0
				LDA (address),Y
				CMP #OBJ_FLOAT
				BNE .not_float
					CALL DrawFloat, address
					JMP .item_done
				.not_float:
				CMP #OBJ_STR
				BNE .not_str
					;one space after colon
					;LDA #CHAR_WIDTH*3
					;STA screen_ptr
					CALL DrawString, address
					JMP .item_done
				.not_str:
				CMP #OBJ_HEX
				BNE .not_hex
					;one space after colon
					;LDA #CHAR_WIDTH*3
					;STA screen_ptr
					CALL DrawHex, address
					JMP .item_done
				.not_hex:
				.item_done:
			.no_item:
			
			LDA address
			SEC
			SBC #OBJ_SIZE
			STA address
			
			DEC character
			LDA counter
			BNE .loop
		LDA #0
		STA screen_ptr
		
		TODO: 6th line of stack or status??? (would save code space)
		TODO: status=bytes free? auto complete? too much space :(
		TODO: option 1: line on bottom, status on top
		TODO: option 2: 6th line on top, status AND line on bottom
		;LDA screen_ptr+1
		;CLC
		;ADC #CHAR_HEIGHT
		;STA screen_ptr+1
		;CALL LCD_print, "--------------STATUS?"
		
		LDA screen_ptr+1
		CLC
		ADC #CHAR_HEIGHT*1.5
		STA screen_ptr+1
		LDY #0
		LDA #FG_COLOR
		.loop_line:
			STA (screen_ptr),Y
			INC screen_ptr+1
			STA (screen_ptr),Y
			DEC screen_ptr+1
			INY
			BNE .loop_line
	END
		