;Debug functions
;===============	
	
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
			WORD test
		END
				
		LDA test
		CMP test_count
		BNE .no_match
		LDA test+1
		CMP test_count+1
		BNE .no_match
			halt
		.no_match:
		
	END
	
	FUNC halt_no_test
		LDA test_count
		AND test_count+1
		CMP #$FF
		BNE .skip
			halt
		.skip:
	END 
	