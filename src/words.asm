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
			
			TXA
			PHA
			LDY #OBJ_SIZE
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
	
	TODO: could be smaller by rotating twice
	WORD_MIN_ROT:
		FCB 4, "-ROT" 			;Name
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
		;FCB 3,"CLR"				;Name
		FDB WORD_ADD			;Next word
		FCB TOKEN_CLEAR			;ID - 14
		CODE_CLEAR:
			FCB OBJ_PRIMITIVE	;Type
			FCB NONE				;Flags
			
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
			BNE .not_float
				.float:
					JSR TosR0R1
					JSR BCD_Add
					JSR CODE_DROP+EXEC_HEADER
					JMP RansTos
			.not_float:
			
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
			BNE .not_float
				.float:
					LDA EXP_HI,X
					EOR #SIGN_BIT
					STA EXP_HI,X
					JMP CODE_ADD.float
			.not_float:
			
			;Subtracting hex objects
			LDA HEX_TYPE,X
			ASL
			ORA HEX_TYPE+OBJ_SIZE,X
			BNE .not_raw_hex
				;Both raw hex
				.hex:
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
					JSR TosR0R1
					JSR BCD_Mult
					JSR CODE_DROP+EXEC_HEADER
					JMP RansTos
			mult_not_float:
			
			;Multiplying hex objects
			LDA HEX_TYPE,X
			TODO: why?
			ASL
			ORA HEX_TYPE+OBJ_SIZE,X
			BNE .not_raw_hex
				;Both raw hex
				
				TODO: 16 bit multiply faster than bytes?
				
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
					JSR TosR0R1
					JSR BCD_Div
					LDA ret_val
					BEQ .no_error
						RTS
					.no_error:
					JSR CODE_DROP+EXEC_HEADER
					JMP RansTos
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
			
			;LDA obj_address
			LDA ret_address
			STA HEX_BASE,X
			STA HEX_SUM,X
			;LDA obj_address+1
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
			
			;Do not drop address!
			
			LDA HEX_SUM,X
			STA ret_address
			LDA HEX_SUM+1,X
			STA ret_address+1
			JSR CODE_DROP+EXEC_HEADER
			
			TODO: check token instead?
			;primitve or word?
			LDY #0
			LDA (ret_address),Y
			CLC
			ADC #4
			TAY
			LDA (ret_address),Y
			CMP #OBJ_PRIMITIVE
			BEQ .primitive
			CMP #OBJ_SECONDARY
			BEQ .secondary
				LDA #ERROR_WRONG_TYPE
				STA ret_val
				RTS
			.primitive:
				TYA
				CLC
				ADC ret_address
				STA ret_address
				BCC .no_c
					INC ret_address+1
				.no_c:
				JMP ExecToken.address_ready
			.secondary:
				
				;Save offset into word
				STY R0
				
				;Drop return address
				PLA
				PLA
				
				TODO: abstract with WORD_SECONDARY
				;Push current thread address to stack
				LDA exec_ptr
				CLC
				ADC #1
				TAY
				LDA exec_ptr+1
				ADC #0
				PHA
				TYA
				PHA
				
				;Load new thread address
				LDY R0
				INY
				INY
				INY
				TYA
				CLC
				ADC ret_address
				STA exec_ptr
				LDA ret_address+1
				ADC #0
				STA exec_ptr+1
				
				JMP ExecThread
				
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
			
			TODO: abstract
			;immediate mode only
			LDA mode
			CMP #MODE_COMPILE
			BNE .not_compile
				LDA #ERROR_IMMED_ONLY
				STA ret_val
				RTS
			.not_compile:
			
			TODO: abstract - used for var as well
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
				TODO: delete then redefine?
				BNE .error_exit
			.word_not_found:
			
			;Is word a value
			CALL CheckData
			LDA R_ans
			CMP #OBJ_ERROR
			BNE .error_exit
			
			TODO: abstract
			;Reset aux stack
			LDA #AUX_STACK_SIZE
			STA aux_stack_ptr
			LDA #0
			STA aux_stack_count
			
			CALL WriteHeader
			FCB 0					;Extra space to reserve
			FDB 0					;Next address
			FCB TOKEN_SECONDARY		;Token
			FCB OBJ_SECONDARY		;Type header
			TODO: old address is always blank?
			FDB 0					;Old address
			
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
			FCB IMMED|COMPILE	;Flags
			
			TODO: check if addresses on aux stack
			
			LDA #MODE_IMMEDIATE
			STA mode
			
			;Extra byte for end token
			LDA #DICT_END_SIZE+1
			JMP DictEnd
			
	TODO: separate 6 and 12 digit floats?
	WORD_FLOAT:
		FCB 0,""				;Name
		FDB WORD_HEX			;Next word
		FCB TOKEN_FLOAT			;ID - 40
		CODE_FLOAT:
			FCB OBJ_PRIMITIVE	;Type
			FCB ADD1			;Flags
			
			TXA
			PHA
			LDA #OBJ_FLOAT
			JMP COPY_STUB
	
	TODO: shorter for raw_hex
	TODO: more efficient way than sharing stub?
	WORD_HEX:
		FCB 0,""
		FDB WORD_STRING			;Next word
		FCB TOKEN_HEX			;ID - 42
		CODE_HEX:
			FCB OBJ_PRIMITIVE	;Type
			FCB ADD1			;Flags
			
			TXA
			PHA
			LDA #OBJ_HEX
			JMP COPY_STUB
	
	TODO: more efficient way than sharing stub?	
	WORD_STRING:
		FCB 0,""
		FDB WORD_HALT			;Next word
		FCB TOKEN_STRING		;ID - 44
		CODE_STRING:
			FCB OBJ_PRIMITIVE	;Type
			FCB ADD1			;Flags

			TXA
			PHA
			LDA #OBJ_STR
			JMP COPY_STUB
		
	WORD_HALT:
		FCB 4,"HALT"			;Name
		FDB WORD_VAR			;Next word
		FCB TOKEN_HALT			;ID - 46
		CODE_HALT:
			FCB OBJ_PRIMITIVE	;Type
			FCB NONE			;Flags
			
			halt
			RTS
	
	;needed? instead use 0 STO varname
	TODO: remove to save space?
	TODO: alternate behavior inside word?
	WORD_VAR:
		FCB 3,"VAR"				;Name
		FDB WORD_VAR_THREAD		;Next word
		FCB TOKEN_VAR			;ID - 48
		CODE_VAR:
			FCB OBJ_PRIMITIVE	;Type
			FCB NONE			;Flags
			
			TODO: Share this with TICK
			CALL LineWord
			LDA new_word_len
			BNE .word_found
				.error_exit:
				LDA #ERROR_INPUT
				STA ret_val
				JMP CODE_DROP+EXEC_HEADER
			.word_found:
			
			TODO: overwrite instead
			;Check if name already exists
			CALL FindWord
			LDA ret_val
			BNE .error_exit
			
			TODO: standardize capitalization in comments			
			;Entry point for STO
			.var_create:
							
			;Allow any valid variable name even if doesn't start with character
			CALL CheckData
			LDA R_ans
			CMP #OBJ_ERROR
			BNE .error_exit
			
			CALL WriteHeader
			FCB OBJ_SIZE			;Extra space to reserve
			FDB 0					;Next address
			FCB TOKEN_VAR_THREAD	;Token
			FCB OBJ_VAR				;Type header
			FDB 0					;Old address
			
			;Check if WriteHeader ran out of memory
			LDA ret_val
			BEQ .no_error
				RTS
			.no_error:
			
			;Update dict ptr
			LDA new_word_len
			CLC
			ADC #WORD_HEADER_SIZE
			CALL IncDictPtr
			
			TODO: still needed?
			;WORD_STO, which may call this, needs obj_address 
			SEC
			LDA dict_ptr
			TODO: magic number. same 3 offset in STO
			SBC #3	
			STA obj_address
			LDA dict_ptr+1
			SBC #0
			STA obj_address+1
			
			;Write variable data
			LDA #OBJ_FLOAT
			LDY #0
			STA (dict_ptr),Y
			TYA
			INY
			.loop:
				STA (dict_ptr),Y
				INY
				CPY #OBJ_SIZE
				BNE .loop
						
			LDA #OBJ_SIZE
			CALL IncDictPtr
			
			LDA #DICT_END_SIZE
			JMP DictEnd
				
	;Copies data from variable to stack
	WORD_VAR_THREAD:
		FCB 0,""				;Name
		FDB WORD_STO			;Next word
		FCB TOKEN_VAR_THREAD	;ID - 50
		CODE_VAR_THREAD:
			FCB OBJ_PRIMITIVE	;Type
			FCB ADD1			;Flags
			
			LDY #1
			LDA (exec_ptr),Y
			STA ret_address
			INY
			LDA (exec_ptr),Y
			STA ret_address+1
			
			TXA
			PHA
			LDY #0
			.loop:
				LDA (ret_address),Y
				STA 0,X
				INX
				INY
				CPY #OBJ_SIZE
				BNE .loop
			PLA
			TAX
			
			LDA #2
			JMP IncExecPtr

	WORD_STO:
		FCB 3,"STO"				;Name
		FDB WORD_STO_CHAR		;Next word
		FCB TOKEN_STO			;ID - 52
		CODE_STO:
			FCB OBJ_PRIMITIVE	;Type
			;FCB MIN1			;Flags
			FCB IMMED			;Flags
			
			LDA mode
			CMP #MODE_IMMEDIATE
			BEQ .immediate
			
				TODO: combine with below?
				
				;Compile mode
				CALL LineWord
				LDA new_word_len
				BEQ .error_exit
				
				CALL FindWord
				;var not found, error
				LDA ret_val
				BEQ .error_exit
			
				;word found. is it a variable?
				LDY #0
				LDA (obj_address),Y
				CMP #OBJ_VAR
				BNE .error_type
				
				LDA #TOKEN_STO_THREAD
				JMP TokenArgThread
				
			.immediate:
			
				LDA stack_count
				CMP #1
				BCS .count_good
					TODO: jump table for errors ie JMP RET_ERROR_STACK_UNDERFLOW
					LDA #ERROR_STACK_UNDERFLOW
					STA ret_val
					RTS
				.count_good:
			
				CALL LineWord
				LDA new_word_len
				BNE .word_found
					.error_exit:
					LDA #ERROR_INPUT
					STA ret_val
					RTS
				.word_found:
				
				CALL FindWord
				
				;word not found. try to create variable
				LDA ret_val
				BNE .word_exists
					JSR CODE_VAR.var_create
					TODO: abstract
					LDA ret_val
					BEQ .type_good
						;Could not create variable
						RTS
				.word_exists:
				
				;word found. is it a variable?
				LDY #0
				LDA (obj_address),Y
				CMP #OBJ_VAR
				BEQ .type_good
					.error_type:
					LDA #ERROR_WRONG_TYPE
					STA ret_val
					RTS
				.type_good:
				
				LDY #3
				;Entry point for STO_THREAD
				.copy_data:
				LDA #OBJ_SIZE
				STA R0
				TXA
				PHA
				.loop:
					LDA 0,X
					STA (obj_address),Y
					INX
					INY
					DEC R0
					BNE .loop
				PLA
				TAX
				
				LDA #ERROR_NONE
				STA ret_val
				JMP CODE_DROP+EXEC_HEADER
	
	;One character shortcut for STO
	WORD_STO_CHAR:
		FCB 1,CHAR_STO			;Name
		FDB WORD_FREE			;Next word
		FCB TOKEN_STO			;ID - 52
		CODE_STO_CHAR:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN1			;Flags
			
			JMP CODE_STO
	
	TODO: this is called UNUSED in forth
	TODO: not needed if shown in interface
	WORD_FREE:
		FCB 4,"FREE"			;Name
		FDB WORD_SECONDARY		;Next word
		FCB TOKEN_FREE			;ID - 54
		CODE_FREE:
			FCB OBJ_PRIMITIVE	;Type
			FCB ADD1			;Flags
			
			LDA #OBJ_HEX
			STA 0,X
			LDA #dict_end % 256
			SEC
			SBC dict_ptr
			STA HEX_SUM,X
			LDA #dict_end/256
			SBC dict_ptr+1
			STA HEX_SUM+1,X
			LDA #0
			STA HEX_TYPE,X
			RTS
	
	WORD_SECONDARY:
		FCB 0,""					;Name
		FDB WORD_EXIT				;Next word
		FCB TOKEN_SECONDARY			;ID - 56
		CODE_SECONDARY:
			FCB OBJ_PRIMITIVE		;Type
			FCB NONE				;Flags
			
			TODO: check stack space left to prevent underflow
			
			;Drop return address
			PLA
			PLA
			
			;Increase word counter
			INC aux_word_counter
			
			;Push current thread address to stack
			LDA exec_ptr
			CLC
			ADC #3
			TAY
			LDA exec_ptr+1
			ADC #0
			PHA
			TYA
			PHA
			
			;Load new thread address
			LDY #1
			LDA (exec_ptr),Y
			PHA
			INY
			LDA (exec_ptr),Y
			STA exec_ptr+1
			PLA 
			STA exec_ptr
			
			JMP ExecThread
			
	WORD_EXIT:
		FCB 4,"EXIT"			;Name
		FDB WORD_BREAK			;Next word
		FCB TOKEN_EXIT			;ID - 58
		CODE_EXIT:
			FCB OBJ_PRIMITIVE				;Type
			FCB COMPILE|IMMED				;Flags
			
			;Drop return address
			PLA
			PLA
			
			;Lay down EXIT_THREAD TOKEN
			LDA #TOKEN_EXIT_THREAD
			STA ret_val
			JMP main.compile_word
	
	TODO: necessary to reset stack?
	;Break out of all threads but continue processing input
	;(ending token for top level thread)
	WORD_BREAK:
		FCB 0,""				;Name
		FDB WORD_QUIT			;Next word
		FCB TOKEN_BREAK			;ID - 60
		CODE_BREAK:
			FCB OBJ_PRIMITIVE				;Type
			FCB NONE						;Flags
			
			;Reset R stack
			TXA
			LDX #R_STACK_SIZE-1
			TXS
			TAX
			
			JMP main.process_loop
	
	;Reset buffers and r and aux stacks
	WORD_QUIT:
		FCB 4,"QUIT"			;Name
		FDB WORD_STO_THREAD		;Next word
		FCB TOKEN_QUIT			;ID - 62
		CODE_QUIT:
			FCB OBJ_PRIMITIVE				;Type
			FCB NONE						;Flags
			
			;Clear input buffer
			LDA input_buff_begin
			STA input_buff_end
			
			TODO: abstract
			;Reset aux stack
			LDA #0
			STA aux_stack_count
			STA aux_word_counter
			LDA #AUX_STACK_SIZE-1
			STA aux_stack_ptr
			
			;Continues processing input so can't use
			;JMP CODE_BREAK+EXEC_HEADER
			
			TODO: combine with above?
			;Reset R stack
			TXA
			LDX #R_STACK_SIZE-1
			TXS
			TAX
			
			LDA #MODE_IMMEDIATE
			STA mode
			
			JMP main.mode_good
	
	WORD_STO_THREAD:
		FCB 0,""				;Name
		FDB WORD_DO				;Next word
		FCB TOKEN_STO_THREAD	;ID - 64
		CODE_STO_THREAD:
			FCB OBJ_PRIMITIVE	;Type
			FCB NONE			;Flags
			
			LDY #1
			LDA (exec_ptr),Y
			STA obj_address
			INY
			LDA (exec_ptr),Y
			STA obj_address+1
			
			LDA #2
			JSR IncExecPtr
			
			LDY #0
			JMP CODE_STO.copy_data
			
	WORD_DO:
		FCB 2,"DO"				;Name
		FDB WORD_DO_THREAD		;Next word
		FCB TOKEN_DO			;ID - 66
		CODE_DO:
			FCB OBJ_PRIMITIVE				;Type
			FCB IMMED|COMPILE				;Flags
			
			LDA #AUX_TYPE_DO
			JSR AuxPushShort
			TODO: change every function to LDA ret_val on exit?
			LDA ret_val
			BEQ .mem_good
				RTS
			.mem_good:
			
			;LDY aux_stack_ptr - Y set after AuxPushShort
			;LOOP adds +3 so -3 here
			SEC
			LDA dict_ptr
			SBC #3
			STA AUX_STACK+1,Y
			LDA dict_ptr+1
			SBC #0
			STA AUX_STACK+2,Y
			
			TODO: abstract next 5 lines?
			;Drop return address
			PLA
			PLA
			
			;Lay down DO_THREAD TOKEN
			LDA #TOKEN_DO_THREAD
			STA ret_val
			JMP main.compile_word
			
	WORD_DO_THREAD:
		FCB 0,""				;Name
		FDB WORD_LOOP			;Next word
		FCB TOKEN_DO_THREAD		;ID - 68
		CODE_DO_THREAD:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|FLOATS					;Flags
			
			;Check if room on aux stack
			LDA aux_stack_count
			CMP #AUX_STACK_COUNT
			BNE .mem_good
				LDA #ERROR_OUT_OF_MEM
				STA ret_val
				RTS
			.mem_good:
			INC aux_stack_count
			
			;Decrease stack pointer
			SEC
			LDA aux_stack_ptr
			SBC #AUX_STACK_ITEM_SIZE
			STA aux_stack_ptr
			TAY
			LDA aux_word_counter
			STA AUX_STACK,Y
			
			;Copy values from stack to aux stack
			LDA #OBJ_SIZE-TYPE_SIZE
			STA R0
			.loop:
				LDA TYPE_SIZE,X
				STA AUX_STACK+AUX_ITER_OFFSET,Y
				LDA TYPE_SIZE+OBJ_SIZE,X
				STA AUX_STACK+AUX_LIMIT_OFFSET,Y
				INX
				INY
				DEC R0
				BNE .loop
			
			;Reset data stack pointer
			TXA
			SEC
			SBC #8
			TAX
			
			JSR CODE_DROP+EXEC_HEADER
			JMP CODE_DROP+EXEC_HEADER
			
	WORD_LOOP:
		FCB 4,"LOOP"			;Name
		FDB WORD_LOOP_THREAD	;Next word
		FCB TOKEN_LOOP			;ID - 70
		CODE_LOOP:
			FCB OBJ_PRIMITIVE				;Type
			FCB IMMED|COMPILE				;Flags
			
			.loop:
				;At least one address on aux stack?
				JSR AuxPopShort
				LDA ret_val
				BEQ .pop_good
					RTS
				.pop_good:
			
				TODO: abstract?
				;Address right type?
				LDY aux_stack_ptr
				LDA AUX_STACK-3,Y
				CMP #AUX_TYPE_DO
				BEQ .loop_done
				CMP #AUX_TYPE_LEAVE
				BEQ .process_leave
					LDA #ERROR_STRUCTURE
					STA ret_val
					RTS
				.process_leave:
					LDA AUX_STACK-2,Y
					STA ret_address
					LDA AUX_STACK-1,Y
					STA ret_address+1
					
					;Increment by 2 to point past LOOP
					CLC
					LDA dict_ptr
					ADC #2
					LDY #1
					STA (ret_address),Y
					LDA dict_ptr+1
					ADC #0
					INY
					STA (ret_address),Y
					
					JMP .loop
					
				.loop_done:
			
			;Lay down LOOP_THREAD TOKEN
			LDA AUX_STACK-2,Y
			STA obj_address
			LDA AUX_STACK-1,Y
			STA obj_address+1
			LDA #TOKEN_LOOP_THREAD
			JMP TokenArgThread
			
	WORD_LOOP_THREAD:
		FCB 0,""				;Name
		FDB WORD_EQUAL			;Next word
		FCB TOKEN_LOOP_THREAD	;ID - 72
		CODE_LOOP_THREAD:
			FCB OBJ_PRIMITIVE				;Type
			FCB NONE						;Flags
			
			TODO: abstract
			;Copy aux stack item to temp register
			LDY aux_stack_ptr
			TXA
			PHA
			LDX #OBJ_SIZE-TYPE_SIZE
			.loop:
				;ie, end of pair which is last byte of iterator in limit/iterator pair
				LDA AUX_STACK+AUX_ITER_OFFSET+OBJ_SIZE-TYPE_SIZE-1,Y
				STA R0,X
				LDA #0
				STA R1,X
				DEY
				DEX
				BNE .loop
			PLA
			TAX
			
			;Set leading digit of R1 to 1, ie 1e0
			LDA #$10
			STA R1+6
			
			;Increment iterator
			JSR BCD_Add
			
			;Copy iterator back to aux stack and iterator and limit to temp regs
			LDY aux_stack_ptr
			TXA
			PHA
			LDX #OBJ_SIZE-TYPE_SIZE
			.copy_loop:
				LDA R_ans,X
				STA AUX_STACK+AUX_ITER_OFFSET+OBJ_SIZE-TYPE_SIZE-1,Y
				STA R0,X
				LDA AUX_STACK+AUX_LIMIT_OFFSET+OBJ_SIZE-TYPE_SIZE-1,Y
				STA R1,X
				DEY
				DEX
				BNE .copy_loop
			PLA
			TAX
			
			;Compare iterator to limit
			LDA R0+EXP_HI
			EOR #SIGN_BIT
			STA R0+EXP_HI
			JSR BCD_Add
			
			;Iterator reached limit?
			LDA R_ans+DEC_COUNT/2
			BEQ .loop_done
			
			;Iterator overshot limit?
			LDA R_ans+EXP_HI
			AND #SIGN_BIT
			BNE .loop_done
			
				;;Haven't reached limit. Jump to head of loop
				;LDY #1
				;LDA (exec_ptr),Y
				;PHA
				;INY
				;LDA (exec_ptr),Y
				;STA exec_ptr+1
				;PLA 
				;STA exec_ptr
				;RTS
			
				JMP CODE_AGAIN_THREAD+EXEC_HEADER
			
			.loop_done:
			
			;Pop limit and iterator off aux stack
			CLC
			LDA aux_stack_ptr
			ADC #AUX_STACK_ITEM_SIZE
			STA aux_stack_ptr
			DEC aux_stack_count
			
			LDA #2
			JMP IncExecPtr
			
	WORD_EQUAL:
		FCB 1,"="				;Name
		FDB WORD_GT				;Next word
		FCB TOKEN_EQUAL			;ID - 74
		CODE_EQUAL:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|SAME					;Flags

			JSR COMPARISON_STUB
			
			CMP #OBJ_FLOAT
			BNE .not_float
			
				;Float
				LDA DEC_COUNT/2,X
				BNE .false
					JMP HexTrue
				.false:
				JMP HexFalse
			.not_float:
			
			;Hex
			LDA HEX_SUM,X
			ORA HEX_SUM+1,X
			BNE .false
			JMP HexTrue
			
	WORD_GT:
		FCB 1,">"				;Name
		FDB WORD_LT				;Next word
		FCB TOKEN_GT			;ID - 76
		CODE_GT:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|SAME					;Flags
			
			LDA 0,X
			CMP #OBJ_HEX
			BNE .not_hex
			
				;Hex
				;Must subtract here to observe sign
				TODO: set sign in hex_sub?
				SEC
				LDA HEX_SUM+OBJ_SIZE,X
				SBC HEX_SUM,X
				STA R0
				LDA HEX_SUM+OBJ_SIZE+1,X
				SBC HEX_SUM+1,X
				BCC .hex_false
				ORA R0
				BEQ .hex_false
				;Could call once but then stack item doesn't exist! not safe for interrupts
				JSR CODE_DROP+EXEC_HEADER
				JMP HexTrue
				.hex_false:
				JSR CODE_DROP+EXEC_HEADER
				JMP HexFalse
			.not_hex:
			
			JSR COMPARISON_STUB
			
			;Float
			LDA EXP_HI,X
			AND #SIGN_BIT
			BNE .false
				LDA DEC_COUNT/2,X
				BEQ .false
				JMP HexTrue
			.false:
			JMP HexFalse
			
	WORD_LT:
		FCB 1,"<"				;Name
		FDB WORD_NEQ			;Next word
		FCB TOKEN_LT			;ID - 78
		CODE_LT:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|SAME					;Flags

			JSR CODE_SWAP+EXEC_HEADER
			JMP CODE_GT+EXEC_HEADER
	
	WORD_NEQ:
		FCB 2,"<>"				;Name
		FDB WORD_I				;Next word
		FCB TOKEN_NEQ			;ID - 80
		CODE_NEQ:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|SAME					;Flags
			
			JSR CODE_EQUAL+EXEC_HEADER
			LDA ret_val
			BEQ .no_error
				RTS
			.no_error:
			
			;Invert return value
			LDA HEX_SUM,X
			EOR #$FF
			STA HEX_SUM,X
			LDA HEX_SUM+1,X
			EOR #$FF
			STA HEX_SUM+1,X
			
			RTS
				
	WORD_I:
		FCB 1,"I"				;Name
		FDB WORD_J				;Next word
		FCB TOKEN_I				;ID - 82
		CODE_I:
			FCB OBJ_PRIMITIVE				;Type
			FCB ADD1 						;Flags
			
			JSR WITHIN_WORD
			
			LDA aux_stack_count
			BNE .count_good
				.error_exit:
				LDA #ERROR_STRUCTURE
				STA ret_val
				JMP CODE_DROP+EXEC_HEADER
			.count_good:
			
			LDA aux_stack_ptr
			
			;Entry point for J and K
			.push_stack:
			TAY
			LDA #OBJ_FLOAT
			STA 0,X
			LDA #OBJ_SIZE-TYPE_SIZE
			STA R0
			.loop:
				LDA AUX_STACK+AUX_ITER_OFFSET,Y
				STA 1,X
				INX
				INY
				DEC R0
				BNE .loop
			
			TODO: abstract
			;Reset stack pointer
			SEC
			TXA
			SBC #OBJ_SIZE-TYPE_SIZE
			TAX
			
			RTS
	
	WORD_J:
		FCB 1,"J"				;Name
		FDB WORD_K				;Next word
		FCB TOKEN_J				;ID - 84
		CODE_J:
			FCB OBJ_PRIMITIVE				;Type
			FCB ADD1 						;Flags
			
			JSR WITHIN_WORD
			
			LDA aux_stack_count
			CMP #2
			BCC CODE_I.error_exit
			
			LDA aux_stack_ptr
			CLC
			ADC #AUX_STACK_ITEM_SIZE
			
			JMP CODE_I.push_stack
	
	WORD_K:
		FCB 1,"K"				;Name
		FDB WORD_EXIT_THREAD	;Next word
		FCB TOKEN_K				;ID - 86
		CODE_K:
			FCB OBJ_PRIMITIVE				;Type
			FCB ADD1 						;Flags
			
			JSR WITHIN_WORD
			
			LDA aux_stack_count
			CMP #3
			BCC CODE_I.error_exit
			
			LDA aux_stack_ptr
			CLC
			ADC #AUX_STACK_ITEM_SIZE*2
			
			JMP CODE_I.push_stack
	
	WORD_EXIT_THREAD:
		FCB 0,""				;Name
		FDB WORD_BEGIN			;Next word
		FCB TOKEN_EXIT_THREAD	;ID - 88
		CODE_EXIT_THREAD:
			FCB OBJ_PRIMITIVE				;Type
			FCB NONE	 					;Flags
			
			;Dump any DO values
			LDA aux_stack_count
			BEQ .done
			STA R0
			.loop:
				LDY aux_stack_ptr			
				LDA AUX_STACK,Y
				CMP aux_word_counter
				BNE .done
					TYA
					CLC
					ADC #AUX_STACK_ITEM_SIZE
					STA aux_stack_ptr
					DEC aux_stack_count
					DEC R0
					BNE .loop
			.done:
			
			;Decrease word counter
			LDA aux_word_counter
			BEQ .no_dec
				DEC aux_word_counter
			.no_dec:
			
			;Drop return address
			PLA
			PLA
			
			;Pop next address or return if no addresses left
			PLA
			STA exec_ptr
			PLA
			STA exec_ptr+1
			JMP ExecThread
			
	WORD_BEGIN:
		FCB 5,"BEGIN"		;Name
		FDB WORD_AGAIN		;Next word
		FCB TOKEN_BEGIN		;ID - 90
		CODE_BEGIN:
			FCB OBJ_PRIMITIVE				;Type
			FCB IMMED|COMPILE				;Flags
			
			LDA #AUX_TYPE_BEGIN
			JSR AuxPushShort
			LDA ret_val
			BEQ .mem_good
				RTS
			.mem_good:
			
			TODO: abstract
			;LDY aux_stack_ptr - Y set after AuxPushShort
			;LOOP adds +3 so -3 here
			SEC
			LDA dict_ptr
			;SBC #3		;LOOP skips DO_THREAD token
			SBC #4		;no BEGIN_THREAD token to skip when jumping back
			STA AUX_STACK+1,Y
			LDA dict_ptr+1
			SBC #0
			STA AUX_STACK+2,Y
			
			RTS
			
	WORD_AGAIN:
		FCB 5,"AGAIN"			;Name
		FDB WORD_AGAIN_THREAD	;Next word
		FCB TOKEN_AGAIN			;ID - 92
		CODE_AGAIN:
			FCB OBJ_PRIMITIVE				;Type
			FCB IMMED|COMPILE				;Flags
			
			;At least one address on aux stack?
			JSR AuxPopShort
			LDA ret_val
			BEQ .pop_good
				RTS
			.pop_good:
			
			TODO: abstract?
			;Address right type?
			LDY aux_stack_ptr
			LDA AUX_STACK-3,Y
			CMP #AUX_TYPE_BEGIN
			BEQ .type_good
				LDA #ERROR_STRUCTURE
				STA ret_val
				RTS
			.type_good:
			
			;Lay down AGAIN_THREAD TOKEN
			LDA AUX_STACK-2,Y
			STA obj_address
			LDA AUX_STACK-1,Y
			STA obj_address+1
			LDA #TOKEN_AGAIN_THREAD
			JMP TokenArgThread
			
	TODO: remove all 0 length words from dictionary - dont need dict header
	WORD_AGAIN_THREAD:
		FCB 0,""				;Name
		FDB WORD_UNTIL			;Next word
		FCB TOKEN_AGAIN_THREAD	;ID - 94
		CODE_AGAIN_THREAD:
			FCB OBJ_PRIMITIVE			;Type
			FCB NONE					;Flags
			
			LDY #1
			LDA (exec_ptr),Y
			PHA
			INY
			LDA (exec_ptr),Y
			STA exec_ptr+1
			PLA 
			STA exec_ptr
			RTS
	
	WORD_UNTIL:
		FCB 5,"UNTIL"			;Name
		FDB WORD_UNTIL_THREAD	;Next word
		FCB TOKEN_UNTIL			;ID - 96
		CODE_UNTIL:
			FCB OBJ_PRIMITIVE			;Type
			FCB COMPILE|IMMED			;Flags
			
			;At least one address on aux stack?
			JSR AuxPopShort
			LDA ret_val
			BEQ .pop_good
				RTS
			.pop_good:
			
			TODO: abstract?
			;Address right type?
			LDY aux_stack_ptr
			LDA AUX_STACK-3,Y
			CMP #AUX_TYPE_BEGIN
			BEQ .type_good
				LDA #ERROR_STRUCTURE
				STA ret_val
				RTS
			.type_good:
			
			;Lay down UNTIL_THREAD TOKEN
			LDA AUX_STACK-2,Y
			STA obj_address
			LDA AUX_STACK-1,Y
			STA obj_address+1
			LDA #TOKEN_UNTIL_THREAD
			JMP TokenArgThread
				
	WORD_UNTIL_THREAD:
		FCB 0,""				;Name
		FDB WORD_MAX			;Next word
		FCB TOKEN_UNTIL_THREAD	;ID - 98
		CODE_UNTIL_THREAD:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN1						;Flags
			
			LDA 0,X
			CMP #OBJ_FLOAT
			BNE .not_float
				
				;Float
				LDA DEC_COUNT/2,X
				JMP .handle
				
			.not_float:
			CMP #OBJ_HEX
			BNE .string
				
				;Hex
				LDA HEX_SUM,X
				ORA HEX_SUM+1,X
				JMP .handle
				
			.string:
				
				;String
				LDA 1,X
			
			.handle:
				BNE .done
			
				;Jump back to BEGIN
				JSR CODE_DROP+EXEC_HEADER
				JMP CODE_AGAIN_THREAD+EXEC_HEADER
			.done:
				
				;Done with loop
				JSR CODE_DROP+EXEC_HEADER
				LDA #2
				JMP IncExecPtr
		
	WORD_MAX:
		FCB 3,"MAX"				;Name
		FDB WORD_MIN			;Next word
		FCB TOKEN_MAX			;ID - 100
		CODE_MAX:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|SAME					;Flags
			
			JSR MIN_MAX_STUB
			
			LDA HEX_SUM,X
			BEQ .nip
				.drop:
				;Top number larger, drop lower number
				JSR CODE_DROP+EXEC_HEADER
				JMP CODE_DROP+EXEC_HEADER
			.nip:
			
			;Lower number larger, nip top number
			JSR CODE_DROP+EXEC_HEADER
			JSR CODE_SWAP+EXEC_HEADER
			JMP CODE_DROP+EXEC_HEADER
			
	WORD_MIN:
		FCB 3,"MIN"				;Name
		FDB WORD_AND			;Next word
		FCB TOKEN_MIN			;ID - 102
		CODE_MIN:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|SAME					;Flags
	
			JSR MIN_MAX_STUB
			
			LDA HEX_SUM,X
			BEQ CODE_MAX.drop
			BNE CODE_MAX.nip
					
	WORD_AND:
		FCB 3,"AND"				;Name
		FDB WORD_OR				;Next word
		FCB TOKEN_AND			;ID - 104
		CODE_AND:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|HEX					;Flags
			
			JSR LOGIC_STUB
			AND HEX_SUM+OBJ_SIZE,X
			STA HEX_SUM+OBJ_SIZE,X
			LDA HEX_SUM+1,X
			AND HEX_SUM+OBJ_SIZE+1,X
			STA HEX_SUM+OBJ_SIZE+1,X
		
			JMP CODE_DROP+EXEC_HEADER
	
	WORD_OR:
		FCB 2,"OR"				;Name
		FDB WORD_XOR			;Next word
		FCB TOKEN_OR			;ID - 106
		CODE_OR:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|HEX					;Flags
			
			JSR LOGIC_STUB
			ORA HEX_SUM+OBJ_SIZE,X
			STA HEX_SUM+OBJ_SIZE,X
			LDA HEX_SUM+1,X
			ORA HEX_SUM+OBJ_SIZE+1,X
			STA HEX_SUM+OBJ_SIZE+1,X
		
			JMP CODE_DROP+EXEC_HEADER
	
	WORD_XOR:
		FCB 3,"XOR"				;Name
		FDB WORD_NOT			;Next word
		FCB TOKEN_XOR			;ID - 108
		CODE_XOR:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|HEX					;Flags
		
			JSR LOGIC_STUB
			EOR HEX_SUM+OBJ_SIZE,X
			STA HEX_SUM+OBJ_SIZE,X
			LDA HEX_SUM+1,X
			EOR HEX_SUM+OBJ_SIZE+1,X
			STA HEX_SUM+OBJ_SIZE+1,X
		
			JMP CODE_DROP+EXEC_HEADER
			
	WORD_NOT:
		FCB 3,"NOT"				;Name
		FDB WORD_LEAVE			;Next word
		FCB TOKEN_NOT			;ID - 110
		CODE_NOT:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN1|HEX					;Flags
		
			JSR LOGIC_STUB
			ORA HEX_SUM+1,X
			BEQ .set_true
				LDA #0
				.set:
				;True so set false
				STA HEX_SUM,X
				STA HEX_SUM+1,X
				RTS
			.set_true:
			LDA #$FF
			BNE .set
					
	WORD_LEAVE:
		FCB 5,"LEAVE"			;Name
		FDB WORD_LEAVE_THREAD	;Next word
		FCB TOKEN_LEAVE			;ID - 112
		CODE_LEAVE:
			FCB OBJ_PRIMITIVE				;Type
			FCB COMPILE|IMMED				;Flags
			
			TODO: abstract with DO?
			LDA #AUX_TYPE_LEAVE
			JSR AuxPushShort
			LDA ret_val
			BEQ .mem_good
				RTS
			.mem_good:
			
			LDA dict_ptr
			STA AUX_STACK+1,Y
			LDA dict_ptr+1
			STA AUX_STACK+2,Y
			
			;Drop return address
			PLA
			PLA
			
			;Lay down LEAVE_THREAD TOKEN
			LDA #TOKEN_LEAVE_THREAD
			JMP TokenArgThread
			
	;Waste of space, but need table entry unless add code for exception
	WORD_LEAVE_THREAD:
		FCB 0,""				;Name
		FDB WORD_IF				;Next word
		FCB TOKEN_LEAVE_THREAD	;ID - 114
		CODE_LEAVE_THREAD:
			FCB OBJ_PRIMITIVE				;Type
			FCB NONE						;Flags
			
			JMP CODE_AGAIN_THREAD+EXEC_HEADER
	
	WORD_IF:
		FCB 2,"IF"				;Name
		FDB WORD_THEN			;Next word
		FCB TOKEN_IF			;ID - 116
		CODE_IF:
			FCB OBJ_PRIMITIVE				;Type
			FCB COMPILE|IMMED				;Flags
			
			LDA #AUX_TYPE_IF
			JSR AuxPushShort
			TODO: change every function to LDA ret_val on exit?
			LDA ret_val
			BEQ .mem_good
				RTS
			.mem_good:
			
			;LDY aux_stack_ptr - Y set after AuxPushShort
			LDA dict_ptr
			STA AUX_STACK+1,Y
			LDA dict_ptr+1
			STA AUX_STACK+2,Y
			
			;Lay down IF_THREAD TOKEN
			LDA  #TOKEN_UNTIL_THREAD ;identical to IF_THREAD
			JMP TokenArgThread
			
	WORD_THEN:
		FCB 4,"THEN"			;Name
		FDB WORD_ELSE			;Next word
		FCB TOKEN_THEN			;ID - 118
		CODE_THEN:
			FCB OBJ_PRIMITIVE				;Type
			FCB COMPILE|IMMED				;Flags
			
			JSR AUX_STUB
			CMP #AUX_TYPE_IF
			BEQ .process_if
				
				;Error - not if
				LDA #ERROR_STRUCTURE
				STA ret_val
				RTS
			.process_if:
			
			;Write IF address
			LDA AUX_STACK-2,Y
			STA ret_address
			LDA AUX_STACK-1,Y
			STA ret_address+1
			
			SEC
			LDA dict_ptr
			SBC #1
			LDY #1
			STA (ret_address),Y
			LDA dict_ptr+1
			SBC #0
			INY
			STA (ret_address),Y
			
			RTS

	WORD_ELSE:
		FCB 4,"ELSE"			;Name
		FDB WORD_LSHIFT			;Next word
		FCB TOKEN_ELSE			;ID - 120
		CODE_ELSE:
			FCB OBJ_PRIMITIVE				;Type
			FCB COMPILE|IMMED				;Flags
			
			;Can't use AUX_STUB since reusing existing stack item
			;At least one stack item?
			LDA aux_stack_count
			BEQ .error_exit
			
			TODO: change AUX_STACK offset to -3 to share code?
			LDY aux_stack_ptr
			LDA AUX_STACK,Y
			CMP #AUX_TYPE_IF
			BEQ .process_if
				
				;Error - not if
				.error_exit:
				LDA #ERROR_STRUCTURE
				STA ret_val
				RTS
			.process_if:
			
			;Write IF address
			LDA AUX_STACK+1,Y
			STA ret_address
			LDA AUX_STACK+2,Y
			STA ret_address+1
			
			;Update existing IF address
			LDA dict_ptr
			STA AUX_STACK+1,Y
			LDA dict_ptr+1
			STA AUX_STACK+2,Y
			
			;Point past ELSE
			CLC
			LDA dict_ptr
			ADC #2
			LDY #1
			STA (ret_address),Y
			LDA dict_ptr+1
			ADC #0
			INY
			STA (ret_address),Y
			
			;Lay down ELSE_THREAD TOKEN
			LDA  #TOKEN_AGAIN_THREAD ;identical to ELSE_THREAD
			JMP TokenArgThread
			
	WORD_LSHIFT:
		FCB 6,"LSHIFT"			;Name
		FDB dict_begin			;Next word
		FCB TOKEN_LSHIFT		;ID - 122
		CODE_LSHIFT:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|HEX					;Flags	
			
			TODO: share with rshift
			
			;Smart
			LDA HEX_TYPE,X
			ORA HEX_TYPE+OBJ_SIZE,X
			BEQ .hex_raw
				;At least one smart hex, so can't shift
				LDA #ERROR_WRONG_TYPE
				STA ret_val
				RTS
			.hex_raw:
			
			;If >=16, return 0
			SEC
			LDA HEX_SUM,X
			SBC #16
			LDA HEX_SUM+1,X
			SBC #0
			BCC .zero_check
				LDA #0
				STA HEX_SUM+OBJ_SIZE,X
				STA HEX_SUM+OBJ_SIZE+1,X
				JMP CODE_DROP+EXEC_HEADER
			
			.zero_check:
			LDA HEX_SUM,X
			BEQ .done
			
			.shift:
			ASL HEX_SUM+OBJ_SIZE,X
			ROL HEX_SUM+OBJ_SIZE+1,X
			DEC HEX_SUM,X
			BNE .shift
			
			.done:
			JMP CODE_DROP+EXEC_HEADER
			
	
	;TYPE	
	;MOD			76
	;ABS			102
	;SIN			104
	;COS			106
	;TAN			108
	;ASIN			110
	;ACOS			112
	;ATAN			114
	;^				116
	;E^				118
	;LN				120
	;LSHIFT			134
	;RSHIFT			136
	;GRAPH			138
	;LIT			144
	;WORDS			146
	;[ ]
	;JUMP
	
	;4ish zp pages also mapped to address range
	
	;Optional:
	;WHILE/REPEAT
	;RAW - convert smart hex
	;DEC - dec from hex
	;HEX - hex from dec
	;WHILE			82
	;REPEAT
	;+LOOP		;great if room
	;IMMED
	;COMPILE
	;PI
	;RESET
	;RDROP		;actually better not expose to user
	;R>
	;R<
	;R@
	;RIGHT
	;LEFT
	;+ (string)
	;CHR
	;CREATE
	;,
	;C,
	;SEE
	;EDIT
	;addresses from ZP, dict, etc onto stack
	;'STO or STO" or similar for indirection on stack
		;hmm, now mismatched though :(
	;DEPTH
	;HERE
		;may be useful even without CREATE
	;BETWEEN
		
	;Not needed:
	;>=				96		;omit to save space
	;<=				98		;omit to save space
	;FORGET			100		;do in MEM window instead
	
	JUMP_TABLE:
		FDB CODE_DUP				;2
		FDB CODE_SWAP				;4
		FDB CODE_DROP				;6
		FDB CODE_OVER				;8
		FDB CODE_ROT				;10
		FDB CODE_MIN_ROT			;12
		FDB CODE_CLEAR				;14
		FDB CODE_ADD				;16
		FDB CODE_SUB				;18
		FDB CODE_MULT				;20
		FDB CODE_DIV				;22
		FDB CODE_TICK				;24
		FDB CODE_EXEC				;26
		FDB CODE_STORE				;28
		FDB CODE_FETCH				;30
		FDB CODE_CSTORE				;32
		FDB CODE_CFETCH				;34
		FDB CODE_COLON				;36
		FDB CODE_SEMI				;38
		FDB CODE_FLOAT				;40
		FDB CODE_HEX				;42
		FDB CODE_STRING				;44
		FDB CODE_HALT				;46
		FDB CODE_VAR				;48
		FDB CODE_VAR_THREAD			;50
		FDB CODE_STO				;52
		FDB CODE_FREE				;54
		FDB CODE_SECONDARY			;56
		FDB CODE_EXIT				;58
		FDB CODE_BREAK				;60
		FDB CODE_QUIT				;62
		FDB CODE_STO_THREAD			;64
		FDB CODE_DO					;66
		FDB CODE_DO_THREAD			;68
		FDB CODE_LOOP				;70
		FDB CODE_LOOP_THREAD		;72
		FDB CODE_EQUAL				;74
		FDB CODE_GT					;76
		FDB CODE_LT					;78
		FDB CODE_NEQ				;80
		FDB CODE_I					;82
		FDB CODE_J					;84
		FDB CODE_K					;86
		FDB CODE_EXIT_THREAD		;88
		FDB CODE_BEGIN				;90
		FDB CODE_AGAIN				;92
		FDB CODE_AGAIN_THREAD		;94
		FDB CODE_UNTIL				;96
		FDB CODE_UNTIL_THREAD		;98
		FDB CODE_MAX				;100
		FDB CODE_MIN				;102
		FDB CODE_AND				;104
		FDB CODE_OR					;106
		FDB CODE_XOR				;108
		FDB CODE_NOT				;110
		FDB CODE_LEAVE				;112
		FDB CODE_LEAVE_THREAD		;114
		FDB CODE_IF					;116
		FDB CODE_THEN				;118
		FDB CODE_ELSE				;120
		FDB CODE_LSHIFT				;122
		
		
		
		
		
		