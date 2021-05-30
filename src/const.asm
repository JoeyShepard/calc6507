;Constants
;=========
	
	;Screen
	SCREEN_ADDRESS = 		$4000
	SCREEN_WIDTH = 			256
	SCREEN_HEIGHT =			128
	CHAR_WIDTH = 			12
	CHAR_HEIGHT = 			16
	CHAR_SCREEN_WIDTH = 	21
	CHAR_SCREEN_HEIGHT = 	8
	
	;Special characters
	CHAR_ARROW =			'a'	;cursor arrow
	CHAR_BOX =				'b'	;box for drawing error message
	;CHAR_MINUS =			'c'	;actually, better to use - for this
	CHAR_STO =				'd'	;store arrow
	CHAR_EXP =				'e'	;lowercase e exponent
	CHAR_QUOTE = 			34	;double quote
	
	;Object types
	OBJ_FLOAT = 			1
	OBJ_STR = 				2
	OBJ_HEX = 				3
	OBJ_ERROR =				4
	TODO: replace with code that isnt op code, so unlikely to crash on EXEC
	OBJ_PRIMITIVE =			5
	OBJ_SECONDARY =			6
	OBJ_VAR =				7
	
	TYPE_SIZE =				1
	OBJ_SIZE =				9
	OBJ_TYPE =				0	;first bytes of stack item is type
	
	;Input
	TODO: increase size?
	BUFF_SIZE =				64
	WORD_MAX_SIZE =			19	;-1.23456789012e-999
	MAX_DIGITS =			12
	MODE_IMMEDIATE =		64
	MODE_COMPILE =			128
	
	;Key constants
	KEY_BACKSPACE = 		8
	KEY_ENTER = 			13
	KEY_ESCAPE =			27
	
	;Floats
	DEC_COUNT =				12
	SIGN_BIT =				$80
	E_SIGN_BIT =			$40
	FIRST_DIGIT =			1
	LAST_DIGIT =			6
	EXP_LO =				7
	EXP_HI =				8
	;Only in registers, not on stack
	SIGN_INFO =				9
	GR_OFFSET =				1
	
	;Hex fields
	HEX_SUM = 				1
	HEX_BASE =				3
	HEX_OFFSET =			5
	HEX_TYPE =				7
	
	;Hex constants
	HEX_SMART =				1
	
	;Error codes
	ERROR_NONE =				0
	ERROR_INPUT =				2
	ERROR_WORD_TOO_LONG =		4
	;Generic string error. Save room on error messages
	ERROR_STRING =				6
	;ERROR_STRING_TOO_LONG =		3
	;ERROR_STRING_UNTERMINATED =	4
	ERROR_STACK_OVERFLOW =		8
	ERROR_STACK_UNDERFLOW =		10
	ERROR_WRONG_TYPE =			12
	ERROR_DIV_ZERO =			14
	ERROR_IMMED_ONLY =			16
	ERROR_COMPILE_ONLY =		18
	ERROR_OUT_OF_MEM =			20
	ERROR_STRUCTURE =			22
	ERROR_RANGE =				24
	
	;Forth
	;=====
		;Word flags
		NONE =				0
		MIN1 =				1
		MIN2 =				2
		MIN3 =				3
		ADD1 =				4
		;FLOAT1 =			8
		;STRING1 =			16
		;HEX1 =				24
		;FLOAT2 =			32
		;STRING2 =			64
		;HEX2 =				96
		FLOATS =			8
		STRINGS =			16
		HEX =				24
		SAME =				32
		IMMED =				64
		COMPILE =			128
		
		;Word tokens
		;							0 - reserved
		TOKEN_DUP =					2
		TOKEN_SWAP =				4
		TOKEN_DROP =				6
		TOKEN_OVER =				8
		TOKEN_ROT =					10
		TOKEN_MIN_ROT =				12
		TOKEN_CLEAR =				14
		TOKEN_ADD =					16
		TOKEN_SUB =					18
		TOKEN_MULT =				20
		TOKEN_DIV =					22
		TOKEN_TICK =				24
		TOKEN_EXEC =				26
		TOKEN_STORE =				28
		TOKEN_FETCH =				30
		TOKEN_CSTORE =				32
		TOKEN_CFETCH =				34
		TOKEN_COLON =				36
		TOKEN_SEMI =				38
		TOKEN_FLOAT =				40
		TOKEN_HEX =					42
		TOKEN_STRING =				44
		TOKEN_HALT =				46
		TOKEN_VAR =					48
		TOKEN_VAR_THREAD =			50
		TOKEN_STO =					52
		TOKEN_FREE =				54
		TOKEN_SECONDARY =			56
		TOKEN_EXIT =				58
		TOKEN_BREAK =				60
		TOKEN_QUIT =				62
		TOKEN_STO_THREAD =			64
		TOKEN_DO =					66
		TOKEN_DO_THREAD =			68
		TOKEN_LOOP =				70
		TOKEN_LOOP_THREAD =			72
		TOKEN_EQUAL =				74
		TOKEN_GT =					76
		TOKEN_LT =					78
		TOKEN_NEQ =					80
		TOKEN_I =					82
		TOKEN_J =					84
		TOKEN_K =					86
		TOKEN_EXIT_THREAD =			88
		TOKEN_BEGIN =				90
		TOKEN_AGAIN =				92
		TOKEN_AGAIN_THREAD =		94
		TOKEN_UNTIL =				96
		TOKEN_UNTIL_THREAD =		98
		TOKEN_MAX =					100
		TOKEN_MIN =					102
		TOKEN_AND =					104
		TOKEN_OR =					106
		TOKEN_XOR =					108
		TOKEN_NOT =					110
		TOKEN_LEAVE =				112
		TOKEN_LEAVE_THREAD =		114
		TOKEN_IF =					116
		TOKEN_THEN =				118
		TOKEN_ELSE =				120
		TOKEN_LSHIFT =				122
		TOKEN_RSHIFT =				124
		TOKEN_ABS =					126
		TOKEN_PI =					128
		TOKEN_SIN =					130
		TOKEN_COS =					132
		
		;Execution modes
		EXEC_INPUT =		0
		EXEC_THREAD =		1
		
		;Return stack types
		R_RAW =			0
		R_THREAD =		1
		
		;Flag masks
		FLAG_MIN =			3
		FLAG_TYPES =		$38
		
		;Stack
		STACK_SIZE =		8
		SYS_STACK_SIZE =	3
		R_STACK_SIZE =		$30
		
		;Two byte header of each word
		EXEC_HEADER =		2
		
		;Three byte header for empty item at end of stack
		DICT_END_SIZE =		3
		
		;Header for new dictionary words
		WORD_HEADER_SIZE =	7
			;1 - name length
			;2 - next word
			;1 - token
			;1 - type
			;2 - old address
		
		;Auxilliary stack for DO loops and IF addresses	in compile mode
		
		;v1
		;AUX_STACK_ITEM_SIZE =	10		;1 type, 1 func ID, 8 data
		;AUX_STACK_COUNT =		8
		;AUX_STACK_SIZE =		AUX_STACK_COUNT*AUX_STACK_ITEM_SIZE
		
		;v2
		;only LOOP values on stack so no type byte!
		;AUX_STACK_ITEM_SIZE =	9		;1 func ID, 8 data
		;AUX_STACK_COUNT =		8
		;AUX_STACK_SIZE =		AUX_STACK_COUNT*AUX_STACK_ITEM_SIZE
		
		;v3
		;LOOP values only need one type byte per pair
		AUX_STACK_ITEM_SIZE =	(1+8+8)	;1 func ID, 8 for limit, 8 for iterator
		AUX_STACK_COUNT =		4
		AUX_STACK_SIZE =		AUX_STACK_COUNT*AUX_STACK_ITEM_SIZE
		AUX_LIMIT_OFFSET =		1		;limit data begins after type byte
		AUX_ITER_OFFSET =		9		;iterator data begins after limit data
		
		;Reused at compile time to hold addresses
		AUX_STACK_SHORT_SIZE =	AUX_STACK_SIZE / 3
		
		;Data types for auxilliary stack
		AUX_TYPE_DO =			1
		AUX_TYPE_BEGIN =		2
		AUX_TYPE_LEAVE =		3
		AUX_TYPE_IF =			4
		AUX_TYPE_ELSE =			5
			
	
	
	
	
