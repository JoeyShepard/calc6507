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
	include emu.asm
	include const.asm

;Notes
;=====
TODO: checking - p110 in Handbook of Floating Point Arithmetic


;Main code
;=========
	
DEBUG_MODE set "off"
		
	;Reset vector
	;ORG $FFFC
	ORG $1FFC
	FDB main
		
	
;Variables in zero page
;======================
	ORG $0000
	
	;Locals usage
LOCALS_BEGIN set	$0
LOCALS_END set		$1F
	
	ORG $20
	;For macros
	BYTE dummy
	WORD ret_val
	
	;Temp address for variables
	WORD ret_address
	
	;Output
	WORD screen_ptr
	
	;Forth
	WORD dict_ptr
	WORD new_dict_ptr
	WORD dict_save
	WORD exec_ptr
	TODO: share with ret_address?
	WORD obj_address
	
	;Don't need header byte, +3 for guard, round, sticky, +1 for exp sign
	R0: DFS OBJ_SIZE-1+4
	R1: DFS OBJ_SIZE-1+4
	R2: DFS OBJ_SIZE-1+4
	R3: DFS OBJ_SIZE-1+4
	R4: DFS OBJ_SIZE-1+4
	R5: DFS OBJ_SIZE-1+4
	R6: DFS OBJ_SIZE-1+4
	R7: DFS OBJ_SIZE-1+4
	Regs_end:
		
	
;Variables in main RAM
;=====================
	ORG $130
	;Must come after include const.asm for constants
	include globals.asm


;Functions in ROM
;================
	ORG $C000
	include tests.asm
	include stats.asm
	
	ORG $900
	code_begin:
	JMP main	;static entry address for emulator
	
	;504 bytes 0_0
	font_table:
	include font_8x8.asm
	
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
		LDX #$2F
		TXS
		
		CALL setup
		CALL tests
		CALL stats
		
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
				LDA new_stack_item
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
					CALL MemCopy, #new_stack_item, dest, #OBJ_SIZE
					JMP .process_loop
				.compile_value:
				
				;Compile mode - compile value
				LDA new_stack_item
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
				LDA new_stack_item,Y
				STA (dict_ptr),Y
				CPY #8
				BNE .loop
				
			;Adjust dict pointer
			MOV.W new_dict_ptr,dict_ptr
			JMP .process_loop
	END
	
	
	code_end:
	