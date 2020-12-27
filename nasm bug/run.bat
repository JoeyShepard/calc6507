type main.asm
"C:\Program Files\nasm\nasm" --v
"C:\Program Files\nasm\nasm" -E -Z main.err -l main.lst main.asm > main.i
type main.err
"C:\Program Files\nasm_test\nasm" --v
"C:\Program Files\nasm_test\nasm" -E -Z main.err -l main.lst main.asm > main.i
type main.err