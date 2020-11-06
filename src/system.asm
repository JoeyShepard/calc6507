;System functions
;================
	FUNC MemCopy
		ARGS
			WORD source, dest
			BYTE count
		END
		
		LDY #0
		.loop:
			LDA (source),Y
			STA (dest),Y
			INY
			CPY count
			BNE .loop
	END
	