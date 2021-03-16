;Macros
;======
	include macros.asm
	include optimizer_nmos.asm

;Notes
;=====
;GPIO
	;RIOT A
		;2 latch enables
		;1 RX
		;1 low battery indicator from Vreg
		;1 EEPROM bank
		;0 EEPROM lock
			;built into EEPROM
		;1 keyboard buffer OE (74HCT244)
			;can't be driven from latch!
		;1 read ON button?
			;should be easy if button is grounding pull-up
		;*1 free
	;RIOT B
		;8 LCD data bus to latch 2
		;also, 8 keyboard inputs
			;inputs are pulled up, so just need diodes
	;Latch 1
		;1 LCD DI
		;1 LCD E
		;1 LCD CS1
		;1 LCD CS2
		;1 LCD RST? may not be necessary
		;1 power transistor
			;must be driven by latch for MOSFET for voltage level
			TODO: latch not Z stated at beginning though! pull-up and ON grounds?
		;1 TX
			;4v min output, so must drive through latch
			;alternative is level shift transistor on RIOT
		;*1 free
	;Latch 2
		;8 LCD data bus out
	;Chips to add:
		;keyboard buffer
		;power transistor
	
	TODO: drive RDY with 6532 interrupt
	TODO: one output of latch to GAL to diable RAM writes for shutdown? may not be enough
	TODO: separate engine and table for 16 bit forth?
	TODO: more comments

;Unlimited lines per page in listing
	PAGE 0


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
	TODO: special handling of ORG for new version of NASM breaks this
	R_STACK_ADDRESS = $100+R_STACK_SIZE
	ORG R_STACK_ADDRESS
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
	include cordic.asm
	include output.asm
	include aux_stack.asm
	include forth.asm
	include words.asm
	include word_stubs.asm
	
;Main function
;=============
	FUNC main, begin
		VARS
			WORD dest
			BYTE arg,type
		END
		
		TODO: copyright
		TODO: easy to add calculated jumps to optimizer - just need to mark which can jump to
		TODO: double check not relying on flags from BCD which are not valid for NMOS
		
		CALL setup
		CALL tests
		;CALL file_tests
		CALL stats
		CALL GfxSetup
		
		CALL InitForth
		
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
				
				TODO: need to copy obj_address to ret_address in new design?
				CALL FindWord
				LDA ret_val
				BEQ .word_not_found
					
					;Word found
					LDA mode
					CMP #MODE_IMMEDIATE
					BNE .compile_word
						
						;Immediate mode - insert word into temp thread and execute
						.immediate:
						LDY #TOKEN_BREAK
						LDA ret_val
						STA temp_thread
						CMP #TOKEN_SECONDARY
						BEQ .insert_address
						CMP #TOKEN_VAR_THREAD
						BEQ .insert_address
							STY temp_thread+1
							JMP .jump_thread
						.insert_address:
						;Secondaries and variables need address in stream
						CLC
						LDA obj_address
						ADC #3
						STA temp_thread+1
						LDA obj_address+1
						ADC #0
						STA temp_thread+2
						STY temp_thread+3
						.jump_thread:
						LDA #temp_thread % 256
						STA exec_ptr
						LDA #temp_thread / 256
						STA exec_ptr+1
						JMP ExecThread
					.compile_word:
					
					;Compile mode
					LDA ret_val
					TAY
					LDA JUMP_TABLE-2,Y
					TODO: sure ret_address isnt needed later?
					STA ret_address
					LDA JUMP_TABLE-1,Y
					STA ret_address+1
					LDY #1
					LDA (ret_address),Y
					AND #MODE_IMMEDIATE
					BNE .immediate
					;Not immediate so compile
					LDA ret_val
					CALL WriteToken
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
				
					;Immediate mode - add value to stack
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
				TODO: handle error
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
	