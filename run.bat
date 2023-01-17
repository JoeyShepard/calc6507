@echo off
title 6507 Calculator
echo.
for /f %%i in ('time /T') do set datetime=%%i

echo [%datetime%] Running optimizer...
cd src
REM echo Optimizer start time %time% REM 0.15 seconds
..\opt-mini.py main.asm
REM echo Optimizer end time   %time%
move processed.asm ../ > nul
move debug.txt ../ > nul
cd ..
type src\mem_template.asm >> processed.asm

echo Assembling...
REM P - write macro processor output
REM G - ???
REM U - case-sensitive operation
REM L - listing to file
REM g - write debug info
REM q - quiet mode
..\..\bin\asw processed.asm -P -G -U -L -g -q -cpu 6502 > asm.txt 2>&1
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

echo Cleaning up...
del asm.txt
del processed.hex
del processed.i
del processed.p

