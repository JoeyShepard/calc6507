@echo off
del resized\* /Q

copy raw\* resized\*

REM magick mogrify -scale 384x192 resized\*
 magick mogrify -scale 256x128 resized\*