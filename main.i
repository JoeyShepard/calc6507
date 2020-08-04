%line 5+1 nasm.asm

%line 8+1 nasm.asm


%line 78+1 nasm.asm

%line 96+1 nasm.asm

%line 102+1 nasm.asm

%line 107+1 nasm.asm


%line 1+1 main.asm



















%line 1+1 emu.asm




RAM_BANK1 = $FFE0
RAM_BANK2 = $FFE1
RAM_BANK3 = $FFE2
ROM_BANK = $FFE3
KB_INPUT = $FFE4
TIMER_MS4 = $FFE5
TIMER_S = $FFE6
DEBUG = $FFE7
DEBUG_HEX = $FFE8
DEBUG_DEC = $FFE9
DEBUG_DEC16 = $FFEA
DEBUG_TIMING = $FFEB
LOG_ON = $FFEC
LOG_OFF = $FFED
LOG_SEND = $FFEE



BANK_GEN_RAM1 = 0
BANK_GEN_RAM2 = 1
BANK_GEN_RAM3 = 2
BANK_GEN_RAM4 = 3
BANK_GFX_RAM1 = 4
BANK_GFX_RAM2 = 5
BANK_GEN_ROM = 14


RB1 = $0200
RB2 = $4000
RB3 = $8000
ROMB = $C000
%line 20+1 main.asm

%line 1+1 const.asm



SCREEN_ADDRESS = $4000



OBJ_FLOAT = 1
OBJ_STR = 2
OBJ_HEX = 3

%line 21+1 main.asm






 PAGE 0
DEBUG_MODE set "off"


%line 1+1 macros.asm


false set 0
true set $FF





%line 15+1 macros.asm

%line 21+1 macros.asm

%line 27+1 macros.asm

%line 31+1 main.asm

%line 1+1 optimizer_nmos.asm









LOCALS_BEGIN set $00
LOCALS_END set $FF




%line 20+1 optimizer_nmos.asm

%line 40+1 optimizer_nmos.asm

%line 43+1 optimizer_nmos.asm




%line 50+1 optimizer_nmos.asm

%line 60+1 optimizer_nmos.asm

%line 71+1 optimizer_nmos.asm

%line 80+1 optimizer_nmos.asm

%line 109+1 optimizer_nmos.asm

%line 138+1 optimizer_nmos.asm

%line 167+1 optimizer_nmos.asm




%line 248+1 optimizer_nmos.asm

%line 466+1 optimizer_nmos.asm

%line 470+1 optimizer_nmos.asm

%line 474+1 optimizer_nmos.asm

%line 743+1 optimizer_nmos.asm

%line 750+1 optimizer_nmos.asm

%line 757+1 optimizer_nmos.asm

%line 767+1 optimizer_nmos.asm

%line 794+1 optimizer_nmos.asm

%line 819+1 optimizer_nmos.asm

%line 850+1 optimizer_nmos.asm

%line 862+1 optimizer_nmos.asm

%line 895+1 optimizer_nmos.asm

%line 934+1 optimizer_nmos.asm

%line 959+1 optimizer_nmos.asm

%line 988+1 optimizer_nmos.asm

%line 1017+1 optimizer_nmos.asm

%line 1022+1 optimizer_nmos.asm

%line 1027+1 optimizer_nmos.asm

%line 1033+1 optimizer_nmos.asm

%line 1039+1 optimizer_nmos.asm

%line 1045+1 optimizer_nmos.asm

%line 1051+1 optimizer_nmos.asm

%line 1057+1 optimizer_nmos.asm

%line 1063+1 optimizer_nmos.asm

%line 1067+1 optimizer_nmos.asm

%line 1076+1 optimizer_nmos.asm


%line 1081+1 optimizer_nmos.asm

%line 1085+1 optimizer_nmos.asm

%line 1094+1 optimizer_nmos.asm


%line 1099+1 optimizer_nmos.asm

%line 1103+1 optimizer_nmos.asm

%line 1112+1 optimizer_nmos.asm

%line 1116+1 optimizer_nmos.asm

%line 1125+1 optimizer_nmos.asm

%line 1129+1 optimizer_nmos.asm

%line 1138+1 optimizer_nmos.asm

%line 1147+1 optimizer_nmos.asm

%line 1164+1 optimizer_nmos.asm

%line 1174+1 optimizer_nmos.asm

%line 1181+1 optimizer_nmos.asm

%line 1195+1 optimizer_nmos.asm






%line 1207+1 optimizer_nmos.asm

%line 1220+1 optimizer_nmos.asm

%line 1236+1 optimizer_nmos.asm

%line 1267+1 optimizer_nmos.asm


%line 1315+1 optimizer_nmos.asm

























%line 1343+1 optimizer_nmos.asm

%line 32+1 main.asm




 ORG $1FFC
 FDB main


LOCALS_BEGIN set $20
LOCALS_END set $3F




 ORG $0000
 dummy:
%line 47+0 main.asm
 DFS 1
%line 48+1 main.asm
 ret_val:
%line 48+0 main.asm
 DFS 2
%line 49+1 main.asm
 cx:
%line 49+0 main.asm
 DFS 1
 cy:
 DFS 1
%line 50+1 main.asm
 screen_ptr:
%line 50+0 main.asm
 DFS 2
%line 51+1 main.asm

 R0: DFS 9




 ORG $130






 ORG $900
 JMP main


 font_table:
%line 1+1 font_8x8.asm

 FCB $0, $0, $0, $0, $0, $0, $0, $0


 FCB $30, $78, $78, $30, $30, $0, $30, $0


 FCB $6c, $6c, $6c, $0, $0, $0, $0, $0


 FCB $6c, $6c, $fe, $6c, $fe, $6c, $6c, $0


 FCB $30, $7c, $c0, $78, $c, $f8, $30, $0


 FCB $0, $c6, $cc, $18, $30, $66, $c6, $0


 FCB $38, $6c, $38, $76, $dc, $cc, $76, $0


 FCB $60, $60, $c0, $0, $0, $0, $0, $0


 FCB $18, $30, $60, $60, $60, $30, $18, $0


 FCB $60, $30, $18, $18, $18, $30, $60, $0


 FCB $0, $66, $3c, $ff, $3c, $66, $0, $0


 FCB $0, $30, $30, $fc, $30, $30, $0, $0


 FCB $0, $0, $0, $0, $0, $30, $30, $60


 FCB $0, $0, $0, $fc, $0, $0, $0, $0


 FCB $0, $0, $0, $0, $0, $30, $30, $0


 FCB $6, $c, $18, $30, $60, $c0, $80, $0


 FCB $7c, $c6, $ce, $de, $f6, $e6, $7c, $0


 FCB $30, $70, $30, $30, $30, $30, $fc, $0


 FCB $78, $cc, $c, $38, $60, $cc, $fc, $0


 FCB $78, $cc, $c, $38, $c, $cc, $78, $0


 FCB $1c, $3c, $6c, $cc, $fe, $c, $1e, $0


 FCB $fc, $c0, $f8, $c, $c, $cc, $78, $0


 FCB $38, $60, $c0, $f8, $cc, $cc, $78, $0


 FCB $fc, $cc, $c, $18, $30, $30, $30, $0


 FCB $78, $cc, $cc, $78, $cc, $cc, $78, $0


 FCB $78, $cc, $cc, $7c, $c, $18, $70, $0


 FCB $0, $30, $30, $0, $0, $30, $30, $0


 FCB $0, $30, $30, $0, $0, $30, $30, $60


 FCB $18, $30, $60, $c0, $60, $30, $18, $0


 FCB $0, $0, $fc, $0, $0, $fc, $0, $0


 FCB $60, $30, $18, $c, $18, $30, $60, $0


 FCB $78, $cc, $c, $18, $30, $0, $30, $0


 FCB $7c, $c6, $de, $de, $de, $c0, $78, $0


 FCB $30, $78, $cc, $cc, $fc, $cc, $cc, $0


 FCB $fc, $66, $66, $7c, $66, $66, $fc, $0


 FCB $3c, $66, $c0, $c0, $c0, $66, $3c, $0


 FCB $f8, $6c, $66, $66, $66, $6c, $f8, $0


 FCB $fe, $62, $68, $78, $68, $62, $fe, $0


 FCB $fe, $62, $68, $78, $68, $60, $f0, $0


 FCB $3c, $66, $c0, $c0, $ce, $66, $3e, $0


 FCB $cc, $cc, $cc, $fc, $cc, $cc, $cc, $0


 FCB $78, $30, $30, $30, $30, $30, $78, $0


 FCB $1e, $c, $c, $c, $cc, $cc, $78, $0


 FCB $e6, $66, $6c, $78, $6c, $66, $e6, $0


 FCB $f0, $60, $60, $60, $62, $66, $fe, $0


 FCB $c6, $ee, $fe, $fe, $d6, $c6, $c6, $0


 FCB $c6, $e6, $f6, $de, $ce, $c6, $c6, $0


 FCB $38, $6c, $c6, $c6, $c6, $6c, $38, $0


 FCB $fc, $66, $66, $7c, $60, $60, $f0, $0


 FCB $78, $cc, $cc, $cc, $dc, $78, $1c, $0


 FCB $fc, $66, $66, $7c, $6c, $66, $e6, $0


 FCB $78, $cc, $e0, $70, $1c, $cc, $78, $0


 FCB $fc, $b4, $30, $30, $30, $30, $78, $0


 FCB $cc, $cc, $cc, $cc, $cc, $cc, $fc, $0


 FCB $cc, $cc, $cc, $cc, $cc, $78, $30, $0


 FCB $c6, $c6, $c6, $d6, $fe, $ee, $c6, $0


 FCB $c6, $c6, $6c, $38, $38, $6c, $c6, $0


 FCB $cc, $cc, $cc, $78, $30, $30, $78, $0


 FCB $fe, $c6, $8c, $18, $32, $66, $fe, $0


 FCB $78, $60, $60, $60, $60, $60, $78, $0





 FCB $78, $18, $18, $18, $18, $18, $78, $0


 FCB $10, $38, $6c, $c6, $0, $0, $0, $0


 FCB $0, $0, $0, $0, $0, $0, $0, $ff

%line 69+1 main.asm



%line 1+1 emu6507.asm


 setup:
 SEI
 CLD


 LDX #0



%line 11+0 emu6507.asm













 LDA #(BANK_GFX_RAM1) % 256
 STA RAM_BANK2

%line 12+1 emu6507.asm


%line 13+0 emu6507.asm

















 LDA #(SCREEN_ADDRESS) % 256
 STA screen_ptr
 LDA #(SCREEN_ADDRESS) / 256
 STA screen_ptr+1

%line 14+1 emu6507.asm
 RTS

 LCD_char:

 c_out set ASSIGN_LOCAL_BYTE
%line 18+0 emu6507.asm
 LCD_char.a0 set LCD_char.c_out
%line 19+1 emu6507.asm

 pixel_ptr set ASSIGN_LOCAL_WORD
 pixel_index set ASSIGN_LOCAL_BYTE
 pixel set ASSIGN_LOCAL_BYTE
 lc1 set ASSIGN_LOCAL_BYTE
%line 23+0 emu6507.asm
 lc2 set ASSIGN_LOCAL_BYTE
%line 24+1 emu6507.asm


 LDA c_out
 CMP #' '
 BCC ..@51.skip
%line 28+0 emu6507.asm
 JMP .if0
 ..@51.skip:
%line 29+1 emu6507.asm
 RTS
 .if0:

 CMP #'`'
 BCS ..@56.skip
%line 33+0 emu6507.asm
 JMP .if1
 ..@56.skip:
%line 34+1 emu6507.asm
 RTS
 .if1:

 SEC
 SBC #32
 STA pixel_ptr
 LDA #0
 STA pixel_ptr+1

 ASL pixel_ptr

 ASL pixel_ptr
 ROL pixel_ptr+1
 ASL pixel_ptr
 ROL pixel_ptr+1

 LDA #font_table % 256
 ADC pixel_ptr
 STA pixel_ptr
 LDA #font_table / 256
 ADC pixel_ptr+1
 STA pixel_ptr+1

 LDA #0
 STA pixel_index
 LDA #8
 STA lc1
 .loop:
 LDA #8
 STA lc2
 LDY pixel_index
 INC pixel_index
 LDA (pixel_ptr),Y
 STA pixel
 LDY #0
 .loop.inner:
 ROL pixel
 LDA #$3F
 BCS .color
 LDA #0
 .color:



 STA (screen_ptr),Y
 INC screen_ptr+1
 STA (screen_ptr),Y
 INY


 STA (screen_ptr),Y
 DEC screen_ptr+1
 STA (screen_ptr),Y
 INY
 DEC lc2
 BNE .loop.inner

 INC screen_ptr+1
 INC screen_ptr+1
 DEC lc1
 BNE .loop
 CLC
 LDA screen_ptr
 ADC #16
 STA screen_ptr
 SEC
 LDA screen_ptr+1

 SBC #16
 STA screen_ptr+1
 RTS

 LCD_print:

 source set ASSIGN_LOCAL_WORD
%line 108+0 emu6507.asm
 LCD_print.a0 set LCD_print.source
%line 109+1 emu6507.asm

 index set ASSIGN_LOCAL_BYTE
%line 110+0 emu6507.asm
 arg set ASSIGN_LOCAL_BYTE
%line 111+1 emu6507.asm


 LDA #0
 STA index
 .loop:
 LDY index
 LDA (source),Y
 BEQ .done
 STA arg

%line 120+0 emu6507.asm











































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 121+1 emu6507.asm
 INC index
 JMP .loop
 .done:
 RTS

%line 72+1 main.asm





 MemCopy:

 source set ASSIGN_LOCAL_WORD
%line 79+0 main.asm
 MemCopy.a0 set MemCopy.source
 dest set ASSIGN_LOCAL_WORD
 MemCopy.a1 set MemCopy.dest
%line 80+1 main.asm
 count set ASSIGN_LOCAL_BYTE
%line 80+0 main.asm
 MemCopy.a2 set MemCopy.count
%line 81+1 main.asm


 LDY #0
 .loop:
 LDA (source),Y
 STA (dest),Y
 INY
 CPY count
 BNE .loop
 RTS

 DigitHigh:

 digit set ASSIGN_LOCAL_BYTE
%line 94+0 main.asm
 DigitHigh.a0 set DigitHigh.digit
%line 95+1 main.asm


 LDA digit
 LSR
 LSR
 LSR
 LSR
 CLC
 ADC #'0'
 STA digit

%line 105+0 main.asm































 LDA digit
 STA LCD_char.a0









 JSR LCD_char
%line 106+1 main.asm
 RTS

 DigitLow:

 digit set ASSIGN_LOCAL_BYTE
%line 110+0 main.asm
 DigitLow.a0 set DigitLow.digit
%line 111+1 main.asm


 LDA digit
 AND #$F
 CLC
 ADC #'0'
 STA digit

%line 118+0 main.asm































 LDA digit
 STA LCD_char.a0









 JSR LCD_char
%line 119+1 main.asm
 RTS

 DrawFloat:

 source set ASSIGN_LOCAL_WORD
%line 123+0 main.asm
 DrawFloat.a0 set DrawFloat.source
%line 124+1 main.asm

 index set ASSIGN_LOCAL_BYTE
%line 125+0 main.asm
 arg set ASSIGN_LOCAL_BYTE
 sign set ASSIGN_LOCAL_BYTE
%line 126+1 main.asm
 buff set ASSIGN_LOCAL_WORD



%line 129+0 main.asm
















































































 LDA source
 STA MemCopy.a0
 LDA source+1
 STA MemCopy.a0+1

















































 LDA #(R0) % 256
 STA MemCopy.a1
 LDA #(R0) / 256
 STA MemCopy.a1+1














































 LDA #(9) % 256
 STA MemCopy.a2








 JSR MemCopy
%line 130+1 main.asm

 LDA #' '
 STA sign
 LDY #6
 LDA (source),Y
 CMP #$50
 BCC .positive
 LDA #'-'
 STA sign

%line 139+0 main.asm









 JSR BCD_Reverse
%line 140+1 main.asm
 .positive:

%line 141+0 main.asm























































 LDA sign
 STA LCD_char.a0









 JSR LCD_char
%line 142+1 main.asm

 LDY #6
 LDA R0,Y
 STA arg

%line 146+0 main.asm





























































 LDA arg
 STA DigitHigh.a0









 JSR DigitHigh
%line 147+1 main.asm

%line 147+0 main.asm


























































 LDA #('.') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 148+1 main.asm

%line 148+0 main.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 149+1 main.asm
 LDA #5
 STA index
 .loop:
 LDY index
 LDA R0,Y
 STA arg

%line 155+0 main.asm





























































 LDA arg
 STA DigitHigh.a0









 JSR DigitHigh
%line 156+1 main.asm

%line 156+0 main.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 157+1 main.asm
 DEC index
 LDA index
 CMP #2
 BNE .loop
 LDA #'+'
 STA sign
 LDY #8
 LDA (source),Y
 CMP #$50
 BCC .positive_e
 LDA #'-'
 STA sign

%line 169+0 main.asm









 JSR BCD_Reverse
%line 170+1 main.asm
 .positive_e:

%line 171+0 main.asm























































 LDA sign
 STA LCD_char.a0









 JSR LCD_char
%line 172+1 main.asm
 LDY #8
 LDA R0,Y
 STA arg

%line 175+0 main.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 176+1 main.asm
 LDY #7
 LDA R0,Y
 STA arg

%line 179+0 main.asm





























































 LDA arg
 STA DigitHigh.a0









 JSR DigitHigh
%line 180+1 main.asm

%line 180+0 main.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 181+1 main.asm

 RTS

 HexHigh:

 digit set ASSIGN_LOCAL_BYTE
%line 186+0 main.asm
 HexHigh.a0 set HexHigh.digit
%line 187+1 main.asm

 arg set ASSIGN_LOCAL_BYTE


 LDA digit
 LSR
 LSR
 LSR
 LSR
 CMP #$A
 BCC .print_digit
 CLC
 ADC #'A'-10
 STA arg
 JMP .done
 .print_digit:
 CLC
 ADC #'0'
 STA arg
 .done:

%line 207+0 main.asm





































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 208+1 main.asm
 RTS

 HexLow:

 digit set ASSIGN_LOCAL_BYTE
%line 212+0 main.asm
 HexLow.a0 set HexLow.digit
%line 213+1 main.asm

 arg set ASSIGN_LOCAL_BYTE


 LDA digit
 AND #$F
 CMP #$A
 BCC .print_digit
 CLC
 ADC #'A'-10
 STA arg
 JMP .done
 .print_digit:
 CLC
 ADC #'0'
 STA arg
 .done:

%line 230+0 main.asm





































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 231+1 main.asm
 RTS

 DrawHex:

 source set ASSIGN_LOCAL_WORD
%line 235+0 main.asm
 DrawHex.a0 set DrawHex.source
%line 236+1 main.asm

 arg set ASSIGN_LOCAL_BYTE



%line 240+0 main.asm















 JMP ..@578.str_skip
 ..@578.str_addr:
 FCB "         $",0
 ..@578.str_skip:






























 LDA #(..@578.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@578.str_addr) / 256
 STA LCD_print.a0+1










 JSR LCD_print
%line 241+1 main.asm

 BRK
 BRK

 LDY #8
 LDA (source),Y
 STA arg

%line 248+0 main.asm





































 LDA arg
 STA HexHigh.a0









 JSR HexHigh
%line 249+1 main.asm

%line 249+0 main.asm





































 LDA arg
 STA HexLow.a0









 JSR HexLow
%line 250+1 main.asm
 LDY #7
 LDA (source),Y
 STA arg

%line 253+0 main.asm





































 LDA arg
 STA HexHigh.a0









 JSR HexHigh
%line 254+1 main.asm

%line 254+0 main.asm





































 LDA arg
 STA HexLow.a0









 JSR HexLow
%line 255+1 main.asm
 RTS




 BCD_Reverse:

 source set ASSIGN_LOCAL_WORD
%line 262+0 main.asm
 BCD_Reverse.a0 set BCD_Reverse.source
%line 263+1 main.asm
 count set ASSIGN_LOCAL_BYTE
%line 263+0 main.asm
 BCD_Reverse.a1 set BCD_Reverse.count
%line 264+1 main.asm


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
 RTS







 test_val1:
 FCB OBJ_FLOAT, $12, $90, $78, $56, $34, $12, $1, $00
 test_val2:
 FCB OBJ_FLOAT, $23, $01, $89, $67, $45, $23, $03, $00
 test_val3:
 FCB OBJ_HEX, $00, $00, $00, $00, $00, $00, $DE, $BC




 BEGIN_FUNC set main
%line 295+0 main.asm
 main:
%line 296+1 main.asm



 LDX #$2F
 TXS


%line 302+0 main.asm









 JSR setup
%line 303+1 main.asm


%line 304+0 main.asm















 JMP ..@705.str_skip
 ..@705.str_addr:
 FCB "RAD",0
 ..@705.str_skip:


















 LDA #(..@705.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@705.str_addr) / 256
 STA LCD_print.a0+1










 JSR LCD_print
%line 305+1 main.asm

 LDA #((SCREEN_ADDRESS / 256)+16)
 STA screen_ptr+1
 LDA #0
 STA screen_ptr


%line 311+0 main.asm
































 LDA #(test_val1) % 256
 STA MemCopy.a0
 LDA #(test_val1) / 256
 STA MemCopy.a0+1




















 LDA #(247) % 256
 STA MemCopy.a1
 LDA #(247) / 256
 STA MemCopy.a1+1
















 LDA #(9) % 256
 STA MemCopy.a2








 JSR MemCopy
%line 312+1 main.asm
 LDX #247


%line 314+0 main.asm




























 LDA #('5') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 315+1 main.asm

%line 315+0 main.asm




























 LDA #(':') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 316+1 main.asm

%line 316+0 main.asm
































 LDA #(247) % 256
 STA DrawFloat.a0
 LDA #(247) / 256
 STA DrawFloat.a0+1










 JSR DrawFloat
%line 317+1 main.asm

 LDA screen_ptr+1
 CLC
 ADC #16
 STA screen_ptr+1


%line 323+0 main.asm
































 LDA #(test_val3) % 256
 STA MemCopy.a0
 LDA #(test_val3) / 256
 STA MemCopy.a0+1




















 LDA #(238) % 256
 STA MemCopy.a1
 LDA #(238) / 256
 STA MemCopy.a1+1
















 LDA #(9) % 256
 STA MemCopy.a2








 JSR MemCopy
%line 324+1 main.asm
 LDX #238


%line 326+0 main.asm




























 LDA #('4') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 327+1 main.asm

%line 327+0 main.asm




























 LDA #(':') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 328+1 main.asm

%line 328+0 main.asm
































 LDA #(238) % 256
 STA DrawHex.a0
 LDA #(238) / 256
 STA DrawHex.a0+1










 JSR DrawHex
%line 329+1 main.asm


 BRK
 BRK
 RTS


%line 110+1 nasm.asm


