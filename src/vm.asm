TODO: different op for pushing bytes

;Constants
;=========
STACK_OPS_BEGIN =		208
STACK_NO_OPS_COUNT =	25+1

VM_code_begin:

FUNC VM_setup
	TODO: remove
	LDA VM_code_end-VM_code_begin	;Total size of VM
	LDA VM_func_end-VM_func_begin	;Size of function being modified
	
	LDA #VM_stack_end
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
	LDA #1
	STA VM_nest_level
	;Fall through to VM dispatch

VM_dispatch:
	LDY #0
	LDA (VM_IP),Y
	TAY	;Save a copy for testing for argument loading
	
	TODO: remove
	LDA VM_debug
	BEQ .no_debug
		JSR VM_handler_debug
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
	TODO: magic number
	AND #7
	ASL
	STA VM_temp0
	ASL
	ASL
	ADC VM_temp0
	ADC #regs_begin
	TODO: store in VM_src instead? may need to analysze usage
	TAY
	TXA
	TODO: magic number
	AND #$F8
	LSR
	LSR
	TAX
	LDA VM_table_fp+1,X
	PHA
	LDA VM_table_fp,X
	PHA
	RTS

;VM fp operations
;================
VM_op_dest_fp:
	STY VM_dest
	STY VM_src1
	JMP VM_dispatch

VM_op_src_fp:
	STY VM_src1
	JMP VM_dispatch
	
TODO: replace with one copy of MemCopy?
VM_op_tos_fp:
	STY VM_src0
	LDX stack_SP
	STX VM_temp0
	LDY #OBJ_SIZE-TYPE_SIZE
	.loop:
		LDX VM_temp0
		LDA 1,X
		INC VM_temp0
		LDX VM_src0
		STA 1,X
		INC VM_src0
		DEY
		BNE .loop
	JMP VM_dispatch	

VM_op_add_fp:
	LDA #$28
	JMP VM_dispatch

VM_table_fp:
	FDB VM_op_dest_fp-1
	FDB VM_op_src_fp-1
	FDB VM_op_tos_fp-1
	FDB VM_op_add_fp-1



;VM stack operations
;===================
TODO: all of these either LDX stack_SP or JSR VM_SP_dec? encode in byte
TODO: replace JMP VM_dispatch with BRK and check status in handler? lots of stack manipulations though

VM_op_nop:			;0
	INC VM_nest_level
	JMP VM_dispatch

VM_op_end:			;1
	DEC VM_nest_level
	BEQ .hard_return
		;Return to VM function
		PLA
		STA VM_IP
		PLA
		STA VM_IP+1
		JMP VM_dispatch
	.hard_return:
	;Finished nested VM calls. Hard return.
	LDX stack_SP
	JMP (VM_IP)
			
VM_op_store:		;2
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
	
VM_op_dup:			;3
	JSR VM_SP_dec
	LDA 2,X
	STA 0,X
	LDA 3,X
	STA 1,X
	JMP VM_dispatch
	
VM_op_over:			;4
	JSR VM_SP_dec
	LDA 4,X
	STA 0,X
	LDA 5,X
	STA 1,X
	JMP VM_dispatch
	
VM_op_inv:			;5
	LDX VM_SP
	SEC
	LDA #0
	SBC 0,X
	STA 0,X
	LDA #0
	SBC 1,X
	STA 1,X
	JMP VM_dispatch

VM_op_inc:			;6
	LDX VM_SP
	INC 0,X
	BNE .done
		INC 1,X
	.done:
	JMP VM_dispatch
	
VM_op_rshift:		;7
	LDX VM_SP
	LDY 0,X
	.loop:
		LSR 3,X
		ROR 2,X
		DEY
		BNE .loop
	JMP VM_SP_inc_dispatch
	
VM_op_A:			;8
	JSR VM_SP_dec
	LDA VM_A_buff
	STA 0,X
	LDA #0
	STA 1,X
	JMP VM_dispatch
	
VM_op_add:			;9
	LDX VM_SP
	CLC
	LDA 2,X
	ADC 0,X
	STA 2,X
	LDA 3,X
	ADC 1,X
	STA 3,X
	JMP VM_SP_inc_dispatch

VM_op_sub:			;10
	LDX VM_SP
	SEC
	LDA 2,X
	SBC 0,X
	STA 2,X
	LDA 3,X
	SBC 1,X
	STA 3,X
	JMP VM_SP_inc_dispatch
	
VM_op_lshift:		;11
	LDX VM_SP
	LDY 0,X
	.loop:
		ASL 2,X
		ROL 3,X
		DEY
		BNE .loop
	JMP VM_SP_inc_dispatch

VM_op_cstore:		;12
	LDX VM_SP
	LDA 2,X
	STA (0,X)
	JMP VM_SP_inc2_dispatch
	
TODO: use assembly name of VM_C0 instead?
VM_op_do0:			;13
	LDX VM_SP
	LDA 0,X
	STA VM_C0
	JMP VM_SP_inc_dispatch

VM_op_do1:			;14
	LDX VM_SP
	LDA 0,X
	STA VM_C1
	JMP VM_SP_inc_dispatch

VM_op_drop:			;15
	LDX VM_SP
	JMP VM_SP_inc_dispatch
	
VM_op_halt:			;16
	TODO: remove
	JMP VM_debug_op_halt
	
VM_op_debug:		;17
	LDX VM_SP
	LDA 0,X
	STA VM_debug
	JMP VM_SP_inc_dispatch
	
VM_op_swap:			;18
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
	
VM_op_fetch:		;19
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
	
VM_op_select:		;20
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
VM_op_and:			;21
	LDX VM_SP
	LDA 2,X
	AND 0,X
	STA 2,X
	LDA 3,X
	AND 1,X
	STA 3,X
	JMP VM_SP_inc_dispatch

VM_op_xor:			;22
	LDX VM_SP
	LDA 2,X
	EOR 0,X
	STA 2,X
	LDA 3,X
	EOR 1,X
	STA 3,X
	JMP VM_SP_inc_dispatch
	
VM_op_cfetch:		;23
	LDX VM_SP
	LDA (0,X)
	STA 0,X
	LDA #0
	STA 1,X
	JMP VM_dispatch
	
VM_op_exec:			;24
	LDX VM_SP
	LDA VM_IP+1
	PHA
	LDA VM_IP
	PHA
	LDA 0,X
	STA VM_IP
	LDA 1,X
	STA VM_IP+1	
	INC VM_nest_level
	JMP VM_SP_inc_dispatch
		
;Single byte ops for FP VM
VM_op_fdrop:		;0
	TODO: only one copy, dont dup with word DROP
	LDA stack_SP
	CLC
	ADC #OBJ_SIZE
	STA stack_SP
	DEC stack_count
	JMP VM_dispatch
	
;Single byte ops that take single byte argument	
VM_op_push_res:		;0
	JSR VM_SP_dec
	LDA VM_res_table_low,Y
	STA 0,X
	LDA VM_res_table_high,Y
	STA 1,X
	JMP VM_dispatch

VM_op_push_byte:	;1
	JSR VM_SP_dec
	STY 0,X
	LDA #0
	STA 1,X
	JMP VM_dispatch

VM_op_loop2:		;2
	LDX VM_SP
	INC 2,X
	BNE .loop
		INC 3,X
		BNE .loop
			;Reached end. Stop looping
			JMP VM_dispatch
	.loop:
	JMP VM_stub_loop

VM_op_djnz0:		;3
	DEC VM_C0
	BNE .loop
		JMP VM_dispatch
	.loop:
	JMP VM_stub_loop
	
VM_op_djnz1:		;4
	DEC VM_C1
	BNE .loop
		JMP VM_dispatch
	.loop:
	JMP VM_stub_loop

VM_op_if:			;5
	LDX VM_SP
	LDA 0,X
	ORA 1,X
	BNE .true
		;Branch to THEN
		TYA
		CLC
		ADC VM_IP
		STA VM_IP
		LDA VM_IP+1
		ADC #0
		STA VM_IP+1
	.true:
	JMP VM_SP_inc_dispatch

VM_table_stack:
	;Single byte stack ops
	FDB VM_op_nop-1			;0
	FDB VM_op_end-1			;1
	FDB VM_op_store-1		;2
	FDB VM_op_dup-1			;3
	FDB VM_op_over-1		;4
	FDB VM_op_inv-1			;5
	FDB VM_op_inc-1			;6
	FDB VM_op_rshift-1		;7
	FDB VM_op_A-1			;8
	FDB VM_op_add-1			;9
	FDB VM_op_sub-1			;10
	FDB VM_op_lshift-1		;11
	FDB VM_op_cstore-1		;12
	FDB VM_op_do0-1			;13
	FDB VM_op_do1-1			;14
	FDB VM_op_drop-1		;15
	FDB VM_op_halt-1		;16
	FDB VM_op_debug-1		;17
	FDB VM_op_swap-1		;18
	FDB VM_op_fetch-1		;19
	FDB VM_op_select-1		;20
	FDB VM_op_and-1			;21
	FDB VM_op_xor-1			;22
	FDB VM_op_cfetch-1		;23
	FDB VM_op_exec-1		;24
	
	;Single byte ops for FP VM
	FDB VM_op_fdrop-1		;0
	
	;Single byte ops that take single byte argument
	FDB VM_op_push_res-1	;0
	FDB VM_op_push_byte-1	;1
	FDB VM_op_loop2-1		;2
	FDB VM_op_djnz0-1		;3
	FDB VM_op_djnz1-1		;4
	FDB VM_op_if-1			;5

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
	STY VM_temp0
	SEC
	LDA VM_IP
	SBC VM_temp0
	STA VM_IP
	LDA VM_IP+1
	SBC #0
	STA VM_IP+1
	JMP VM_dispatch

VM_code_end:
	