;I/O and setup for emulator
;==========================
	
	BG_COLOR = $2A
	FG_COLOR = $0
	
	;Layout
	INPUT_Y =				(SCREEN_ADDRESS / 256)+CHAR_HEIGHT*7
	ERROR_X =				3*CHAR_WIDTH
	ERROR_Y =				(SCREEN_ADDRESS / 256)+CHAR_HEIGHT*2
	
	<NOVM
		[
			$2A2A CONST BG_COLOR_WIDE
			0     CONST FG_COLOR_WIDE
		]
	VM>
	
	FUNC setup
		
		;Only use bottom 48 bytes of stack
		;May need a lot more for R stack
		PLA
		STA 0
		PLA
		STA 1
		TODO: expand this - will need a lot of stack space
		LDX #R_STACK_SIZE-1
		TXS
		LDA 1
		PHA
		LDA 0
		PHA
		
		;Stack grows down
		LDX #0
		STX stack_count
		
		<VM
			EXTERN
				font_inverted dict_begin dict_ptr dict_save 
				mode RAM_BANK2 RAM_BANK3
			END
			
			0 font_inverted c!
			dict_begin DUP dict_ptr ! dict_save !
			0 dict_begin OVER OVER ! c!
			CONST8 MODE_IMMEDIATE mode c!
			CONST8 BANK_GEN_RAM2 RAM_BANK2 c!
			CONST8 BANK_GEN_RAM3 RAM_BANK3 c!
		VM>		
	END

	FUNC GfxSetup
		;Emulator only!
		MOV #BANK_GFX_RAM1,RAM_BANK2		
		MOV #BANK_GFX_RAM2,RAM_BANK3		
	END
	
	FUNC ReadKey
		LDA KB_INPUT
	END
	
	FUNC LCD_clrscr
		<VM
			EXTERN
				screen_ptr
			END
			
			BG_COLOR_WIDE SCREEN_ADDRESS
			64 DO 
				0 DO
					;Faster than pushing BG_COLOR_WIDE every time
					OVER OVER ! 1+ 1+ 
				LOOP
			LOOP	
			DROP DROP
			SCREEN_ADDRESS screen_ptr !
		VM>
	END
	
	FUNC LCD_char_A
		TODO: more elegant solution? shouldnt be necessary after all is VM
		TODO: maybe skip VM> and <V M pair
		
		<VM A VM>
		LCD_char:
		<VM
			EXTERN 
				font_table font_inverted screen_ptr
			END
			
			32 - DUP 2 LSHIFT + font_table + 4 +
			screen_ptr @
			
			5 DO
				OVER C@ font_inverted C@ XOR SWAP		;font_table font_data screen_ptr
				8 DO
					OVER 128 AND
					FG_COLOR_WIDE BG_COLOR_WIDE
					SELECT
					OVER OVER OVER ! 256 + !
					512 +								;screen_ptr
					SWAP 1 LSHIFT SWAP					;shift font data
				LOOP									;font_table font_data screen_ptr

				[ 256 16 * 2 - CONST line_reset ]
				line_reset - SWAP DROP SWAP 1 - SWAP	;font_table screen_ptr
			LOOP
			
			font_inverted C@ 
			FG_COLOR_WIDE BG_COLOR_WIDE SELECT SWAP		;font_table color screen_ptr
			16 DO
				OVER OVER ! 256 +
			LOOP
			
			line_reset - screen_ptr ! DROP DROP
		VM>
	END
	
	FUNC LCD_print
		<VM		
			
			BEGIN
				DUP C@ LCD_char EXEC 1+ DUP C@ 
			WHILE
			DROP
		VM>
	END

	
	