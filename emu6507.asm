;I/O and setup for emulator
;==========================
	
	BG_COLOR = $2A
	FG_COLOR = $0
	
	;Layout
	INPUT_Y =				(SCREEN_ADDRESS / 256)+CHAR_HEIGHT*6+12
	ERROR_X =				2*8*1
	ERROR_Y =				(SCREEN_ADDRESS / 256)+CHAR_HEIGHT*2
	
	
	FUNC setup
		SEI
		CLD
		
		;Stack grows down
		LDX #0
		STX stack_count
		
		LDA #0
		STA font_inverted
		
		LDA #dict_begin % 256
		STA dict_ptr
		STA dict_save
		LDA #dict_begin / 256
		STA dict_ptr+1
		STA dict_save+1
		CALL DictEnd
		
		LDA #MODE_IMMEDIATE
		STA mode
		
		;Emulator only!
		MOV #BANK_GFX_RAM1,RAM_BANK2		
		MOV #BANK_GFX_RAM2,RAM_BANK3		
		
	END

	FUNC ReadKey
		LDA KB_INPUT
	END

	FUNC LCD_clrscr
		VARS
			BYTE counter
		END
		
		MOV.W #SCREEN_ADDRESS, screen_ptr
		;Rows on screen
		MOV #128, counter
		LDA #BG_COLOR
		LDY #0
		.loop:
			STA (screen_ptr),Y
			INY
			BNE .loop
			INC screen_ptr+1
			DEC counter
			BNE .loop
		MOV.W #SCREEN_ADDRESS, screen_ptr
	END

	FUNC LCD_char
		ARGS
			BYTE c_out
		VARS
			WORD pixel_ptr
			BYTE pixel_index
			BYTE pixel
			BYTE lc1, lc2
		END
		
		LDA c_out
		CMP #' '
		IF_LT
			RTS
		END_IF
		
		CMP #'e'+1	
		IF_GE
			RTS
		END_IF
		
		SEC
		SBC #32
		STA pixel_ptr
		LDA #0
		STA pixel_ptr+1
		
		ASL pixel_ptr
		;ROL pixel_ptr+1	;highest char <128
		ASL pixel_ptr
		ROL pixel_ptr+1
		ASL pixel_ptr
		ROL pixel_ptr+1
		;CLC ;16-bit can't overflow
		LDA #font_table % 256
		ADC pixel_ptr
		STA pixel_ptr
		LDA #font_table / 256
		ADC pixel_ptr+1
		STA pixel_ptr+1
		
		LDA #0
		STA pixel_index
		LDA #8
		STA lc1
		.loop:
			LDA #8
			STA lc2
			LDY pixel_index
			INC pixel_index
			LDA (pixel_ptr),Y
			EOR font_inverted
			STA pixel
			LDY #0
			.loop.inner:
				ROL pixel
				LDA #FG_COLOR
				BCS .color
					LDA #BG_COLOR
				.color:
				;16x24 - ie 8x8 stretched over half pixels :/
				;STA (screen_ptr),Y
				;INC screen_ptr+1
				STA (screen_ptr),Y
				INC screen_ptr+1
				STA (screen_ptr),Y
				INY
				;STA (screen_ptr),Y
				;DEC screen_ptr+1
				STA (screen_ptr),Y
				DEC screen_ptr+1
				STA (screen_ptr),Y
				INY
				DEC lc2
				BNE .loop.inner
			;INC screen_ptr+1
			INC screen_ptr+1
			INC screen_ptr+1
			DEC lc1
			BNE .loop
		CLC
		LDA screen_ptr
		ADC #16
		STA screen_ptr
		SEC
		LDA screen_ptr+1
		;SBC #24
		SBC #16
		STA screen_ptr+1
	END
	
	FUNC LCD_print
		ARGS
			STRING source
		VARS
			BYTE index, arg
		END
		
		LDA #0
		STA index
		.loop:
			LDY index
			LDA (source),Y
			BEQ .done
			STA arg
			CALL LCD_char, arg
			INC index
			JMP .loop
		.done:
	END
	