;Constants
;=========

LCD_E set $10
LCD_RS set $20

	include emu.asm

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
LOCALS_END set		$7F
	
;Variables in zero page
;======================
	ORG $0000
	BYTE debug_temp
	WORD ret_val
	
	BYTE debug_RS
	BYTE debug_ptr
		
	
;Variables in main RAM
;=====================
	ORG $130
	;Must come after include const.asm for constants
	;include globals.asm


;Functions in ROM
;================
	ORG $900
	JMP main	;static entry address for emulator
	
	
;System functions
;================
	
	FUNC delay
		ARGS
			BYTE loops
		VARS 
			BYTE counter
		END
		
		MOV #0,counter
		.loop:
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		DEC counter
		BNE .loop
		DEC loops
		BNE .loop
				
	END
	
	;debug_nibble:
	;	LDA debug_temp
	;	ORA debug_RS
	;	ORA #LCD_E
	;	STA $880
	;	CALL delay, #2
	;	LDA debug_temp
	;	ORA debug_RS
	;	STA $880
	;	CALL delay, #2
	;RTS
	
	FUNC LCD_nibble
		ARGS
			BYTE nibble, RS_mode
		END
				
		LDA nibble
		ORA RS_mode
		;STA nibble
		ORA #LCD_E
		STA $880 ;write data, E=1
		CALL delay, #2
		LDA nibble
		ORA RS_mode
		STA $880
		
		;Small delay =~5ms
		CALL delay, #2
	END
	
	FUNC LCD_byte
		ARGS
			BYTE dbyte, RS_mode
		VARS
			BYTE arg
		END
		
		;LDA dbyte
		;ROR
		;ROR
		;ROR
		;ROR
		;AND #$F
		;STA arg
		;CALL LCD_nibble, arg, RS_mode
		;LDA dbyte
		;AND #$F
		;STA arg
		;CALL LCD_nibble, arg, RS_mode
		
		LDA RS_mode
		STA debug_RS
		
		LDA dbyte
		LSR
		LSR
		LSR
		LSR
		STA debug_temp
		;Works!
		;JSR debug_nibble
		;Doesn't work!
		CALL LCD_nibble, debug_temp, RS_mode
		
		LDA dbyte
		AND #$F
		STA debug_temp
		;JSR debug_nibble
		CALL LCD_nibble, debug_temp, RS_mode
	END
	
	FUNC LCD_print
		ARGS
			STRING msg
		VARS
			BYTE character
		END
		
		LDY #0
		.loop:
			LDA (msg),Y
			BEQ .loop_done
			STA character
			;STA DEBUG_HEX
			CALL LCD_byte, character, #LCD_RS
			INY
			JMP .loop
		.loop_done:
	END
	
	LCD_commands:
	FCB $28, $E, $1, $6, $C, $1, 0
		
	FUNC LCD_setup
		VARS
			BYTE arg
			WORD ptr
		END
		
		;Long delay=~500ms (~1s here)
		;CALL delay, #$80
		CALL delay, #$FF
		
		CALL LCD_nibble, #3, #0
		
		;Medium delay=~30ms
		;CALL delay, #8
		CALL delay, #$10
		
		CALL LCD_nibble, #3, #0
		CALL LCD_nibble, #3, #0
		CALL LCD_nibble, #2, #0
		
		;CALL LCD_byte, #$28, #0
		;CALL LCD_byte, #$E, #0
		;CALL LCD_byte, #1, #0
		;CALL LCD_byte, #6, #0
		;CALL LCD_byte, #$C, #0
		;CALL LCD_byte, #1, #0
				
		;33 bytes shorter
		MOV.W #LCD_commands,ptr
		LDY #0
		.loop:
			LDA (ptr),Y
			BEQ .loop_done
			STA arg
			;STA DEBUG_HEX
			CALL LCD_byte, arg, #0
			INY
			JMP .loop
		.loop_done:
		
	END
	
	
	
;Main function
;=============
	FUNC main, begin
		;Setup
		;=====
		SEI
		CLD
		
		;Only use bottom 48 bytes of stack
		;May need a lot more for R stack
		LDX #$2F
		TXS
		
		;stack grows down
		LDX #0
		
		;$800-$87F		SRAM
		;$880-$8FF		RIOT
		
		LDA #$FF
		STA $881		;DDRA
		STA $883		;DDRB
		;LDA #$A5
		STA $880		;DRA
		LDA #$96
		STA $882		;DRB

		;MOV #$A5,debug_temp
		;.loop:
		;	CALL delay, #$FF
		;	LDA debug_temp
		;	EOR #$FF
		;	STA debug_temp
		;	STA $880
		;JMP .loop

		;CALL LCD_setup
		;CALL LCD_byte, #'A', #LCD_RS
		;CALL LCD_print, "Hello, World!"
		
		
		
		
		
		
		
		
		;LDA #0
		;STA debug_RS
		;
		;;Long delay=~500ms (~1s here)
		;;CALL delay, #$80
		;CALL delay, #$FF
		;
		;LDA #3
		;STA debug_temp
		;JSR debug_nibble
		;		
		;;Medium delay=~30ms
		;;CALL delay, #8
		;CALL delay, #$10
		
		;LDA #3
		;STA debug_temp
		;JSR debug_nibble
		;
		;LDA #3
		;STA debug_temp
		;JSR debug_nibble
		;
		;LDA #2
		;STA debug_temp
		;JSR debug_nibble
		
		;;CALL LCD_byte, #$28, #0
		;LDA #2
		;STA debug_temp
		;JSR debug_nibble
		;
		;LDA #8
		;STA debug_temp
		;JSR debug_nibble
		;
		;;CALL LCD_byte, #$E, #0
		;LDA #0
		;STA debug_temp
		;JSR debug_nibble
		;
		;LDA #$E
		;STA debug_temp
		;JSR debug_nibble
		;
		;;CALL LCD_byte, #1, #0
		;LDA #0
		;STA debug_temp
		;JSR debug_nibble
		;
		;LDA #1
		;STA debug_temp
		;JSR debug_nibble
		;
		;;CALL LCD_byte, #6, #0
		;LDA #0
		;STA debug_temp
		;JSR debug_nibble
		;
		;LDA #6
		;STA debug_temp
		;JSR debug_nibble
		;
		;;CALL LCD_byte, #$C, #0
		;LDA #0
		;STA debug_temp
		;JSR debug_nibble
		;
		;LDA #$C
		;STA debug_temp
		;JSR debug_nibble
		;
		;;CALL LCD_byte, #1, #0
		;LDA #0
		;STA debug_temp
		;JSR debug_nibble
		;
		;LDA #1
		;STA debug_temp
		;JSR debug_nibble
		
		JSR debug_setup
		
		;CALL LCD_setup
		
		;65 = A = 0x41
		;LDA #LCD_RS
		;STA debug_RS
		;
		;LDA #4
		;STA debug_temp
		;JSR debug_nibble
		;
		;LDA #2
		;STA debug_temp
		;JSR debug_nibble
		
		CALL LCD_byte, #'E', #LCD_RS
		
		.done:
		LDA #1
		STA $882
		LDA #0
		STA $882
		JMP .done
		
		CALL LCD_setup
		CALL LCD_print, "Hello, World!"
	END
	
	debug_nibble:
		LDA debug_temp
		ORA debug_RS
		ORA #LCD_E
		STA $880
		CALL delay, #2
		LDA debug_temp
		ORA debug_RS
		STA $880
		CALL delay, #2
	RTS

	;LCD_commands:
	;FCB $28, $E, $1, $6, $C, $1, 0

	debug_setup:
	
		LDA #0
		STA debug_RS
		
		;Long delay=~500ms (~1s here)
		;CALL delay, #$80
		CALL delay, #$FF
		
		;LDA #3
		;STA debug_temp
		;JSR debug_nibble
		CALL LCD_nibble, #3, #0
		
		;Medium delay=~30ms
		;CALL delay, #8
		CALL delay, #$10
	
		;LDA #3
		;STA debug_temp
		;JSR debug_nibble
		CALL LCD_nibble, #3, #0
		
		;LDA #3
		;STA debug_temp
		;JSR debug_nibble
		CALL LCD_nibble, #3, #0
		
		;LDA #2
		;STA debug_temp
		;JSR debug_nibble
		CALL LCD_nibble, #2, #0
	
		MOV.W #LCD_commands,debug_ptr
		LDY #0
		.loop:
			LDA (debug_ptr),Y
			BEQ .loop_done
			;ROR
			;ROR
			;ROR
			;ROR
			;AND #$F
			;STA debug_temp
			;JSR debug_nibble
			;LDA (debug_ptr),Y
			;AND #$F
			;STA debug_temp
			;JSR debug_nibble
			STA debug_temp
			CALL LCD_byte, debug_temp, #0
			
			INY
			JMP .loop
		.loop_done:
	RTS
	
	debug_commands:
	FCB 2, 8, 0, $E, 0, $1, 0, 6, 0, $C, 0, 1, $FF
	
	debug_setup2:
		MOV.W #debug_commands,debug_ptr
		LDY #0
		.loop:
			LDA (debug_ptr),Y
			CLC
			ADC #1
			BEQ .loop_done
			SEC
			SBC #1
			STA debug_temp
			JSR debug_nibble
			INY
			JMP .loop
		.loop_done:
	RTS
	
	
	