;CORDIC routines for transcendentals
;===================================

TODO: clear up these notes
;for atan, f(x)=x at some point
;what size table? seems tiny numbers could need huge table
;could also do fixed point but code larger?
;no need for GR if not shifting
;interesting that sin(0.01) and sin(0.001) on HP-48 produces 12 digits. sin(0.000001)=0.000001

;For now, table assumes xx.yy yy yy yy yy fixed point
;ACTUALLY x.y if radians!!!
TODO: using stack is slower but MUCH better precision
TODO: actually, extremely slow

;limiting it to above xx.y10 is TINY table
;intermediates at least will need larger range, so need full precision
;also, see if above tiny format will work for atan as well as tan
;	TWO DIFFERENT TABLES!
;	tan 89.999 is 57k :(
;	tan 89.9999999999 is 12 digit integer - doesn't matter - calculate sin/cos
;	could use large table of floats then determine what can be cut
;	actually, look at algorithm since may be possible to generate huge tan with shifts
;	look at hp-35 page - example table seems especially large tbh
;
;btw, figured out how to - then + division 

	TODO: delete if not used
	;Floating point version (too slow):
	;==================================

	;Constants
	;=========
	;CORDIC_SIGN =			1
	
	;CORDIC_ADD_Y =			0
	;CORDIC_SUB_Y =			1
	;CORDIC_ADD_MASK =		1
	;CORDIC_CMP_Y =			0
	;CORDIC_CMP_Z =			2
	;CORDIC_CMP_MASK =		2
	;CORDIC_HALF =			4
	;CORDIC_HALF_MASK =		4
	;CORDIC_ATAN =			0
	;CORDIC_ATANH =			8
	;CORDIC_ATAN_MASK =		8
		
	;INV_K:
	;	;1/k = 1/23.674377006269683 = 0.042 23 97 59 87 774 335
	;	FCB $77, $87, $59, $97, $23, $42, $98, $49
	
	;TODO: more or less rows?
	;TODO: smaller to generate later rows of form 1E-X?
	;ATAN_TABLE:
	;	FCB $97, $33, $16, $98, $53, $78, $01, $40
	;	FCB $12, $49, $52, $86, $66, $99, $02, $40
	;	FCB $67, $86, $66, $66, $99, $99, $03, $40
	;	FCB $67, $66, $66, $99, $99, $99, $04, $40
	;	FCB $67, $66, $99, $99, $99, $99, $05, $40
	;	FCB $67, $99, $99, $99, $99, $99, $06, $40
	;	FCB $00, $00, $00, $00, $00, $10, $06, $40
	;	FCB $00, $00, $00, $00, $00, $10, $07, $40
	;	FCB $00, $00, $00, $00, $00, $10, $08, $40
	;	FCB $00, $00, $00, $00, $00, $10, $09, $40
	;	FCB $00, $00, $00, $00, $00, $10, $10, $40
	;	FCB $00, $00, $00, $00, $00, $10, $11, $40
	;	FCB $00, $00, $00, $00, $00, $10, $12, $40
	;
	;ATANH_TABLE:
	;
	;ATAN_ROWS = 	13
	
	;Functions
	;=========
	
	;Used in floating point version
	;;Reg in X
	;;Source in ret_address
	;FUNC BCD_CopyConst
	;	LDY #0
	;	.loop:
	;		LDA (ret_address),Y
	;		STA 1,X
	;		INX
	;		INY
	;		CPY #OBJ_SIZE-1
	;		BNE .loop
	;END
	;
	;;Strange to have function only for inserting constants but smaller than inserting pointer after function call
	;BCD_CopyInvK:
	;	MOV.W #INV_K,ret_address
	;	JMP BCD_CopyConst
	
	;Floating point using BCD functions rather than fixed place - smaller though much slower
	;Flags in A
	;Actually, this is too slow. reverting back to version above.
	;FUNC BCD_CORDIC
	;	
	;	TAY
	;	
	;	;Compare to Y or Z?
	;	AND #CORDIC_CMP_MASK
	;	STA CORDIC_compare
	;	
	;	;Add or sub Y each time through?
	;	TYA
	;	AND #CORDIC_ADD_MASK
	;	STA CORDIC_add
	;	
	;	;Use ATAN or ATANH table?
	;	TAY
	;	AND #CORDIC_ATAN_MASK
	;	BNE .use_ATANH
	;		MOV.W #ATAN_TABLE,CORDIC_table
	;		BNE .table_done
	;	.use_ATANH:
	;		MOV.W #ATANH_TABLE,CORDIC_table
	;	.table_done:
	;	
	;	LDA #ATAN_ROWS
	;	STA CORDIC_loops
	;	.loop_outer:
	;		;make copy of table entry in register for faster copying
	;		LDY #7
	;		.table_copy:
	;			LDA (CORDIC_table),Y
	;			STA R5+1,Y
	;			DEY
	;			BPL .table_copy
	;			
	;		TODO: magic number
	;		LDA #9
	;		STA CORDIC_digits
	;		.loop_inner:
	;			
	;			;Z(R4) to R0 for adding
	;			LDA #R4
	;			LDY #R0
	;			JSR CopyRegs
	;			
	;			;Copy table entry(R5) to R1 for adding to Z(R4)
	;			LDA #R5
	;			LDY #R1
	;			JSR CopyRegs
	;			
	;			TODO: eliminate comparison on every iteration
	;			LDA CORDIC_compare
	;			BEQ .compare_Y
	;			.compare_Z:
	;				LDA R4+EXP_HI
	;				AND #SIGN_BIT
	;				STA CORDIC_sign
	;				BNE .add_table
	;				BEQ .sub_table
	;			.compare_Y:
	;				TODO: compare Y
	;				halt
	;			.compare_done:
	;			
	;			.sub_table:
	;				LDA R1+EXP_HI
	;				EOR #SIGN_BIT
	;				STA R1+EXP_HI
	;			.add_table:
	;			
	;			JSR BCD_Add
	;			
	;			;TODO: remove after debugging
	;			;MOV #BANK_GEN_RAM3,RAM_BANK3
	;			;CALL DebugRans
	;			;MOV #BANK_GFX_RAM1,RAM_BANK3
	;			;JSR DEBUG_NL
	;			
	;			;Save calculated Z to R4
	;			LDA #R_ans
	;			LDY #R4
	;			JSR CopyRegs
	;			
	;			;Update X and Y
	;			
	;			halt
	;			
	;			;Copy X(R2) to R0
	;			LDA #R2
	;			LDY #R0
	;			JSR CopyRegs
	;			
	;			halt
	;			
	;			;Adjust exponent
	;			LDX #R0
	;			JSR BCD_Unpack
	;			
	;			halt
	;			
	;			
	;			
	;		DEC CORDIC_digits
	;		BNE .loop_inner
	;		
	;		;TODO: remove after debugging
	;		;JSR DEBUG_NL
	;		;halt
	;	
	;		CLC
	;		LDA CORDIC_table
	;		ADC #OBJ_SIZE-TYPE_SIZE
	;		STA CORDIC_table
	;		BCC .no_carry
	;			INC CORDIC_table+1
	;		.no_carry:
	;	
	;	DEC CORDIC_loops
	;	BNE .loop_outer
	;	
	;	halt
	;	halt
	;	
	;END
	;
	;TODO: delete
	;DEBUG_NL:
	;	LDA #'\\'
	;	STA DEBUG
	;	LDA #'n'
	;	STA DEBUG
	;	RTS
		
	
	;Fixed point version:
	;====================

	;Constants
	;=========
	CORDIC_SIGN =			1
	
	CORDIC_ADD_Y =			0
	CORDIC_SUB_Y =			1
	CORDIC_ADD_MASK =		1
	CORDIC_CMP_Y =			0
	CORDIC_CMP_Z =			2
	CORDIC_CMP_MASK =		2
	CORDIC_HALF =			4
	CORDIC_HALF_MASK =		4
	CORDIC_ATAN =			0
	CORDIC_ATANH =			8
	CORDIC_ATAN_MASK =		8
	
	INV_K:
		;1/k = 1/23.674377006269683 = 0.0 42 23 97 59 877 74 33 5
		FCB $88, $59, $97, $23, $42, $00
	
	;TODO: smaller to generate later rows of form 1E-X?	
	ATAN_TABLE:
		FCB $40, $63, $81, $39, $85, $07
		FCB $49, $52, $86, $66, $99, $00
		FCB $69, $66, $96, $99, $09, $00
		FCB $67, $99, $99, $99, $00, $00
		FCB $00, $00, $00, $10, $00, $00
		FCB $00, $00, $00, $01, $00, $00
		FCB $00, $00, $10, $00, $00, $00
		FCB $00, $00, $01, $00, $00, $00
		FCB $00, $10, $00, $00, $00, $00
		FCB $00, $01, $00, $00, $00, $00
		FCB $10, $00, $00, $00, $00, $00
		FCB $01, $00, $00, $00, $00, $00

	ATAN_ROWS = 	12
	ATAN_WIDTH =	6
	
	ATANH_TABLE:
	
	;Functions
	;=========
	
	;Flags in A
	;R0 - shifting
	;R1 - X'
	;R2 - X
	;R3 - Y
	;R4 - Z
	TODO: 
	FUNC BCD_CORDIC
		
		TAY
		AND #CORDIC_CMP_MASK
		STA math_a
		TYA
		AND #CORDIC_ADD_MASK
		STA math_signs
		TYA
		AND #CORDIC_HALF_MASK
		STA math_b
	
		TODO: push status word?
		SED
	
		MOV.W #ATAN_TABLE, ret_address
		LDA #ATAN_ROWS
		STA math_c
		.loop_outer:
			TODO: magic number
			LDA #9
			STA math_d
			.loop_inner:
				LDA math_a
				BEQ .compare_y
				.compare_z:
				
					TODO: remove after debugging
					LDA R4+DEC_COUNT/2
					STA DEBUG_HEX
					LDA #' '
					STA DEBUG
					LDY #ATAN_WIDTH-1
					.debug_loop:
						LDA R4,Y
						STA DEBUG_HEX
						DEY
						BNE .debug_loop
					LDA #'\\'
					STA DEBUG
					LDA #'n'
					STA DEBUG
					;halt
					
					;if z positive, sub table from z
					;if z negative, add table to z
					LDX #ATAN_WIDTH
					LDY #0
					TODO: true for sin/cos but true for others too?
					;low byte of exp is 0 or negative
					TODO: magic number
					LDA R4+DEC_COUNT/2+1
					BNE .z_negative
					.z_positive:
						SEC
						.z_sub_loop:
							TODO: magic number
							LDA R4+1,Y
							SBC (ret_address),Y
							STA R4+1,Y
							INY
							DEX
							BNE .z_sub_loop
							;Mark sign negative if necessary
							BCS .not_neg
								LDA #$99
								TODO: magic number
								STA R4+DEC_COUNT/2+1
							.not_neg:
							JMP .z_comp_done
					.z_negative:
						CLC
						.z_add_loop:
							TODO: magic number
							LDA R4+1,Y
							ADC (ret_address),Y
							STA R4+1,Y
							INY
							DEX
							BNE .z_add_loop
							;Mark sign positive if necessary
							TODO: sure that overflow is always flipping sign?
							BCC .not_pos
								LDA #0
								TODO: magic number
								STA R4+DEC_COUNT/2+1
							.not_pos:
					.z_comp_done:
					
					;Load sign of comparison for computation of X and Y
					LDA R4+DEC_COUNT/2+1
					JMP .compare_done
					
				.compare_y:
					TODO: compare Y
					halt
				.compare_done:
				
				halt
				
				
				;calculate X and Y
				;=================
				
				;A - sign of comparison	of z or y
				AND #1	;Convert $99 to 1
				XOR	math_signs
				
				START HERE: finish this brainstorming
				;Need to figure out how to optimize shifts
				;1.
					;1. copy Y
					;2. shift Y (maybe combine with 1)
					;3. add to X
				;2.
					;1. load, shift and add in one step
					;2. GRS at end!
					TODO: if this, then dont need R0 for shifting!
				
				
				
				
				DEC math_d
				BNE .loop_inner
				;BEQ .compare_done
				
			TODO: remove after debugging
			LDA #'\\'
			STA DEBUG
			LDA #'n'
			STA DEBUG
			
			LDA ret_address
			CLC
			CLD
			ADC #ATAN_WIDTH
			SED
			STA ret_address
			BCC .no_inc
				INC ret_address+1
			.no_inc:
	
			DEC math_c
			;BNE .loop_outer
			JNE .loop_outer
			
		CLD
		RTS
		
		.calc_X:
	
	END
	