;Constants
;=========
false equ 0
true equ $FF

;Misc
;====
lo FUNCTION x,(x # 256)
hi FUNCTION x,(x / 256)

halt MACRO
	BRK
	BRK
	ENDM
	
INC.W MACRO address
	INC address
	BNE .skip
		INC (address)+1
	.skip:
	ENDM
	
JCC MACRO target
	BCS .skip
	JMP target
	.skip:
	ENDM

JCS MACRO target
	BCC .skip
	JMP target
	.skip:
	ENDM

JEQ MACRO target
	BNE .skip
	JMP target
	.skip:
	ENDM
	
JNE MACRO target
	BEQ .skip
	JMP target
	.skip:
	ENDM
	
MOV MACRO src, dst
	IF SUBSTR("src",0,1)=="#"
		LDA #(VAL(SUBSTR("src",1,STRLEN("src")-1))#256)
		STA dst
	ELSE
		LDA src
		STA dst
	ENDIF
	ENDM
	
MOV.W MACRO src, dst
	IF SUBSTR("src",0,1)=="#"
		LDA #(VAL(SUBSTR("src",1,STRLEN("src")-1))#256)
		STA dst
		LDA #(VAL(SUBSTR("src",1,STRLEN("src")-1))>>8)
		STA (dst)+1
	ELSE
		LDA src
		STA dst
		LDA (src)+1
		STA (dst)+1
	ENDIF
	ENDM

