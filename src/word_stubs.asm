;Helper stub functions for Forth words
;=====================================

	;Used by smart hex
	HEX_RECALC:
		CLC
		LDA OBJ_SIZE+HEX_BASE,X
		ADC OBJ_SIZE+HEX_OFFSET,X
		STA OBJ_SIZE+HEX_SUM,X
		LDA OBJ_SIZE+HEX_BASE+1,X
		ADC OBJ_SIZE+HEX_OFFSET+1,X
		STA OBJ_SIZE+HEX_SUM+1,X
				
		JMP CODE_DROP+EXEC_HEADER
	
	;Copy data from thread to stack
	COPY_STUB:
		STA 0,X
		LDY #1
		.loop:
			INX
			LDA (exec_ptr),Y
			STA 0,X
			INY
			CPY #OBJ_SIZE
			BNE .loop
		PLA
		TAX
		
		LDA #OBJ_SIZE-1
		JMP IncExecPtr
	
	;Compare top two stack values
	COMPARISON_STUB:
		LDA 0,X
		CMP #OBJ_FLOAT
		BNE .not_float
			;Float
			JSR CODE_SUB.float
			LDA #OBJ_FLOAT
			RTS
		.not_float:
		CMP #OBJ_HEX
		BNE .not_hex
			;Hex 
			JSR CODE_SUB.hex
			LDA #OBJ_HEX
			RTS
		.not_hex:
		
		TODO: compare strings
	
		LDA #ERROR_WRONG_TYPE
		STA ret_val
		;Return to caller!
		PLA
		PLA
		RTS
		
	;Check if executing from inside word
	WITHIN_WORD:
		LDA aux_word_counter
		BNE .good
			LDA #ERROR_COMPILE_ONLY
			STA ret_val
			PLA
			PLA
			RTS
		.good:
		RTS
		
	;Compare top two on stack and return to caller if error
	MIN_MAX_STUB:
		TODO: larger but faster to copy to R0 and R1 since copied there anyway?
		;System has 3 extra stack levels, so still works even if user stack full
		TODO: tokenize
		;(token parser adds item, so must do here explicitly)
		JSR StackAddItem
		JSR CODE_OVER+EXEC_HEADER
		JSR StackAddItem
		JSR CODE_OVER+EXEC_HEADER
		JSR CODE_GT+EXEC_HEADER
		
		LDA ret_val
		BEQ .comparison_good
			TODO: add string support
			;Error - probably trying to compare strings
			PLA
			PLA
			JSR CODE_DROP+EXEC_HEADER
			JMP CODE_DROP+EXEC_HEADER
		.comparison_good:
		
		RTS
		
	TODO: abstract? words above check for smart hex?
	;Check if hex is type raw. Return to caller if not
	LOGIC_STUB:
		LDA HEX_TYPE,X
		CMP #HEX_SMART
		BNE .good
			;Drop return address
			PLA
			PLA
			LDA #ERROR_WRONG_TYPE
			STA ret_val
		.good:
		LDA HEX_SUM,X
		RTS
	
	TODO: abstract with LOOP and AGAIN	
	TODO: still used since change?
	AUX_STUB:
			
		;At least one address on aux stack?
		JSR AuxPopShort
		LDA ret_val
		BEQ .pop_good
			PLA
			PLA
			RTS
		.pop_good:
		
		;Address right type?
		LDY aux_stack_ptr
		LDA AUX_STACK-3,Y
		
		RTS
		
	SHIFT_STUB:
		
		;Smart
		LDA HEX_TYPE,X
		ORA HEX_TYPE+OBJ_SIZE,X
		BEQ .hex_raw
			;At least one smart hex, so can't shift
			LDA #ERROR_WRONG_TYPE
			STA ret_val
			;Return to caller
			PLA
			PLA
			RTS
		.hex_raw:
		
		;If >=16, return 0
		SEC
		LDA HEX_SUM,X
		SBC #16
		LDA HEX_SUM+1,X
		SBC #0
		BCC .zero_check
			;Return 0
			LDA #0
			STA HEX_SUM+OBJ_SIZE,X
			STA HEX_SUM+OBJ_SIZE+1,X
			BEQ .done
		
		.zero_check:
		LDA HEX_SUM,X
		BEQ .done
		RTS
		
		.done:
		PLA
		PLA
		JMP CODE_DROP+EXEC_HEADER
	
	TODO: delete and use function?
	TODO: change to use pointer rather than embedded data?
	;Push literal value onto stack
	PUSH_STUB:
		
		TODO: abstract?
		PLA
		STA ret_address
		PLA
		STA ret_address+1
		
		TXA
		PHA
		
		LDY #1
		.loop:
			LDA (ret_address),Y
			STA 0,X
			INX
			INY
			CPY #OBJ_SIZE+1
			BNE .loop
		PLA
		TAX
		
		;One byte longer. Doesn't use stack
		CLC
		LDA ret_address
		ADC #OBJ_SIZE+1
		STA ret_address
		BCC .skip
			INC ret_address+1
		.skip:
		JMP (ret_address)
		
	PUSH_STUB_0:
		JSR PUSH_STUB
		FCB OBJ_FLOAT, $00, $00, $00, $00, $00, $00, $00, $00
		RTS
			
	PUSH_STUB_1:
		JSR PUSH_STUB
		FCB OBJ_FLOAT, $00, $00, $00, $00, $00, $10, $00, $00
		RTS
	
    NEXT_WORD_STUB:
        LDY #0                  ;Point to next word
        LDA (R0+3),Y
        TAY
        INY
        LDA (R0+3),Y
        STA R1
        INY
        LDA (R0+3),Y
        STA R1+1
        RTS

    WORD_TYPE_STUB:
        LDY #0
        LDA (R0+3),Y
        CLC
        ADC #4  ;point past name to word type
        TAY
        LDA (R0+3),Y
        RTS

    WORD_SIZE_STUB:
        ;Check if next word is beginning of dictionary - only possible when searching primitives
        LDY #WORDS_WORDS_LEFT
        LDA R1+0
        CMP #lo(dict_begin)
        BNE .not_dict_begin
            LDA R1+1
            CMP #hi(dict_begin)
            BNE .not_dict_begin
                ;Next word is dict_begin! Adjust calculation
                LDA #lo(FORTH_WORDS_END-FORTH_LAST_WORD)
                STA R1+2
                LDA #hi(FORTH_WORDS_END-FORTH_LAST_WORD)
                STA R1+3
                LDY #WORDS_WORDS_DONE
                RTS
        .not_dict_begin:

        ;Check if next word is last word in dictionary
        LDA R1+1
        CMP dict_ptr+1
        BNE .not_dict_end
            LDA R1+0
            CMP dict_ptr
            BNE .not_dict_end
                ;Next word is end of dictionary
                LDY #WORDS_WORDS_DONE
        .not_dict_end:

        ;Calculate size
        SEC
        LDA R1+0
        SBC R0+3
        STA R1+2
        LDA R1+1
        SBC R0+4
        STA R1+3
        RTS 

	TODO: delete?
	TODO: check that BCD_CopyConst is smaller than this - seems only 19 bytes
	TODO: eliminate PUSH_STUB too?
	;Register in X
	;10 bytes smaller than JMP()
	TODO: much smaller in forth
	;R_COPY_STUB:
	;	TODO: abstract with PUSH_STUB?
	;	PLA
	;	STA ret_address
	;	CLC
	;	ADC #2
	;	TAY
	;	PLA
	;	STA ret_address+1
	;	ADC #0
	;	PHA
	;	TYA
	;	PHA
	;	LDY #1
	;	LDA (ret_address),Y
	;	PHA 
	;	INY 
	;	LDA (ret_address),Y
	;	STA ret_address+1
	;	PLA
	;	STA ret_address
	;	
	;	LDY #0
	;	.loop:
	;		LDA (ret_address),Y
	;		STA 0,X
	;		INY
	;		INX
	;		TODO: magic number
	;		CPY #8
	;		BNE .loop
	;	
	;	RTS
		

		
		
		
		
		
		
		
		
		
