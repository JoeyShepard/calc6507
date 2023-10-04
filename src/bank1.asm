;Copies of functions from other banks for use in bank 1 to reduce bank switching
   
bank1_asm_begin:

    ;From: words.asm - bank 3
    ;Used in: cordic.asm
    CODE_DROP_bank1:
        TXA
        CLC
        ADC #OBJ_SIZE
        TAX
        DEC stack_count
        RTS

    CODE_FREE_bank1:
        LDA #OBJ_HEX
        STA 0,X
        LDA #lo(dict_end)
        SEC
        SBC dict_ptr
        STA HEX_SUM,X
        LDA #hi(dict_end)
        SBC dict_ptr+1
        STA HEX_SUM+1,X
        LDA #0
        STA HEX_TYPE,X
        RTS

bank1_asm_end:
