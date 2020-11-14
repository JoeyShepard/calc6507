;Unit tests
;==========

;Frameworks

	FUNC InputTest
		ARGS
			STRING input, output
		VARS
			BYTE output_index, calculated_index, value
		END
		
		LDY #0
		.loop:
			LDA (input),Y
			BEQ .loop_done
			;CMP #'-'
			;BNE .not_minus
			;	LDA #CHAR_MINUS
			;.not_minus:
			STA new_word_buff,Y
			INY
			JMP .loop
		.loop_done:
		STY new_word_len
		CALL CheckData
		
		LDY #0
		STY calculated_index
		STY output_index
		.check_loop:
			LDY output_index
			LDA (output),Y
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
			
			INY
			LDA (output),Y
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
			
			INY
			STY output_index
			
			LDY calculated_index
			LDA new_stack_item,Y
			CMP value
			BNE .failed
			INY
			STY calculated_index
			
			LDY output_index
			LDA (output),Y
			BNE .continue
				JMP .done
			.continue:
			INY
			STY output_index
			JMP .check_loop
		
			.failed:
				CALL DebugText, "\\rTest "
				LDX test_count+1
				LDA test_count
				STA DEBUG_DEC16
				CALL DebugText,": FAILED!\\n"
				CALL DebugText,"   Expected: "
				CALL DebugText,output
				CALL DebugText,"\\n   Found:    "
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
				JMP .failed
			
		.done:
		CALL DebugText, "\\gTest "
		LDX test_count+1
		LDA test_count
		STA DEBUG_DEC16
		CALL DebugText,": passed\\n"
		INC.W test_count
		
	END

	FUNC NewToR
		ARGS
			WORD Rx
		END
		
		LDY #1
		.loop:
			LDA new_stack_item,Y
			STA (Rx),Y
			INY
			CPY #9
			BNE .loop
	END

	FUNC CopyNew
		ARGS 
			STRING num1
		END
		
		LDY #0
		.loop:
			LDA (num1),Y
			BEQ .loop_done
			;CMP #'-'
			;BNE .not_minus
			;	LDA #CHAR_MINUS
			;.not_minus:
			STA new_word_buff,Y
			INY
			JMP .loop
		.loop_done:
		STY new_word_len
		CALL CheckData
	END

	FUNC DebugR1
		TXA
		PHA
		
		;CALL DebugText,"\\n"
		LDX #(DEC_COUNT/2)-1+GR_OFFSET
		.loop:
			LDA R1,X
			STA DEBUG_HEX
			DEX
			BNE .loop
		LDA #' '
		STA DEBUG
		
		LDA R1		;GR
		STA DEBUG_HEX
		
		CALL DebugText," E"
		LDA R1+DEC_COUNT/2+2
		STA DEBUG_HEX
		LDA R1+DEC_COUNT/2+1
		STA DEBUG_HEX
		
		PLA
		TAX
	END

	FUNC AddTest
		ARGS
			STRING num1,num2,ans
		END
		
		CALL CopyNew,num1
		CALL NewToR, #R1
		CALL CopyNew,num2
		CALL NewToR, #R0
		CALL CopyNew,ans
		CALL BCD_Add
		
		LDY #8
		.loop:
			LDA R1,Y
			CMP new_stack_item,Y
			BNE .failed
			DEY
			BNE .loop
		JMP .done
		
		.failed:
				CALL DebugText, "\\rTest "
				LDX test_count+1
				LDA test_count
				STA DEBUG_DEC16
				CALL DebugText,": FAILED!\\n"
				CALL DebugText,"   Expected: "
				CALL DebugText,ans
				CALL DebugText,"\\n   Found:    "
				CALL DebugR1
				CALL DebugText,"\\n\\n"
				
				halt
				
				JMP .failed
			
		.done:
		CALL DebugText, "\\gTest "
		LDX test_count+1
		LDA test_count
		STA DEBUG_DEC16
		CALL DebugText,": passed - "
		CALL DebugR1
		CALL DebugText,"\\n"
		INC.W test_count
		
	END
	
	FUNC tests
		
		;Number input
		MOV.W #1,test_count
		
		;Moved to input.txt
		
		TODO: tests for hex arithmetic
		
		;Floating point add
		MOV.W #501,test_count
		
		;temp
    	
		;1e-999
		;-1.1242385757e-999
		;1e-999
		;HP-48 rounds to 0!!!
		;Python dec gives -1e-1000, which should round to 0
		
		CALL AddTest, "1e-999","-1.1242385757e-999","0"
		
		CALL DebugText, "\\n\\gAll specific tests passed"
		MOV.W #0,test_count
		
		MOV.W #$FFFF,test_count
		
		;Reset stack pointer
		LDX #0
	END 
	