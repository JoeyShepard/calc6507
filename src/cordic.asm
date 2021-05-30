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
	
	TODO: more precision to X and Y below would probably give more accurate answer
	
	
	;Fixed point version:
	;====================

	;Constants
	;=========
	CORDIC_SIGN =			1
	
	;Masks and flags
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
	
	;Return values
	CORDIC_CLEANUP =			0
	CORDIC_NO_CLEANUP =			1
	
	INV_K:
		;1/k = 1/23.674377006269683 = 0.0 42 23 97 59 87 | 77 43 35
		;FCB $88, $59, $97, $23, $42, $00
		;added decimal of precision
		FCB $77, $87, $59, $97, $23, $42, $00
	
	TODO: add precision to match X and Y?
	TODO: smaller to generate later rows of form 1E-X?	
	ATAN_TABLE:
		FCB $74, $39, $63, $81, $39, $85, $07
		FCB $12, $49, $52, $86, $66, $99, $00
		FCB $67, $68, $66, $96, $99, $09, $00
		FCB $67, $66, $99, $99, $99, $00, $00
		FCB $97, $99, $99, $99, $09, $00, $00
		FCB $00, $00, $00, $00, $01, $00, $00
		FCB $00, $00, $00, $10, $00, $00, $00
		FCB $00, $00, $00, $01, $00, $00, $00
		FCB $00, $00, $10, $00, $00, $00, $00
		FCB $00, $00, $01, $00, $00, $00, $00
		FCB $00, $10, $00, $00, $00, $00, $00
		FCB $00, $01, $00, $00, $00, $00, $00
		FCB $10, $00, $00, $00, $00, $00, $00
		FCB $01, $00, $00, $00, $00, $00, $00

	ATAN_ROWS = 	14
	ATAN_WIDTH =	7
	
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
		
		;STATS:
		;bc shows cos(pi/6) as 86602540 37844
		;HP-48GX shows         86602540 3785
		;without sticky:       86602540 418
		;with sticky (v1):     86602540 426 (worse)
		;with sticky (v2):     86602540 469 (even worse)
		;with sticky (v3):     86602540 378 68
		;C64 shows             86602540 4
		
		;currently (without sticky) ~187,000 cycles
			;copying for shift is probably big slow down
			;add without copying if aligned?
		;C64 can do for i=1 to 100: x+=sin(45) in 4 seconds ie ~40,000 cycles
		
		TODO: replace halt here with code that will return if accidentally left in
		TODO: halt assembling if halt ever invoked
		
		TAY
		AND #CORDIC_CMP_MASK
		STA CORDIC_compare
		TYA
		AND #CORDIC_ADD_MASK
		STA CORDIC_sign
		TYA
		AND #CORDIC_HALF_MASK
		STA CORDIC_halve
		
		TODO: remove after debugging
		LDA #0
		STA CORDIC_DEBUG_COUNTER
	
		MOV.W #ATAN_TABLE, ret_address
		LDA #ATAN_ROWS
		STA CORDIC_loop_outer
		LDA #0
		STA CORDIC_shift_count
		.loop_outer:
		
			TODO: magic number
			LDA #9
			STA CORDIC_loop_inner
			.loop_inner:
				
				TODO: remove after debugging
				INC CORDIC_DEBUG_COUNTER
				
				TODO: remove after debugging
				JSR CORDIC_DEBUG_STUB	
				
				TODO: remove after debugging
				;LDA CORDIC_DEBUG_COUNTER
				;CMP #$1C
				;BNE .debug_skip
				;	halt
				;.debug_skip:
				
				;halt
				
				TODO: need extra degree of precision for Z?
				LDA R3+DEC_COUNT/2+1 ;sign of Y
				LDX CORDIC_compare
				BEQ .compare_y
				.compare_z:
					LDA R4+DEC_COUNT/2+1 ;sign of Z
					EOR #$99
				.compare_y:
				TODO: magic number. new constant?
				LDX #ATAN_WIDTH
				LDY #0
				AND #1	;Convert $99 sign of Y to 1
				STA CORDIC_sign_temp
				BEQ .add_Z
					.sub_Z:
					SEC
					.sub_Z_loop:
						TODO: magic number
						LDA R4,Y
						SBC (ret_address),Y
						STA R4,Y
						INY
						DEX
						BNE .sub_Z_loop
						
						LDA R4+DEC_COUNT/2+1
						SBC #0
						STA R4+DEC_COUNT/2+1
						
						JMP .z_done
				.add_Z:
					CLC
					.add_Z_loop:
						TODO: magic number
						LDA R4,Y
						ADC (ret_address),Y
						STA R4,Y
						INY
						DEX
						BNE .add_Z_loop
						
						LDA R4+DEC_COUNT/2+1
						ADC #0
						STA R4+DEC_COUNT/2+1	
				.z_done:
				
				;calculate X and Y
				;=================
				
				TODO: remove
				;LDA CORDIC_shift_count
				;BEQ .no_debug2
				;	halt
				;.no_debug2:
				
				;Add X to Y>> and store in X'
				TODO: magic number - GRS set to need to copy one byte earlier
				TODO: swap CopyRegs for something general purpose
				LDA #R3-1	;source - Y
				LDY #R0-1	;dest - shifter
				JSR CopyRegs
				
				;shift Y
				LDA CORDIC_shift_count
				TODO: remove
				;BEQ .no_debug
				;	halt
				;.no_debug:
				LDX R3+DEC_COUNT/2+1	;sign of Y
				JSR CORDIC_ShiftR0
				
				TODO: replace GRS with guard, round, sticky in all comments
				
				;NOTE: skips adding GRS since would be zero
				
				TODO: rename GR_OFFSET to FIRST_DIGIT?
				LDX #0
				TODO: magic_number
				TODO: store elsewhere to reuse math functions?
				LDY #DEC_COUNT/2+2	;+1 for sign byte, +1 for extra precision byte
				LDA CORDIC_sign_temp
				EOR CORDIC_sign
				BEQ .add_X
				.sub_X:
					TODO: abstract
					SEC
					.sub_X_loop:
						LDA R2,X
						SBC R0,X
						STA R1,X
						INX
						DEY
						BNE .sub_X_loop	
					JMP .X_done
				.add_X:
					CLC
					.add_X_loop:
						LDA R2,X
						ADC R0,X
						STA R1,X
						INX
						DEY
						BNE .add_X_loop
				.X_done:
				
				;Add Y to X/d and store in Y
				LDA #R2-1	;source - X
				LDY #R0-1	;dest - shifter
				JSR CopyRegs
				
				;shift X
				LDA CORDIC_shift_count
				LDX R2+DEC_COUNT/2+1	;sign of X
				JSR CORDIC_ShiftR0
				
				LDX #0
				TODO: magic_number
				LDY #DEC_COUNT/2+2	;+1 for sign byte, +1 for extra precision byte
				LDA CORDIC_sign_temp
				BNE .add_Y
				.sub_Y:
					TODO: abstract
					SEC
					.sub_Y_loop:
						LDA R3,X
						SBC R0,X
						STA R3,X
						INX
						DEY
						BNE .sub_Y_loop	
					JMP .Y_done
				.add_Y:
					CLC
					.add_Y_loop:
						LDA R3,X
						ADC R0,X
						STA R3,X
						INX
						DEY
						BNE .add_Y_loop
				.Y_done:
				
				;Copy X' to X
				LDA #R1-1	;source - X'
				LDY #R2-1	;dest - X
				JSR CopyRegs
				
				DEC CORDIC_loop_inner
				;BNE .loop_inner
				JNE .loop_inner
				;BEQ .compare_done
				
				TODO: remove after debugging
				LDA #'\\'
				STA DEBUG
				LDA #'n'
				STA DEBUG
				
			INC CORDIC_shift_count
			
			LDA ret_address
			CLC
			CLD
			ADC #ATAN_WIDTH
			SED
			STA ret_address
			BCC .no_inc
				INC ret_address+1
			.no_inc:
			
			DEC CORDIC_loop_outer
			;BNE .loop_outer
			JNE .loop_outer
			
		LDA #CORDIC_CLEANUP
		
	END
		
	;A - shift places
	;X - fill byte
	FUNC CORDIC_ShiftR0
		STA math_a
		STX math_fill
		JMP ShiftR0.CORDIC
	END
	
	FUNC CORDIC_SinCos
		
		;save here and restore in cleanup
		STX stack_X
		
		;sign: sin(-x) = -sin(x)
		LDY #0
		LDA EXP_HI,X
		AND #SIGN_BIT
		BEQ .sign_pos
			TODO: test!
			EOR EXP_HI,X 
			STA EXP_HI,X
			LDY #SIGN_BIT
		.sign_pos:
		STY CORDIC_end_sign
	
		;sin(0)=0, cos(0)=1
		LDA DEC_COUNT/2,X
		BNE .not_zero
			TODO: test
			TODO: make sure this is used or remove
			;JMP PUSH_STUB_0
			
			.return_0:
			LDX #R2
			JSR ZeroReg
			LDX #R3
			JSR ZeroReg
			LDA #$10
			STA R2+LAST_DIGIT
			LDA #OBJ_FLOAT
			STA R2
			STA R3
			
			LDA #CORDIC_NO_CLEANUP
			RTS
			
		.not_zero:
		
		;x <= pi/2?
		TODO: combine into one stub? used below too
		JSR StackAddItem
		JSR PUSH_STUB
		;-pi/2 = 1.5 70 79 63 26 794 8966
		;FCB OBJ_FLOAT, $79, $26, $63, $79, $70, $15, $00, $00|SIGN_BIT
		;pi/2 rounds up to the below. use this otherwise sin(pi/2) causes range error
		FCB OBJ_FLOAT, $80, $26, $63, $79, $70, $15, $00, $00|SIGN_BIT
		
		SED
		
		JSR TosR0R1
		JSR BCD_Add
		JSR CODE_DROP+EXEC_HEADER
		
		;sin(pi/2)=1, cos(pi/2)=0
		LDA R_ans+LAST_DIGIT
		BNE .not_one
			TODO: abstract!!!
			TODO: test
			
			TODO: set sign here or in cleanup?
			;LDA CORDIC_end_sign
			
			LDX #R2
			JSR ZeroReg
			LDX #R3
			JSR ZeroReg
			LDA #$10
			STA R3+EXP_LO-1	;ie last digit
			;LDA #OBJ_FLOAT	;also #1
			STA R2
			STA R3
			
			LDA #CORDIC_NO_CLEANUP
			RTS
			
		.not_one:
		
		;x > pi/2 - range error
		LDA R_ans+EXP_HI
		AND #SIGN_BIT
		BNE .range_good
			TODO: test!
			LDA #ERROR_RANGE
			STA ret_val
			
			LDX stack_X
			CLD
			
			PLA		;drop return to word
			PLA
			
			RTS
		.range_good:
		
		LDX stack_X
		
		DEX	;X and Y have one more byte of precision
		
		LDY #0
		LDA #ATAN_WIDTH
		STA CORDIC_loop_inner
		.loop:
			TODO: why GR_OFFSET? seems from previous CORDIC version
		
			;X(R2)=1/K
			LDA INV_K,Y
			STA R2,Y
			
			;Y(R3)=0
			LDA #0
			STA R3,Y
			
			;Z(R0)=arg for shifting then R4
			TODO: wait, why TYPE_SIZE? need OBJ_TYPE then if have this?
			LDA TYPE_SIZE,X
			STA R0,Y
			
			INY
			INX
			DEC CORDIC_loop_inner
			BNE .loop
			
		;calculate exp difference (seems hard to abstract)
		;exp is 0 or negative
		TODO: test!
		LDA 2,X				;high byte of exponent
		AND #$F
		STA math_hi	
		;LDA 1,X				;low byte of exponent
		;STA math_lo
		;ORA math_hi
		ORA 1,X				;low byte of exponent
		BEQ .no_shift
			
			TODO: test
			;exponent <= -100, return sin(0)=0
			LDA math_hi
			BEQ .no_ret_zero
				.ret_zero:
				CLD
				LDX stack_X
				JMP .return_0
				
			.no_ret_zero:
			
			TODO: test
			;exponent <= -12,  return sin(0)=0
			LDA 1,X
			CMP #$12
			BCS .ret_zero
			
			TODO: test
			;shift arg
			LDY #0
			STY R0
			TAY
			LDA hex_table,Y
			LDX #0
			JSR CORDIC_ShiftR0
			
		.no_shift:
		
		;Z(R4)=arg
		LDA #R0-1
		LDY #R4-1
		JSR CopyRegs
		
		TODO: move to BCD_CORDIC?
		;sign - always starts positive
		LDA #0
		STA R4+DEC_COUNT/2+1
		STA R3+DEC_COUNT/2+1
		STA R2+DEC_COUNT/2+1
		
		LDA #CORDIC_CMP_Z|CORDIC_ADD_Y|CORDIC_ATAN
		JMP BCD_CORDIC
		
	END
	
	TODO: assumes result is positive since sign filtered out before CORDIC
	;A - flag whether to clean up
	;X - register
	FUNC CORDIC_Push
		
		CMP #CORDIC_CLEANUP
		BNE .skip_cleanup
			TODO: magic number
			LDA 0,X
			STA R_ans
			TXA
			
			LDY #R_ans
			JSR CopyRegs
			
			;shift forward
			LDA #0
			STA R_ans+EXP_LO
			STA R_ans+EXP_HI
			JSR NormRans
			
			;clear sticky and round
			LDA #0
			STA math_sticky
			JSR BCD_StickyRound
			
			TODO: test with negative zero!
			;set sign for BCD_Pack to use
			LDA CORDIC_end_sign
			STA R_ans+SIGN_INFO
			LDX #R_ans
			JSR BCD_Pack
					
			JMP .done
					
		.skip_cleanup:
		
		TXA
		LDY #R_ans
		JSR CopyRegs
		
		TODO: Replace all DEC_PLACE/2 with LAST_DIGIT
		TODO: Replace all with new constant FIRST_DIGIT
		LDA R_ans+LAST_DIGIT
		BEQ .no_sign			;don't set sign if zero
			LDA CORDIC_end_sign
			;ORA R_ans+EXP_HI	;always zero?
			STA R_ans+EXP_HI
		.no_sign:
		
		.done:
		
		;restore stack pointer
		LDX stack_X
		CLD
			
		;Copy to stack
		JMP RansTos
		
	END
	
	TODO: remove after debugging
	CORDIC_DEBUG_COUNTER:
		DFS 1
	CORDIC_DEBUG_BUFF:
		DFS 12
	CORDIC_DEBUG_STUB:

		LDA #'X'
		STA DEBUG
		LDA #':'
		STA DEBUG
		LDX #R2
		JSR DEBUG_REG
		
		LDA #'Y'
		STA DEBUG
		LDA #':'
		STA DEBUG
		LDX #R3
		JSR DEBUG_REG
		
		LDA #'Z'
		STA DEBUG
		LDA #':'
		STA DEBUG
		LDX #R4
		JSR DEBUG_REG
		
		LDA #'\\'
		STA DEBUG
		LDA #'n'
		STA DEBUG
		
		RTS
		
	DEBUG_REG:
		LDA DEC_COUNT/2+1,X
		BNE .x1
			.assume_positive:
			LDA #' '
			STA DEBUG
			TXA
			PHA
			CLC
			PHP
			CLD
			ADC #ATAN_WIDTH-1
			PLP
			TAX
			LDY #ATAN_WIDTH-1
			.debug_plus:
				LDA 0,X
				STA DEBUG_HEX
				DEX
				DEY
				BNE .debug_plus
			LDA #' '
			STA DEBUG
			PLA
			TAX
			LDA 0,X
			STA DEBUG_HEX
			JMP .done
		.x1:
		CMP #$99
		BNE .x_unknown
			LDA #'-'
			STA DEBUG
			LDY #ATAN_WIDTH
			SEC
			.debug_minus:
				LDA #0
				SBC 0,X
				STA CORDIC_DEBUG_BUFF,Y
				INX
				DEY
				BNE .debug_minus
			LDY #1
			.print:
				LDA CORDIC_DEBUG_BUFF,Y
				STA DEBUG_HEX
				INY
				CPY #ATAN_WIDTH
				BNE .print
			LDA #' '
			STA DEBUG
			LDA CORDIC_DEBUG_BUFF,Y
			STA DEBUG_HEX
			JMP .done
		.x_unknown:
			LDA CORDIC_DEBUG_COUNTER
			halt
			JMP .assume_positive
		.done:
		
		LDA #'\\'
		STA DEBUG
		LDA #'n'
		STA DEBUG
		
		RTS
		