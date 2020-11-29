;Notes
;=====
;74HCT244 for LCD?
;	HCT latch is better - 373? see doc
;power transistor - mosfet
;	2N7000??? see wikipedia
;	BS170 is 500mA
;	IRC says AO3400 and BSS138
;v small thumb wheel
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
	
	BYTE dummy
		
	
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
		DEC counter
		BNE .loop
		DEC loops
		BNE .loop
				
	END
		
	FUNC LCD_nibble
		ARGS
			BYTE nibble, RS_mode
		END
				
		LDA nibble
		ORA RS_mode
		STA nibble
		ORA #LCD_E
		STA $880 ;write data, E=1
		
		;300ns, so shouldnt be necessary
		;CALL delay, #1
		
		LDA nibble
		STA $880
		
		;May need 39-43us after command (ie 39 cycles)
		;CALL delay, #1
	END
	
	FUNC LCD_byte
		ARGS
			BYTE dbyte, RS_mode
		VARS
			BYTE arg
		END
		
		LDA dbyte
		LSR
		LSR
		LSR
		LSR
		STA arg
		CALL LCD_nibble, arg, RS_mode
		
		LDA dbyte
		AND #$F
		STA arg
		CALL LCD_nibble, arg, RS_mode
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
	;Taken from other project
	;FCB $28, $E, $1, $6, $C, $1, 0
	;From datasheet
	FCB $28	;4-bit/2-line
	FCB $10	;Set cursor
	FCB $F	;Display ON, blinking cursor
	FCB 6	;Entry mode
	FCB 1	;Clear display
	FCB 2	;Return home
	FCB 0	;End of data 	
	
	FUNC LCD_setup
		VARS
			BYTE arg
			WORD ptr
			
			BYTE d_counter
			
		END


		;THIS DISAGREES WITH DATASHEET	;https://www.bipom.com/documents/appnotes/LCD%20Interfacing%20using%20HD44780%20Hitachi%20chipset%20compatible%20LCD.pdf
		
		;USING THIS INSTEAD
		;http://www.newhavendisplay.com/specs/NHD-0420H1Z-FSW-GBW.pdf
		
		;40ms = 40 / 4 = 10
		CALL delay, #12
		
		CALL LCD_nibble, #3, #0
		
		;5 msecs = 5 / 4 = ~1
		CALL delay, #2
		
		CALL LCD_nibble, #3, #0
		CALL LCD_nibble, #3, #0
		CALL LCD_nibble, #2, #0
				
		;33 bytes shorter
		MOV.W #LCD_commands,ptr
		LDY #0
		.loop:
			LDA (ptr),Y
			BEQ .loop_done
			STA arg
			;STA DEBUG_HEX
			CALL LCD_byte, arg, #0
			;1 and 2 require 1.53ms
			CALL delay, #1
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
		
		LDX #$0
		TXS
		
		;;$800-$87F		SRAM
		;;$880-$8FF		RIOT
		;
		;LDA #$FF
		;STA $881		;DDRA
		;STA $883		;DDRB
		;;LDA #$A5
		;STA $880		;DRA
		;LDA #$96
		;STA $882		;DRB

		;CALL LCD_setup
		;CALL LCD_print, "Hello, World!"
		
		.done:		
		JMP .done
		
		CALL LCD_print, "112"
	END
	