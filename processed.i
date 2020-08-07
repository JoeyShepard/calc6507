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
 DFS $12
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
 FCB $8,$18,$38,$78,$38,$18,$8,$0
 FCB $8,$18,$38,$78,$38,$18,$8,$0
 FCB $8,$18,$38,$78,$38,$18,$8,$0
 FCB $0,$0,$EE,$88,$EE,$88,$EE,$0
setup:
 SEI
 CLD
 LDX #$0
 LDA #$4
 STA $FFE1
 LDA #$5
 STA $FFE2
 JSR DrawStack
 RTS
LCD_clrscr:
 LDA #$0
 STA screen_ptr
 LDA #$40
 STA screen_ptr+$1
 LDA #$80
 STA $1 ;counter
 LDA #$2A
 LDY #$0
 .loop:
 STA (screen_ptr),Y
 INY
 BNE .loop
 INC screen_ptr+$1
 DEC $1 ;counter
 BNE .loop
 LDA #$0
 STA screen_ptr
 LDA #$40
 STA screen_ptr+$1
 RTS
LCD_char:
 LDA $A ;c_out
 CMP #$20
 BCC .._92.skip
 JMP .if0
 .._92.skip:
 RTS
 .if0:
 CMP #$66
 BCS .._97.skip
 JMP .if1
 .._97.skip:
 RTS
 .if1:
 SEC
 SBC #$20
 STA $B ;pixel_ptr
 LDA #$0
 STA $C ;pixel_ptr
 ASL $B ;pixel_ptr
 ASL $B ;pixel_ptr
 ROL $C ;pixel_ptr
 ASL $B ;pixel_ptr
 ROL $C ;pixel_ptr
 LDA #font_table # $100
 ADC $B ;pixel_ptr
 STA $B ;pixel_ptr
 LDA #font_table/$100
 ADC $C ;pixel_ptr
 STA $C ;pixel_ptr
 LDA #$0
 STA $D ;pixel_index
 LDA #$8
 STA $F ;lc1
 .loop:
 LDA #$8
 STA $10 ;lc2
 LDY $D ;pixel_index
 INC $D ;pixel_index
 LDA ($B),Y ;pixel_ptr
 STA $E ;pixel
 LDY #$0
 .loop.inner:
 ROL $E ;pixel
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
 DEC $10 ;lc2
 BNE .loop.inner
 INC screen_ptr+$1
 INC screen_ptr+$1
 DEC $F ;lc1
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
 STA $8 ;index
 .loop:
 LDY $8 ;index
 LDA ($6),Y ;source
 BEQ .done
 STA $9 ;arg
 LDA $9 ;arg
 STA $A ;LCD_char.c_out
 JSR LCD_char
 INC $8 ;index
 JMP .loop
 .done:
 RTS
BCD_Reverse:
 LDY #$0
 SED
 SEC
 .loop:
 LDA #$0
 SBC (dummy),Y
 STA (dummy),Y
 INY
 CPY dummy
 BNE .loop
 CLD
 RTS
DigitHigh:
 LDA dummy
 LSR
 LSR
 LSR
 LSR
 CLC
 ADC #$30
 STA dummy
 LDA dummy
 STA $A ;LCD_char.c_out
 JSR LCD_char
 RTS
DigitLow:
 LDA dummy
 AND #$F
 CLC
 ADC #$30
 STA dummy
 LDA dummy
 STA $A ;LCD_char.c_out
 JSR LCD_char
 RTS
DrawFloat:
 JSR MemCopy
 LDA #$20
 STA dummy
 LDY #$6
 LDA (dummy),Y
 CMP #$50
 BCC .positive
 LDA #$2D
 STA dummy
 LDA # (R0+$1) # $100
 STA dummy
 LDA # (R0+$1)/$100
 STA dummy+$1
 LDA #$6
 STA dummy
 JSR BCD_Reverse
 .positive:
 LDA dummy
 STA $A ;LCD_char.c_out
 JSR LCD_char
 LDY #$6
 LDA R0,Y
 STA dummy
 LDA dummy
 STA dummy
 JSR DigitHigh
 LDA #$2E
 STA $A ;LCD_char.c_out
 JSR LCD_char
 LDA dummy
 STA dummy
 JSR DigitLow
 LDA #$5
 STA dummy
 .loop:
 LDY dummy
 LDA R0,Y
 STA dummy
 LDA dummy
 STA dummy
 JSR DigitHigh
 LDA dummy
 STA dummy
 JSR DigitLow
 DEC dummy
 LDA dummy
 CMP #$2
 BNE .loop
 LDA #$2B
 STA dummy
 LDY #$8
 LDA (dummy),Y
 CMP #$50
 BCC .positive_e
 LDA #$2D
 STA dummy
 LDA # (R0+$7) # $100
 STA dummy
 LDA # (R0+$7)/$100
 STA dummy+$1
 LDA #$2
 STA dummy
 JSR BCD_Reverse
 .positive_e:
 LDA dummy
 STA $A ;LCD_char.c_out
 JSR LCD_char
 LDY #$8
 LDA R0,Y
 STA dummy
 LDA dummy
 STA dummy
 JSR DigitLow
 LDY #$7
 LDA R0,Y
 STA dummy
 LDA dummy
 STA dummy
 JSR DigitHigh
 LDA dummy
 STA dummy
 JSR DigitLow
 RTS
HexHigh:
 LDA dummy
 LSR
 LSR
 LSR
 LSR
 CMP #$A
 BCC .print_digit
 CLC
 ADC #$37
 STA dummy
 JMP .done
 .print_digit:
 CLC
 ADC #$30
 STA dummy
 .done:
 LDA dummy
 STA $A ;LCD_char.c_out
 JSR LCD_char
 RTS
HexLow:
 LDA dummy
 AND #$F
 CMP #$A
 BCC .print_digit
 CLC
 ADC #$37
 STA dummy
 JMP .done
 .print_digit:
 CLC
 ADC #$30
 STA dummy
 .done:
 LDA dummy
 STA $A ;LCD_char.c_out
 JSR LCD_char
 RTS
DrawHex:
 JMP .._638.str_skip
 .._638.str_addr:
 FCB "$",$0
 .._638.str_skip:
 LDA # (.._638.str_addr) # $100
 STA $6 ;LCD_print.source
 LDA # (.._638.str_addr)/$100
 STA $7 ;LCD_print.source
 JSR LCD_print
 LDY #$8
 LDA (dummy),Y
 STA dummy
 LDA dummy
 STA dummy
 JSR HexHigh
 LDA dummy
 STA dummy
 JSR HexLow
 LDY #$7
 LDA (dummy),Y
 STA dummy
 LDA dummy
 STA dummy
 JSR HexHigh
 LDA dummy
 STA dummy
 JSR HexLow
 RTS
DrawStack:
 JSR LCD_clrscr
 JMP .._760.str_skip
 .._760.str_addr:
 FCB "RAD",$0
 .._760.str_skip:
 LDA # (.._760.str_addr) # $100
 STA $6 ;LCD_print.source
 LDA # (.._760.str_addr)/$100
 STA $7 ;LCD_print.source
 JSR LCD_print
 LDA #$35
 STA $3 ;character
 LDA #$D3
 STA $2 ;counter
 .loop:
 LDA #$0
 STA screen_ptr
 LDA screen_ptr+$1
 CLC
 ADC #$10
 STA screen_ptr+$1
 LDA $3 ;character
 STA $A ;LCD_char.c_out
 JSR LCD_char
 LDA #$3A
 STA $A ;LCD_char.c_out
 JSR LCD_char
 DEC $3 ;character
 LDA $2 ;counter
 CLC
 ADC #$9
 STA $2 ;counter
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
InitForth:
 LDA #$0
 STA input_buff_begin
 STA input_buff_end
 STA new_word_len
 RTS
LineWord:
 LDA #$0
 STA new_word_len
 LDY input_buff_begin
 CPY input_buff_end
 BNE .chars_left
 RTS
 .chars_left:
 LDA #$0
 STA $1 ;mode
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
 CPY #$12
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
MemCopy:
 LDY #$0
 .loop:
 LDA (dummy),Y
 STA (dummy),Y
 INY
 CPY dummy
 BNE .loop
 RTS
special_chars:
 FCB " e."
ReadLine:
 LDA #$0
 STA $1 ;cursor
 STA $4 ;index
 STA screen_ptr
 LDA #$AC
 STA screen_ptr+$1
 JMP .._884.str_skip
 .._884.str_addr:
 FCB "a               ",$0
 .._884.str_skip:
 LDA # (.._884.str_addr) # $100
 STA $6 ;LCD_print.source
 LDA # (.._884.str_addr)/$100
 STA $7 ;LCD_print.source
 JSR LCD_print
 LDA $FFE6
 STA $2 ;cursor_timer
 .loop:
 LDA #$0
 STA $3 ;arg
 LDA $FFE4
 BNE .key_read
 JMP .no_key
 .key_read:
 CMP #$D
 BNE .not_enter
 LDA $4 ;index
 BEQ .loop
 LDA #$0
 STA input_buff_begin
 LDA $4 ;index
 STA input_buff_end
 RTS
 .not_enter:
 CMP #$8
 BNE .not_backspace
 LDA $4 ;index
 BEQ .backspace_done
 DEC $4 ;index
 CMP #$10
 BCS .backspace_scroll
 LDA #$20
 STA $A ;LCD_char.c_out
 JSR LCD_char
 LDA screen_ptr
 SEC
 SBC #$20
 STA screen_ptr
 PHA
 LDA #$61
 STA $A ;LCD_char.c_out
 JSR LCD_char
 PLA
 STA screen_ptr
 JMP .draw_done
 .backspace_scroll:
 LDY $4 ;index
 DEY
 JMP .scroll_buffer
 .backspace_done:
 JMP .no_key
 .not_backspace:
 LDY #$0
 .special_loop:
 CMP special_chars,Y
 BNE .special_next
 STA $3 ;arg
 JMP .key_done
 .special_next:
 INY
 CPY #$3
 BNE .special_loop
 CMP #$30
 BCC .not_num
 CMP #$3A
 BCS .not_num
 STA $3 ;arg
 JMP .key_done
 .not_num:
 CMP #$41
 BCC .not_upper
 CMP #$5B
 BCS .not_upper
 STA $3 ;arg
 JMP .key_done
 .not_upper:
 CMP #$61
 BCC .not_lower
 CMP #$7B
 BCS .not_lower
 SEC
 SBC #$20
 STA $3 ;arg
 .not_lower:
 .key_done:
 LDA $3 ;arg
 BEQ .not_valid
 LDY $4 ;index
 CPY #$40
 BCS .buffer_full
 STA input_buff,Y
 INC $4 ;index
 CPY #$F
 BCS .scroll_buffer
 LDA $3 ;arg
 STA $A ;LCD_char.c_out
 JSR LCD_char
 LDA screen_ptr
 PHA
 LDA #$61
 STA $A ;LCD_char.c_out
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
 STA $5 ;str_index
 .scroll_loop:
 LDY $5 ;str_index
 INC $5 ;str_index
 LDA input_buff,Y
 STA $3 ;arg
 LDA $3 ;arg
 STA $A ;LCD_char.c_out
 JSR LCD_char
 LDA $4 ;index
 CMP $5 ;str_index
 BNE .scroll_loop
 LDA screen_ptr
 PHA
 LDA #$61
 STA $A ;LCD_char.c_out
 JSR LCD_char
 PLA
 STA screen_ptr
 .draw_done:
 .buffer_full:
 .not_valid:
 .no_key:
 LDA $FFE6
 CMP $2 ;cursor_timer
 BEQ .cursor_done
 STA $2 ;cursor_timer
 LDA $1 ;cursor
 BEQ .draw_blank
 LDA #$0
 STA $1 ;cursor
 LDA #$20
 JMP .draw
 .draw_blank:
 LDA #$FF
 STA $1 ;cursor
 LDA #$61
 .draw:
 STA $3 ;arg
 LDA $3 ;arg
 STA $A ;LCD_char.c_out
 JSR LCD_char
 LDA screen_ptr
 SEC
 SBC #$10
 STA screen_ptr
 .cursor_done:
 JMP .loop
 RTS
main:
 LDX #$2F
 TXS
 JSR setup
 JSR ReadLine
 JSR LineWord
 BRK
 BRK
 JSR LineWord
 BRK
 BRK
 JSR LineWord
 BRK
 BRK
 JSR LineWord
 BRK
 BRK
 JSR LineWord
 BRK
 BRK
 BRK
 BRK
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
