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
CHAR_EXP = 'e'
CHAR_QUOTE = 34			;double quote


;Object types
OBJ_FLOAT = 			1
OBJ_STR = 				2
OBJ_HEX = 				3
OBJ_ERROR =				4

;Input buffer
BUFF_SIZE =				64
WORD_MAX_SIZE =			19	;-1.23456789012e-999
INPUT_Y =				(SCREEN_ADDRESS / 256)+CHAR_HEIGHT*6+12

;Key constants
KEY_BACKSPACE = 		8
KEY_ENTER = 			13
KEY_ESCAPE =			27

;Input modes for float interpretter
MODE_NONE =				1
MODE_DIGITS_PRE	=		2
MODE_DIGITS_POST =		3
MODE_E_FOUND =			4
MODE_E_DIGITS =			5

;Error codes
ERROR_NONE =			0
ERROR_WORD_TOO_LONG =	1
;Generic string error. Save room on error messages
ERROR_STRING =			2
;ERROR_STRING_TOO_LONG
;ERROR_STRING_UNTERMINATED

;Forth
	;Word flags
FORTH_1ITEM =			1
FORTH_2ITEMS =			2
FORTH_3ITEMS =			3
