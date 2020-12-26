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
LCD_WIDTH	set 128

LCD_RIGHT	set $2	;active low
LCD_LEFT	set $1	;active low
LCD_BOTH	set $0	;active low
LCD_DI		set $4
LCD_E 		set $8
LCD_RST		set $10

LCD_D 	set $4
LCD_I	set $0

RIOT_A		set $880
RIOT_B		set $882


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
	
	TODO: remove after debugging
	BYTE debug_RS
	BYTE debug_ptr
	
	BYTE dummy
	
	
;Variables in main RAM
;=====================
	ORG $130
	;Must come after include const.asm for constants
	;include globals.asm

;Variables in RIOT
;=================
	ORG $800
	BYTE counter1, counter2
	BYTE LCD_CS, LCD_X
	TODO: remove after debugging
	BYTE clr_byte
	BYTE debug_1

;Functions in ROM
;================
	ORG $900
	JMP main	;static entry address for emulator
	
	font_table:
	include ../src/font_5x8.asm
	
;System functions
;================
	
	;count in A
	FUNC delay
	
		STA counter1
		LDA #0
		STA counter2
		
		.loop:
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			DEC counter2
			BNE .loop
		DEC counter1
		BNE .loop
				
	END
	
	;15us? https://exploreembedded.com/wiki/Interfacing_KS0108_based_JHD12864E_Graphics_LCD_with_Atmega32
	;1us?  https://openlabpro.com/guide/ks0108-graphic-lcd-interfacing-with-pic18f4550-part-1/
	FUNC delay15
		
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		
	END
	
	
	;data in A
	;put byte on LCD bus
	FUNC LCD_Bus
	
		STA RIOT_B
		;data is latch 2
		LDA #2
		STA RIOT_A
		LDA #0
		STA RIOT_A
		
	END
	
	;data in A
	;put byte out to control lines
	FUNC LCD_Control
		
		STA RIOT_B
		;control is latch 1
		LDA #1
		STA RIOT_A
		LDA #0
		STA RIOT_A
		
	END
	
	;signal in A
	FUNC  LCD_Enable
	
		TAY
		JSR LCD_Control
		TYA
		ORA #LCD_E
		JSR LCD_Control
		;min 500ns delay in datasheet!
		TYA
		JSR LCD_Control
		;LDA #1			;500ns in datahseet! also Tbusy - 1us?
		;delay
		TODO: necessary?
		JSR delay15			;1us is enough?
	
	END

	;data in A
	;send byte of data to LCD
	FUNC LCD_Data
		
		JSR LCD_Bus
		LDA #LCD_RST|LCD_D
		ORA LCD_CS
		JSR LCD_Enable
		
	END
	
	;data in A
	;send byte of instruction to LCD
	FUNC LCD_Command
		
		JSR LCD_Bus
		LDA #LCD_RST|LCD_I
		ORA LCD_CS
		JSR LCD_Enable
		
	END

	TODO: maybe not needed
	FUNC LCD_Home
	
		LDA #$40	;Y address=0
		JSR LCD_Command
		
		LDA #$B8|7	;X address=7 since screen upside down
		JSR LCD_Command
		
	END

	FUNC LCD_Setup
		
		;Enable both halves for resetting
		LDA #LCD_BOTH
		STA LCD_CS
		;Pull LCD reset low	
		JSR LCD_Control
		
		TODO: needed?
		LDA #1			;<==1us/1000ns in datasheet!
		JSR delay
		
		LDA #LCD_RST|LCD_BOTH
		JSR LCD_Control
		
		LDA #10			;<==how long after reset???
		JSR delay
		
		LDA #$3F	;LCD on
		JSR LCD_Command
		
		LDA #10			;<==how long after power on???
		JSR delay
		
		LDA #$C0	;Z address
		JSR LCD_Command
		
	END

	TODO: smaller to use calls to LCD_Data?
	FUNC LCD_Clear
		
		;enable both halves at once
		LDA #LCD_BOTH
		STA LCD_CS
		
		;doesn't matter where in line we start since wraps around
		;JSR LCD_Home
		
		LDA #0
		STA counter1
		
		LDA #$41
		STA clr_byte
		
		.loop1:
			
			TODO: abstract with LCD_Home
			LDA counter1
			ORA #$B8	;X address
			JSR LCD_Command
			
			LDA #64			;64 pixels per half
			STA counter2
			.loop2:
				LDA clr_byte
				JSR LCD_Data
				
				DEC counter2
				BNE .loop2
				
			INC counter1
			LDA counter1
			CMP #8			;8 lines of text on LCD
			BNE .loop1
		
		LDA #0
		STA LCD_X
		;Enable left half of LCD
		LDA #LCD_LEFT
		STA LCD_CS
		
	END
	
	FUNC LCD_Char
		ARGS
			BYTE c_out
		VARS
			WORD pixel_ptr
			BYTE pixel_index
			BYTE pixel_counter
		END
		
		LDA c_out
		CMP #' '
		BCS .char_good1
			RTS
		.char_good1:
		
		CMP #'e'+1
		BCC .char_good2
			RTS
		.char_good2:
		
		;carry clear above
		LDA LCD_X
		ADC #6
		BPL .width_good
			RTS
		.width_good:
		
		TODO: could save a few bytes by calculating in loop
		SEC
		LDA #LCD_WIDTH-1-6	;character is 6 wide
		SBC LCD_X
		STA pixel_counter
		
		TODO: set LCD CS here? larger but much faster
		
		TODO: optimize
		LDA c_out
		SEC
		SBC #32
		STA pixel_ptr
		LDA #0
		STA pixel_ptr+1
	
		LDA pixel_ptr
		ASL pixel_ptr
		;ROL pixel_ptr+1	;highest char <128
		ASL pixel_ptr
		ROL pixel_ptr+1
		;CLC 				;16-bit so can't overflow
		ADC pixel_ptr
		STA pixel_ptr
		BCC .no_C
			INC pixel_ptr+1
		.no_C:
		
		CLC
		LDA #font_table % 256
		ADC pixel_ptr
		STA pixel_ptr
		LDA #font_table / 256
		ADC pixel_ptr+1
		STA pixel_ptr+1
		
		LDA #5
		STA pixel_index
		.loop:
			
			TODO: smaller but much slower to check every column
			LDY #LCD_RIGHT
			LDA pixel_counter
			CMP #64
			BCC .left_side
				LDY #LCD_LEFT
			.left_side:
			STY LCD_CS
			
			
			
			;AND #63	;bit set below so not needed
			ORA #$40
			JSR LCD_Command
			INC LCD_X
			DEC pixel_counter
			
			;first is blank line. insert here to share LCD_X logic
			LDA #0
			LDY pixel_index
			CPY #5
			BEQ .first_line
				LDA (pixel_ptr),Y
			.first_line:
			
			;EOR font_inverted
			JSR LCD_Data
			
			DEC pixel_index
			BPL .loop
		
	END
	
	
TODO: set interrupt vector or reuse BRK
	
;Main function
;=============
	FUNC main, begin
		;Setup
		;=====
		SEI
		CLD
		
		LDX #$0
		TXS
		
		LDA #5
		PHA
		
		
		LDA #$FF
		STA $881		;DDRA
		STA $883		;DDRB
		;LDA #$A5
		;STA $880		;DRA
		;LDA #$96
		;STA $882		;DRB
		
		;Latch write low in preparation
		LDA #0
		STA RIOT_A
		
		JSR LCD_Setup
		
		.lcd_test:
			INC clr_byte
			JSR LCD_Clear
			LDA #'A'
			STA debug_1
			
			.lcd_loop:
				CALL LCD_Char, debug_1
				INC debug_1
				LDA debug_1
				CMP #'C'+1
				BNE .lcd_loop
				
			LDA #100
			JSR delay
			
		JMP .lcd_test
		
		;.loop:
		;	
		;	LDA #$A5
		;	LCD_Bus
		;	LDA #$FF
		;	LCD_Control
		;	
		;	LDA #250
		;	JSR delay
		;	
		;	LDA #$5A
		;	LCD_Bus
		;	LDA #0
		;	LCD_Control
		;	
		;	LDA #100
		;	JSR delay
		;	
		;	JMP .loop
			
		;CALL LCD_setup
		;CALL LCD_print, "Hello, World!"
		
		.done:		
		JMP .done
		
	END
	