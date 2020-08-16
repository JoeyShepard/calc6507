;Forth related functions
;=======================
	FUNC InitForth
		LDA #0
		STA input_buff_begin
		STA input_buff_end
		STA new_word_len
	END
	
	
	FUNC LineWord
		
		LDA #0
		STA new_word_len
		
		LDY input_buff_begin
		CPY input_buff_end
		BNE .chars_left
			;No characters left
			RTS
		.chars_left:
		
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
	
	FUNC FindWord
		
		MOV.W #FORTH_WORDS,ret_val
		.loop:
			LDY #0
			LDA (ret_val),Y
			CMP new_word_len
			BNE .loop_next
				INY
				.str_loop:
					LDA (ret_val),Y
					CMP new_word_buff-1,Y	;offset by 1 since string starts one byte in
					BNE .no_match
						CPY new_word_len
						BEQ .word_found
							INY
							JMP .str_loop
					.no_match:
			.loop_next:
			LDY #0
			LDA (ret_val),Y
			TAY
			INY
			LDA (ret_val),Y
			PHA
			INY 
			LDA (ret_val),Y
			STA ret_val+1
			PLA
			STA ret_val
				
			;Check if done searching
			LDY #0
			LDA (ret_val),Y
			INY 
			ORA (ret_val),Y
			BNE .loop
			;Done searching - zero ret_val
			STA ret_val
			STA ret_val+1
		.word_found:
			;ret_val contains base address of word
			
			;Can't work backwards to get name from token if point to flags
			;LDY #0
			;LDA (ret_val),Y
			;CLC
			;ADC #3		;point past name and next word to flags
			;ADC ret_val
			;STA ret_val
			;LDA ret_val+1
			;ADC #0
			;STA ret_val+1
			;ret_val now points to flags
	END
	
	FUNC CheckData
		VARS
			BYTE input_mode		;input mode for float - pre decimal, post decimal, or exponent
			BYTE y_buff			;temporary storage for y
			BYTE index			;generic index
			BYTE which_digit	;whether first or second digit of BCD byte
			BYTE negative		;whether float is negative number
			BYTE exp_offset		;offset from decimal place in float
			BYTE nonzero_yet	;whether non-zero encounter yet in float
			BYTE digit_count	;count of digits during float input
		END
		LDA #OBJ_ERROR
		STA new_stack_item
		
		LDA new_word_len
		BNE .not_zero_len
			;Zero length string
			RTS
		.not_zero_len:
		
		LDY #8
		LDA #0
		.zero_loop:
			STA new_stack_item,Y
			DEY
			BNE .zero_loop
		
		LDY #0
		LDA new_word_buff
		CMP #'"'
		BNE .not_string
			;string
			LDA new_word_len
			CMP #1
			BNE .not_single_quote
				;single quote - invalid string
				RTS
			.not_single_quote:
			;reduce by one so can compare to Y below
			DEC new_word_len
			.loop_str:
				LDA new_word_buff+1,y	;+1 to skip first quote
				CMP #'"'
				BEQ .str_done
				STA new_stack_item+1,Y
				INY
				CPY #9
				BEQ .string_too_long
				CPY new_word_len
				BEQ .string_unterminated
				BNE .loop_str
				.string_too_long:
				;string longer than 8!
				.string_unterminated:
				;no matching quote on end!
				
				;optional - could cut to save space
				;LDA #ERROR_STRING
				;STA global_error
				
				;item type already set to OBJ_ERROR
				RTS
			.str_done:
			;was closing quote also last character?
			INY
			CPY new_word_len
			BNE .str_return
			
			;all successful
			LDA #OBJ_STR
			STA new_stack_item
			.str_return:
			RTS
		.not_string:
		
		CMP #'$'
		BNE .not_hex
		
			;hex
			LDA new_word_len
			;single dollar sign - invalid hex
			CMP #1
			BEQ .hex_error
			;limit to 16 bits - 4 digits
			CMP #6
			BCS .hex_error
			
			;decrease to make easier to compare to Y below
			DEC new_word_len
			LDY #0
			.loop_hex:
				LDA new_word_buff+1,Y
				CMP #'0'
				BCC .hex_error
				CMP #'9'+1
				BCS .not_digit
					SEC
					SBC #'0'
					JSR .hex_rotate
					ORA new_stack_item+1
					STA new_stack_item+1
					JMP .hex_char_next
				.not_digit:
				
				CMP #'A'
				BCC .hex_error
				CMP #'F'+1
				BCS .hex_error
				SEC
				SBC #'A'-10
				JSR .hex_rotate
				ORA new_stack_item+1
				STA new_stack_item+1
				
				.hex_char_next:
				INY
				CPY new_word_len
				BEQ .hex_done
				CPY #4
				BNE .loop_hex
				
				;success
				.hex_done:
				LDA #OBJ_HEX
				STA new_stack_item
				RTS
			.hex_error:
			RTS
		.not_hex:
		
		halt
		
		;not string or hex, so must be float
		LDA #6
		STA index
		LDA #0
		STA which_digit
		STA negative
		STA exp_offset
		STA digit_count
		LDA #MODE_DIGITS_PRE
		STA input_mode
		
		;1 - first character is negative or digit?
		LDA new_word_buff
		CMP #'-'
		BNE .float_no_neg
			;neg sign
			LDA #1
			STA negative
			INY
		.float_no_neg:
		
		.loop_float:
			LDA new_word_buff,Y
			JSR .digit
			BCC .float_not_digit
				PHA
				LDA digit_count
				CMP #12
				BNE .digit_ok
					;max digits exceeded!
					PLA
					RTS
				.digit_ok:
				PLA
				JSR .add_digit
				INY
				CPY new_word_len
				BEQ .float_done
				JMP .loop_float
			.float_not_digit:
			
			;not digit
			CMP #'.'
			BNE .not_decimal_point
				LDA input_mode
				CMP #MODE_DIGITS_PRE
				BEQ .decimal_good
					;second decimal found or decimal in exponent!
					RTS
				.decimal_good:
				LDA #MODE_DIGITS_POST
				STA input_mode
				JMP .loop_float
			.not_decimal_point:
		
		.float_done:
		
		RTS
		
		;helper functions
		.hex_rotate:
			STY y_buff
			LDY #4
			.hex_rot_loop:
				ASL new_stack_item+1
				ROL new_stack_item+2
				DEY
				BNE .hex_rot_loop
			LDY y_buff
			RTS
		
		;Carry set means digit
		.digit:
			CMP #'9'+1
			BCS .is_digit_no
			CMP #'0'
			BCC .is_digit_no
				;SEC
				SBC #'0'
				
				;actually no, need to know if in exponent
				
				BEQ .zero_digit
					PHA
					LDA #$FF
					STA nonzero_yet
					PLA
				.zero_digit:
				RTS
			.is_digit_no:
				CLC
				RTS
				
		.add_digit:
			PHA
			STY y_buff
			LDY index
			INC digit_count
			LDA which_digit
			EOR #$FF
			STA which_digit
			BEQ .second_digit
				;first digit
				PLA
				ASL
				ASL
				ASL
				ASL
				STA new_stack_item,Y
				LDY y_buff
				RTS
			.second_digit:
				PLA
				ORA new_stack_item,Y
				STA new_stack_item,Y
				DEC index
				LDY y_buff
				RTS
			
	END
	
	
	
	;Word list
	FORTH_WORDS:
	
	WORD_DUP:
		FCB 3, "DUP" 		;Name
		FDB	WORD_SWAP		;Next word
		FCB FORTH_1ITEM		;Flags
		FCB 2				;ID
		CODE_DUP:
			LDA #5			;Test
			RTS
	
	WORD_SWAP:
		FCB 4, "SWAP" 		;Name
		FDB	WORD_DROP		;Next word
		FCB FORTH_2ITEMS	;Flags
		FCB 4				;ID
		CODE_SWAP:
			LDA #6			;Test
			RTS	
	
	WORD_DROP:
		FCB 4, "DROP" 		;Name
		FDB	WORD_OVER		;Next word
		FCB FORTH_1ITEM		;Flags
		FCB 6				;ID
		CODE_DROP:
			LDA #7			;Test
			RTS
	
	WORD_OVER:
		FCB 4, "OVER" 		;Name
		FDB	0				;Next word
		FCB FORTH_2ITEMS	;Flags
		FCB 8				;ID
		CODE_OVER:
			LDA #8			;Test
			RTS
	