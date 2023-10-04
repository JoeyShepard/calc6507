

EEPROM set *

	OUTRADIX 10

AddCommas MACRO num
comma_ret set "\{num}"
	IF num<1000
		EXITM
	ELSE
comma_ret set "\{substr(comma_ret,0,strlen(comma_ret)-3)},\{substr(comma_ret,strlen(comma_ret)-3,strlen(comma_ret))}"
	ENDIF
	ENDM

Align4 MACRO num
    SET spaces,"    "
    SET align_return,"\{num}"
    IF strlen(align_return)>=4
        EXITM
    ENDIF
    SET align_return,"\{num}\{substr(spaces,0,4-strlen(align_return))}"
    ENDM

HeaderSize MACRO hname
    Align4 hname_asm_end-hname_asm_begin
    set hname_asm_size, align_return
    ENDM

BankAlignSize MACRO bname
    Align4 bname_END-BANKED_EEPROM
    set bname_ALIGNED_SIZE, align_return
    ENDM

;Display memory usage in console
;===============================
	;MESSAGE " "
	;MESSAGE "Memory usage"
	;MESSAGE "============"
    ;Banked system makes calculation difficult. Calculate by bank instead.
	;AddCommas EEPROM-$900
	;MESSAGE "ROM size:	\{comma_ret} bytes (\{100*(EEPROM-$900)/$8000}%) of 32k ROM"
	;AddCommas GENRAM-$200
	;MESSAGE "RAM size:	\{comma_ret} bytes (\{100*(GENRAM-$200)/($4000-$200)}%) of 15.8k bank"
    
    ;v1
    ;MESSAGE "Fixed ROM size: \{code_end-FIXED_EEPROM} of \{BANKED_EEPROM-FIXED_EEPROM} bytes"
    ;MESSAGE "BANK 1 size: \{BANK1_END-BANKED_EEPROM} of 4096 bytes"
    ;MESSAGE "BANK 2 size: \{BANK2_END-BANKED_EEPROM} of 4096 bytes"
    ;MESSAGE "BANK 3 size: \{BANK3_END-BANKED_EEPROM} of 4096 bytes"
    ;MESSAGE "BANK 4 size: \{BANK4_END-BANKED_EEPROM} of 4096 bytes"
    ;MESSAGE "Size check: \{size_check_end-size_check_begin} bytes"

    ;v2
    ;MESSAGE "Fixed ROM size: \{code_end-FIXED_EEPROM} of \{BANKED_EEPROM-FIXED_EEPROM} bytes"
    ;Align4 BANK1_END-BANKED_EEPROM
    ;SET BANK1_ALIGN,"\{align_return}"
    ;Align4 BANK2_END-BANKED_EEPROM
    ;SET BANK2_ALIGN,"\{align_return}"
    ;Align4 BANK3_END-BANKED_EEPROM
    ;SET BANK3_ALIGN,"\{align_return}"
    ;Align4 BANK4_END-BANKED_EEPROM
    ;SET BANK4_ALIGN,"\{align_return}"
    ;MESSAGE "Banks: 1:\{BANK1_ALIGN}|2:\{BANK1_ALIGN}|3:\{BANK1_ALIGN}|4:\{BANK1_ALIGN} of 4096 bytes"
   
    ;v3
    ;MESSAGE "Fixed ROM size: \{code_end-FIXED_EEPROM} of \{BANKED_EEPROM-FIXED_EEPROM} bytes"
    ;MESSAGE "- Banking code: \{banking_end-banking_begin} bytes (7+1+2 bytes per function)"
    ;MESSAGE "Bank 1:\{BANK1_END-BANKED_EEPROM} | 2:\{BANK2_END-BANKED_EEPROM} | 3:\{BANK3_END-BANKED_EEPROM} | 4:\{BANK4_END-BANKED_EEPROM} of 4096 bytes"
    ;MESSAGE "Size check: \{size_check_end-size_check_begin} bytes"

    ;v4
    MESSAGE "Fixed ROM size: \{code_end-FIXED_EEPROM} of \{BANKED_EEPROM-FIXED_EEPROM} bytes"
    ;MESSAGE "- Banking code: \{banking_end-banking_begin} bytes (7+1+2 bytes per function)"
    ;MESSAGE "Bank 1:\{BANK1_END-BANKED_EEPROM} | 2:\{BANK2_END-BANKED_EEPROM} | 3:\{BANK3_END-BANKED_EEPROM} | 4:\{BANK4_END-BANKED_EEPROM} of 4096 bytes"
    ;MESSAGE "Size check: \{size_check_end-size_check_begin} bytes"
    MESSAGE "Bank            1      2      3"
    HeaderSize hardware
    HeaderSize output
    HeaderSize forth
    HeaderSize forthloop
    HeaderSize error
    HeaderSize math
    HeaderSize cordic
    HeaderSize words
    HeaderSize word_stubs
    HeaderSize aux_stack
    BankAlignSize BANK1
    BankAlignSize BANK2
    BankAlignSize BANK3
    BankAlignSize BANK4
    MESSAGE "hardware.asm    \{hardware_asm_size}   \{math_asm_size}   \{words_asm_size}"
    MESSAGE "output.asm      \{output_asm_size}   \{cordic_asm_size}   \{word_stubs_asm_size}"
    MESSAGE "forth.asm       \{forth_asm_size}          \{aux_stack_asm_size}"
    MESSAGE "forth_loop.asm  \{forthloop_asm_size}"
    MESSAGE "error.asm       \{error_asm_size}"
    MESSAGE "Total           \{BANK1_ALIGNED_SIZE}   \{BANK2_ALIGNED_SIZE}   \{BANK3_ALIGNED_SIZE}   \{BANK4_ALIGNED_SIZE}"

	;Tell script that prints assembler output to stop outputting
	;Eliminates double output (because of multiple passes?)
	MESSAGE "END"
