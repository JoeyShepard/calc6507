;I/O and setup for emulator
;==========================
	FUNC setup
		SEI
		CLD
		
		;Stack grows down
		LDX #0
		
		;Emulator only!
		MOV #BANK_GFX_RAM1,RAM_BANK2		
		
		MOV.W #SCREEN_ADDRESS,screen_ptr
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
		
		CMP #'`'	;_ + 1
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
			STA pixel
			LDY #0
			.loop.inner:
				ROL pixel
				LDA #$3F
				BCS .color
					LDA #0
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
	