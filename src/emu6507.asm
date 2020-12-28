;I/O and setup for emulator
;==========================
	
	BG_COLOR = $2A
	FG_COLOR = $0
	
	;Layout
	INPUT_Y =				(SCREEN_ADDRESS / 256)+CHAR_HEIGHT*7
	ERROR_X =				2*8*1
	ERROR_Y =				(SCREEN_ADDRESS / 256)+CHAR_HEIGHT*2
	
	
	FUNC setup
		SEI
		CLD
		
		;Fill RAM with $FF for debugging
		PLA
		STA 2
		PLA
		STA 3
		LDA #0
		STA 0
		STA 1
		LDY #4
		.loop_begin:
		LDA #$FF
		.loop:
			STA (0),Y
			INY
			BNE .loop
		INC 1
		LDA 1
		CMP #9
		BNE .loop_begin
		LDA 3
		PHA
		LDA 2
		PHA
		
		;Stack grows down
		LDX #0
		STX stack_count
		
		LDA #0
		STA font_inverted
		
		MOV.W #font_table,font_ptr
		
		LDA #dict_begin % 256
		STA dict_ptr
		STA dict_save
		LDA #dict_begin / 256
		STA dict_ptr+1
		STA dict_save+1
		
		LDA #0
		STA dict_begin
		STA dict_begin+1
		STA dict_begin+2
		
		LDA #MODE_IMMEDIATE
		STA mode
		
		;Point to RAM so tests can run
		;Emulator only!
		MOV #BANK_GEN_RAM2,RAM_BANK2		
		MOV #BANK_GEN_RAM3,RAM_BANK3		
		
	END

	FUNC gfx_setup
		
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
	
		LDA pixel_ptr
		ASL pixel_ptr
		;ROL pixel_ptr+1	;highest char <128
		ASL pixel_ptr
		ROL pixel_ptr+1
		;CLC ;16-bit can't overflow
		ADC pixel_ptr
		STA pixel_ptr
		BCC .no_C
			INC pixel_ptr+1
		.no_C:
		
		TODO: remove after debugging
		;CLC
		;LDA #font_table % 256
		;ADC pixel_ptr
		;STA pixel_ptr
		;LDA #font_table / 256
		;ADC pixel_ptr+1
		;STA pixel_ptr+1
		
		CLC
		LDA font_ptr
		ADC pixel_ptr
		STA pixel_ptr
		LDA font_ptr+1
		ADC pixel_ptr+1
		STA pixel_ptr+1
		
		;LDA #0
		;STA pixel_index
		LDA #5
		STA lc1
		STA pixel_index
		.loop:
			LDA #8
			STA lc2
			;LDY pixel_index
			;INC pixel_index
			DEC pixel_index
			LDY pixel_index
			LDA (pixel_ptr),Y
			EOR font_inverted
			STA pixel
			LDY #0
			.loop.inner:
				ASL pixel
				LDA #FG_COLOR
				BCS .color
					LDA #BG_COLOR
				.color:
				STA (screen_ptr),Y
				INY
				STA (screen_ptr),Y
				INC screen_ptr+1
				STA (screen_ptr),Y				
				DEY
				STA (screen_ptr),Y
				INC screen_ptr+1
				DEC lc2
				BNE .loop.inner
			INC screen_ptr
			INC screen_ptr
			
			LDA screen_ptr+1
			SEC
			SBC #16
			STA screen_ptr+1
			
			DEC lc1
			BNE .loop	
		
		;blank line after character
		;looks fine on actual LCD since room around edge
		LDA #16
		STA lc1
		LDA #BG_COLOR
		LDY font_inverted
		BEQ .no_inv
			LDA #FG_COLOR
		.no_inv:
		LDY #0
		.blank_loop:
			STA (screen_ptr),Y
			INY
			STA (screen_ptr),Y
			DEY
			INC screen_ptr+1
			
			DEC lc1
			BNE .blank_loop
		
		INC screen_ptr
		INC screen_ptr
		LDA screen_ptr+1
		SEC 
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
	