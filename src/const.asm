;Constants
;=========
	
	;Screen
	equ SCREEN_ADDRESS,		$4000
	equ SCREEN_WIDTH,		256
	equ SCREEN_HEIGHT,		128
	equ CHAR_WIDTH,			12
	equ CHAR_HEIGHT, 		16
	equ CHAR_SCREEN_WIDTH, 	21
	equ CHAR_SCREEN_HEIGHT, 8
	
	;Special characters
	equ CHAR_ARROW,				'a'	;cursor arrow
	equ CHAR_BOX,				'b'	;box for drawing error message
	;equ CHAR_MINUS,			'c'	;actually, better to use - for this
	equ CHAR_STO,				'd'	;store arrow
	equ CHAR_EXP,				'e'	;lowercase e exponent
	equ CHAR_QUOTE, 			34	;double quote
	
	;Object types
	equ OBJ_FLOAT,				1
	equ OBJ_STR, 				2
	equ OBJ_HEX, 				3
	equ OBJ_ERROR,				4
	TODO: replace with code that isnt op code, so unlikely to crash on EXEC
	equ OBJ_PRIMITIVE,			5
	equ OBJ_SECONDARY,			6
	equ OBJ_VAR,				7
	
	equ TYPE_SIZE,				1
	equ OBJ_SIZE,				9
	equ OBJ_TYPE,				0	;first bytes of stack item is type
	
	;Input
	TODO: increase size?
	equ BUFF_SIZE,			64
	equ WORD_MAX_SIZE,		19	;-1.23456789012e-999
	equ MAX_DIGITS,			12
	equ MODE_IMMEDIATE,		64
	equ MODE_COMPILE,		128
	
	;Key constants
	equ KEY_BACKSPACE, 		8
	equ KEY_ENTER, 			13
	equ KEY_ENTER_ALT, 		10  ;Compatibility for key input files on Linux
	equ KEY_ESCAPE,			27
	equ KEY_ON,		        KEY_ESCAPE
	
	;Floats
	equ DEC_COUNT,			12
	equ SIGN_BIT,			$80
	equ E_SIGN_BIT,			$40
	equ FIRST_DIGIT,		6
	equ LAST_DIGIT,			1
	equ EXP_LO,				7
	equ EXP_HI,				8
	;Only in registers, not on stack
	equ SIGN_INFO,			9
	equ GR_OFFSET,			1
	
	;Hex fields
	equ HEX_SUM,			1
	equ HEX_BASE,			3
	equ HEX_OFFSET,			5
	equ HEX_TYPE,			7
	
	;Hex constants
	equ HEX_SMART,			1

    ;Constants for WORDS
    equ WORDS_PRIM,         0
    equ WORDS_VARS,         1
    equ WORDS_USER,         2
    equ WORDS_MODES,        3   ;Count of modes above
    equ WORDS_Y,            SCREEN_ADDRESS+(SCREEN_HEIGHT-CHAR_HEIGHT)*SCREEN_WIDTH
    equ WORD_MSG_LEN,       8
    equ WORDS_ROWS,         7
    equ WORDS_SIZE_X,       17*CHAR_WIDTH

	;Error codes
	equ ERROR_NONE,					0
	equ ERROR_INPUT,				2
	TODO: delete! combined with ERROR_INPUT
	equ ERROR_WORD_TOO_LONG,		4
	TODO: delete! not used
	;Generic string error. Save room on error messages
	equ ERROR_STRING,				6
	;ERROR_STRING_TOO_LONG =		3
	;ERROR_STRING_UNTERMINATED =	4
	equ ERROR_STACK_OVERFLOW,		8
	equ ERROR_STACK_UNDERFLOW,		10
	equ ERROR_WRONG_TYPE,			12
	equ ERROR_DIV_ZERO, 			14
	equ ERROR_IMMED_ONLY, 			16
	equ ERROR_COMPILE_ONLY, 		18
	equ ERROR_OUT_OF_MEM, 			20
	equ ERROR_STRUCTURE, 			22
	equ ERROR_RANGE, 				24
	
	;Forth
	;=====
		;Word flags
		equ NONE, 			0   ;No flags
		equ MIN1,			1   ;At least one item on stack
		equ MIN2,			2   ;At least two items on stack
		equ MIN3,			3   ;At least three items on stack
		equ ADD1,			4   ;Add one stack item for result
		;FLOAT1 =			8
		;STRING1 =			16
		;HEX1 =				24
		;FLOAT2 =			32
		;STRING2 =			64
		;HEX2 =				96
		equ FLOATS,			8   ;Minimum items on stack must be floats
		equ STRINGS,		16  ;Minimum items on stack must be strings
		equ HEX,			24  ;Minimum items on stack must be hex
		equ SAME,			32  ;Minimum items on stack must be floats
		equ IMMED,			64
		equ COMPILE,		128 ;Compile-only
		
		;Word tokens
		;							0 - reserved
		equ TOKEN_DUP,				2
		equ TOKEN_SWAP,				4
		equ TOKEN_DROP,				6
		equ TOKEN_OVER,				8
		equ TOKEN_ROT,				10
		equ TOKEN_MIN_ROT,			12
		equ TOKEN_CLEAR,			14
		equ TOKEN_ADD,				16
		equ TOKEN_SUB,				18
		equ TOKEN_MULT,				20
		equ TOKEN_DIV,				22
		equ TOKEN_TICK,				24
		equ TOKEN_EXEC,				26
		equ TOKEN_STORE,			28
		equ TOKEN_FETCH,			30
		equ TOKEN_CSTORE,			32
		equ TOKEN_CFETCH,			34
		equ TOKEN_COLON,			36
		equ TOKEN_SEMI,				38
		equ TOKEN_FLOAT,			40
		equ TOKEN_HEX,				42
		equ TOKEN_STRING,			44
		equ TOKEN_HALT,				46
		equ TOKEN_VAR,				48
		equ TOKEN_VAR_THREAD,		50
		equ TOKEN_STO,				52
		equ TOKEN_FREE,				54
		equ TOKEN_SECONDARY,		56
		equ TOKEN_EXIT,				58
		equ TOKEN_BREAK,			60
		equ TOKEN_QUIT,				62
		equ TOKEN_STO_THREAD,		64
		equ TOKEN_DO,				66
		equ TOKEN_DO_THREAD,		68
		equ TOKEN_LOOP,				70
		equ TOKEN_LOOP_THREAD,		72
		equ TOKEN_EQUAL,			74
		equ TOKEN_GT,				76
		equ TOKEN_LT,				78
		equ TOKEN_NEQ,				80
		equ TOKEN_I,				82
		equ TOKEN_J,				84
		equ TOKEN_K,				86
		equ TOKEN_EXIT_THREAD,		88
		equ TOKEN_BEGIN,			90
		equ TOKEN_AGAIN,			92
		equ TOKEN_AGAIN_THREAD,		94
		equ TOKEN_UNTIL,			96
		equ TOKEN_UNTIL_THREAD,		98
		equ TOKEN_MAX,				100
		equ TOKEN_MIN,				102
		equ TOKEN_AND,				104
		equ TOKEN_OR,				106
		equ TOKEN_XOR,				108
		equ TOKEN_NOT,				110
		equ TOKEN_LEAVE,			112
		equ TOKEN_LEAVE_THREAD,		114
		equ TOKEN_IF,				116
		equ TOKEN_THEN,				118
		equ TOKEN_ELSE,				120
		equ TOKEN_LSHIFT,			122
		equ TOKEN_RSHIFT,			124
		equ TOKEN_ABS,				126
		equ TOKEN_PI,				128
		equ TOKEN_SIN,				130
		equ TOKEN_COS,				132
		equ TOKEN_TAN,				134
		equ TOKEN_ASIN,				136
		equ TOKEN_ACOS,				138
		equ TOKEN_ATAN,				140
		equ TOKEN_DEG,				142
        equ TOKEN_WORDS,            144
		
		;Execution modes
		equ EXEC_INPUT,			0
		equ EXEC_THREAD,		1
		
		;Return stack types
		equ R_RAW,				0
		equ R_THREAD,			1
		
		;Flag masks
		equ FLAG_MIN,			3
		equ FLAG_TYPES,			$38
		
		;Stack
		equ STACK_SIZE,			8
		equ SYS_STACK_SIZE,		3
		equ R_STACK_SIZE,		$30
	    equ HW_STACK_BEGIN,     $100

		;Two byte header of each word
		equ EXEC_HEADER,		2
		
		;Three byte header for empty item at end of stack
		equ DICT_END_SIZE,		3
		
		;Header for new dictionary words
		equ WORD_HEADER_SIZE,	7
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
		equ AUX_STACK_ITEM_SIZE,	(1+8+8)	;1 func ID, 8 for limit, 8 for iterator
		equ AUX_STACK_COUNT,		4
		equ AUX_STACK_SIZE,		AUX_STACK_COUNT*AUX_STACK_ITEM_SIZE
		equ AUX_LIMIT_OFFSET,		1		;limit data begins after type byte
		equ AUX_ITER_OFFSET,		9		;iterator data begins after limit data
		
		;Reused at compile time to hold addresses
		equ AUX_STACK_SHORT_SIZE,	AUX_STACK_SIZE / 3
		
		;Data types for auxilliary stack
		equ AUX_TYPE_DO,			1
		equ AUX_TYPE_BEGIN,			2
		equ AUX_TYPE_LEAVE,			3
		equ AUX_TYPE_IF,			4
		;equ AUX_TYPE_ELSE,			5	;reuse AUX_TYPE_IF since behavior is the same
		equ AUX_TYPE_CLEARED,		6	;set AUX_TYPE_IF to CLEARED instead of popping
		
