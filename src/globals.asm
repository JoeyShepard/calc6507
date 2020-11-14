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

	ORG $800
	dict_end:
	
	;extra RAM in RIOT - not preserved by backup battery
	TODO: what else will fit in RIOT RAM?
	
	;Math
	TODO: move to zero page if room
	BYTE math_lo
	BYTE math_hi
	BYTE math_a
	BYTE math_b
	BYTE math_c
	BYTE math_d
	BYTE math_signs
	BYTE math_sticky
	
	;Splitting input into words
	new_word_len:		DFS 1
	new_word_buff:		DFS WORD_MAX_SIZE
	new_stack_item:		DFS OBJ_SIZE+GR_OFFSET
	
	ORG 880
	