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
	END
	
	;Register address in Y
	FUNC BCD_Unpack
		LDA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		STA GR_OFFSET+SIGN_INFO-TYPE_SIZE,Y
		AND #$F
		STA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		LDA GR_OFFSET+SIGN_INFO-TYPE_SIZE,Y
		AND #$F0
		STA GR_OFFSET+SIGN_INFO-TYPE_SIZE,Y
		AND #E_SIGN_BIT
		BEQ .no_reverse
			JSR BCD_RevExp
		.no_reverse:
		
		;LDA GR_OFFSET+SIGN_INFO-TYPE_SIZE,Y
		;AND #SIGN_BIT
		;BEQ .positive
		;	JSR BCD_RevSig
		;.positive:
	END
	
	;Register address in Y
	FUNC BCD_Pack
		
		TODO: adjust exponent if subtracted
	
		LDA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		BPL .no_rev
			JSR BCD_RevExp
			;High byte of exp in A
			
			TODO: check if sum more than 999
			
			ORA #E_SIGN_BIT
			STA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		.no_rev:
		
		;LDA GR_OFFSET+SIGN_INFO-TYPE_SIZE,Y
		;BEQ .no_sign
		;	JSR BCD_RevSig
		;	LDA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		;	ORA #SIGN_BIT
		;	STA GR_OFFSET+EXP_HI-TYPE_SIZE,Y
		;.no_sign:
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
		
		LDY #R0
		JSR BCD_Unpack
		LDY #R1
		JSR BCD_Unpack
		JSR BCD_Exp_diff
		
		LDY #0
		STY math_sticky
		
		TODO: abstract this if reused by other routines
		;only invert digits if signs different
		LDA R0+GR_OFFSET+SIGN_INFO-TYPE_SIZE
		EOR R1+GR_OFFSET+SIGN_INFO-TYPE_SIZE
		AND #SIGN_BIT
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
		
		TODO: take GR into account! 12 is not max!
		
		;0 - no shift
		;1-11 - shift R0
		;12+ - ignore
		;-1 to -11 - swap, shift R0
		;-12+ - ignore
		
		;0 - no shift
		LDA math_lo
		ORA math_hi
		BEQ .do_add
		
		;-1 to -11?
		LDA math_hi
		CMP #$99
		BNE .not_neg
			LDA math_lo
			;CMP #-DEC_COUNT
			CMP #$89
			;-12+
			JCC .ignore
			
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
		JNE .ignore
		LDA math_lo
		CMP #DEC_COUNT-TYPE_SIZE
		;12+
		JCS .ignore
		
		.do_shift:
		LDA math_lo
		JSR ShiftR0
		
		.do_add:
		
		;also, only guard can be shifted in, never round
		;	100000000000 - 0.04 = 100000000000??? yes, shifts 9 in and round is 60
		;	100000000000 - 0.06 = 99999999999.9??? yes shifts 9 in and round is 40
		;	100000000000 - 0.05 = 100000000000??? round to nearest
		;   100000000001 - 0.05 = 100000000001??? 0.95 rounds to 1
		;	123456789012 - 0.4 = 123456789012
		;	123456789012 - 0.6 = 123456789011
		;	500000000002 + 500000000002 = 1E12
		;	500000000003 + 500000000003 = 100000000001
		;	999999999999 + 999999999999 = 2E12!
		;   600000000001 + 600000000001 = 1.2E12
		;   600000000006 + 600000000006 = 120000000001
		;   600000000009 + 600000000009 = 120000000001
		;   456000000005 + 789000000005 = 124500000001
		;   999999999999 + 0.9 = 1E12
		;		carry from rounding
		;   999999999999 + 1 = 1E12
		;       carry from adding
		;   999999999999 + 1.4 = 1E12
		;       carry from adding
		;   999999999999 + 1.6 = 10000000000 06 = 1E12
		;       carry from adding and rounding
		;   456.000000005 + 789.000000004 = 1245.00000001
		;
		;   values too large or small
		;   basically every combination of paths
		
		;start here: tests for addition before continuing
		
		
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
		
		;process carry
		PHP
		LDA math_signs
		BNE .not_same
			;both operands same
			;carry set means increase exponent
			PLP
			BCC .no_carry
				INC.W R1+GR_OFFSET+EXP_LO-TYPE_SIZE
				LDA R1
				AND #$F
				ORA math_sticky
				STA math_sticky
				LDX #R1
				LDA #$10		;fill byte
				CALL HalfShift
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
		
		halt
		
		;round
		LDA R1
		CMP #$50
		BNE .not_50
			LDA math_sticky
			BNE .round
			;round to nearest
			LDA R1+1
			AND #1
			BNE .round
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
				INC.W R1+GR_OFFSET+EXP_LO-TYPE_SIZE
				LDX #R1
				LDA #$10		;fill byte
				CALL HalfShift
			.round_done:
		.no_round:
		
		;sign???
		
		
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
	
	;Number in A
	;ASSUMES X IS SAVED ON STACK!!!
	FUNC ShiftR0
		TODO: consider byte by byte - slower but smaller
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
		
		;byte for filling empty space
		LDY #0
		LDA math_signs
		BEQ .pos
			LDA R0+EXP_HI+GR_OFFSET-TYPE_SIZE
			BPL .pos
				LDY #$99
		.pos:
		STY math_b
		
		;shift by half byte?
		TODO: abstract?
		LDA math_a
		LSR
		STA math_a
		BCC .no_half_shift
			LDX #R0
			LDA math_b		;fill byte
			AND #$F0
			CALL HalfShift
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
		STA math_c	;dest
		.loop:
			LDX math_a
			LDA R0,X
			LDX math_c
			STA R0,X
			INC math_a
			INC math_c
			DEY
			BNE .loop
		.done:
		
		;fill empty bytes with fill byte
		LDX math_c
		PLA
		TAY
		LDA math_b
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
	
	
	