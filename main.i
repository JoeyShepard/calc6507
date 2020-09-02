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
%line 22+1 main.asm

%line 1+1 const.asm



SCREEN_ADDRESS = $4000
SCREEN_WIDTH = 256
SCREEN_HEIGHT = 128
CHAR_WIDTH = 16
CHAR_HEIGHT = 16
CHAR_SCREEN_WIDTH = 16
CHAR_SCREEN_HEIGHT = 16


CHAR_ARROW = 'a'
CHAR_BOX = 'b'
CHAR_MINUS = 'c'
CHAR_EXP = 'e'
CHAR_QUOTE = 34


OBJ_FLOAT = 1
OBJ_STR = 2
OBJ_HEX = 3
OBJ_ERROR = 4

OBJ_SIZE = 9


BUFF_SIZE = 64
WORD_MAX_SIZE = 19
MAX_DIGITS = 12


KEY_BACKSPACE = 8
KEY_ENTER = 13
KEY_ESCAPE = 27


ERROR_NONE = 0
ERROR_WORD_TOO_LONG = 2

ERROR_STRING = 4


ERROR_STACK_OVERFLOW = 6
ERROR_STACK_UNDERFLOW = 8

ERROR_INPUT = 10





 MIN_1 = 1
 MIN_2 = 2
 MIN_3 = 3
 ADD_1 = 4

 STACK_SIZE = 8
%line 23+1 main.asm






 PAGE 0

DEBUG_MODE set "off"


%line 1+1 macros.asm


false set 0
true set $FF





%line 15+1 macros.asm

%line 21+1 macros.asm

%line 27+1 macros.asm




%line 34+1 main.asm

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

%line 35+1 main.asm




 ORG $1FFC
 FDB main




 ORG $0000


LOCALS_BEGIN set $0
LOCALS_END set $1F

 ORG $20

 dummy:
%line 53+0 main.asm
 DFS 1
%line 54+1 main.asm
 ret_val:
%line 54+0 main.asm
 DFS 2
%line 55+1 main.asm


 screen_ptr:
%line 57+0 main.asm
 DFS 2
%line 58+1 main.asm

 R0: DFS OBJ_SIZE
 R1: DFS OBJ_SIZE
 R2: DFS OBJ_SIZE
 R3: DFS OBJ_SIZE
 R4: DFS OBJ_SIZE
 R5: DFS OBJ_SIZE
 R6: DFS OBJ_SIZE
 R7: DFS OBJ_SIZE

STACK_END:




 ORG $130

%line 1+1 globals.asm


 global_error: DFS 1


 input_buff_begin: DFS 1
 input_buff_end: DFS 1
 input_buff: DFS BUFF_SIZE


 new_word_len: DFS 1
 new_word_buff: DFS WORD_MAX_SIZE
 new_stack_item: DFS 9


 font_inverted:
%line 16+0 globals.asm
 DFS 1
%line 17+1 globals.asm


 stack_count:
%line 19+0 globals.asm
 DFS 1
%line 20+1 globals.asm



%line 75+1 main.asm





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








 FCB $8, $18, $38, $78, $38, $18, $8, $0


 FCB $00, $00, $00, $00, $FF, $FF, $FF, $FF


 FCB $00, $1E, $00, $00, $00, $00, $00, $00

 FCB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF


 FCB $0, $0, $EE, $88, $EE, $88, $EE, $0





%line 85+1 main.asm



%line 1+1 emu6507.asm



 BG_COLOR = $2A
 FG_COLOR = $0


 INPUT_Y = (SCREEN_ADDRESS / 256)+CHAR_HEIGHT*6+12
 ERROR_X = 2*8*2
 ERROR_Y = (SCREEN_ADDRESS / 256)+CHAR_HEIGHT*2


 setup:
 SEI
 CLD


 LDX #0
 STX stack_count

 LDA #0
 STA font_inverted



%line 25+0 emu6507.asm













 LDA #(BANK_GFX_RAM1) % 256
 STA RAM_BANK2

%line 26+1 emu6507.asm

%line 26+0 emu6507.asm













 LDA #(BANK_GFX_RAM2) % 256
 STA RAM_BANK3

%line 27+1 emu6507.asm

 RTS

 ReadKey:
 LDA KB_INPUT
 RTS

 LCD_clrscr:

 counter set ASSIGN_LOCAL_BYTE



%line 39+0 emu6507.asm























 LDA #(SCREEN_ADDRESS) % 256
 STA screen_ptr
 LDA #(SCREEN_ADDRESS) / 256
 STA screen_ptr+1

%line 40+1 emu6507.asm


%line 41+0 emu6507.asm
















 LDA #(128) % 256
 STA counter

%line 42+1 emu6507.asm
 LDA #BG_COLOR
 LDY #0
 .loop:
 STA (screen_ptr),Y
 INY
 BNE .loop
 INC screen_ptr+1
 DEC counter
 BNE .loop

%line 51+0 emu6507.asm























 LDA #(SCREEN_ADDRESS) % 256
 STA screen_ptr
 LDA #(SCREEN_ADDRESS) / 256
 STA screen_ptr+1

%line 52+1 emu6507.asm
 RTS

 LCD_char:

 c_out set ASSIGN_LOCAL_BYTE
%line 56+0 emu6507.asm
 LCD_char.a0 set LCD_char.c_out
%line 57+1 emu6507.asm

 pixel_ptr set ASSIGN_LOCAL_WORD
 pixel_index set ASSIGN_LOCAL_BYTE
 pixel set ASSIGN_LOCAL_BYTE
 lc1 set ASSIGN_LOCAL_BYTE
%line 61+0 emu6507.asm
 lc2 set ASSIGN_LOCAL_BYTE
%line 62+1 emu6507.asm


 LDA c_out
 CMP #' '
 BCC ..@98.skip
%line 66+0 emu6507.asm
 JMP .if0
 ..@98.skip:
%line 67+1 emu6507.asm
 RTS
 .if0:

 CMP #'e'+1
 BCS ..@103.skip
%line 71+0 emu6507.asm
 JMP .if1
 ..@103.skip:
%line 72+1 emu6507.asm
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
 EOR font_inverted
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
%line 147+0 emu6507.asm
 LCD_print.a0 set LCD_print.source
%line 148+1 emu6507.asm

 index set ASSIGN_LOCAL_BYTE
%line 149+0 emu6507.asm
 arg set ASSIGN_LOCAL_BYTE
%line 150+1 emu6507.asm


 LDA #0
 STA index
 .loop:
 LDY index
 LDA (source),Y
 BEQ .done
 STA arg

%line 159+0 emu6507.asm











































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 160+1 emu6507.asm
 INC index
 JMP .loop
 .done:
 RTS

%line 88+1 main.asm


%line 1+1 system.asm


 MemCopy:

 source set ASSIGN_LOCAL_WORD
%line 5+0 system.asm
 MemCopy.a0 set MemCopy.source
 dest set ASSIGN_LOCAL_WORD
 MemCopy.a1 set MemCopy.dest
%line 6+1 system.asm
 count set ASSIGN_LOCAL_BYTE
%line 6+0 system.asm
 MemCopy.a2 set MemCopy.count
%line 7+1 system.asm


 LDY #0
 .loop:
 LDA (source),Y
 STA (dest),Y
 INY
 CPY count
 BNE .loop
 RTS

%line 90+1 main.asm

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
 DEC count
 BNE .loop
 CLD
 RTS


%line 91+1 main.asm

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


%line 54+0 output.asm























































 LDA sign
 STA LCD_char.a0









 JSR LCD_char
%line 55+1 output.asm

 LDY #6
 LDA R0,Y
 STA arg

%line 59+0 output.asm





























































 LDA arg
 STA DigitHigh.a0









 JSR DigitHigh
%line 60+1 output.asm


%line 61+0 output.asm


























































 LDA #('.') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 62+1 output.asm

%line 62+0 output.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 63+1 output.asm
 LDA #5
 STA index
 .loop:
 LDY index
 LDA R0,Y
 STA arg

%line 69+0 output.asm





























































 LDA arg
 STA DigitHigh.a0









 JSR DigitHigh
%line 70+1 output.asm

%line 70+0 output.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 71+1 output.asm
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

%line 83+0 output.asm






























































 LDA #(R0+7) % 256
 STA BCD_Reverse.a0
 LDA #(R0+7) / 256
 STA BCD_Reverse.a0+1














































 LDA #(2) % 256
 STA BCD_Reverse.a1









 JSR BCD_Reverse
%line 84+1 output.asm
 .positive_e:

%line 85+0 output.asm























































 LDA sign
 STA LCD_char.a0









 JSR LCD_char
%line 86+1 output.asm
 LDY #8
 LDA R0,Y
 STA arg

%line 89+0 output.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 90+1 output.asm
 LDY #7
 LDA R0,Y
 STA arg

%line 93+0 output.asm





























































 LDA arg
 STA DigitHigh.a0









 JSR DigitHigh
%line 94+1 output.asm

%line 94+0 output.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 95+1 output.asm

 RTS

 HexHigh:

 digit set ASSIGN_LOCAL_BYTE
%line 100+0 output.asm
 HexHigh.a0 set HexHigh.digit
%line 101+1 output.asm

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

%line 121+0 output.asm





































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 122+1 output.asm
 RTS

 HexLow:

 digit set ASSIGN_LOCAL_BYTE
%line 126+0 output.asm
 HexLow.a0 set HexLow.digit
%line 127+1 output.asm

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

%line 144+0 output.asm





































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 145+1 output.asm
 RTS

 DrawHex:

 source set ASSIGN_LOCAL_WORD
%line 149+0 output.asm
 DrawHex.a0 set DrawHex.source
%line 150+1 output.asm

 arg set ASSIGN_LOCAL_BYTE



%line 154+0 output.asm








































 LDA #('$') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 155+1 output.asm

 LDY #2
 LDA (source),Y
 STA arg

%line 159+0 output.asm





































 LDA arg
 STA HexHigh.a0









 JSR HexHigh
%line 160+1 output.asm

%line 160+0 output.asm





































 LDA arg
 STA HexLow.a0









 JSR HexLow
%line 161+1 output.asm
 LDY #1
 LDA (source),Y
 STA arg

%line 164+0 output.asm





































 LDA arg
 STA HexHigh.a0









 JSR HexHigh
%line 165+1 output.asm

%line 165+0 output.asm





































 LDA arg
 STA HexLow.a0









 JSR HexLow
%line 166+1 output.asm
 RTS

 DrawString:

 source set ASSIGN_LOCAL_WORD
%line 170+0 output.asm
 DrawString.a0 set DrawString.source
%line 171+1 output.asm

 arg set ASSIGN_LOCAL_BYTE
 index set ASSIGN_LOCAL_BYTE



%line 176+0 output.asm














































 LDA #(CHAR_QUOTE) % 256
 STA LCD_char.a0










 JSR LCD_char
%line 177+1 output.asm

 LDA #1
 STA index
 .loop:
 LDY index
 LDA (source),Y
 BEQ .done
 STA arg

%line 185+0 output.asm

















































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 186+1 output.asm
 INC index
 LDA index
 CMP #9
 BNE .loop
 .done:

%line 191+0 output.asm














































 LDA #(CHAR_QUOTE) % 256
 STA LCD_char.a0










 JSR LCD_char
%line 192+1 output.asm
 RTS

 DrawStack:

 character set ASSIGN_LOCAL_BYTE
 counter set ASSIGN_LOCAL_BYTE
 address set ASSIGN_LOCAL_WORD


 TXA
 CLC
 ADC #(4*OBJ_SIZE)
 STA address
 LDA #0
 STA address+1


%line 208+0 output.asm









 JSR LCD_clrscr
%line 209+1 output.asm

%line 209+0 output.asm















 JMP ..@913.str_skip
 ..@913.str_addr:
 FCB "RAD",0
 ..@913.str_skip:




































 LDA #(..@913.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@913.str_addr) / 256
 STA LCD_print.a0+1










 JSR LCD_print
%line 210+1 output.asm


%line 211+0 output.asm






















 LDA #('5') % 256
 STA character

%line 212+1 output.asm

%line 212+0 output.asm
















 LDA #(5) % 256
 STA counter

%line 213+1 output.asm

 .loop:
 LDA #0
 STA screen_ptr
 LDA screen_ptr+1
 CLC
 ADC #CHAR_HEIGHT
 STA screen_ptr+1

%line 221+0 output.asm

















































 LDA character
 STA LCD_char.a0









 JSR LCD_char
%line 222+1 output.asm

%line 222+0 output.asm














































 LDA #(':') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 223+1 output.asm

 DEC counter
 LDA counter
 CMP stack_count
 BCS .no_item
 LDY #0
 LDA (address),Y
 CMP #OBJ_FLOAT
 BNE .not_float

%line 232+0 output.asm
























































 LDA address
 STA DrawFloat.a0
 LDA address+1
 STA DrawFloat.a0+1









 JSR DrawFloat
%line 233+1 output.asm
 JMP .item_done
 .not_float:
 CMP #OBJ_STR
 BNE .not_str

%line 237+0 output.asm
























































 LDA address
 STA DrawString.a0
 LDA address+1
 STA DrawString.a0+1









 JSR DrawString
%line 238+1 output.asm
 JMP .item_done
 .not_str:
 CMP #OBJ_HEX
 BNE .not_hex

%line 242+0 output.asm
























































 LDA address
 STA DrawHex.a0
 LDA address+1
 STA DrawHex.a0+1









 JSR DrawHex
%line 243+1 output.asm
 JMP .item_done
 .not_hex:
 .item_done:
 .no_item:

 LDA address
 SEC
 SBC #OBJ_SIZE
 STA address

 DEC character
 LDA counter
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



 ERROR_NONE = 0
 ERROR_INPUT = 2
 ERROR_WORD_TOO_LONG = 4
 ERROR_STRING = 6
 ERROR_STACK_OVERFLOW = 8
 ERROR_STACK_UNDERFLOW = 10



 ERROR_MSG_INPUT:
 FCB "INPUT ERROR ",0
 ERROR_MSG_WORD_TOO_LONG:
 FCB "INPUT SIZE  ",0
 ERROR_MSG_STRING:
 FCB "STRING ERROR",0
 ERROR_MSG_STACK_OVERFLOW:
 FCB "STACK OVERF ",0
 ERROR_MSG_STACK_UNDERFLOW:
 FCB "STACK UNDERF",0

 ERROR_TABLE:
 FDB ERROR_MSG_INPUT
 FDB ERROR_MSG_WORD_TOO_LONG
 FDB ERROR_MSG_STRING
 FDB ERROR_MSG_STACK_OVERFLOW
 FDB ERROR_MSG_STACK_UNDERFLOW


 ErrorMsg:

 error_code set ASSIGN_LOCAL_BYTE
%line 306+0 output.asm
 ErrorMsg.a0 set ErrorMsg.error_code
%line 307+1 output.asm
 msg set ASSIGN_LOCAL_WORD
%line 307+0 output.asm
 ErrorMsg.a1 set ErrorMsg.msg
%line 308+1 output.asm


 LDY error_code
 LDA ERROR_TABLE-2,Y
 STA msg
 LDA ERROR_TABLE-1,Y
 STA msg+1

 LDA #ERROR_X
 STA screen_ptr
 LDA #ERROR_Y
 STA screen_ptr+1

%line 320+0 output.asm















 JMP ..@1088.str_skip
 ..@1088.str_addr:
 FCB "bbbbbbbbbbbb",0
 ..@1088.str_skip:






























 LDA #(..@1088.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@1088.str_addr) / 256
 STA LCD_print.a0+1










 JSR LCD_print
%line 321+1 output.asm
 LDA #ERROR_X
 STA screen_ptr
 LDA #ERROR_Y+CHAR_HEIGHT
 STA screen_ptr+1

%line 325+0 output.asm

























 LDA #($FF) % 256
 STA font_inverted

%line 326+1 output.asm

%line 326+0 output.asm












































 LDA msg
 STA LCD_print.a0
 LDA msg+1
 STA LCD_print.a0+1









 JSR LCD_print
%line 327+1 output.asm
 LDA #ERROR_X
 STA screen_ptr
 LDA #ERROR_Y+CHAR_HEIGHT*2
 STA screen_ptr+1

%line 331+0 output.asm















 JMP ..@1142.str_skip
 ..@1142.str_addr:
 FCB "bbbbbbbbbbbb",0
 ..@1142.str_skip:






























 LDA #(..@1142.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@1142.str_addr) / 256
 STA LCD_print.a0+1










 JSR LCD_print
%line 332+1 output.asm

%line 332+0 output.asm

























 LDA #(0) % 256
 STA font_inverted

%line 333+1 output.asm

 .loop:

%line 335+0 output.asm









 JSR ReadKey
%line 336+1 output.asm
 CMP #KEY_ENTER
 BNE .loop
 RTS
 RTS


%line 92+1 main.asm

%line 1+1 forth.asm


 InitForth:
 LDA #0
 STA input_buff_begin
 STA input_buff_end
 STA new_word_len
 RTS

 SPECIAL_CHARS_LEN = 6
 special_chars:
 FCB CHAR_EXP, CHAR_QUOTE
 FCB " .$m"


 ReadLine:

 cursor set ASSIGN_LOCAL_BYTE
%line 18+0 forth.asm
 cursor_timer set ASSIGN_LOCAL_BYTE
%line 19+1 forth.asm
 arg set ASSIGN_LOCAL_BYTE
 index set ASSIGN_LOCAL_BYTE
%line 20+0 forth.asm
 str_index set ASSIGN_LOCAL_BYTE
%line 21+1 forth.asm


 LDA #0
 STA cursor
 STA index
 STA screen_ptr
 LDA #INPUT_Y
 STA screen_ptr+1

%line 29+0 forth.asm















 JMP ..@1193.str_skip
 ..@1193.str_addr:
 FCB "a               ",0
 ..@1193.str_skip:
















































 LDA #(..@1193.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@1193.str_addr) / 256
 STA LCD_print.a0+1










 JSR LCD_print
%line 30+1 forth.asm
 LDA TIMER_S
 STA cursor_timer

 .loop:
 LDA #0
 STA arg

%line 36+0 forth.asm









 JSR ReadKey
%line 37+1 forth.asm
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

%line 61+0 forth.asm


























































 LDA #(' ') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 62+1 forth.asm
 LDA screen_ptr
 SEC
 SBC #CHAR_WIDTH*2
 STA screen_ptr
 PHA

%line 67+0 forth.asm


























































 LDA #(CHAR_ARROW) % 256
 STA LCD_char.a0










 JSR LCD_char
%line 68+1 forth.asm
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

 CMP #'m'
 BNE .key_done
 LDA #CHAR_MINUS
 STA arg
 JMP .key_done
 .special_next:
 INY
 CPY #SPECIAL_CHARS_LEN
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

%line 136+0 forth.asm



































































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 137+1 forth.asm
 LDA screen_ptr
 PHA

%line 139+0 forth.asm


























































 LDA #(CHAR_ARROW) % 256
 STA LCD_char.a0










 JSR LCD_char
%line 140+1 forth.asm
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

%line 155+0 forth.asm



































































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 156+1 forth.asm
 LDA index
 CMP str_index
 BNE .scroll_loop
 LDA screen_ptr
 PHA

%line 161+0 forth.asm


























































 LDA #(CHAR_ARROW) % 256
 STA LCD_char.a0










 JSR LCD_char
%line 162+1 forth.asm
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

%line 185+0 forth.asm



































































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 186+1 forth.asm
 LDA screen_ptr
 SEC
 SBC #CHAR_WIDTH
 STA screen_ptr
 .cursor_done:
 JMP .loop
 RTS

 LineWord:

 LDA #ERROR_NONE
 STA ret_val

 LDA #0
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
 STA ret_val
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


%line 243+0 forth.asm

















 LDA #(FORTH_WORDS) % 256
 STA ret_val
 LDA #(FORTH_WORDS) / 256
 STA ret_val+1

%line 244+1 forth.asm
 .loop:
 LDY #0
 LDA (ret_val),Y
 CMP new_word_len
 BNE .loop_next
 INY
 .str_loop:
 LDA (ret_val),Y
 CMP new_word_buff-1,Y
 BNE .no_match
 CPY new_word_len
 BEQ .word_found
 INY
 JMP .str_loop
 .no_match:
 .loop_next:
 LDY #0
 LDA (ret_val),Y
 TAY
 INY
 LDA (ret_val),Y
 PHA
 INY
 LDA (ret_val),Y
 STA ret_val+1
 PLA
 STA ret_val
 ORA ret_val+1
 BNE .loop

 STA ret_val
 RTS
 .word_found:
 LDY #0
 LDA (ret_val),Y
 TAY
 INY
 INY
 INY
 LDA (ret_val),Y
 STA ret_val
 RTS

 CheckData:

 input_mode set ASSIGN_LOCAL_BYTE
 y_buff set ASSIGN_LOCAL_BYTE
 index set ASSIGN_LOCAL_BYTE
 which_digit set ASSIGN_LOCAL_BYTE
 negative set ASSIGN_LOCAL_BYTE
 exp_negative set ASSIGN_LOCAL_BYTE
 exp_count set ASSIGN_LOCAL_BYTE
 exp_found set ASSIGN_LOCAL_BYTE
 dec_found set ASSIGN_LOCAL_BYTE
 nonzero_found set ASSIGN_LOCAL_BYTE
 digit_count set ASSIGN_LOCAL_BYTE

 LDA #OBJ_ERROR
 STA new_stack_item

 LDA new_word_len
 BNE .not_zero_len

 RTS
 .not_zero_len:

 LDY #8
 LDA #0
 .zero_loop:
 STA new_stack_item,Y
 DEY
 BNE .zero_loop

 LDY #0
 LDA new_word_buff
 CMP #'"'
 BNE .not_string

 LDA new_word_len
 CMP #1
 BNE .not_single_quote

 RTS
 .not_single_quote:

 DEC new_word_len
 .loop_str:
 LDA new_word_buff+1,y
 CMP #'"'
 BEQ .str_done
 CPY #8
 BEQ .string_too_long
 STA new_stack_item+1,Y
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


 LDA #OBJ_STR
 STA new_stack_item
 .str_return:
 RTS
 .not_string:

 CMP #'$'
 BNE .not_hex

 LDA new_word_len

 CMP #1
 BEQ .hex_error

 CMP #6
 BCS .hex_error


 DEC new_word_len
 LDY #0
 .loop_hex:
 LDA new_word_buff+1,Y
 CMP #'0'
 BCC .hex_error
 CMP #'9'+1
 BCS .not_digit
 SEC
 SBC #'0'
 JSR .hex_rotate
 ORA new_stack_item+1
 STA new_stack_item+1
 JMP .hex_char_next
 .not_digit:

 CMP #'A'
 BCC .hex_error
 CMP #'F'+1
 BCS .hex_error
 SEC
 SBC #'A'-10
 JSR .hex_rotate
 ORA new_stack_item+1
 STA new_stack_item+1

 .hex_char_next:
 INY
 CPY new_word_len
 BEQ .hex_done
 CPY #4
 BNE .loop_hex


 .hex_done:
 LDA #OBJ_HEX
 STA new_stack_item
 RTS
 .hex_error:
 RTS
 .not_hex:


 LDA #6
 STA index
 LDA #0
 STA which_digit
 STA negative
 STA exp_negative
 STA exp_count
 STA digit_count
 STA nonzero_found
 STA dec_found
 STA exp_found


 LDA new_word_buff
 CMP #CHAR_MINUS
 BNE .float_no_neg

 LDA #$FF
 STA negative
 INY
 .float_no_neg:

 .loop_float:
 LDA new_word_buff,Y
 JSR .digit
 BCC .float_not_digit
 PHA
 LDA nonzero_found
 BNE .digit_good

 PLA
 PHA
 BEQ .digit_zero

 LDA #$FF
 STA nonzero_found
 BNE .digit_good

 .digit_zero:

 PLA
 LDA exp_found
 BNE .float_next
 LDA dec_found
 BEQ .float_next
 DEC exp_count
 BNE .float_next

 .digit_good:
 LDA exp_found
 BNE .exp_digit
 LDA digit_count
 CMP #MAX_DIGITS
 BNE .digit_ok

 PLA
 RTS
 .digit_ok:
 LDA dec_found
 BNE .no_dec_yet
 INC exp_count
 .no_dec_yet:

 PLA
 JSR .add_digit
 .float_next:
 INY
 CPY new_word_len
 BEQ .float_done
 JMP .loop_float
 .exp_digit:
 LDA digit_count
 CMP #3
 BNE .exp_digit_ok

 PLA
 RTS
 .exp_digit_ok:

 PLA
 STY y_buff
 LDY #4
 .exp_loop:
 ASL new_stack_item+7
 ROL new_stack_item+8
 DEY
 BNE .exp_loop
 LDY y_buff
 ORA new_stack_item+7
 STA new_stack_item+7
 INC index
 INC digit_count
 JMP .float_next
 .float_not_digit:


 CMP #'.'
 BNE .not_decimal_point
 LDA dec_found
 BEQ .decimal_good

 RTS
 .decimal_good:
 LDA exp_found
 BEQ .exp_good

 RTS
 .exp_good:
 LDA #$FF
 STA dec_found
 BNE .float_next
 .not_decimal_point:

 CMP #'e'
 BNE .not_exp
 LDA exp_found
 BEQ .first_exp

 RTS
 .first_exp:
 LDA #0
 STA index
 STA which_digit
 STA digit_count
 STA nonzero_found
 LDA #$FF
 STA exp_found
 BNE .float_next
 .not_exp:

 CMP #CHAR_MINUS
 BNE .not_minus

 LDA exp_found
 EOR #$FF
 ORA index
 ORA exp_negative
 BEQ .minus_good

 RTS
 .minus_good:
 LDA #$FF
 STA exp_negative
 BNE .float_next
 .not_minus:


 RTS
 .float_done:





 LDA exp_negative
 BEQ .exp_not_negative

%line 576+0 forth.asm


































































































 LDA #(new_stack_item+7) % 256
 STA BCD_Reverse.a0
 LDA #(new_stack_item+7) / 256
 STA BCD_Reverse.a0+1


















































































 LDA #(2) % 256
 STA BCD_Reverse.a1









 JSR BCD_Reverse
%line 577+1 forth.asm
 .exp_not_negative:


 LDA exp_count





 LDA #OBJ_FLOAT
 STA new_stack_item

 RTS


 .hex_rotate:
 STY y_buff
 LDY #4
 .hex_rot_loop:
 ASL new_stack_item+1
 ROL new_stack_item+2
 DEY
 BNE .hex_rot_loop
 LDY y_buff
 RTS


 .digit:
 CMP #'9'+1
 BCS .is_digit_no
 CMP #'0'
 BCC .is_digit_no

 SBC #'0'
 RTS
 .is_digit_no:
 CLC
 RTS

 .add_digit:
 PHA
 STY y_buff
 LDY index
 INC digit_count
 LDA which_digit
 EOR #$FF
 STA which_digit
 BEQ .second_digit

 PLA
 ASL
 ASL
 ASL
 ASL
 STA new_stack_item,Y
 LDY y_buff
 RTS
 .second_digit:
 PLA
 ORA new_stack_item,Y
 STA new_stack_item,Y
 DEC index
 LDY y_buff
 RTS

 RTS

 ExecToken:

 token set ASSIGN_LOCAL_BYTE
%line 646+0 forth.asm
 ExecToken.a0 set ExecToken.token
 flags set ASSIGN_LOCAL_BYTE
 ExecToken.a1 set ExecToken.flags
%line 647+1 forth.asm
 temp set ASSIGN_LOCAL_BYTE
%line 647+0 forth.asm
 ExecToken.a2 set ExecToken.temp
%line 648+1 forth.asm
 address set ASSIGN_LOCAL_WORD
%line 648+0 forth.asm
 ExecToken.a3 set ExecToken.address
%line 649+1 forth.asm



 LDA #ERROR_NONE
 STA ret_val

 LDY token
 LDA JUMP_TABLE,Y
 STA address
 LDA JUMP_TABLE+1,Y
 STA address+1
 LDY #0
 LDA (address),Y
 BEQ .no_flags
 STA flags


 AND #MIN_3
 STA temp
 LDA stack_count
 CMP temp
 BCS .no_underflow
 LDA #ERROR_STACK_UNDERFLOW
 STA ret_val
 RTS
 .no_underflow:


 LDA flags
 AND #ADD_1
 BEQ .no_add_item
 LDA #STACK_SIZE-1
 CMP stack_count
 BCS .no_overflow
 LDA #ERROR_STACK_OVERFLOW
 STA ret_val
 RTS
 .no_overflow:
 JSR StackAddItem
 .no_add_item:
 .no_flags:


 LDA address+1
 PHA
 LDA address
 PHA
 RTS
 RTS

 StackAddItem:
 TXA
 SEC
 SBC #OBJ_SIZE
 TAX
 INC stack_count
 RTS



 FORTH_WORDS:

 WORD_DUP:
 FCB 3, "DUP"
 FDB WORD_SWAP
 FCB 2
 CODE_DUP:
 FCB MIN_1|ADD_1

 LDY #OBJ_SIZE
 TXA
 PHA
 .dup_loop:
 LDA OBJ_SIZE,X
 STA 0,X
 INX
 DEY
 BNE .dup_loop
 PLA
 TAX
 RTS

 WORD_SWAP:
 FCB 4, "SWAP"
 FDB WORD_DROP
 FCB 4
 CODE_SWAP:
 FCB MIN_2

 LDY #OBJ_SIZE
 TXA
 PHA
 .swap_loop:
 LDA OBJ_SIZE,X
 PHA
 LDA 0,X
 STA OBJ_SIZE,X
 PLA
 STA 0,X
 INX
 DEY
 BNE .swap_loop
 PLA
 TAX
 RTS

 WORD_DROP:
 FCB 4, "DROP"
 FDB WORD_OVER
 FCB 6
 CODE_DROP:
 FCB MIN_1

 TXA
 CLC
 ADC #OBJ_SIZE
 TAX
 DEC stack_count
 RTS

 WORD_OVER:
 FCB 4, "OVER"
 FDB WORD_ROT
 FCB 8
 CODE_OVER:
 FCB MIN_2|ADD_1

 LDY #OBJ_SIZE
 TXA
 PHA
 .over_loop:
 LDA OBJ_SIZE*2,X
 STA 0,X
 INX
 DEY
 BNE .over_loop
 PLA
 TAX
 RTS

 WORD_ROT:
 FCB 3, "ROT"
 FDB WORD_MIN_ROT
 FCB 10
 CODE_ROT:
 FCB MIN_3

 LDY #OBJ_SIZE
 TXA
 PHA
 .rot_loop:
 LDA OBJ_SIZE*2,X
 PHA
 LDA OBJ_SIZE,X
 PHA
 LDA 0,X
 STA OBJ_SIZE,X
 PLA
 STA OBJ_SIZE*2,X
 PLA
 STA 0,X

 INX
 DEY
 BNE .rot_loop
 PLA
 TAX
 RTS

 WORD_MIN_ROT:
 FCB 4, "-ROT"
 FDB WORD_CLEAR
 FCB 12
 CODE_MIN_ROT:
 FCB MIN_3

 LDY #OBJ_SIZE
 TXA
 PHA
 .min_rot_loop:
 LDA OBJ_SIZE*2,X
 PHA
 LDA OBJ_SIZE,X
 PHA
 LDA 0,X
 STA OBJ_SIZE*2,X
 PLA
 STA 0,X
 PLA
 STA OBJ_SIZE,X

 INX
 DEY
 BNE .min_rot_loop
 PLA
 TAX
 RTS

 WORD_CLEAR:
 FCB 5,"CLEAR"
 FDB 0
 FCB 14
 CODE_CLEAR:
 FCB 0
 LDX #0
 STX stack_count
 RTS


 JUMP_TABLE:
 FDB 0
 FDB CODE_DUP
 FDB CODE_SWAP
 FDB CODE_DROP
 FDB CODE_OVER
 FDB CODE_ROT
 FDB CODE_MIN_ROT
 FDB CODE_CLEAR


%line 93+1 main.asm





 BEGIN_FUNC set main
%line 98+0 main.asm
 main:
%line 100+1 main.asm
 dest set ASSIGN_LOCAL_WORD
 arg set ASSIGN_LOCAL_BYTE





 LDX #$2F
 TXS


%line 110+0 main.asm









 JSR setup
%line 111+1 main.asm

 .input_loop:

%line 113+0 main.asm









 JSR DrawStack
%line 114+1 main.asm

%line 114+0 main.asm









 JSR ReadLine
%line 115+1 main.asm

 .process_loop:

%line 117+0 main.asm









 JSR LineWord
%line 118+1 main.asm
 LDA new_word_len
 BEQ .input_loop


%line 121+0 main.asm









 JSR FindWord
%line 122+1 main.asm
 LDA ret_val
 BEQ .not_found



%line 126+0 main.asm














































 LDA ret_val
 STA ExecToken.a0









 JSR ExecToken
%line 127+1 main.asm
 LDA ret_val
 BEQ .no_exec_error
 STA arg

%line 130+0 main.asm





































 LDA arg
 STA ErrorMsg.a0









 JSR ErrorMsg
%line 131+1 main.asm
 JMP .input_loop
 .no_exec_error:
 JMP .process_loop
 .not_found:


%line 136+0 main.asm









 JSR CheckData
%line 137+1 main.asm
 LDA new_stack_item
 CMP #OBJ_ERROR
 BNE .input_good

%line 140+0 main.asm








































 LDA #(ERROR_INPUT) % 256
 STA ErrorMsg.a0










 JSR ErrorMsg
%line 141+1 main.asm
 JMP .input_loop
 .input_good:


 LDA #STACK_SIZE-1
 CMP stack_count
 BCS .no_overflow

%line 148+0 main.asm








































 LDA #(ERROR_STACK_OVERFLOW) % 256
 STA ErrorMsg.a0










 JSR ErrorMsg
%line 149+1 main.asm
 JMP .input_loop
 .no_overflow:


 JSR StackAddItem

 STX dest
 LDA #0
 STA dest+1

%line 158+0 main.asm












































 LDA #(new_stack_item) % 256
 STA MemCopy.a0
 LDA #(new_stack_item) / 256
 STA MemCopy.a0+1
































 LDA dest
 STA MemCopy.a1
 LDA dest+1
 STA MemCopy.a1+1



























 LDA #(OBJ_SIZE) % 256
 STA MemCopy.a2








 JSR MemCopy
%line 159+1 main.asm

 JMP .process_loop

 RTS


%line 110+1 nasm.asm


