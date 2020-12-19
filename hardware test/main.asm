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

LCD_CS1	set $2	;active low
LCD_CS2	set $1	;active low
LCD_DI	set $4
LCD_E 	set $8
LCD_RST	set $10

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


;Functions in ROM
;================
	ORG $900
	JMP main	;static entry address for emulator
	
	font_table:
	include font_5x8.asm
	
;System functions
;================
	
	;count in A
	;FUNC delay
	%macro delay 0
	
		STA counter1
		LDA #0
		STA counter2
		
		%%loop:
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		DEC counter2
		BNE %%loop
		DEC counter1
		BNE %%loop
				
	;END
	%endmacro
	
	;15us? https://exploreembedded.com/wiki/Interfacing_KS0108_based_JHD12864E_Graphics_LCD_with_Atmega32
	;1us?  https://openlabpro.com/guide/ks0108-graphic-lcd-interfacing-with-pic18f4550-part-1/
	%macro delay15 0
		
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		
	%endmacro
	
	
	;data in A
	;FUNC LCD_Data
	%macro LCD_Data 0
	
		STA RIOT_B
		;data is latch 2
		LDA #2
		STA RIOT_A
		;could optimize out potentially
		LDA #0
		STA RIOT_A
		
	;END
	%endmacro
	
	;FUNC LCD_Control
	%macro LCD_Control 0
	
		STA RIOT_B
		;control is latch 2
		LDA #1
		STA RIOT_A
		;could optimize out potentially
		LDA #0
		STA RIOT_A
		
	;END
	%endmacro
	
	%macro LCD_Enable 1
		
		LDA %1
		LCD_Control
		LDA %1|LCD_E
		LCD_Control
		;min 500ns delay in datasheet!
		LDA %1
		LCD_Control
		;LDA #1			;500ns in datahseet! also Tbusy - 1us?
		;delay
		TODO: necessary?
		delay15			;1us is enough?
	
	%endmacro

	%macro LCD_Clear 0
		
		LDA #0
		STA counter1
		
		%%loop1:
			
			LDA #$40	;Y address=0
			LCD_Data
			LCD_Enable #LCD_RST|LCD_I
		
			LDA counter1
			ORA #$B8	;X address
			LCD_Data
			LCD_Enable #LCD_RST|LCD_I
		
			LDY #64
			%%loop2:
				LDA #$0
				LCD_Data
				LCD_Enable #LCD_RST|LCD_D
				;LDA #10
				;delay
				DEY
				BNE %%loop2
				
			INC counter1
			LDA counter1
			CMP #8
			JNE %%loop1
			
	%endmacro
	
;Main function
;=============
	FUNC main, begin
		;Setup
		;=====
		SEI
		CLD
		
		;LDX #$0
		;TXS
		
		;$800-$87F		SRAM
		;$880-$8FF		RIOT
		
		;.test:
		;	JMP .test
		
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
		
		;Pull reset low
		LDA #0
		LCD_Control
		
		LDA #1			;<==1us/1000ns in datasheet!
		delay
		
		LDA #LCD_RST
		LCD_Control
		
		LDA #10			;<==how long after reset???
		delay
				
		LDA #$3F	;LCD on
		LCD_Data
		LCD_Enable #LCD_RST|LCD_I
		
		LDA #10			;<==how long after power on???
		delay
		
		LDA #$C0	;Z address
		LCD_Enable #LCD_RST|LCD_I
		
		LCD_Clear
		
		.lcd_test:	
		JMP .lcd_test
		
		.loop:
			
			LDA #$A5
			LCD_Data
			LDA #$FF
			LCD_Control
			
			LDA #250
			delay
			
			LDA #$5A
			LCD_Data
			LDA #0
			LCD_Control
			
			LDA #100
			delay
			
			JMP .loop
			
		
		

		;CALL LCD_setup
		;CALL LCD_print, "Hello, World!"
		
		.done:		
		JMP .done
		
	END
	