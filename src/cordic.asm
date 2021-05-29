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
		
		;currently ~187,000 cycles
			;copying for shift is probably big slow down
			;add without copying if aligned?
		;C64 can do for i=1 to 100: x+=sin(45) in 4 seconds ie ~40,000 cycles
		
		
		TAY
		AND #CORDIC_CMP_MASK
		STA CORDIC_compare
		TYA
		AND #CORDIC_ADD_MASK
		STA CORDIC_sign
		TYA
		AND #CORDIC_HALF_MASK
		STA CORDIC_halve
	
		TODO: push status word?
		SED
	
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
				JSR CORDIC_DEBUG_STUB	
				
				halt
				
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
				
				LDX #R1
				JSR CORDIC_Round
				
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
				
				LDX #R3
				JSR CORDIC_Round
				
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
			
		CLD
		RTS
		
	END
		
	;A - shift places
	;X - fill byte
	FUNC CORDIC_ShiftR0
		;LDY #0
		;STY R0
		STX math_fill
		JMP ShiftR0.CORDIC
	END
	
	;X - target register
	FUNC CORDIC_Round
	
		RTS
		
		LDA R0
		CMP #$50
		BCC .done		;less than 50
		BNE .round		;more than 50
		.equal_50:		;equal to 50 - check sticky
		LDA math_sticky
		BNE .round		;equal to 50, sticky set, round
		.check_digit:	;equal to 50, no sticky, check next digit
		LDA 1,X
		AND #1
		BEQ .done	;next digit even - don't round
		.round:
		
		SEC
		LDY #ATAN_WIDTH+1
		.loop:
			LDA 1,X
			ADC #0
			STA 1,X
			INX
			DEY
			BNE .loop
		.done:
	END
	
	TODO: remove after debugging	
	CORDIC_DEBUG_STUB:

		LDA #'X'
		STA DEBUG
		LDA #':'
		STA DEBUG
		LDA #' '
		STA DEBUG
		LDA R2+DEC_COUNT/2+1
		STA DEBUG_HEX
		LDA #' '
		STA DEBUG
		LDY #ATAN_WIDTH-1
		.debug_loop_X:
			LDA R2,Y
			STA DEBUG_HEX
			DEY
			BNE .debug_loop_X
		LDA #' '
		STA DEBUG
		LDA R2
		STA DEBUG_HEX
		LDA #'\\'
		STA DEBUG
		LDA #'n'
		STA DEBUG

		LDA #'Y'
		STA DEBUG
		LDA #':'
		STA DEBUG
		LDA #' '
		STA DEBUG
		LDA R3+DEC_COUNT/2+1
		STA DEBUG_HEX
		LDA #' '
		STA DEBUG
		LDY #ATAN_WIDTH-1
		.debug_loop_Y:
			LDA R3,Y
			STA DEBUG_HEX
			DEY
			BNE .debug_loop_Y
		LDA #' '
		STA DEBUG
		LDA R3
		STA DEBUG_HEX
		LDA #'\\'
		STA DEBUG
		LDA #'n'
		STA DEBUG
		
		LDA #'Z'
		STA DEBUG
		LDA #':'
		STA DEBUG
		LDA #' '
		STA DEBUG
		LDA R4+DEC_COUNT/2+1
		STA DEBUG_HEX
		LDA #' '
		STA DEBUG
		LDY #ATAN_WIDTH-1
		.debug_loop_Z:
			LDA R4,Y
			STA DEBUG_HEX
			DEY
			BNE .debug_loop_Z
		LDA #' '
		STA DEBUG
		LDA R4
		STA DEBUG_HEX
		LDA #'\\'
		STA DEBUG
		LDA #'n'
		STA DEBUG
		LDA #'\\'
		STA DEBUG
		LDA #'n'
		STA DEBUG
		
		RTS
		