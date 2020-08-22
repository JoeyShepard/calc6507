;Output functions
;================

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
		
		CALL MemCopy,source,#R0,#9
		
		LDA #' '
		STA sign
		LDY #6
		LDA (source),Y
		CMP #$50
		BCC .positive
			LDA #'-'
			STA sign
			CALL BCD_Reverse, #R0+1, #6
		.positive:
		
		CALL LCD_char, sign
				
		LDY #6
		LDA R0,Y
		STA arg
		CALL DigitHigh, arg
		
		CALL LCD_char, #'.'
		CALL DigitLow, arg
		LDA #5
		STA index
		.loop:
			LDY index
			LDA R0,Y
			STA arg
			CALL DigitHigh, arg
			CALL DigitLow, arg
			DEC index
			LDA index
			CMP #2
			BNE .loop
		LDA #'+'
		STA sign
		LDY #8
		LDA (source),Y
		CMP #$50
		BCC .positive_e
			LDA #'-'
			STA sign
			CALL BCD_Reverse, #R0+7, #2
		.positive_e:
		CALL LCD_char,sign
		LDY #8
		LDA R0,Y
		STA arg
		CALL DigitLow, arg
		LDY #7
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
		
		TXA
		CLC
		ADC #(4*OBJ_SIZE)
		STA address
		LDA #0
		STA address+1
		
		CALL LCD_clrscr
		CALL LCD_print, "RAD"
		
		MOV #'5',character
		MOV #5,counter
		
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
					CALL DrawString, address
					JMP .item_done
				.not_str:
				CMP #OBJ_HEX
				BNE .not_hex
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
		LDA screen_ptr+1
		CLC
		ADC #20
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
	
	FUNC ErrorMsg
		ARGS
			STRING msg
		END
		
		LDA #ERROR_X
		STA screen_ptr
		LDA #ERROR_Y
		STA screen_ptr+1
		CALL LCD_print, "bbbbbbbbbbbb"
		LDA #ERROR_X
		STA screen_ptr
		LDA #ERROR_Y+CHAR_HEIGHT
		STA screen_ptr+1
		MOV.B #$FF,font_inverted
		CALL LCD_print, msg
		LDA #ERROR_X
		STA screen_ptr
		LDA #ERROR_Y+CHAR_HEIGHT*2
		STA screen_ptr+1
		CALL LCD_print, "bbbbbbbbbbbb"
		MOV.B #0,font_inverted
		
		.loop:
			CALL ReadKey
			CMP #KEY_ENTER
			BNE .loop
		RTS
	END
	
	