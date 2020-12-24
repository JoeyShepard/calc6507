;Notes
;=====
;
;GPIO
;	8 outputs for LCD data lines and keyboard
;	1 output for LCD E
;	1 output for latch
;		4 or 5 for rst, rs, cs1, cs2, and r/w (NEEDED)
;		1-3 for EEPROM bank
;		1 for power transistor
;	1 output for Tx <== latched? speed may not matter
;	1 input for Rx
;	5 inputs for keyboard
;***1 PIN SHORT!***

;Unlimited lines per page in listing
	PAGE 0
	
;Macros
;======
	include macros.asm
	include optimizer_nmos.asm

;Constants
;=========
	include const.asm
	include emu.asm
	
;Notes
;=====
TODO: checking - p110 in Handbook of Floating Point Arithmetic


;Main code
;=========
	
DEBUG_MODE set "off"
		
	;Reset vector
	ORG RESET_VECTOR
	;ORG $1FFC
	FDB main
		
	
;Variables in zero page
;======================
	ORG $0000
	
	;Locals usage
LOCALS_BEGIN set	$0
LOCALS_END set		$1F
	
	ORG $20
	;For macros
	WORD dummy
	WORD ret_val
	
	;Temp address for variables
	WORD ret_address
	
	;Output
	WORD screen_ptr
	TODO: remove after debugging done
	WORD font_ptr
	
	;Forth
	WORD dict_ptr
	WORD new_dict_ptr
	WORD dict_save
	WORD exec_ptr
	TODO: share with ret_address?
	WORD obj_address
	
	;Math
	WORD math_ptr1
	WORD math_ptr2
	
	;Don't need header byte, +1 for guard and round, +1 for exp sign
	R0: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R1: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R2: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R3: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R4: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R5: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R6: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R7: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R_ans:	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	
	;reg before R_ans in case double wide reg needed
	;+3 since only need 6 of 9 bytes 
	R_ans_wide = R7+3
	
	Regs_end:
		
	
;Variables in main RAM
;=====================
	ORG $130
	;Must come after include const.asm for constants
	include globals.asm


;Functions in ROM
;================
	;ORG $C000
	ORG $D000
	;should be visible to tests below which overflow $C000
	include debug.asm
	
	TODO: remove after debugging
	include font_debug.asm
	
	ORG $8900	;RAM + ROM size
	;overlaps with video memory, no video output
	;but banked out after all tests pass
	include tests.asm
	include file_tests.asm
	include stats.asm
	
	ORG $900
	code_begin:
	JMP main	;static entry address for emulator
	
	font_table:
	include font_5x8.asm
	include font_custom.asm
	
	;include calc6507.asm
	include emu6507.asm
	
	include system.asm
	include math.asm
	include output.asm
	include forth.asm
	include words.asm
	
;Main function
;=============
	FUNC main, begin
		VARS
			WORD dest
			BYTE arg,type
		END
		
		;Only use bottom 48 bytes of stack
		;May need a lot more for R stack
		;Must come before any JSR
		TODO: expand this - will need a lot of stack space
		LDX #$2F
		TXS
		
		TODO: copyright
		TODO: number entry wraps if backspace past beginning - cant reproduce!
		TODO: easy to add calculated jumps to optimizer - just need to mark which can jump to
		TODO: tagging stack maybe not good idea - save first address then error calls function to clear r stack
		
		CALL setup
		CALL tests
		;CALL file_tests
		CALL stats
		CALL gfx_setup
		
		;Reset data stack pointer
		LDX #0
		
		.input_loop:
			;Colon definitions must fit on one line
			LDA mode
			CMP #MODE_IMMEDIATE
			BEQ .mode_good
				LDA #MODE_IMMEDIATE
				STA mode
				LDA #ERROR_INPUT
				JMP .error_sub
			.mode_good:
		
			;Reset dict_ptr in case anything went wrong below
			MOV.W dict_save,dict_ptr
			
			CALL DrawStack
			CALL ReadLine
			
			.process_loop:
				
				CALL LineWord
				LDA ret_val
				BEQ .no_word_error
					JMP .error_sub
				.no_word_error:
				LDA new_word_len
				BEQ .input_loop
				
				CALL FindWord
				LDA ret_val
				BEQ .word_not_found
					
					;Word found
					LDA mode
					CMP #MODE_IMMEDIATE
					BNE .compile_word
					
						;Immediate mode - execute word
						LDA ret_val
						CALL ExecToken
						LDA ret_val
						BEQ .no_exec_error
							JMP .error_sub
						.no_exec_error:
						JMP .process_loop
					.compile_word:
					
					;Compile mode - compile word
					LDA ret_val
					JSR WriteToken
					LDA ret_val
					BEQ .no_compile_error
						JMP .error_sub
					.no_compile_error:
					JMP .process_loop
				.word_not_found:
				
				;Word not found, so check if data
				CALL CheckData
				LDA R_ans
				CMP #OBJ_ERROR
				BNE .input_good
					LDA #ERROR_INPUT
					JMP .error_sub
				.input_good:
				
				LDA mode
				CMP #MODE_IMMEDIATE
				BNE .compile_value
				
					;Immediate mode - add to stack
					LDA #STACK_SIZE-1
					CMP stack_count
					BCS .no_overflow
						LDA #ERROR_STACK_OVERFLOW
						JMP .error_sub
					.no_overflow:
					
					JSR StackAddItem
					
					STX dest
					LDA #0
					STA dest+1
					CALL MemCopy, #R_ans, dest, #OBJ_SIZE
					JMP .process_loop
				.compile_value:
				
				;Compile mode - compile value
				LDA R_ans
				;float?
				LDY #TOKEN_FLOAT
				CMP #OBJ_FLOAT
				BEQ .value_compile
				;hex?
				LDY #TOKEN_HEX
				CMP #OBJ_HEX
				BEQ .value_compile
				;string?
				LDY #TOKEN_STRING
				CMP #OBJ_STR
				BEQ .value_compile
				
				;unknown type - something is very wrong
				halt
					
				JMP .process_loop
				
		.error_sub:
			CALL ErrorMsg
			JMP .input_loop
			
		.value_compile:
			STY type
			LDA #OBJ_SIZE
			JSR AllocMem
			LDA ret_val
			BEQ .float_alloc_good
				JMP .error_sub
			.float_alloc_good:
			LDA type
			LDY #0
			STA (dict_ptr),Y
			
			TODO: smaller than calling MemCopy here?
			.loop:
				INY
				LDA R_ans,Y
				STA (dict_ptr),Y
				CPY #8
				BNE .loop
				
			;Adjust dict pointer
			MOV.W new_dict_ptr,dict_ptr
			JMP .process_loop
	END
	
	
	code_end:
	