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

;Hex fields
HEX_SUM = 				1
HEX_BASE =				3
HEX_OFFSET =			5
HEX_TYPE =				7

;Hex constants
HEX_SMART =				1

;Error codes
ERROR_NONE =				0
ERROR_WORD_TOO_LONG =		2
;Generic string error. Save room on error messages
ERROR_STRING =				4
;ERROR_STRING_TOO_LONG =		3
;ERROR_STRING_UNTERMINATED =	4
ERROR_STACK_OVERFLOW =		6
ERROR_STACK_UNDERFLOW =		8
;Input not recognized
ERROR_INPUT =				10
ERROR_WRONG_TYPE =			12


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
	
	;Flag masks
	FLAG_MIN =			3
	FLAG_TYPES =		$38
	
	
	
	STACK_SIZE =		8
