;Math functions
;==============

	;Constants
	;=========
	;This converts in both directions!
	hex_table:
		FCB 0,1,2,3,4,5,6,7,8,9,$10,$11,$12,$13,$14,$15,10,11,12,13,14,15
	
	
	;Functions
	;=========
	
	TODO: see how many times each is used and how (ie args needed?)
	
	TODO: combine with below
	FUNC BCD_Reverse
		ARGS
			WORD source
			BYTE count
		END
		
		LDY #0
		PHP
		SED
		SEC
		.loop:
			LDA #0
			SBC (source),Y
			STA (source),Y
			INY
			DEC count
			BNE .loop
		PLP
	END
	
	;Register address in X
	FUNC BCD_RevExp
		SEC
		LDA #0
		SBC EXP_LO,X
		STA EXP_LO,X
		LDA #0
		SBC EXP_HI,X
		STA EXP_HI,X
	END
	
	;Register address in X
	FUNC BCD_RevSig
		;PHP
		;SED
		
		;reverse significand
		;LDA #DEC_COUNT/2+GR_OFFSET
		;STA math_a
		LDY #DEC_COUNT/2+GR_OFFSET
		SEC
		.loop:
			LDA #0
			SBC 0,X
			STA 0,X
			INX
			DEY
			BNE .loop
		
		;PLP
	END
	
	;Reg in X
	FUNC ZeroReg
		LDY #OBJ_SIZE
		LDA #0
		.loop:
			STA 1,X
			INX
			DEY
			BNE .loop
	END
	
	;Reg in X
	FUNC MaxReg
		LDY #DEC_COUNT/2+1
		LDA #$99
		.loop:
			STA 1,X
			INX
			DEY
			BNE .loop
		LDA #9
		ORA math_max
		STA 1,X
	END
	
	;FUNC DecR1Exp
	;	LDA R1+GR_OFFSET+EXP_LO-TYPE_SIZE
	;	SEC
	;	SBC #1
	;	STA R1+GR_OFFSET+EXP_LO-TYPE_SIZE
	;	LDA R1+GR_OFFSET+EXP_HI-TYPE_SIZE
	;	SBC #0
	;	STA R1+GR_OFFSET+EXP_HI-TYPE_SIZE		
	;END
	
	;Assumes dec mode
	TODO: mark all functions that assume dec mode
	FUNC IncRansExp
		LDA R_ans+EXP_LO
		CLC
		ADC #1
		STA R_ans+EXP_LO
		LDA R_ans+EXP_HI
		ADC #0
		STA R_ans+EXP_HI
	END
	
	TODO: replace with 3 calls to CopyRegs?
	FUNC SwapR0R1
	
		LDX #GR_OFFSET
		.swap_loop:
			LDA R0,X
			PHA
			LDA R1,X
			STA R0,X
			PLA
			STA R1,X
			INX
			CPX #GR_OFFSET+OBJ_SIZE
			BNE .swap_loop
	END
	
	TODO: make sure every utility function is actually used
	;A - source
	;Y - dest
	FUNC CopyRegs
		STA math_ptr1
		STY math_ptr2
		LDA #0
		STA math_ptr1+1
		STA math_ptr2+1
		
		LDY #GR_OFFSET
		.swap_loop:
			LDA (math_ptr1),Y
			STA (math_ptr2),Y
			INY
			CPY #GR_OFFSET+OBJ_SIZE
			BNE .swap_loop
	END
	
	FUNC TosR0R1
		TXA
		PHA
		
		;not here - numbers may reach R0 by different route
		;guard and round
		;LDA #0
		;STA R0
		;STA R1

		LDY #GR_OFFSET
		.loop:
			INX
			LDA 0,X
			STA R0,Y
			LDA OBJ_SIZE,X
			STA R1,Y
			INY
			CPY #OBJ_SIZE+GR_OFFSET-TYPE_SIZE
			BNE .loop
		PLA
		TAX
	END
	
	FUNC RansTos
		TXA
		PHA
		LDA #OBJ_FLOAT
		STA 0,X
		INX
		LDY #GR_OFFSET
		.loop:
			LDA R_ans,Y
			STA 0,X
			INX
			INY
			CPY #OBJ_SIZE
			BNE .loop
		PLA
		TAX
	END
		
	;which register in X
	;shift count in Y
	;fill byte in A
	FUNC HalfShift
		STY shift_counter
		LDY #4
		.half_loop:
			LSR GR_OFFSET+(DEC_COUNT/2)-1,X
			ROR GR_OFFSET+(DEC_COUNT/2)-2,X
			ROR GR_OFFSET+(DEC_COUNT/2)-3,X
			ROR GR_OFFSET+(DEC_COUNT/2)-4,X
			ROR GR_OFFSET+(DEC_COUNT/2)-5,X
			ROR GR_OFFSET+(DEC_COUNT/2)-6,X
			;guard/round byte
			ROR GR_OFFSET+(DEC_COUNT/2)-7,X
			DEY
			BNE .half_loop
		ORA GR_OFFSET+(DEC_COUNT/2)-1,X
		STA GR_OFFSET+(DEC_COUNT/2)-1,X
	END
	
	;Which register in X
	FUNC HalfShiftForward
		LDY #4
		.half_loop:
			;guard/round byte
			ASL GR_OFFSET+(DEC_COUNT/2)-7,X
			
			ROL GR_OFFSET+(DEC_COUNT/2)-6,X
			ROL GR_OFFSET+(DEC_COUNT/2)-5,X
			ROL GR_OFFSET+(DEC_COUNT/2)-4,X
			ROL GR_OFFSET+(DEC_COUNT/2)-3,X
			ROL GR_OFFSET+(DEC_COUNT/2)-2,X
			ROL GR_OFFSET+(DEC_COUNT/2)-1,X
			DEY
			BNE .half_loop
	END
	
	;Which register in X
	FUNC HalfShiftBackward
		LDY #4
		.half_loop:
			;guard/round byte
			LSR 6,X
			ROR 5,X
			ROR 4,X
			ROR 3,X
			ROR 2,X
			ROR 1,X
			DEY
			BNE .half_loop
	END
	
	;Which register in X
	TODO: combine with HalfShiftBackward to save space
	TODO: roll into loop
	FUNC HalfShiftWide
		LDY #4
		.half_loop:
			;guard/round byte
			LSR 13,X
			ROR 12,X
			ROR 11,X
			ROR 10,X
			ROR 9,X
			ROR 8,X
			ROR 7,X
			ROR 6,X
			ROR 5,X
			ROR 4,X
			ROR 3,X
			ROR 2,X
			ROR 1,X
			DEY
			BNE .half_loop
	END
	
	;Which register in X
	TODO: roll into loop?
	FUNC HalfShiftWideForward
		LDY #4
		.half_loop:
			;guard/round byte
			ASL 1,X
			ROL 2,X
			ROL 3,X
			ROL 4,X
			ROL 5,X
			ROL 6,X
			ROL 7,X
			ROL 8,X
			ROL 9,X
			ROL 10,X
			ROL 11,X
			ROL 12,X
			DEY
			BNE .half_loop
	END
	
	;Number in A
	;ASSUMES X IS SAVED ON STACK!!!
	FUNC ShiftR0
		TODO: consider byte by byte - slower but smaller
		
		;Fill 0 by default
		LDY #0
		STY math_fill
		
		TAY
		LDA hex_table,Y		
		STA math_a
		
		;calculate sticky first
		TAY
		DEY
		DEY
		DEY
		BMI .sticky_done	;no sticky if shift is 1 or 2
			LDX #R0+GR_OFFSET
			.sticky_loop:
				LDA 0,X
				CPY #0
				BNE .both_digits
					AND #$F
				.both_digits:
				ORA math_sticky
				STA math_sticky
				INX
				DEY
				DEY
				BPL .sticky_loop
		.sticky_done:
		
		
		;shift by half byte?
		TODO: abstract?
		LDA math_a
		
		;entry point for CORDIC
		.CORDIC:
		
		LSR
		STA math_a
		BCC .no_half_shift
			LDX #R0
			;LDA #0
			LDA math_fill
			TODO: works for CORDIC but messes up addition?
			AND #$F0	;$99 -> $90
			JSR HalfShift
		.no_half_shift:
		
		;shift bytes
		LDA math_a	;bytes to shift
		BEQ .done
		PHA
		LDA #(DEC_COUNT/2)+GR_OFFSET
		SEC
		SBC math_a
		TAY			;counter
		LDA #0
		STA math_b	;dest
		.loop:
			LDX math_a
			LDA R0,X
			LDX math_b
			STA R0,X
			INC math_a
			INC math_b
			DEY
			BNE .loop
		
		;fill empty bytes with fill byte
		LDX math_b
		PLA
		TAY
		LDA math_fill
		.fill_loop:
			STA R0,X
			INX
			DEY
			BNE .fill_loop
		.done:
	END
	
	FUNC NormRans
		LDY #DEC_COUNT/2
		LDA #0
		STA math_a	;count
		.loop:
			LDA R_ans,Y
			BEQ .c2
			AND #$F0
			BNE .done
			INC math_a
			BNE .done
			.c2:
			INC math_a
			INC math_a
			DEY
			BNE .loop
		.done:
		
		;check if zero
		LDA math_a
		CMP #DEC_COUNT
		BCC .not_0
			LDA #0
			STA R_ans	;guard/round
			STA R_ans+OBJ_SIZE-1
			STA R_ans+OBJ_SIZE-2
			RTS
		.not_0:
		
		LDA math_a
		BEQ .return ;normalized!
		PHA
		LSR
		STA math_a
		BCC .even_shift
			;odd number of shift places
			LDX #R_ans
			JSR HalfShiftForward
		.even_shift:
		
		TODO: share with ShiftR0?
		LDA math_a	;bytes to shift
		BEQ .adjust_exp
		PHA
		LDA #(DEC_COUNT/2)
		STA math_c	;dest
		SEC
		SBC math_a
		STA math_a
		.shift_loop:
			LDX math_a
			LDA R_ans,X
			LDX math_c
			STA R_ans,X
			DEC math_c
			DEC math_a
			BPL .shift_loop
		
		;fill empty bytes with fill byte
		LDX #0
		PLA
		TAY
		TXA
		.fill_loop:
			STA R_ans,X
			INX
			DEY
			BNE .fill_loop
		
		.adjust_exp:
		PLA	;saved count of zeroes
		
		TAY
		LDA hex_table,Y
		STA math_a
		LDA R_ans+EXP_LO
		SEC
		SBC math_a
		STA R_ans+EXP_LO
		LDA R_ans+EXP_HI
		SBC #0
		STA R_ans+EXP_HI
		
		.return:
	END
	
	;Register address in X
	TODO: simplify if only ever used on R_ans
	FUNC BCD_Round
		
		;round if necessary
		LDA 0,X
		CMP #$50
		BCC .no_round
			PHP
			SED
		
			LDY #DEC_COUNT/2
			SEC
			.round_loop:
				LDA 1,X
				ADC #0
				STA 1,X
				INX
				DEY
				BNE .round_loop
			
			BCC .no_carry
				;mantissa should be zeroed
				LDA #$10
				STA 0,X
				;SEC
				LDA 1,X
				ADC #0
				STA 1,X
				LDA 2,X
				ADC #0
				STA 2,X
			.no_carry:
			PLP
		.no_round:
	END
	
	;Register address in X
	FUNC BCD_Unpack
		LDA #0
		STA 0,X		;guard/round byte
		LDA EXP_HI,X
		STA SIGN_INFO,X
		AND #$F
		STA EXP_HI,X
		LDA SIGN_INFO,X
		AND #E_SIGN_BIT
		BEQ .no_reverse
			JSR BCD_RevExp
		.no_reverse:
		LDA SIGN_INFO,X
		AND #SIGN_BIT
		STA SIGN_INFO,X
	END
	
	TODO: only ever used on R_ans?
	;X - register
	FUNC BCD_Pack
		LDA EXP_HI,X
		;addition ranges
			;0000-0999	0-9		positive
			;1000		10 		overflow
			;9001-9999	90-99	negative
			;9000		10		underflow
		;multiplication ranges
			;0000-0999	0-9		positive
			;1000-1999	10-19 	overflow
			;9001-9999	90-99	negative
			;8001-9000	10-19	underflow
		BPL .no_rev
			JSR BCD_RevExp
			;High byte of exp in A
			ORA #E_SIGN_BIT
			STA EXP_HI,X
		.no_rev:
		CMP #$50	;high byte of $10 (overflow) | E_SIGN_BIT
		BCC .no_underflow
			;exp negative and exceeded 999: set to 0
			;CALL ZeroR1
			;JMP .overflow_done
			JMP ZeroReg
		.no_underflow:
		;AND #~E_SIGN_BIT	
		AND #$BF	;mask out E_SIGN_BIT
		CMP #$10
		BCC .overflow_done
			;exp positive and exceeded 999: set to max val
			;CALL MaxReg
			;RTS
			JMP MaxReg
		.overflow_done:
		
		LDA EXP_HI,X
		ORA SIGN_INFO,X
		STA EXP_HI,X
	END
	
	FUNC BCD_Exp_diff
		LDA R1+EXP_LO
		SEC
		SBC R0+EXP_LO
		STA math_lo
		LDA R1+EXP_HI
		SBC R0+EXP_HI
		STA math_hi
	END
	
	FUNC BCD_StickyRound
		LDA R_ans
		CMP #$50
		BNE .not_50
			;if GRS=50|1 and signs same, round up
			;if GRS=50|1 and signs different, round down
			LDA math_sticky
			BEQ .round_even
				;LDA R0+GR_OFFSET+SIGN_INFO-TYPE_SIZE
				LDA math_signs
				BNE .no_round
				BEQ .round
			.round_even:
			LDA R_ans+1
			AND #1
			BNE .round
			BEQ .no_round
		.not_50:
		BCC .no_round
			.round:
			TODO: combine with BCD_Round
			LDX #0
			LDY #DEC_COUNT/2
			SEC
			.round_loop:
				LDA R_ans+GR_OFFSET,X
				ADC #0
				STA R_ans+GR_OFFSET,X
				INX
				DEY
				BNE .round_loop
			BCC .round_done
				JSR IncRansExp
				LDX #R_ans
				TODO: slow! set MS nibble explicitly?
				LDA #$10		;fill byte
				JSR HalfShift
			.round_done:
		.no_round:
	END
	
	TODO: redo with pointers? would make CORDIC MUCH faster
	;Add R0 to R1 and store in R_ans
	FUNC BCD_Add
		
		TODO: necessary?
		PHP
		SED
		TXA
		PHA
			
		;check for zero - simplifies logic below
		LDA R0+GR_OFFSET+DEC_COUNT/2-1
		BNE .no_zero_exit
			LDA #R1		;source
			.zero_copy_exit:
			LDY #R_ans	;dest
			JSR CopyRegs
			JMP .zero_exit
		.no_zero_exit:
		LDA R1+GR_OFFSET+DEC_COUNT/2-1
		BNE .R1_good
			LDA #R0		;source
			BNE .zero_copy_exit
		.R1_good:
		
		LDY #0
		STY math_sticky
		
		LDX #R0
		JSR BCD_Unpack
		LDX #R1
		JSR BCD_Unpack
		JSR BCD_Exp_diff
		
		;0 exp diff - no shift
		LDA math_lo
		ORA math_hi
		BEQ .do_sign
		
		;exp -1 to -13?
		LDA math_hi
		CMP #$99
		BNE .not_neg
			LDA math_lo
			
			;CMP #-DEC_COUNT
			CMP #$87
			;-14+
			JCC .ignore
			
			;swap
			CALL SwapR0R1
			JSR BCD_Exp_diff
			JMP .do_shift
		.not_neg:
		
		;exp 1 to 13?
		CMP #0
		;high byte not 0 - ignore
		JNE .ignore
		LDA math_lo
		CMP #$14	;must be BCD!
		;14+
		JCS .ignore
		
		.do_shift:
		LDA math_lo
		JSR ShiftR0
		
		.do_sign:
		TODO: abstract this if reused by other routines
		;only invert digits if signs different
		LDA R0+SIGN_INFO
		EOR R1+SIGN_INFO
		STA math_signs
		BEQ .same_sign
			TODO: use SBC loop instead of rev and ADC below?
			LDX #R0
			;A = #SIGN_BIT
			AND R0+SIGN_INFO
			BNE .invert_R0
				LDX #R1
			.invert_R0:
			JSR BCD_RevSig
		.same_sign:
		
		TODO: generic copy routine?
		;copy exponent to answer so ready to adjust if needed
		LDA R1+EXP_LO
		STA R_ans+EXP_LO
		LDA R1+EXP_HI
		STA R_ans+EXP_HI
		LDA R1+EXP_HI+1
		STA R_ans+EXP_HI+1
		
		.do_add:
		CLC
		LDX #0
		LDY #DEC_COUNT/2+GR_OFFSET
		.add_loop:
			LDA R1,X
			ADC R0,X
			STA R_ans,X
			INX
			DEY
			BNE .add_loop
		
		;process carry
		PHP
		LDA math_signs
		BNE .not_same
			;both operands same
			;carry set means increase exponent
			PLP
			BCC .no_carry
				JSR IncRansExp
				
				LDA R_ans
				AND #$F
				ORA math_sticky
				STA math_sticky
				LDX #R_ans
				LDA #$10		;fill byte
				JSR HalfShift
			.no_carry:
			JMP .carry_done
		.not_same:
			;operands different
			;carry set means positive result
			LDA #0
			PLP
			BCS .no_carry2
				LDX #R_ans
				JSR BCD_RevSig
				LDA #SIGN_BIT
			.no_carry2:
			STA R_ans+SIGN_INFO
		.carry_done:
		
		;shift forward
		JSR NormRans
		
		;round
		JSR BCD_StickyRound
		
		JMP .done
		.ignore:
			;exp diff too large, so skipped adding
			;if exp neg, keep the one with smaller abs magnitude
			;if exp pos, keep the one with larger abs magnitude
			;ie, just compare diff in exponents
			
			LDA #R1
			LDY math_hi
			BPL .no_copy
				LDA #R0
			.no_copy:
			
			LDY #R_ans
			JSR CopyRegs
		.done:
		
		;sign if positive or negative overflow
		LDA R0+SIGN_INFO
		STA math_max
		
		;pack sign bits into exponent
		LDX #R_ans
		JSR BCD_Pack
		
		.zero_exit:
		PLA
		TAX
		PLP
	END
	
	FUNC BCD_Mult
		PHP
		SED
		TXA
		PHA
		
		;zero double wide answer register
		LDX #R_ans_wide
		JSR ZeroReg
		LDX #R_ans
		JSR ZeroReg
		
		;exit if either arg is zero
		LDA R0+DEC_COUNT/2
		BEQ .ret_zero
		LDA R1+DEC_COUNT/2
		BNE .no_zero_exit
			.ret_zero:
			JMP .zero_exit
		.no_zero_exit:
		
		;calculate exponent first
		LDX #R0
		JSR BCD_Unpack
		LDX #R1
		JSR BCD_Unpack
		
		LDA R0+SIGN_INFO
		EOR R1+SIGN_INFO
		AND #SIGN_BIT
		STA R_ans+SIGN_INFO
		
		TODO: abstract
		CLC
		LDA R0+EXP_LO
		ADC R1+EXP_LO
		;STA R_ans+GR_OFFSET+EXP_LO-TYPE_SIZE
		STA math_lo
		LDA R0+EXP_HI
		ADC R1+EXP_HI
		STA R_ans+EXP_HI
		
		LDA #DEC_COUNT
		STA math_b
		.loop:
			;bits in nibble
			LDY #4	
			
			;save least significant digit - addition count
			LDA R0+1
			AND #$F
			STA R0
			
			TODO: consider ShiftR0 - slower but smaller
			TODO: pointer to R0 would be less shifts. smaller too?
			LDX #R0
			JSR HalfShiftBackward
			
			LDA R0
			BEQ .add_skip
			
			;clear carry buffer
			LDA #0
			STA R_ans+DEC_COUNT/2+1
			
			;add digits
			TODO: russian peasant faster but any smaller? 
			.mult_loop:
				LDY #DEC_COUNT/2
				LDX #1
				CLC
				.add_loop:
					LDA R1,X
					ADC R_ans,X
					STA R_ans,X
					INX
					DEY
					BNE .add_loop
				BCC .no_carry
					INC R_ans+DEC_COUNT/2+1
				.no_carry:
				
				DEC R0	;least significant digit of other arg
				BNE .mult_loop
			.add_skip:
			
			;shift answer and shift in carry
			TODO: below fails. problem in optimizer?
			;LDX #R_ans_wide+GR_OFFSET
			LDX #R_ans_wide+1
			JSR HalfShiftWide
			
		DEC math_b
		BNE .loop
		
		;restore exponent since low byte no longer used for mantissa
		LDA math_lo
		STA R_ans+DEC_COUNT/2+1
		
		TODO: use NormRans instead?
		;shift forward if necessary
		LDA R_ans+DEC_COUNT/2
		AND #$F0
		BEQ .shift
			JSR IncRansExp
			JMP .shift_done
		.shift:
			LDX #R_ans_wide+1
			JSR HalfShiftWideForward
		.shift_done:
		
		;calculate sticky
		LDY #5
		LDA #0
		.sticky_loop:
			ORA R_ans_wide+1,Y
			DEY
			BNE .sticky_loop
		STA math_sticky
		
		;round
		LDA #0
		STA math_signs	;round as if same sign
		JSR BCD_StickyRound
		
		;sign if positive or negative overflow
		LDA R_ans+SIGN_INFO
		STA math_max
		
		;pack sign bits into exponent
		LDX #R_ans
		JSR BCD_Pack
		
		.zero_exit:
		PLA
		TAX
		PLP
	END
	
	FUNC BCD_Div
		
		;check for division by zero
		LDA R0+DEC_COUNT/2
		BNE .no_zero_exit
			LDA #ERROR_DIV_ZERO
			STA ret_val
			RTS
		.no_zero_exit:
		
		TODO: replace with stack_X
		PHP
		SED
		TXA
		PHA
		
		;zero answer register
		LDX #R_ans
		JSR ZeroReg
		LDA #0
		STA R_ans
		
		TODO: abstract - same for BCD_Mult
		;calculate exponent first
		LDX #R0
		JSR BCD_Unpack
		LDX #R1
		JSR BCD_Unpack
				
		LDA R0+SIGN_INFO
		EOR R1+SIGN_INFO
		AND #SIGN_BIT
		STA R_ans+SIGN_INFO
		
		;calculate exponent
		TODO: abstract
		SEC
		LDA R1+EXP_LO
		SBC R0+EXP_LO
		STA math_lo
		LDA R1+EXP_HI
		SBC R0+EXP_HI
		STA R_ans+EXP_HI
		
		;reuse first byte of exponent data as decimal place
		LDA #0
		STA R0+EXP_LO
		STA R1+EXP_LO
		
		LDA #DEC_COUNT+2	;extra decimal places for rounding
		STA math_b
		.loop_outer:
			
			;shift answer forward 
			LDX #R_ans
			JSR HalfShiftForward
		
			.loop:		
				LDY #DEC_COUNT/2+1
				LDX #1
				SEC
				.div_loop:
					LDA R1,X
					SBC R0,X
					STA R1,X
					INX
					DEY
					BNE .div_loop
				
				BCC .add_back
				
				;not done subtracting. increment answer
				INC R_ans
				BCS .loop
				
			.add_back:
				;done subtracting
				LDY #DEC_COUNT/2+1
				LDX #1
				CLC
				.add_loop:
					LDA R1,X
					ADC R0,X
					STA R1,X
					INX
					DEY
					BNE .add_loop
					
				;shift R1 forward
				LDX #R1+1
				JSR HalfShiftForward
								
				DEC math_b
				BNE .loop_outer
		
		;restore exponent since low byte no longer used for decimal place
		LDA math_lo
		STA R_ans+DEC_COUNT/2+1
				
		;done subtracting
		JSR NormRans
		
		TODO: get rid of ;halt everywhere
		;halt
		
		;calculate sticky
		LDY #7
		LDA #0
		.sticky_loop:
			ORA R1,Y
			DEY
			BNE .sticky_loop
		STA math_sticky
		
		;round
		LDA #0
		STA math_signs	;round as if same sign
		JSR BCD_StickyRound
		
		;sign if positive or negative overflow
		LDA R_ans+SIGN_INFO
		STA math_max
		
		;pack sign bits into exponent
		LDX #R_ans
		JSR BCD_Pack
		
		.zero_exit:
		PLA
		TAX
		PLP
	END
	
	
	
