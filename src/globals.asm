;Global variables in RAM
;=======================
	TODO: move these to zp if room
	global_error:		DFS 1
	
	;Line input
	input_buff_begin:	DFS 1
	input_buff_end:		DFS 1
	input_buff:			DFS BUFF_SIZE
	
	;Font
	BYTE font_inverted
	
	;Forth
	BYTE stack_count
	BYTE mode
		
	;Tests
	WORD test_count
	
	;Rest of RAM for user dictionary
	dict_begin:

	TODO: magical number
	ORG $800
	dict_end:
	
	RIOT_mem_begin:
	;extra RAM in RIOT - not preserved by backup battery
	TODO: what else will fit in RIOT RAM?
	
	;Temporary Forth thread
	temp_thread:		DFS 4
	
	;Math
	TODO: move to zero page if room
	TODO: rename these to something useful
	BYTE math_lo
	BYTE math_hi
	BYTE math_a
	BYTE math_b
	BYTE math_c
	TODO: double check that these are all used
	BYTE math_d
	
	BYTE math_signs
	BYTE math_sticky
	BYTE math_max
	
	TODO: all used?
	;Locals for functions - wasteful but RIOT mem not used otherwise
	BYTE shift_counter
	BYTE CORDIC_compare
	BYTE CORDIC_sign
	BYTE CORDIC_halve
	BYTE CORDIC_loop_inner
	BYTE CORDIC_loop_outer
	BYTE CORDIC_shift_count
	BYTE CORDIC_sign_temp
	BYTE CORDIC_end_sign
	
	;Splitting input into words
	new_word_len:		DFS 1
	new_word_buff:		DFS WORD_MAX_SIZE
	;new_stack_item:		DFS OBJ_SIZE+GR_OFFSET
	
	AUX_STACK:
		DFS AUX_STACK_SIZE
		BYTE aux_stack_ptr
		BYTE aux_stack_count
		BYTE aux_word_counter
	
	RIOT_mem_end:
	
	TODO: magical number
	ORG $880
	