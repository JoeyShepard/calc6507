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

;Key constants
KEY_BACKSPACE = 		8
KEY_ENTER = 			13
KEY_ESCAPE =			27

;Error codes
ERROR_NONE =			0
ERROR_WORD_TOO_LONG =	1
;Generic string error. Save room on error messages
ERROR_STRING =			2
;ERROR_STRING_TOO_LONG
;ERROR_STRING_UNTERMINATED

;Forth
	;Word flags
	MIN_1 =				1
	MIN_2 =				2
	MIN_3 =				3
	ADD_1 =				4
