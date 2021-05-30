@echo off

"C:\Program Files (x86)\GnuWin32\bin\bc" -l atan.txt>temp.txt
python formatter.py
REM output.txt
