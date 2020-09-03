;Unit tests
;==========

;Frameworks

	tests_begin:

	FUNC DebugText
		ARGS
			STRING msg
		END
		LDY #0
		.loop:
		LDA (msg),Y
		BEQ .done
			STA DEBUG
			INY
			JMP .loop
		.done:
	END

	FUNC halt_test
		ARGS
			BYTE test
		END
				
		LDA test
		CMP test_count
		BNE .done
			halt
		.done:
	END

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
			CMP #'-'
			BNE .not_minus
				LDA #CHAR_MINUS
			.not_minus:
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
				STY calculated_index
				LDY #2
				STY output_index
				.fail_loop:
					LDY calculated_index
					LDA new_stack_item,Y
					STA DEBUG_HEX
					LDA #' '
					STA DEBUG
					INY
					STY calculated_index
					LDY output_index
					LDA (output),Y
					BEQ .fail_done
					INY
					INY
					INY
					STY output_index
					
					JMP .fail_loop
				.fail_done:
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

	FUNC tests
		
		LDA #1
		STA test_count
		
		;Reading inputs

		;1 - 5 = 5e0
		CALL InputTest, "5", "01 00 00 00 00 00 50 00 00" 
		
		;2 - 500 = 5e2
		CALL InputTest, "500", "01 00 00 00 00 00 50 02 00"
		
		;3 - 500. = 5e2
		CALL InputTest, "500", "01 00 00 00 00 00 50 02 00"
		
		;4 - 500.0 = 5e2
		CALL InputTest, "500.0", "01 00 00 00 00 00 50 02 00"
		
		;5 - 500.00 = 5e2
		CALL InputTest, "500.00", "01 00 00 00 00 00 50 02 00"
		
		;6 - 5e0 = 5e0
		CALL InputTest, "5e0", "01 00 00 00 00 00 50 00 00"
		
		;7 - 500e0 = 5e2
		CALL InputTest, "500e0", "01 00 00 00 00 00 50 02 00"
		
		;8 - 500e2 = 5e4
		CALL InputTest, "500e2", "01 00 00 00 00 00 50 04 00"
		
		;9 - 500e997 = 5e999
		CALL InputTest, "500e997", "01 00 00 00 00 00 50 99 09"
		
		;10 - 500e998 = Error! overflow
		CALL InputTest, "500e998", "04"
		
		;11 - -5 = -5e0
		CALL InputTest, "-5", "01 00 00 00 00 00 50 00 80"
		
		;12 - -500 = -5e2
		CALL InputTest, "-500", "01 00 00 00 00 00 50 02 80"
		
		;13 - -500e997 = -5e999
		;14 - 0.05 = 5e-2
		;15 - 0.05e2 = 5e0
		;16 - 0.05e1 = 5e-1
		;17 - 0.05e3 = 5e1
		;18 - 0.05e-2 = 5e-4
		;19 - 5e-0 = 5e0
		;20 - 5e-2 = 5e-2
		;21 - 0.05e-997 = 5e-999
		;22 - 0.05e-998 = Error! underflow
		;23 - 0.05e101 = 5e99
		;24 - 0.05e99 = 5e97
		;25 - 500e99 = 5e101
		;26 - 500e97 = 5e99
		;27 - 500e98 = 5e100
		;28 - 0.05e102 = 5e100
		;29 - 1.23456789012 = 1.23456789012e0
		;30 - 12345.6789012 = 1.23456789012e4
		;31 - 1.23456789012e10 = 1.23456789012e10
		;32 - e = Error!
		;33 - . = Error!
		;34 - .e = Error!
		;35 - 1.5. = Error
		;36 - .5 = 5e-1
		;37 - 0 = 0
		;38 - 00 = 0
		;39 - 00.0 = 0
		;40 - 1e2e = Error!
		;41 - 1e2e3 = Error!
		;42 - .5. = Error!
		;43 - 1234567890123 = Error! too long
		;44 - 5e9999 = Error! exp too long
		;45 - 0.000123456789012 = ???
		;46 - -5- = Error!
		;47 - 5-e = Error!
		;48 - 5e- = 5e0
		
		CALL DebugText, "\\n\\gAll tests passed"
		CALL DebugText, "\\n\\lSize of tests: "
		LDX #(tests_end-tests_begin)/256
		LDA #(tests_end-tests_begin) # 256
		STA DEBUG_DEC16
		CALL DebugText, " bytes"
	END 
	
	tests_end: