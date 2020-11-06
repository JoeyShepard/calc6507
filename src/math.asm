;Math functions
;==============

	;Constants
	;=========
	;this converts in both directions!
	hex_table: FCB 0,1,2,3,4,5,6,7,8,9,$10,$11,$12,$13,$14,$15,10,11,12,13,14,15
	
	
	;Functions
	;=========
	
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
	
	;Register address in Y
	FUNC BCD_RevExp
		SEC
		LDA #0
		SBC GR_OFFSET+EXP_LO-TYPE_SIZE,Y
		STA GR_OFFSET+EXP_LO-TYPE_SIZE,Y
		LDA #0
		SBC GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		STA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
	END
	
	;Register address in Y
	FUNC BCD_RevSig
		;PHP
		;SED
		
		;reverse significand
		LDA #DEC_COUNT/2+GR_OFFSET
		STA math_a
		SEC
		.loop:
			LDA #0
			SBC 0,Y
			STA 0,Y
			INY
			DEC math_a
			BNE .loop
		
		;PLP
	END
	
	FUNC ZeroR1
		LDX #1
		LDA #0
		.loop:
			STA R1,X
			INX
			CPX #OBJ_SIZE-TYPE_SIZE
			BNE .loop
	END
	
	FUNC MaxR1
		LDX #1
		LDA #$99
		.loop:
			STA R1,X
			INX
			CPX #DEC_COUNT/2+1
			BNE .loop
		STA R1+OBJ_SIZE-2
		LDA #9
		STA R1+OBJ_SIZE-1
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
	
	FUNC IncR1Exp
		LDA R1+GR_OFFSET+EXP_LO-TYPE_SIZE
		CLC
		ADC #1
		STA R1+GR_OFFSET+EXP_LO-TYPE_SIZE
		LDA R1+GR_OFFSET+EXP_HI-TYPE_SIZE
		ADC #0
		STA R1+GR_OFFSET+EXP_HI-TYPE_SIZE		
	END
	
	FUNC SwapR0R1
	
		LDY #GR_OFFSET
		.swap_loop:
			LDA R0,Y
			PHA
			LDA R1,Y
			STA R0,Y
			PLA
			STA R1,Y
			INY
			CPY #GR_OFFSET+OBJ_SIZE
			BNE .swap_loop
	END
	
	TODO: SwapR0R1? slower but smaller
	FUNC CopyR0R1
	
		LDY #GR_OFFSET
		.swap_loop:
			LDA R0,Y
			STA R1,Y
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
	
	FUNC R1Tos
		TXA
		PHA
		LDA #OBJ_FLOAT
		STA 0,X
		INX
		LDY #GR_OFFSET
		.loop:
			LDA R1,Y
			STA 0,X
			INX
			INY
			CPY #OBJ_SIZE
			BNE .loop
		PLA
		TAX
	END
	
	;Which register in X
	;fill byte in A
	FUNC HalfShift
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
	
	;Number in A
	;ASSUMES X IS SAVED ON STACK!!!
	FUNC ShiftR0
		TODO: consider byte by byte - slower but smaller
		
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
		LSR
		STA math_a
		BCC .no_half_shift
			LDX #R0
			LDA #0
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
		LDA #0
		.fill_loop:
			STA R0,X
			INX
			DEY
			BNE .fill_loop
		.done:
	END
	
	FUNC NormR1
		LDY #DEC_COUNT/2
		LDA #0
		STA math_a	;count
		.loop:
			LDA R1,Y
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
			STA R1	;guard/round
			STA R1+OBJ_SIZE-1
			STA R1+OBJ_SIZE-2
			RTS
		.not_0:
		
		LDA math_a
		BEQ .return ;normalized!
		PHA
		LSR
		STA math_a
		BCC .even_shift
			;odd number of shift places
			LDX #R1
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
			LDA R1,X
			LDX math_c
			STA R1,X
			DEC math_c
			DEC math_a
			BPL .shift_loop
		
		;fill empty bytes with fill byte
		LDX #0
		PLA
		TAY
		TXA
		.fill_loop:
			STA R1,X
			INX
			DEY
			BNE .fill_loop
		
		.adjust_exp:
		PLA	;saved count of zeroes
		
		TAY
		LDA hex_table,Y
		STA math_a
		LDA R1+GR_OFFSET+EXP_LO-TYPE_SIZE
		SEC
		SBC math_a
		STA R1+GR_OFFSET+EXP_LO-TYPE_SIZE
		LDA R1+GR_OFFSET+EXP_HI-TYPE_SIZE
		SBC #0
		STA R1+GR_OFFSET+EXP_HI-TYPE_SIZE
		
		.return:
	END
	
	
	;Register address in Y
	FUNC BCD_Unpack
		LDA #0
		STA 0,Y		;guard/round byte
		LDA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		STA GR_OFFSET+SIGN_INFO-TYPE_SIZE,Y
		AND #$F
		STA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		LDA GR_OFFSET+SIGN_INFO-TYPE_SIZE,Y
		AND #E_SIGN_BIT
		BEQ .no_reverse
			JSR BCD_RevExp
		.no_reverse:
		LDA GR_OFFSET+SIGN_INFO-TYPE_SIZE,Y
		AND #SIGN_BIT
		STA GR_OFFSET+SIGN_INFO-TYPE_SIZE,Y
	END
	
	;Register address in Y
	FUNC BCD_Pack
		LDA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		BPL .no_rev
			JSR BCD_RevExp
			;High byte of exp in A
			ORA #E_SIGN_BIT
			STA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		.no_rev:
		CMP #$50	;high byte of $10 (overflow) | E_SIGN_BIT
		BCC .no_underflow
			;exp negative and exceeded 999: set to 0
			;CALL ZeroR1
			;JMP .overflow_done
			JMP ZeroR1
		.no_underflow:
		;AND #~E_SIGN_BIT	
		AND #$BF	;mask out E_SIGN_BIT
		CMP #$10
		BCC .overflow_done
			;exp positive and exceeded 999: set to max val
			;CALL MaxR1
			JMP MaxR1
			;RTS
		.overflow_done:
		
		LDA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		ORA GR_OFFSET+SIGN_INFO-TYPE_SIZE,Y
		STA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
	END
	
	FUNC BCD_Exp_diff
		LDA R1+GR_OFFSET+EXP_LO-TYPE_SIZE
		SEC
		SBC R0+GR_OFFSET+EXP_LO-TYPE_SIZE
		STA math_lo
		LDA R1+GR_OFFSET+EXP_HI-TYPE_SIZE
		SBC R0+GR_OFFSET+EXP_HI-TYPE_SIZE
		STA math_hi
	END
	
	FUNC BCD_Add
		PHP
		SED
		TXA
		PHA
		
		;check for zero - simplifies logic below
		LDA R0+GR_OFFSET+DEC_COUNT/2-1
		JEQ .zero_exit
		LDA R1+GR_OFFSET+DEC_COUNT/2-1
		BNE .R1_good
			JSR CopyR0R1
			JMP .zero_exit
		.R1_good:
		
		LDY #0
		STY math_sticky
		
		LDY #R0
		JSR BCD_Unpack
		LDY #R1
		JSR BCD_Unpack
		JSR BCD_Exp_diff
		
		;0 exp diff - no shift
		LDA math_lo
		ORA math_hi
		BEQ .do_sign
		
		;-1 to -13?
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
		
		;1-13?
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
		LDA R0+GR_OFFSET+SIGN_INFO-TYPE_SIZE
		EOR R1+GR_OFFSET+SIGN_INFO-TYPE_SIZE
		STA math_signs
		BEQ .same_sign
			LDY #R0
			;A = #SIGN_BIT
			AND R0+GR_OFFSET+SIGN_INFO-TYPE_SIZE
			BNE .invert_R0
				LDY #R1
			.invert_R0:
			JSR BCD_RevSig
		.same_sign:
		
		.do_add:
		CLC
		LDX #0
		LDY #DEC_COUNT/2+GR_OFFSET
		.add_loop:
			LDA R1,X
			ADC R0,X
			STA R1,X
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
				JSR IncR1Exp
				
				LDA R1
				AND #$F
				ORA math_sticky
				STA math_sticky
				LDX #R1
				LDA #$10		;fill byte
				JSR HalfShift
			.no_carry:
			;LDA R1+GR_OFFSET+SIGN_INFO-TYPE_SIZE
			;AND #SIGN_BIT
			JMP .carry_done
		.not_same:
			;operands different
			;carry set means positive result
			LDA #0
			PLP
			BCS .no_carry2
				LDY #R1
				JSR BCD_RevSig
				LDA #SIGN_BIT
			.no_carry2:
			STA R1+GR_OFFSET+SIGN_INFO-TYPE_SIZE
		.carry_done:
		;STA R1+GR_OFFSET+SIGN_INFO-TYPE_SIZE
		
		;shift forward
		JSR NormR1
		
		;round
		LDA R1
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
			LDA R1+1
			AND #1
			BNE .round
			BEQ .no_round
		.not_50:
		BCC .no_round
			.round:
			LDX #0
			LDY #DEC_COUNT/2
			SEC
			.round_loop:
				LDA R1+GR_OFFSET,X
				ADC #0
				STA R1+GR_OFFSET,X
				INX
				DEY
				BNE .round_loop
			BCC .round_done
				JSR IncR1Exp
				LDX #R1
				LDA #$10		;fill byte
				JSR HalfShift
			.round_done:
		.no_round:
		
		JMP .done
		.ignore:
			;exp diff too large, so skipped adding
			;if exp neg, keep the one with smaller abs magnitude
			;if exp pos, keep the one with larger abs magnitude
			;ie, just compare diff in exponents
			
			LDA math_hi
			BPL .no_copy
				CALL CopyR0R1
			.no_copy:
		.done:
		
		LDY #R1
		JSR BCD_Pack
		
		.zero_exit:
		PLA
		TAX
		PLP
	END
	
	;Number in A
	;FUNC BCDtoDec
	;	VARS
	;		BYTE total
	;	END
	;	
	;	PHA
	;	AND #$F
	;	STA total
	;	PLA
	;	AND #$F0
	;	LSR
	;	PHA
	;	CLC
	;	ADC total
	;	STA total
	;	PLA
	;	LSR
	;	LSR
	;	ADC total
	;END
	
	;Reg address in A
	;FUNC ZeroReg
	;	VARS
	;		WORD address
	;	END
	;	
	;	STA address
	;	LDA #0
	;	STA address+1
	;	LDY #0
	;	.loop:
	;		STA (address),Y
	;		INY
	;		CPY #OBJ_SIZE
	;		BNE .loop
	;END
	
	
	