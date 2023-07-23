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

    ;General
    ;=======
    TODO: add aux stack check to semi colon
	TODO: github readme
    TODO: checking - p110 in Handbook of Floating Point Arithmetic
    TODO: copyright
    TODO: double check not relying on flags from BCD which are not valid for NMOS
    TODO: - N and V invalid. Z also invalid if roll over from addition. check for BNE/BEQ
    TODO: - modify emulator?
    TODO: - math.asm, words.asm, word_stubs.asm
    TODO: remove trailing zeroes?
    TODO: draw smart hex differently? M$1234
    TODO: double check list on webpage
    TODO: better error messages if room left
    TODO: merge system.asm
    TODO: reuse FP registers to replace temp variables in other functions
    TODO: prevent WORDS from being inserted into word
    TODO: capitalize comments. done: main, emu6507, forth, math, words
    TODO: until test in keys/ stopped working after replacing PLA with stack_X: WRONG TYPE
    TODO: macro for reg usage as locals

    ;Size related - only if necessary
    ;================================
    TODO: LDA ret_val, BNE error_exit could be smaller in main.asm and forth.asm
    TODO: compare to error_sub in main.asm
    TODO: see if part of ' can be combined w main loop

    ;Necessary words
    ;===============
    TODO: GRAPH
    TODO: XMAX, YMAX
    TODO: ACOS
    TODO: ASIN
    TODO: ATAN
    TODO: LN
    TODO: E^
    TODO: MOD
    TODO: ^

    ;Optional words
    ;==============
    TODO: +, *, = for strings
    TODO: some type of MID
    TODO: TYPE of stack item
    TODO: JUMP to address
    TODO: WHILE
    TODO: REPEAT
    TODO: FLOAT
    TODO: HEX
    TODO: DEC
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
    TODO: see list in words.asm
    TODO: [ ] and LIT
    TODO: CHR
    TODO: SEE

    ;Known bugs from website
    ;=======================
    TODO: limit return stack
    TODO: check if IF and DO have closing structures

    ;Finished - only what might be forgotten and waste time redoing
    ;==============================================================
    DONE:
