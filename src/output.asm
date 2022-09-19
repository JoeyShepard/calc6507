;Output functions
;================

	FUNC DigitHighZ
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
	
	VM_func_begin:
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
	VM_func_end:
	
	FUNC DrawHex
		<VM
			12
			4 DO
				OVER OVER RSHIFT $F AND 
				DUP 10 < '0' CONST8 'A'-10 SELECT +
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
		TODO: strings appear more than once in table
		TODO: stack usage in status? battery? takes up more room though
		TODO: 3 way structure below should be more efficient
		
		<VM
			LCD_clrscr EXEC
			
			EXTERN
				CHAR_WIDTH*8+SCREEN_ADDRESS AS STATUS_X
			END
			STATUS_X screen_ptr !
			'[' LCD_char EXEC
			
			FNEW
			DO_FREE JSR
			FTOS FDROP
			DrawHex EXEC
			
			" \sFREE]" LCD_print EXEC
			
			EXTERN
				CHAR_HEIGHT*SCREEN_WIDTH AS STACK_LINE_HEIGHT
				CHAR_HEIGHT*SCREEN_WIDTH+SCREEN_ADDRESS AS STACK_X
				OBJ_SIZE*4 AS STACK_DRAW_OFFSET
				stack_count
			END
			
			STACK_X screen_ptr !
			FSP STACK_DRAW_OFFSET + 
			5 DO
				I DUP 1+ '0' + LCD_char EXEC
				':' LCD_char EXEC
				
				;I+1 on stack from above				
				stack_count C@ <
				IF
					DUP DUP C@
					1 DEBUG	
					
					DUP CONST8 OBJ_FLOAT IF
						DrawFloat 
					ELSE
						DUP CONST8 OBJ_STR IF
							DrawString
						ELSE
							DUP CONST8 OBJ_HEX IF
								DrawHex
							THEN
						THEN
					THEN
					;SWAP DROP EXEC
					SWAP DROP DROP
					
					0 DEBUG
				THEN
				CONST8 OBJ_SIZE -
				screen_ptr @ $FF00 AND STACK_LINE_HEIGHT + screen_ptr !
			LOOP
			DROP
			
			EXTERN
				SCREEN_ADDRESS+CHAR_HEIGHT*6.5*SCREEN_WIDTH AS STACK_LINE_Y
			END
			
			STACK_LINE_Y
			0 DO
				0 OVER ! 1+ 1+
			LOOP
			DROP	
		VM>
	END

		
	