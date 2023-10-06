;Forth word list
;===============

words_asm_begin:

	FORTH_WORDS:
	
	WORD_DUP:
		FCB 3, "DUP" 			;Name
		FDB	WORD_SWAP			;Next word
		FCB TOKEN_DUP			;ID - 2
		CODE_DUP:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN1|ADD1		;Flags
			
			LDY #OBJ_SIZE
			STX stack_X
			.dup_loop:
				LDA OBJ_SIZE,X
				STA 0,X
				INX
				DEY
				BNE .dup_loop
			LDX stack_X
			RTS

    REGS
        BYTE word_temp
	END
    WORD_SWAP:
		FCB 4, "SWAP" 			;Name
		FDB	WORD_DROP			;Next word
		FCB TOKEN_SWAP			;ID - 4
		CODE_SWAP:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN2			;Flags
			
			LDY #OBJ_SIZE
			STX stack_X
			.swap_loop:
				LDA OBJ_SIZE,X
                STA word_temp
				LDA 0,X
				STA OBJ_SIZE,X
				LDA word_temp
				STA 0,X
				INX
				DEY
				BNE .swap_loop
			LDX stack_X
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
            STX stack_X
			.over_loop:
				LDA OBJ_SIZE*2,X
				STA 0,X
				INX
				DEY
				BNE .over_loop
			LDX stack_X
			RTS
		
    REGS
        BYTE word_temp1
        BYTE word_temp2
	END
	WORD_ROT:
		FCB 3, "ROT" 			;Name
		FDB	WORD_MIN_ROT		;Next word
		FCB TOKEN_ROT			;ID - 10
		CODE_ROT:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN3			;Flags
			
			LDY #OBJ_SIZE
            STX stack_X
			.rot_loop:
				LDA OBJ_SIZE*2,X
				STA word_temp1
				LDA OBJ_SIZE,X
				STA word_temp2
				LDA 0,X
				STA OBJ_SIZE,X
				LDA word_temp2
				STA OBJ_SIZE*2,X
				LDA word_temp1
				STA 0,X
				
				INX
				DEY
				BNE .rot_loop
            LDX stack_X
			RTS
	
    REGS
        BYTE word_temp1
        BYTE word_temp2
	END
	WORD_MIN_ROT:
		FCB 4, "-ROT" 			;Name
		FDB	WORD_CLEAR			;Next word
		FCB TOKEN_MIN_ROT		;ID - 12
		CODE_MIN_ROT:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN3			;Flags
			
			LDY #OBJ_SIZE
            STX stack_X
			.min_rot_loop:
				LDA OBJ_SIZE*2,X
				STA word_temp1
				LDA OBJ_SIZE,X
				STA word_temp2
				LDA 0,X
				STA OBJ_SIZE*2,X
				LDA word_temp2
				STA 0,X
				LDA word_temp1
				STA OBJ_SIZE,X
				
				INX
				DEY
				BNE .min_rot_loop
            LDX stack_X
			RTS
	
	WORD_CLEAR:
		FCB 5,"CLEAR"			;Name
		;FCB 3,"CLR"				;Name
		FDB WORD_ADD			;Next word
		FCB TOKEN_CLEAR			;ID - 14
		CODE_CLEAR:
			FCB OBJ_PRIMITIVE	;Type
			FCB NONE			;Flags
			
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
			
			LDA OBJ_TYPE,X
			
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
			
			LDA OBJ_TYPE,X
			
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

    REGS
        WORD hex_mult_sum
        WORD hex_mult_double
        WORD hex_mult_half
    END
	WORD_MULT:
		FCB 1,"*"				;Name
		FDB WORD_DIV			;Next word
		FCB TOKEN_MULT			;ID - 20
		CODE_MULT:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN2|SAME		;Flags
	
			LDA OBJ_TYPE,X
			
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
			ASL
			ORA HEX_TYPE+OBJ_SIZE,X
			BNE .not_raw_hex
				;Both raw hex
				LDA #0
				STA hex_mult_sum
				STA hex_mult_sum+1
                LDA HEX_SUM,X
                STA hex_mult_double
                LDA HEX_SUM+1,X
                STA hex_mult_double+1
				LDA OBJ_SIZE+HEX_SUM,X
                STA hex_mult_half
				LDA OBJ_SIZE+HEX_SUM+1,X
                STA hex_mult_half+1
                LDY #16
                .mult_loop:
                    LSR hex_mult_half+1
                    ROR hex_mult_half
                    BCC .no_add
                        CLC
                        LDA hex_mult_sum
                        ADC hex_mult_double
                        STA hex_mult_sum
                        LDA hex_mult_sum+1
                        ADC hex_mult_double+1
                        STA hex_mult_sum+1
                    .no_add:
                    ASL hex_mult_double
                    ROL hex_mult_double+1
                    DEY
                    BNE .mult_loop

			    ;Write to destination
                LDA hex_mult_sum
                STA OBJ_SIZE+HEX_SUM,X
                LDA hex_mult_sum+1
                STA OBJ_SIZE+HEX_SUM+1,X
                JMP CODE_DROP+EXEC_HEADER
			.not_raw_hex:
			
			;Either strings or at least one smart hex
			LDA #ERROR_WRONG_TYPE
			STA ret_val
			RTS
			
    REGS
        WORD hex_div_low
        WORD hex_div_high
        WORD hex_div_divisor
        WORD hex_div_temp
    END
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
				STA hex_div_divisor
				LDA HEX_SUM+1,X
				STA hex_div_divisor+1
				
				ORA hex_div_divisor
				BNE .div_zero_check
					LDA #ERROR_DIV_ZERO
					STA ret_val
					RTS
				.div_zero_check:
				
				LDA OBJ_SIZE+HEX_SUM,X
				STA hex_div_low
				LDA OBJ_SIZE+HEX_SUM+1,X
				STA hex_div_low+1
				
				LDA #0
				STA hex_div_high
				STA hex_div_high+1
				
				LDY #16
				.loop:
					ASL hex_div_low
					ROL hex_div_low+1
					ROL hex_div_high
					ROL hex_div_high+1
					
					SEC
					LDA hex_div_high
					SBC hex_div_divisor
					STA hex_div_temp
					LDA hex_div_high+1
					SBC hex_div_divisor+1
					STA hex_div_temp+1
					BCC .div_underflow
						LDA hex_div_low
						ORA #1
                        STA hex_div_low
						MOV.W hex_div_temp,hex_div_high
					.div_underflow:
					DEY
					BNE .loop
				LDA hex_div_low
				STA OBJ_SIZE+HEX_SUM,X
				LDA hex_div_low+1
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
			
			CCALL FindWord
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

    REGS
        BYTE offset
    END
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

            LDA ret_address
            ORA ret_address+1
            BNE .not_null
				LDA #ERROR_BROKEN_REF
				STA ret_val
				RTS
            .not_null:
			;Primitve or word?
			LDY #0
			LDA (ret_address),Y
			CLC
			ADC #WORD_HEADER_OBJ_TYPE
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
				STY offset
				
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
				LDY offset
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

            ;Don't write to null address
            LDA HEX_SUM,X
            ORA HEX_SUM+1,X
            BEQ .null_exit
            
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
			
            .null_exit:
			JSR CODE_DROP+EXEC_HEADER
			JMP CODE_DROP+EXEC_HEADER
	
	WORD_FETCH:
		FCB 1,"@"				;Name
		FDB WORD_CSTORE			;Next word
		FCB TOKEN_FETCH			;ID - 30
		CODE_FETCH:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN1|HEX		;Flags

            ;Don't read from null address
            LDA HEX_SUM,X
            ORA HEX_SUM+1,X
            BEQ .null_read  
            
            ;Read from address
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
            JMP .done

            ;Read from null - return 0
            .null_read:
            LDA #0
            STA HEX_SUM,X
            STA HEX_SUM+1,X
            
            .done:
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

            ;Don't write to null address
            LDA HEX_SUM,X
            ORA HEX_SUM+1,X
            BEQ .null_exit

			LDA HEX_SUM,X
			STA ret_address
			LDA HEX_SUM+1,X
			STA ret_address+1
			LDY #0
			LDA OBJ_SIZE+HEX_SUM,X
			STA (ret_address),Y
			
            .null_exit:
			JSR CODE_DROP+EXEC_HEADER
			JMP CODE_DROP+EXEC_HEADER
	
	WORD_CFETCH:
		FCB 2,"C@"				;Name
		FDB WORD_COLON			;Next word
		FCB TOKEN_CFETCH		;ID - 34
		CODE_CFETCH:
			FCB OBJ_PRIMITIVE	;Type
			FCB MIN1|HEX		;Flags

            ;Don't read from null address
            LDA HEX_SUM,X
            ORA HEX_SUM+1,X
            BEQ .null_read
            
            ;Read from address
			LDA HEX_SUM,X
			STA ret_address
			LDA HEX_SUM+1,X
			STA ret_address+1
			LDY #0
			LDA (ret_address),Y
            JMP .done

            ;Read from null - return 0
            .null_read:
            LDA #0
            .done: 
            STA HEX_SUM,X
			LDA #0
			STA HEX_SUM+1,X
			LDA #HEX_NORMAL
			STA HEX_TYPE,X
			RTS
	
	WORD_COLON:
		FCB 1,":"				;Name
		FDB WORD_SEMI			;Next word
		FCB TOKEN_COLON			;ID - 36
		CODE_COLON:
			FCB OBJ_PRIMITIVE	;Type
			FCB IMMED			;Flags
		
            ;Immediate mode only
			JSR IMMED_ONLY_STUB

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
			CCALL FindWord
			LDA ret_val
			BEQ .word_not_found
				;Word exists - error instead of redefining word
				BNE .error_exit
			.word_not_found:
			
			;Is word a value?
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
			
            LDA aux_stack_count
            BEQ .no_aux_items
				LDA #ERROR_STRUCTURE
				STA ret_val
				RTS
            .no_aux_items:
			
			LDA #MODE_IMMEDIATE
			STA mode
			
			;Extra byte for end token
			LDA #DICT_END_SIZE+1
			JMP DictEnd
			
	WORD_FLOAT:
		FCB 0,""				;Name
		FDB WORD_HEX			;Next word
		FCB TOKEN_FLOAT			;ID - 40
		CODE_FLOAT:
			FCB OBJ_PRIMITIVE	;Type
			FCB ADD1			;Flags
			
			LDA #OBJ_FLOAT
			JMP COPY_STUB
	
	WORD_HEX:
		FCB 0,""
		FDB WORD_STRING			;Next word
		FCB TOKEN_HEX			;ID - 42
		CODE_HEX:
			FCB OBJ_PRIMITIVE	;Type
			FCB ADD1			;Flags
			
			LDA #OBJ_HEX
			JMP COPY_STUB
	
	WORD_STRING:
		FCB 0,""
		FDB WORD_HALT			;Next word
		FCB TOKEN_STRING		;ID - 44
		CODE_STRING:
			FCB OBJ_PRIMITIVE	;Type
			FCB ADD1			;Flags

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
	
	WORD_VAR:
		FCB 3,"VAR"				;Name
		FDB WORD_VAR_THREAD		;Next word
		FCB TOKEN_VAR			;ID - 48
		CODE_VAR:
			FCB OBJ_PRIMITIVE	;Type
			FCB IMMED			;Flags
			
			;Immediate mode only
            JSR IMMED_ONLY_STUB

			TODO: Share this with TICK
			CALL LineWord
			LDA new_word_len
			BNE .word_found
				.error_exit:
				LDA #ERROR_INPUT
				STA ret_val
				JMP CODE_DROP+EXEC_HEADER
			.word_found:
			
			;Check if name already exists
			CCALL FindWord
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
			SBC #1	
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
		
            STX stack_X
			LDY #0
			.loop:
				LDA (ret_address),Y
				STA 0,X
				INX
				INY
				CPY #OBJ_SIZE
				BNE .loop
            LDX stack_X
			
			LDA #2
			JMP IncExecPtr

    REGS
        WORD counter
    END
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
				
				CCALL FindWord
				;Var not found, error
				LDA ret_val
				BEQ .error_exit
			
				;Word found. is it a variable?
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
				
				CCALL FindWord

				;Word not found. try to create variable
				LDA ret_val
				BNE .word_exists
					JSR CODE_VAR.var_create
					TODO: abstract
					LDA ret_val
					BEQ .type_good
						;Could not create variable
						RTS
				.word_exists:
				
				;Word found. Is it a variable?
				LDY #0
				LDA (obj_address),Y
				CMP #OBJ_VAR
				BEQ .type_good
					.error_type:
					LDA #ERROR_WRONG_TYPE
					STA ret_val
					RTS
				.type_good:
			
				LDY #1
				;Entry point for STO_THREAD
				.copy_data:
				LDA #OBJ_SIZE
				STA counter
                STX stack_X
				.loop:
					LDA 0,X
					STA (obj_address),Y
					INX
					INY
					DEC counter
					BNE .loop
                LDX stack_X
				
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
	
	WORD_FREE:
		FCB 4,"FREE"			;Name
		FDB WORD_SECONDARY		;Next word
		FCB TOKEN_FREE			;ID - 54
		CODE_FREE:
			FCB OBJ_PRIMITIVE	;Type
			FCB ADD1			;Flags
		
			LDA #OBJ_HEX
			STA 0,X
			LDA #lo(dict_end)
			SEC
			SBC dict_ptr
			STA HEX_SUM,X
			LDA #hi(dict_end)
			SBC dict_ptr+1
			STA HEX_SUM+1,X
			LDA #0
			STA HEX_TYPE,X
			RTS

    REGS
        BYTE word_temp
    END
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
			ADC #3 ;Size of current token and address
			TAY
			LDA exec_ptr+1
			ADC #0
			PHA
			TYA
			PHA
			
			;Load new thread address
			LDY #1
			LDA (exec_ptr),Y
            STA word_temp
			INY
			LDA (exec_ptr),Y
			STA exec_ptr+1
			LDA word_temp
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
			JMP ForthLoop.compile_word
	
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
			
			JMP ForthLoop.process_loop
	
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
			
			TODO: combine with above?
			;Reset R stack
			TXA
			LDX #R_STACK_SIZE-1
			TXS
			TAX
	
	        JMP ForthLoop.input_loop


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
			
			TODO: test DO without loop and mismatch like DO THEN
			TODO: only DO values on aux stack? test with other things inside loop	
			
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
			JMP ForthLoop.compile_word
		
    REGS
        BYTE counter
    END
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
			STA counter
			.loop:
				LDA TYPE_SIZE,X
				STA AUX_STACK+AUX_ITER_OFFSET,Y
				LDA TYPE_SIZE+OBJ_SIZE,X
				STA AUX_STACK+AUX_LIMIT_OFFSET,Y
				INX
				INY
				DEC counter
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
				CMP #AUX_TYPE_CLEARED
				BEQ .loop
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
            STX stack_X
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
            LDX stack_X
			
			;Set leading digit of R1 to 1, ie 1e0
			LDA #$10
			STA R1+6
			
			;Increment iterator
			JSR BCD_Add
			
			;Copy iterator back to aux stack and iterator and limit to temp regs
			LDY aux_stack_ptr
            STX stack_X
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
			LDX stack_X

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
			
    REGS
        BYTE word_temp
    END
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
				STA word_temp
				LDA HEX_SUM+OBJ_SIZE+1,X
				SBC HEX_SUM+1,X
				BCC .hex_false
				ORA word_temp
				BEQ .hex_false
				;Could call once but then stack item doesn't exist! Not safe for interrupts
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
			

    REGS
        BYTE counter
    END
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
			STA counter
			.loop:
				LDA AUX_STACK+AUX_ITER_OFFSET,Y
				STA 1,X
				INX
				INY
				DEC counter
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
	
    REGS
        BYTE counter
    END
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
			STA counter
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
					DEC counter
					BNE .loop
			.done:
			
			TODO: shouldnt this always be non-zero?
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
			SBC #4		;No BEGIN_THREAD token to skip when jumping back
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
			
			.loop:
				;At least one address on aux stack?
				JSR AuxPopShort
				LDA ret_val
				BEQ .pop_good
					RTS
				.pop_good:
				
				TODO: add support for LEAVE
			
				TODO: abstract?
				;Address right type?
				LDY aux_stack_ptr
				LDA AUX_STACK-3,Y
				CMP #AUX_TYPE_BEGIN
				BEQ .type_good
				CMP #AUX_TYPE_CLEARED
				BEQ .loop
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
	
    REGS	
        BYTE word_temp
	END
    WORD_AGAIN_THREAD:
		FCB 0,""				;Name
		FDB WORD_UNTIL			;Next word
		FCB TOKEN_AGAIN_THREAD	;ID - 94
		CODE_AGAIN_THREAD:
			FCB OBJ_PRIMITIVE			;Type
			FCB NONE					;Flags
			
			;Check if Escape was pressed
            JSR ESC_CHECK_STUB
			
			LDY #1
			LDA (exec_ptr),Y
			STA word_temp
			INY
			LDA (exec_ptr),Y
			STA exec_ptr+1
			LDA word_temp
			STA exec_ptr
			RTS
	
	WORD_UNTIL:
		FCB 5,"UNTIL"			;Name
		FDB WORD_UNTIL_THREAD	;Next word
		FCB TOKEN_UNTIL			;ID - 96
		CODE_UNTIL:
			FCB OBJ_PRIMITIVE			;Type
			FCB COMPILE|IMMED			;Flags
			
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
				CMP #AUX_TYPE_BEGIN
				BEQ .type_good
				CMP #AUX_TYPE_CLEARED
				BEQ .loop
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
		
			;Check if escape was pressed
		    JSR ESC_CHECK_STUB

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
			
			TODO: was dropping return value here
			
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
			LDA  #TOKEN_UNTIL_THREAD ;Identical to IF_THREAD
			JMP TokenArgThread
			
	WORD_THEN:
		FCB 4,"THEN"			;Name
		FDB WORD_ELSE			;Next word
		FCB TOKEN_THEN			;ID - 118
		CODE_THEN:
			FCB OBJ_PRIMITIVE				;Type
			FCB COMPILE|IMMED				;Flags
			
			TODO: delete
			;v1 - does not work with LEAVE
			;JSR AUX_STUB
			;CMP #AUX_TYPE_IF
			;BEQ .process_if
			;	
			;	;Error - not if
			;	LDA #ERROR_STRUCTURE
			;	STA ret_val
			;	RTS
			;.process_if:
			;
			;;Write IF address
			;LDA AUX_STACK-2,Y
			;STA ret_address
			;LDA AUX_STACK-1,Y
			;STA ret_address+1
			;
			;SEC
			;LDA dict_ptr
			;SBC #1
			;LDY #1
			;STA (ret_address),Y
			;LDA dict_ptr+1
			;SBC #0
			;INY
			;STA (ret_address),Y
			;
			;RTS

			;v2 - changes address type from IF to NONE and leaves in place
			TODO: abstract? as above maybe
			LDY aux_stack_ptr
			.loop:
				CPY #AUX_STACK_SIZE
				BNE .stack_good
					.error_exit:
					LDA #ERROR_STRUCTURE
					STA ret_val
					RTS
				.stack_good:
				LDA AUX_STACK,Y
				CMP #AUX_TYPE_CLEARED
				BEQ .process_skip
				CMP #AUX_TYPE_LEAVE
				BEQ .process_skip
				CMP #AUX_TYPE_IF
				BEQ .process_if
					;Error - not if	
					BNE .error_exit
				.process_skip:
					INY
					INY
					INY
					JMP .loop
			
			.process_if:
			
			;Change address type from IF to CLEARED
			LDA #AUX_TYPE_CLEARED
			STA AUX_STACK,Y
			
			;Write IF address
			LDA AUX_STACK+1,Y
			STA ret_address
			LDA AUX_STACK+2,Y
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
			LDA  #TOKEN_AGAIN_THREAD ;Identical to ELSE_THREAD
			JMP TokenArgThread
	
	WORD_LSHIFT:
		TODO: delete
		;FCB 6,"LSHIFT"			;Name
		FCB 2,"LS"				;Name
		FDB WORD_RSHIFT			;Next word
		FCB TOKEN_LSHIFT		;ID - 122
		CODE_LSHIFT:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|HEX					;Flags	
			
			JSR SHIFT_STUB
			
			.shift:
			ASL HEX_SUM+OBJ_SIZE,X
			ROL HEX_SUM+OBJ_SIZE+1,X
			DEC HEX_SUM,X
			BNE .shift
			
			JMP CODE_DROP+EXEC_HEADER
	
	WORD_RSHIFT:
		TODO: delete
		;FCB 6,"RSHIFT"			;Name
		FCB 2,"RS"				;Name
		FDB WORD_ABS			;Next word
		FCB TOKEN_RSHIFT		;ID - 124
		CODE_RSHIFT:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN2|HEX					;Flags	
			
			JSR SHIFT_STUB
			
			.shift:
			LSR HEX_SUM+OBJ_SIZE+1,X
			ROR HEX_SUM+OBJ_SIZE,X
			DEC HEX_SUM,X
			BNE .shift
			
			JMP CODE_DROP+EXEC_HEADER

	WORD_ABS:
		FCB 3,"ABS"				;Name
		FDB WORD_PI				;Next word
		FCB TOKEN_ABS			;ID - 126
		CODE_ABS:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN1|FLOATS					;Flags	
			
			LDA EXP_HI,X
			AND #$7F	;Zero sign bit
			STA EXP_HI,X
			
			RTS
	
	WORD_PI:
		FCB 2,"PI"				;Name
		FDB WORD_SIN			;Next word
		FCB TOKEN_PI			;ID - 128
		CODE_PI:
			FCB OBJ_PRIMITIVE				;Type
			FCB ADD1						;Flags	
			
			JSR PUSH_STUB
			;3.1 41 59 26 53 58 97
			FCB OBJ_FLOAT, $59, $53, $26, $59, $41, $31, $00, $00
			
			;Do not optimize out! PUSH_STUB calculates return to here
			TODO: where else is PUSH_STUB used? return to caller?
			RTS
				
	WORD_SIN:
		FCB 3,"SIN"				;Name
		FDB WORD_COS			;Next word
		FCB TOKEN_SIN			;ID - 130
		CODE_SIN:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN1|FLOATS					;Flags	
			
			TODO: switch formula at ends of spectrum? sin(89.999) seems very good compared to sin(0.001)
			
			JSR CORDIC_Trig
			
			;Push CORDIC Y reg (R3) to stack
			LDX #R3
			JSR CORDIC_Pack
			JMP CORDIC_Push
			
	WORD_COS:
		FCB 3,"COS"				;Name
		FDB WORD_TAN			;Next word
		FCB TOKEN_COS			;ID - 132
		CODE_COS:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN1|FLOATS					;Flags	
			
			TODO: smaller to convert cos to sin with identity?
		
            halt

			JSR CORDIC_Trig

            halt
			
			;Clear sign if set since cos(-x) = cos(x)
            ;(at least for x=[-pi/2,pi/2])
			LDX #0
			STX CORDIC_end_sign
			
			;Push CORDIC X reg (R2) to stack
			LDX #R2
			JSR CORDIC_Pack
			JMP CORDIC_Push

	WORD_TAN:
		FCB 3,"TAN"				;Name
		FDB WORD_ASIN			;Next word
		FCB TOKEN_TAN			;ID - 134
		CODE_TAN:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN1|FLOATS					;Flags	
			
			TODO: loses accuracy near pi/2 - possible to calculate without division?
			
			JSR CORDIC_Trig
			CMP #CORDIC_CLEANUP
			BEQ .divide
			.const:
				;X,Y is 1,0 or 0,1
				LDY R3+FIRST_DIGIT
				BEQ .push0
				.error:
					;tan(pi/2)=infinity
					LDX stack_X
					CLD
					TODO: set error and exit used consistantly throughout? ie JMP ErrRangeRet
					LDA #ERROR_RANGE
					STA ret_val
					RTS
				.push0:
					;tan(0)=0
					LDX #R3
					JMP CORDIC_Push
			.divide:
			
			;Pack cosine and copy to R0 for dividing
			LDX #R2
			JSR CORDIC_Pack
			LDA #R_ans
			LDY #R0
			JSR CopyRegs
			
			;Pack sine and copy to R0 for dividing
			LDA #CORDIC_CLEANUP
			LDX #R3
			JSR CORDIC_Pack
			LDA #R_ans
			LDY #R1
			JSR CopyRegs
			
			;Divide sine by cosine
			JSR BCD_Div
			TODO: check for div by 0 error?
			JMP CORDIC_Push
	
	WORD_ASIN:
		FCB 4,"ASIN"			;Name
		FDB WORD_ACOS			;Next word
		FCB TOKEN_ASIN			;ID - 136
		CODE_ASIN:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN1|FLOATS					;Flags	
			
			;JSR CORDIC_ArcTrig
			;
			;;push CORDIC X reg (R2) to stack
			;LDX #R3
			;JSR CORDIC_Pack
			;JMP CORDIC_Push
			
			RTS
			
	WORD_ACOS:
		FCB 4,"ACOS"			;Name
		FDB WORD_ATAN			;Next word
		FCB TOKEN_ACOS			;ID - 138
		CODE_ACOS:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN1|FLOATS					;Flags	
			
			RTS
			
	WORD_ATAN:
		FCB 4,"ATAN"			;Name
		FDB WORD_DEG			;Next word
		FCB TOKEN_ATAN			;ID - 140
		CODE_ATAN:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN1|FLOATS					;Flags	
			
            ;tan(pi/2)      = tan(1.5707)=infinity
            ;tan(1.5)       = 14.1  - too big to fit into CORDIC registers
            ;tan(1.4)       = 5.79  - fits in theory but intermediate might overflow
            ;tan(pi/4=0.78) = 1     - good
            ;atan(1)        = pi/4
            ;atan(1/x)      = pi/2-atan(x)
            ;atan(x)        = pi/2-atan(1/x)

            ;IMPORTANT: X goes up to 30 when Y (atan arg) is 0.8 which is highest needed
            ;           down to 20 or so with 0.0001

			JSR CORDIC_Atan
			
			RTS
	
	WORD_DEG:
		FCB 3,"DEG"				;Name
		FDB WORD_WORDS			;Next word
		FCB TOKEN_DEG			;ID - 142
		CODE_DEG:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN1|FLOATS					;Flags	
			
			;Divide by 90
			JSR StackAddItem
			JSR PUSH_STUB
			FCB OBJ_FLOAT, $00, $00, $00, $00, $00, $90, $01, $00
			JSR TosR0R1
			JSR BCD_Div
			TODO: only error is divide by 0?
			;LDA ret_val
			;BEQ .no_error
			;	RTS
			;.no_error:
			JSR CODE_DROP+EXEC_HEADER
			JSR RansTos
			
			JSR StackAddItem
			JSR PUSH_STUB
			TODO: abstract with other calls to push this?
			FCB OBJ_FLOAT, $80, $26, $63, $79, $70, $15, $00, $00
			JSR TosR0R1
			JSR BCD_Mult
			JSR CODE_DROP+EXEC_HEADER
			JMP RansTos

    REGS WORDS
        BYTE words_mode         ;Mode: primary, variables, or user-defined words
        BYTE skip_count         ;Words to skip before starting to print words. For scrolling.
        BYTE word_count         ;Counter of words to skip then counter of words to print
        WORD word_list          ;Pointer to word list
        BYTE sel_row            ;Selected row on screen
        BYTE index              ;Index into word characters for word 
        BYTE words_temp         ;Temp storage in multiple places
        WORD next_word          ;Pointer to next word in word list
        WORD word_diff          ;Difference between next_word and current word in word_list
        BYTE words_left         ;Whether word left to draw after last drawn
        BYTE rows_drawn         ;Rows drawn to screen
        WORD sel_address        ;Address of highlighted word
        WORD gc_counter         ;Counter for garbage collection. Reused to hold address to check for gc
        WORD sel_address_body   ;Address of garbage collected word body as embedded in other words
        WORD gc_check           ;sel_address or sel_address_body depending on if var or word
    END
    WORD_WORDS:
		FCB 5,"WORDS"			    ;Name
		FDB WORD_BROKEN_REF	        ;Next word
		FCB TOKEN_WORDS			    ;ID - 144
		CODE_WORDS:
			FCB OBJ_PRIMITIVE				;Type
			FCB IMMED    					;Flags	

            JSR IMMED_ONLY_STUB
           ;Part of WORDS in fixed ROM since all words won't fit
           ;into bank 3 but WORDS needs to see bank 3 to look up
           ;info on other words.
            JMP WORD_WORDS_Search ;Jump to fixed ROM and don't return

	WORD_BROKEN_REF:
		FCB 0,""		            ;Name
		FDB WORD_LN                 ;Next word
		FCB TOKEN_BROKEN_REF        ;ID - 146
		CODE_BROKEN_REF:
			FCB OBJ_PRIMITIVE				;Type
			FCB NONE     					;Flags	

            LDA #ERROR_BROKEN_REF
            STA ret_val
            RTS

    TODO: placed before last word in primitives?
    FORTH_LAST_WORD:
	WORD_LN:
		FCB 2,"LN"		            ;Name
		FDB dict_begin              ;Next word
		FCB TOKEN_LN                ;ID - 148
		CODE_LN:
			FCB OBJ_PRIMITIVE				;Type
			FCB MIN1|FLOATS     			;Flags	

            RTS

    FORTH_WORDS_END:

	JUMP_TABLE:
		FDB CODE_DUP				;2   $02
		FDB CODE_SWAP				;4   $04
		FDB CODE_DROP				;6   $06
		FDB CODE_OVER				;8   $08
		FDB CODE_ROT				;10  $0A
		FDB CODE_MIN_ROT			;12  $0C
		FDB CODE_CLEAR				;14  $0E
		FDB CODE_ADD				;16  $10
		FDB CODE_SUB				;18  $12 
		FDB CODE_MULT				;20  $14
		FDB CODE_DIV				;22  $16
		FDB CODE_TICK				;24  $18
		FDB CODE_EXEC				;26  $1A
		FDB CODE_STORE				;28  $1C
		FDB CODE_FETCH				;30  $1E
		FDB CODE_CSTORE				;32  $20
		FDB CODE_CFETCH				;34  $22
		FDB CODE_COLON				;36  $24
		FDB CODE_SEMI				;38  $26
		FDB CODE_FLOAT				;40  $28
		FDB CODE_HEX				;42  $2A
		FDB CODE_STRING				;44  $2C
		FDB CODE_HALT				;46  $2E
		FDB CODE_VAR				;48  $30
		FDB CODE_VAR_THREAD			;50  $32
		FDB CODE_STO				;52  $34
		FDB CODE_FREE				;54  $36
		FDB CODE_SECONDARY			;56  $38
		FDB CODE_EXIT				;58  $3A
		FDB CODE_BREAK				;60  $3C
		FDB CODE_QUIT				;62  $3E
		FDB CODE_STO_THREAD			;64  $40
		FDB CODE_DO					;66  $42
		FDB CODE_DO_THREAD			;68  $44
		FDB CODE_LOOP				;70  $46
		FDB CODE_LOOP_THREAD		;72  $48
		FDB CODE_EQUAL				;74  $4A
		FDB CODE_GT					;76  $4C
		FDB CODE_LT					;78  $4E
		FDB CODE_NEQ				;80  $50
		FDB CODE_I					;82  $52
		FDB CODE_J					;84  $54
		FDB CODE_K					;86  $56
		FDB CODE_EXIT_THREAD		;88  $58
		FDB CODE_BEGIN				;90  $5A
		FDB CODE_AGAIN				;92  $5C
		FDB CODE_AGAIN_THREAD		;94  $5E
		FDB CODE_UNTIL				;96  $60
		FDB CODE_UNTIL_THREAD		;98  $62
		FDB CODE_MAX				;100 $64
		FDB CODE_MIN				;102 $66
		FDB CODE_AND				;104 $68
		FDB CODE_OR					;106 $6A
		FDB CODE_XOR				;108 $6C
		FDB CODE_NOT				;110 $6E
		FDB CODE_LEAVE				;112 $70
		FDB CODE_LEAVE_THREAD		;114 $72
		FDB CODE_IF					;116 $74
		FDB CODE_THEN				;118 $76
		FDB CODE_ELSE				;120 $78
		FDB CODE_LSHIFT				;122 $7A
		FDB CODE_RSHIFT				;124 $7C
		FDB CODE_ABS				;126 $7E
		FDB CODE_PI					;128 $80
		FDB CODE_SIN				;130 $82
		FDB CODE_COS				;132 $84
		FDB CODE_TAN				;134 $86
		FDB CODE_ASIN				;136 $88
		FDB CODE_ACOS				;138 $8A
		FDB CODE_ATAN				;140 $8C
		FDB CODE_DEG				;142 $8E
		FDB CODE_WORDS              ;144 $90
        FDB CODE_BROKEN_REF         ;146 $92
        FDB CODE_LN                 ;148 $94
       
words_asm_end:
