 PAGE $0
 ORG $1FFC
 FDB main
 ORG $0
 ORG $20
dummy:
 DFS $1
ret_val:
 DFS $2
screen_ptr:
 DFS $2
R0:
 DFS $9
R1:
 DFS $9
R2:
 DFS $9
R3:
 DFS $9
R4:
 DFS $9
R5:
 DFS $9
R6:
 DFS $9
R7:
 DFS $9
STACK_END:
 ORG $130
global_error:
 DFS $1
input_buff_begin:
 DFS $1
input_buff_end:
 DFS $1
input_buff:
 DFS $40
new_word_len:
 DFS $1
new_word_buff:
 DFS $13
new_stack_item:
 DFS $9
font_inverted:
 DFS $1
stack_count:
 DFS $1
 ORG $900
 JMP main
font_table:
 FCB $0,$0,$0,$0,$0,$0,$0,$0
 FCB $30,$78,$78,$30,$30,$0,$30,$0
 FCB $6C,$6C,$6C,$0,$0,$0,$0,$0
 FCB $6C,$6C,$FE,$6C,$FE,$6C,$6C,$0
 FCB $30,$7C,$C0,$78,$C,$F8,$30,$0
 FCB $0,$C6,$CC,$18,$30,$66,$C6,$0
 FCB $38,$6C,$38,$76,$DC,$CC,$76,$0
 FCB $60,$60,$C0,$0,$0,$0,$0,$0
 FCB $18,$30,$60,$60,$60,$30,$18,$0
 FCB $60,$30,$18,$18,$18,$30,$60,$0
 FCB $0,$66,$3C,$FF,$3C,$66,$0,$0
 FCB $0,$30,$30,$FC,$30,$30,$0,$0
 FCB $0,$0,$0,$0,$0,$30,$30,$60
 FCB $0,$0,$0,$FC,$0,$0,$0,$0
 FCB $0,$0,$0,$0,$0,$30,$30,$0
 FCB $6,$C,$18,$30,$60,$C0,$80,$0
 FCB $7C,$C6,$CE,$DE,$F6,$E6,$7C,$0
 FCB $30,$70,$30,$30,$30,$30,$FC,$0
 FCB $78,$CC,$C,$38,$60,$CC,$FC,$0
 FCB $78,$CC,$C,$38,$C,$CC,$78,$0
 FCB $1C,$3C,$6C,$CC,$FE,$C,$1E,$0
 FCB $FC,$C0,$F8,$C,$C,$CC,$78,$0
 FCB $38,$60,$C0,$F8,$CC,$CC,$78,$0
 FCB $FC,$CC,$C,$18,$30,$30,$30,$0
 FCB $78,$CC,$CC,$78,$CC,$CC,$78,$0
 FCB $78,$CC,$CC,$7C,$C,$18,$70,$0
 FCB $0,$30,$30,$0,$0,$30,$30,$0
 FCB $0,$30,$30,$0,$0,$30,$30,$60
 FCB $18,$30,$60,$C0,$60,$30,$18,$0
 FCB $0,$0,$FC,$0,$0,$FC,$0,$0
 FCB $60,$30,$18,$C,$18,$30,$60,$0
 FCB $78,$CC,$C,$18,$30,$0,$30,$0
 FCB $7C,$C6,$DE,$DE,$DE,$C0,$78,$0
 FCB $30,$78,$CC,$CC,$FC,$CC,$CC,$0
 FCB $FC,$66,$66,$7C,$66,$66,$FC,$0
 FCB $3C,$66,$C0,$C0,$C0,$66,$3C,$0
 FCB $F8,$6C,$66,$66,$66,$6C,$F8,$0
 FCB $FE,$62,$68,$78,$68,$62,$FE,$0
 FCB $FE,$62,$68,$78,$68,$60,$F0,$0
 FCB $3C,$66,$C0,$C0,$CE,$66,$3E,$0
 FCB $CC,$CC,$CC,$FC,$CC,$CC,$CC,$0
 FCB $78,$30,$30,$30,$30,$30,$78,$0
 FCB $1E,$C,$C,$C,$CC,$CC,$78,$0
 FCB $E6,$66,$6C,$78,$6C,$66,$E6,$0
 FCB $F0,$60,$60,$60,$62,$66,$FE,$0
 FCB $C6,$EE,$FE,$FE,$D6,$C6,$C6,$0
 FCB $C6,$E6,$F6,$DE,$CE,$C6,$C6,$0
 FCB $38,$6C,$C6,$C6,$C6,$6C,$38,$0
 FCB $FC,$66,$66,$7C,$60,$60,$F0,$0
 FCB $78,$CC,$CC,$CC,$DC,$78,$1C,$0
 FCB $FC,$66,$66,$7C,$6C,$66,$E6,$0
 FCB $78,$CC,$E0,$70,$1C,$CC,$78,$0
 FCB $FC,$B4,$30,$30,$30,$30,$78,$0
 FCB $CC,$CC,$CC,$CC,$CC,$CC,$FC,$0
 FCB $CC,$CC,$CC,$CC,$CC,$78,$30,$0
 FCB $C6,$C6,$C6,$D6,$FE,$EE,$C6,$0
 FCB $C6,$C6,$6C,$38,$38,$6C,$C6,$0
 FCB $CC,$CC,$CC,$78,$30,$30,$78,$0
 FCB $FE,$C6,$8C,$18,$32,$66,$FE,$0
 FCB $78,$60,$60,$60,$60,$60,$78,$0
 FCB $C0,$60,$30,$18,$C,$6,$2,$0
 FCB $78,$18,$18,$18,$18,$18,$78,$0
 FCB $10,$38,$6C,$C6,$0,$0,$0,$0
 FCB $0,$0,$0,$0,$0,$0,$0,$FF
 FCB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
 FCB $8,$18,$38,$78,$38,$18,$8,$0
 FCB $0,$0,$0,$0,$FF,$FF,$FF,$FF
 FCB $FF,$FF,$FF,$FF,$0,$0,$0,$0
 FCB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
 FCB $0,$0,$EE,$88,$EE,$88,$EE,$0
setup:
 SEI
 CLD
 LDX #$0
 STX stack_count
 LDA #$0
 STA font_inverted
 LDA #$4
 STA $FFE1
 LDA #$5
 STA $FFE2
 RTS
ReadKey:
 LDA $FFE4
 RTS
LCD_clrscr:
 LDA #$0
 STA screen_ptr
 LDA #$40
 STA screen_ptr+$1
 LDA #$80
 STA $6 ;counter
 LDA #$2A
 LDY #$0
 .loop:
 STA (screen_ptr),Y
 INY
 BNE .loop
 INC screen_ptr+$1
 DEC $6 ;counter
 BNE .loop
 LDA #$0
 STA screen_ptr
 LDA #$40
 STA screen_ptr+$1
 RTS
LCD_char:
 LDA $E ;c_out
 CMP #$20
 BCC .._98.skip
 JMP .if0
 .._98.skip:
 RTS
 .if0:
 CMP #$66
 BCS .._103.skip
 JMP .if1
 .._103.skip:
 RTS
 .if1:
 SEC
 SBC #$20
 STA $F ;pixel_ptr
 LDA #$0
 STA $10 ;pixel_ptr
 ASL $F ;pixel_ptr
 ASL $F ;pixel_ptr
 ROL $10 ;pixel_ptr
 ASL $F ;pixel_ptr
 ROL $10 ;pixel_ptr
 LDA #font_table # $100
 ADC $F ;pixel_ptr
 STA $F ;pixel_ptr
 LDA #font_table/$100
 ADC $10 ;pixel_ptr
 STA $10 ;pixel_ptr
 LDA #$0
 STA $11 ;pixel_index
 LDA #$8
 STA $13 ;lc1
 .loop:
 LDA #$8
 STA $14 ;lc2
 LDY $11 ;pixel_index
 INC $11 ;pixel_index
 LDA ($F),Y ;pixel_ptr
 EOR font_inverted
 STA $12 ;pixel
 LDY #$0
 .loop.inner:
 ROL $12 ;pixel
 LDA #$0
 BCS .color
 LDA #$2A
 .color:
 STA (screen_ptr),Y
 INC screen_ptr+$1
 STA (screen_ptr),Y
 INY
 STA (screen_ptr),Y
 DEC screen_ptr+$1
 STA (screen_ptr),Y
 INY
 DEC $14 ;lc2
 BNE .loop.inner
 INC screen_ptr+$1
 INC screen_ptr+$1
 DEC $13 ;lc1
 BNE .loop
 CLC
 LDA screen_ptr
 ADC #$10
 STA screen_ptr
 SEC
 LDA screen_ptr+$1
 SBC #$10
 STA screen_ptr+$1
 RTS
LCD_print:
 LDA #$0
 STA $9 ;index
 .loop:
 LDY $9 ;index
 LDA ($7),Y ;source
 BEQ .done
 STA $A ;arg
 LDA $A ;arg
 STA $E ;LCD_char.c_out
 JSR LCD_char
 INC $9 ;index
 JMP .loop
 .done:
 RTS
MemCopy:
 LDY #$0
 .loop:
 LDA ($D),Y ;source
 STA ($F),Y ;dest
 INY
 CPY $11 ;count
 BNE .loop
 RTS
BCD_Reverse:
 LDY #$0
 SED
 SEC
 .loop:
 LDA #$0
 SBC ($D),Y ;source
 STA ($D),Y ;source
 INY
 CPY $F ;count
 BNE .loop
 CLD
 RTS
DigitHigh:
 LDA $D ;digit
 LSR
 LSR
 LSR
 LSR
 CLC
 ADC #$30
 STA $D ;digit
 LDA $D ;digit
 STA $E ;LCD_char.c_out
 JSR LCD_char
 RTS
DigitLow:
 LDA $D ;digit
 AND #$F
 CLC
 ADC #$30
 STA $D ;digit
 LDA $D ;digit
 STA $E ;LCD_char.c_out
 JSR LCD_char
 RTS
DrawFloat:
 LDA $6 ;source
 STA $D ;MemCopy.source
 LDA $7 ;source
 STA $E ;MemCopy.source
 LDA # (R0) # $100
 STA $F ;MemCopy.dest
 LDA # (R0)/$100
 STA $10 ;MemCopy.dest
 LDA #$9
 STA $11 ;MemCopy.count
 JSR MemCopy
 LDA #$20
 STA $A ;sign
 LDY #$6
 LDA ($6),Y ;source
 CMP #$50
 BCC .positive
 LDA #$2D
 STA $A ;sign
 LDA # (R0+$1) # $100
 STA $D ;BCD_Reverse.source
 LDA # (R0+$1)/$100
 STA $E ;BCD_Reverse.source
 LDA #$6
 STA $F ;BCD_Reverse.count
 JSR BCD_Reverse
 .positive:
 LDA $A ;sign
 STA $E ;LCD_char.c_out
 JSR LCD_char
 LDY #$6
 LDA R0,Y
 STA $9 ;arg
 LDA $9 ;arg
 STA $D ;DigitHigh.digit
 JSR DigitHigh
 LDA #$2E
 STA $E ;LCD_char.c_out
 JSR LCD_char
 LDA $9 ;arg
 STA $D ;DigitLow.digit
 JSR DigitLow
 LDA #$5
 STA $8 ;index
 .loop:
 LDY $8 ;index
 LDA R0,Y
 STA $9 ;arg
 LDA $9 ;arg
 STA $D ;DigitHigh.digit
 JSR DigitHigh
 LDA $9 ;arg
 STA $D ;DigitLow.digit
 JSR DigitLow
 DEC $8 ;index
 LDA $8 ;index
 CMP #$2
 BNE .loop
 LDA #$2B
 STA $A ;sign
 LDY #$8
 LDA ($6),Y ;source
 CMP #$50
 BCC .positive_e
 LDA #$2D
 STA $A ;sign
 LDA # (R0+$7) # $100
 STA $D ;BCD_Reverse.source
 LDA # (R0+$7)/$100
 STA $E ;BCD_Reverse.source
 LDA #$2
 STA $F ;BCD_Reverse.count
 JSR BCD_Reverse
 .positive_e:
 LDA $A ;sign
 STA $E ;LCD_char.c_out
 JSR LCD_char
 LDY #$8
 LDA R0,Y
 STA $9 ;arg
 LDA $9 ;arg
 STA $D ;DigitLow.digit
 JSR DigitLow
 LDY #$7
 LDA R0,Y
 STA $9 ;arg
 LDA $9 ;arg
 STA $D ;DigitHigh.digit
 JSR DigitHigh
 LDA $9 ;arg
 STA $D ;DigitLow.digit
 JSR DigitLow
 RTS
HexHigh:
 LDA $6 ;digit
 LSR
 LSR
 LSR
 LSR
 CMP #$A
 BCC .print_digit
 CLC
 ADC #$37
 STA $7 ;arg
 JMP .done
 .print_digit:
 CLC
 ADC #$30
 STA $7 ;arg
 .done:
 LDA $7 ;arg
 STA $E ;LCD_char.c_out
 JSR LCD_char
 RTS
HexLow:
 LDA $6 ;digit
 AND #$F
 CMP #$A
 BCC .print_digit
 CLC
 ADC #$37
 STA $7 ;arg
 JMP .done
 .print_digit:
 CLC
 ADC #$30
 STA $7 ;arg
 .done:
 LDA $7 ;arg
 STA $E ;LCD_char.c_out
 JSR LCD_char
 RTS
DrawHex:
 LDA #$24
 STA $E ;LCD_char.c_out
 JSR LCD_char
 LDY #$2
 LDA ($8),Y ;source
 STA $A ;arg
 LDA $A ;arg
 STA $6 ;HexHigh.digit
 JSR HexHigh
 LDA $A ;arg
 STA $6 ;HexLow.digit
 JSR HexLow
 LDY #$1
 LDA ($8),Y ;source
 STA $A ;arg
 LDA $A ;arg
 STA $6 ;HexHigh.digit
 JSR HexHigh
 LDA $A ;arg
 STA $6 ;HexLow.digit
 JSR HexLow
 RTS
DrawString:
 LDA #$22
 STA $E ;LCD_char.c_out
 JSR LCD_char
 LDA #$1
 STA $9 ;index
 .loop:
 LDY $9 ;index
 LDA ($6),Y ;source
 BEQ .done
 STA $8 ;arg
 LDA $8 ;arg
 STA $E ;LCD_char.c_out
 JSR LCD_char
 INC $9 ;index
 LDA $9 ;index
 CMP #$9
 BNE .loop
 .done:
 LDA #$22
 STA $E ;LCD_char.c_out
 JSR LCD_char
 RTS
DrawStack:
 TXA
 CLC
 ADC #$24
 STA $4 ;address
 LDA #$0
 STA $5 ;address
 JSR LCD_clrscr
 JMP .._913.str_skip
 .._913.str_addr:
 FCB "RAD",$0
 .._913.str_skip:
 LDA # (.._913.str_addr) # $100
 STA $7 ;LCD_print.source
 LDA # (.._913.str_addr)/$100
 STA $8 ;LCD_print.source
 JSR LCD_print
 LDA #$35
 STA $2 ;character
 LDA #$5
 STA $3 ;counter
 .loop:
 LDA #$0
 STA screen_ptr
 LDA screen_ptr+$1
 CLC
 ADC #$10
 STA screen_ptr+$1
 LDA $2 ;character
 STA $E ;LCD_char.c_out
 JSR LCD_char
 LDA #$3A
 STA $E ;LCD_char.c_out
 JSR LCD_char
 DEC $3 ;counter
 LDA $3 ;counter
 CMP stack_count
 BCS .no_item
 LDY #$0
 LDA ($4),Y ;address
 CMP #$1
 BNE .not_float
 LDA $4 ;address
 STA $6 ;DrawFloat.source
 LDA $5 ;address
 STA $7 ;DrawFloat.source
 JSR DrawFloat
 JMP .item_done
 .not_float:
 CMP #$2
 BNE .not_str
 LDA $4 ;address
 STA $6 ;DrawString.source
 LDA $5 ;address
 STA $7 ;DrawString.source
 JSR DrawString
 JMP .item_done
 .not_str:
 CMP #$3
 BNE .not_hex
 LDA $4 ;address
 STA $8 ;DrawHex.source
 LDA $5 ;address
 STA $9 ;DrawHex.source
 JSR DrawHex
 JMP .item_done
 .not_hex:
 .item_done:
 .no_item:
 LDA $4 ;address
 SEC
 SBC #$9
 STA $4 ;address
 DEC $2 ;character
 LDA $3 ;counter
 BNE .loop
 LDA #$0
 STA screen_ptr
 LDA screen_ptr+$1
 CLC
 ADC #$14
 STA screen_ptr+$1
 LDY #$0
 LDA #$0
 .loop_line:
 STA (screen_ptr),Y
 INC screen_ptr+$1
 STA (screen_ptr),Y
 DEC screen_ptr+$1
 INY
 BNE .loop_line
 RTS
ErrorMsg:
 LDA #$20
 STA screen_ptr
 LDA #$60
 STA screen_ptr+$1
 JMP .._1087.str_skip
 .._1087.str_addr:
 FCB "bbbbbbbbbbbb",$0
 .._1087.str_skip:
 LDA # (.._1087.str_addr) # $100
 STA $7 ;LCD_print.source
 LDA # (.._1087.str_addr)/$100
 STA $8 ;LCD_print.source
 JSR LCD_print
 LDA #$20
 STA screen_ptr
 LDA #$70
 STA screen_ptr+$1
 LDA #$FF
 STA font_inverted
 LDA $2 ;msg
 STA $7 ;LCD_print.source
 LDA $3 ;msg
 STA $8 ;LCD_print.source
 JSR LCD_print
 LDA #$20
 STA screen_ptr
 LDA #$80
 STA screen_ptr+$1
 JMP .._1137.str_skip
 .._1137.str_addr:
 FCB "bbbbbbbbbbbb",$0
 .._1137.str_skip:
 LDA # (.._1137.str_addr) # $100
 STA $7 ;LCD_print.source
 LDA # (.._1137.str_addr)/$100
 STA $8 ;LCD_print.source
 JSR LCD_print
 LDA #$0
 STA font_inverted
 .loop:
 JSR ReadKey
 CMP #$D
 BNE .loop
 RTS
 RTS
InitForth:
 LDA #$0
 STA input_buff_begin
 STA input_buff_end
 STA new_word_len
 RTS
special_chars:
 FCB 'e',$22
 FCB " .$-"
ReadLine:
 LDA #$0
 STA $2 ;cursor
 STA $5 ;index
 STA screen_ptr
 LDA #$AC
 STA screen_ptr+$1
 JMP .._1186.str_skip
 .._1186.str_addr:
 FCB "a               ",$0
 .._1186.str_skip:
 LDA # (.._1186.str_addr) # $100
 STA $7 ;LCD_print.source
 LDA # (.._1186.str_addr)/$100
 STA $8 ;LCD_print.source
 JSR LCD_print
 LDA $FFE6
 STA $3 ;cursor_timer
 .loop:
 LDA #$0
 STA $4 ;arg
 JSR ReadKey
 BNE .key_read
 JMP .no_key
 .key_read:
 CMP #$D
 BNE .not_enter
 LDA $5 ;index
 BEQ .loop
 LDA #$0
 STA input_buff_begin
 LDA $5 ;index
 STA input_buff_end
 RTS
 .not_enter:
 CMP #$8
 BNE .not_backspace
 LDA $5 ;index
 BEQ .backspace_done
 DEC $5 ;index
 CMP #$10
 BCS .backspace_scroll
 LDA #$20
 STA $E ;LCD_char.c_out
 JSR LCD_char
 LDA screen_ptr
 SEC
 SBC #$20
 STA screen_ptr
 PHA
 LDA #$61
 STA $E ;LCD_char.c_out
 JSR LCD_char
 PLA
 STA screen_ptr
 JMP .draw_done
 .backspace_scroll:
 LDY $5 ;index
 DEY
 JMP .scroll_buffer
 .backspace_done:
 JMP .no_key
 .not_backspace:
 LDY #$0
 .special_loop:
 CMP special_chars,Y
 BNE .special_next
 STA $4 ;arg
 JMP .key_done
 .special_next:
 INY
 CPY #$6
 BNE .special_loop
 CMP #$30
 BCC .not_num
 CMP #$3A
 BCS .not_num
 STA $4 ;arg
 JMP .key_done
 .not_num:
 CMP #$41
 BCC .not_upper
 CMP #$5B
 BCS .not_upper
 STA $4 ;arg
 JMP .key_done
 .not_upper:
 CMP #$61
 BCC .not_lower
 CMP #$7B
 BCS .not_lower
 SEC
 SBC #$20
 STA $4 ;arg
 .not_lower:
 .key_done:
 LDA $4 ;arg
 BEQ .not_valid
 LDY $5 ;index
 CPY #$40
 BCS .buffer_full
 STA input_buff,Y
 INC $5 ;index
 CPY #$F
 BCS .scroll_buffer
 LDA $4 ;arg
 STA $E ;LCD_char.c_out
 JSR LCD_char
 LDA screen_ptr
 PHA
 LDA #$61
 STA $E ;LCD_char.c_out
 JSR LCD_char
 PLA
 STA screen_ptr
 JMP .draw_done
 .scroll_buffer:
 LDA #$0
 STA screen_ptr
 TYA
 SEC
 SBC #$E
 STA $6 ;str_index
 .scroll_loop:
 LDY $6 ;str_index
 INC $6 ;str_index
 LDA input_buff,Y
 STA $4 ;arg
 LDA $4 ;arg
 STA $E ;LCD_char.c_out
 JSR LCD_char
 LDA $5 ;index
 CMP $6 ;str_index
 BNE .scroll_loop
 LDA screen_ptr
 PHA
 LDA #$61
 STA $E ;LCD_char.c_out
 JSR LCD_char
 PLA
 STA screen_ptr
 .draw_done:
 .buffer_full:
 .not_valid:
 .no_key:
 LDA $FFE6
 CMP $3 ;cursor_timer
 BEQ .cursor_done
 STA $3 ;cursor_timer
 LDA $2 ;cursor
 BEQ .draw_blank
 LDA #$0
 STA $2 ;cursor
 LDA #$20
 JMP .draw
 .draw_blank:
 LDA #$FF
 STA $2 ;cursor
 LDA #$61
 .draw:
 STA $4 ;arg
 LDA $4 ;arg
 STA $E ;LCD_char.c_out
 JSR LCD_char
 LDA screen_ptr
 SEC
 SBC #$10
 STA screen_ptr
 .cursor_done:
 JMP .loop
 RTS
LineWord:
 LDA #$0
 STA global_error
 LDA #$0
 STA new_word_len
 LDY input_buff_begin
 CPY input_buff_end
 BNE .chars_left
 RTS
 .chars_left:
 .loop:
 LDY input_buff_begin
 LDA input_buff,Y
 INC input_buff_begin
 CMP #$20
 BNE .not_space
 LDA new_word_len
 BEQ .chars_left2
 RTS
 .not_space:
 LDY new_word_len
 STA new_word_buff,Y
 INY
 STY new_word_len
 CPY #$13
 BNE .word_size_good
 LDA #$1
 STA global_error
 RTS
 .word_size_good:
 .chars_left2:
 LDA input_buff_begin
 CMP input_buff_end
 BEQ .found
 JMP .loop
 .found:
 RTS
 RTS
FindWord:
 LDA # (FORTH_WORDS) # $100
 STA ret_val
 LDA # (FORTH_WORDS)/$100
 STA ret_val+$1
 .loop:
 LDY #$0
 LDA (ret_val),Y
 CMP new_word_len
 BNE .loop_next
 INY
 .str_loop:
 LDA (ret_val),Y
 CMP new_word_buff-$1,Y
 BNE .no_match
 CPY new_word_len
 BEQ .word_found
 INY
 JMP .str_loop
 .no_match:
 .loop_next:
 LDY #$0
 LDA (ret_val),Y
 TAY
 INY
 LDA (ret_val),Y
 PHA
 INY
 LDA (ret_val),Y
 STA ret_val+$1
 PLA
 STA ret_val
 ORA ret_val+$1
 BNE .loop
 STA ret_val
 STA ret_val+$1
 .word_found:
 RTS
CheckData:
 LDA #$4
 STA new_stack_item
 LDA new_word_len
 BNE .not_zero_len
 RTS
 .not_zero_len:
 LDY #$8
 LDA #$0
 .zero_loop:
 STA new_stack_item,Y
 DEY
 BNE .zero_loop
 LDY #$0
 LDA new_word_buff
 CMP #$22
 BNE .not_string
 LDA new_word_len
 CMP #$1
 BNE .not_single_quote
 RTS
 .not_single_quote:
 DEC new_word_len
 .loop_str:
 LDA new_word_buff+$1,y
 CMP #$22
 BEQ .str_done
 CPY #$8
 BEQ .string_too_long
 STA new_stack_item+$1,Y
 INY
 CPY new_word_len
 BEQ .string_unterminated
 BNE .loop_str
 .string_too_long:
 .string_unterminated:
 RTS
 .str_done:
 INY
 CPY new_word_len
 BNE .str_return
 LDA #$2
 STA new_stack_item
 .str_return:
 RTS
 .not_string:
 CMP #$24
 BNE .not_hex
 LDA new_word_len
 CMP #$1
 BEQ .hex_error
 CMP #$6
 BCS .hex_error
 DEC new_word_len
 LDY #$0
 .loop_hex:
 LDA new_word_buff+$1,Y
 CMP #$30
 BCC .hex_error
 CMP #$3A
 BCS .not_digit
 SEC
 SBC #$30
 JSR .hex_rotate
 ORA new_stack_item+$1
 STA new_stack_item+$1
 JMP .hex_char_next
 .not_digit:
 CMP #$41
 BCC .hex_error
 CMP #$47
 BCS .hex_error
 SEC
 SBC #$37
 JSR .hex_rotate
 ORA new_stack_item+$1
 STA new_stack_item+$1
 .hex_char_next:
 INY
 CPY new_word_len
 BEQ .hex_done
 CPY #$4
 BNE .loop_hex
 .hex_done:
 LDA #$3
 STA new_stack_item
 RTS
 .hex_error:
 RTS
 .not_hex:
 LDA #$6
 STA $4 ;index
 LDA #$0
 STA $5 ;which_digit
 STA $6 ;negative
 STA $7 ;exp_negative
 STA $8 ;exp_count
 STA $C ;digit_count
 STA $B ;nonzero_found
 STA $A ;dec_found
 STA $9 ;exp_found
 LDA new_word_buff
 CMP #$2D
 BNE .float_no_neg
 LDA #$FF
 STA $6 ;negative
 INY
 .float_no_neg:
 .loop_float:
 LDA new_word_buff,Y
 JSR .digit
 BCC .float_not_digit
 PHA
 LDA $B ;nonzero_found
 BNE .digit_good
 PLA
 PHA
 BEQ .digit_zero
 LDA #$FF
 STA $B ;nonzero_found
 BNE .digit_good
 .digit_zero:
 PLA
 LDA $9 ;exp_found
 BNE .float_next
 LDA $A ;dec_found
 BEQ .float_next
 DEC $8 ;exp_count
 BNE .float_next
 .digit_good:
 LDA $9 ;exp_found
 BNE .exp_digit
 LDA $C ;digit_count
 CMP #$C
 BNE .digit_ok
 PLA
 RTS
 .digit_ok:
 LDA $A ;dec_found
 BNE .no_dec_yet
 INC $8 ;exp_count
 .no_dec_yet:
 PLA
 JSR .add_digit
 .float_next:
 INY
 CPY new_word_len
 BEQ .float_done
 JMP .loop_float
 .exp_digit:
 LDA $C ;digit_count
 CMP #$3
 BNE .exp_digit_ok
 PLA
 RTS
 .exp_digit_ok:
 PLA
 STY $3 ;y_buff
 LDY #$4
 .exp_loop:
 ASL new_stack_item+$7
 ROL new_stack_item+$8
 DEY
 BNE .exp_loop
 LDY $3 ;y_buff
 ORA new_stack_item+$7
 STA new_stack_item+$7
 INC $4 ;index
 JMP .float_next
 .float_not_digit:
 CMP #$2E
 BNE .not_decimal_point
 LDA $A ;dec_found
 BEQ .decimal_good
 RTS
 .decimal_good:
 LDA $9 ;exp_found
 BEQ .exp_good
 RTS
 .exp_good:
 LDA #$FF
 STA $A ;dec_found
 BNE .float_next
 .not_decimal_point:
 CMP #$65
 BNE .not_exp
 LDA $9 ;exp_found
 BEQ .first_exp
 RTS
 .first_exp:
 LDA #$0
 STA $4 ;index
 STA $5 ;which_digit
 STA $C ;digit_count
 STA $B ;nonzero_found
 LDA #$FF
 STA $9 ;exp_found
 BNE .float_next
 .not_exp:
 CMP #$2D
 BNE .not_minus
 LDA $9 ;exp_found
 EOR #$FF
 ORA $4 ;index
 ORA $7 ;exp_negative
 BEQ .minus_good
 RTS
 .minus_good:
 LDA #$FF
 STA $7 ;exp_negative
 BNE .float_next
 .not_minus:
 RTS
 .float_done:
 LDA #$1
 STA new_stack_item
 RTS
 .hex_rotate:
 STY $3 ;y_buff
 LDY #$4
 .hex_rot_loop:
 ASL new_stack_item+$1
 ROL new_stack_item+$2
 DEY
 BNE .hex_rot_loop
 LDY $3 ;y_buff
 RTS
 .digit:
 CMP #$3A
 BCS .is_digit_no
 CMP #$30
 BCC .is_digit_no
 SBC #$30
 RTS
 .is_digit_no:
 CLC
 RTS
 .add_digit:
 PHA
 STY $3 ;y_buff
 LDY $4 ;index
 INC $C ;digit_count
 LDA $5 ;which_digit
 EOR #$FF
 STA $5 ;which_digit
 BEQ .second_digit
 PLA
 ASL
 ASL
 ASL
 ASL
 STA new_stack_item,Y
 LDY $3 ;y_buff
 RTS
 .second_digit:
 PLA
 ORA new_stack_item,Y
 STA new_stack_item,Y
 DEC $4 ;index
 LDY $3 ;y_buff
 RTS
 RTS
Execute:
 LDY #$0
 LDA ($2),Y ;address
 CLC
 ADC #$4
 ADC $2 ;address
 TAY
 LDA #$0
 ADC $3 ;address
 PHA
 TYA
 PHA
 RTS
FORTH_WORDS:
WORD_DUP:
 FCB $3,"DUP"
 FDB WORD_SWAP
 FCB $5
 FCB $2
CODE_DUP:
 LDA #$5
 RTS
WORD_SWAP:
 FCB $4,"SWAP"
 FDB WORD_DROP
 FCB $2
 FCB $4
CODE_SWAP:
 LDA #$6
 RTS
WORD_DROP:
 FCB $4,"DROP"
 FDB WORD_OVER
 FCB $1
 FCB $6
CODE_DROP:
 TXA
 CLC
 ADC #$9
 TAX
 DEC stack_count
 RTS
WORD_OVER:
 FCB $4,"OVER"
 FDB $0
 FCB $6
 FCB $8
CODE_OVER:
 LDA #$8
 RTS
main:
 LDX #$2F
 TXS
 JSR setup
 .input_loop:
 JSR DrawStack
 JSR ReadLine
 .process_loop:
 JSR LineWord
 LDA new_word_len
 BEQ .input_loop
 JSR FindWord
 LDA ret_val
 ORA ret_val+$1
 BEQ .not_found
 LDA ret_val
 STA $2 ;Execute.address
 LDA ret_val+$1
 STA $3 ;Execute.address
 JSR Execute
 JMP .input_loop
 .not_found:
 JSR CheckData
 LDA new_stack_item
 CMP #$4
 BNE .input_good
 JMP .._1480.str_skip
 .._1480.str_addr:
 FCB "INPUT ERROR ",$0
 .._1480.str_skip:
 LDA # (.._1480.str_addr) # $100
 STA $2 ;ErrorMsg.msg
 LDA # (.._1480.str_addr)/$100
 STA $3 ;ErrorMsg.msg
 JSR ErrorMsg
 JMP .input_loop
 .input_good:
 TXA
 SEC
 SBC #$9
 TAX
 INC stack_count
 STA $0 ;dest
 LDA #$0
 STA $1 ;dest
 LDA # (new_stack_item) # $100
 STA $D ;MemCopy.source
 LDA # (new_stack_item)/$100
 STA $E ;MemCopy.source
 LDA $0 ;dest
 STA $F ;MemCopy.dest
 LDA $1 ;dest
 STA $10 ;MemCopy.dest
 LDA #$9
 STA $11 ;MemCopy.count
 JSR MemCopy
 JMP .process_loop
 RTS
EEPROM set *
	OUTRADIX 10
;Display memory usage in console
;===============================
	MESSAGE " "
	MESSAGE "Memory usage"
	MESSAGE "============"
comma_ret set "\{EEPROM-$900}"
comma_ret set "\{substr(comma_ret,0,strlen(comma_ret)-3)},\{substr(comma_ret,strlen(comma_ret)-3,strlen(comma_ret))}"
	MESSAGE "ROM size:	\{comma_ret} bytes (\{100*(EEPROM-$900)/$1700}%) of 5.75k bank"
	;AddCommas GENRAM-$200
	;MESSAGE "RAM size:	\{comma_ret} bytes (\{100*(GENRAM-$200)/($4000-$200)}%) of 15.8k bank"
	;Tell script that prints assembler output to stop outputting
	;Eliminates double output (because of multiple passes???)
	MESSAGE "END"
