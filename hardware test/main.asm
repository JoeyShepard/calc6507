
;Constants
;=========
LCD_WIDTH	set 128

;RIOT Port A pins
CONTROL_CP	set $1
BUS_CP		set $2
UART_RX		set $4
BATTERY		set $8
BANK		set $10
KEYPAD		set $20

;Constants for RIOT Port A pins
BANK_0		set $0
BANK_1		set BANK
KEYPAD_OFF	set KEYPAD
KEYPAD_ON	set $0

;Command latch pins
LCD_LEFT	set $1					;active low
LCD_RIGHT	set $2					;active low
LCD_DI		set $4
LCD_E 		set $8
LCD_RST		set $10
POWER		set $20
UART_TX		set $40

;Constants for command latch pins
LCD_BOTH		set $0					;active low
LCD_NEITHER		set LCD_LEFT|LCD_RIGHT	;active low
LCD_LEFT_ON		set $FF-LCD_LEFT
LCD_RIGHT_ON	set $FF-LCD_RIGHT
LCD_D 			set LCD_DI
LCD_I			set $0
LCD_RST_LO  	set $0
LCD_RST_HI		set LCD_RST
POWER_ON		set POWER
POWER_OFF		set $0
UART_TX_ON		set UART_TX
UART_TX_OFF		set $0

;LCD commands
LCD_ON		set $3F
LCD_ROW		set $B8
LCD_COL		set $40
LCD_Z		set $C0

;Addresses in RIOT
PORT_A		set $880
PORT_A_DIR	set $881
PORT_B		set $882
PORT_B_DIR	set $883

	include ../src/emu.asm

;Main code
;=========
	;Unlimited lines per page in listing
	PAGE 0
DEBUG_MODE set "off"
	
	;Macros at very beginning
	include ../src/macros.asm
	include ../src/optimizer_nmos.asm
	
	;Reset vector
	;ORG $FFFC
	ORG $1FFC
	FDB Setup
	
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
	TODO: consider moving into zero page
	BYTE counter1, counter2
	BYTE LCD_X
	
	;State of Port A output pins
	BYTE State_BANK
	BYTE State_KEYPAD
	BYTE State_PortA
	
	;State of control latch pins
	BYTE State_LCD_CS		;set explicitly every time so not needed
	BYTE State_LCD_RST
	;BYTE State_POWER		;should always be on
	BYTE State_UART_TX
	BYTE State_Control
	
	TODO: remove after debugging
	BYTE debug1, debug2, debug3

;Functions in ROM
;================
	;Testing banking
	ORG $0
		FCB 'A'
		FCB 'B'
		
	ORG $1000
		FCB 'C'
		FCB 'D'
		
	ORG $900
	;JMP main	;static entry address for emulator
	JMP Setup
	
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
	;put byte on bus latch
	FUNC LatchBus
		
		STA PORT_B
		LDA State_PortA
		STA PORT_A
		ORA #BUS_CP
		STA PORT_A
		
	END
	
	;data in A
	;put byte out to control latch
	FUNC LatchControl
		
		ORA State_Control
		STA PORT_B
		LDA State_PortA
		STA PORT_A
		ORA #CONTROL_CP
		STA PORT_A
		
	END
	
	FUNC UpdatePortA
	
		LDA State_BANK
		ORA State_KEYPAD
		STA State_PortA
	
	END
	
	FUNC UpdateControl
	
		LDA State_LCD_CS
		ORA State_LCD_RST
		ORA State_UART_TX
		TODO: make sure this isnt 0 after circuit is final
		ORA #POWER_ON
		STA State_Control
	
	END
	
	FUNC Setup
		
		SEI
		CLD
		
		LDX #$FF
		TXS
		
		;All outputs
		;LDX #$FF
		STX PORT_B_DIR
		
		;Load Port A with values before enabling to avoid glitch
		LDA #BANK_1
		STA State_BANK
		LDA #KEYPAD_OFF
		STA State_KEYPAD
		JSR UpdateControl
		STA PORT_A
		
		;Enable outputs on Port A
		LDA #CONTROL_CP|BUS_CP|BANK|KEYPAD
		STA PORT_A_DIR
		
		;Starting states for control latch
		LDA #LCD_NEITHER
		STA State_LCD_CS
		LDA #LCD_RST_LO
		STA State_LCD_RST
		LDA #UART_TX_ON
		STA State_UART_TX
		JSR UpdateControl
		JSR LatchControl
		
		JMP main
		
	TODO: wasted ret
	END
	
	;signal in A
	FUNC  LCD_Enable
	
		TAY
		JSR LatchControl
		TYA
		ORA #LCD_E
		JSR LatchControl
		;min 500ns delay in datasheet!
		TYA
		JSR LatchControl
		;LDA #1			;500ns in datahseet! also Tbusy - 1us?
		;delay
		TODO: necessary?
		JSR delay15			;1us is enough?
	
	END

	;data in A
	;send byte of data to LCD
	FUNC LCD_Data
		
		JSR LatchBus
		LDA #LCD_D
		JSR LCD_Enable
		
	END
	
	;data in A
	;send byte of instruction to LCD
	FUNC LCD_Command
		
		JSR LatchBus
		LDA #LCD_I
		JSR LCD_Enable
		
	END

	TODO: maybe not needed
	FUNC LCD_Home
		
		LDA #0
		STA LCD_X
		
		LDA #LCD_BOTH
		STA State_LCD_CS
		JSR UpdateControl
	
		;LDA #LCD_COL	;Y address=0
		;JSR LCD_Command
		
		LDA #LCD_ROW|7	;X address=7 since screen upside down
		JSR LCD_Command
		
	END

	FUNC LCD_Setup
		
		;Enable both halves for resetting
		LDA #LCD_BOTH
		STA State_LCD_CS
		;Already on from Setup
		;LDA #LCD_RST_LO
		;STA State_LCD_RST
		JSR UpdateControl
		JSR LatchControl
		
		TODO: needed?
		LDA #1			;<==1us/1000ns in datasheet!
		JSR delay
		
		LDA #LCD_RST_HI
		STA State_LCD_RST
		JSR UpdateControl
		JSR LatchControl
		
		LDA #10			;<==how long after reset???
		JSR delay
		
		LDA #LCD_ON		;LCD on
		JSR LCD_Command
		
		TODO: necessary?
		LDA #10			;<==how long after power on???
		JSR delay
		
		LDA #LCD_Z
		JSR LCD_Command
		
	END

	TODO: smaller to use calls to LCD_Data?
	FUNC LCD_Clear
		
		;enable both halves at once
		LDA #LCD_BOTH
		STA State_LCD_CS
		JSR UpdateControl
		
		;doesn't matter where in line we start since wraps around
		;JSR LCD_Home
		
		LDA #7	;top line of LCD is #7
		STA counter1
		
		.loop1:
			
			TODO: abstract with LCD_Home
			LDA counter1
			ORA #LCD_ROW	;X address
			JSR LCD_Command
			
			LDA #64			;64 pixels per half
			STA counter2
			
			.loop2:
				LDA #0
				JSR LCD_Data
				DEC counter2
				BNE .loop2
				
			DEC counter1
			LDA counter1
			BPL .loop1
		
		;Move cursor to 0,0
		JSR LCD_Home
		
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
		BCC .char_invalid
		
		CMP #'e'+1
		BCC .char_good
		
		.char_invalid:
			TODO: constant for this
			LDA #'!'
			STA c_out
		.char_good:
		
		;carry clear above
		LDA LCD_X
		ADC #6
		BPL .width_good
			RTS
		.width_good:
		
		TODO: could save a few bytes by calculating in loop
		TODO: could also save bytes by storing real X in LCD_X
		SEC
		LDA #LCD_WIDTH-1
		SBC LCD_X
		STA pixel_counter
		
		TODO: set LCD CS and X here? larger but much faster
		TODO: ie just spit out bytes
		
		TODO: optimize
		LDA #0
		STA pixel_ptr+1
		LDA c_out
		SEC
		SBC #32
		STA pixel_ptr
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
		LDA #(font_table-1) % 256	;-1 simplifies counter logic below
		ADC pixel_ptr
		STA pixel_ptr
		LDA #(font_table-1) / 256	;-1 simplifies counter logic below
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
			STY State_LCD_CS
			TODO: faster to try to manipulate manually?
			TODO: noticeably slower on display
			JSR UpdateControl
			
			LDA pixel_counter
			;AND #63	;bit set below so not needed
			ORA #LCD_COL
			JSR LCD_Command
			INC LCD_X
			DEC pixel_counter
			
			;first is blank line. insert here to share LCD_X logic
			LDA #0
			LDY pixel_index
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
	FUNC main, begin		;start in Setup and jump here
		
		JSR LCD_Setup
		JSR LCD_Clear
		
		LDA #BANK_0
		STA State_BANK
		JSR UpdatePortA
		STA PORT_A
		
		LDA $1000
		CALL LCD_Char, A
		LDA $1001
		CALL LCD_Char, A
		
		LDA #BANK_1
		STA State_BANK
		JSR UpdatePortA
		STA PORT_A		
		
		LDA $1000
		CALL LCD_Char, A
		LDA $1001
		CALL LCD_Char, A
		
		.loop:
			LDA #'.'
			CALL LCD_Char, A
			
			LDA #200
			JSR delay
				
			JMP .loop
		
		.done:		
		JMP .done
		
	END
	