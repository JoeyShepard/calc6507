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
	
	