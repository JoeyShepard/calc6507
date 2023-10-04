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
		
        IF FALSE
		JSR StackAddItem
        JSR CODE_FREE+EXEC_HEADER
		ENDIF

		TXA
		STA address
		LDA #0
		STA address+1
		
		CALL LCD_clrscr

        LDA keys_alpha
        BEQ .no_alpha
            LDA #CHAR_WIDTH*19
            CALL LCD_Col
            ;LSB is on top to match hardware LCD
            CALL LCD_Byte,#$FF
            MOV #$FF,font_inverted
            CALL LCD_char, #'A'
            MOV #0,font_inverted
        .no_alpha:

        IF FALSE

        TODO: magic number
        LDA #CHAR_WIDTH*6
        CALL LCD_Col
		CALL LCD_char, #'['
		CALL DrawHex, address
		CALL LCD_print, " FREE]"
	
		JSR CODE_DROP+EXEC_HEADER
		
        ENDIF

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
            CALL LCD_Col
            LDA #6
            SEC
            SBC counter
            CALL LCD_Row
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

        ;Draw line
        LDA #0
        CALL LCD_Col
        LDA #6
        CALL LCD_Row
        MOV #SCREEN_WIDTH_LOGICAL,counter
        .line_loop:
            CALL LCD_Byte,#$10
            DEC counter
            BNE .line_loop
	END
		
	
