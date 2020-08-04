;Notes
;=====
;
;GPIO
;	8 outputs for LCD data lines and keyboard
;	1 output for LCD E
;	1 output for latch
;		4 or 5 for rst, rs, cs1, cs2, and maybe r/w
;		1-3 for EEPROM bank
;		1 for power transistor
;	1 output for Tx <== latched? speed may not matter
;	1 input for Rx
;	5 inputs for keyboard
;***1 PIN SHORT!***



;Constants
;=========
	include emu.asm
	include const.asm


;Main code
;=========
	;Unlimited lines per page in listing
	PAGE 0
DEBUG_MODE set "off"
	
	;Macros at very beginning
	include macros.asm
	include optimizer_nmos.asm
	
	;Reset vector
	;ORG $FFFC
	ORG $1FFC
	FDB main
	
	;Locals usage
LOCALS_BEGIN set	$20
LOCALS_END set		$3F
	
	
;Variables in zero page
;======================
	ORG $0000
	BYTE dummy
	WORD ret_val
	BYTE cx, cy
	WORD screen_ptr
	
	R0: DFS 9
	
	
;Variables in main RAM
;=====================
	ORG $130
	;Must come after include const.asm for constants
	;include globals.asm


;Functions in ROM
;================
	ORG $900
	JMP main	;static entry address for emulator
	
	;504 bytes 0_0
	font_table:
	include font_8x8.asm

	;include calc6507.asm
	include emu6507.asm
	
	
;System functions
;================
	FUNC MemCopy
		ARGS
			WORD source, dest
			BYTE count
		END
		
		LDY #0
		.loop:
			LDA (source),Y
			STA (dest),Y
			INY
			CPY count
			BNE .loop
	END
	
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
		
		CALL LCD_print, "$"
		
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
	
	
;Math functions
;==============
	FUNC BCD_Reverse
		ARGS
			WORD source
			BYTE count
		END
		
		LDY #0
		SED
		SEC
		.loop:
			LDA #0
			SBC (source),Y
			STA (source),Y
			INY
			CPY count
			BNE .loop
		CLD
	END



	

;Test data
;=========
	test_val1:
	FCB OBJ_FLOAT,	$12, $90, $78, $56, $34, $12, $1, $00
	test_val2:
	FCB OBJ_FLOAT,	$23, $01, $89, $67, $45, $23, $03, $00
	test_val3:
	FCB OBJ_HEX,	$00, $00, $00, $00, $00, $00, $DE, $BC
	
	
;Main function
;=============
	FUNC main, begin
		;Only use bottom 48 bytes of stack
		;May need a lot more for R stack
		;Must come before any JSR
		LDX #$2F
		TXS
		
		CALL setup
		
		CALL LCD_print, "RAD"
		
		LDA #((SCREEN_ADDRESS / 256)+16)
		STA screen_ptr+1
		LDA #0
		STA screen_ptr
		
		CALL MemCopy, #test_val1, #247, #9
		LDX #247
		
		CALL LCD_char, #'5'
		CALL LCD_char, #':'
		CALL DrawFloat, #247
		
		LDA screen_ptr+1
		CLC
		ADC #16
		STA screen_ptr+1
		
		CALL MemCopy, #test_val3, #238, #9
		LDX #238
		
		CALL LCD_char, #'4'
		CALL LCD_char, #':'
		CALL DrawHex, #238
		
		
		BRK
		BRK
	END
	
	