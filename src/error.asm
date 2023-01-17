;Error message functions
;=======================

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
		MOV #$FF,font_inverted
		CALL LCD_print, "               "
		LDA #ERROR_X
		STA screen_ptr
		LDA #ERROR_Y+CHAR_HEIGHT
		STA screen_ptr+1
		MOV #$FF,font_inverted
		CALL LCD_char,#' '
		CALL LCD_print, msg
		LDA #ERROR_X
		STA screen_ptr
		LDA #ERROR_Y+CHAR_HEIGHT*2
		STA screen_ptr+1
		CALL LCD_print, "           [OK]"
		MOV #0,font_inverted
		
		;halt
		
		.loop:
			CALL ReadKey
			CMP #KEY_ENTER
			BNE .loop
		RTS
	END
