;Forth word list
;===============

	FORTH_WORDS:
	
	WORD_DUP:
		FCB 3, "DUP" 			;Name
		FDB	WORD_SWAP			;Next word
		FCB TOKEN_DUP			;ID - 2
		CODE_DUP:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN1|ADD1		;Flags
			
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
		FCB 4, "SWAP" 			;Name
		FDB	WORD_DROP			;Next word
		FCB TOKEN_SWAP			;ID - 4
		CODE_SWAP:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN2			;Flags
			
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
		FCB 4, "DROP" 			;Name
		FDB	WORD_OVER			;Next word
		FCB TOKEN_DROP			;ID - 6
		CODE_DROP:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN1			;Flags
			
			TXA
			CLC
			ADC #OBJ_SIZE
			TAX
			DEC stack_count
			RTS
	
	WORD_OVER:
		FCB 4, "OVER" 			;Name
		FDB	WORD_ROT			;Next word
		FCB TOKEN_OVER			;ID - 8
		CODE_OVER:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN2|ADD1		;Flags
			
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
		FCB 3, "ROT" 			;Name
		FDB	WORD_MIN_ROT		;Next word
		FCB TOKEN_ROT			;ID - 10
		CODE_ROT:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN3			;Flags
			
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
	
	TODO: could be smalled by rotating twice
	WORD_MIN_ROT:
		FCB 4, "cROT" 			;Name
		FDB	WORD_CLEAR			;Next word
		FCB TOKEN_MIN_ROT		;ID - 12
		CODE_MIN_ROT:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN3			;Flags
			
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
		FCB 5,"CLEAR"			;Name
		FDB WORD_ADD			;Next word
		FCB TOKEN_CLEAR			;ID - 14
		CODE_CLEAR:
			FCB OBJ_PRIMITIVE	;Type
			FCB 0				;Flags
			
			LDX #0
			STX stack_count
			RTS
			
	WORD_ADD:
		FCB 1,"+"				;Name
		FDB WORD_SUB			;Next word
		FCB TOKEN_ADD			;ID - 16
		CODE_ADD:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN2|SAME		;Flags
			
			LDA 0,X
			
			TODO: add flag for checking these types (room for 3 more flags)
			
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
				JMP CODE_DROP+EXEC_HEADER
			.not_raw_hex:
			CMP #1
			BNE .not_mixed1
				;Top most is raw so ready to add
				.mixed_add:
					CLC
					LDA HEX_SUM,X
					ADC OBJ_SIZE+HEX_OFFSET,X
					STA OBJ_SIZE+HEX_OFFSET,X
					LDA HEX_SUM+1,X
					ADC OBJ_SIZE+HEX_OFFSET+1,X
					STA OBJ_SIZE+HEX_OFFSET+1,X
					JMP HEX_RECALC
			.not_mixed1:
			CMP #2
			BNE .no_swap
				;Top most is smart hex so need to swap
				JSR CODE_SWAP+EXEC_HEADER
				JMP .mixed_add
			.no_swap:
			
			;Both are smart hex - can't add
			LDA #ERROR_WRONG_TYPE
			STA ret_val
			RTS
			
		;Helper function
		HEX_RECALC:
			CLC
			LDA OBJ_SIZE+HEX_BASE,X
			ADC OBJ_SIZE+HEX_OFFSET,X
			STA OBJ_SIZE+HEX_SUM,X
			LDA OBJ_SIZE+HEX_BASE+1,X
			ADC OBJ_SIZE+HEX_OFFSET+1,X
			STA OBJ_SIZE+HEX_SUM+1,X
					
			JMP CODE_DROP+EXEC_HEADER
			
	WORD_SUB:
		FCB 1,"-"				;Name
		FDB WORD_MULT			;Next word
		FCB TOKEN_SUB			;ID - 18
		CODE_SUB:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN2|SAME		;Flags
			
			LDA 0,X
			
			;Subtracting floats
			CMP #OBJ_FLOAT
			BNE sub_not_float
				SUB_FLOAT:
					TODO: subtracting floats
					RTS
			sub_not_float:
			
			;Subtracting hex objects
			LDA HEX_TYPE,X
			ASL
			ORA HEX_TYPE+OBJ_SIZE,X
			BNE .not_raw_hex
				;Both raw hex
				SEC
				LDA OBJ_SIZE+HEX_SUM,X
				SBC HEX_SUM,X
				STA OBJ_SIZE+HEX_SUM,X
				LDA OBJ_SIZE+HEX_SUM+1,X
				SBC HEX_SUM+1,X
				STA OBJ_SIZE+HEX_SUM+1,X
				JMP CODE_DROP+EXEC_HEADER
			.not_raw_hex:
			
			CMP #1
			BNE .not_smart_hex
				SEC
				LDA OBJ_SIZE+HEX_OFFSET,X
				SBC HEX_SUM,X
				STA OBJ_SIZE+HEX_OFFSET,X
				LDA OBJ_SIZE+HEX_OFFSET+1,X
				SBC HEX_SUM+1,X
				STA OBJ_SIZE+HEX_OFFSET+1,X
				JMP HEX_RECALC
			.not_smart_hex:
			
			;Either strings or at least one smart hex
			LDA #ERROR_WRONG_TYPE
			STA ret_val
			RTS
	
	WORD_MULT:
		FCB 1,"*"				;Name
		FDB WORD_DIV			;Next word
		FCB TOKEN_MULT			;ID - 20
		CODE_MULT:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN2|SAME		;Flags
	
			LDA 0,X
			
			;Multiplying floats
			CMP #OBJ_FLOAT
			BNE mult_not_float
				MULT_FLOAT:
					TODO: multiplying floats
					RTS
			mult_not_float:
			
			;Multiplying hex objects
			LDA HEX_TYPE,X
			ASL
			ORA HEX_TYPE+OBJ_SIZE,X
			BNE .not_raw_hex
				;Both raw hex
				
				TODO: smaller in loop? calculated high bytes wasted?
				
				LDA #0
				STA R0+2	;Low byte of sum
				STA R0+3	;High byte of sum
				
				;bb*dd of aabb*ccdd
				LDA HEX_SUM,X
				STA R0
				LDA OBJ_SIZE+HEX_SUM,X
				JSR .mult_sub
				LDA R0+2	;Low byte of sum
				STA R0+5	;Save
				LDA R0+3	;High byte of sum
				STA R0+2	;To low byte of sum
				LDA #0
				STA R0+3	;High byte of sum
				
				;aa*dd of aabb*ccdd
				LDA HEX_SUM,X
				STA R0
				LDA OBJ_SIZE+HEX_SUM+1,X
				JSR .mult_sub
				
				;cc*bb of aabb*ccdd
				LDA HEX_SUM+1,X
				STA R0
				LDA OBJ_SIZE+HEX_SUM,X
				JSR .mult_sub
				
				;Write to destination
				LDA R0+5
				STA OBJ_SIZE+HEX_SUM,X
				LDA R0+2
				STA OBJ_SIZE+HEX_SUM+1,X
				JMP CODE_DROP+EXEC_HEADER
				
				.mult_sub:
					STA R0+4	;Halved value
					LDA #0
					STA R0+1	;High byte of doubled value
					LDY #8
					.loop:
						LSR R0+4
						BCC .loop_next
							CLC
							LDA R0+2	;Low byte of sum
							ADC R0		;Low byte of doubled value
							STA R0+2
							LDA R0+3	;High byte of sum
							ADC R0+1	;High byte of doubled value
							STA R0+3
						.loop_next:
						ASL R0
						ROL R0+1
						DEY
						BNE .loop
					RTS
				
			.not_raw_hex:
			
			;Either strings or at least one smart hex
			LDA #ERROR_WRONG_TYPE
			STA ret_val
			RTS
			
	
	WORD_DIV:
		FCB 1,"/"				;Name
		FDB WORD_TICK			;Next word
		FCB TOKEN_DIV			;ID - 22
		CODE_DIV:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN2|SAME		;Flags
	
			LDA 0,X
			
			;Dividing floats
			CMP #OBJ_FLOAT
			BNE div_not_float
				DIV_FLOAT:
					TODO: dividing floats
					RTS
			div_not_float:
			
			;Dividing hex objects
			LDA HEX_TYPE,X
			ASL
			ORA HEX_TYPE+OBJ_SIZE,X
			BNE .not_raw_hex
				;Both raw hex
				
				LDA HEX_SUM,X
				STA R0
				LDA HEX_SUM+1,X
				STA R0+1
				
				ORA R0
				BNE .div_zero_check
					LDA #ERROR_DIV_ZERO
					STA ret_val
					RTS
				.div_zero_check:
				
				LDA OBJ_SIZE+HEX_SUM,X
				STA R0+2
				LDA OBJ_SIZE+HEX_SUM+1,X
				STA R0+3
				
				LDA #0
				STA R0+4
				STA R0+5
				
				LDY #16
				.loop:
					ASL R0+2
					ROL R0+3
					ROL R0+4
					ROL R0+5
					
					SEC
					LDA R0+4
					SBC R0
					PHA
					LDA R0+5
					SBC R0+1
					PHA
					BCC .div_underflow
						LDA R0+2
						ORA #1
						STA R0+2
						PLA
						STA R0+5
						PLA
						STA R0+4
						JMP .loop_next
					.div_underflow:
					PLA
					PLA
					.loop_next:
					DEY
					BNE .loop
				LDA R0+2
				STA OBJ_SIZE+HEX_SUM,X
				LDA R0+3
				STA OBJ_SIZE+HEX_SUM+1,X
				JMP CODE_DROP+EXEC_HEADER
			.not_raw_hex:
			
			;Either strings or at least one smart hex
			LDA #ERROR_WRONG_TYPE
			STA ret_val
			RTS
			
	WORD_TICK:
		FCB 1,"'"				;Name
		FDB WORD_EXEC			;Next word
		FCB TOKEN_TICK			;ID - 24
		CODE_TICK:
			FCB OBJ_PRIMITIVE	;Type
			FCB ADD1			;Flags
			
			CALL LineWord
			LDA new_word_len
			BNE .word_found
				.error_exit:
				LDA #ERROR_INPUT
				STA ret_val
				JMP CODE_DROP+EXEC_HEADER
			.word_found:
			
			CALL FindWord
			LDA ret_val
			BEQ .error_exit
			
			LDA ret_address
			STA HEX_BASE,X
			STA HEX_SUM,X
			LDA ret_address+1
			STA HEX_BASE+1,X
			STA HEX_SUM+1,X
			LDA #0
			STA HEX_OFFSET,X
			STA HEX_OFFSET+1,X
			LDA #OBJ_HEX
			STA 0,X
			LDA #HEX_SMART
			STA HEX_TYPE,X
			
			LDA #ERROR_NONE
			STA ret_val
			RTS
	
	WORD_EXEC:
		FCB 4,"EXEC"			;Name
		FDB WORD_STORE			;Next word
		FCB TOKEN_EXEC			;ID - 26
		CODE_EXEC:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN1|HEX		;Flags
			
			LDA HEX_SUM,X
			STA ret_address
			LDA HEX_SUM+1,X
			STA ret_address+1
			JSR CODE_DROP+EXEC_HEADER
			;Original return address still on stack, so no recursion problems
			LDA #TOKEN_WORD
			JMP ExecToken
	
	WORD_STORE:
		FCB 1,"!"				;Name
		FDB WORD_FETCH			;Next word
		FCB TOKEN_STORE			;ID - 28
		CODE_STORE:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN2|HEX		;Flags
	
			LDA HEX_SUM,X
			STA ret_address
			LDA HEX_SUM+1,X
			STA ret_address+1
			LDY #0
			LDA OBJ_SIZE+HEX_SUM,X
			STA (ret_address),Y
			LDA OBJ_SIZE+HEX_SUM+1,X
			INY
			STA (ret_address),Y
			
			JSR CODE_DROP+EXEC_HEADER
			JMP CODE_DROP+EXEC_HEADER
	
	WORD_FETCH:
		FCB 1,"@"				;Name
		FDB WORD_CSTORE			;Next word
		FCB TOKEN_FETCH			;ID - 30
		CODE_FETCH:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN1|HEX		;Flags
	
			LDA HEX_SUM,X
			STA ret_address
			LDA HEX_SUM+1,X
			STA ret_address+1
			LDY #0
			LDA (ret_address),Y
			STA HEX_SUM,X
			INY
			LDA (ret_address),Y
			STA HEX_SUM+1,X
			LDA #0
			STA HEX_TYPE,X
			RTS
	
	WORD_CSTORE:
		FCB 2,"C!"				;Name
		FDB WORD_CFETCH			;Next word
		FCB TOKEN_CSTORE		;ID - 32
		CODE_CSTORE:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN2|HEX		;Flags
	
			LDA HEX_SUM,X
			STA ret_address
			LDA HEX_SUM+1,X
			STA ret_address+1
			LDY #0
			LDA OBJ_SIZE+HEX_SUM,X
			STA (ret_address),Y
			
			JSR CODE_DROP+EXEC_HEADER
			JMP CODE_DROP+EXEC_HEADER
	
	WORD_CFETCH:
		FCB 2,"C@"				;Name
		FDB WORD_COLON			;Next word
		FCB TOKEN_CFETCH		;ID - 34
		CODE_CFETCH:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN1|HEX		;Flags
	
			LDA HEX_SUM,X
			STA ret_address
			LDA HEX_SUM+1,X
			STA ret_address+1
			LDY #0
			LDA (ret_address),Y
			STA HEX_SUM,X
			LDA #0
			STA HEX_SUM+1,X
			LDA #0
			STA HEX_TYPE,X
			RTS
	
	WORD_COLON:
		FCB 1,":"				;Name
		FDB WORD_SEMI			;Next word
		FCB TOKEN_COLON			;ID - 36
		CODE_COLON:
			FCB OBJ_PRIMITIVE	;Type
			FCB IMMED			;Flags
			
			;Get next word in stream
			CALL LineWord
			LDA new_word_len
			BNE .name_word
				;No more words left in stream
				.error_exit:
				LDA #ERROR_INPUT
				STA ret_val
				RTS
			.name_word:
			
			;Word already exists?
			CALL FindWord
			LDA ret_val
			BEQ .word_not_found
				;Word exists - error instead of redefining word
				BNE .error_exit
			.word_not_found:
			
			;Allocate room for word header
			LDA new_word_len
			CLC
			ADC #WORD_HEADER_SIZE
			JSR AllocMem
			LDA ret_val
			BEQ .alloc_good
				;Alloc failed - out of memory
				RTS
			.alloc_good:
			
			
			;Setup header for new word
			LDA new_word_len
			LDY #0
			STA (dict_ptr),Y
			.loop:
				LDA new_word_buff,Y
				INY
				STA (dict_ptr),Y
				CPY new_word_len
				BNE .loop
				
			TODO: smaller to copy run of bytes?
			;Next word - 0 being end of chain
			LDA #0
			INY
			STA (dict_ptr),Y
			INY
			STA (dict_ptr),Y
			;Token
			LDA #TOKEN_WORD
			INY
			STA (dict_ptr),Y
			;Only one byte header
			LDA #OBJ_WORD
			INY
			STA (dict_ptr),Y
			
			;Adjust dict pointer
			MOV.W new_dict_ptr,dict_ptr
			
			;Now in compile mode
			LDA #MODE_COMPILE
			STA mode
			RTS
	
	WORD_SEMI:
		FCB 1,";"				;Name
		FDB WORD_FLOAT			;Next word
		FCB TOKEN_SEMI			;ID - 38
		CODE_SEMI:
			FCB OBJ_PRIMITIVE	;Type
			FCB COMPILE			;Flags
			
			;Allocate dict end item
			LDA #DICT_END_SIZE
			JSR AllocMem
			LDA ret_val
			BEQ .alloc_good
				.error_exit:
				LDA #ERROR_INPUT
				STA ret_val
				RTS
			.alloc_good:
			
			;Write dict end item
			TODO: copying run of bytes is faster?
			LDA #TOKEN_DONE
			LDY #0
			STA (dict_ptr),Y
			LDA #0
			INY
			STA (dict_ptr),Y
			INY
			STA (dict_ptr),Y
			INY
			STA (dict_ptr),Y
			
			;Point past done byte to dict end item
			INC dict_ptr
			BNE .skip
				INC dict_ptr
			.skip:
			
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
			
			LDA #MODE_IMMEDIATE
			STA mode
			RTS
			
	WORD_FLOAT:
		FCB 0,""				;Name
		FDB dict_begin			;Next word
		FCB TOKEN_FLOAT			;ID - 40
		CODE_FLOAT:
			FCB OBJ_PRIMITIVE	;Type
			FCB ADD1			;Flags
			
			TXA
			PHA
			LDA #OBJ_FLOAT
			STA 0,X
			LDY #OBJ_SIZE-1
			.loop:
				INX
				LDA (exec_ptr),Y
				STA 0,X
				DEY
				BNE .loop
			PLA
			TAX
			RTS
	
	
	JUMP_TABLE:
		FDB CODE_DUP		;2
		FDB CODE_SWAP		;4
		FDB CODE_DROP		;6
		FDB CODE_OVER		;8
		FDB CODE_ROT		;10
		FDB CODE_MIN_ROT	;12
		FDB CODE_CLEAR		;14
		FDB CODE_ADD		;16
		FDB CODE_SUB		;18
		FDB CODE_MULT		;20
		FDB CODE_DIV		;22
		FDB CODE_TICK		;24
		FDB CODE_EXEC		;26
		FDB CODE_STORE		;28
		FDB CODE_FETCH		;30
		FDB CODE_CSTORE		;32
		FDB CODE_CFETCH		;34
		FDB CODE_COLON		;36
		FDB CODE_SEMI		;38
		FDB CODE_FLOAT		;40
		
		
		