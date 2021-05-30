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
		
		TODO: shrink
		CALL LCD_clrscr
		LDA #(CHAR_SCREEN_WIDTH-12)*CHAR_WIDTH+6	;len("[$xxxx FREE]"=12, 4=align to right side
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
	
	TODO: shorten messages?
	TODO: remove ending 0
	ERROR_MSG_INPUT:
	FCB " INPUT ERROR  ",0		;2
	ERROR_MSG_WORD_TOO_LONG:
	FCB "  INPUT SIZE  ",0		;4
	ERROR_MSG_STRING:
	FCB " STRING ERROR ",0		;6
	ERROR_MSG_STACK_OVERFLOW:
	FCB "STACK OVERFLOW",0		;8
	ERROR_MSG_STACK_UNDERFLOW:
	FCB "STACK UNDERFL ",0		;10
	ERROR_MSG_WRONG_TYPE:
	FCB "  WRONG TYPE  ",0		;12
	ERROR_MSG_DIV_ZERO:
	FCB "DIVIDE BY ZERO",0		;14
	ERROR_MSG_IMMED_ONLY:
	FCB "  IMMED ONLY  ",0		;16
	ERROR_MSG_COMPILE_ONLY:
	FCB " COMPILE ONLY ",0		;18
	ERROR_MSG_OUT_OF_MEM:
	FCB "OUT OF MEMORY ",0		;20
	ERROR_MSG_STRUCTURE:
	FCB "  STRUCTURE   ",0		;22
	ERROR_MSG_RANGE:
	FCB " RANGE ERROR  ",0		;24
	
	TODO: table smaller than fixed length strings?
	ERROR_TABLE:
		FDB	ERROR_MSG_INPUT
		FDB ERROR_MSG_WORD_TOO_LONG
		FDB ERROR_MSG_STRING
		FDB ERROR_MSG_STACK_OVERFLOW
		FDB ERROR_MSG_STACK_UNDERFLOW
		FDB ERROR_MSG_WRONG_TYPE
		FDB ERROR_MSG_DIV_ZERO
		FDB ERROR_MSG_IMMED_ONLY
		FDB ERROR_MSG_COMPILE_ONLY
		FDB ERROR_MSG_OUT_OF_MEM
		FDB ERROR_MSG_STRUCTURE
		FDB ERROR_MSG_RANGE
		
	TODO: adjust display and messages for new 5x8 font
	;error code in A
	FUNC ErrorMsg
		VARS
			WORD msg
		END
		
		;LDY error_code
		TAY
		LDA ERROR_TABLE-2,Y
		STA msg
		LDA ERROR_TABLE-1,Y
		STA msg+1
		
		LDA #ERROR_X
		STA screen_ptr
		LDA #ERROR_Y
		STA screen_ptr+1
		CALL LCD_print, "bbbbbbbbbbbbbb"
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
		CALL LCD_print, "bbbbbbbbbbbbbb"
		MOV.B #0,font_inverted
		
		halt
		
		.loop:
			CALL ReadKey
			CMP #KEY_ENTER
			BNE .loop
		RTS
	END
	
	