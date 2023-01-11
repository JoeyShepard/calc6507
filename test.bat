@echo off
title opt-mini test
echo.
for /f %%i in ('time /T') do set datetime=%%i
echo [%datetime%] Testing...
cd src
echo Optimizer start time %time%
..\opt-mini.py main.asm
echo Optimizer end time   %time%
move debug.txt ..
move processed.asm ..
cd ..