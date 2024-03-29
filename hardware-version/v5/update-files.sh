#!/bin/bash

declare -a files=( \
    "const.asm" "zp.asm" "globals.asm" \
    "system.asm" "math.asm" "cordic.asm" "output.asm" \
    "error.asm" "aux_stack.asm" "forth.asm" "words.asm" \
    "word_stubs.asm" "forth_loop.asm" \
    "bank1.asm" "bank2.asm" "bank4.asm" "bank_fixed.asm" )


for file in ${files[@]}; do
    cp ../../src/$file src/
done


