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
		CALL LCD_char,sign
				
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
		
		CALL LCD_print, "$", #FONT_NORMAL
		
		LDY #8
		LDA (source),Y
		STA arg
		CALL HexHigh, arg
		CALL HexLow, arg
		LDY #7
		LDA (source),Y
		STA arg
		CALL HexHigh, arg
		CALL HexLow, arg
	END
		
	FUNC DrawStack
		VARS
			BYTE counter
			BYTE character
		END
		
		CALL LCD_clrscr
		
		CALL LCD_print, "RAD", #FONT_NORMAL
		
		MOV #'5',character
		MOV #211,counter
		.loop:
			LDA #0
			STA screen_ptr
			LDA screen_ptr+1
			CLC
			ADC #CHAR_HEIGHT
			STA screen_ptr+1
			CALL LCD_char,character
			CALL LCD_char,#':'
			DEC character
			LDA counter
			CLC
			ADC #9
			STA counter
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
	