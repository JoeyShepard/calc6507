

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

;Display memory usage in console
;===============================
	MESSAGE " "
	MESSAGE "Memory usage"
	MESSAGE "============"
	AddCommas EEPROM-$900
	MESSAGE "ROM size:	\{comma_ret} bytes (\{100*(EEPROM-$900)/$8000}%) of 32k ROM"
	;AddCommas GENRAM-$200
	;MESSAGE "RAM size:	\{comma_ret} bytes (\{100*(GENRAM-$200)/($4000-$200)}%) of 15.8k bank"
	;Tell script that prints assembler output to stop outputting
	;Eliminates double output (because of multiple passes???)
	MESSAGE "END"
