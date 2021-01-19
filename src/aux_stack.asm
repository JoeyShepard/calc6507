;Auxiliary stack
;===============

;Type in A
FUNC AuxPushShort
	
	INC aux_stack_count
	LDY aux_stack_count
	CPY #AUX_STACK_SHORT_SIZE
	BNE .mem_good
		LDA #ERROR_OUT_OF_MEM
		STA ret_val
		RTS
	.mem_good:
	
	DEC aux_stack_ptr
	DEC aux_stack_ptr
	DEC aux_stack_ptr
	
	LDY aux_stack_ptr
	STA AUX_STACK,Y
	
END

FUNC AuxPopShort
	
	LDA aux_stack_count
	BNE .stack_good
		LDA #ERROR_STRUCTURE
		STA ret_val
		;RTS - doesnt matter
	.stack_good:
	DEC aux_stack_count
	CLC
	LDA aux_stack_ptr
	ADC #3
	STA aux_stack_ptr
	
END

