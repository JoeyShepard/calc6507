;Global variables in RAM
;=======================
	global_error:		DFS 1
	
	;Line input
	input_buff_begin:	DFS 1
	input_buff_end:		DFS 1
	input_buff:			DFS BUFF_SIZE
	
	;Splitting input into words
	new_word_len:		DFS 1
	new_word_buff:		DFS WORD_MAX_SIZE
	new_stack_item:		DFS 9
	
	;Font
	BYTE font_inverted
	
	;Forth
	BYTE stack_count
	BYTE mode
	
	;Math
	TODO: move to zero page if room
	BYTE math_a
	BYTE math_b
	BYTE math_c
	BYTE math_d
	BYTE math_e
	BYTE math_f
	BYTE math_signs
	BYTE math_sticky
	
	;Tests
	BYTE test_count
	
	;Rest of RAM for user dictionary
	dict_begin:

	TODO: what about extra 128 bytes in RIOT? not preserved by backup battery
	ORG $800
	dict_end:
	