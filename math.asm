;Math functions
;==============

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
		;reverse significand
		LDA #DEC_COUNT/2
		STA math_a
		SEC
		.loop:
			LDA #0
			SBC GR_OFFSET,Y
			STA GR_OFFSET,Y
			INY
			DEC math_a
			BNE .loop
	END
	
	;Register address in Y
	FUNC BCD_Unpack
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
		BEQ .positive
			JSR BCD_RevSig
		.positive:
	END
	
	;Register address in Y
	FUNC BCD_Pack
		
		TODO: adjust exponent if subtracted
	
		LDA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		BPL .no_rev
			JSR BCD_RevExp
			ORA #E_SIGN_BIT
			STA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		.no_rev:
		
		TODO: check if sum more than 999
		
		LDA GR_OFFSET+SIGN_INFO-TYPE_SIZE,Y
		BEQ .no_sign
			JSR BCD_RevSig
			LDA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
			ORA #SIGN_BIT
			STA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		.no_sign:
	END
	
	FUNC BCD_Exp_diff
		LDA R1+GR_OFFSET+EXP_LO-TYPE_SIZE
		SEC
		SBC R0+GR_OFFSET+EXP_LO-TYPE_SIZE
		STA math_a
		LDA R1+GR_OFFSET+EXP_HI-TYPE_SIZE
		SBC R0+GR_OFFSET+EXP_HI-TYPE_SIZE
		STA math_b
	END
	
	FUNC BCD_Add
		PHP
		SED
		TXA
		PHA
		
		LDY #R0
		JSR BCD_Unpack
		LDY #R1
		JSR BCD_Unpack
		
		JSR BCD_Exp_diff
		
		;0 - no shift
		;1-11 - shift R0
		;12+ - ignore
		;-1 to -11 - swap, shift R0
		;-12+ - ignore
		
		;0 - no shift
		ORA math_a
		BEQ .do_add
		
		;-1 to -11?
		LDA math_b
		CMP #$99
		BNE .not_neg
			LDA math_a
			;CMP #-DEC_COUNT
			CMP #$89
			;-12+
			BCC .ignore
			
			;swap
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
			JSR BCD_Exp_diff
			JMP .do_shift
		.not_neg:
		
		;1-11?
		CMP #0
		;12+
		BNE .ignore
		LDA math_a
		CMP #DEC_COUNT-TYPE_SIZE
		;12+
		BCS .ignore
		
		.do_shift:
		LDA math_a
		JSR ShiftR0
		
		.do_add:
		
		halt
		start here: adding these two negatives is off by one in LS digit 
			either set c for inversion on guard or clear carry and skip guard
		
		CLC
		LDX #0
		LDY #DEC_COUNT/2+GR_OFFSET
		CLC
		.add_loop:
			LDA R1,X
			ADC R0,X
			STA R1,X
			INX
			DEY
			BNE .add_loop
		
		TODO: rounding!!!
		
		halt
		
		;process carry
		PHP
		LDA R1+SIGN_INFO
		EOR R0+SIGN_INFO
		BNE .not_same
			;both operands same
			;carry set means increase exponent
			PLP
			BCC .no_carry
				INC.W R1+GR_OFFSET+EXP_LO-TYPE_SIZE
			.no_carry:	
			JMP .carry_done
		.not_same:
			;operands different
			;carry set means positive result
			LDA #0
			PLP
			BCS .no_carry2
				LDA #E_SIGN_BIT
			.no_carry2:
			STA R1+GR_OFFSET+SIGN_INFO-TYPE_SIZE
		.carry_done:
		LDY #R1
		JSR BCD_Pack
		
		.ignore:
		PLA
		TAX
		PLP
	END
	
	FUNC TosR0R1
		TXA
		PHA
		
		;guard and round
		LDA #0
		STA R0
		STA R1

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
	
	;Number in A
	;ASSUMES X IS SAVED ON STACK!!!
	FUNC ShiftR0
		TODO: consider byte by byte - slower but smaller
		STA math_c
		
		;calculate sticky first
		LDY #0
		STY math_sticky
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
		
		;byte for filling empty space
		LDY #$99
		;high byte of exponent
		LDA R0+EXP_HI+GR_OFFSET-TYPE_SIZE
		BMI .neg
			LDY #0
		.neg:
		STY math_d
		
		;shift by half byte?
		TODO: abstract?
		LDA math_c
		LSR
		STA math_c
		BCC .no_half_shift
			LDY #4
			.half_loop:
				LSR R0+GR_OFFSET+(DEC_COUNT/2)-1
				ROR R0+GR_OFFSET+(DEC_COUNT/2)-2
				ROR R0+GR_OFFSET+(DEC_COUNT/2)-3
				ROR R0+GR_OFFSET+(DEC_COUNT/2)-4
				ROR R0+GR_OFFSET+(DEC_COUNT/2)-5
				ROR R0+GR_OFFSET+(DEC_COUNT/2)-6
				;guard/round byte
				ROR R0+GR_OFFSET+(DEC_COUNT/2)-7
				DEY
				BNE .half_loop
			LDA math_d		;fill byte
			AND #$F0
			ORA R0+GR_OFFSET+(DEC_COUNT/2)-1
			STA R0+GR_OFFSET+(DEC_COUNT/2)-1
		.no_half_shift:
		
		;shift bytes
		LDA math_c	;bytes to shift
		BEQ .done
		PHA
		LDA #(DEC_COUNT/2)+GR_OFFSET
		SEC
		SBC math_c
		TAY			;counter
		LDA #0
		STA math_e	;dest
		.loop:
			LDX math_c
			LDA R0,X
			LDX math_e
			STA R0,X
			INC math_c
			INC math_e
			DEY
			BNE .loop
		.done:
		
		;fill empty bytes with fill byte
		LDX math_e
		PLA
		TAY
		LDA math_d
		.fill_loop:
			STA R0,X
			INX
			DEY
			BNE .fill_loop
		
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
	
	
	