;Copies of functions from other banks for use in bank 2 to reduce bank switching
   
bank2_asm_begin:

    ;From: forth.asm - bank 1
    ;Used in: cordic.asm
	FUNC StackAddItem_bank2
		TXA
		SEC
		SBC #OBJ_SIZE
		TAX
		INC stack_count
	END

    ;From: words.asm - bank 3
    ;Used in: cordic.asm
    CODE_DROP_bank2:
        TXA
        CLC
        ADC #OBJ_SIZE
        TAX
        DEC stack_count
        RTS

bank2_asm_end:
