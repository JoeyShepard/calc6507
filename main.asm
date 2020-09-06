;Notes
;=====
;
;GPIO
;	8 outputs for LCD data lines and keyboard
;	1 output for LCD E
;	1 output for latch
;		4 or 5 for rst, rs, cs1, cs2, and maybe r/w
;		1-3 for EEPROM bank
;		1 for power transistor
;	1 output for Tx <== latched? speed may not matter
;	1 input for Rx
;	5 inputs for keyboard
;***1 PIN SHORT!***

;Compare to bc for rounding



;Constants
;=========
	include emu.asm
	include const.asm


;Main code
;=========
	;Unlimited lines per page in listing
	PAGE 0
	
DEBUG_MODE set "off"
	
	;Macros at very beginning
	include macros.asm
	include optimizer_nmos.asm
	
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
	
	;Output
	WORD screen_ptr
	
	R0: DFS OBJ_SIZE
	R1: DFS OBJ_SIZE
	R2: DFS OBJ_SIZE
	R3: DFS OBJ_SIZE
	R4: DFS OBJ_SIZE
	R5: DFS OBJ_SIZE
	R6: DFS OBJ_SIZE
	R7: DFS OBJ_SIZE
	
STACK_END:
	
	
;Variables in main RAM
;=====================
	ORG $130
	;Must come after include const.asm for constants
	include globals.asm


;Functions in ROM
;================
	ORG $C000
	include tests.asm
	
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
			BYTE arg
		END
		
		;Only use bottom 48 bytes of stack
		;May need a lot more for R stack
		;Must come before any JSR
		LDX #$2F
		TXS
		
		CALL setup
		
		CALL tests
		
		.input_loop:
			CALL DrawStack
			CALL ReadLine
			
			.process_loop:
				CALL LineWord
				LDA new_word_len
				BEQ .input_loop
			
				CALL FindWord
				LDA ret_val
				BEQ .not_found
				
					;Word found
					CALL ExecToken,ret_val
					LDA ret_val
					BEQ .no_exec_error
						STA arg
						CALL ErrorMsg,arg
						JMP .input_loop
					.no_exec_error:
					JMP .process_loop
				.not_found:
				
				;Word not found, so check if data
				CALL CheckData
				LDA new_stack_item
				CMP #OBJ_ERROR
				BNE .input_good
					CALL ErrorMsg,#ERROR_INPUT
					JMP .input_loop
				.input_good:
				
				;Check stack size
				LDA #STACK_SIZE-1
				CMP stack_count
				BCS .no_overflow
					CALL ErrorMsg,#ERROR_STACK_OVERFLOW
					JMP .input_loop
				.no_overflow:
				
				;add new data to stack
				JSR StackAddItem
				
				STX dest
				LDA #0
				STA dest+1
				CALL MemCopy, #new_stack_item, dest, #OBJ_SIZE
				
				JMP .process_loop
				
	END
	code_end:
	