;CORDIC routines for transcendentals
;===================================

cordic_asm_begin:

;Links
;=====
;https://www.hpmuseum.org/forum/thread-12180.html
;https://archived.hpcalc.org/laporte/Trigonometry.htm
;https://archived.hpcalc.org/laporte/TheSecretOfTheAlgorithms.htm
;http://www.voidware.com/cordic.htm
;https://people.sc.fsu.edu/~jburkardt/c_src/cordic/cordic.c

TODO: clear up these notes

TODO: improve division then?
;Btw, figured out how to - then + division 
	
TODO: more precision to X and Y below would probably give
TODO: more accurate answer at cost of added complexity
	
	
	;Fixed point version:
	;====================

	;Constants
	;=========
	equ CORDIC_SIGN,			1
	
	;Masks and flags
	equ CORDIC_ADD_Y,			0
	equ CORDIC_SUB_Y,			1
	equ CORDIC_ADD_MASK,		1
	equ CORDIC_CMP_Z,			0
	equ CORDIC_CMP_Y,			2
	equ CORDIC_CMP_Y_R5,		4
	equ CORDIC_CMP_MASK,		2|4
	equ CORDIC_HALF,			8
	equ CORDIC_HALF_MASK,		8
	equ CORDIC_ATAN,			0
	equ CORDIC_ATANH,			16
	equ CORDIC_ATAN_MASK,		16
	
	;Return values
	equ CORDIC_CLEANUP,			0
	equ CORDIC_NO_CLEANUP,		1
	
	INV_K:
		;1/k = 1/23.674377006269683 = 0.0 42 23 97 59 87 | 77 43 35
		;FCB $88, $59, $97, $23, $42, $00
		;Added decimal of precision
		FCB $77, $87, $59, $97, $23, $42, $00
	
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
	
	ATANH_TABLE:
		FCB $11, $73, $47, $53, $33, $00, $01
		FCB $33, $35, $33, $03, $00, $10, $00
		FCB $33, $33, $00, $00, $00, $01, $00
		FCB $03, $00, $00, $00, $10, $00, $00
		FCB $00, $00, $00, $00, $01, $00, $00
		FCB $00, $00, $00, $10, $00, $00, $00
		FCB $00, $00, $00, $01, $00, $00, $00
		FCB $00, $00, $10, $00, $00, $00, $00
		FCB $00, $00, $01, $00, $00, $00, $00
		FCB $00, $10, $00, $00, $00, $00, $00
		FCB $00, $01, $00, $00, $00, $00, $00
		FCB $10, $00, $00, $00, $00, $00, $00
		FCB $01, $00, $00, $00, $00, $00, $00

	equ ATAN_ROWS, 		14
	equ ATANH_ROWS,		13
	
	equ CORDIC_WIDTH,	7
	
	;Functions
	;=========
	
	;Comparison routines for BCD_CORDIC
	;(reached by JMP (xxxx) so don't end in RTS)
	CORDIC_Compare_Z:
		LDA R4+FIRST_DIGIT+1 ;Sign of Z
		EOR #$99
		JMP BCD_CORDIC.compare_done
		
	CORDIC_Compare_Y:
		LDA R3+FIRST_DIGIT+1 ;Sign of Y
		JMP BCD_CORDIC.compare_done
	
	TODO: could store in globals instead of R5 in ZP
	CORDIC_Compare_Y_R5:
		halt
		JMP BCD_CORDIC.compare_done
	
	CORDIC_COMPARE_TABLE:
		FDB CORDIC_Compare_Z
		FDB CORDIC_Compare_Y
		FDB CORDIC_Compare_Y_R5
	
	;Flags in A
	;R0 - shifting
	;R1 - X'
	;R2 - X
	;R3 - Y
	;R4 - Z
	FUNC BCD_CORDIC
		
        ;Current algorithm:
            ;Add +a or -a from table to Z(R4)
            ;Copy Y(R3) to shifter(R0)
            ;Shift R0 which holds Y
            ;Add +R0 or -R0 to X(R2) and store in X'(R1)
            ;Copy X(R2) to shifter(R0)  < wasted copy
            ;Shift R0 which holds X
            ;Add Y(R3) +R0 or -R0 to Y(R3)
            ;Copy X'(R1) to X(R2)       < leave number in place

		;STATS:
		;bc shows cos(pi/6) as 86602540 37844
		;HP-48GX shows         86602540 3785
		;Without sticky:       86602540 418
		;With sticky (v1):     86602540 426 (worse)
		;With sticky (v2):     86602540 469 (even worse)
		;With sticky (v3):     86602540 378 68
		;C64 shows             86602540 4
	
        TODO: resolve or remove
		;Currently (without sticky) ~187,000 cycles
        ;Later, up to ~224,000 cycles
			;Copying for shift is probably big slow down
			;Add without copying if aligned?
		;C64 can do for i=1 to 100: x+=sin(45) in 4 seconds ie ~40,000 cycles
		
		TODO: replace halt here with code that will return if accidentally left in
		TODO: halt assembling if halt ever invoked

		TAY	;Save flags
		
		;Compare mode
		AND #CORDIC_CMP_MASK
		TAX
		LDA CORDIC_COMPARE_TABLE,X
		STA CORDIC_comparator
		LDA CORDIC_COMPARE_TABLE+1,X
		STA CORDIC_comparator+1
		
		;Add mode
		TYA
		AND #CORDIC_ADD_MASK
		STA CORDIC_sign
		
		;Halving
		TYA
		AND #CORDIC_HALF_MASK
		STA CORDIC_halve
		
		;Table selection
		TYA
		AND #CORDIC_ATAN_MASK
		;CMP #CORDIC_ATAN
		BEQ .load_atan
			MOV.W #ATANH_TABLE, ret_address
			LDA #ATANH_ROWS
			BNE .load_done
		.load_atan:
			MOV.W #ATAN_TABLE, ret_address
			LDA #ATAN_ROWS
		.load_done:
		STA CORDIC_loop_outer
		
		;Sign - always starts positive
		;Move outside of BCD_CORDIC if not always positive
		LDA #0
		STA R4+FIRST_DIGIT+1    ;Z
		STA R3+FIRST_DIGIT+1    ;Y
		STA R2+FIRST_DIGIT+1    ;X
		
		TODO: remove after debugging
		;LDA #0
		;STA CORDIC_DEBUG_COUNTER
		
		;halt
		
		LDA #0
		STA CORDIC_shift_count
		.loop_outer:
		
			TODO: magic number
			LDA #9
			STA CORDIC_loop_inner
			.loop_inner:
				
				TODO: remove after debugging
				;INC CORDIC_DEBUG_COUNTER
				
				TODO: remove after debugging
				;JSR CORDIC_DEBUG_STUB	
				
				TODO: remove after debugging
				;LDA CORDIC_DEBUG_COUNTER
				;CMP #$1C
				;BNE .debug_skip
				;	halt
				;.debug_skip:
				
				;halt
				
				TODO: shortcut to recognize flip flopping?
			
                ;Calculate Z: +a or -a from table
                ;================================

				JMP (CORDIC_comparator)
				;CORDIC_comparator returns here:
				.compare_done:
				LDX #CORDIC_WIDTH
				LDY #0
				AND #1	;Convert $99 sign to 1
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
						
                        TODO: magic number
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
						
                        TODO: magic number
						LDA R4+DEC_COUNT/2+1
						ADC #0
						STA R4+DEC_COUNT/2+1	
				.z_done:
				
				;Calculate X and Y
				;=================
				
				TODO: remove
				;LDA CORDIC_shift_count
				;BEQ .no_debug2
				;	halt
				;.no_debug2:
				
				;Add X to shifted Y and store in X'
				TODO: magic number - GRS set so need to copy one byte earlier
				TODO: swap CopyRegs for something general purpose
				LDA #R3-1	;Source - Y
				LDY #R0-1	;Dest - shifter
				JSR CopyRegs
				
				;Shift Y in R0
				LDA CORDIC_shift_count
				TODO: remove
				;BEQ .no_debug
				;	halt
				;.no_debug:
				LDX R3+DEC_COUNT/2+1	;sign of Y
				JSR CORDIC_ShiftR0
				
				TODO: replace GRS with guard, round, sticky in all comments
				
				;NOTE: skips adding GRS since would be zero
				
                ;Add X to shifted Y and store in X'
				LDX #0
				TODO: magic_number
				TODO: store elsewhere to reuse math functions?
				LDY #FIRST_DIGIT+2	;+1 for sign byte, +1 for extra precision byte
				LDA CORDIC_sign_temp
				EOR CORDIC_sign
				BEQ .add_X
				.sub_X:
					TODO: abstract
					SEC
					.sub_X_loop:
						LDA R2,X ;X
						SBC R0,X ;Shifted Y
						STA R1,X ;X'
						INX
						DEY
						BNE .sub_X_loop	
					JMP .X_done
				.add_X:
					CLC
					.add_X_loop:
						LDA R2,X ;X
						ADC R0,X ;Shifted Y
						STA R1,X ;X'
						INX
						DEY
						BNE .add_X_loop
				.X_done:
				
				;Add Y to shifted X and store in Y
				LDA #R2-1	;Source - X
				LDY #R0-1	;Dest - shifter
				JSR CopyRegs
				
				;Shift X
				LDA CORDIC_shift_count
				LDX R2+DEC_COUNT/2+1	;Sign of X
				JSR CORDIC_ShiftR0
				
                ;Add X to shifted Y and store in X'
				LDX #0
				TODO: magic_number
				LDY #DEC_COUNT/2+2	;+1 for sign byte, +1 for extra precision byte
				LDA CORDIC_sign_temp
				BNE .add_Y
				.sub_Y:
					TODO: abstract
					SEC
					.sub_Y_loop:
						LDA R3,X ;Y
						SBC R0,X ;Shifted X
						STA R3,X ;Y
						INX
						DEY
						BNE .sub_Y_loop	
					JMP .Y_done
				.add_Y:
					CLC
					.add_Y_loop:
						LDA R3,X ;Y
						ADC R0,X ;Shifted X
						STA R3,X ;Y
						INX
						DEY
						BNE .add_Y_loop
				.Y_done:
				
				;Copy X' to X
				LDA #R1-1	;Source - X'
				LDY #R2-1	;Dest - X
				JSR CopyRegs
				
				DEC CORDIC_loop_inner
				;BNE .loop_inner
				JNE .loop_inner
				;BEQ .compare_done
				
				TODO: remove after debugging
				LDA #'\\'
				;STA DEBUG
				LDA #'n'
				;STA DEBUG
				
			INC CORDIC_shift_count
			
			LDA ret_address
			CLC
			CLD
			ADC #CORDIC_WIDTH
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
	
	;Expects stack pointer in X
	FUNC CORDIC_MarkSign
	
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
	
	END
	
	FUNC CORDIC_Trig
		
		;Save stack pointer here and restore in cleanup
		STX stack_X
		
		;Sign: sin(-x) = -sin(x) though cos(-x) = cos(x)
		JSR CORDIC_MarkSign
		
		;sin(0)=0, cos(0)=1
		LDA FIRST_DIGIT,X
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
			STA R2+FIRST_DIGIT
			
			LDA #CORDIC_NO_CLEANUP
			RTS
			
		.not_zero:
		
		;x <= pi/2?
		TODO: combine into one stub? used below too
		JSR StackAddItem_bank2
		JSR PUSH_STUB
		;-pi/2 = 1.5 70 79 63 26 794 8966
		;FCB OBJ_FLOAT, $79, $26, $63, $79, $70, $15, $00, $00|SIGN_BIT
		;pi/2 rounds up to the below. use this otherwise sin(pi/2) causes range error
		FCB OBJ_FLOAT, $80, $26, $63, $79, $70, $15, $00, $00|SIGN_BIT
		
		SED
		
		JSR TosR0R1
		JSR BCD_Add
		JSR CODE_DROP_bank2
		
		;sin(pi/2)=1, cos(pi/2)=0
		LDA R_ans+FIRST_DIGIT
		BNE .not_one
			TODO: test
			
			LDX #R2
			JSR ZeroReg
			LDX #R3
			JSR ZeroReg
			LDA #$10
			STA R3+FIRST_DIGIT
			
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
			
			PLA		;Drop return to word
			PLA
			
			RTS
		.range_good:
		
		LDX stack_X
		
		DEX	;X and Y have one more byte of precision
		
		LDY #0
		LDA #CORDIC_WIDTH
		STA CORDIC_loop_inner
		.loop:
		
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
			
		;Calculate exp difference (seems hard to abstract)
		;Exp is 0 or negative
		TODO: test!
        TODO: magic number
		LDA 2,X			;High byte of exponent
		AND #$F
		STA math_hi	
		;LDA 1,X		;Low byte of exponent
		;STA math_lo
		;ORA math_hi
		ORA 1,X			;Low byte of exponent
		BEQ .no_shift
			
			TODO: test
			;Exponent <= -100, return sin(0)=0
			LDA math_hi
			BEQ .no_ret_zero
				.ret_zero:
				CLD
				LDX stack_X
				JMP .return_0
				
			.no_ret_zero:
			
			TODO: test
			;Exponent <= -12,  return sin(0)=0
			LDA 1,X
			CMP #$12
			BCS .ret_zero
			
			TODO: test
			;Shift arg
			LDY #0
			STY R0
			TAY
			LDA hex_table,Y
			LDX #0
			JSR CORDIC_ShiftR0
			
		.no_shift:
		
		;Z(R4)=arg
		LDA #R0-1 ;Source - shifter
		LDY #R4-1 ;Dest - Z
		JSR CopyRegs
		
		LDA #CORDIC_CMP_Z|CORDIC_ADD_Y|CORDIC_ATAN
		JMP BCD_CORDIC
		
	END
	
	TODO: share with CORDIC_Trig?
	FUNC CORDIC_Atrig1
		
		;Save stack pointer here and restore in cleanup
		STX stack_X
		
		;Sign: asin(-x) = -asin(x), acos(-x) = pi-acos(x), atan(-x) = -atan(x)
		JMP CORDIC_MarkSign
		
	END
	
	FUNC CORDIC_Atan
		
		RTS
		
		JSR CORDIC_Atrig1
		
		TODO: check
		;atan(0)=0
		LDA FIRST_DIGIT,X
		BNE .not_zero
			
			.return_0:
			LDX #R_ans
			JSR ZeroReg
			
			halt
			
			LDA #CORDIC_NO_CLEANUP
			RTS
			
		.not_zero:
		
		;TODO: combine into one stub? used below too
		;JSR StackAddItem_bank2
		;JSR PUSH_STUB
		;FCB OBJ_FLOAT, $00, $00, $00, $00, $00, $10, $00, $00|SIGN_BIT
		
		SED
		
		;JSR TosR0R1
		;JSR BCD_Add
		;JSR CODE_DROP_bank2
		
		;;asin(1)=pi/2, acos(1)=0
		;LDA R_ans+FIRST_DIGIT
		;BNE .not_one
		;	TODO: abstract!!!
		;	TODO: test
		;	
		;	TODO: CHANGE TO PI/2!
		;	LDX #R2
		;	JSR ZeroReg
		;	LDX #R3
		;	JSR ZeroReg
		;	LDA #$10
		;	STA R3+FIRST_DIGIT
		;	
		;	LDA #CORDIC_NO_CLEANUP
		;	RTS
		;	
		;.not_one:
		
		;;x > 1 - range error
		;LDA R_ans+EXP_HI
		;AND #SIGN_BIT
		;BNE .range_good
		;	TODO: test!
		;	LDA #ERROR_RANGE
		;	STA ret_val
		;	
		;	LDX stack_X
		;	CLD
		;	
		;	PLA		;Drop return to word
		;	PLA
		;	
		;	RTS
		;.range_good:
		
		;if exp 0:
		;	x=0.01, y=0.0999
		;if exp neg:
		;	if too small, return 0
		;	x=0.01, y=0.0000999
		;if exp pos:
		;	if too large, return pi/2
		;	x=0.00001, y=0.0999
		
		
		LDX stack_X
		
		DEX	;X and Y have one more byte of precision
		
		LDY #0
		LDA #CORDIC_WIDTH
		STA CORDIC_loop_inner
		.loop:
		
			;X(R2)=1
			LDA #0
			STA R2,Y
			
			;Y(R0)=arg for shifting then R3
			TODO: wait, why TYPE_SIZE? need OBJ_TYPE then if have this?
			LDA TYPE_SIZE,X
			STA R0,Y
			
			;Z(R4)=0
			LDA #0
			STA R4,Y
			
			INY
			INX
			DEC CORDIC_loop_inner
			BNE .loop
			
		LDA #$10
		STA R2+FIRST_DIGIT
			
		;Calculate exp difference (seems hard to abstract)
		;exp is 0 or negative
		TODO: can abstract with above CORDIC_Trig
		TODO: test!
		LDA 2,X				;High byte of exponent
		AND #$F
		STA math_hi	
		;LDA 1,X			;Low byte of exponent
		;STA math_lo
		;ORA math_hi
		ORA 1,X				;Low byte of exponent
		BEQ .no_shift
			
			TODO: test
			;Exponent <= -100, return asin(0)=0
			LDA math_hi
			BEQ .no_ret_zero
				.ret_zero:
				CLD
				LDX stack_X
				JMP .return_0
			.no_ret_zero:
			
			TODO: test
			;Exponent <= -12,  return sin(0)=0
			LDA 1,X
			CMP #$12
			BCS .ret_zero
			
			TODO: test
			;Shift arg
			LDY #0
			STY R0
			TAY
			LDA hex_table,Y
			LDX #0
			JSR CORDIC_ShiftR0
			
		.no_shift:
		
		;Y(R3)=arg
		LDA #R0-1
		LDY #R3-1
		JSR CopyRegs
		
		LDA #CORDIC_CMP_Y|CORDIC_ADD_Y|CORDIC_ATAN
		JMP BCD_CORDIC
		
	END
	
	FUNC CORDIC_AsinAcos
		
		JSR CORDIC_Atrig1
		
		TODO: check
		;asin(0)=0, acos(0)=pi/2
		LDA FIRST_DIGIT,X
		BNE .not_zero
						
			TODO: CHANGE TO PI/2
			.return_0:
			LDX #R2
			JSR ZeroReg
			LDX #R3
			JSR ZeroReg
			LDA #$10
			STA R2+FIRST_DIGIT
			
			LDA #CORDIC_NO_CLEANUP
			RTS
			
		.not_zero:
		
		;x <= 1? for asin and acos but not atan
		TODO: combine into one stub? used below too
		JSR StackAddItem_bank2
		JSR PUSH_STUB
		FCB OBJ_FLOAT, $00, $00, $00, $00, $00, $10, $00, $00|SIGN_BIT
		
		SED
		
		JSR TosR0R1
		JSR BCD_Add
		JSR CODE_DROP_bank2
		
		;asin(1)=pi/2, acos(1)=0
		LDA R_ans+FIRST_DIGIT
		BNE .not_one
			TODO: abstract!!!
			TODO: test
			
			TODO: CHANGE TO PI/2!
			LDX #R2
			JSR ZeroReg
			LDX #R3
			JSR ZeroReg
			LDA #$10
			STA R3+FIRST_DIGIT
			
			LDA #CORDIC_NO_CLEANUP
			RTS
			
		.not_one:
		
		;x > 1 - range error
		LDA R_ans+EXP_HI
		AND #SIGN_BIT
		BNE .range_good
			TODO: test!
			LDA #ERROR_RANGE
			STA ret_val
			
			LDX stack_X
			CLD
			
			PLA		;Drop return to word
			PLA
			
			RTS
		.range_good:
		
		LDX stack_X
		
		DEX	;X and Y have one more byte of precision
		
		LDY #0
		LDA #CORDIC_WIDTH
		STA CORDIC_loop_inner
		.loop:
		
			;X(R2)=1
			LDA #0
			STA R2,Y
			
			;Y(R0)=arg for shifting then R3
			TODO: wait, why TYPE_SIZE? need OBJ_TYPE then if have this?
			LDA TYPE_SIZE,X
			STA R0,Y
			
			;Z(R4)=0
			LDA #0
			STA R4,Y
			
			INY
			INX
			DEC CORDIC_loop_inner
			BNE .loop
			
		LDA #$10
		STA R2+FIRST_DIGIT
			
		;Calculate exp difference (seems hard to abstract)
		;Exp is 0 or negative
		TODO: can abstract with above CORDIC_Trig
		TODO: test!
		LDA 2,X			;High byte of exponent
		AND #$F
		STA math_hi	
		;LDA 1,X		;Low byte of exponent
		;STA math_lo
		;ORA math_hi
		ORA 1,X			;Low byte of exponent
		BEQ .no_shift
			
			TODO: test
			;Exponent <= -100, return asin(0)=0
			LDA math_hi
			BEQ .no_ret_zero
				.ret_zero:
				CLD
				LDX stack_X
				JMP .return_0
			.no_ret_zero:
			
			TODO: test
			;Exponent <= -12,  return sin(0)=0
			LDA 1,X
			CMP #$12
			BCS .ret_zero
			
			TODO: test
			;Shift arg
			LDY #0
			STY R0
			TAY
			LDA hex_table,Y
			LDX #0
			JSR CORDIC_ShiftR0
			
		.no_shift:
		
		;Y(R3)=arg
		LDA #R0-1
		LDY #R3-1
		JSR CopyRegs
		
		LDA #CORDIC_CMP_Y|CORDIC_ADD_Y|CORDIC_ATAN
		JMP BCD_CORDIC
		
	END
	
	
	;A - flag whether to clean up
	;X - register
	FUNC CORDIC_Pack
		
		CMP #CORDIC_CLEANUP
		BNE .skip_cleanup
			TODO: magic number
			LDA 0,X
			STA R_ans
			TXA
			
			LDY #R_ans
			JSR CopyRegs
			
			;Shift forward
			LDA #0
			STA R_ans+EXP_LO
			STA R_ans+EXP_HI
			JSR NormRans
			
			TODO: not BCD_Round?
			;Clear sticky and round
			LDA #0
			STA math_sticky
			JSR BCD_StickyRound
			
			TODO: test with negative zero!
			;Set sign for BCD_Pack to use
			LDA CORDIC_end_sign
			STA R_ans+SIGN_INFO
			LDX #R_ans
			JSR BCD_Pack
					
			RTS
					
		.skip_cleanup:
		
		TXA
		LDY #R_ans
		JSR CopyRegs
		
		TODO: Replace all DEC_PLACE/2 with LAST_DIGIT
		TODO: Replace all with new constant FIRST_DIGIT
		LDA R_ans+FIRST_DIGIT
		BEQ .no_sign			;Don't set sign if zero
			LDA CORDIC_end_sign
			;ORA R_ans+EXP_HI	;Always zero?
			STA R_ans+EXP_HI
		.no_sign:
		
	END
	
	FUNC CORDIC_Push
		
		;Restore stack pointer
		LDX stack_X
		CLD
			
		;Copy answer to stack
		JMP RansTos
	
	END
	
	TODO: remove after debugging
;	CORDIC_DEBUG_COUNTER:
;		DFS 1
;	CORDIC_DEBUG_BUFF:
;		DFS 12
;	CORDIC_DEBUG_STUB:
;
;		LDA #'X'
;		STA DEBUG
;		LDA #':'
;		STA DEBUG
;		LDX #R2
;		JSR DEBUG_REG
;		
;		LDA #'Y'
;		STA DEBUG
;		LDA #':'
;		STA DEBUG
;		LDX #R3
;		JSR DEBUG_REG
;		
;		LDA #'Z'
;		STA DEBUG
;		LDA #':'
;		STA DEBUG
;		LDX #R4
;		JSR DEBUG_REG
;		
;		LDA #'\\'
;		STA DEBUG
;		LDA #'n'
;		STA DEBUG
;		
;		RTS
;		
;	DEBUG_REG:
;		LDA DEC_COUNT/2+1,X
;		BNE .x1
;			.assume_positive:
;			LDA #' '
;			STA DEBUG
;			TXA
;			PHA
;			CLC
;			PHP
;			CLD
;			ADC #CORDIC_WIDTH-1
;			PLP
;			TAX
;			LDY #CORDIC_WIDTH-1
;			.debug_plus:
;				LDA 0,X
;				STA DEBUG_HEX
;				DEX
;				DEY
;				BNE .debug_plus
;			LDA #' '
;			STA DEBUG
;			PLA
;			TAX
;			LDA 0,X
;			STA DEBUG_HEX
;			JMP .done
;		.x1:
;		CMP #$99
;		BNE .x_unknown
;			LDA #'-'
;			STA DEBUG
;			LDY #CORDIC_WIDTH
;			SEC
;			.debug_minus:
;				LDA #0
;				SBC 0,X
;				STA CORDIC_DEBUG_BUFF,Y
;				INX
;				DEY
;				BNE .debug_minus
;			LDY #1
;			.print:
;				LDA CORDIC_DEBUG_BUFF,Y
;				STA DEBUG_HEX
;				INY
;				CPY #CORDIC_WIDTH
;				BNE .print
;			LDA #' '
;			STA DEBUG
;			LDA CORDIC_DEBUG_BUFF,Y
;			STA DEBUG_HEX
;			JMP .done
;		.x_unknown:
;			LDA CORDIC_DEBUG_COUNTER
;			halt
;			JMP .assume_positive
;		.done:
;		
;		LDA #'\\'
;		STA DEBUG
;		LDA #'n'
;		STA DEBUG
;		
;		RTS

cordic_asm_end:
