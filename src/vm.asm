;Constants
;=========
STACK_OPS_BEGIN set 240

FUNC VM_Setup
	LDA #VM_STACK_END-1
	STA VM_sp
END

VM_next:
	INC VM_ip
	BNE .done
		INC VM_ip
	.done:
	;Fall through to VM_dispatch

VM_dispatch:
	LDY #0
	LDA (VM_ip),Y
	CMP #STACK_OPS_BEGIN
	BCC .reg_op
	;VM stack op
	SBC #STACK_OPS_BEGIN
	ASL
	TAX
	LDA VM_table_stack+1,X
	PHA
	LDA VM_table_stack,X
	PHA
	RTS
	
	.reg_op:
	;Decode VM register op
	JMP VM_next

;Interrupt handler so no FUNC/END
VM_brk_handler:
	halt
	
	CLD
	PLA		;Discard status reg from BRK
	PLA		;Low byte of return address
	SEC
	SBC #1	;Decrease address by 1 for first byte after BRK
	STA VM_ip
	PLA		;High byte of return address
	SBC #0
	STA VM_ip+1
	
	JMP VM_dispatch

VM_op_end:
	INC VM_ip
	BNE .done
		INC VM_ip
	.done:
	JMP (VM_ip)
	
VM_op_test:
	LDA #$23
	JMP VM_next
	
VM_table_stack:
	FDB VM_op_end-1
	FDB VM_op_test-1