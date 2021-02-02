;Forth related functions
;=======================
	FUNC InitForth
		LDA #0
		STA input_buff_begin
		STA input_buff_end
		STA new_word_len
		
		;Auxiliary stack
		TODO: abstract
		STA aux_stack_count
		STA aux_word_counter
		LDA #AUX_STACK_SIZE-1
		STA aux_stack_ptr
		
		;Data stack pointer
		LDX #0
	END
	
	SPECIAL_CHARS_LEN = 18	;2+15+1
	special_chars:
	FCB CHAR_EXP, CHAR_QUOTE		;2
	FCB " .$+-*/'!@:;=<>"			;15
	FCB "s"							;1
	
	;Can save space here by removing cursor draw after key
	FUNC ReadLine
		VARS
			BYTE cursor, cursor_timer
			BYTE arg
			BYTE index, str_index
		END
		
		LDA #0
		STA cursor
		STA index
		STA screen_ptr
		LDA #INPUT_Y
		STA screen_ptr+1
		CALL LCD_print,"a                     "
		LDA #0
		STA screen_ptr
		LDA TIMER_S
		STA cursor_timer
		
		.loop:
			LDA #0
			STA arg
			TODO: require shift for special characters
			CALL ReadKey
			BNE .key_read
				JMP .no_key
			.key_read:
			
				;Enter key
				CMP #KEY_ENTER
				BNE .not_enter
					LDA index
					BEQ .loop
					LDA #0
					STA input_buff_begin
					LDA index
					STA input_buff_end
					RTS
				.not_enter:
			
				;Backspace
				CMP #KEY_BACKSPACE
				BNE .not_backspace
					LDA index
					BEQ .backspace_done
						DEC index
						CMP #CHAR_SCREEN_WIDTH
						BCS .backspace_scroll
							TODO: pass input in register?
							CALL LCD_char, #' '
							LDA screen_ptr
							SEC
							SBC #CHAR_WIDTH*2
							STA screen_ptr
							PHA
							CALL LCD_char, #CHAR_ARROW
							PLA
							STA screen_ptr
							JMP .draw_done
						.backspace_scroll:
							LDY index
							DEY
							JMP .scroll_buffer
						
					.backspace_done:
					JMP .no_key
				.not_backspace:
				
				TODO: remove this and extra font data from ROM
				;;Switch font (debug only!)
				;CMP #'f'
				;BNE .not_font
				;	LDY font_counter
				;	LDA debug_fonts,Y
				;	STA font_ptr
				;	LDA debug_fonts+1,Y
				;	STA font_ptr+1
				;	INY
				;	INY
				;	CPY #DEBUG_FONT_COUNT*2
				;	BNE .no_font_reset
				;		LDY #0
				;	.no_font_reset:
				;	STY font_counter
				;	CALL DrawStack
				;	;Reset screen pointer after drawing
				;	LDA #0
				;	STA cursor
				;	STA index
				;	STA screen_ptr
				;	LDA #INPUT_Y
				;	STA screen_ptr+1
				;	
				;	JMP .no_key
				;.not_font:
				
				;Special character
				LDY #0
				.special_loop:
					CMP special_chars,Y
					BNE .special_next
						STA arg
						;;recode m for minus as c since c assigned to minus sign
						;CMP #'m'
						;BNE .key_done
						;	LDA #CHAR_MINUS
						;	STA arg
						;recode s for STO as d which is store arrow
						CMP #'s'
						BNE .key_done
							LDA #CHAR_STO
							STA arg
						JMP .key_done
					.special_next:
					INY
					CPY #SPECIAL_CHARS_LEN
					BNE .special_loop
				
				;Number
				CMP #'0'
				BCC .not_num
				CMP #'9'+1
				BCS .not_num
					STA arg
					JMP .key_done
				.not_num:
				
				;Uppercase
				CMP #'A'
				BCC .not_upper
				CMP #'Z'+1
				BCS .not_upper
					STA arg
					JMP .key_done
				.not_upper:
				
				;Lowercase
				CMP #'a'
				BCC .not_lower
				CMP #'z'+1
				BCS .not_lower
					;Convert to uppercase
					SEC
					SBC #$20
					STA arg
				.not_lower:
				
				.key_done:
				LDA arg
				BEQ .not_valid
					LDY index
					CPY #BUFF_SIZE
					BCS .buffer_full
						
						STA input_buff,Y
						INC index
						CPY #CHAR_SCREEN_WIDTH-1
						BCS .scroll_buffer
							CALL LCD_char, arg
							LDA screen_ptr
							PHA
							CALL LCD_char, #CHAR_ARROW
							PLA
							STA screen_ptr
							JMP .draw_done
						.scroll_buffer:
							LDA #0
							STA screen_ptr
							TYA
							SEC
							SBC #CHAR_SCREEN_WIDTH-2
							STA str_index
							.scroll_loop:
								LDY str_index
								INC str_index
								LDA input_buff,Y
								STA arg
								CALL LCD_char, arg
								LDA index
								CMP str_index
								BNE .scroll_loop
							LDA screen_ptr
							PHA
							CALL LCD_char, #CHAR_ARROW
							PLA
							STA screen_ptr
						.draw_done:
					.buffer_full:
				.not_valid:

			.no_key:
			LDA TIMER_S
			CMP cursor_timer
			BEQ .cursor_done
				STA cursor_timer
				LDA cursor
				BEQ .draw_blank
					LDA #0
					STA cursor
					LDA #' '
					JMP .draw
				.draw_blank:
					LDA #$FF
					STA cursor
					LDA #CHAR_ARROW
				.draw:
				STA arg
				CALL LCD_char, arg
				LDA screen_ptr
				SEC
				SBC #CHAR_WIDTH
				STA screen_ptr
			.cursor_done:
		JMP .loop
	END
	
	FUNC LineWord
		LDA #ERROR_NONE
		STA ret_val
		
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
					;LDA #ERROR_WORD_TOO_LONG
					LDA #ERROR_INPUT
					STA ret_val
					RTS
				.word_size_good:
				
				.chars_left2:
				LDA input_buff_begin
				CMP input_buff_end
				BEQ .found
				JMP .loop
		.found:
	END
	
	FUNC FindWord
		LDA new_word_len
		BEQ .not_found
		MOV.W #FORTH_WORDS,ret_address
		.loop:
			LDY #0
			LDA (ret_address),Y
			CMP new_word_len
			BNE .loop_next
				INY
				.str_loop:
					LDA (ret_address),Y
					CMP new_word_buff-1,Y	;offset by 1 since string starts one byte in
					BNE .no_match
						CPY new_word_len
						BEQ .word_found
							INY
							JMP .str_loop
					.no_match:
			.loop_next:
			LDY #0
			LDA (ret_address),Y
			TAY
			INY
			LDA (ret_address),Y
			PHA
			INY 
			LDA (ret_address),Y
			STA ret_address+1
			PLA
			STA ret_address			
			ORA ret_address+1
			BNE .loop
			;Done searching - zero ret_val
			.not_found:
			STA ret_val
			RTS
		.word_found:
		
		LDY #0
		LDA (ret_address),Y
		TAY
		INY
		INY
		INY		;point past header
		LDA (ret_address),Y
		;Token
		STA ret_val
		;Address for tick and user defined words
		INY
		CLC
		TYA
		ADC ret_address
		STA obj_address
		LDA ret_address+1
		ADC #0
		STA obj_address+1
	END
	
	FUNC CheckData
		VARS
			BYTE input_mode			;input mode for float - pre decimal, post decimal, or exponent
			BYTE y_buff				;temporary storage for y
			BYTE index				;generic index
			BYTE which_digit		;whether first or second digit of BCD byte
			BYTE negative			;whether float is negative number
			BYTE exp_negative		;whether exp is negative number
			BYTE exp_count			;offset from decimal place in float
			BYTE exp_found			;whether e encountered yet in float
			BYTE dec_found			;whether decimal point encountered yet in float
			BYTE nonzero_found		;whether non-zero encountered yet in float
			BYTE digit_count		;count of digits during float input
			BYTE exp_digit_count	;count of digits during float input
			BYTE digit_found		;whether digit found yet
		END
		
		TODO: check that reading in hex and strings still works since switching to R_ans
		
		LDA #OBJ_ERROR
		STA R_ans
		
		LDA new_word_len
		BNE .not_zero_len
			;Zero length string
			RTS
		.not_zero_len:
		
		LDY #OBJ_SIZE
		LDA #0
		.zero_loop:
			STA R_ans,Y
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
				CPY #8
				BEQ .string_too_long
				STA R_ans+1,Y
				INY
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
			STA R_ans
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
					ORA R_ans+1
					STA R_ans+1
					JMP .hex_char_next
				.not_digit:
				
				CMP #'A'
				BCC .hex_error
				CMP #'F'+1
				BCS .hex_error
				SEC
				SBC #'A'-10
				JSR .hex_rotate
				ORA R_ans+1
				STA R_ans+1
				
				.hex_char_next:
				INY
				CPY new_word_len
				BEQ .hex_done
				CPY #4
				BNE .loop_hex
				
				;success
				.hex_done:
				LDA #OBJ_HEX
				STA R_ans
				RTS
			.hex_error:
			RTS
		.not_hex:
		
		TODO: this whole routine should use R1 so it can share functionality!
		
		TODO: give name to numbers
		;not string or hex, so must be float
		LDA #7
		STA index
		LDA #0
		STA which_digit
		STA negative
		STA exp_negative
		STA exp_count
		STA digit_count
		STA exp_digit_count
		STA nonzero_found
		STA dec_found
		STA exp_found
		STA digit_found
		
		;first character is negative or digit?
		LDA new_word_buff
		;CMP #CHAR_MINUS
		CMP #'-'
		BNE .float_no_neg
			;neg sign
			LDA #$FF
			STA negative
			INY
			JMP .float_first_done
		.float_no_neg:
		
		CMP #CHAR_EXP
		BNE .float_not_exp
			;First character cannot be exponent sign
			RTS
		.float_not_exp:
		
		.float_first_done:
		
		.loop_float:
			LDA new_word_buff,Y
			JSR .digit
			BCC .float_not_digit
				PHA
				LDA nonzero_found
				BNE .digit_good
					;mark at least one digit found in case all 0(s)
					;otherwise, can't tell e from 0e
					LDA #$FF
					STA digit_found
					PLA
					PHA
					BEQ .digit_zero
						;non zero digit
						LDA #$FF
						STA nonzero_found
						BNE .digit_good
						
					.digit_zero:
					;only zeroes so far, so just count exponent
					
					PLA
					LDA exp_found
					BNE .float_next
						LDA dec_found
						BNE .dec_exp_count
							LDA #1
							STA exp_count
						.dec_exp_count:
						DEC exp_count
						JMP .float_next
	
					.digit_good:
					LDA exp_found
					BNE .exp_digit
						
						LDA digit_count
						CMP #MAX_DIGITS+1	;one extra digit for input rounding
						BCC .digit_ok
							;;max digits exceeded!
							;PLA
							;RTS
							PLA
							JMP .exp_check
						.digit_ok:
						
						PLA
						JSR .add_digit
						
						.exp_check:
						LDA dec_found
						BNE .no_dec_yet
							INC exp_count
						.no_dec_yet:
						
						.float_next:
						INY
						CPY new_word_len
						BEQ .float_done
						JMP .loop_float
					.exp_digit:
						LDA exp_digit_count
						CMP #3
						BNE .exp_digit_ok
							;max exp digits exceeded!
							PLA
							RTS
						.exp_digit_ok:
						
						PLA
						STY y_buff
						LDY #4
						.exp_loop:
							ASL R_ans+GR_OFFSET+EXP_LO
							ROL R_ans+GR_OFFSET+EXP_HI
							DEY
							BNE .exp_loop
						LDY y_buff
						ORA R_ans+GR_OFFSET+EXP_LO
						STA R_ans+GR_OFFSET+EXP_LO
						INC index
						INC exp_digit_count
						JMP .float_next
			.float_not_digit:
			
			;not digit
			CMP #'.'
			BNE .not_decimal_point
				LDA dec_found
				BEQ .decimal_good
					;second decimal found!
					RTS
				.decimal_good:
				LDA exp_found
				BEQ .exp_good
					;decimal in exponent!
					RTS
				.exp_good:
				;if starts with . or only zeroes
				LDA nonzero_found
				BNE .no_implied_0
					DEC exp_count
				.no_implied_0:
				
				LDA #$FF
				STA dec_found
				BNE .float_next
			.not_decimal_point:
		
			CMP #CHAR_EXP
			BNE .not_exp
				LDA exp_found
				BEQ .first_exp
					;second e found, error!
					RTS
				.first_exp:
				
				LDA #0
				STA index
				STA which_digit
				STA nonzero_found
				LDA #$FF
				STA exp_found
				BNE .float_next		
			.not_exp:
			
			;CMP #CHAR_MINUS
			CMP #'-'
			BNE .not_minus
				;only allowed if exp_found and at first character:
				LDA exp_found
				EOR #$FF
				ORA index
				ORA exp_negative
				BEQ .minus_good
					;minus in wrong place!
					RTS
				.minus_good:
				LDA #$FF
				STA exp_negative
				BNE .float_next
			.not_minus:
			
			;character not recognized - invalid input!
			RTS
		.float_done:
		
		;Error if no digits, even if exponent given ie e500
		LDA digit_count
		BNE .exp_count_good
			LDA digit_found
			BNE .zero_ret
				RTS
			.zero_ret:
				;if input is zero, clear exponent
				LDA #0
				STA R_ans+GR_OFFSET+EXP_LO
				STA R_ans+GR_OFFSET+EXP_HI
				JMP .float_success
		.exp_count_good:
		
		;Adjust exponent
		LDA exp_negative
		BEQ .exp_positive
			TODO: smaller?
			CALL BCD_Reverse, #R_ans+GR_OFFSET+EXP_LO, #2
		.exp_positive:
		
		SED
		;Convert exp offset to BCD
		;Looping here is slower but smaller
		TODO: optimize?
		TODO: look up table?
		LDA #0
		LDY exp_count
		BMI .exp_count_neg
			DEY				;count of digits, so -1 since 5 is e0 not e1
			BEQ .exp_count_done
			CPY #$FF
			BEQ .exp_count_neg
			.exp_pos_loop:
				CLC
				ADC #1
				DEY
				BNE .exp_pos_loop
				JMP .exp_count_done
		.exp_count_neg:
			.exp_min_loop:
				SEC
				SBC #1
				INY
				BNE .exp_min_loop
		.exp_count_done:
		STA exp_count
		
		TODO: move exp to math_lo/hi and reuse code from BCD_Add
		;Add decimal place offset to exponent
		LDY #$99
		CMP #$50
		BCS .exp_count_neg2
			LDY #0
		.exp_count_neg2:
		STY index
		CLC
		ADC R_ans+GR_OFFSET+EXP_LO
		STA R_ans+GR_OFFSET+EXP_LO
		LDA index
		ADC R_ans+GR_OFFSET+EXP_HI
		STA R_ans+GR_OFFSET+EXP_HI
		CLD
		
		;round if necessary
		TXA
		PHA
		LDX #R_ans+1
		JSR BCD_Round
		PLA
		TAX
		
		;Reverse exponent bytes
		LDA #0
		LDY R_ans+GR_OFFSET+EXP_HI
		CPY #$50
		BCC .exp_positive2
			TODO: smaller?
			CALL BCD_Reverse, #R_ans+GR_OFFSET+EXP_LO, #2
			LDA #$FF 
		.exp_positive2:
		STA exp_negative
		
		;Check for overflow or underflow
		LDA R_ans+GR_OFFSET+EXP_HI
		CMP #$10
		BNE .no_exp_overflow
			;Exponent underflowed or overflowed!
			RTS
		.no_exp_overflow:
		
		;Mark negative sign bit
		LDA exp_negative
		BEQ .exp_no_neg_bit
			LDA R_ans+GR_OFFSET+EXP_HI
			ORA #E_SIGN_BIT
			STA R_ans+GR_OFFSET+EXP_HI
		.exp_no_neg_bit:
		
		;Mark negative bit
		LDA negative
		BEQ .positive
			LDA R_ans+GR_OFFSET+EXP_HI
			ORA #SIGN_BIT
			STA R_ans+GR_OFFSET+EXP_HI
		.positive:
		
		;shift everything one byte left - slow but fine since input
		TODO: replace with CopyRegs?
		TODO: change offset to -1 so shifting not necessary
		LDY #1
		.shift_loop:
			LDA R_ans+GR_OFFSET,Y
			STA R_ans+GR_OFFSET-1,Y
			INY
			CPY #OBJ_SIZE
			BNE .shift_loop
		
		;success - mark object type as float and return
		.float_success:
		LDA #OBJ_FLOAT
		STA R_ans
		
		RTS
		
		;helper routines
		.hex_rotate:
			STY y_buff
			LDY #4
			.hex_rot_loop:
				ASL R_ans+1
				ROL R_ans+2
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
				STA R_ans,Y
				LDY y_buff
				RTS
			.second_digit:
				PLA
				ORA R_ans,Y
				STA R_ans,Y
				DEC index
				LDY y_buff
				RTS
			
	END
	
	;Token in A
	FUNC ExecToken
		TODO: add support to optimizer. wont work since gets here from word
		;VARS
		;	BYTE flags
		;	BYTE temp
		;END
		
		flags = 		R0+0
		temp =			R0+1

		;No error unless set below
		LDY #ERROR_NONE
		STY ret_val
		
		TODO: error on odd tokens
		TODO: compare to max token
		
		TAY
		LDA JUMP_TABLE-2,Y
		STA ret_address
		LDA JUMP_TABLE-1,Y
		STA ret_address+1
		
		;Entry point for EXEC which sets ret_address
		.address_ready:
		LDY #0
		LDA (ret_address),Y
		
		;Check type
		CMP #OBJ_PRIMITIVE
		BEQ .exec_primitive
		CMP #OBJ_SECONDARY
		BEQ .exec_word
			;ie try to EXEC variable or random address
			LDA #ERROR_WRONG_TYPE
			STA ret_val
			RTS
		
		.exec_word:
		.exec_primitive:
		
		;Check flags
		INY
		LDA (ret_address),Y
		BEQ .no_flags
			STA flags
			
			;Check min stack size
			AND #FLAG_MIN
			STA temp
			LDA stack_count
			CMP temp
			BCS .no_underflow
				LDA #ERROR_STACK_UNDERFLOW
				STA ret_val
				RTS
			.no_underflow:
			
			;Check max stack size
			LDA flags
			AND #ADD1
			BEQ .no_add_item
				LDA #STACK_SIZE-1
				CMP stack_count
				BCS .no_overflow
					LDA #ERROR_STACK_OVERFLOW
					STA ret_val
					RTS
				.no_overflow:
				JSR StackAddItem
			.no_add_item:
			
			;Check types
			LDA flags
			AND #FLAG_TYPES
			BEQ .type_check_done
				PHA
				LDA flags
				AND #FLAG_MIN
				TAY
				PLA
				
				CMP #SAME
				BNE .not_same
					LDA 0,x
					STA temp
					;Adjusting X here would eliminate 1 redundant check below
					JMP .type_check
				.not_same:
					;Rotate type info into low bits so matches object type constants
					LSR
					LSR
					LSR
					STA temp
				.type_check:
				
				TXA
				PHA
				.type_loop:
					LDA 0,X
					CMP temp
					BEQ .type_good
						PLA
						TAX
						LDA #ERROR_WRONG_TYPE
						STA ret_val
						RTS
					.type_good:
					TXA
					CLC
					ADC #OBJ_SIZE
					TAX
					DEY
					BNE .type_loop
				PLA
				TAX
			.type_check_done:
			
			;Check if compile only
			LDA flags
			AND #COMPILE
			BEQ .mode_check_done
				AND mode
				BNE .mode_check_done
					LDA #ERROR_COMPILE_ONLY
					STA ret_val
					RTS
			.mode_check_done:
			
		.no_flags:
		
		LDA ret_address
		CLC
		ADC #1
		TAY
		LDA ret_address+1
		ADC #0
		PHA
		TYA
		PHA
	END					;calls calculated jump!
	
	;Thread in exec_ptr
	FUNC ExecThread
		;Can't allocate any locals since JMPed here
		;Modify optimizer if necessary
		
		.loop:
			LDY #0
			LDA (exec_ptr),Y
			CALL ExecToken
			LDA ret_val
			BEQ .no_error
				CALL ErrorMsg
				JMP CODE_QUIT+EXEC_HEADER
			.no_error:
			
			;Same size and faster than IncExecPtr by 1
			INC exec_ptr
			BNE .loop
				INC exec_ptr+1
			BNE .loop
			
	END
	
	FUNC StackAddItem
		TXA
		SEC
		SBC #OBJ_SIZE
		TAX
		INC stack_count
	END
	
	;Put placeholder stop word at dictionary pointer and increment
	FUNC DictEnd
		
		PHA
		JSR AllocMem
		LDA ret_val
		BEQ .alloc_good
			PLA
			RTS
		.alloc_good:
		
		LDY #0
		PLA
		CMP #4
		BNE .no_end_token
			LDA #TOKEN_EXIT_THREAD
			STA (dict_ptr),Y
			INC dict_ptr
			BNE .skip
				INC dict_ptr
			.skip:
		.no_end_token:
		
		TODO: abstract?
		;Three byte empty header signifying end of dictionary
		LDA #0
		STA (dict_ptr),Y		;Length of name
		INY
		STA (dict_ptr),Y		;Next word low
		INY
		STA (dict_ptr),Y		;Next word high
		
		;Set next word to new dict end item
		LDY #0
		LDA (dict_save),Y
		TAY
		INY
		LDA dict_ptr
		STA (dict_save),Y
		LDA dict_ptr+1
		INY
		STA (dict_save),Y
		
		;Save changes to dictionary pointer
		MOV.W dict_ptr,dict_save
	END
	
	;Amount in A
	FUNC IncDictPtr
		CLC
		ADC dict_ptr
		STA dict_ptr
		BCC .skip
			INC dict_ptr+1
		.skip:
	END
	
	;Amount in A
	FUNC IncExecPtr
		CLC
		ADC exec_ptr
		STA exec_ptr
		BCC .done
			INC exec_ptr+1
		.done:
	END
	
	TODO: return value in A too?
	;Amount in A
	FUNC AllocMem
		
		LDY #ERROR_NONE
		STY ret_val
		
		CLC
		ADC dict_ptr
		STA new_dict_ptr
		LDA #0
		ADC dict_ptr+1
		STA new_dict_ptr+1
		
		SEC
		LDA #dict_end % 256
		SBC new_dict_ptr
		LDA #dict_end / 256
		SBC new_dict_ptr+1
		
		BCS .mem_good
			LDA #ERROR_OUT_OF_MEM
			STA ret_val
		.mem_good:
		
	END
	
	;Token in A
	FUNC WriteToken
		VARS
			BYTE token
			BYTE user_defined
		END
		
		STA token
		TAY
		LDA #3
		CPY #TOKEN_SECONDARY
		BEQ .add_address
		CPY #TOKEN_VAR_THREAD
		BEQ .add_address
		CPY #TOKEN_LEAVE_THREAD
		BEQ .add_address
			LDA #1
		.add_address:
		STA user_defined
		CALL AllocMem
		LDA ret_val
		BEQ .success
			RTS
		.success:
		
		;Store token
		LDA token
		LDY #0
		STA (dict_ptr),Y
		
		;Write address after token if necessary
		LDA user_defined
		CMP #1
		BEQ .return
			TODO: add 3 here then sub 3 later. why? just for var?
			CLC 
			LDA obj_address
			ADC #3
			INY
			STA (dict_ptr),Y
			LDA obj_address+1
			ADC #0
			INY
			STA (dict_ptr),Y
		.return:
		
		;Adjust dict pointer
		MOV.W new_dict_ptr,dict_ptr
		
	END
	
	
	;Allocate room for word header
	FUNC WriteHeader
		TODO: stop relying on optimizer then?
		TODO: or add functionality to optimizer? not trivial
		;Optimizer doesn't work unless function called from function!
		;VARS
		;	BYTE count
		;	BYTE src_index, dest_index
		;	WORD ptr
		;END
		
		count = 		R0+0
		src_index =		R0+1
		dest_index =	R0+2
		ptr =			R0+3
		
		PLA
		STA ptr
		PLA
		STA ptr+1
		
		LDA new_word_len
		STA dest_index
		CLC
		ADC #WORD_HEADER_SIZE
		LDY #1
		ADC (ptr),Y
		JSR AllocMem
		LDA ret_val
		BEQ .alloc_good
			;Alloc failed - out of memory
			TODO: test!
			LDA #ERROR_OUT_OF_MEM
			STA ret_val
			BNE .return
		.alloc_good:
		
		;Setup header for new word
		LDA new_word_len
		LDY #0
		STA (dict_ptr),Y
		.name_loop:
			LDA new_word_buff,Y
			INY
			STA (dict_ptr),Y
			CPY new_word_len
			BNE .name_loop
		
		LDA #WORD_HEADER_SIZE-1
		STA count
		
		LDY #2
		.header_loop:
			LDA (ptr),Y
			INY
			STY src_index
			LDY dest_index
			INY
			STA (dict_ptr),Y
			STY dest_index
			LDY src_index
			DEC count
			BNE .header_loop
		
		.return:
		LDA #WORD_HEADER_SIZE
		CLC
		ADC ptr
		TAY
		LDA ptr+1
		ADC #0
		PHA
		TYA
		PHA	
		
	END
	
	;Token in A
	FUNC TokenArgThread
		
		PHA
		LDA #3	;token and 16 bit address
		CALL AllocMem
		LDA ret_val
		BEQ .success
			PLA
			RTS
		.success:
		
		;Store token
		PLA
		LDY #0
		STA (dict_ptr),Y
		
		TODO: abstract?
		;Write address of user defined word
		LDA obj_address
		CLC
		ADC #3	;Skip over type byte and old address pointer
		INY
		STA (dict_ptr),Y
		LDA obj_address+1
		ADC #0
		INY
		STA (dict_ptr),Y
		
		;May be better to do after call in some cases
		MOV.W new_dict_ptr,dict_ptr
			
	END
	
	;Overwrites current stack item!
	FUNC HexFalse
		LDA #0
		JMP HEX_STUB
	END
	
	FUNC HexTrue
		LDA #$FF
		JMP HEX_STUB
	END
	
	HEX_STUB:
		STA HEX_SUM+1,X
		STA HEX_SUM,X
		LDA #0
		STA HEX_TYPE,X
		LDA #OBJ_HEX
		STA 0,X
		RTS 
		