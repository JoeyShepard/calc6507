;Copies of functions from other banks for use in bank 4 to reduce bank switching

    bank4_asm_begin:
    ;Garbage collection routines from WORD_WORDS
    REREGS WORDS    ;Reuse same local variables
    FUNC WORD_WORDS_GC
                        
        ;Calculate size of bytes to delete
        MOV.W sel_address,word_list
        JSR NEXT_WORD_STUB
        JSR WORD_SIZE_SHORT_STUB

        ;Calculate count of bytes to shift
        SEC
        LDA dict_ptr
        SBC next_word
        STA gc_counter
        LDA dict_ptr+1
        SBC next_word+1
        STA gc_counter+1
       
        ;Adjust dict_ptr
        CLC
        LDA word_list
        ADC gc_counter
        STA dict_ptr
        STA dict_save
        LDA word_list+1
        ADC gc_counter+1
        STA dict_ptr+1
        STA dict_save+1
        
        ;Add 3 so final 0-length item is copied too
        CLC
        LDA gc_counter
        ADC #3 
        STA gc_counter
        BNE .gc_no_carry
            INC gc_counter+1
        .gc_no_carry:
        
        ;Copy bytes
        LDY #0
        .gc_copy_loop:
            LDA (next_word),Y
            STA (word_list),Y
            DEC gc_counter
            BNE .no_underflow
                LDA gc_counter+1
                BEQ .gc_copy_done
                DEC gc_counter+1
            .no_underflow: 
            INY
            BNE .gc_copy_loop
            INC next_word+1
            INC word_list+1
            JMP .gc_copy_loop
        .gc_copy_done:
       
        ;Fix addresses in word headers
        MOV.W sel_address,word_list
        .gc_address_loop:
            LDY #0
            LDA (word_list),Y
            TAY
            INY
            LDA (word_list),Y
            STA next_word
            INY
            LDA (word_list),Y
            STA next_word+1
            ORA next_word
            BEQ .gc_address_done
            DEY
            SEC
            LDA next_word
            SBC word_diff
            STA (word_list),Y
            STA words_temp
            INY
            LDA next_word+1
            SBC word_diff+1
            STA (word_list),Y
            STA word_list+1
            LDA words_temp
            STA word_list
            JMP .gc_address_loop
        .gc_address_done:

        ;Fix addresses in variables and word bodies
        LDY #0
        LDA (sel_address),Y
        CLC
        ADC #WORD_HEADER_SIZE
        ADC sel_address
        STA sel_address_body
        LDA sel_address+1
        ADC #0
        STA sel_address_body+1
        MOV.W #dict_begin,word_list
        .gc_obj_loop:
            JSR NEXT_WORD_STUB  
            ORA next_word
            JEQ .gc_objs_done

            LDY #0
            LDA (word_list),Y
            JSR WORD_SKIP_STUB
            LDY #WORD_HEADER_OBJ_TYPE
            LDA (word_list),Y
            TAY
            LDA #WORD_HEADER_SIZE
            JSR WORD_SKIP_STUB

            ;Word or variable?
            CPY #OBJ_SECONDARY
            BEQ .gc_secondary
            CPY #OBJ_VAR
            BEQ .gc_variable
            ;Object other than secondary or var
            ;Something is very wrong
            JMP ERROR_RESTART_STUB

            ;Current object is variable
            .gc_variable:
            ;Only need to adjust smart hex
            LDY #0
            LDA (word_list),Y
            CMP #OBJ_HEX
            BNE .gc_var_next
            LDY #HEX_TYPE
            LDA (word_list),Y
            CMP #HEX_SMART
            BNE .gc_var_next
            
            ;Smart hex found
            MOV.W sel_address,gc_check
            JSR GC_HEX_STUB

            ;Advance to next object
            .gc_var_next:
            LDA #OBJ_SIZE
            JSR WORD_SKIP_STUB
            JMP .gc_obj_loop

            ;Current object is secondary word
            .gc_secondary:
            MOV.W sel_address_body,gc_check
            ;Loop through tokens in word
            .gc_token_loop:
                LDY #0
                LDA (word_list),Y
                LSR
                TAY
                LDA GC_TABLE,Y
                STA words_temp  ;Save copy of byte from lookup table
                AND #WORDS_SKIP2
                BNE .skip2
                LDA words_temp
                AND #WORDS_GC
                BEQ .no_gc
                    ;Garbage collect address
                    LDY #1
                    LDA (word_list),Y
                    STA gc_counter
                    INY
                    LDA (word_list),Y
                    STA gc_counter+1
                    JSR GC_ADDRESS_STUB
                    LDA gc_counter
                    ORA gc_counter+1
                    BNE .not_null
                        ;Address is same as deleted object
                        LDA #TOKEN_BROKEN_REF
                        LDY #0
                        STA (word_list),Y
                        JMP .skip2
                    .not_null:
                    LDA gc_counter
                    LDY #1
                    STA (word_list),Y
                    LDA gc_counter+1
                    INY
                    STA (word_list),Y
                
                    ;Advance past token and address that follows
                    .skip2:
                    LDA #3
                    JSR WORD_SKIP_STUB
                    JMP .gc_token_next
                .no_gc:
                LDA words_temp
                AND #WORDS_SKIP8
                BEQ .no_skip8
                    ;Token with 8 bytes of data embedded after it
                    LDA #OBJ_SIZE
                    JSR WORD_SKIP_STUB
                    JMP .gc_token_next
                .no_skip8:
                ;Single-byte token, increment by one
                LDA #1
                JSR WORD_SKIP_STUB
                
                ;Check if word list pointer has reached next word
                .gc_token_next:
                LDA next_word
                CMP word_list
                BNE .gc_token_loop
                LDA next_word+1
                CMP word_list+1
                BNE .gc_token_loop
                
                ;Done processing word - advance to next word
                JMP .gc_obj_loop
        .gc_objs_done:

        ;Fix addresses on stack
        STX stack_X
        LDA #0
        STA word_list+1
        .gc_stack_loop:
            ;Only need to adjust smart hex
            CPX #0
            BEQ .gc_stack_done
            LDA OBJ_TYPE,X
            CMP #OBJ_HEX
            BNE .gc_stack_next
            LDA HEX_TYPE,X
            CMP #HEX_SMART
            BNE .gc_stack_next
            
            ;Smart hex found
            STX word_list
            MOV.W sel_address,gc_check
            JSR GC_HEX_STUB

            ;Advance to next stack object
            .gc_stack_next:
            TXA
            CLC
            ADC #OBJ_SIZE
            TAX
            JMP .gc_stack_loop
        .gc_stack_done:
        LDX stack_X

    END

    GC_ADDRESS_STUB:
        ;Check if garbage collecting address of deleted object
        LDA gc_counter
        CMP gc_check
        BNE .not_same
        LDA gc_counter+1
        CMP gc_check+1
        BNE .not_same
            ;Garbage collected address is same as deleted object
            LDA #0
            STA gc_counter
            STA gc_counter+1
            RTS
        .not_same:
        
        ;Check if address is in range
        SEC 
        LDA gc_counter
        SBC gc_check
        LDA gc_counter+1
        SBC gc_check+1
        BCC .no_adjustment
        SEC
        LDA #lo(dict_end)
        SBC gc_counter
        LDA #hi(dict_end)
        SBC gc_counter+1
        BCC .no_adjustment
            ;Address in range - adjust
            LDA gc_counter
            SBC word_diff
            STA gc_counter
            LDA gc_counter+1
            SBC word_diff+1
            STA gc_counter+1
        .no_adjustment:
        RTS

    GC_HEX_STUB:
        LDY #HEX_BASE
        LDA (word_list),Y
        STA gc_counter
        INY
        LDA (word_list),Y
        STA gc_counter+1
        JSR GC_ADDRESS_STUB
        
        LDA gc_counter
        ORA gc_counter
        BNE .not_null
            ;Set hex to null if pointed to deleted object
            LDA #0
            LDY #HEX_SUM
            STA (word_list),Y
            INY
            STA (word_list),Y
            LDY #HEX_BASE
            STA (word_list),Y
            INY
            STA (word_list),Y
            RTS
        .not_null:
        CLC
        LDA gc_counter
        LDY #HEX_BASE
        STA (word_list),Y
        LDY #HEX_OFFSET
        ADC (word_list),Y
        LDY #HEX_SUM
        STA (word_list),Y
        LDA gc_counter+1
        LDY #HEX_BASE+1
        STA (word_list),Y
        LDY #HEX_OFFSET+1
        ADC (word_list),Y
        LDY #HEX_SUM+1
        STA (word_list),Y
        RTS

    GC_TABLE:
        FCB WORDS_NO_GC ;                       ;0
        FCB WORDS_NO_GC ; CODE_DUP			    ;2
        FCB WORDS_NO_GC ; CODE_SWAP				;4
        FCB WORDS_NO_GC ; CODE_DROP				;6
        FCB WORDS_NO_GC ; CODE_OVER				;8
        FCB WORDS_NO_GC ; CODE_ROT				;10
        FCB WORDS_NO_GC ; CODE_MIN_ROT			;12
        FCB WORDS_NO_GC ; CODE_CLEAR			;14
        FCB WORDS_NO_GC ; CODE_ADD				;16
        FCB WORDS_NO_GC ; CODE_SUB				;18
        FCB WORDS_NO_GC ; CODE_MULT				;20
        FCB WORDS_NO_GC ; CODE_DIV				;22
        FCB WORDS_NO_GC ; CODE_TICK				;24
        FCB WORDS_NO_GC ; CODE_EXEC				;26
        FCB WORDS_NO_GC ; CODE_STORE			;28
        FCB WORDS_NO_GC ; CODE_FETCH			;30
        FCB WORDS_NO_GC ; CODE_CSTORE			;32
        FCB WORDS_NO_GC ; CODE_CFETCH			;34
        FCB WORDS_NO_GC ; CODE_COLON			;36
        FCB WORDS_NO_GC ; CODE_SEMI				;38
        FCB WORDS_SKIP8 ; CODE_FLOAT			;40
        FCB WORDS_SKIP8 ; CODE_HEX				;42
        FCB WORDS_SKIP8 ; CODE_STRING			;44
        FCB WORDS_NO_GC ; CODE_HALT				;46
        FCB WORDS_NO_GC ; CODE_VAR				;48
        FCB WORDS_GC    ; CODE_VAR_THREAD		;50 Yes
        FCB WORDS_NO_GC ; CODE_STO				;52 
        FCB WORDS_NO_GC ; CODE_FREE				;54
        FCB WORDS_GC    ; CODE_SECONDARY		;56 Yes
        FCB WORDS_NO_GC ; CODE_EXIT				;58 
        FCB WORDS_NO_GC ; CODE_BREAK			;60 
        FCB WORDS_NO_GC ; CODE_QUIT				;62 
        FCB WORDS_GC    ; CODE_STO_THREAD		;64 Yes
        FCB WORDS_NO_GC ; CODE_DO				;66 
        FCB WORDS_NO_GC ; CODE_DO_THREAD		;68 No!!!
        FCB WORDS_NO_GC ; CODE_LOOP				;70 
        FCB WORDS_GC    ; CODE_LOOP_THREAD		;72 Yes
        FCB WORDS_NO_GC ; CODE_EQUAL			;74
        FCB WORDS_NO_GC ; CODE_GT				;76
        FCB WORDS_NO_GC ; CODE_LT				;78
        FCB WORDS_NO_GC ; CODE_NEQ				;80
        FCB WORDS_NO_GC ; CODE_I				;82
        FCB WORDS_NO_GC ; CODE_J				;84
        FCB WORDS_NO_GC ; CODE_K				;86
        FCB WORDS_NO_GC ; CODE_EXIT_THREAD		;88
        FCB WORDS_NO_GC ; CODE_BEGIN			;90
        FCB WORDS_NO_GC ; CODE_AGAIN			;92
        FCB WORDS_GC    ; CODE_AGAIN_THREAD		;94 Yes
        FCB WORDS_NO_GC ; CODE_UNTIL			;96 
        FCB WORDS_GC    ; CODE_UNTIL_THREAD		;98 Yes
        FCB WORDS_NO_GC ; CODE_MAX				;100
        FCB WORDS_NO_GC ; CODE_MIN				;102
        FCB WORDS_NO_GC ; CODE_AND				;104
        FCB WORDS_NO_GC ; CODE_OR				;106
        FCB WORDS_NO_GC ; CODE_XOR				;108
        FCB WORDS_NO_GC ; CODE_NOT				;110
        FCB WORDS_NO_GC ; CODE_LEAVE			;112 
        FCB WORDS_GC    ; CODE_LEAVE_THREAD	    ;114 Yes
        FCB WORDS_NO_GC ; CODE_IF				;116
        FCB WORDS_NO_GC ; CODE_THEN				;118 
        FCB WORDS_NO_GC ; CODE_ELSE				;120
        FCB WORDS_NO_GC ; CODE_LSHIFT			;122 
        FCB WORDS_NO_GC ; CODE_RSHIFT			;124
        FCB WORDS_NO_GC ; CODE_ABS				;126
        FCB WORDS_NO_GC ; CODE_PI				;128
        FCB WORDS_NO_GC ; CODE_SIN				;130
        FCB WORDS_NO_GC ; CODE_COS				;132
        FCB WORDS_NO_GC ; CODE_TAN				;134
        FCB WORDS_NO_GC ; CODE_ASIN				;136
        FCB WORDS_NO_GC ; CODE_ACOS				;138
        FCB WORDS_NO_GC ; CODE_ATAN				;140
        FCB WORDS_NO_GC ; CODE_DEG				;142
        FCB WORDS_NO_GC ; CODE_WORDS            ;144
        FCB WORDS_SKIP2 ; CODE_BROKEN_REF       ;146
        FCB WORDS_NO_GC ; CODE_LN               ;148

    bank4_asm_end:
