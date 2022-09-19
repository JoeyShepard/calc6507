;List of assembly labels accessed from Forth
;May also be defined elsewhere but defining here common ones here for convenience
;================================================================================

;Constants
<NOVM
	EXTERN
		SCREEN_ADDRESS
	END
VM>

;Assembly function names
;VM Python script runs before macro expansion so can't automate
TODO: keep FUNC abstraction so script can recognize?
<NOVM
	EXTERN
		LCD_clrscr
		LCD_print
		LCD_char
		
		DigitHigh
		DigitLow
		
		DrawFloat
		DrawString
		DrawHex
	END
VM>

;Forth word code labels
<NOVM
	EXTERN
		CODE_FREE+EXEC_HEADER	AS	DO_FREE
	END
VM>

