;Unit tests
;==========

;Frameworks

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
		CALL InputTest, "-500e997", "01 00 00 00 00 00 50 99 89"
		
		;14 - 0.05 = 5e-2
		CALL InputTest, "0.05", "01 00 00 00 00 00 50 02 40"
		
		;15 - 0.05e2 = 5e0
		CALL InputTest, "0.05e2", "01 00 00 00 00 00 50 00 00"
		
		;16 - 0.05e1 = 5e-1
		CALL InputTest, "0.05e1", "01 00 00 00 00 00 50 01 40"
		
		;17 - 0.05e3 = 5e1
		CALL InputTest, "0.05e3", "01 00 00 00 00 00 50 01 00"
		
		;18 - 0.05e-2 = 5e-4
		CALL InputTest, "0.05e-2", "01 00 00 00 00 00 50 04 40"
		
		;19 - 5e-0 = 5e0
		CALL InputTest, "5e-0", "01 00 00 00 00 00 50 00 00"
		
		;20 - 5e-2 = 5e-2
		CALL InputTest, "5e-2", "01 00 00 00 00 00 50 02 40"
		
		;21 - 0.05e-997 = 5e-999
		CALL InputTest, "0.05e-997", "01 00 00 00 00 00 50 99 49"
		
		;22 - 0.05e-998 = Error! underflow
		CALL InputTest, "0.05e-998", "04"
		
		;23 - 0.05e101 = 5e99
		CALL InputTest, "0.05e101", "01 00 00 00 00 00 50 99 00"
		
		;24 - 0.05e99 = 5e97
		CALL InputTest, "0.05e99", "01 00 00 00 00 00 50 97 00"
		
		;25 - 500e99 = 5e101
		CALL InputTest, "500e99", "01 00 00 00 00 00 50 01 01"
		
		;26 - 500e97 = 5e99
		CALL InputTest, "500e97", "01 00 00 00 00 00 50 99 00"
		
		;27 - 500e98 = 5e100
		CALL InputTest, "500e98", "01 00 00 00 00 00 50 00 01"
		
		;28 - 0.05e102 = 5e100
		CALL InputTest, "0.05e102", "01 00 00 00 00 00 50 00 01"
		
		;29 - 1.23456789012 = 1.23456789012e0
		CALL InputTest, "1.23456789012", "01 12 90 78 56 34 12 00 00"
		
		;30 - 12345.6789012 = 1.23456789012e4
		CALL InputTest, "12345.6789012", "01 12 90 78 56 34 12 04 00"
		
		;31 - 1.23456789012e10 = 1.23456789012e10
		CALL InputTest, "1.23456789012e10", "01 12 90 78 56 34 12 10 00"
		
		;32 - e = Error!
		CALL InputTest, "e", "04"
		
		;33 - . = Error!
		CALL InputTest, ".", "04"
		
		;34 - .e = Error!
		CALL InputTest, ".e", "04"
		
		;35 - 1.5. = Error
		CALL InputTest, "1.5.", "04"
		
		;36 - .5 = 5e-1
		CALL InputTest, ".5", "01 00 00 00 00 00 50 01 40"
		
		;37 - 0 = 0
		CALL InputTest, "0", "01 00 00 00 00 00 00 00 00"
		
		;38 - 00 = 0
		CALL InputTest, "00", "01 00 00 00 00 00 00 00 00"
		
		;39 - 00.0 = 0
		CALL InputTest, "00.0", "01 00 00 00 00 00 00 00 00"
		
		;40 - 1e2e = Error!
		CALL InputTest, "1e2e", "04"
		
		;41 - 1e2e3 = Error!
		CALL InputTest, "1e2e3", "04"
		
		;42 - .5. = Error!
		CALL InputTest, ".5.", "04"
		
		;43 - 1234567890123 = Error! too long
		CALL InputTest, "1234567890123", "04"
		
		;44 - 5e9999 = Error! exp too long
		CALL InputTest, "5e9999", "04"
		
		;45 - 0.000123456789012 = 1.23456789012e-4
		CALL InputTest, "0.000123456789012", "01 12 90 78 56 34 12 04 40"
		
		;46 - -5- = Error!
		CALL InputTest, "-5-", "04"
		
		;47 - 5-e = Error!
		CALL InputTest, "-5-e", "04"
		
		;48 - 5e- = 5
		CALL InputTest, "5e", "01 00 00 00 00 00 50 00 00"
		
		;49 - 0e500 = 0e0
		CALL InputTest, "0e500", "01 00 00 00 00 00 00 00 00"
		
		;50 - 0e-500 = 0e0
		CALL InputTest, "0e-500", "01 00 00 00 00 00 00 00 00"
		
		;51 - 0.00000123456789012 = 1.23456789012e-6 (max size)
		CALL InputTest, "0.00000123456789012", "01 12 90 78 56 34 12 06 40"
		
		;51 - 0.000000123456789012 = Error! too large
		CALL InputTest, "0.000000123456789012", "04"
		
		;52 - 5e = 5
		CALL InputTest, "5e", "01 00 00 00 00 00 50 00 00"
		
		TODO: tests for hex arithmetic
		
		
		CALL DebugText, "\\n\\gAll tests passed"
		
	END 
	