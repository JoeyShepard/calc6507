 PAGE $0
 ORG $1FFC
 FDB main
 ORG $0
 
dummy:
 DFS $1
 
ret_val:
 DFS $2
 
cx:
 DFS $1
 
cy:
 DFS $1
 
screen_ptr:
 DFS $2
 
R0:
 DFS $9
 ORG $130
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
 FCB $78,$18,$18,$18,$18,$18,$78,$0
 FCB $10,$38,$6C,$C6,$0,$0,$0,$0
 FCB $0,$0,$0,$0,$0,$0,$0,$FF
 
setup:
 SEI
 CLD
 LDX #$0
 LDA #$4
 STA $FFE1
 LDA #$0
 STA screen_ptr
 LDA #$40
 STA screen_ptr+$1
 RTS
 
LCD_char:
 LDA $28 ;c_out
 CMP #$20
 BCC .._51.skip
 JMP .if0
 .._51.skip:
 RTS
 .if0:
 CMP #$60
 BCS .._56.skip
 JMP .if1
 .._56.skip:
 RTS
 .if1:
 SEC
 SBC #$20
 STA $29 ;pixel_ptr
 LDA #$0
 STA $2A ;pixel_ptr
 ASL $29 ;pixel_ptr
 ASL $29 ;pixel_ptr
 ROL $2A ;pixel_ptr
 ASL $29 ;pixel_ptr
 ROL $2A ;pixel_ptr
 LDA #font_table # $100
 ADC $29 ;pixel_ptr
 STA $29 ;pixel_ptr
 LDA #font_table/$100
 ADC $2A ;pixel_ptr
 STA $2A ;pixel_ptr
 LDA #$0
 STA $2B ;pixel_index
 LDA #$8
 STA $2D ;lc1
 .loop:
 LDA #$8
 STA $2E ;lc2
 LDY $2B ;pixel_index
 INC $2B ;pixel_index
 LDA ($29),Y ;pixel_ptr
 STA $2C ;pixel
 LDY #$0
 .loop.inner:
 ROL $2C ;pixel
 LDA #$3F
 BCS .color
 LDA #$0
 .color:
 STA (screen_ptr),Y
 INC screen_ptr+$1
 STA (screen_ptr),Y
 INY
 STA (screen_ptr),Y
 DEC screen_ptr+$1
 STA (screen_ptr),Y
 INY
 DEC $2E ;lc2
 BNE .loop.inner
 INC screen_ptr+$1
 INC screen_ptr+$1
 DEC $2D ;lc1
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
 STA $25 ;index
 .loop:
 LDY $25 ;index
 LDA ($20),Y ;source
 BEQ .done
 STA $26 ;arg
 LDA $26 ;arg
 STA $28 ;LCD_char.c_out
 JSR LCD_char
 INC $25 ;index
 JMP .loop
 .done:
 RTS
 
MemCopy:
 LDY #$0
 .loop:
 LDA ($27),Y ;source
 STA ($29),Y ;dest
 INY
 CPY $2B ;count
 BNE .loop
 RTS
 
DigitHigh:
 LDA $27 ;digit
 LSR
 LSR
 LSR
 LSR
 CLC
 ADC #$30
 STA $27 ;digit
 LDA $27 ;digit
 STA $28 ;LCD_char.c_out
 JSR LCD_char
 RTS
 
DigitLow:
 LDA $27 ;digit
 AND #$F
 CLC
 ADC #$30
 STA $27 ;digit
 LDA $27 ;digit
 STA $28 ;LCD_char.c_out
 JSR LCD_char
 RTS
 
DrawFloat:
 LDA $20 ;source
 STA $27 ;MemCopy.source
 LDA $21 ;source
 STA $28 ;MemCopy.source
 LDA # (R0) # $100
 STA $29 ;MemCopy.dest
 LDA # (R0)/$100
 STA $2A ;MemCopy.dest
 LDA #$9
 STA $2B ;MemCopy.count
 JSR MemCopy
 LDA #$20
 STA $24 ;sign
 LDY #$6
 LDA ($20),Y ;source
 CMP #$50
 BCC .positive
 LDA #$2D
 STA $24 ;sign
 JSR BCD_Reverse
 .positive:
 LDA $24 ;sign
 STA $28 ;LCD_char.c_out
 JSR LCD_char
 LDY #$6
 LDA R0,Y
 STA $23 ;arg
 LDA $23 ;arg
 STA $27 ;DigitHigh.digit
 JSR DigitHigh
 LDA #$2E
 STA $28 ;LCD_char.c_out
 JSR LCD_char
 LDA $23 ;arg
 STA $27 ;DigitLow.digit
 JSR DigitLow
 LDA #$5
 STA $22 ;index
 .loop:
 LDY $22 ;index
 LDA R0,Y
 STA $23 ;arg
 LDA $23 ;arg
 STA $27 ;DigitHigh.digit
 JSR DigitHigh
 LDA $23 ;arg
 STA $27 ;DigitLow.digit
 JSR DigitLow
 DEC $22 ;index
 LDA $22 ;index
 CMP #$2
 BNE .loop
 LDA #$2B
 STA $24 ;sign
 LDY #$8
 LDA ($20),Y ;source
 CMP #$50
 BCC .positive_e
 LDA #$2D
 STA $24 ;sign
 JSR BCD_Reverse
 .positive_e:
 LDA $24 ;sign
 STA $28 ;LCD_char.c_out
 JSR LCD_char
 LDY #$8
 LDA R0,Y
 STA $23 ;arg
 LDA $23 ;arg
 STA $27 ;DigitLow.digit
 JSR DigitLow
 LDY #$7
 LDA R0,Y
 STA $23 ;arg
 LDA $23 ;arg
 STA $27 ;DigitHigh.digit
 JSR DigitHigh
 LDA $23 ;arg
 STA $27 ;DigitLow.digit
 JSR DigitLow
 RTS
 
HexHigh:
 LDA $20 ;digit
 LSR
 LSR
 LSR
 LSR
 CMP #$A
 BCC .print_digit
 CLC
 ADC #$37
 STA $21 ;arg
 JMP .done
 .print_digit:
 CLC
 ADC #$30
 STA $21 ;arg
 .done:
 LDA $21 ;arg
 STA $28 ;LCD_char.c_out
 JSR LCD_char
 RTS
 
HexLow:
 LDA $20 ;digit
 AND #$F
 CMP #$A
 BCC .print_digit
 CLC
 ADC #$37
 STA $21 ;arg
 JMP .done
 .print_digit:
 CLC
 ADC #$30
 STA $21 ;arg
 .done:
 LDA $21 ;arg
 STA $28 ;LCD_char.c_out
 JSR LCD_char
 RTS
 
DrawHex:
 JMP .._578.str_skip
 .._578.str_addr:
 FCB "         $",$0
 .._578.str_skip:
 LDA # (.._578.str_addr) # $100
 STA $20 ;LCD_print.source
 LDA # (.._578.str_addr)/$100
 STA $21 ;LCD_print.source
 JSR LCD_print
 BRK
 BRK
 LDY #$8
 LDA ($22),Y ;source
 STA $24 ;arg
 LDA $24 ;arg
 STA $20 ;HexHigh.digit
 JSR HexHigh
 LDA $24 ;arg
 STA $20 ;HexLow.digit
 JSR HexLow
 LDY #$7
 LDA ($22),Y ;source
 STA $24 ;arg
 LDA $24 ;arg
 STA $20 ;HexHigh.digit
 JSR HexHigh
 LDA $24 ;arg
 STA $20 ;HexLow.digit
 JSR HexLow
 RTS
 
BCD_Reverse:
 LDY #$0
 SED
 SEC
 .loop:
 LDA #$0
 SBC ($27),Y ;source
 STA ($27),Y ;source
 INY
 CPY $29 ;count
 BNE .loop
 CLD
 RTS
 
test_val1:
 FCB $1,$12,$90,$78,$56,$34,$12,$1,$0
 
test_val2:
 FCB $1,$23,$1,$89,$67,$45,$23,$3,$0
 
test_val3:
 FCB $3,$0,$0,$0,$0,$0,$0,$DE,$BC
 
main:
 LDX #$2F
 TXS
 JSR setup
 JMP .._705.str_skip
 .._705.str_addr:
 FCB "RAD",$0
 .._705.str_skip:
 LDA # (.._705.str_addr) # $100
 STA $20 ;LCD_print.source
 LDA # (.._705.str_addr)/$100
 STA $21 ;LCD_print.source
 JSR LCD_print
 LDA #$50
 STA screen_ptr+$1
 LDA #$0
 STA screen_ptr
 LDA # (test_val1) # $100
 STA $27 ;MemCopy.source
 LDA # (test_val1)/$100
 STA $28 ;MemCopy.source
 LDA #$F7
 STA $29 ;MemCopy.dest
 LDA #$0
 STA $2A ;MemCopy.dest
 LDA #$9
 STA $2B ;MemCopy.count
 JSR MemCopy
 LDX #$F7
 LDA #$35
 STA $28 ;LCD_char.c_out
 JSR LCD_char
 LDA #$3A
 STA $28 ;LCD_char.c_out
 JSR LCD_char
 LDA #$F7
 STA $20 ;DrawFloat.source
 LDA #$0
 STA $21 ;DrawFloat.source
 JSR DrawFloat
 LDA screen_ptr+$1
 CLC
 ADC #$10
 STA screen_ptr+$1
 LDA # (test_val3) # $100
 STA $27 ;MemCopy.source
 LDA # (test_val3)/$100
 STA $28 ;MemCopy.source
 LDA #$EE
 STA $29 ;MemCopy.dest
 LDA #$0
 STA $2A ;MemCopy.dest
 LDA #$9
 STA $2B ;MemCopy.count
 JSR MemCopy
 LDX #$EE
 LDA #$34
 STA $28 ;LCD_char.c_out
 JSR LCD_char
 LDA #$3A
 STA $28 ;LCD_char.c_out
 JSR LCD_char
 LDA #$EE
 STA $22 ;DrawHex.source
 LDA #$0
 STA $23 ;DrawHex.source
 JSR DrawHex
 BRK
 BRK
 RTS


EEPROM set *

	OUTRADIX 10

AddCommas MACRO num
comma_ret set "\{num}"
	IF num<1000
		EXITM
	ELSE
comma_ret set "\{substr(comma_ret,0,strlen(comma_ret)-3)},\{substr(comma_ret,strlen(comma_ret)-3,strlen(comma_ret))}"
	ENDIF
	ENDM

;Display memory usage in console
;===============================
	MESSAGE " "
	MESSAGE "Memory usage"
	MESSAGE "============"
	AddCommas EEPROM-$900
	MESSAGE "ROM size:	\{comma_ret} bytes (\{100*(EEPROM-$900)/$1700}%) of 5.75k bank"
	;AddCommas GENRAM-$200
	;MESSAGE "RAM size:	\{comma_ret} bytes (\{100*(GENRAM-$200)/($4000-$200)}%) of 15.8k bank"
	;Tell script that prints assembler output to stop outputting
	;Eliminates double output (because of multiple passes???)
	MESSAGE "END"