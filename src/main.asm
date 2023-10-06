;Main file
;=========
;Note different for emulated and hardware versions!

;Unlimited lines per page in listing
	PAGE 0

;Macros
;======
	include macros.asm
	
;General TODO items stored in separate file. Included here so todo.py can find it.
    include todo.asm

;Constants
;=========
	include const.asm
	include emu.asm
	
;Main code
;=========

	;Reset vector
	ORG RESET_VECTOR
	;ORG $1FFC
	FDB main
		
;Variables in zero page
;======================
	ORG $0000
	include zp.asm
	
;Variables in main RAM
;=====================
    ORG HW_STACK_BEGIN+R_STACK_SIZE
	include globals.asm

	
;Functions in ROM
;================
	;ORG $C000
	ORG $D000
	;Should be visible to tests below which overflow $C000
	include debug.asm
	
	ORG $8900	;RAM + ROM size
	;Overlaps with video memory, no video output
	;but banked out after all tests pass
	include tests.asm
	include file_tests.asm
	TODO: remove or add to emu6507
	include stats.asm
	
	ORG $900
	code_begin:
	JMP main	;Static entry address for emulator
	
	font_table:
	include font_5x8.asm
	include font_custom.asm
	
	;include calc6507.asm
	include emu6507.asm
	
	include system.asm
	include math.asm
	include cordic.asm
	include output.asm
	include error.asm
	include aux_stack.asm
	include forth.asm
	include words.asm
	include word_stubs.asm
    include forth_loop.asm
    include bank1.asm
    include bank2.asm
    include bank4.asm
    include bank_fixed.asm

;Main function
;=============
	FUNC main BEGIN

		CALL setup
		CALL tests
		;CALL file_tests
		TODO: remove
		CALL stats
		CALL GfxSetup
	
		;Jump to ForthLoop function and never return
        ;(Needs to be CALL for optimizer)
        CALL ForthLoop
	END

;Insertion point for string literals
;(should come after all instances of CALL)
;=========================================
	STRING_LITERALS

	code_end:
	
