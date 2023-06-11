#!/bin/bash

starttime=$(date +"%T")

echo "[$starttime] Running optimizer..."
cd src
../opt-mini.py main.asm
mv processed.asm ../
mv debug.txt ../
mv debug.html ../
cd ..
cat src/mem_template.asm >> processed.asm

echo Assembling...
#P - write macro processor output
#G - ???
#U - case-sensitive operation
#L - listing to file
#g - write debug info
#q - quiet mode
asl processed.asm -P -G -U -L -g -q -cpu 6502 > asm.txt
./remove-escape.py asm.txt
echo
echo Generating hex file...
p2hex processed.p -F Intel -l 32 -r 0x0000-0xFFFF > hex.txt
cp processed.hex emu.hex
echo :02FFFC000009BF >> emu.hex

echo Copying...
emu_path=~/"projects/6502/emu6502/local-copy/"
cp processed.lst "${emu_path}/listing.lst"
cp emu.hex "${emu_path}/prog.hex"
cp input.txt "${emu_path}/input.txt"
cp keys.txt "${emu_path}/keys.txt"

echo Cleaning up...
rm asm.txt
rm processed.hex
rm processed.i
rm processed.p

