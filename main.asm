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
		
	
;Variables in zero page
;======================
	ORG $0000
	
	;Locals usage
LOCALS_BEGIN set	$0
LOCALS_END set		$1F
	
	ORG $20
	;For macros
	BYTE dummy
	WORD ret_val
	
	;Output
	WORD screen_ptr
	
	R0: DFS 9
	R1: DFS 9
	R2: DFS 9
	R3: DFS 9
	R4: DFS 9
	R5: DFS 9
	R6: DFS 9
	R7: DFS 9
	
STACK_END:
	
	
;Variables in main RAM
;=====================
	ORG $130
	;Must come after include const.asm for constants
	include globals.asm


;Functions in ROM
;================
	ORG $900
	JMP main	;static entry address for emulator
	
	;504 bytes 0_0
	font_table:
	include font_8x8.asm

	;include calc6507.asm
	include emu6507.asm
	
	include math.asm
	include output.asm
	include forth.asm
	
	
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
		
	FUNC ErrorMsg
		ARGS
			STRING msg
		END
		
		LDA #ERROR_X
		STA screen_ptr
		LDA #ERROR_Y
		STA screen_ptr+1
		CALL LCD_print, "bbbbbbbbbbbb", #FONT_NORMAL
		LDA #ERROR_X
		STA screen_ptr
		LDA #ERROR_Y+CHAR_HEIGHT
		STA screen_ptr+1
		CALL LCD_print, msg, #FONT_INVERTED
		LDA #ERROR_X
		STA screen_ptr
		LDA #ERROR_Y+CHAR_HEIGHT*2
		STA screen_ptr+1
		CALL LCD_print, "bbbbbbbbbbbb", #FONT_INVERTED
		
		.loop:
			CALL ReadKey
			CMP #KEY_ENTER
			BNE .loop
		RTS
	END

	
;Main function
;=============
	FUNC main, begin
		VARS
			BYTE counter
		END
	
		;Only use bottom 48 bytes of stack
		;May need a lot more for R stack
		;Must come before any JSR
		LDX #$2F
		TXS
				
		CALL setup
		
		.input_loop:
			CALL DrawStack
			CALL ReadLine
			
			.process_loop:
				CALL LineWord
				LDA new_word_len
				BEQ .input_loop
			
				CALL FindWord
				LDA ret_val
				ORA ret_val+1
				BEQ .not_found
					;Word found
					JMP .process_loop
				.not_found:
		
				CALL CheckData
				LDA new_stack_item
				CMP #OBJ_ERROR
				BNE .input_good
					CALL ErrorMsg,"INPUT ERROR "
					JMP .input_loop
				.input_good:
				;add new data to stack
				JMP .process_loop
				
	END
	
	