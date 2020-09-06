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
	
	FUNC BCD_Add
		
	END
	
	;Number in A
	FUNC BCDtoDec
		VARS
			BYTE total
		END
		
		PHA
		AND #$F
		STA total
		PLA
		AND #$F0
		LSR
		PHA
		CLC
		ADC total
		STA total
		PLA
		LSR
		LSR
		ADC total
	END
	
	