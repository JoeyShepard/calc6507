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
SCREEN_WIDTH = 256
SCREEN_HEIGHT = 128
CHAR_WIDTH = 16
CHAR_HEIGHT = 16
CHAR_SCREEN_WIDTH = 16
CHAR_SCREEN_HEIGHT = 16


OBJ_FLOAT = 1
OBJ_STR = 2
OBJ_HEX = 3


BUFF_SIZE = 64
WORD_MAX_SIZE = 18
INPUT_Y = (SCREEN_ADDRESS / 256)+CHAR_HEIGHT*6+12


KEY_BACKSPACE = 8
KEY_ENTER = 13
KEY_ESCAPE = 27


MODE_NONE = 0
MODE_STRING = 1


ERROR_NONE = 0
ERROR_WORD_TOO_LONG = 1
%line 21+1 main.asm






 PAGE 0

DEBUG_MODE set "off"


%line 1+1 macros.asm


false set 0
true set $FF





%line 15+1 macros.asm

%line 21+1 macros.asm

%line 27+1 macros.asm




%line 32+1 main.asm

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

%line 33+1 main.asm




 ORG $1FFC
 FDB main




 ORG $0000


LOCALS_BEGIN set $0
LOCALS_END set $1F

 ORG $20

 dummy:
%line 51+0 main.asm
 DFS 1
%line 52+1 main.asm
 ret_val:
%line 52+0 main.asm
 DFS 2
%line 53+1 main.asm

 screen_ptr:
%line 54+0 main.asm
 DFS 2
%line 55+1 main.asm

 R0: DFS 9
 R1: DFS 9
 R2: DFS 9
 R3: DFS 9
 R4: DFS 9
 R5: DFS 9
 R6: DFS 9
 R7: DFS 9

STACK_END:




 ORG $130

%line 1+1 globals.asm


 global_error: DFS 1


 input_buff_begin: DFS 1
 input_buff_end: DFS 1
 input_buff: DFS BUFF_SIZE


 new_word_len: DFS 1
 new_word_buff: DFS WORD_MAX_SIZE


%line 72+1 main.asm





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


 FCB $c0, $60, $30, $18, $c, $6, $2, $0


 FCB $78, $18, $18, $18, $18, $18, $78, $0


 FCB $10, $38, $6c, $c6, $0, $0, $0, $0


 FCB $0, $0, $0, $0, $0, $0, $0, $ff


 FCB $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff





CHAR_ARROW = 'a'




 FCB $8, $18, $38, $78, $38, $18, $8, $0

 FCB $8, $18, $38, $78, $38, $18, $8, $0

 FCB $8, $18, $38, $78, $38, $18, $8, $0

 FCB $8, $18, $38, $78, $38, $18, $8, $0


 FCB $0, $0, $EE, $88, $EE, $88, $EE, $0





%line 82+1 main.asm



%line 1+1 emu6507.asm



 BG_COLOR = $2A
 FG_COLOR = $0

 setup:
 SEI
 CLD


 LDX #0



%line 15+0 emu6507.asm













 LDA #(BANK_GFX_RAM1) % 256
 STA RAM_BANK2

%line 16+1 emu6507.asm

%line 16+0 emu6507.asm













 LDA #(BANK_GFX_RAM2) % 256
 STA RAM_BANK3

%line 17+1 emu6507.asm





%line 21+0 emu6507.asm




 JSR DrawStack
%line 22+1 emu6507.asm
 RTS

 LCD_clrscr:

 counter set ASSIGN_LOCAL_BYTE



%line 29+0 emu6507.asm























 LDA #(SCREEN_ADDRESS) % 256
 STA screen_ptr
 LDA #(SCREEN_ADDRESS) / 256
 STA screen_ptr+1

%line 30+1 emu6507.asm


%line 31+0 emu6507.asm
















 LDA #(128) % 256
 STA counter

%line 32+1 emu6507.asm
 LDA #BG_COLOR
 LDY #0
 .loop:
 STA (screen_ptr),Y
 INY
 BNE .loop
 INC screen_ptr+1
 DEC counter
 BNE .loop

%line 41+0 emu6507.asm























 LDA #(SCREEN_ADDRESS) % 256
 STA screen_ptr
 LDA #(SCREEN_ADDRESS) / 256
 STA screen_ptr+1

%line 42+1 emu6507.asm
 RTS

 LCD_char:

 c_out set ASSIGN_LOCAL_BYTE
%line 46+0 emu6507.asm
 LCD_char.a0 set LCD_char.c_out
%line 47+1 emu6507.asm

 pixel_ptr set ASSIGN_LOCAL_WORD
 pixel_index set ASSIGN_LOCAL_BYTE
 pixel set ASSIGN_LOCAL_BYTE
 lc1 set ASSIGN_LOCAL_BYTE
%line 51+0 emu6507.asm
 lc2 set ASSIGN_LOCAL_BYTE
%line 52+1 emu6507.asm


 LDA c_out
 CMP #' '
 BCC ..@92.skip
%line 56+0 emu6507.asm
 JMP .if0
 ..@92.skip:
%line 57+1 emu6507.asm
 RTS
 .if0:

 CMP #'e'+1
 BCS ..@97.skip
%line 61+0 emu6507.asm
 JMP .if1
 ..@97.skip:
%line 62+1 emu6507.asm
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
 LDA #FG_COLOR
 BCS .color
 LDA #BG_COLOR
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
%line 136+0 emu6507.asm
 LCD_print.a0 set LCD_print.source
%line 137+1 emu6507.asm

 index set ASSIGN_LOCAL_BYTE
%line 138+0 emu6507.asm
 arg set ASSIGN_LOCAL_BYTE
%line 139+1 emu6507.asm


 LDA #0
 STA index
 .loop:
 LDY index
 LDA (source),Y
 BEQ .done
 STA arg

%line 148+0 emu6507.asm











































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 149+1 emu6507.asm
 INC index
 JMP .loop
 .done:
 RTS

%line 85+1 main.asm


%line 1+1 math.asm



 BCD_Reverse:

 source set ASSIGN_LOCAL_WORD
%line 6+0 math.asm
 BCD_Reverse.a0 set BCD_Reverse.source
%line 7+1 math.asm
 count set ASSIGN_LOCAL_BYTE
%line 7+0 math.asm
 BCD_Reverse.a1 set BCD_Reverse.count
%line 8+1 math.asm


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


%line 87+1 main.asm

%line 1+1 output.asm



 DigitHigh:

 digit set ASSIGN_LOCAL_BYTE
%line 6+0 output.asm
 DigitHigh.a0 set DigitHigh.digit
%line 7+1 output.asm


 LDA digit
 LSR
 LSR
 LSR
 LSR
 CLC
 ADC #'0'
 STA digit

%line 17+0 output.asm































 LDA digit
 STA LCD_char.a0









 JSR LCD_char
%line 18+1 output.asm
 RTS

 DigitLow:

 digit set ASSIGN_LOCAL_BYTE
%line 22+0 output.asm
 DigitLow.a0 set DigitLow.digit
%line 23+1 output.asm


 LDA digit
 AND #$F
 CLC
 ADC #'0'
 STA digit

%line 30+0 output.asm































 LDA digit
 STA LCD_char.a0









 JSR LCD_char
%line 31+1 output.asm
 RTS

 DrawFloat:

 source set ASSIGN_LOCAL_WORD
%line 35+0 output.asm
 DrawFloat.a0 set DrawFloat.source
%line 36+1 output.asm

 index set ASSIGN_LOCAL_BYTE
%line 37+0 output.asm
 arg set ASSIGN_LOCAL_BYTE
 sign set ASSIGN_LOCAL_BYTE
%line 38+1 output.asm
 buff set ASSIGN_LOCAL_WORD



%line 41+0 output.asm









 JSR MemCopy
%line 42+1 output.asm

 LDA #' '
 STA sign
 LDY #6
 LDA (source),Y
 CMP #$50
 BCC .positive
 LDA #'-'
 STA sign

%line 51+0 output.asm






























































 LDA #(R0+1) % 256
 STA BCD_Reverse.a0
 LDA #(R0+1) / 256
 STA BCD_Reverse.a0+1














































 LDA #(6) % 256
 STA BCD_Reverse.a1









 JSR BCD_Reverse
%line 52+1 output.asm
 .positive:

%line 53+0 output.asm























































 LDA sign
 STA LCD_char.a0









 JSR LCD_char
%line 54+1 output.asm

 LDY #6
 LDA R0,Y
 STA arg

%line 58+0 output.asm





























































 LDA arg
 STA DigitHigh.a0









 JSR DigitHigh
%line 59+1 output.asm


%line 60+0 output.asm


























































 LDA #('.') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 61+1 output.asm

%line 61+0 output.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 62+1 output.asm
 LDA #5
 STA index
 .loop:
 LDY index
 LDA R0,Y
 STA arg

%line 68+0 output.asm





























































 LDA arg
 STA DigitHigh.a0









 JSR DigitHigh
%line 69+1 output.asm

%line 69+0 output.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 70+1 output.asm
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

%line 82+0 output.asm






























































 LDA #(R0+7) % 256
 STA BCD_Reverse.a0
 LDA #(R0+7) / 256
 STA BCD_Reverse.a0+1














































 LDA #(2) % 256
 STA BCD_Reverse.a1









 JSR BCD_Reverse
%line 83+1 output.asm
 .positive_e:

%line 84+0 output.asm























































 LDA sign
 STA LCD_char.a0









 JSR LCD_char
%line 85+1 output.asm
 LDY #8
 LDA R0,Y
 STA arg

%line 88+0 output.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 89+1 output.asm
 LDY #7
 LDA R0,Y
 STA arg

%line 92+0 output.asm





























































 LDA arg
 STA DigitHigh.a0









 JSR DigitHigh
%line 93+1 output.asm

%line 93+0 output.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 94+1 output.asm

 RTS

 HexHigh:

 digit set ASSIGN_LOCAL_BYTE
%line 99+0 output.asm
 HexHigh.a0 set HexHigh.digit
%line 100+1 output.asm

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

%line 120+0 output.asm





































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 121+1 output.asm
 RTS

 HexLow:

 digit set ASSIGN_LOCAL_BYTE
%line 125+0 output.asm
 HexLow.a0 set HexLow.digit
%line 126+1 output.asm

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

%line 143+0 output.asm





































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 144+1 output.asm
 RTS

 DrawHex:

 source set ASSIGN_LOCAL_WORD
%line 148+0 output.asm
 DrawHex.a0 set DrawHex.source
%line 149+1 output.asm

 arg set ASSIGN_LOCAL_BYTE



%line 153+0 output.asm















 JMP ..@638.str_skip
 ..@638.str_addr:
 FCB "$",0
 ..@638.str_skip:






























 LDA #(..@638.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@638.str_addr) / 256
 STA LCD_print.a0+1










 JSR LCD_print
%line 154+1 output.asm

 LDY #8
 LDA (source),Y
 STA arg

%line 158+0 output.asm





































 LDA arg
 STA HexHigh.a0









 JSR HexHigh
%line 159+1 output.asm

%line 159+0 output.asm





































 LDA arg
 STA HexLow.a0









 JSR HexLow
%line 160+1 output.asm
 LDY #7
 LDA (source),Y
 STA arg

%line 163+0 output.asm





































 LDA arg
 STA HexHigh.a0









 JSR HexHigh
%line 164+1 output.asm

%line 164+0 output.asm





































 LDA arg
 STA HexLow.a0









 JSR HexLow
%line 165+1 output.asm
 RTS

 DrawStack:

 counter set ASSIGN_LOCAL_BYTE
 character set ASSIGN_LOCAL_BYTE



%line 173+0 output.asm









 JSR LCD_clrscr
%line 174+1 output.asm


%line 175+0 output.asm















 JMP ..@760.str_skip
 ..@760.str_addr:
 FCB "RAD",0
 ..@760.str_skip:






























 LDA #(..@760.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@760.str_addr) / 256
 STA LCD_print.a0+1










 JSR LCD_print
%line 176+1 output.asm


%line 177+0 output.asm
















 LDA #('5') % 256
 STA character

%line 178+1 output.asm

%line 178+0 output.asm






















 LDA #(211) % 256
 STA counter

%line 179+1 output.asm
 .loop:
 LDA #0
 STA screen_ptr
 LDA screen_ptr+1
 CLC
 ADC #CHAR_HEIGHT
 STA screen_ptr+1

%line 186+0 output.asm





































 LDA character
 STA LCD_char.a0









 JSR LCD_char
%line 187+1 output.asm

%line 187+0 output.asm








































 LDA #(':') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 188+1 output.asm
 DEC character
 LDA counter
 CLC
 ADC #9
 STA counter
 BNE .loop
 LDA #0
 STA screen_ptr
 LDA screen_ptr+1
 CLC
 ADC #20
 STA screen_ptr+1

 LDY #0
 LDA #FG_COLOR
 .loop_line:
 STA (screen_ptr),Y
 INC screen_ptr+1
 STA (screen_ptr),Y
 DEC screen_ptr+1
 INY
 BNE .loop_line
 RTS

%line 88+1 main.asm

%line 1+1 forth.asm


 InitForth:
 LDA #0
 STA input_buff_begin
 STA input_buff_end
 STA new_word_len
 RTS


 LineWord:

 mode set ASSIGN_LOCAL_BYTE


 LDA #0
 STA new_word_len

 LDY input_buff_begin
 CPY input_buff_end
 BNE .chars_left

 RTS
 .chars_left:

 LDA #MODE_NONE
 STA mode

 .loop:
 LDY input_buff_begin
 LDA input_buff,Y
 INC input_buff_begin
 CMP #' '
 BNE .not_space
 LDA new_word_len
 BEQ .chars_left2

 RTS
 .not_space:
 LDY new_word_len
 STA new_word_buff,Y
 INY
 STY new_word_len
 CPY #WORD_MAX_SIZE
 BNE .word_size_good

 LDA #ERROR_WORD_TOO_LONG
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

%line 89+1 main.asm





 MemCopy:

 source set ASSIGN_LOCAL_WORD
%line 96+0 main.asm
 MemCopy.a0 set MemCopy.source
 dest set ASSIGN_LOCAL_WORD
 MemCopy.a1 set MemCopy.dest
%line 97+1 main.asm
 count set ASSIGN_LOCAL_BYTE
%line 97+0 main.asm
 MemCopy.a2 set MemCopy.count
%line 98+1 main.asm


 LDY #0
 .loop:
 LDA (source),Y
 STA (dest),Y
 INY
 CPY count
 BNE .loop
 RTS

 special_chars:
 FCB " e."


 ReadLine:

 cursor set ASSIGN_LOCAL_BYTE
%line 115+0 main.asm
 cursor_timer set ASSIGN_LOCAL_BYTE
%line 116+1 main.asm
 arg set ASSIGN_LOCAL_BYTE
 index set ASSIGN_LOCAL_BYTE
%line 117+0 main.asm
 str_index set ASSIGN_LOCAL_BYTE
%line 118+1 main.asm


 LDA #0
 STA cursor
 STA index
 STA screen_ptr
 LDA #INPUT_Y
 STA screen_ptr+1

%line 126+0 main.asm















 JMP ..@884.str_skip
 ..@884.str_addr:
 FCB "a               ",0
 ..@884.str_skip:
















































 LDA #(..@884.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@884.str_addr) / 256
 STA LCD_print.a0+1










 JSR LCD_print
%line 127+1 main.asm
 LDA TIMER_S
 STA cursor_timer

 .loop:
 LDA #0
 STA arg
 LDA KB_INPUT
 BNE .key_read
 JMP .no_key
 .key_read:


 CMP #KEY_ENTER
 BNE .not_enter
 LDA index
 BEQ .loop
 LDA #0
 STA input_buff_begin
 LDA index
 STA input_buff_end
 RTS
 .not_enter:


 CMP #KEY_BACKSPACE
 BNE .not_backspace
 LDA index
 BEQ .backspace_done
 DEC index
 CMP #CHAR_SCREEN_WIDTH
 BCS .backspace_scroll

%line 158+0 main.asm


























































 LDA #(' ') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 159+1 main.asm
 LDA screen_ptr
 SEC
 SBC #CHAR_WIDTH*2
 STA screen_ptr
 PHA

%line 164+0 main.asm


























































 LDA #(CHAR_ARROW) % 256
 STA LCD_char.a0










 JSR LCD_char
%line 165+1 main.asm
 PLA
 STA screen_ptr
 JMP .draw_done
 .backspace_scroll:
 LDY index
 DEY
 JMP .scroll_buffer

 .backspace_done:
 JMP .no_key
 .not_backspace:


 LDY #0
 .special_loop:
 CMP special_chars,Y
 BNE .special_next
 STA arg
 JMP .key_done
 .special_next:
 INY
 CPY #3
 BNE .special_loop


 CMP #'0'
 BCC .not_num
 CMP #'9'+1
 BCS .not_num
 STA arg
 JMP .key_done
 .not_num:


 CMP #'A'
 BCC .not_upper
 CMP #'Z'+1
 BCS .not_upper
 STA arg
 JMP .key_done
 .not_upper:


 CMP #'a'
 BCC .not_lower
 CMP #'z'+1
 BCS .not_lower

 SEC
 SBC #$20
 STA arg
 .not_lower:

 .key_done:
 LDA arg
 BEQ .not_valid
 LDY index
 CPY #BUFF_SIZE
 BCS .buffer_full
 STA input_buff,Y
 INC index
 CPY #CHAR_SCREEN_WIDTH-1
 BCS .scroll_buffer

%line 228+0 main.asm



































































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 229+1 main.asm
 LDA screen_ptr
 PHA

%line 231+0 main.asm


























































 LDA #(CHAR_ARROW) % 256
 STA LCD_char.a0










 JSR LCD_char
%line 232+1 main.asm
 PLA
 STA screen_ptr
 JMP .draw_done
 .scroll_buffer:
 LDA #0
 STA screen_ptr
 TYA
 SEC
 SBC #CHAR_SCREEN_WIDTH-2
 STA str_index
 .scroll_loop:
 LDY str_index
 INC str_index
 LDA input_buff,Y
 STA arg

%line 247+0 main.asm



































































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 248+1 main.asm
 LDA index
 CMP str_index
 BNE .scroll_loop
 LDA screen_ptr
 PHA

%line 253+0 main.asm


























































 LDA #(CHAR_ARROW) % 256
 STA LCD_char.a0










 JSR LCD_char
%line 254+1 main.asm
 PLA
 STA screen_ptr
 .draw_done:
 .buffer_full:
 .not_valid:

 .no_key:
 LDA TIMER_S
 CMP cursor_timer
 BEQ .cursor_done
 STA cursor_timer
 LDA cursor
 BEQ .draw_blank
 LDA #0
 STA cursor
 LDA #' '
 JMP .draw
 .draw_blank:
 LDA #$FF
 STA cursor
 LDA #CHAR_ARROW
 .draw:
 STA arg

%line 277+0 main.asm



































































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 278+1 main.asm
 LDA screen_ptr
 SEC
 SBC #CHAR_WIDTH
 STA screen_ptr
 .cursor_done:
 JMP .loop
 RTS




 BEGIN_FUNC set main
%line 289+0 main.asm
 main:
%line 291+1 main.asm
 counter set ASSIGN_LOCAL_BYTE





 LDX #$2F
 TXS


%line 300+0 main.asm









 JSR setup
%line 301+1 main.asm


%line 302+0 main.asm









 JSR ReadLine
%line 303+1 main.asm


%line 304+0 main.asm









 JSR LineWord
%line 305+1 main.asm
 BRK
%line 305+0 main.asm
 BRK
%line 306+1 main.asm

%line 306+0 main.asm









 JSR LineWord
%line 307+1 main.asm
 BRK
%line 307+0 main.asm
 BRK
%line 308+1 main.asm

%line 308+0 main.asm









 JSR LineWord
%line 309+1 main.asm
 BRK
%line 309+0 main.asm
 BRK
%line 310+1 main.asm

%line 310+0 main.asm









 JSR LineWord
%line 311+1 main.asm
 BRK
%line 311+0 main.asm
 BRK
%line 312+1 main.asm

%line 312+0 main.asm









 JSR LineWord
%line 313+1 main.asm
 BRK
%line 313+0 main.asm
 BRK
%line 314+1 main.asm

 BRK
%line 315+0 main.asm
 BRK
%line 316+1 main.asm
 RTS


%line 110+1 nasm.asm


