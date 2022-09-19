;Output functions
;================
	FUNC DigitHigh
		<VM
			4 RSHIFT '0' + LCD_char EXEC
		VM>
	END
	
	FUNC DigitLow
		<VM
			$F AND '0' + LCD_char EXEC
		VM>
	END
	
	FUNC DrawFloat
		<VM
			1+ DUP CONST8 EXP_HI-1 + C@ CONST8 SIGN_BIT AND
			'-' '\s' SELECT LCD_char EXEC
			DUP 5 + C@ DUP DigitHigh EXEC
			'.' LCD_char EXEC
			DigitLow EXEC
			4 +
			5 DO
				DUP C@ DUP 
				DigitHigh EXEC DigitLow EXEC
				1 -
			LOOP
			CONST8 EXP_HI + DUP C@ DUP CONST8 E_SIGN_BIT AND
			'-' '+' SELECT LCD_char EXEC
			DigitLow EXEC
			1 - C@ DUP DigitHigh EXEC DigitLow EXEC
		VM>		
	END
	
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
		<VM
			'"' LCD_char EXEC
			0
			BEGIN
				SWAP 1+ SWAP
				OVER C@ DUP IF		;address count char
					LCD_char EXEC
					1+ DUP 8 <
				ELSE
					DROP 0
				THEN
			WHILE
			DROP DROP
			'"' LCD_char EXEC
		VM>
	END
	
	VM_func_begin:
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
					DUP CONST8 OBJ_HEX = IF
						DROP
						'$' LCD_char EXEC
						CONST8 HEX_SUM + @
						DrawHex
					ELSE
						1 - DrawString DrawFloat SELECT
					THEN
					EXEC
					HALT
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
	VM_func_end:

		
	