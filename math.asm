;Math functions
;==============

	FUNC BCD_Reverse
		ARGS
			WORD source
			BYTE count
		END
		
		LDY #0
		SED
		SEC
		.loop:
			LDA #0
			SBC (source),Y
			STA (source),Y
			INY
			CPY count
			BNE .loop
		CLD
	END
	
	