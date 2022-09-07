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
	JMP VM_stub_halt
	