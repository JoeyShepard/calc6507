;Existing functions or parts of functions moved from banked memory to fixed ROM

;From forth.asm
;==============
    ;If word found:
    ;- ret_val: token
    ;- ret_address: beginning of word header
    ;- obj_address: beginning of code after header
    ;If word not found:
    ;- ret_val: 0 
    ;- ret_address: last searched word (not useful)
    ;- obj_address: unchanged
	FUNC FindWord
        VARS
            BYTE address_temp
            BYTE bank_temp
        END

		LDA new_word_len    ;Set by LineWord
		BEQ .not_found
		MOV.W #FORTH_WORDS,ret_address
		.loop:
            ;Length of word in dictionary
			LDY #0
			LDA (ret_address),Y
			CMP new_word_len
			BNE .loop_next
				INY
                ;Loop through letters of word in dictionary
				.str_loop:
					LDA (ret_address),Y
					CMP new_word_buff-1,Y	;Offset by 1 since string starts one byte in
					BNE .no_match
						CPY new_word_len
						BEQ .word_found
							INY
							JMP .str_loop
					.no_match:
			.loop_next:
            ;Address of next word in dictionary
			LDY #0
			LDA (ret_address),Y
			TAY
			INY
			LDA (ret_address),Y
            STA address_temp
			INY 
			LDA (ret_address),Y
			STA ret_address+1
			LDA address_temp
			STA ret_address
            ;Check for end of dictionary
			ORA ret_address+1
			BNE .loop
			;Done searching - zero ret_val
			.not_found:
			STA ret_val
			RTS
		.word_found:
	   
        ;Load token
		LDY #0
		LDA (ret_address),Y
		TAY
		INY
		INY
		INY
		LDA (ret_address),Y
		STA ret_val
		;Address for tick and user defined words
		INY
		CLC
		TYA
		ADC ret_address
		STA obj_address
		LDA ret_address+1
		ADC #0
		STA obj_address+1
	END

;From words.asm
;==============
    ;First part of WORDS command. Searches built in words, so needs to see bank 3.
    REREGS WORDS    ;Reuse same local variables
    FUNC WORD_WORDS_Search

        LDA #WORDS_PRIM
        .display_new:           ;New screen - reset offset into list
            STA words_mode      ;What to display - primary words, variables, or user-defined words
            LDA #0
            STA skip_count      ;Words to skip before printing
            STA sel_row         ;Selected row on screen
        .display:

            ;Print out list of words
            CALL LCD_clrscr
            LDA skip_count      ;Words to skip before printing
            STA word_count      ;Counter of words to skip
            LDA #0
            STA rows_drawn      ;Rows drawn to screen
            STA sel_address     ;Address of selected word
            STA sel_address+1   ;Address of selected word

            ;Whether primitive, variable, or user-defined word
            LDA words_mode
            CMP #WORDS_PRIM
            JNE .not_prim
                ;Showing primary words
                MOV.W #FORTH_WORDS,word_list
                JMP .type_done
            .not_prim:
                ;Showing variables and user-defined words
                MOV.W #dict_begin,word_list
            .type_done:

            .word_skip_loop:
                JSR NEXT_WORD_STUB

                ;No words left to skip?
                LDA word_count
                BEQ .word_skip_done     
               
                ;End of list?
                JSR WORD_SIZE_STUB
                CPY #WORDS_WORDS_DONE
                BEQ .word_skip_done

                ;Skip word if not same type
                JSR WORD_TYPE_STUB
                CMP words_mode
                BNE .skip_word

                ;Skip words with no name
                LDY #0
                LDA (word_list),Y
                BEQ .skip_word
                    DEC word_count
                .skip_word:
                
                ;Update pointer to next word
                MOV.W next_word,word_list
                JMP .word_skip_loop
            .word_skip_done:

            ;Check if any words to draw - vars and user-defined only
            LDA next_word
            ORA next_word+1
            JEQ .word_draw_done

            LDA #WORDS_ROWS
            STA word_count
            .word_draw_loop:  

                ;No words left to draw?
                LDA word_count
                JEQ .word_draw_done

                ;End of list?
                JSR WORD_SIZE_STUB
                STY words_left

                ;Skip word if not same type?
                JSR WORD_TYPE_STUB
                CMP words_mode
                JNE .next_word

                ;Skip words with no name
                LDY #0
                LDA (word_list),Y
                JEQ .next_word

                ;Invert selected row
                LDA #0
                STA font_inverted
                LDA #WORDS_ROWS
                SEC
                SBC word_count  ;Rows left to print
                CMP sel_row     ;Selected row
                BNE .not_selected_row
                    LDA #$FF
                    STA font_inverted
                    CALL LCD_print, "                "
                    LDA #0
                    CALL LCD_Col

                    ;Save address of selected row
                    MOV.W word_list,sel_address
                .not_selected_row:

                ;Draw characters in word
                LDA #1
                STA index
                .word_draw_chars:
                    LDY index
                    LDA (word_list),Y
                    STA words_temp
                    CALL LCD_char, words_temp
                    INC index
                    LDY #0
                    LDA (word_list),Y
                    CMP index
                BCS .word_draw_chars

                ;Draw word size
                LDA #WORDS_SIZE_X
                CALL LCD_Col
                LDA #'$'
                STA words_temp
                CALL LCD_char, words_temp
                CALL HexHigh, word_diff+1
                CALL HexLow, word_diff+1
                CALL HexHigh, word_diff
                CALL HexLow, word_diff

                ;Mark line as drawn
                INC rows_drawn

                ;Next line on screen
                LDA #0
                CALL LCD_Col
                LDA #WORDS_ROWS+1
                SEC
                SBC word_count  ;Rows left to print
                CALL LCD_Row
               
                ;Next word to draw
                DEC word_count
                .next_word:
                LDA words_left    ;Set above by WORD_SIZE_STUB
                CMP #WORDS_WORDS_DONE
                BEQ .word_draw_done
                MOV.W next_word,word_list
                JSR NEXT_WORD_STUB 
                JMP .word_draw_loop

            .word_draw_done:

            ;Print modes out along bottom of screen
            MOV.W #WORDS_MSG, word_list
            LDA #WORDS_Y
            CALL LCD_Row
            LDA #WORDS_PRIM
            STA word_count
            .mode_loop:
                LDA #0
                STA font_inverted
                LDA words_mode
                CMP word_count
                BNE .not_selected
                    LDA #$FF
                    STA font_inverted
                .not_selected:
                CALL LCD_print, word_list

                LDA #WORD_MSG_LEN
                JSR WORD_SKIP_STUB
                INC word_count
                LDA word_count
                CMP #WORDS_LAST_MODE
                BNE .mode_loop

        .input_loop:
            CALL ReadKey
            CMP #'A'
            BNE .not_a
                LDA #WORDS_PRIM
                JMP .display_new
            .not_a:
            CMP #'B'
            BNE .not_b
                LDA #WORDS_USER
                JMP .display_new
            .not_b:
            CMP #'C'
            BNE .not_c
                LDA #WORDS_VARS
                JMP .display_new
            .not_c:
            CMP #'+'    ;Selection down
            BNE .not_down

                LDA rows_drawn  ;Rows drawn to screen
                CLC
                SBC sel_row     ;Selected row on screen
                BNE .not_at_end
                    ;Last line selected
                    LDA words_mode
                    CMP #WORDS_PRIM
                    BNE .last_not_prim
                        ;Primary selected 
                        LDA words_left
                        CMP #WORDS_WORDS_DONE
                        BEQ .input_loop
                        ;Advance scroll
                        INC skip_count
                        JMP .display
                    .last_not_prim:
                        ;Var or user-defined selected
                        MOV.W sel_address,word_list
                        .down_loop:
                            JSR NEXT_WORD_STUB
                            JSR WORD_SIZE_STUB
                            CPY #WORDS_WORDS_DONE
                            BEQ .input_loop
                            MOV.W next_word,word_list
                            JSR WORD_TYPE_STUB
                            CMP words_mode
                            JNE .down_loop 
                            ;Advance scroll
                            INC skip_count
                            JMP .display
                .not_at_end:
                INC sel_row
                JMP .display
            .not_down:
            CMP #'-'    ;Selection up
            BNE .not_up
                LDA sel_row     ;Selected row on screen
                BEQ .at_top
                    ;Not at top - move up one
                    DEC sel_row
                    JMP .display
                .at_top:
                LDA skip_count    ;Rows to skip
                JEQ .input_loop
                DEC skip_count
                JMP .display
            .not_up:
            CMP #KEY_ON
            BNE .not_on
                RTS
            .not_on:
            CMP #KEY_BACKSPACE
            JNE .not_backspace
                LDA words_mode
                CMP #WORDS_PRIM
                JEQ .cant_delete
                    ;Anything to delete selected?
                    LDA sel_address
                    ORA sel_address+1
                    JEQ .input_loop

                    ;Jump to GC code in bank 4
                    BCALL WORD_WORDS_GC
                    LDA words_mode
                    JMP .display_new
                .cant_delete:
            .not_backspace:
        JMP .input_loop
    END

    ;Stubs for WORD_WORDS_Search
    ;Here since needed for above code, also reused in bank 4
    NEXT_WORD_STUB:
        LDY #0  ;Point to next word
        LDA (word_list),Y
        TAY
        INY
        LDA (word_list),Y
        STA next_word
        INY
        LDA (word_list),Y
        STA next_word+1
        RTS

    WORD_TYPE_STUB:
        LDY #0
        LDA (word_list),Y
        CLC
        TODO: magic number
        ADC #4  ;Point past name to word type
        TAY
        LDA (word_list),Y
        RTS

    WORD_SIZE_STUB:
        ;Check if next word is beginning of dictionary - only possible when searching primitives
        LDY #WORDS_WORDS_LEFT
        LDA next_word
        CMP #lo(dict_begin)
        BNE .not_dict_begin
            LDA next_word+1
            CMP #hi(dict_begin)
            BNE .not_dict_begin
                ;Next word is dict_begin! Adjust calculation
                LDA #lo(FORTH_WORDS_END-FORTH_LAST_WORD)
                STA word_diff
                LDA #hi(FORTH_WORDS_END-FORTH_LAST_WORD)
                STA word_diff+1
                LDY #WORDS_WORDS_DONE
                RTS
        .not_dict_begin:

        ;Check if next word is last word in dictionary
        LDA next_word+1
        CMP dict_ptr+1
        BNE .not_dict_end
            LDA next_word
            CMP dict_ptr
            BNE .not_dict_end
                ;Next word is end of dictionary
                LDY #WORDS_WORDS_DONE
        .not_dict_end:
        
        ;*FALLTHROUGH HERE!*

    WORD_SIZE_SHORT_STUB:
        ;Calculate size
        SEC
        LDA next_word
        SBC word_list
        STA word_diff
        LDA next_word+1
        SBC word_list+1
        STA word_diff+1
        RTS 

    WORD_SKIP_STUB:
        CLC
        ADC word_list
        STA word_list
        BNE .no_carry
            INC word_list+1
        .no_carry:
        RTS

    WORDS_MSG:
        FCB " A-PRIM",0
        FCB " B-USER",0
        FCB " C-VARS",0

