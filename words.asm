;Forth word list
;===============

	FORTH_WORDS:
	
	WORD_DUP:
		FCB 3, "DUP" 		;Name
		FDB	WORD_SWAP		;Next word
		FCB 2				;ID
		CODE_DUP:
			FCB MIN1|ADD1	;Flags
			
			LDY #OBJ_SIZE
			TXA
			PHA
			.dup_loop:
				LDA OBJ_SIZE,X
				STA 0,X
				INX
				DEY
				BNE .dup_loop
			PLA
			TAX
			RTS
	
	WORD_SWAP:
		FCB 4, "SWAP" 		;Name
		FDB	WORD_DROP		;Next word
		FCB 4				;ID
		CODE_SWAP:
			FCB MIN2		;Flags
			
			LDY #OBJ_SIZE
			TXA
			PHA
			.swap_loop:
				LDA OBJ_SIZE,X
				PHA
				LDA 0,X
				STA OBJ_SIZE,X
				PLA
				STA 0,X
				INX
				DEY
				BNE .swap_loop
			PLA
			TAX
			RTS	
	
	WORD_DROP:
		FCB 4, "DROP" 		;Name
		FDB	WORD_OVER		;Next word
		FCB 6				;ID
		CODE_DROP:
			FCB MIN1		;Flags
			
			TXA
			CLC
			ADC #OBJ_SIZE
			TAX
			DEC stack_count
			RTS
	
	WORD_OVER:
		FCB 4, "OVER" 		;Name
		FDB	WORD_ROT		;Next word
		FCB 8				;ID
		CODE_OVER:
			FCB MIN2|ADD1	;Flags
			
			LDY #OBJ_SIZE
			TXA
			PHA
			.over_loop:
				LDA OBJ_SIZE*2,X
				STA 0,X
				INX
				DEY
				BNE .over_loop
			PLA
			TAX
			RTS
			
	WORD_ROT:
		FCB 3, "ROT" 		;Name
		FDB	WORD_MIN_ROT	;Next word
		FCB 10				;ID
		CODE_ROT:
			FCB MIN3		;Flags
			
			LDY #OBJ_SIZE
			TXA
			PHA
			.rot_loop:
				LDA OBJ_SIZE*2,X
				PHA
				LDA OBJ_SIZE,X
				PHA
				LDA 0,X
				STA OBJ_SIZE,X
				PLA 
				STA OBJ_SIZE*2,X
				PLA 
				STA 0,X
				
				INX
				DEY
				BNE .rot_loop
			PLA
			TAX
			RTS
	
	WORD_MIN_ROT:
		FCB 4, "-ROT" 		;Name
		FDB	WORD_CLEAR		;Next word
		FCB 12				;ID
		CODE_MIN_ROT:
			FCB MIN3		;Flags
			
			LDY #OBJ_SIZE
			TXA
			PHA
			.min_rot_loop:
				LDA OBJ_SIZE*2,X
				PHA
				LDA OBJ_SIZE,X
				PHA
				LDA 0,X
				STA OBJ_SIZE*2,X
				PLA 
				STA 0,X
				PLA 
				STA OBJ_SIZE,X
				
				INX
				DEY
				BNE .min_rot_loop
			PLA
			TAX
			RTS
	
	WORD_CLEAR:
		FCB 5,"CLEAR"		;Name
		FDB WORD_ADD		;Next word
		FCB 14				;ID
		CODE_CLEAR:
			FCB 0			;Flags
			
			LDX #0
			STX stack_count
			RTS
			
	WORD_ADD:
		FCB 1,"+"			;Name
		FDB 0				;Next word
		FCB 16				;ID
		CODE_ADD:
			FCB MIN2|SAME
			
			LDA 0,X
			
			;Adding floats
			CMP #OBJ_FLOAT
			BNE add_not_float
				ADD_FLOAT:
					TODO: adding floats
					RTS
			add_not_float:
			
			;Adding strings
			CMP #OBJ_STR
			BNE add_not_string
				ADD_STRING:
					TODO: adding strings
					RTS
			add_not_string:
			
			;Adding hex objects
			LDA HEX_TYPE,X
			ASL
			ORA HEX_TYPE+OBJ_SIZE,X
			BNE .not_raw_hex
				;Both raw hex
				CLC
				LDA HEX_SUM,X
				ADC OBJ_SIZE+HEX_SUM,X
				STA OBJ_SIZE+HEX_SUM,X
				LDA HEX_SUM+1,X
				ADC OBJ_SIZE+HEX_SUM+1,X
				STA OBJ_SIZE+HEX_SUM+1,X
				JMP CODE_DROP+1
			.not_raw_hex:
			CMP #1
			BNE .not_mixed1
				;Top most is raw so ready to add
				.mixed_add:
					TODO: adding mixed hex types
				JMP CODE_DROP+1
			.not_mixed1:
			CMP #2
			BNE .no_swap
				;Top most is smart hex so need to swap
				JSR CODE_SWAP+1
				JMP .mixed_add
			.no_swap:
			
			;Both are smart pointers - can't add
			LDA #ERROR_WRONG_TYPE
			STA ret_val
			RTS
			
	
	JUMP_TABLE:
		FDB 0				;0 - reserved
		FDB CODE_DUP		;2
		FDB CODE_SWAP		;4
		FDB CODE_DROP		;6
		FDB CODE_OVER		;8
		FDB CODE_ROT		;10
		FDB CODE_MIN_ROT	;12
		FDB CODE_CLEAR		;14
		FDB CODE_ADD		;16
		