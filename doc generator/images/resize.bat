@echo off
del "C:\Users\druzy\Google Drive\Electronics\6502\NASM\6507 calculator\doc generator\images\resized\*" /Q

echo Copying images...
copy "C:\Users\druzy\Google Drive\Electronics\6502\NASM\6507 calculator\doc generator\images\raw\*" "C:\Users\druzy\Google Drive\Electronics\6502\NASM\6507 calculator\doc generator\images\resized\*"

REM magick mogrify -scale 384x192 "C:\Users\druzy\Google Drive\Electronics\6502\NASM\6507 calculator\doc generator\images\resized\*"

echo Resizing images...
magick mogrify -scale 256x128 "C:\Users\druzy\Google Drive\Electronics\6502\NASM\6507 calculator\doc generator\images\resized\*"

