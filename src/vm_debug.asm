VM_debug_op_halt:
	JSR VM_stub_halt
	JMP VM_dispatch
	
VM_stub_halt:
	LDA #'['
	STA DEBUG
	LDA #VM_stack_end
	SEC
	SBC VM_SP
	LSR
	STA DEBUG_HEX
	LDA #']'
	STA DEBUG
	LDA #' '
	STA DEBUG
	LDX #VM_stack_end
	.loop:
		CPX VM_SP
		BEQ .done
			DEX
			DEX
			LDA 1,X
			STA DEBUG_HEX
			LDA 0,X
			STA DEBUG_HEX
			LDA #' '
			STA DEBUG
			JMP .loop
	.done:
	LDA #'\'
	STA DEBUG
	LDA #'n'
	STA DEBUG	
	halt
	RTS
	
VM_handler_debug:
	LDA VM_IP+1
	STA DEBUG_HEX
	LDA VM_IP
	STA DEBUG_HEX
	LDA #':'
	STA DEBUG
	TYA
	STA DEBUG_HEX
	LDA #' '
	STA DEBUG
	
	TYA
	SEC
	SBC #STACK_OPS_BEGIN
	TAX
	LDA #lo(VM_DEBUG_WORDS)
	STA VM_temp0
	LDA #hi(VM_DEBUG_WORDS)
	STA VM_temp1
	.loop:
		CLC
		LDA VM_temp0
		ADC VM_DEBUG_WORDS_LEN
		STA VM_temp0
		LDA VM_temp1
		ADC #0
		STA VM_temp1
		DEX
		BNE .loop
	
	TYA
	TAX
	LDY #0
	.loop2:
	LDA (VM_temp0),Y
	BEQ .done2
		STA DEBUG
		INY
		JMP .loop2
	.done2:
	TXA
	TAY
	JMP VM_stub_halt
	