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


SIGN_BIT = $80
E_SIGN_BIT = $40


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
 FLOAT1 = 8
 STRING1 = 16
 HEX1 = 24
 FLOAT2 = 32
 STRING2 = 64
 HEX2 = 96
 COMPILE_ONLY = 128

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


 test_count:
%line 22+0 globals.asm
 DFS 1
%line 23+1 globals.asm



%line 75+1 main.asm





 ORG $C000
%line 1+1 tests.asm





 DebugText:

 msg set ASSIGN_LOCAL_WORD
%line 8+0 tests.asm
 DebugText.a0 set DebugText.msg
%line 9+1 tests.asm

 LDY #0
 .loop:
 LDA (msg),Y
 BEQ .done
 STA DEBUG
 INY
 JMP .loop
 .done:
 RTS

 halt_test:

 test set ASSIGN_LOCAL_BYTE
%line 22+0 tests.asm
 halt_test.a0 set halt_test.test
%line 23+1 tests.asm


 LDA test
 CMP test_count
 BNE .done
 BRK
%line 28+0 tests.asm
 BRK
%line 29+1 tests.asm
 .done:
 RTS

 InputTest:

 input set ASSIGN_LOCAL_WORD
%line 34+0 tests.asm
 InputTest.a0 set InputTest.input
 output set ASSIGN_LOCAL_WORD
 InputTest.a1 set InputTest.output
%line 35+1 tests.asm

 output_index set ASSIGN_LOCAL_BYTE
%line 36+0 tests.asm
 calculated_index set ASSIGN_LOCAL_BYTE
 value set ASSIGN_LOCAL_BYTE
%line 37+1 tests.asm


 LDY #0
 .loop:
 LDA (input),Y
 BEQ .loop_done
 CMP #'-'
 BNE .not_minus
 LDA #CHAR_MINUS
 .not_minus:
 STA new_word_buff,Y
 INY
 JMP .loop
 .loop_done:
 STY new_word_len

%line 52+0 tests.asm









 JSR CheckData
%line 53+1 tests.asm

 LDY #0
 STY calculated_index
 STY output_index
 .check_loop:
 LDY output_index
 LDA (output),Y
 CMP #'A'
 BCS .letter
 SEC
 SBC #'0'
 JMP .letter_done
 .letter:
 SEC
 SBC #'A'-10
 .letter_done:
 ASL
 ASL
 ASL
 ASL
 STA value

 INY
 LDA (output),Y
 CMP #'A'
 BCS .letter2
 SEC
 SBC #'0'
 JMP .letter_done2
 .letter2:
 SEC
 SBC #'A'-10
 .letter_done2:
 ORA value
 STA value

 INY
 STY output_index

 LDY calculated_index
 LDA new_stack_item,Y
 CMP value
 BNE .failed
 INY
 STY calculated_index

 LDY output_index
 LDA (output),Y
 BNE .continue
 JMP .done
 .continue:
 INY
 STY output_index
 JMP .check_loop

 .failed:

%line 109+0 tests.asm















 JMP ..@53.str_skip
 ..@53.str_addr:
 FCB "\\rTest ",0
 ..@53.str_skip:
















































 LDA #(..@53.str_addr) % 256
 STA DebugText.a0
 LDA #(..@53.str_addr) / 256
 STA DebugText.a0+1










 JSR DebugText
%line 110+1 tests.asm
 LDX test_count+1
 LDA test_count
 STA DEBUG_DEC16

%line 113+0 tests.asm















 JMP ..@77.str_skip
 ..@77.str_addr:
 FCB ": FAILED!\\n",0
 ..@77.str_skip:
















































 LDA #(..@77.str_addr) % 256
 STA DebugText.a0
 LDA #(..@77.str_addr) / 256
 STA DebugText.a0+1










 JSR DebugText
%line 114+1 tests.asm

%line 114+0 tests.asm















 JMP ..@101.str_skip
 ..@101.str_addr:
 FCB "   Expected: ",0
 ..@101.str_skip:
















































 LDA #(..@101.str_addr) % 256
 STA DebugText.a0
 LDA #(..@101.str_addr) / 256
 STA DebugText.a0+1










 JSR DebugText
%line 115+1 tests.asm

%line 115+0 tests.asm










































































 LDA output
 STA DebugText.a0
 LDA output+1
 STA DebugText.a0+1









 JSR DebugText
%line 116+1 tests.asm

%line 116+0 tests.asm















 JMP ..@153.str_skip
 ..@153.str_addr:
 FCB "\\n   Found:    ",0
 ..@153.str_skip:
















































 LDA #(..@153.str_addr) % 256
 STA DebugText.a0
 LDA #(..@153.str_addr) / 256
 STA DebugText.a0+1










 JSR DebugText
%line 117+1 tests.asm
 LDY #0
 STY calculated_index
 LDY #2
 STY output_index
 .fail_loop:
 LDY calculated_index
 LDA new_stack_item,Y
 STA DEBUG_HEX
 LDA #' '
 STA DEBUG
 INY
 STY calculated_index
 LDY output_index
 LDA (output),Y
 BEQ .fail_done
 INY
 INY
 INY
 STY output_index

 JMP .fail_loop
 .fail_done:
 BRK
%line 139+0 tests.asm
 BRK
%line 140+1 tests.asm
 LDA new_stack_item
 JMP .failed

 .done:

%line 144+0 tests.asm















 JMP ..@178.str_skip
 ..@178.str_addr:
 FCB "\\gTest ",0
 ..@178.str_skip:
















































 LDA #(..@178.str_addr) % 256
 STA DebugText.a0
 LDA #(..@178.str_addr) / 256
 STA DebugText.a0+1










 JSR DebugText
%line 145+1 tests.asm
 LDX test_count+1
 LDA test_count
 STA DEBUG_DEC16

%line 148+0 tests.asm















 JMP ..@202.str_skip
 ..@202.str_addr:
 FCB ": passed\\n",0
 ..@202.str_skip:
















































 LDA #(..@202.str_addr) % 256
 STA DebugText.a0
 LDA #(..@202.str_addr) / 256
 STA DebugText.a0+1










 JSR DebugText
%line 149+1 tests.asm
 INC test_count
%line 149+0 tests.asm
 BNE ..@223.no_carry
 INC test_count+1
 ..@223.no_carry:
%line 150+1 tests.asm
 RTS

 tests:

 LDA #1
 STA test_count





%line 160+0 tests.asm















 JMP ..@232.str_skip
 ..@232.str_addr:
 FCB "5",0
 ..@232.str_skip:


















 LDA #(..@232.str_addr) % 256
 STA InputTest.a0
 LDA #(..@232.str_addr) / 256
 STA InputTest.a0+1



 JMP ..@241.str_skip
 ..@241.str_addr:
 FCB "01 00 00 00 00 00 50 00 00",0
 ..@241.str_skip:


















 LDA #(..@241.str_addr) % 256
 STA InputTest.a1
 LDA #(..@241.str_addr) / 256
 STA InputTest.a1+1









 JSR InputTest
%line 161+1 tests.asm



%line 163+0 tests.asm















 JMP ..@259.str_skip
 ..@259.str_addr:
 FCB "500",0
 ..@259.str_skip:


















 LDA #(..@259.str_addr) % 256
 STA InputTest.a0
 LDA #(..@259.str_addr) / 256
 STA InputTest.a0+1



 JMP ..@268.str_skip
 ..@268.str_addr:
 FCB "01 00 00 00 00 00 50 02 00",0
 ..@268.str_skip:


















 LDA #(..@268.str_addr) % 256
 STA InputTest.a1
 LDA #(..@268.str_addr) / 256
 STA InputTest.a1+1









 JSR InputTest
%line 164+1 tests.asm



%line 166+0 tests.asm















 JMP ..@286.str_skip
 ..@286.str_addr:
 FCB "500",0
 ..@286.str_skip:


















 LDA #(..@286.str_addr) % 256
 STA InputTest.a0
 LDA #(..@286.str_addr) / 256
 STA InputTest.a0+1



 JMP ..@295.str_skip
 ..@295.str_addr:
 FCB "01 00 00 00 00 00 50 02 00",0
 ..@295.str_skip:


















 LDA #(..@295.str_addr) % 256
 STA InputTest.a1
 LDA #(..@295.str_addr) / 256
 STA InputTest.a1+1









 JSR InputTest
%line 167+1 tests.asm



%line 169+0 tests.asm















 JMP ..@313.str_skip
 ..@313.str_addr:
 FCB "500.0",0
 ..@313.str_skip:


















 LDA #(..@313.str_addr) % 256
 STA InputTest.a0
 LDA #(..@313.str_addr) / 256
 STA InputTest.a0+1



 JMP ..@322.str_skip
 ..@322.str_addr:
 FCB "01 00 00 00 00 00 50 02 00",0
 ..@322.str_skip:


















 LDA #(..@322.str_addr) % 256
 STA InputTest.a1
 LDA #(..@322.str_addr) / 256
 STA InputTest.a1+1









 JSR InputTest
%line 170+1 tests.asm



%line 172+0 tests.asm















 JMP ..@340.str_skip
 ..@340.str_addr:
 FCB "500.00",0
 ..@340.str_skip:


















 LDA #(..@340.str_addr) % 256
 STA InputTest.a0
 LDA #(..@340.str_addr) / 256
 STA InputTest.a0+1



 JMP ..@349.str_skip
 ..@349.str_addr:
 FCB "01 00 00 00 00 00 50 02 00",0
 ..@349.str_skip:


















 LDA #(..@349.str_addr) % 256
 STA InputTest.a1
 LDA #(..@349.str_addr) / 256
 STA InputTest.a1+1









 JSR InputTest
%line 173+1 tests.asm



%line 175+0 tests.asm















 JMP ..@367.str_skip
 ..@367.str_addr:
 FCB "5e0",0
 ..@367.str_skip:


















 LDA #(..@367.str_addr) % 256
 STA InputTest.a0
 LDA #(..@367.str_addr) / 256
 STA InputTest.a0+1



 JMP ..@376.str_skip
 ..@376.str_addr:
 FCB "01 00 00 00 00 00 50 00 00",0
 ..@376.str_skip:


















 LDA #(..@376.str_addr) % 256
 STA InputTest.a1
 LDA #(..@376.str_addr) / 256
 STA InputTest.a1+1









 JSR InputTest
%line 176+1 tests.asm



%line 178+0 tests.asm















 JMP ..@394.str_skip
 ..@394.str_addr:
 FCB "500e0",0
 ..@394.str_skip:


















 LDA #(..@394.str_addr) % 256
 STA InputTest.a0
 LDA #(..@394.str_addr) / 256
 STA InputTest.a0+1



 JMP ..@403.str_skip
 ..@403.str_addr:
 FCB "01 00 00 00 00 00 50 02 00",0
 ..@403.str_skip:


















 LDA #(..@403.str_addr) % 256
 STA InputTest.a1
 LDA #(..@403.str_addr) / 256
 STA InputTest.a1+1









 JSR InputTest
%line 179+1 tests.asm



%line 181+0 tests.asm















 JMP ..@421.str_skip
 ..@421.str_addr:
 FCB "500e2",0
 ..@421.str_skip:


















 LDA #(..@421.str_addr) % 256
 STA InputTest.a0
 LDA #(..@421.str_addr) / 256
 STA InputTest.a0+1



 JMP ..@430.str_skip
 ..@430.str_addr:
 FCB "01 00 00 00 00 00 50 04 00",0
 ..@430.str_skip:


















 LDA #(..@430.str_addr) % 256
 STA InputTest.a1
 LDA #(..@430.str_addr) / 256
 STA InputTest.a1+1









 JSR InputTest
%line 182+1 tests.asm



%line 184+0 tests.asm















 JMP ..@448.str_skip
 ..@448.str_addr:
 FCB "500e997",0
 ..@448.str_skip:


















 LDA #(..@448.str_addr) % 256
 STA InputTest.a0
 LDA #(..@448.str_addr) / 256
 STA InputTest.a0+1



 JMP ..@457.str_skip
 ..@457.str_addr:
 FCB "01 00 00 00 00 00 50 99 09",0
 ..@457.str_skip:


















 LDA #(..@457.str_addr) % 256
 STA InputTest.a1
 LDA #(..@457.str_addr) / 256
 STA InputTest.a1+1









 JSR InputTest
%line 185+1 tests.asm



%line 187+0 tests.asm















 JMP ..@475.str_skip
 ..@475.str_addr:
 FCB "500e998",0
 ..@475.str_skip:


















 LDA #(..@475.str_addr) % 256
 STA InputTest.a0
 LDA #(..@475.str_addr) / 256
 STA InputTest.a0+1



 JMP ..@484.str_skip
 ..@484.str_addr:
 FCB "04",0
 ..@484.str_skip:


















 LDA #(..@484.str_addr) % 256
 STA InputTest.a1
 LDA #(..@484.str_addr) / 256
 STA InputTest.a1+1









 JSR InputTest
%line 188+1 tests.asm



%line 190+0 tests.asm















 JMP ..@502.str_skip
 ..@502.str_addr:
 FCB "-5",0
 ..@502.str_skip:


















 LDA #(..@502.str_addr) % 256
 STA InputTest.a0
 LDA #(..@502.str_addr) / 256
 STA InputTest.a0+1



 JMP ..@511.str_skip
 ..@511.str_addr:
 FCB "01 00 00 00 00 00 50 00 80",0
 ..@511.str_skip:


















 LDA #(..@511.str_addr) % 256
 STA InputTest.a1
 LDA #(..@511.str_addr) / 256
 STA InputTest.a1+1









 JSR InputTest
%line 191+1 tests.asm



%line 193+0 tests.asm















 JMP ..@529.str_skip
 ..@529.str_addr:
 FCB "-500",0
 ..@529.str_skip:


















 LDA #(..@529.str_addr) % 256
 STA InputTest.a0
 LDA #(..@529.str_addr) / 256
 STA InputTest.a0+1



 JMP ..@538.str_skip
 ..@538.str_addr:
 FCB "01 00 00 00 00 00 50 02 80",0
 ..@538.str_skip:


















 LDA #(..@538.str_addr) % 256
 STA InputTest.a1
 LDA #(..@538.str_addr) / 256
 STA InputTest.a1+1









 JSR InputTest
%line 194+1 tests.asm







































%line 232+0 tests.asm















 JMP ..@556.str_skip
 ..@556.str_addr:
 FCB "\\n\\gAll tests passed",0
 ..@556.str_skip:


















 LDA #(..@556.str_addr) % 256
 STA DebugText.a0
 LDA #(..@556.str_addr) / 256
 STA DebugText.a0+1










 JSR DebugText
%line 233+1 tests.asm

%line 233+0 tests.asm















 JMP ..@575.str_skip
 ..@575.str_addr:
 FCB "\\n\\lSize of code: ",0
 ..@575.str_skip:


















 LDA #(..@575.str_addr) % 256
 STA DebugText.a0
 LDA #(..@575.str_addr) / 256
 STA DebugText.a0+1










 JSR DebugText
%line 234+1 tests.asm
 LDX #(code_end-code_begin)/256
 LDA #(code_end-code_begin) # 256
 STA DEBUG_DEC16

%line 237+0 tests.asm















 JMP ..@594.str_skip
 ..@594.str_addr:
 FCB " bytes",0
 ..@594.str_skip:


















 LDA #(..@594.str_addr) % 256
 STA DebugText.a0
 LDA #(..@594.str_addr) / 256
 STA DebugText.a0+1










 JSR DebugText
%line 238+1 tests.asm
 RTS

%line 81+1 main.asm


 ORG $900
 code_begin:
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





%line 89+1 main.asm



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
 BCC ..@696.skip
%line 66+0 emu6507.asm
 JMP .if0
 ..@696.skip:
%line 67+1 emu6507.asm
 RTS
 .if0:

 CMP #'e'+1
 BCS ..@701.skip
%line 71+0 emu6507.asm
 JMP .if1
 ..@701.skip:
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

%line 92+1 main.asm


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

%line 94+1 main.asm

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
 PHP
 SED
 SEC
 .loop:
 LDA #0
 SBC (source),Y
 STA (source),Y
 INY
 DEC count
 BNE .loop
 PLP
 RTS


%line 95+1 main.asm

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
 LDY #8
 LDA (source),Y
 AND #SIGN_BIT
 BEQ .positive
 LDA #CHAR_MINUS
 STA sign
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
 AND #E_SIGN_BIT
 BEQ .positive_e
 LDA #CHAR_MINUS
 STA sign
 .positive_e:

%line 83+0 output.asm























































 LDA sign
 STA LCD_char.a0









 JSR LCD_char
%line 84+1 output.asm
 LDY #8
 LDA R0,Y
 STA arg

%line 87+0 output.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 88+1 output.asm
 LDY #7
 LDA R0,Y
 STA arg

%line 91+0 output.asm





























































 LDA arg
 STA DigitHigh.a0









 JSR DigitHigh
%line 92+1 output.asm

%line 92+0 output.asm





























































 LDA arg
 STA DigitLow.a0









 JSR DigitLow
%line 93+1 output.asm

 RTS

 HexHigh:

 digit set ASSIGN_LOCAL_BYTE
%line 98+0 output.asm
 HexHigh.a0 set HexHigh.digit
%line 99+1 output.asm

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

%line 119+0 output.asm





































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 120+1 output.asm
 RTS

 HexLow:

 digit set ASSIGN_LOCAL_BYTE
%line 124+0 output.asm
 HexLow.a0 set HexLow.digit
%line 125+1 output.asm

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

%line 142+0 output.asm





































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 143+1 output.asm
 RTS

 DrawHex:

 source set ASSIGN_LOCAL_WORD
%line 147+0 output.asm
 DrawHex.a0 set DrawHex.source
%line 148+1 output.asm

 arg set ASSIGN_LOCAL_BYTE



%line 152+0 output.asm








































 LDA #('$') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 153+1 output.asm

 LDY #2
 LDA (source),Y
 STA arg

%line 157+0 output.asm





































 LDA arg
 STA HexHigh.a0









 JSR HexHigh
%line 158+1 output.asm

%line 158+0 output.asm





































 LDA arg
 STA HexLow.a0









 JSR HexLow
%line 159+1 output.asm
 LDY #1
 LDA (source),Y
 STA arg

%line 162+0 output.asm





































 LDA arg
 STA HexHigh.a0









 JSR HexHigh
%line 163+1 output.asm

%line 163+0 output.asm





































 LDA arg
 STA HexLow.a0









 JSR HexLow
%line 164+1 output.asm
 RTS

 DrawString:

 source set ASSIGN_LOCAL_WORD
%line 168+0 output.asm
 DrawString.a0 set DrawString.source
%line 169+1 output.asm

 arg set ASSIGN_LOCAL_BYTE
 index set ASSIGN_LOCAL_BYTE



%line 174+0 output.asm














































 LDA #(CHAR_QUOTE) % 256
 STA LCD_char.a0










 JSR LCD_char
%line 175+1 output.asm

 LDA #1
 STA index
 .loop:
 LDY index
 LDA (source),Y
 BEQ .done
 STA arg

%line 183+0 output.asm

















































 LDA arg
 STA LCD_char.a0









 JSR LCD_char
%line 184+1 output.asm
 INC index
 LDA index
 CMP #9
 BNE .loop
 .done:

%line 189+0 output.asm














































 LDA #(CHAR_QUOTE) % 256
 STA LCD_char.a0










 JSR LCD_char
%line 190+1 output.asm
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


%line 206+0 output.asm









 JSR LCD_clrscr
%line 207+1 output.asm

%line 207+0 output.asm















 JMP ..@1437.str_skip
 ..@1437.str_addr:
 FCB "RAD",0
 ..@1437.str_skip:




































 LDA #(..@1437.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@1437.str_addr) / 256
 STA LCD_print.a0+1










 JSR LCD_print
%line 208+1 output.asm


%line 209+0 output.asm






















 LDA #('5') % 256
 STA character

%line 210+1 output.asm

%line 210+0 output.asm
















 LDA #(5) % 256
 STA counter

%line 211+1 output.asm

 .loop:
 LDA #0
 STA screen_ptr
 LDA screen_ptr+1
 CLC
 ADC #CHAR_HEIGHT
 STA screen_ptr+1

%line 219+0 output.asm

















































 LDA character
 STA LCD_char.a0









 JSR LCD_char
%line 220+1 output.asm

%line 220+0 output.asm














































 LDA #(':') % 256
 STA LCD_char.a0










 JSR LCD_char
%line 221+1 output.asm

 DEC counter
 LDA counter
 CMP stack_count
 BCS .no_item
 LDY #0
 LDA (address),Y
 CMP #OBJ_FLOAT
 BNE .not_float

%line 230+0 output.asm
























































 LDA address
 STA DrawFloat.a0
 LDA address+1
 STA DrawFloat.a0+1









 JSR DrawFloat
%line 231+1 output.asm
 JMP .item_done
 .not_float:
 CMP #OBJ_STR
 BNE .not_str




%line 238+0 output.asm
























































 LDA address
 STA DrawString.a0
 LDA address+1
 STA DrawString.a0+1









 JSR DrawString
%line 239+1 output.asm
 JMP .item_done
 .not_str:
 CMP #OBJ_HEX
 BNE .not_hex




%line 246+0 output.asm
























































 LDA address
 STA DrawHex.a0
 LDA address+1
 STA DrawHex.a0+1









 JSR DrawHex
%line 247+1 output.asm
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
%line 310+0 output.asm
 ErrorMsg.a0 set ErrorMsg.error_code
%line 311+1 output.asm
 msg set ASSIGN_LOCAL_WORD
%line 311+0 output.asm
 ErrorMsg.a1 set ErrorMsg.msg
%line 312+1 output.asm


 LDY error_code
 LDA ERROR_TABLE-2,Y
 STA msg
 LDA ERROR_TABLE-1,Y
 STA msg+1

 LDA #ERROR_X
 STA screen_ptr
 LDA #ERROR_Y
 STA screen_ptr+1

%line 324+0 output.asm















 JMP ..@1612.str_skip
 ..@1612.str_addr:
 FCB "bbbbbbbbbbbb",0
 ..@1612.str_skip:






























 LDA #(..@1612.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@1612.str_addr) / 256
 STA LCD_print.a0+1










 JSR LCD_print
%line 325+1 output.asm
 LDA #ERROR_X
 STA screen_ptr
 LDA #ERROR_Y+CHAR_HEIGHT
 STA screen_ptr+1

%line 329+0 output.asm

























 LDA #($FF) % 256
 STA font_inverted

%line 330+1 output.asm

%line 330+0 output.asm












































 LDA msg
 STA LCD_print.a0
 LDA msg+1
 STA LCD_print.a0+1









 JSR LCD_print
%line 331+1 output.asm
 LDA #ERROR_X
 STA screen_ptr
 LDA #ERROR_Y+CHAR_HEIGHT*2
 STA screen_ptr+1

%line 335+0 output.asm















 JMP ..@1666.str_skip
 ..@1666.str_addr:
 FCB "bbbbbbbbbbbb",0
 ..@1666.str_skip:






























 LDA #(..@1666.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@1666.str_addr) / 256
 STA LCD_print.a0+1










 JSR LCD_print
%line 336+1 output.asm

%line 336+0 output.asm

























 LDA #(0) % 256
 STA font_inverted

%line 337+1 output.asm

 .loop:

%line 339+0 output.asm









 JSR ReadKey
%line 340+1 output.asm
 CMP #KEY_ENTER
 BNE .loop
 RTS
 RTS


%line 96+1 main.asm

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















 JMP ..@1717.str_skip
 ..@1717.str_addr:
 FCB "a               ",0
 ..@1717.str_skip:
















































 LDA #(..@1717.str_addr) % 256
 STA LCD_print.a0
 LDA #(..@1717.str_addr) / 256
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
 shift1 set ASSIGN_LOCAL_BYTE
%line 300+0 forth.asm
 shift2 set ASSIGN_LOCAL_BYTE
%line 301+1 forth.asm

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
 JMP .float_first_done
 .float_no_neg:

 CMP #CHAR_EXP
 BNE .float_not_exp

 RTS
 .float_not_exp:

 .float_first_done:

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
 BNE .dec_exp_count
 LDA #0
 STA exp_count
 .dec_exp_count:
 DEC exp_count
 JMP .float_next

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

 CMP #CHAR_EXP
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
 BEQ .exp_positive

%line 587+0 forth.asm














































































































 LDA #(new_stack_item+7) % 256
 STA BCD_Reverse.a0
 LDA #(new_stack_item+7) / 256
 STA BCD_Reverse.a0+1






























































































 LDA #(2) % 256
 STA BCD_Reverse.a1









 JSR BCD_Reverse
%line 588+1 forth.asm
 .exp_positive:

 SED

 LDA #0
 LDY exp_count
 BMI .exp_count_neg
 DEY
 BEQ .exp_count_done
 .exp_pos_loop:
 CLC
 ADC #1
 DEY
 BNE .exp_pos_loop
 JMP .exp_count_done
 .exp_count_neg:
 .exp_min_loop:
 SEC
 SBC #1
 INY
 BNE .exp_min_loop
 .exp_count_done:
 STA exp_count

 CMP #$50
 BCS .exp_count_neg2
 CLC
 ADC new_stack_item+7
 STA new_stack_item+7
 LDA #0
 ADC new_stack_item+8
 JMP .exp_count_done2
 .exp_count_neg2:
 CLC
 ADC new_stack_item+7
 STA new_stack_item+7
 LDA #0
 SBC new_stack_item+8
 .exp_count_done2:
 STA new_stack_item+8
 CLD

 LDA #0
 LDY new_stack_item+8
 CPY #$50
 BCC .exp_positive2

%line 634+0 forth.asm














































































































 LDA #(new_stack_item+7) % 256
 STA BCD_Reverse.a0
 LDA #(new_stack_item+7) / 256
 STA BCD_Reverse.a0+1






























































































 LDA #(2) % 256
 STA BCD_Reverse.a1









 JSR BCD_Reverse
%line 635+1 forth.asm
 LDA #$FF
 .exp_positive2:
 STA exp_negative

 LDA new_stack_item+8
 CMP #$10
 BNE .no_exp_overflow

 RTS
 .no_exp_overflow:

 LDA exp_negative
 BEQ .exp_no_neg_bit
 LDA new_stack_item+8
 ORA #E_SIGN_BIT
 STA new_stack_item+8
 .exp_no_neg_bit:


 LDA negative
 BEQ .positive
 LDA new_stack_item+8
 ORA #SIGN_BIT
 STA new_stack_item+8
 .positive:


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
%line 722+0 forth.asm
 ExecToken.a0 set ExecToken.token
 flags set ASSIGN_LOCAL_BYTE
 ExecToken.a1 set ExecToken.flags
%line 723+1 forth.asm
 temp set ASSIGN_LOCAL_BYTE
%line 723+0 forth.asm
 ExecToken.a2 set ExecToken.temp
%line 724+1 forth.asm
 address set ASSIGN_LOCAL_WORD
%line 724+0 forth.asm
 ExecToken.a3 set ExecToken.address
%line 725+1 forth.asm



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


%line 97+1 main.asm




 BEGIN_FUNC set main
%line 101+0 main.asm
 main:
%line 103+1 main.asm
 dest set ASSIGN_LOCAL_WORD
 arg set ASSIGN_LOCAL_BYTE





 LDX #$2F
 TXS


%line 113+0 main.asm









 JSR setup
%line 114+1 main.asm


%line 115+0 main.asm









 JSR tests
%line 116+1 main.asm

 .input_loop:

%line 118+0 main.asm









 JSR DrawStack
%line 119+1 main.asm

%line 119+0 main.asm









 JSR ReadLine
%line 120+1 main.asm

 .process_loop:

%line 122+0 main.asm









 JSR LineWord
%line 123+1 main.asm
 LDA new_word_len
 BEQ .input_loop


%line 126+0 main.asm









 JSR FindWord
%line 127+1 main.asm
 LDA ret_val
 BEQ .not_found



%line 131+0 main.asm














































 LDA ret_val
 STA ExecToken.a0









 JSR ExecToken
%line 132+1 main.asm
 LDA ret_val
 BEQ .no_exec_error
 STA arg

%line 135+0 main.asm





































 LDA arg
 STA ErrorMsg.a0









 JSR ErrorMsg
%line 136+1 main.asm
 JMP .input_loop
 .no_exec_error:
 JMP .process_loop
 .not_found:


%line 141+0 main.asm









 JSR CheckData
%line 142+1 main.asm
 LDA new_stack_item
 CMP #OBJ_ERROR
 BNE .input_good

%line 145+0 main.asm








































 LDA #(ERROR_INPUT) % 256
 STA ErrorMsg.a0










 JSR ErrorMsg
%line 146+1 main.asm
 JMP .input_loop
 .input_good:


 LDA #STACK_SIZE-1
 CMP stack_count
 BCS .no_overflow

%line 153+0 main.asm








































 LDA #(ERROR_STACK_OVERFLOW) % 256
 STA ErrorMsg.a0










 JSR ErrorMsg
%line 154+1 main.asm
 JMP .input_loop
 .no_overflow:


 JSR StackAddItem

 STX dest
 LDA #0
 STA dest+1

%line 163+0 main.asm












































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
%line 164+1 main.asm

 JMP .process_loop

 RTS
 code_end:

%line 110+1 nasm.asm


