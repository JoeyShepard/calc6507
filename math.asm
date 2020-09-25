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
	FUNC BCD_Unpack
		LDA GRS_OFFSET+EXP_HI-1,Y
		STA GRS_OFFSET+EXP_INFO-1,Y
		AND #$F
		STA GRS_OFFSET+EXP_HI-1,Y
		LDA GRS_OFFSET+EXP_INFO-1,Y
		AND #E_SIGN_BIT
		BEQ .no_reverse
			TODO: consolidate with one routine?
			SED
			SEC
			LDA #0
			SBC GRS_OFFSET+EXP_LO-1,Y
			STA GRS_OFFSET+EXP_LO-1,Y
			LDA #0
			SBC GRS_OFFSET+EXP_HI-1,Y
			STA GRS_OFFSET+EXP_HI-1,Y
			CLD
		.no_reverse:
	END
	
	FUNC BCD_Add
		LDY #R0
		JSR BCD_Unpack
		LDY #R1
		JSR BCD_Unpack
	END
	
	FUNC TosR0R1
		TXA
		PHA
		
		LDY #2
		LDA #0
		.zero_loop:
			STA R0,Y
			STA R1,Y
			DEY
			BPL .zero_loop
			
		LDY #3
		.loop:
			INX
			LDA 0,X
			STA R0,Y
			LDA OBJ_SIZE,X
			STA R1,Y
			INY
			CPY #OBJ_SIZE+GRS_OFFSET-1
			BNE .loop
		PLA
		TAX
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
	
	
	