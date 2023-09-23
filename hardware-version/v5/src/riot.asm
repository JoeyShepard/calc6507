
;Addresses in RIOT
PORT_A		set $880
PORT_A_DIR	set $881
PORT_B		set $882
PORT_B_DIR	set $883

;Pin assignments
;PORT A
KB_IN_0     set 1
KB_IN_1     set 2
KB_IN_2     set 4
KB_IN_3     set 8
KB_IN_4     set $10
LCD_RW      set $20
LCD_E       set $40
LATCH_CP    set $80

;Latch - driven by PORT B
BANK0       set 1
BANK1       set 2
BANK2       set 4
LCD_DI      set 8
LCD_CS1     set $10
LCD_CS2     set $20
LCD_RST     set $40
;$80 not assigned
