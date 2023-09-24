#!/bin/bash

for file in "const.asm" "zp.asm" "globals.asm"; do
    cp ../../src/$file src/
done


