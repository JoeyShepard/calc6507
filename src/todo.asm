;Space for general TODO items
;Cleaner to keep here than in main.asm

    ;Plan
    ;====
    ;Fix errors
    ;Implement necessary words
    ;Implement optional words as space allows

    ;General
    ;=======
	TODO: github readme
    TODO: checking - p110 in Handbook of Floating Point Arithmetic
    TODO: copyright
    TODO: double check not relying on flags from BCD which are not valid for NMOS
    TODO: - N and V invalid. Z also invalid if roll over from addition. check for BNE/BEQ
    TODO: - modify emulator?
    TODO: - math.asm, words.asm, word_stubs.asm
    TODO: remove trailing zeroes?
    TODO: double check list on webpage
    TODO: merge system.asm

    ;Optional
    ;========
    TODO: draw smart hex differently? M$1234
    TODO: better error messages if room left - Unkown in addition to input error

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
    TODO: limit return stack - easy in EXEC but need to determine other usage

    ;Finished - only what might be forgotten and waste time redoing
    ;==============================================================
    DONE: capitalize comments
