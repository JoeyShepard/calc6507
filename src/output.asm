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
		;STA digit
		;CALL LCD_char, digit
		JSR LCD_char_A
	END
	
	FUNC DigitLow
		ARGS
			BYTE digit
		END
		
		LDA digit
		AND #$F
		CLC
		ADC #'0'
		;STA digit
		;CALL LCD_char, digit
		JSR LCD_char_A
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
			LDA #'-'
			STA sign
		.positive:
		
		;CALL LCD_char, sign
		LDA sign
		JSR LCD_char_A
		
		LDY #5
		LDA R0,Y
		STA arg
		CALL DigitHigh, arg
		
		;CALL LCD_char, #'.'
		LDA #'.'
		JSR LCD_char_A
		
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
		
		;CALL LCD_char,sign
		LDA sign
		JSR LCD_char_A
		
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
	
	FUNC DrawHex
		<VM
			12
			4 DO
				OVER OVER RSHIFT $F AND '0' +
				LCD_char EXEC
				4 -
			LOOP DROP DROP
		VM>
	END
	
	FUNC DrawString
		ARGS
			WORD source
		VARS
			BYTE arg
			BYTE index
		END
		
		LDA #CHAR_QUOTE
		JSR LCD_char_A
		
		LDA #1
		STA index
		.loop:
			LDY index
			LDA (source),Y
			BEQ .done
			JSR LCD_char_A
			
			INC index
			LDA index
			CMP #9
			BNE .loop
		.done:
		LDA #CHAR_QUOTE
		JSR LCD_char_A
		
	END
	
	FUNC DrawStack
		VARS
			BYTE character
			BYTE counter
			WORD address
		END
		
		TODO: strings appear more than once in table
		
		START HERE: cant reuse DO for while!
		
		<VM
			LCD_clrscr EXEC
			
			CONST8 CHAR_WIDTH*8 SCREEN_ADDRESS + screen_ptr !
			'[' LCD_char EXEC
			
			FNEW
			DO_FREE JSR
			FTOS FDROP
			DrawHex EXEC
			
			halt
			
			" \sFREE]" LCD_print EXEC
			halt
		VM>
		
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
		LDA #'['
		JSR LCD_char_A
		
		;CALL DrawHex, address
		
		<VM 
			" \sFREE]" LCD_print EXEC FDROP
		VM>
		
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
			
			LDA character
			JSR LCD_char_A
			LDA #':'
			JSR LCD_char_A
			
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
					
					TODO: Make sure it works
					;CALL DrawHex, address
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
	
		
	