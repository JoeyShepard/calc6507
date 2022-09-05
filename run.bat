@echo off
title 6507 Calculator
echo.
for /f %%i in ('time /T') do set datetime=%%i
echo [%datetime%] Assembling...
cd src

..\vm.py main.asm ..\combined.asm
move vm-debug.html ..\vm-debug.html > nul

"C:\Program Files\nasm\nasm" --no-line -e -Z main.err -l main.lst nasm.asm > main.i
move main.i ..\main.i > nul
move main.err ..\main.err > nul
cd ..
type main.err
echo.
del processed.asm
python "..\..\..\projects\6502 Optimizer\NASM based\main.py" main.i
type src\mem_template.asm >> processed.asm
echo.

echo Re-assembling...
..\..\bin\asw processed.asm -P -G -U -L -g -q -cpu 6502 > asm.txt
python "remove escape.py" asm.txt
echo Generating hex file...
..\..\bin\p2hex processed.p -F Intel -l 32 -r $0000-$FFFF > hex.txt
copy processed.hex emu.hex > nul
echo :02FFFC000009BF >> emu.hex

echo Copying...
copy processed.lst "..\..\..\projects\6502 emu\local copy\listing.lst" > nul
REM copy processed.hex "..\..\..\projects\6502 emu\local copy\prog.hex" > nul
copy emu.hex "..\..\..\projects\6502 emu\local copy\prog.hex" > nul
REM copy emu.hex "..\..\..\projects\6502 emu\node.js\prog.hex" > nul
copy input.txt "..\..\..\projects\6502 emu\local copy\input.txt" > nul
REM break > "..\..\..\projects\6502 emu\local copy\keys.txt"
copy keys.txt "..\..\..\projects\6502 emu\local copy\keys.txt" > nul
echo.