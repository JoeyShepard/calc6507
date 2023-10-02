;Hardware specific constants
;===========================
;Must be included before any code is generated

;Constants
;=========
;Memory
RESET_VECTOR    = $FFFC
FIXED_EEPROM    = $900
BANKED_EEPROM   = $1000
BANK0           = 0
BANK1           = 1
BANK2           = 2
BANK3           = 3
BANK4           = 4
BANK5           = 5
BANK6           = 6
BANK7           = 7
BANK0_ADDRESS   = $0000 
BANK1_ADDRESS   = $1000
BANK2_ADDRESS   = $2000
BANK3_ADDRESS   = $3000
BANK4_ADDRESS   = $4000
BANK5_ADDRESS   = $5000
BANK6_ADDRESS   = $6000
BANK7_ADDRESS   = $7000

;LCD commands
LCD_ON          = $3F
LCD_ROW         = $B8
LCD_COL         = $40
LCD_Z           = $C0

;LCD CS
LCD_BOTH        = 0
LCD_LEFT        = $20
LCD_RIGHT       = $10

;Screen constants
SCREEN_WIDTH    = 128   ;Note SCREEN_WIDTH is 256 for emulator
SCREEN_HEIGHT   = 64
CHAR_WIDTH      = 6
CHAR_HEIGHT     = 8
WORDS_Y         = 7

;Keypad constants
KEY_MASK            = $1F
KEY_ALPHA           = 20
KEY_SETTLE_CYCLES   = 100
KEY_DEBOUNCE_CYCLES = 5


;Macros
;======
;10us delay. At 1mhz, each nop is 2us.
delay MACRO
    nop
    nop
    nop
    nop
    nop
    ENDM

LatchLoad MACRO
    LDA #LATCH_CP 
    STA PORT_A
    LDA #0
    STA PORT_A
    ENDM

LCD_Pulse MACRO
    LDA #LCD_E
    STA PORT_A
    delay
    LDA #0
    STA PORT_A
    delay ;probably not necessary
    ENDM

