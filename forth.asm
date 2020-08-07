;Forth related functions
;=======================
	FUNC InitForth
		LDA #0
		STA input_buff_begin
		STA input_buff_end
		STA new_word_len
	END
	
	
	FUNC LineWord
		VARS
			BYTE mode
		END
		
		LDA #0
		STA new_word_len
		
		LDY input_buff_begin
		CPY input_buff_end
		BNE .chars_left
			;No characters left
			RTS
		.chars_left:
		
		LDA #MODE_NONE
		STA mode
		
		.loop:
			LDY input_buff_begin
			LDA input_buff,Y
			INC input_buff_begin
			CMP #' '
			BNE .not_space
				LDA new_word_len
				BEQ .chars_left2
					;Word is non-zero in size
					RTS
			.not_space:
				LDY new_word_len
				STA new_word_buff,Y
				INY
				STY new_word_len
				CPY #WORD_MAX_SIZE
				BNE .word_size_good
					;Word too big to fit into 18 byte buffer
					LDA #ERROR_WORD_TOO_LONG
					STA global_error
					RTS
				.word_size_good:
				
				.chars_left2:
				LDA input_buff_begin
				CMP input_buff_end
				BEQ .found
				JMP .loop
		.found:
		RTS
	END
	