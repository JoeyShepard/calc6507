;Space for general TODO items
;Cleaner to keep here than in main.asm

    ;Plan
    ;====
    ;Fix errors
    ;Implement necessary words
    ;Implement optional words as space allows

    ;To fix
    ;======
    TODO: out of memory error then gives input error
    TODO: out of memory error also seems to freeze with too much keys.txt input. retry with halt in error msg enabled
    TODO: DEG appears to be wrong
    TODO: easy to add calculated jumps to optimizer - just need to mark which can jump to
    TODO: STO handled correctly in words? should be. seems VAR is what I remember not working
    TODO: optimizer should identify unreachable code that passes variables or uses locals
        ;Should be fine if treated as if jumped from main

    ;General
    ;=======
    TODO: replace calculated jump with JMP (addr)
    TODO: use registers for text input also somehow? no bc could be used by words
    TODO: add aux stack check to semi colon
    TODO: var in word? causes double input error
	TODO: github readme
    TODO: checking - p110 in Handbook of Floating Point Arithmetic
    TODO: copyright
    TODO: double check not relying on flags from BCD which are not valid for NMOS
    TODO: remove trailing zeroes?
    TODO: draw smart hex differently? M$1234
    TODO: double check list on webpage
    TODO: LDA ret_val, BNE error_exit could be smaller
    TODO: compare to error_sub in main.asm
    TODO: use registers instead of optimized mem in forth.asm where possible
    TODO: better error messages if room left

    ;Necessary words
    ;===============
    TODO: DEL including garbage collection
    TODO: WORD browser
    TODO: GRAPH
    TODO: XMAX, YMAX
    TODO: SEE
    TODO: ACOS
    TODO: ASIN
    TODO: ATAN
    TODO: LN
    TODO: E^
    TODO: MOD
    TODO: ^

    ;Optional words
    ;==============
    TODO: + for strings
    TODO: * for strings
    TODO: TYPE of stack item
    TODO: JUMP to address
    TODO: WHILE
    TODO: REPEAT
    TODO: FLOAT
    TODO: HEX
    TODO: RAW - convert smart hex to raw
    TODO: +LOOP
    TODO: STATE
    TODO: COMPILE
    TODO: IMMED
    TODO: DEPTH
    TODO: BETWEEN
    TODO: >=
    TODO: <=
    TODO: RESET

    ;Known bugs from website
    ;=======================
    TODO: limit return stack
    TODO: VAR in words
    TODO: check if IF and DO have closing structures
    TODO: unknown word in word causes double error message

