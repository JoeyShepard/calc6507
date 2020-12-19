;Constants
;=========

	SCREEN_ADDRESS = 		$4000
	SCREEN_WIDTH = 			256
	SCREEN_HEIGHT =			128
	CHAR_WIDTH = 			12
	CHAR_HEIGHT = 			16
	CHAR_SCREEN_WIDTH = 	16
	CHAR_SCREEN_HEIGHT = 	16
	
	;Special characters
	CHAR_ARROW =			'a'
	CHAR_BOX =				'b'
	;CHAR_MINUS =			'c'	;actually, better to use - for this
	CHAR_EXP =				'e'
	CHAR_QUOTE = 			34	;double quote
	
	;Object types
	OBJ_FLOAT = 			1
	OBJ_STR = 				2
	OBJ_HEX = 				3
	OBJ_ERROR =				4
	TODO: replace with code that isnt op code, so unlikely to crash on EXEC
	OBJ_PRIMITIVE =			5
	OBJ_WORD =				6
	OBJ_VAR =				7
	
	TYPE_SIZE =				1
	OBJ_SIZE =				9
	
	;Input
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
	
	;Forth
	;=====
		;Word flags
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
		;					0 - reserved
		TOKEN_DUP =			2
		TOKEN_SWAP =		4
		TOKEN_DROP =		6
		TOKEN_OVER =		8
		TOKEN_ROT =			10
		TOKEN_MIN_ROT =		12
		TOKEN_CLEAR =		14
		TOKEN_ADD =			16
		TOKEN_SUB =			18
		TOKEN_MULT =		20
		TOKEN_DIV =			22
		TOKEN_TICK =		24
		TOKEN_EXEC =		26
		TOKEN_STORE =		28
		TOKEN_FETCH =		30
		TOKEN_CSTORE =		32
		TOKEN_CFETCH =		34
		TOKEN_COLON =		36
		TOKEN_SEMI =		38
		TOKEN_FLOAT =		40
		TOKEN_HEX =			42
		TOKEN_STRING =		44
		TOKEN_HALT =		46
		TOKEN_VAR =			48
		TOKEN_VAR_DATA =	50
		TOKEN_VAR_THREAD =	52
		TOKEN_STO =			54
		TOKEN_FREE =		56
		
		;Odd tokens - no jump table entry
		TOKEN_DONE =		1
		TOKEN_WORD =		3
		
		;Execution modes
		EXEC_INPUT =		0
		EXEC_THREAD =		1
		
		;Return stack types
		R_RAW =			0
		R_THREAD =		1
		
		;Flag masks
		FLAG_MIN =			3
		FLAG_TYPES =		$38
		FLAG_MODE =			$C0
		
		;Stack
		STACK_SIZE =		8
		SYS_STACK_SIZE =	3
		
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
			
	
	
	
	
