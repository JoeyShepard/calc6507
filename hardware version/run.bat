@echo off
title 6507 Calculator - Hardware test
echo.
for /f %%i in ('time /T') do set datetime=%%i
echo [%datetime%] Assembling...

REM copy of nasm.asm from parent directory
copy ..\src\nasm.asm nasm.asm > nul

"C:\Program Files\nasm\nasm" --no-line -e -Z main.err -l main.lst nasm.asm > main.i
type main.err
echo.
del processed.asm
python "..\..\..\projects\6502 Optimizer\NASM based\main.py" main.i
type mem_template.asm >> processed.asm
echo.
echo Re-assembling...
..\..\..\AS\bin\asw processed.asm -P -G -U -L -g -q -cpu 6502 > asm.txt
python "remove escape.py" asm.txt
echo Generating hex file...
..\..\..\AS\bin\p2hex processed.p -F Intel -l 32 -r $0000-$FFFF > hex.txt
copy processed.hex emu.hex > nul
echo :02FFFC000009BF >> emu.hex
echo Copying...
copy processed.lst "..\..\..\projects\6502 emu\main\listing.lst" > nul
REM copy processed.hex "..\..\..\projects\6502 emu\main\prog.hex" > nul
copy emu.hex "..\..\..\projects\6502 emu\main\prog.hex" > nul
break > "..\..\..\projects\6502 emu\main\input.txt" > nul
break > "..\..\..\projects\6502 emu\main\keys.txt" > nul

REM copy processed.hex "\\DESKTOP-P9O36J4\compile share\eeprom.hex" > nul
REM echo processed.hex "\\DESKTOP-P9O36J4\compile share\eeprom_%TIME:~0,2%.%TIME:~3,2%.%TIME:~6,2%.hex"
del "\\DESKTOP-P9O36J4\compile share\eeprom_*.hex"
copy processed.hex "\\DESKTOP-P9O36J4\compile share\eeprom_%TIME:~0,2%.%TIME:~3,2%.%TIME:~6,2%.hex" > nul
echo.