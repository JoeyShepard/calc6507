;Tests from file input
;=====================

	;should never run from ROM, so ok to put variables here
	WORD counter1, counter2
	WORD failed1, failed2
	
	FUNC line_num
		CALL DebugText, "\\n\\l"
		LDA counter2+1
		STA DEBUG_HEX
		LDA counter2
		STA DEBUG_HEX
		LDA counter1+1
		STA DEBUG_HEX
		LDA counter1
		STA DEBUG_HEX
	END
	
	FUNC inc_line
		INC counter1
		BNE .carry_done
			INC counter1+1
			BNE .carry_done
			
			CALL line_num
			
				INC counter2
				BNE .carry_done
					INC counter2+1
		.carry_done:
	END
	
	FUNC read_file_line
		
		CALL inc_line
		
		LDY #0
		.loop:
			LDA FILE_INPUT
			BEQ .loop_done
			CMP #$D
			BEQ .loop_done
			STA new_word_buff,Y
			INY
			JMP .loop
		.loop_done:
		LDA FILE_INPUT
		STY new_word_len
		CALL CheckData
	END
	
	FUNC FileInputTest
		VARS
			BYTE value
		END
		
		CALL read_file_line
		
		LDY #0
		.check_loop:
			LDA FILE_INPUT
			CMP #'A'
			BCS .letter
				SEC
				SBC #'0'
				JMP .letter_done
			.letter:
				SEC
				SBC #'A'-10
			.letter_done:
			ASL
			ASL
			ASL
			ASL
			STA value
			
			LDA FILE_INPUT
			CMP #'A'
			BCS .letter2
				SEC
				SBC #'0'
				JMP .letter_done2
			.letter2:
				SEC
				SBC #'A'-10
			.letter_done2:
			ORA value
			STA value
			
			LDA new_stack_item,Y
			CMP value
			BNE .failed_input
			INY
			LDA FILE_INPUT
			CMP #$D
			BNE .continue
				JMP .done
			.continue:
			JMP .check_loop
		
			.failed_input:
				CALL DebugText, "\\n\\n\\rLine "
				LDA counter2+1
				STA DEBUG_HEX
				LDA counter2
				STA DEBUG_HEX
				LDA counter1+1
				STA DEBUG_HEX
				LDA counter1
				STA DEBUG_HEX
				CALL DebugText,": FAILED!\\n"
				CALL DebugText,"   Found:    "
				LDY #0
				.fail_loop:
					LDA new_stack_item,Y
					STA DEBUG_HEX
					LDA #' '
					STA DEBUG
					INY
					CPY #9
					BNE .fail_loop
				halt
				LDA new_stack_item
				JMP .failed_input
			
		.done:
		LDA FILE_INPUT
		INC.W test_count
	END
	
	FUNC read3
		CALL read_file_line
		CALL NewToR, #R1
		CALL read_file_line
		CALL NewToR, #R0
		CALL read_file_line
	END
	
	FUNC file_tests
		
		MOV.W #0,counter1
		MOV.W #0,counter2
		MOV.W #0,failed1
		MOV.W #0,failed2
		
		CALL DebugText,"\\n\\n\\lBeginning file-based tests"
		
		.loop:
			CALL inc_line, #counter1
			
			LDA FILE_INPUT
			
			;No more input
			JEQ .done
			
			;Input test
			CMP #'I'
			BNE .not_I
				LDA FILE_INPUT
				LDA FILE_INPUT
				CALL FileInputTest
				JMP .loop
			.not_I:
			
			;Addition test
			CMP #'A'
			BNE .not_A
				LDA FILE_INPUT
				LDA FILE_INPUT
				CALL read3
				CALL BCD_Add
				CALL CompareR1
				BEQ .loop
				JMP .failed
			.not_A:
			
			;Comment
			CMP #';'
			BNE .not_comment
				.loop_comment:
					LDA FILE_INPUT
					BEQ .file_end
					CMP #$A
					BEQ .loop
					BNE .loop_comment
					
					.file_end:
					;file ended on comment!
					halt
			.not_comment:
			
			;Empty line
			CMP #$D
			BNE .not_newline
				LDA FILE_INPUT
				JMP .loop
			.not_newline:
			
			;End of file marker
			CMP #'Z'
			BNE .not_Z
				;done with file
				JMP .done
			.not_Z:
			
			;unrecognized mode!
			PHA
			CALL DebugText,"\\n\\rUnrecognized input code: $"
			PLA
			STA DEBUG_HEX
			CALL DebugText, "\\n\\l"
			LDA counter2+1
			STA DEBUG_HEX
			LDA counter2
			STA DEBUG_HEX
			LDA counter1+1
			STA DEBUG_HEX
			LDA counter1
			STA DEBUG_HEX
			halt
		.done:
		
		LDA failed1
		ORA failed1+1
		ORA failed2
		ORA failed2+1
		BNE .some_failed
			CALL DebugText, "\\n\\n\\gAll filed-based tests passed"
			;storing any value here will exit node.js. ignored otherwise
			JMP .failed_done
		.some_failed:
		
		CALL DebugText, "\\n\\n\\rFile-based tests failed: "
		LDA failed2+1
		STA DEBUG_HEX
		LDA failed2
		STA DEBUG_HEX
		LDA failed1+1
		STA DEBUG_HEX
		LDA failed1
		STA DEBUG_HEX
		
		.failed_done:
		CALL DebugText, "\\n\\lTotal lines: "
		LDA counter2+1
		STA DEBUG_HEX
		LDA counter2
		STA DEBUG_HEX
		LDA counter1+1
		STA DEBUG_HEX
		LDA counter1
		STA DEBUG_HEX
		
		STA NODE_EXIT
		
		RTS
		
		.failed:
			INC failed1
			BNE .failed_carry_done
				INC failed1+1
				BNE .failed_carry_done
					INC failed2
					BNE .failed_carry_done
						INC failed2+1
			.failed_carry_done:
			
			.fail_loop:
				CALL DebugText, "\\n\\n\\rLine "
				LDA counter2+1
				STA DEBUG_HEX
				LDA counter2
				STA DEBUG_HEX
				LDA counter1+1
				STA DEBUG_HEX
				LDA counter1
				STA DEBUG_HEX
				CALL DebugText,": FAILED!\\n"
				CALL DebugText,"   Expected: "
				
				LDY #(DEC_COUNT/2)-1+GR_OFFSET
				.floop:
					LDA new_stack_item,Y
					STA DEBUG_HEX
					DEY
					BNE .floop
				LDA #' '
				STA DEBUG
				
				LDA R1		;GR
				STA DEBUG_HEX
				
				CALL DebugText," E"
				
				LDA new_stack_item+EXP_HI
				STA DEBUG_HEX
				LDA new_stack_item+EXP_LO
				STA DEBUG_HEX
				
				CALL DebugText,"\\n   Found:    "
				CALL DebugR1
			
				halt
			
			JMP .fail_loop
			;JMP .loop
	END
	
	FUNC CompareR1
	
		LDY #8
		.loop:
			LDA R1,Y
			CMP new_stack_item,Y
			BNE .failed
			DEY
			BNE .loop
		LDA #0
		RTS
		.failed:
		LDA #$FF
	END
	
	
	