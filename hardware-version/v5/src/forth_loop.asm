;Main forth loop
;===============
;abstracted here so emulated and hardware main functions can
;be different

forthloop_asm_begin:

    FUNC ForthLoop
        VARS
            WORD dest
            BYTE arg,type
        END

        ;Reached here from main by CALL but never return so drop return address
        PLA
        PLA

        CALL InitForth

		.input_loop:
			
			;Colon definitions must fit on one line
            ;Error message handled below
			LDA mode
			CMP #MODE_IMMEDIATE
			BEQ .mode_good
		        
				;Colon writes new words length and name. Blank out
				LDY #0
				TYA
				STA (dict_save),Y
				INY
				STA (dict_save),Y
				INY
				STA (dict_save),Y				
				
				LDA #MODE_IMMEDIATE
				STA mode
			.mode_good:
			
			;Reset dict_ptr in case anything went wrong below
			MOV.W dict_save,dict_ptr
			
			CALL DrawStack
			CALL ReadLine
			
			.process_loop:
				
				CALL LineWord
				LDA ret_val
				BEQ .no_word_error
                    ;Only error should be if word was too long
					JMP .error_sub
				.no_word_error:
				LDA new_word_len

                BNE .still_processing
                    ;Out of words to process
                    ;Error if still in compile mode
                    LDA mode
                    CMP #MODE_IMMEDIATE
                    BEQ .input_loop
                    LDA #ERROR_INPUT
                    JMP .error_sub
				.still_processing:

				CALL FindWord
				LDA ret_val
				BEQ .word_not_found
					
					;Word found
					LDA mode
					CMP #MODE_IMMEDIATE
					BNE .compile_word
				
						;Immediate mode - insert word token into temp thread and execute
						.immediate:
						LDY #TOKEN_BREAK
						LDA ret_val
						STA temp_thread
						CMP #TOKEN_SECONDARY
						BEQ .insert_address
						CMP #TOKEN_VAR_THREAD
						BEQ .insert_address
							STY temp_thread+1
							JMP .jump_thread
						.insert_address:

						;Secondaries and variables need address in stream
						CLC
						LDA obj_address ;Beginning of CODE
						ADC #1
						STA temp_thread+1
						LDA obj_address+1
						ADC #0
						STA temp_thread+2
						STY temp_thread+3
						.jump_thread:
						LDA #lo(temp_thread)
						STA exec_ptr
						LDA #hi(temp_thread)
						STA exec_ptr+1
						JMP ExecThread ;BREAK inserted above returns to main loop
					.compile_word:
					
					;Compile mode
                    LDA ret_val
                    TAY
					LDA JUMP_TABLE-2,Y
					STA ret_address
					LDA JUMP_TABLE-1,Y
					STA ret_address+1
					LDY #1
					LDA (ret_address),Y
					AND #IMMED
					BNE .immediate
					;Not immediate so compile
					LDA ret_val
					CALL WriteToken
					LDA ret_val
					BEQ .no_compile_error
						JMP .error_sub
					.no_compile_error:
					JMP .process_loop
				.word_not_found:
				
				;Word not found, so check if data
				CALL CheckData
				LDA R_ans
				CMP #OBJ_ERROR
				BNE .input_good
                    ;Unrecognized input
                    LDA #ERROR_INPUT
					JMP .error_sub
				.input_good:
				
				LDA mode
				CMP #MODE_IMMEDIATE
				BNE .compile_value
				
					;Immediate mode - add value to stack
					LDA #STACK_SIZE-1
					CMP stack_count
					BCS .no_overflow
						LDA #ERROR_STACK_OVERFLOW
						JMP .error_sub
					.no_overflow:
					
					JSR StackAddItem
					
					STX dest
					LDA #0
					STA dest+1
					CALL MemCopy, #R_ans, dest, #OBJ_SIZE
					JMP .process_loop
				.compile_value:
			
				;Compile mode - compile value
				LDA R_ans
				;Float?
				LDY #TOKEN_FLOAT
				CMP #OBJ_FLOAT
				BEQ .value_compile
				;Hex?
				LDY #TOKEN_HEX
				CMP #OBJ_HEX
				BEQ .value_compile
				;String?
				LDY #TOKEN_STRING
				CMP #OBJ_STR
				BEQ .value_compile
				
				;Unknown type - something is very wrong
				JMP ERROR_RESTART_STUB

		.error_sub:	
			CALL ErrorMsg
			JMP .input_loop
			
		.value_compile:
			STY type
			LDA #OBJ_SIZE
			JSR AllocMem
			LDA ret_val
			BEQ .float_alloc_good
				JMP .error_sub
			.float_alloc_good:
			LDA type
			LDY #0
			STA (dict_ptr),Y
			
			.loop:
				INY
				LDA R_ans,Y
				STA (dict_ptr),Y
				CPY #8
				BNE .loop
			
			;Adjust dict pointer
			MOV.W new_dict_ptr,dict_ptr
			
			JMP .process_loop
    END

    
forthloop_asm_end:
