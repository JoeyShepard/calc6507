TODO: different op for pushing bytes

;Constants
;=========
STACK_OPS_BEGIN =		240
STACK_NO_OPS_COUNT =	6

VM_code_begin:

FUNC VM_setup
	TODO: remove
	LDA VM_code_end-VM_code_begin	;Total size of VM
	LDA VM_func_end-VM_func_begin	;Size of function being modified
	
	LDA #VM_STACK_END
	STA VM_SP
	LDA #0
	STA VM_A0+1
	STA VM_A1+1
END

;Interrupt handler so no FUNC/END
VM_brk_handler:
	STX stack_SP
	CLD
	PLA		;Discard status reg from BRK
	PLA		;Low byte of return address
	SEC
	SBC #1	;Decrease address by 1 for first byte after BRK
	STA VM_IP
	PLA		;High byte of return address
	SBC #0
	STA VM_IP+1
	;Fall through to VM dispatch

VM_dispatch:
	LDY #0
	LDA (VM_IP),Y
	TAY	;Save a copy for testing for argument loading
	
	TODO: remove
	;STA DEBUG_HEX
	;LDA #' '
	;STA DEBUG
	;TYA
	;halt
	
	JSR VM_IP_inc
	CMP #STACK_OPS_BEGIN
	BCC .fp_op
	
	;VM stack op
	SBC #STACK_OPS_BEGIN
	ASL
	TAX
	LDA VM_table_stack+1,X
	PHA
	LDA VM_table_stack,X
	PHA
	;Load next byte as arg if needed
	;CLC - should be clear already
	CPY #(STACK_OPS_BEGIN+STACK_NO_OPS_COUNT)
	BCC .no_arg
		LDY #0
		LDA (VM_IP),Y
		TODO: usually used in A or Y below?
		TAY
		JMP VM_IP_inc	;tail call
	.no_arg:
	RTS
	
	.fp_op:
	;VM fp op
	TAX
	AND #$E0
	LSR
	LSR
	STA VM_A1
	TXA
	AND #$1F
	ASL
	TAX
	LDA VM_table_fp+1,X
	PHA
	LDA VM_table_fp,X
	PHA
	RTS

;VM fp operations
;================
VM_op_reg_fp:
	LDA #$25
	JMP VM_dispatch
	
VM_op_add_fp:
	LDA #$26
	JMP VM_dispatch

VM_table_fp:
	FDB VM_op_reg_fp-1
	FDB VM_op_add_fp-1

;VM stack operations
;===================
VM_op_end:			;#0
	LDX stack_SP
	JMP (VM_IP)
			
VM_op_store:		;#1
	LDX VM_SP
	LDA 2,X
	STA (0,X)
	INC 0,X
	BNE .done
		INC 1,X
	.done:
	LDA 3,X
	STA (0,X)
	TODO: abstract?
	CLC
	LDA VM_SP
	ADC #4
	STA VM_SP
	JMP VM_dispatch
	
VM_op_dup:			;#2
	JSR VM_SP_dec
	LDA 2,X
	STA 0,X
	LDA 3,X
	STA 1,X
	JMP VM_dispatch
	
VM_op_over:			;#3
	JSR VM_SP_dec
	LDA 4,X
	STA 0,X
	LDA 5,X
	STA 1,X
	JMP VM_dispatch
	
VM_op_inv:			;#4
	LDX VM_SP
	SEC
	LDA #0
	SBC 0,X
	STA 0,X
	LDA #0
	SBC 1,X
	STA 1,X
	JMP VM_dispatch

VM_op_inc:			;#5
	LDX VM_SP
	INC 0,X
	BNE .done
		INC 1,X
	.done:
	JMP VM_dispatch

;These takes arguments
VM_op_JSR:
	JSR VM_SP_dec
	LDA VM_IP
	STA 0,X
	LDA VM_IP+1
	STA 1,X
	LDA VM_res_table_low,Y
	STA VM_IP
	LDA VM_res_table_high,Y
	STA VM_IP+1
	JMP VM_dispatch
	
VM_op_push_res:
	JSR VM_SP_dec
	LDA VM_res_table_low,Y
	STA 0,X
	LDA VM_res_table_high,Y
	STA 1,X
	JMP VM_dispatch

TODO: abstract out if LOOP3 or LOOP4 needed
VM_op_loop2:
	LDX VM_SP
	INC 2,X
	BNE .loop
		INC 3,X
		BNE .loop
			halt
			;Reached end. Stop looping
			JMP VM_dispatch
	.loop:
	;Not done looping
	STY VM_temp
	SEC
	LDA VM_IP
	SBC VM_temp
	STA VM_IP
	LDA VM_IP+1
	SBC #0
	STA VM_IP+1
	JMP VM_dispatch
	
VM_table_stack:
	;Stack ops
	FDB VM_op_end-1
	FDB VM_op_store-1
	FDB VM_op_dup-1
	FDB VM_op_over-1
	FDB VM_op_inv-1
	FDB VM_op_inc-1
	;These take arguments
	FDB VM_op_JSR-1
	FDB VM_op_push_res-1
	FDB VM_op_loop2-1
	

;Small stubs used above
;======================
TODO: check occurences and if this really makes sense
VM_IP_inc:
	INC VM_IP
	BNE .done
		INC VM_IP+1
	.done:
	RTS
	
VM_SP_dec:
	LDX VM_SP
	DEX
	DEX
	STX VM_SP
	RTS

VM_code_end:
	