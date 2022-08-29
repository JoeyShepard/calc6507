TODO: different op for pushing bytes

;Constants
;=========
STACK_OPS_BEGIN =		224
STACK_NO_OPS_COUNT =	23

VM_code_begin:

FUNC VM_setup
	TODO: remove
	LDA VM_code_end-VM_code_begin	;Total size of VM
	LDA VM_func_end-VM_func_begin	;Size of function being modified
	
	LDA #VM_STACK_END
	STA VM_SP
	LDA #0
	TODO: remove
	STA VM_debug
END

;Interrupt handler so no FUNC/END
VM_brk_handler:
	CLD
	STX stack_SP
	STA VM_A_buff
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
	LDA VM_debug
	BEQ .no_debug
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
		JSR VM_stub_halt
	.no_debug:
	TYA
	
	TODO: eliminate overhead if enough room?
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
	TODO: load X here?
	TODO: also encode stack growth in token?
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
TODO: all of these either LDX stack_SP or JSR VM_SP_dec? encode in byte
TODO: replace JMP VM_dispatch with BRK and check status in handler? lots of stack manipulations though
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
	JMP VM_SP_inc2_dispatch
	
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
	
VM_op_rshift:		;#6
	LDX VM_SP
	LSR 1,X
	ROR 0,X
	JMP VM_dispatch
	
VM_op_A:			;#7
	JSR VM_SP_dec
	LDA VM_A_buff
	STA 0,X
	LDA #0
	STA 1,X
	JMP VM_dispatch
	
VM_op_add:			;#8	
	LDX VM_SP
	CLC
	LDA 2,X
	ADC 0,X
	STA 2,X
	LDA 3,X
	ADC 1,X
	STA 3,X
	JMP VM_SP_inc_dispatch

VM_op_sub:			;#9
	LDX VM_SP
	SEC
	LDA 2,X
	SBC 0,X
	STA 2,X
	LDA 3,X
	SBC 1,X
	STA 3,X
	JMP VM_SP_inc_dispatch
	
VM_op_lshift:		;#10
	LDX VM_SP
	ASL 0,X
	ROL 1,X
	JMP VM_dispatch

VM_op_cstore:		;#11
	LDX VM_SP
	LDA 2,X
	STA (0,X)
	JMP VM_SP_inc2_dispatch
	
TODO: use assembly name of VM_C0 instead?
VM_op_do0:			;#12
	LDX VM_SP
	LDA 0,X
	STA VM_C0
	JMP VM_SP_inc_dispatch

VM_op_do1:			;#13
	LDX VM_SP
	LDA 0,X
	STA VM_C1
	JMP VM_SP_inc_dispatch

VM_op_drop:			;#14
	LDX VM_SP
	JMP VM_SP_inc_dispatch
	
VM_op_halt:			;#15
	TODO: remove
	JSR VM_stub_halt
	JMP VM_dispatch
	
VM_op_debug:		;#16
	LDX VM_SP
	LDA 0,X
	STA VM_debug
	JMP VM_SP_inc_dispatch
	
VM_op_swap:			;#17
	LDX VM_SP
	LDA 0,X
	TAY
	LDA 2,X
	STA 0,X
	STY 2,X
	LDA 1,X
	TAY
	LDA 3,X
	STA 1,X
	STY 3,X
	JMP VM_dispatch
	
VM_op_fetch:		;#18
	LDX VM_SP
	LDA (0,X)
	TAY
	INC 0,X
	BNE .skip
		INC 1,X
	.skip:
	LDA (0,X)
	STA 1,X
	STY 0,X
	JMP VM_dispatch
	
VM_op_select:		;#19
	LDX VM_SP
	LDA 4,X
	ORA 5,X
	BEQ .zero
		;Non-zero 
		LDA 2,X
		STA 4,X
		LDA 3,X
		STA 5,X
		JMP VM_SP_inc2_dispatch
	.zero:
	LDA 0,X
	STA 4,X
	LDA 1,X
	STA 5,X
	JMP VM_SP_inc2_dispatch
	
TODO: share with main stack code
VM_op_and:			;#20
	LDX VM_SP
	LDA 2,X
	AND 0,X
	STA 2,X
	LDA 3,X
	AND 1,X
	STA 3,X
	JMP VM_SP_inc_dispatch

VM_op_xor:			;#21
	LDX VM_SP
	LDA 2,X
	EOR 0,X
	STA 2,X
	LDA 3,X
	EOR 1,X
	STA 3,X
	JMP VM_SP_inc_dispatch
	
VM_op_cfetch:
	LDX VM_SP
	LDA (0,X)
	STA 0,X
	LDA #0
	STA 1,X
	JMP VM_dispatch
	
;These take arguments
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

VM_op_push_byte:
	JSR VM_SP_dec
	STY 0,X
	LDA #0
	STA 1,X
	JMP VM_dispatch

VM_op_loop2:
	LDX VM_SP
	INC 2,X
	BNE .loop
		INC 3,X
		BNE .loop
			;Reached end. Stop looping
			JMP VM_dispatch
	.loop:
	JMP VM_stub_loop

VM_op_djnz0:
	DEC VM_C0
	BNE .loop
		JMP VM_dispatch
	.loop:
	JMP VM_stub_loop
	
VM_op_djnz1:
	DEC VM_C1
	BNE .loop
		JMP VM_dispatch
	.loop:
	JMP VM_stub_loop

VM_table_stack:
	;Stack ops
	FDB VM_op_end-1			;0
	FDB VM_op_store-1		;1
	FDB VM_op_dup-1			;2
	FDB VM_op_over-1		;3
	FDB VM_op_inv-1			;4
	FDB VM_op_inc-1			;5
	FDB VM_op_rshift-1		;6
	FDB VM_op_A-1			;7
	FDB VM_op_add-1			;8
	FDB VM_op_sub-1			;9
	FDB VM_op_lshift-1		;10
	FDB VM_op_cstore-1		;11
	FDB VM_op_do0-1			;12
	FDB VM_op_do1-1			;13
	FDB VM_op_drop-1		;14
	FDB VM_op_halt-1		;15
	FDB VM_op_debug-1		;16
	FDB VM_op_swap-1		;17
	FDB VM_op_fetch-1		;18
	FDB VM_op_select-1		;19
	FDB VM_op_and-1			;20
	FDB VM_op_xor-1			;21
	FDB VM_op_cfetch-1		;22
	;These take arguments
	FDB VM_op_JSR-1
	FDB VM_op_push_res-1
	FDB VM_op_push_byte-1
	FDB VM_op_loop2-1
	FDB VM_op_djnz0-1
	FDB VM_op_djnz1-1
	

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

VM_SP_inc2_dispatch:
	INX
	INX
	;Fall through!
	
VM_SP_inc_dispatch:
	INX
	INX
	STX VM_SP
	JMP VM_dispatch
	
VM_stub_loop:
	STY VM_temp
	SEC
	LDA VM_IP
	SBC VM_temp
	STA VM_IP
	LDA VM_IP+1
	SBC #0
	STA VM_IP+1
	JMP VM_dispatch

VM_stub_halt:
	LDA #'['
	STA DEBUG
	LDA #VM_STACK_END
	SEC
	SBC VM_SP
	LSR
	STA DEBUG_HEX
	LDA #']'
	STA DEBUG
	LDA #' '
	STA DEBUG
	LDX VM_SP
	.loop:
		CPX #VM_STACK_END
		BEQ .done
			LDA 1,X
			STA DEBUG_HEX
			LDA 0,X
			STA DEBUG_HEX
			LDA #' '
			STA DEBUG
			INX
			INX
			JMP .loop
	.done:
	LDA #'\'
	STA DEBUG
	LDA #'n'
	STA DEBUG	
	halt
	RTS

VM_code_end:
	