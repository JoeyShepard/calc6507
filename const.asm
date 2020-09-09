;Constants
;=========

SCREEN_ADDRESS = 		$4000
SCREEN_WIDTH = 			256
SCREEN_HEIGHT =			128
CHAR_WIDTH = 			16
CHAR_HEIGHT = 			16
CHAR_SCREEN_WIDTH = 	16
CHAR_SCREEN_HEIGHT = 	16

;Special characters
CHAR_ARROW =			'a'
CHAR_BOX =				'b'
CHAR_MINUS =			'c'
CHAR_EXP =				'e'
CHAR_QUOTE = 			34	;double quote

;Object types
OBJ_FLOAT = 			1
OBJ_STR = 				2
OBJ_HEX = 				3
OBJ_ERROR =				4
OBJ_PRIMITIVE =			5
OBJ_WORD =				6
OBJ_ARRAY =				7

OBJ_SIZE =				9

;Input buffer
BUFF_SIZE =				64
WORD_MAX_SIZE =			19	;-1.23456789012e-999
MAX_DIGITS =			12

;Key constants
KEY_BACKSPACE = 		8
KEY_ENTER = 			13
KEY_ESCAPE =			27

;Floats
SIGN_BIT =				$80
E_SIGN_BIT =			$40
EXP_LO =				7
EXP_HI =				8

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
	COMPILE_ONLY =		128
	
	;Word tokens
	;				0 - reserved
	TOKEN_DUP =		2
	TOKEN_SWAP =	4
	TOKEN_DROP =	6
	TOKEN_OVER =	8
	TOKEN_ROT =		10
	TOKEN_MIN_ROT =	12
	TOKEN_CLEAR =	14
	TOKEN_ADD =		16
	TOKEN_SUB =		18
	TOKEN_MULT =	20
	TOKEN_DIV =		22
	TOKEN_TICK =	24
	TOKEN_EXEC =	26
	TOKEN_WORD =	28
	
	;Flag masks
	FLAG_MIN =			3
	FLAG_TYPES =		$38
	
	;Stack
	STACK_SIZE =		8
	SYS_STACK_SIZE =	3
	
	;Two byte header of each word
	EXEC_HEADER =		2
	
	
